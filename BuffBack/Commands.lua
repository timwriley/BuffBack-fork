---@class AddonPrivate
local Private = select(2, ...)

---@class AddonCommands
local commands = {}
Private.Commands = commands

function commands:Register(commandTbl, func)
    local addon = Private.Addon
    for _, command in ipairs(commandTbl) do
        addon:RegisterChatCommand(command, function (...)
            local args = {...}
            Private.Utils:DPrint("Command %s, args: %s", command, Private.Utils:TableConcat(args))
            func(commands, ...)
        end)
    end
end

function commands:OnCommand(msg)
    local command, arg = msg:match("^(%S*)%s*(.-)$")
    if command == "debug" then
        local invertedState = not Private.Config:GetDatabaseValue('debug')
        Private.Config:SetDatabaseValue('debug', invertedState)
        Private.Utils:PrintF("Debug mode is now %s!", invertedState and "enabled" or "disabled")
    elseif command == "setbuff" then
        if arg and arg ~= "" then
            local validCast = Private.Utils:GetItemOrSpell(arg, true)
            if type(validCast) == "string" then
                Private.Utils:PrintF(validCast)
                return
            end
            Private.Config:SetDatabaseValue('setbuff', arg)
            Private.Utils:PrintF("Buff set to %s", arg:gsub(':', ' '))
        else
            Private.Utils:PrintF("Usage: /buffback setbuff [spell/item name]", arg)
        end
    elseif command == "emote" then
        local invertedState = not Private.Config:GetDatabaseValue('emote')
        Private.Config:SetDatabaseValue('emote', invertedState)
        Private.Utils:PrintF("Emote is now %s!", invertedState and "enabled" or "disabled")
    elseif command == "setemote" then
        if arg and arg ~= "" then
            Private.Config:SetDatabaseValue('setemote', arg)
            Private.Utils:PrintF("Custom emote set to: %s!", arg)
        else
            Private.Utils:PrintF("Usage: /buffback setemote [text]")
        end
    elseif command == "default" then
        Private.Config:Reset()
        print("|cffff7d0aBuffBack:|r Settings reset to default.")
    elseif command == "last" then
        local lastSource = Private.Events:GetLastSource()
        Private.Utils:PrintF("Last buff source: %s", (lastSource and lastSource ~= "") and lastSource or "None")
    elseif command == "cd" then
        local invertedState = not Private.Config:GetDatabaseValue('cd')
        Private.Config:SetDatabaseValue('cd', invertedState)
        Private.Utils:PrintF("Cooldown is now %s!", invertedState and "enabled" or "disabled")
    elseif command == "cooldown" then
        local time = tonumber(arg)
        if time and time >= 0 then
            Private.Config:SetDatabaseValue('cooldown', time)
            Private.Utils:PrintF("Cooldown time set to %d seconds!", time)
        else
            Private.Utils:PrintF("Usage: /buffback cooldown [seconds]")
        end
    else
        local helpStr = "Available commands:"..
                    "\n- /buffback debug   (Toggles debug mode)"..
                    "\n- /buffback setbuff [spell/item]   (Sets the buff or item to cast. (prefix with spell: or item:))"..
                    "\n- /buffback emote   (Toggles emote on/off)"..
                    "\n- /buffback setemote [text]   (Customizes the emote message)"..
                    "\n- /buffback default   (Resets settings to defaults)"..
                    "\n- /buffback last   (Shows the last buff source)"..
                    "\n- /buffback cd   (Toggles cooldown on/off)"..
                    "\n- /buffback cooldown [seconds]   (Sets cooldown time)"
        Private.Utils:PrintF(helpStr)
    end
end

function commands:InitializeCommands()
    self:Register({"buffback", "bb"}, self.OnCommand)
end