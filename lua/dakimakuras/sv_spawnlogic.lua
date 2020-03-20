resource.AddSingleFile("materials/models/dakimakura/dakifront.vmt")
resource.AddSingleFile("materials/models/dakimakura/dakifront.vtf")
resource.AddSingleFile("materials/models/dakimakura/dakiback.vmt")
resource.AddSingleFile("materials/models/dakimakura/dakiback.vtf")
resource.AddFile("models/dakimakura/daki_phys.mdl")

net.Receive("dakimakuras-net", function( Len, Player )
	local CanSpawn = hook.Run("PlayerSpawnSENT", Player, "prop_dakimakura")
	local EyeTrace = Player:GetEyeTrace()
	
	if( CanSpawn == nil or CanSpawn == true )then
		local Front, Back, IsNSFW, IsFloppy = net.ReadString(), net.ReadString(), net.ReadBool(), net.ReadBool()
		local Daki = nil
		if( IsFloppy ) then
			Daki = ents.Create("prop_dakimakura_physics")
		else
			Daki = ents.Create("prop_dakimakura")		
		end
		Daki:SetPos( EyeTrace.HitPos + EyeTrace.HitNormal * 50 )
		Daki:SetDegenerate( Player:SteamID() )
		Daki:Spawn()
		Daki:EmitSound("garrysmod/balloon_pop_cute.wav",90,100)
		if( !IsFloppy ) then
			Daki:PhysWake()
		end
		
		timer.Simple( .05, function()
			Daki:SetIsNSFW( IsNSFW )
			Daki:SetFrontImage( Front )
			Daki:SetBackImage( Back )
		end)


		
		undo.Create("Dakimakura")
			undo.SetCustomUndoText("Undone Dakimakura")
			undo.SetPlayer( Player )
			undo.AddEntity( Daki )
		undo.Finish()
	end
end)