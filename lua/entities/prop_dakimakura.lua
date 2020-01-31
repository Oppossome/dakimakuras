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
	else
		self:OnVarChanged()
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
	
	self:NetworkVarNotify( "FrontImage", self.OnVarChanged )
	self:NetworkVarNotify( "BackImage", self.OnVarChanged )
end

function ENT:OnVarChanged()
	timer.Simple( 0.5, function()
		if( IsValid( self ) )then
			self:UpdateImages()
		end
	end)
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

function ENT:PostEntityPaste( Player )
	self:SetDegenerate( Player:SteamID() )
end