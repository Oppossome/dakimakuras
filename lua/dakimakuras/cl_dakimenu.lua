local DakiMenu = {}

function DakiMenu:Init()
	self:SetTitle("Daki Builder")
	self:SetSize( 600, 500 )
	
	self.SelectDaki = self:Add("DButton")
	self.SelectDaki:SetText("Upload Daki")
	self.SelectDaki:DockMargin( 0, 3, 0, 0 )
	self.SelectDaki:Dock( BOTTOM )
	
	self.SelectDaki.DoClick = function()
		net.Start("dakimakuras-net")
			net.WriteString( self.FrontEntry:GetValue() )
			net.WriteString( self.BackEntry:GetValue() )
			net.WriteBool( self.IsNSFW:GetChecked() )
			net.WriteBool( self.IsFloppy:GetChecked() )
		net.SendToServer()
		Dakimakuras.RegisterDaki( self.FrontEntry:GetValue(), self.BackEntry:GetValue(), self.IsNSFW:GetChecked() )
		self:Close()
	end
	
	self.DakiViewer = self:Add("DAdjustableModelPanel")
	self.DakiViewer:SetModel("models/dakimakura/daki.mdl")
	self.DakiViewer:SetWidth( 200 )
	self.DakiViewer:Dock( RIGHT )
	self.DakiViewer:SetCamPos( Vector( -200, 0, 0 ) )
	self.DakiViewer:SetFOV( 10 )
	
	self.Switcher = self:Add("DPropertySheet")
	self.Switcher:Dock( FILL )
	
	--> Start of builder tab
	self.Builder = self.Switcher:Add("DPanel")
	self.Switcher:AddSheet("Builder", self.Builder, "icon16/pencil.png")
	
	--> Frontside Entry
	self.Front = self.Builder:Add("DPanel")
	self.Front.Paint = function()  end
	self.Front:Dock( TOP )
	
	self.FrontText = self.Front:Add("DLabel")
	self.FrontText:SetText("Front:")
	self.FrontText:SetTextColor( Color( 0, 0, 0 ) )
	self.FrontText:DockMargin( 5, 0, 0, 0 )
	self.FrontText:Dock( LEFT )
	self.FrontText:SetWide(40)

	self.FrontEntry = self.Front:Add("DTextEntry")
	self.FrontEntry:DockMargin( 0, 3, 3, 3 )
	self.FrontEntry:Dock( FILL )
	
	--> Backside Entry
	self.Back = self.Builder:Add("DPanel")
	self.Back.Paint = function()  end
	self.Back:Dock( TOP )

	self.BackText = self.Back:Add("DLabel")
	self.BackText:SetText("Back:")
	self.BackText:SetTextColor( Color( 0, 0, 0 ) )
	self.BackText:DockMargin( 5, 0, 0, 0 )
	self.BackText:Dock( LEFT )
	self.BackText:SetWide(40)

	self.BackEntry = self.Back:Add("DTextEntry")
	self.BackEntry:DockMargin( 0, 3, 3, 3 )
	self.BackEntry:Dock( FILL )
	
	self.FrontEntry.OnLoseFocus = function() self:UpdateDaki() end
	self.BackEntry.OnLoseFocus = function() self:UpdateDaki() end
	
	--> Is Pillow NSFW?
	self.NSFWPanel = self.Builder:Add("DPanel")
	self.NSFWPanel.Paint = function()  end
	self.NSFWPanel:SetTall( 15 )
	self.NSFWPanel:DockMargin( 0, 5, 0, 0 )
	self.NSFWPanel:Dock( TOP )
	
	self.NSFWLabel = self.NSFWPanel:Add("DLabel")
	self.NSFWLabel:SetWide(48)
	self.NSFWLabel:SetTextColor( Color( 0, 0, 0 ) )
	self.NSFWLabel:SetText("Is NSFW")
	self.NSFWLabel:DockMargin( 5, 0, 0, 0 )
	self.NSFWLabel:Dock( LEFT )

	self.IsNSFW = self.NSFWPanel:Add("DCheckBox")
	self.IsNSFW:DockMargin( 0, 0, 0, 0 )
	self.IsNSFW:Dock( LEFT )

	self.FloppyLabel = self.NSFWPanel:Add("DLabel")
	self.FloppyLabel:SetWide(74)
	self.FloppyLabel:SetTextColor( Color( 0, 0, 0 ) )
	self.FloppyLabel:SetText("Spawn Floppy ")
	self.FloppyLabel:DockMargin( 20, 0, 0, 0 )
	self.FloppyLabel:Dock( LEFT )

	self.IsFloppy = self.NSFWPanel:Add("DCheckBox")
	self.IsFloppy:DockMargin( 0, 0, 0, 0 )
	self.IsFloppy:Dock( LEFT )
	
	--> Start of history tab
	self.HistoryTab = self.Switcher:Add("DPanel")
	self.Switcher:AddSheet( "History", self.HistoryTab, "icon16/hourglass.png")
	
	self.HistoryScroll = self.HistoryTab:Add("DScrollPanel")
	self.HistoryScroll:Dock( FILL )
	
	self.History = self.HistoryScroll:Add("DIconLayout")
	self.History:SetSpaceX( 5 )
	self.History:SetSpaceY( 5 )
	self.History:DockMargin( 5, 5, 0, 0 )
	self.History:Dock( FILL )
	
	--> Start of block tab
	self.BlockTab = self.Switcher:Add("DScrollPanel")
	self.Switcher:AddSheet( "Blocklist", self.BlockTab, "icon16/user_delete.png")
	
	--> Populate History
	for _, Data in pairs( Dakimakuras.History ) do
		self:AddHistoryObject( Data )
	end
	
	for _, ply in pairs( player.GetAll() ) do
		self:AddBlockButton( ply )
	end
	
	self:Center()
