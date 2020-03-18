AddCSLuaFile()

ENT.PrintName = "Dakimakura"
ENT.Information = "A bodypillow"
ENT.Category = "Fun + Games"
ENT.Author = "Sera"

ENT.Spawnable = false
ENT.Base = "base_gmodentity"
ENT.Type = "point"


function ENT:Initialize()
	if( SERVER )then
		local rag = ents.Create( "prop_ragdoll" )
		if ( !IsValid( rag ) ) then return end // Check whether we successfully made an entity, if not - bail
		rag:SetModel("models/dakimakura/daki_phys.mdl")
		rag:SetPos( self:GetPos() )
		rag:SetAngles( self:GetAngles() )
		rag:Spawn()
		rag:Activate()
		self:SetRagdoll(rag)
		self.ragdoll = rag // for server to bail if they remove it
		rag:CPPISetOwner( self.Owner )
		
	end
end

function ENT:OnRemove()

	if(IsValid(self.ragdoll))then
		self.ragdoll:Remove()
	end

end

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "FrontImage" )
	self:NetworkVar( "String", 1, "BackImage" )
	self:NetworkVar( "String", 2, "Degenerate" )
	self:NetworkVar( "Bool", 3, "IsNSFW" )
	self:NetworkVar( "Entity", 4, "Ragdoll" )
	
	if( SERVER )then  return  end
	self:NetworkVarNotify( "FrontImage", self.OnVarChanged )
	self:NetworkVarNotify( "BackImage", self.OnVarChanged )
end

function ENT:OnVarChanged()
	self.NeedUpdate = CurTime() + .1
end

function ENT:ShouldRender()
	if( not GetConVar("dakimakura_nsfw"):GetBool() and self:GetIsNSFW() )then  return false  end
	if( not GetConVar("dakimakura_enable"):GetBool() )then  return false  end 
	if( Dakimakuras.Blacklist[ self:GetDegenerate() ] )then  return false  end
	return true
end

function ENT:GetSelf()
	return self.ragdoll
end

function ENT:UpdateImages()
	if( SERVER )then  return  end
	for Id, Url in pairs({ self:GetFrontImage(), self:GetBackImage() }) do	
		Dakimakuras.LoadImg( Url, function( Mat )
			local rag = self:GetRagdoll()
			if( IsValid(rag) ) then
				if( true or self:ShouldRender() )then
					rag:SetSubMaterial( Id - 1, Mat )
				else
					rag:SetSubMaterial( Id - 1, "" )
				end
			else
				return CurTime() + .5
			end
		end)
	end
end

function ENT:Think()

	if( CLIENT )then
		local IsDormant = self:IsDormant()
		if( IsDormant ~= self.DakiDormant )then
			self.DakiDormant = IsDormant
			
			if( not IsDormant )then
				self.NeedUpdate = CurTime() + .5
			end
		end
		if( self.NeedUpdate and self.NeedUpdate < CurTime() )then
			self.NeedUpdate = self:UpdateImages()
		end
	else
		if( !IsValid(self.ragdoll) ) then
			self:Remove()
		end
	end
	
end


function ENT:PostEntityPaste( Player )
	self:SetDegenerate( Player:SteamID() )
end