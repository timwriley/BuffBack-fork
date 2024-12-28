local addonName = ...
---@class AddonPrivate
local Private = select(2, ...)

local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
local constants = Private.Constants
local minimapLDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
	type = "data source",
	text = addonName,
	icon = constants.ADDON_PATH .. "BB.png",
	OnClick = function(_, mouseButton)
        if mouseButton == "LeftButton" then
            Private.Utils:ToggleAddon()
        elseif mouseButton == "RightButton" then
            Settings.OpenToCategory(addonName)
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText(addonName)
        tooltip:AddLine("Left-click to toggle BuffBack", 1, 1, 1)
        tooltip:AddLine("Right-click to open settings", 1, 1, 1)
    end,
})
local icon = LibStub("LibDBIcon-1.0")

Private.Icon = icon
Private.MMLDB = minimapLDB
Private.Addon = addon

function addon:OnInitialize()
    Private.Config:InitializeConfig()
    Private.Commands:InitializeCommands()
    Private.Events:InitializeEvents()
    Private.UI:InitializeUI()
	icon:Register(addonName, minimapLDB, Private.Config.db.profile.minimap)
end

function addon:OnEnable()
    local utils = Private.Utils
    utils:PrintF("v|cff00ff00%s|r loaded.",constants.ADDON_VERSION)
    if not AreDangerousScriptsAllowed() then
        utils:PrintF("To use BuffBack's full functionality, you must have the use of scripts enabled. \nJust type /run in chat and accept the pop-up to enable them!")
	end
end