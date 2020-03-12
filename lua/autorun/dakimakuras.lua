
if( SERVER )then
	util.AddNetworkString("dakimakuras-net")
	
	print("h")
	
	hook.Remove("FindUseEntity", "daki_use_hook")
	
	hook.Add( "PlayerUse", "daki_use_hook", function( ply, ent )
		if ( !IsValid( ent ) or !(ent:GetClass() == "prop_ragdoll") ) then return end
			if( ent.isDaki )then
			
				if( CurTime() - ent.controller:GetLastUsed() > 0.1 ) then
					ent.TimeOffset = 65 - engine.TickCount()%66
				end
			
				ent.controller:SetLastUsed(CurTime())	
				
				if( ply:Health() < ply:GetMaxHealth() and ((engine.TickCount()+ent.TimeOffset) % 66 == 0) )then
					ply:SetHealth( ply:Health() + 1 ) // heal them incredibly slowly
				end
				
			end
	end )
	
end

local function AInclude( File )
	local Context = select(3, File:reverse():find(".-_(%w+)"))
	File = "dakimakuras/"..File
	
	if( Context )then
		Context = Context:reverse():lower()
		
		if( Context == "sh" or Context == "cl" )then
			AddCSLuaFile( File )
		end
		
		if( Context == "sv" and SERVER )then
			include( File )
		end
		
		if( Context == "cl" and CLIENT )then
			include( File )
		end
		
		if( Context == "sh" )then
			include( File )
		end
	end
end

AInclude("cl_img-loader.lua")
AInclude("cl_dakihistory.lua")
AInclude("cl_dakimenu.lua")
AInclude("sv_spawnlogic.lua")