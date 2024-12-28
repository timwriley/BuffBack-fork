---@class AddonPrivate
local Private = select(2, ...)

---@class AddonUI
local ui = {
    ---@type table|Button
    button = nil,
    target = "",
    errorReason = "",
    clickedTime = 0,
    waitCast = false,
    castSpell = ""
}
Private.UI = ui

function ui:InitializeUI()
    local constants = Private.Constants
    local button = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
    button:SetSize(128, 64)
    button:SetPoint("CENTER", 0, 200)
    button:SetNormalTexture(constants.ADDON_PATH .. "BuffBackButton.png")
    button:SetHighlightTexture(constants.ADDON_PATH .. "BuffBackButton_.png")
    button:SetAttribute("type", "macro")

    local fadeAnimationGroup = button:CreateAnimationGroup()
    local fadeOut = fadeAnimationGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(3)
    fadeOut:SetStartDelay(3)
    fadeOut:SetSmoothing("IN")

    fadeAnimationGroup:SetScript("OnFinished", function()
        if button:IsShown() then
            button:Hide()
            Private.Utils:DPrint("Button faded out")
        end
    end)

    button:HookScript("OnShow", function()
        fadeAnimationGroup:Restart()
        Private.Utils:DPrint("Fade animation started")
    end)

    button:HookScript("PostClick", function ()
        button:Hide()
        if AreDangerousScriptsAllowed() then return end
        self.clickedTime = GetTime()
        self.waitCast = true
        RunNextFrame(function()
            ui:SendStatusMessage(true)
        end)
    end)
    button:Hide()
    self.button = button
end

function ui:DetermineOutcome()
    local casted = self.castSpell

    local aura = C_UnitAuras.GetAuraDataBySpellName("target", casted)
    local state = true

    if aura then
        if not aura.canApplyAura then -- Higher than yours
            self.errorReason = "More Powerful Spell Already Active"
            state = false
        end
    end
    local cd = GetSpellCooldown(self.castSpell)
    if cd and cd > 0 then -- Spell on CD
        self.errorReason = "On Cooldown"
        state = false
    end
    local cost = GetSpellPowerCost(self.castSpell)
    if not cost then -- Player doesn't know the Spell
        state = false
    elseif cost then
        for _, powerCost in ipairs(cost) do
            if UnitPower("player", powerCost.type) < powerCost.cost then -- Player doesn't have enough power
                self.errorReason = "Not Enough Mana"
                state = false
            end
        end
    end
    if not C_Spell.IsSpellInRange(self.castSpell, "target") then
        self.errorReason = "Too Far Away"
        state = false
    end

    self:SendStatusMessage(state)
    Private.Utils:TempGlobal(nil)
end

function ui:UpdateButton(target)
    -- Check if the addon is enabled
    if not Private.Utils:IsAddonEnabled() then return end

    -- Check if the player is in combat
    if InCombatLockdown() then
        return -- Skip updates during combat
    end

    -- Get the spell or item to cast
    local cast = Private.Config:GetDatabaseValue("setbuff")
    local castName = Private.Utils:GetItemOrSpell(cast)
    ---@cast castName string

    -- Determine if the player has a target
    local hasTarget = UnitExists("target")

    -- Temporary global scope for determining outcomes
    Private.Utils:TempGlobal(function ()
        ui:DetermineOutcome()
    end)

    -- Set up the macro for the button
    self.button:SetAttribute("macrotext", string.format(
        "/targetexact %s\n/run BBG()\n/cast %s\n/%s",
        target, castName, hasTarget and "targetlasttarget" or "cleartarget"
    ))

    -- Set button state and show it
    self.target = target
    self.errorReason = "unknown reason"
    self.castSpell = castName
    self.button:Show()
end


function ui:SendStatusMessage(isSuccess)
    if not Private.Config:GetDatabaseValue("emote") then return end
    if not AreDangerousScriptsAllowed() and not self.waitCast then return end
    self.waitCast = false
    if isSuccess then
        local formattedEmote = string.format(Private.Config:GetDatabaseValue("setemote"), self.target)
        SendChatMessage(formattedEmote, "EMOTE")
        Private.Utils:DPrint("Emote sent: %s", formattedEmote)
    else
        local failedEmote = string.format("thanks %s for the buff, but couldn't give a BuffBack. (%s)", self.target, self.errorReason)
        SendChatMessage(failedEmote, "EMOTE")
        Private.Utils:DPrint("Failed emote sent: %s", failedEmote)
    end
end