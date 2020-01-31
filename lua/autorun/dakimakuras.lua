if( SERVER )then  util.AddNetworkString("dakimakuras-net")  end

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