end

function DakiMenu:UpdateDaki()
	for Id, Text in pairs({ self.FrontEntry:GetValue(), self.BackEntry:GetValue() }) do
		if( Text ~= "" )then  
			Dakimakuras.LoadImg( Text, function( Mat )
				if( IsValid( self ) )then
					self.DakiViewer.Entity:SetSubMaterial( Id - 1, Mat )
				end
			end)
		else
			self.DakiViewer.Entity:SetSubMaterial( Id - 1, "" )
		end
	end
end

function DakiMenu:AddBlockButton( Ply )
	local BlockButton = self.BlockTab:Add("DButton")
	BlockButton.UserName = Ply:GetName()
	BlockButton.SteamID = Ply:SteamID()
	BlockButton:DockMargin( 3, 3, 3, 0 )
	BlockButton:Dock( TOP )
		
	BlockButton.UpdateName = function()
		local IsBlocked = Dakimakuras.Blacklist[ BlockButton.SteamID ]
		BlockButton:SetText( string.format("%s%s%s", (IsBlocked and "[" or ""), BlockButton.UserName, (IsBlocked and "]" or "")))
	end
	
	BlockButton.DoClick = function()
		local IsBlocked = Dakimakuras.Blacklist[ BlockButton.SteamID ]
		Dakimakuras.BlacklistUser( BlockButton.SteamID, not IsBlocked )
		BlockButton.UpdateName()
	end
	
	BlockButton.UpdateName()
end
 
function DakiMenu:AddHistoryObject( Data )
	local DakiModel = ClientsideModel("models/dakimakura/daki.mdl")
	DakiModel:SetNoDraw( true )
	
	local ListItem = self.History:Add( "DButton" )
	ListItem:SetSize( 83, 83 )
	ListItem:SetText("")
	
	
	for Id, Text in pairs({ Data.Front, Data.Back }) do
		if( Text ~= "" )then
			Dakimakuras.LoadImg( Text, function( Mat )
				if( IsValid( DakiModel ) )then
					DakiModel:SetSubMaterial( Id - 1, Mat )
				end
			end)
		end
	end
	
	ListItem.DoClick = function()
		surface.PlaySound("garrysmod/ui_click.wav")
		self.FrontEntry:SetValue( Data.Front )
		self.BackEntry:SetValue( Data.Back )
		self.IsNSFW:SetValue( Data.IsNSFW )
		self:UpdateDaki()
	end 
	
	ListItem.DoRightClick = function()
		local Menu = DermaMenu()
		Menu:AddOption("Remove", function()
			Dakimakuras.RemoveDaki( Data.Front, Data.Back, true )
			self.History:Clear()
			
			for _, Data in pairs( Dakimakuras.History ) do
				self:AddHistoryObject( Data )
			end			
		end)
		
		Menu:Open()
	end
	
	ListItem.OnRemove = function() 
		DakiModel:Remove() 
	end
	
	ListItem.Paint = function( Self, Width, Height )

		if( Self:IsHovered() and !Self.wasHovered ) then
			surface.PlaySound("garrysmod/ui_hover.wav") -- ui sounds are nice
		end
		Self.wasHovered = Self:IsHovered()

		local Left, Top = ListItem:LocalToScreen( 0, 0 )
		local Right, Bottom = ListItem:LocalToScreen( 83, 83 )
		local Current = Self
		
		while( Current:GetParent() ~= null )do
			Current = Current:GetParent()
			
			local NewLeft, NewTop = Current:LocalToScreen( 0, 0 )
			local NewRight, NewBottom = Current:LocalToScreen( Current:GetWide(), Current:GetTall() )
			
			Left = math.max( Left, NewLeft )
			Top = math.max( Top, NewTop )
			Right = math.min( Right, NewRight )
			Bottom = math.min( Bottom, NewBottom )
		end
		
		draw.RoundedBox( 5, 0, 0, Width, Height, ( ListItem:IsHovered() and Color( 190, 190, 190 ) or Color( 215, 215, 215 ) ) )
		render.SetScissorRect( Left, Top, Right, Bottom, true )
		
		local RealX, RealY = ListItem:LocalToScreen( 0, 0 )
		cam.Start3D( Vector( -200, 0, 0 ), Angle(), 20, RealX, RealY, Width, Height)
			DakiModel:SetupBones()
			
			DakiModel:SetPos( Vector( 0, -15, 0 ) )
			DakiModel:SetAngles( Angle( 0, 0, 0 ) )
			DakiModel:DrawModel()
			
			DakiModel:SetupBones()
			
			DakiModel:SetPos( Vector( 0, 15, 0 ) )
			DakiModel:SetAngles( Angle( 0, 180, 0 ) )
			DakiModel:DrawModel()
		cam.End3D()
		
		render.SetScissorRect( 0, 0, 0, 0, false )
	end
end

vgui.Register("DakiMenu", DakiMenu, "DFrame")

net.Receive("dakimakuras-net", function()
	LocalPlayer():ConCommand("-menu")
	local Menu = vgui.Create("DakiMenu")
	Menu:MakePopup()
end)