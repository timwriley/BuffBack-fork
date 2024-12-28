---@class AddonPrivate
local Private = select(2, ...)

---@class AddonEvents
local events = {
    lastSource = "",
    lastTime = 0
}
Private.Events = events

function events:Register(event, func)
    local addon = Private.Addon
    addon:RegisterEvent(event, function (triggered, ...)
        local args = {...}
        if triggered == "COMBAT_LOG_EVENT_UNFILTERED" then
            args = {CombatLogGetCurrentEventInfo()}
        end
        Private.Utils:DPrint("Event %s, args: %s", triggered, Private.Utils:TableConcat(args))
        func(events, unpack(args))
    end)
end

function events:InitializeEvents()
    self:Register("COMBAT_LOG_EVENT_UNFILTERED", events.CLEU)
    self:Register("UI_ERROR_MESSAGE", events.OnError)
end

function events:OnError(errorNum)
    if AreDangerousScriptsAllowed() then return end
    local currentTime = GetTime()
    local errorGlobal = GetGameMessageInfo(errorNum)
    if currentTime <= Private.UI.clickedTime + 1 and (errorGlobal:match("ERR_SPELL") or errorNum == 340) then
        Private.UI.errorReason = _G[errorGlobal]
        Private.UI:SendStatusMessage(false)
    end
end

function events:CLEU(...)
    local info = {...}
    local subEvent = info[2]
    local destGUID = info[8]

    if (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH") and destGUID == UnitGUID("player") then
        local sourceGUID = info[4]
        local sourceName = info[5]
        if not sourceName and sourceGUID then
            local unitToken = UnitTokenFromGUID(sourceGUID)
            if unitToken then
                sourceName = UnitName(unitToken)
            end
        end
        local spellID = info[12]
        local spellName = info[13]

        if Private.Constants.HOTS[spellID] then
            Private.Utils:DPrint("Ignored HoT spell: %s", spellName)
            return
        end

        if sourceName == UnitName("player") and not Private.Config:GetDatabaseValue("debug") then
            return
        end

        local currentTime = GetTime()
        local cdTime = tonumber(Private.Config:GetDatabaseValue("cooldown"))
        if Private.Config:GetDatabaseValue("cd") and self.lastSource == sourceName and currentTime - self.lastTime < cdTime then
            local remainingTime = self.lastTime + cdTime - currentTime
            Private.Utils:DPrint("Cooldown active (%.2f sec). Ignoring buff from %s.", remainingTime, sourceName)
            return
        end

        self.lastSource = sourceName
        self.lastTime = currentTime

        Private.UI:UpdateButton(sourceName)
    end
end

function events:GetLastSource()
    return self.lastSource
end