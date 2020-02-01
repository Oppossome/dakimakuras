AddCSLuaFile()

ENT.PrintName = "Dakimakura"
ENT.Information = "A bodypillow"
ENT.Category = "Fun + Games"
ENT.Author = "Sera"

ENT.Spawnable = true
ENT.Base = "base_anim"
ENT.Type = "anim"

function ENT:Initialize()
	if( SERVER )then
		self:SetModel("models/dakimakura/daki.mdl")
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
	end
end

function ENT:SpawnFunction( Ply )
	net.Start("dakimakuras-net")
	net.Send( Ply )
end

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "FrontImage" )
	self:NetworkVar( "String", 1, "BackImage" )
	self:NetworkVar( "String", 2, "Degenerate" )
	
	if( SERVER )then  return  end
	self:NetworkVarNotify( "FrontImage", self.OnVarChanged )
	self:NetworkVarNotify( "BackImage", self.OnVarChanged )
end

function ENT:OnVarChanged()
	self.NeedUpdate = CurTime() + .1
end

function ENT:UpdateImages()
	if( SERVER )then  return  end
	local Enabled = GetConVar("dakimakura_enable")
	
	for Id, Url in pairs({ self:GetFrontImage(), self:GetBackImage() }) do	
		Dakimakuras.LoadImg( Url, function( Mat )
			if( IsValid( self ) )then				
				if( not Dakimakuras.Blacklist[ self:GetDegenerate() ] and Enabled:GetBool() )then
					self:SetSubMaterial( Id - 1, Mat )
				else
					self:SetSubMaterial( Id - 1, "" )
				end
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
			self.NeedUpdate = nil
			self:UpdateImages()
		end
	end
end

function ENT:Use( Activator )
	if( IsValid( Activator ) and Activator:IsPlayer() )then
		Activator:PickupObject( self )
	end
end

function ENT:PostEntityPaste( Player )
	self:SetDegenerate( Player:SteamID() )
end