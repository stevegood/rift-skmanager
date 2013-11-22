--
-- Created by IntelliJ IDEA.
-- User: Ardoth
-- Date: 11/21/13
-- Time: 11:51 PM
--

SKManager = {}

local addon = ...
local context = UI.CreateContext("SKManager")
local listWindow = UI.CreateFrame("SimpleWindow", "SKManagerListWindow", context)
local importButton = UI.CreateFrame("RiftButton", "SKManagerImportButton", listWindow)
local exportButton = UI.CreateFrame("RiftButton", "SKManagerExportButton", listWindow)

local function init()
    local windowWidth = 1024
    local windowHeight = 600

    local windowStartX
    if _listWindowX then
        windowStartX = _listWindowX
    else
        windowStartX = 100
    end

    local windowStartY
    if _listWindowY then
        windowStartY = _listWindowY
    else
        windowStartY = 100
    end

    local edgeGap = 15
    local topGap = 70
    local innerWidth = windowWidth - (edgeGap * 2)
    local innerHeight = windowHeight - ((edgeGap * 2) + topGap + exportButton:GetHeight())

    -- list window
    listWindow:SetVisible(false)
    listWindow:SetCloseButtonVisible(true)
    listWindow:SetWidth(windowWidth)
    listWindow:SetHeight(windowHeight)
    listWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", windowStartX, windowStartY)
    listWindow:SetTitle("SKManager")
    listWindow:SetLayer(1)
    listWindow:SetAlpha(1)
    function listWindow.Event.Close()
        local x = listWindow:GetLeft()
        local y = listWindow:GetTop()

        if x < 0 then
            x = 0
        end

        if y < 0 then
            y = 0
        end

        SKManager.saveData(x,y)
    end

    -- buttons
    local buttonBottom = (0-edgeGap)-(edgeGap/2)
    local leftButtonStart = (edgeGap*2)
    -- import button
    importButton:SetLayer(2)
    importButton:SetText("Import")
    local importButtonLeft = leftButtonStart
    importButton:SetPoint("BOTTOMLEFT", listWindow, "BOTTOMLEFT", importButtonLeft, buttonBottom)
    importButton:SetWidth(100)
	function importButton.Event.LeftClick()
		SKManager.openImportWindow()
	end

    -- export button
    exportButton:SetLayer(2)
    exportButton:SetText("Export")
    local exportButtonLeft = leftButtonStart + importButton:GetWidth()
    exportButton:SetPoint("BOTTOMLEFT", listWindow, "BOTTOMLEFT", exportButtonLeft, buttonBottom)
    exportButton:SetWidth(100)
end

local function AddonSavedVariablesLoadEnd(handle, identifier)
    if identifier == addon.identifier then
        Command.Event.Detach(Event.Addon.SavedVariables.Load.End, AddonSavedVariablesLoadEnd)
        print("SKManager version "..addon.toc.Version.." loaded")
        print("Use /skm to open SKManager")
        init()
    end
end

function SKManager.saveData(x,y)
    _listWindowX = x
    _listWindowY = y
end

function SKManager.toggleListWindow()
    -- TODO: toggle the listWindow
    SKManager.saveData()

    -- toggle window
    listWindow:SetVisible(not listWindow:GetVisible())
end

function SKManager.openImportWindow()
	local importWindow = UI.CreateFrame("SimpleWindow", "SKMImportWindow", context)
	importWindow:SetCloseButtonVisible(true)
	importWindow:SetLayer(3)
	importWindow:SetWidth(640)
	importWindow:SetHeight(480)
	listWindow:SetVisible(false)
	
	local textArea = skmUtils.createTextArea("SKMImportTextArea", importWindow, (importWindow:GetHeight()-100), (importWindow:GetWidth()-30), 15, 70)
	textArea.text:SetKeyFocus(true)
	
	-- local textFrame = UI.CreateFrame("Text", "SKMImportTextFrame", importWindow:GetContent())
-- 	textFrame:SetWidth(importWindow:GetWidth()-30)
-- 	textFrame:SetHeight(importWindow:GetHeight()-100)
-- 	textFrame:SetPoint("TOPLEFT", importWindow, "TOPLEFT", 15, 70)
-- 	textFrame:SetBackgroundColor(0,0,0,0.5)
-- 	
-- 	local scrollView = UI.CreateFrame("SimpleScrollView", "SKMImportScrollView", textFrame)
-- 	scrollView:SetWidth(textFrame:GetWidth())
-- 	scrollView:SetHeight(textFrame:GetHeight())
-- 	scrollView:SetPoint("TOPLEFT", textFrame, "TOPLEFT", 0, 0)
-- 	
-- 	local textArea = UI.CreateFrame("RiftTextfield", "SKMImportTextArea", scrollView)
-- 	textArea:SetText("")
-- 	textArea:SetKeyFocus(true)
-- 	scrollView:SetContent(textArea)
	
	function importWindow.Event.Close()
		textArea.text:SetKeyFocus(false)
		-- SKManager.doRun(textArea:GetText())
		listWindow:SetVisible(true)
	end
end

function SKManager.doRun(obj)

		function xpError(obj)
			print(" ")
			print("Error: "..obj)
		end
		
		local retOK, ret1 = xpcall(loadstring(obj), xpError)

end

-- Commands and bindings
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, AddonSavedVariablesLoadEnd, "AddonSavedVariablesLoadEnd")
table.insert(Command.Slash.Register("skm"), {SKManager.toggleListWindow, "SKManager", "Slash command"})
