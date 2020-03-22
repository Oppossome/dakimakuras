if SERVER then  util.AddNetworkString("dakimakuras-net") end

local function AInclude( file )
	local context = string.match(file, "(%w+)_.-%.lua")
	file = "dakimakuras/" .. file

	if context then
		if context == "sh" or context == "cl" then
			AddCSLuaFile( file )
		end

		if context == "sv" and SERVER then
			include( file )
		end

		if context == "cl" and CLIENT then
			include( file )
		end

		if context == "sh" then
			include( file )
		end
	end
end

AInclude("cl_img-loader.lua")
AInclude("cl_dakihistory.lua")
AInclude("cl_dakimenu.lua")
AInclude("sv_spawnlogic.lua")
