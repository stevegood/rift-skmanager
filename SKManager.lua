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
local lists
local listLabels
local importButton = UI.CreateFrame("RiftButton", "SKManagerImportButton", listWindow)
local exportButton = UI.CreateFrame("RiftButton", "SKManagerExportButton", listWindow)
local edgeGap = 15
local topGap = 70

local function init()
    local windowWidth = 768
    local windowHeight = 480

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
        SKManager.saveListWindowPosition()
    end

    function listWindow.Event.Move()
        SKManager.saveListWindowPosition()
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
    function exportButton.Event.LeftClick()
        SKManager.openExportWindow()
    end
end

local function AddonSavedVariablesLoadEnd(handle, identifier)
    if identifier == addon.identifier then
        Command.Event.Detach(Event.Addon.SavedVariables.Load.End, AddonSavedVariablesLoadEnd)
        print("SKManager version "..addon.toc.Version.." loaded")
        print("Use /skm to open SKManager")
        init()
        if _listData then
            Raid = _listData
            SKManager.renderRaid()
        end
    end
end

function SKManager.saveListWindowPosition()
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
    local x = listWindow:GetLeft()
    local y = listWindow:GetTop()
    local importWindow = UI.CreateFrame("SimpleWindow", "SKMImportWindow", context)
	importWindow:SetCloseButtonVisible(true)
	importWindow:SetLayer(3)
	importWindow:SetWidth(320)
	importWindow:SetHeight(240)
    importWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
	listWindow:SetVisible(false)
	
	local textArea = skmUtils.createTextArea("SKMImportTextArea", importWindow, (importWindow:GetHeight()-100), (importWindow:GetWidth()-30), 15, 70)
	textArea.text:SetKeyFocus(true)
	
	function importWindow.Event.Close()
		textArea.text:SetKeyFocus(false)
        if textArea.text:GetText() ~= '' then
            Raid = nil
            _listData = nil
            Raid = raidService.parseRaidString(textArea.text:GetText())
            _listData = Raid
            SKManager.renderRaid()
        end
		listWindow:SetVisible(true)
	end
end

function SKManager.openExportWindow()
    local raidString = raidService.buildRaidString(Raid)
    local x = listWindow:GetLeft()
    local y = listWindow:GetTop()
    local exportWindow = UI.CreateFrame("SimpleWindow", "SKMExportWindow", context)
    exportWindow:SetCloseButtonVisible(true)
    exportWindow:SetLayer(3)
    exportWindow:SetWidth(320)
    exportWindow:SetHeight(240)
    exportWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
    listWindow:SetVisible(false)

    local textArea = skmUtils.createTextArea("SKMExportTextArea", exportWindow, (exportWindow:GetHeight()-100), (exportWindow:GetWidth()-30), 15, 70)
    textArea.text:SetText(raidString)

    function exportWindow.Event.Close()
        textArea.text:SetKeyFocus(false)
        listWindow:SetVisible(true)
    end
end

function SKManager.renderRaid()
    listWindow:SetTitle("SKManager - "..Raid.name)
    local nextX = edgeGap*2
    for k, v in pairs(Raid.callings) do
        local label = SKManager.getListLabel(v.name, nextX)
        local list = SKManager.getList(v.name, label, nextX)

        local items = {}
        for key, val in pairs(v.members) do
            -- add members to list
            table.insert(items, val.name)
        end
        list:SetItems(items)
        function list.Event.SelectionChange()
            local selectedItem = list:GetSelectedItem()

            local alert = UI.CreateFrame("SimpleWindow", "SKMMoveToBottomConfirmationAlert", context)
            alert:SetHeight(240)
            alert:SetWidth(320)
            alert:SetTitle("Are you Sure?")
            alert:SetPoint("TOPLEFT", UIParent, "TOPLEFT", listWindow:GetLeft(), listWindow:GetTop())
            alert:SetCloseButtonVisible(true)
            function alert.Event.Close()
                alert:SetVisible(false)
                listWindow:SetVisible(true)
            end

            local text = UI.CreateFrame("Text", "SKMMoveToBottomConfirmationAlertText", alert)
            text:SetWordwrap(true)
            text:SetText("Are you sure you want to move "..selectedItem.." to the bottom of the "..v.name.." list?\nConfirm below or close this window to cancel.")
            text:SetPoint("TOPLEFT", alert, "TOPLEFT", edgeGap*2, topGap)
            text:SetWidth(alert:GetWidth()-(edgeGap*4))

            local confirmationButton = UI.CreateFrame("RiftButton", "SKMMoveToBottomConfirmationAlertConfirmButton", alert)
            confirmationButton:SetWidth(100)
            confirmationButton:SetText("Yes")
            confirmationButton:SetPoint("BOTTOMRIGHT", alert, "BOTTOMRIGHT", 0-(edgeGap), 0-(edgeGap))
            function confirmationButton.Event.LeftClick()
                local newMemberTable = {}
                local memberNames = {}
                local listPosition = 0
                for i, member in pairs(v.members) do
                    if member.name ~= selectedItem then
                        member.listPosition = listPosition
                        table.insert(newMemberTable, member)
                        table.insert(memberNames, member.name)
                        listPosition = listPosition + 1
                    end
                end

                for i, member in pairs(v.members) do
                    if member.name == selectedItem then
                        member.listPosition = listPosition
                        table.insert(newMemberTable, member)
                        table.insert(memberNames, member.name)
                    end
                end

                list:SetItems(memberNames)
                v.members = newMemberTable
                alert.Event.Close(alert)
            end

            alert:SetVisible(true)
            listWindow:SetVisible(false)
        end

        -- increment the next x position
        nextX = nextX+edgeGap+list:GetWidth()
    end
end

function SKManager.getListLabel(listName, x)
    if not listLabels then
        listLabels = {}
    end

    for i,lbl in pairs(listLabels) do
        if lbl:GetName() == listName.."ListLabel" then
            return lbl
        end
    end

    local label = UI.CreateFrame("Text", listName.."ListLabel", listWindow)
    label:SetText(listName)
    label:SetWidth((listWindow:GetWidth()-(edgeGap*7))/4)
    label:SetPoint("TOPLEFT", listWindow, "TOPLEFT", x, topGap)
    table.insert(listLabels, label)
    return label
end

function SKManager.getList(listName, label, x)
    if not lists then
        lists = {}
    end

    for i,lst in pairs(lists) do
        if lst:GetName() == listName.."LootList" then
            return lst
        end
    end

    local list = UI.CreateFrame("SimpleList", listName.."LootList", listWindow)
    list:SetHeight(listWindow:GetHeight()-label:GetHeight()-((edgeGap*2)+topGap+exportButton:GetHeight()))
    list:SetWidth(label:GetWidth())
    list:SetPoint("TOPLEFT", listWindow, "TOPLEFT", x, label:GetHeight()+5+topGap)
    table.insert(lists, list)
    return list
end

-- Commands and bindings
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, AddonSavedVariablesLoadEnd, "AddonSavedVariablesLoadEnd")
table.insert(Command.Slash.Register("skm"), {SKManager.toggleListWindow, "SKManager", "Slash command"})
