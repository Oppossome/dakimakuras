Dakimakuras = Dakimakuras or {}
Dakimakuras.History = Dakimakuras.History or {}
Dakimakuras.Blacklist = Dakimakuras.Blacklist or {}

function Dakimakuras.RemoveDaki( Front, Back, ShouldSave )
	for Ind, Data in pairs( Dakimakuras.History )do
		if( Data.Front == Front and Data.Back == Back )then
			table.remove( Dakimakuras.History, Ind )
		end
	end
	
	if( ShouldSave )then
		Dakimakuras.Save()
	end
end

function Dakimakuras.RegisterDaki( Front, Back )
	Dakimakuras.RemoveDaki( Front, Back )
	
	table.insert(Dakimakuras.History, 1, {
		["Front"] = Front;
		["Back"] = Back;
	})
	
	Dakimakuras.Save()
end

function Dakimakuras.BlacklistUser( SteamId, Bool )
	Dakimakuras.Blacklist[ SteamId ] = ( Bool == true and true or nil )
	Dakimakuras.Save()
	
	for _, ent in pairs( ents.FindByClass("prop_dakimakura") )do
		if( ent:GetDegenerate() == SteamId )then
			ent:UpdateImages()
		end
	end
end

function Dakimakuras.Save()
	local RawBlacklist = util.TableToJSON( Dakimakuras.Blacklist )
	local RawHistory = util.TableToJSON( Dakimakuras.History )
	cookie.Set("daki-blacklist", RawBlacklist )
	cookie.Set("daki-history", RawHistory )
end

function Dakimakuras.Load()
	local RawBlacklist = cookie.GetString("daki-blacklist", "{}" )
	local RawHistory = cookie.GetString("daki-history", "{}" )
	Dakimakuras.Blacklist = util.JSONToTable( RawBlacklist )
	Dakimakuras.History = util.JSONToTable( RawHistory )
end

hook.Add("InitPostEntity", "Dakimakuras", Dakimakuras.Load)

CreateClientConVar("dakimakura_enable", "1", true, false, "Disable the pesky bodypillows that haunt you in your dreams")
cvars.AddChangeCallback("dakimakura_enable", function( Name, Old, New )
	for _, ent in pairs( ents.FindByClass("prop_dakimakura") )do
		ent:UpdateImages()
	end
end)