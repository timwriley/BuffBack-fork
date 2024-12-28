local addonName = ...
---@class AddonPrivate
local Private = select(2, ...)

---@class AddonUtils
local utils = {}
Private.Utils = utils

local constants = Private.Constants

function utils:PrintF(...)
    local msg = ...
    print(string.format("%s%s|r: " .. msg, constants.PLAYER_CLASS_COLOR:GenerateHexColorMarkup(), addonName, select(2, ...)))
end

function utils:DPrint(...)
    if Private.Config:GetDatabaseValue("debug") then
        local msg = ...
        self:PrintF("%s(DEBUG)|r " .. msg, constants.DEBUG_COLOR:GenerateHexColorMarkup(), select(2, ...))
    end
end

function utils:AsyncSpellCall(spellID, func)
    local spell = Spell:CreateFromSpellID(spellID)
    spell:ContinueOnSpellLoad(func)
end

function utils:AsyncItemCall(itemID, func)
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(func)
end

function utils:TableConcat(table, sep, includeKeys)
    sep = sep or ", "
    local str = ""
    for key, value in pairs(table) do
        str = string.format("%s%s%s%s", str, includeKeys and tostring(key) .. ": " or "", tostring(value), sep)
    end
    return str
end

function utils:GetItemOrSpell(identifier, validate)
    local prefix, input = identifier:match("(%a+):(.*)")
    local inputID = tonumber(input)
    if prefix and prefix:lower() == "spell" then
        local spellName = C_Spell.GetSpellName(inputID and inputID or input)
        if validate then
            return spellName and true or "Couldn't find Spell! Please try again."
        end
        return spellName
    elseif prefix and prefix:lower() == "item" then
        local itemName = C_Item.GetItemNameByID(inputID and inputID or input)
        if validate then
            return itemName and true or "Couldn't find Item! Please try again."
        end
        return itemName
    end
    if validate then
        return "Please set 'spell:' or 'item' as prefix!"
    end
end

function utils:IsAddonEnabled()
    return Private.Config:GetDatabaseValue("enableAddon")
end

function utils:ToggleAddon()
    Private.Config:SetDatabaseValue('enableAddon', not self:IsAddonEnabled())
    self:PrintF("BuffBack is now %s!", self:IsAddonEnabled() and "Enabled" or "Disabled")
end

function utils:TempGlobal(input)
    _G["BBG"] = input
end