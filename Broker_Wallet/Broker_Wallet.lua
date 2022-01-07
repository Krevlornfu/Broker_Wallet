local LDB = LibStub:GetLibrary("LibDataBroker-1.1")

Wallet = LDB:NewDataObject( "Broker_Wallet", {
		type = "data source",
		icon = "Interface\\Icons\\Inv_Misc_Armorkit_18",
		text = "",
	} )

local frame = CreateFrame("Frame")
frame:RegisterEvent( "CURRENCY_DISPLAY_UPDATE", "LISTEN_CURRENCY_UPDATE" )
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function( ) Wallet:Update( ) end )

function Wallet:ADDON_LOADED( )
    Wallet:Update( )
end

function Wallet.OnClick( frame, button )
	_G.CharacterFrame_OnLoad(_G.CharacterFrame)
    ToggleCharacter("TokenFrame")
end

function Wallet.OnTooltipShow(tooltip)
	tooltip:AddLine("Broker_Wallet", 0,1,0, 0,1,0)
	local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize()
	if numTokenTypes == 0 then return end
	-- expand all token headers
	for j = numTokenTypes, 1, -1 do
		local info = C_CurrencyInfo.GetCurrencyListInfo( j )
		if info.isHeader and not info.isHeaderExpanded then
		C_CurrencyInfo.ExpandCurrencyList( j, true )
		end
	end
	local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize( )
	for j = 1, numTokenTypes do
		local info = C_CurrencyInfo.GetCurrencyListInfo( j )
		if info.isHeader then
			tooltip:AddLine( " " )
			tooltip:AddLine( info.name )
		else
			tooltip:AddDoubleLine( info.name, info.quantity, 1, 1, 1, 1, 1, 1 )
		end
	end
	tooltip:AddLine( " " )
	tooltip:AddLine( " " )
	tooltip:AddLine("Click to toggle currency frame.", 0,1,0, 0,1,0)
	tooltip:AddLine("Track up to 3 tokens on the bar", 0,1,0, 0,1,0)
	tooltip:AddLine("using the default in-game tracker.", 0,1,0, 0,1,0)
end

function Wallet:Update( )
	self.text = ""
	
	local numTokenTypes = C_CurrencyInfo.GetCurrencyListSize( )	
	if numTokenTypes == 0 then return end	
	for i = numTokenTypes, 1, -1 do
		local info = C_CurrencyInfo.GetCurrencyListInfo( i )
		if info.isHeader and not info.isHeaderExpanded then
			C_CurrencyInfo.ExpandCurrencyList( i, true )
		end
	end
	local numTracked = 0
	numTokenTypes = C_CurrencyInfo.GetCurrencyListSize( )
	local size = ( 0 ) + 1
	
	for i = 1, numTokenTypes do
		local info = C_CurrencyInfo.GetCurrencyListInfo( i )
		if not info.isHeader and info.isShowInBackpack then
			if extraCurrencyType == 1 then
				info.iconFileID = [[Interface\PVPFrame\PVP-ArenaPoints-Icon]]
			elseif extraCurrencyType == 2 then
				local factionGroup = UnitFactionGroup( "player" )
				if factionGroup then
					info.iconFileID = [[Interface\PVPFrame\PVP-Currency-]] .. factionGroup
				end
			end
			self.text = string.format( "%s |T%s:0|t %d", self.text, info.iconFileID or [[Interface\Icons\Temp]], info.quantity or 0 )
		end
		self.text = string.trim( self.text )
	end
end

function Wallet.BackpackUpdate( )
    Wallet:Update( )
end

hooksecurefunc( "BackpackTokenFrame_Update", Wallet.BackpackUpdate)
