local addonName = ...
---@class AddonPrivate
local Private = select(2, ...)

-- Initialize global database table if not already defined
BuffBackGlobalDB = BuffBackGlobalDB or {}


---@class AddonConfig
local config = {
    options = {},
    db = {},
    optionsFrame = {}
}
Private.Config = config

function config:ConfigGetter(info)
    local key = info[#info]
    if key == "minimapToggle" then
        return not self.db.profile.minimap.hide
    end
    return self.db.profile[key]
end

function config:ConfigSetter(info, value)
    local key = info[#info]
    if key == "minimapToggle" then
        self.db.profile.minimap.hide = not value
        Private.Icon[self.db.profile.minimap.hide and "Hide" or "Show"](Private.Icon, addonName)
        return
    end
    self.db.profile[key] = value
end

function config:InitializeConfig()
    self.options = {
        name = addonName,
        handler = self,
        type = 'group',
        args = {
            minimapToggle = {
                type = 'toggle',
                name = 'Minimap Button',
                desc = 'Toggles the Minimap Button.',
                default = true,
            },
            enableAddon = {
                type = 'toggle',
                name = 'Enable BuffBack',
                desc = 'Toggles the entire Add-on.',
                default = true,
            },
            debug = {
                type = 'toggle',
                name = 'Debug Mode',
                desc = 'Toggles debug mode.',
                default = false,
            },
            setbuff = {
                type = 'input',
                name = 'Set Buff',
                desc = 'Sets the buff or item to cast. (prefix with spell: or item:)',
                default = "spell:" .. (Private.Constants.CLASS_BUFFS[UnitClassBase("player")] or ""),
                validate = function (_, value)
                    return Private.Utils:GetItemOrSpell(value, true)
                end
            },
            emote = {
                type = 'toggle',
                name = 'Emote',
                desc = 'Toggles the emote.',
                default = true,
            },
            setemote = {
                type = 'input',
                name = 'Set Emote',
                desc = 'Customizes the emote message. (use %s for the triggering buff providers name)',
                default = "thanks %s for the buff, and gives a BuffBack!",
            },
            last = {
                type = 'execute',
                name = 'Last Buff Source',
                desc = 'Shows the last buff source.',
                func = function()
                    local lastSource = Private.Events:GetLastSource()
                    Private.Utils:PrintF("The last buff source was: %s", (lastSource and lastSource ~= "") and lastSource or "None")
                end,
            },
            cd = {
                type = 'toggle',
                name = 'Cooldown',
                desc = 'Toggles a player specfic cooldown for button triggers to prevent spamming.',
                default = true,
            },
            cooldown = {
                type = 'input',
                name = 'Set Cooldown',
                desc = 'Sets the cooldown time in seconds.',
                validate = function(_, value)
                    local num = tonumber(value)
                    if num and num > 0 then
                        return true
                    else
                        return "Cooldown must be a positive number."
                    end
                end,
                default = "60",
            },
        },
    }
    local defaults = {
        minimap = {
            hide = false,
        }
    }
    for setting, settingInfo in pairs(self.options.args) do
        if settingInfo.default ~= nil then
            defaults[setting] = settingInfo.default
            settingInfo.get = "ConfigGetter"
            settingInfo.set = "ConfigSetter"
            settingInfo.default = nil
        end
    end
	self.db = LibStub("AceDB-3.0"):New(BuffBackGlobalDB, {
        profile  = defaults,
    }, true)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)

	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName .. "_Profiles", profiles)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName .. "_Profiles", "Profiles", addonName)
end

function config:GetDatabaseValue(databasePath)
    local dbValue = self.db.profile
    if type(dbValue) ~= "table" then error("Database is not a table!", 2) end
    for step in databasePath:gmatch("[^%.]+") do
        if type(dbValue) == "table" then
            dbValue = dbValue[step]
        else
            error(string.format("Couldn't find %s!", step), 2)
        end
    end
    return dbValue
end

function config:SetDatabaseValue(databasePath, newValue)
    local dbTable = self.db.profile
    if type(dbTable) ~= "table" then error("Database is not a table!", 2) end
    if self:InitDatabasePath(databasePath, newValue) then return end
    local keys = {}
    for step in databasePath:gmatch("[^%.]+") do
        table.insert(keys, step)
    end

    local lastKey = keys[#keys]
    local parentTable = self:GetParentTable(dbTable, keys)

    if parentTable then
        parentTable[lastKey] = newValue
    else
        error("Invalid database path!", 2)
    end
end

function config:GetParentTable(tbl, keys)
    local parentTable = tbl
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(parentTable[key]) == "table" then
            parentTable = parentTable[key]
        else
            return nil
        end
    end
    return parentTable
end

function config:InitDatabasePath(databasePath, defaultValue)
    local dbTable = self.db.profile
    if type(dbTable) ~= "table" then error("Database is not a table!", 2) end
    local steps = {}
    for step in databasePath:gmatch("[^%.]+") do
        table.insert(steps, step)
    end

    for i, step in ipairs(steps) do
        if dbTable[step] == nil then
            if i == #steps then
                dbTable[step] = defaultValue
                return true
            else
                dbTable[step] = {}
            end
        end
        dbTable = dbTable[step]
    end
end

function config:Reset()
    self.db:ResetProfile()
end