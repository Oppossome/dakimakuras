AddCSLuaFile()


ENT.PrintName = "Dakimakura"
ENT.Information = "A bodypillow"
ENT.Category = "Fun + Games"
ENT.Author = "Sera"

ENT.Spawnable = true
ENT.Base = "base_gmodentity"
ENT.Type = "point" // this is more of a controller than it is the actual entity now

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
		self:SetLastUsed(CurTime())
		self.ragdoll = rag // for server to bail if they remove it
		rag.TimeOffset = 0
		rag.controller = self
		rag.isDaki = true
		rag.lastUsed = CurTime()
		rag:CPPISetOwner( self.Owner )
		
	else
		self.ScaleFactor = 1
		self.LastUsed = CurTime()
		self.Squishing = false
	end

end

function ENT:OnRemove()

	if(IsValid(self.ragdoll))then
		self.ragdoll:Remove()
	end

end

function ENT:SpawnFunction( Ply )
	net.Start("dakimakuras-net")
	net.Send( Ply )
	self.Owner = Ply
	self.spawnTime = CurTime()
end

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "FrontImage" )
	self:NetworkVar( "String", 1, "BackImage" )
	self:NetworkVar( "String", 2, "Degenerate" )
	self:NetworkVar( "Bool", 3, "IsNSFW" )
	self:NetworkVar( "Entity", 4, "Ragdoll" )
	self:NetworkVar( "Float", 5, "LastUsed" )	
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

function UpdateBones( ent, scale ) // do NOT call on server!

	for bone = 0, 3 do
		ent:ManipulateBoneScale( bone, Vector( scale, scale, scale ) )
	end

end

local function lerp( a, b, p )
	return a*p + b*(1-p)
end

function ENT:Think()

	if( SERVER )then

		if( !IsValid(self.ragdoll) ) then
			self:Remove()
		end

		
	else
	
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
		
		local squished = (0.9 + math.Clamp( CurTime() - self:GetLastUsed(), 0, 0.2 )/2 )
		self.ScaleFactor = lerp( self.ScaleFactor, squished, 0.95 )

		UpdateBones( self:GetRagdoll(), self.ScaleFactor )

	end
	
end


function ENT:PostEntityPaste( Player )
	self:SetDegenerate( Player:SteamID() )
end