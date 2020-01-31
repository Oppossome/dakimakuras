Dakimakuras = Dakimakuras or {}
Dakimakuras.ImgCache = Dakimakuras.ImgCache or {}

-- Send help, this is painfully hacky
local function NearestPow2( Number )
	for i = 1, 200 do
		if( 2 ^ i > Number )then
			return 2 ^ i
		end
	end
	
	return 0
end

local Queue = {}
function Dakimakuras.LoadImg( Url, Callback )
	Url = Url:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;")
	if( Dakimakuras.ImgCache[ Url ] )then  
		Callback( Dakimakuras.ImgCache[ Url ] )  
		return  
	end
	
	local ImgPanel = vgui.Create("DHTML")
	ImgPanel:SetMouseInputEnabled( false )
	ImgPanel:SetAlpha( 0 )
	
	ImgPanel:SetHTML([[
		<html>
			<body>
				<head>
					<style type="text/css">
						html {
							overflow: hidden;
						}
						
						body {
							padding:0px 0px;
							margin:0px 0px;
						}
					</style					
				</head>
				
				<script>
					function FullyLoaded(){
						var img = document.getElementById("img");
						console.log('Loaded: '+img.width+' '+img.height);
					}
				</script>
			
				<img id="img" src="]]..Url..[[" onLoad="FullyLoaded()"></img>
			</body>
		</html>
	]])
	
	function ImgPanel.ConsoleMessage(self, msg)
		local Width, Height = select( 3, msg:find("Loaded: (%w+) (%w+)") )
		local Width, Height = tonumber( Width ), tonumber( Height )
	
		if( Width and Height )then
			ImgPanel:SetSize( Width, Height )
			ImgPanel.Loaded = true
			
			timer.Simple(1, function()
				ImgPanel:UpdateHTMLTexture() 
			
				table.insert( Queue, {
					["Width"] = Width / NearestPow2( Width ),
					["Height"] = Height / NearestPow2( Height ),
					["Callback"] = Callback,
					["Start"] = CurTime(),
					["Panel"] = ImgPanel,
					["Url"] = Url
				})
			end)
		end
	end
	
	timer.Simple( 15, function()
		if( IsValid( ImgPanel ) and not ImgPanel.Loaded )then
			ImgPanel:Remove()
		end
	end)
end 

hook.Add("Think", "Dakimakura-ImgLoad", function()
	for Ind, Data in pairs( Queue ) do
		if( Data.Panel:GetHTMLMaterial() and not Data.Panel:IsLoading())then
			local HTMLMaterial = Data.Panel:GetHTMLMaterial()
			
			local Mat = CreateMaterial( HTMLMaterial:GetName():Replace("__vgui_texture_","__daki-"), "VertexLitGeneric", {
				["$basetexturetransform"] = string.format("center 0 0 scale %s %s rotate 0 translate 0 0", Data.Width, Data.Height),
				["$basetexture"] = HTMLMaterial:GetName(),
				["$vertexcolor"] = "1",
				["$nolod"] = "1",
				["$model"] = "1",
			})
			
			Dakimakuras.ImgCache[ Data.Url ] = "!"..Mat:GetName()
			Data.Callback( "!"..Mat:GetName() )
			table.remove( Queue, Ind )
			Data.Panel:Remove()
		elseif( CurTime() > Data.Start + 30 )then
			table.remove( Queue, Ind )
			Data.Panel:Remove()
		end
	end
end)