local addonName = ...
---@class AddonPrivate
local Private = select(2, ...)

---@class AddonConstants
local constants = {}
Private.Constants = constants

constants.CLASS_BUFFS = {
    DRUID = "Mark of the Wild",
    MAGE = "Arcane Intellect",
    PALADIN = "Blessing of Might",
    PRIEST = "Power Word: Fortitude",
    SHAMAN = "Water Breathing",
    WARLOCK = "Unending Breath",
    WARRIOR = nil,
    HUNTER = nil
}

constants.CLASS_COLORS = RAID_CLASS_COLORS
constants.SPELL_COLOR = CreateColorFromHexString("ff00ff00")
constants.PLAYER_CLASS_COLOR = constants.CLASS_COLORS[UnitClassBase("player")]
constants.DEBUG_COLOR = CreateColorFromHexString("FFe74c3c")

constants.ADDON_VERSION = C_AddOns.GetAddOnMetadata(addonName, 'Version')
constants.ADDON_PATH = string.format("Interface\\AddOns\\%s\\", addonName)

constants.HOTS = {
    [774] = true,   -- Rejuvenation (Rank 1)
    [1058] = true,  -- Rejuvenation (Rank 2)
    [1430] = true,  -- Rejuvenation (Rank 3)
    [2090] = true,  -- Rejuvenation (Rank 4)
    [2091] = true,  -- Rejuvenation (Rank 5)
    [3627] = true,  -- Rejuvenation (Rank 6)
    [8910] = true,  -- Rejuvenation (Rank 7)
    [9839] = true,  -- Rejuvenation (Rank 8)
    [9840] = true,  -- Rejuvenation (Rank 9)
    [9841] = true,  -- Rejuvenation (Rank 10)
    [25299] = true, -- Rejuvenation (Rank 11)
    
    [8936] = true,  -- Regrowth (Rank 1)
    [8938] = true,  -- Regrowth (Rank 2)
    [8939] = true,  -- Regrowth (Rank 3)
    [8940] = true,  -- Regrowth (Rank 4)
    [8941] = true,  -- Regrowth (Rank 5)
    [9750] = true,  -- Regrowth (Rank 6)
    [9856] = true,  -- Regrowth (Rank 7)
    [9857] = true,  -- Regrowth (Rank 8)
    [9858] = true,  -- Regrowth (Rank 9)

    [61295] = true, -- Riptide (Rank 1)
    
    [139] = true,   -- Renew (Rank 1)
    [6074] = true,  -- Renew (Rank 2)
    [6075] = true,  -- Renew (Rank 3)
    [6076] = true,  -- Renew (Rank 4)
    [6077] = true,  -- Renew (Rank 5)
    [6078] = true,  -- Renew (Rank 6)
    [10927] = true, -- Renew (Rank 7)
    [10928] = true, -- Renew (Rank 8)
    [10929] = true, -- Renew (Rank 9)
    [25315] = true, -- Renew (Rank 10)

    [8170] = true,  -- Healing Stream Totem (Shaman)
    [5672] = true,  -- Healing Stream Totem (Rank 1)
    [6371] = true,  -- Healing Stream Totem (Rank 2)
    [6372] = true,  -- Healing Stream Totem (Rank 3)
    [10460] = true, -- Healing Stream Totem (Rank 4)
    [10461] = true, -- Healing Stream Totem (Rank 5)
}