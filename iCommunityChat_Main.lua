-- ═══════════════════════════════════════════════════════════════════════════════════════════
-- ██╗  ██████╗  ██████╗ ███╗   ███╗ ███╗   ███╗ ██╗   ██╗ ███╗   ██╗ ██╗ ████████╗ ██╗   ██╗
-- ██║ ██╔════╝ ██╔═══██╗████╗ ████║ ████╗ ████║ ██║   ██║ ████╗  ██║ ██║ ╚══██╔══╝ ╚██╗ ██╔╝
-- ██║ ██║      ██║   ██║██╔████╔██║ ██╔████╔██║ ██║   ██║ ██╔██╗ ██║ ██║    ██║     ╚████╔╝
-- ██║ ██║      ██║   ██║██║╚██╔╝██║ ██║╚██╔╝██║ ██║   ██║ ██║╚██╗██║ ██║    ██║      ╚██╔╝
-- ██║ ╚██████╗ ╚██████╔╝██║ ╚═╝ ██║ ██║ ╚═╝ ██║ ╚██████╔╝ ██║ ╚████║ ██║    ██║       ██║
-- ╚═╝  ╚═════╝  ╚═════╝ ╚═╝     ╚═╝ ╚═╝     ╚═╝  ╚═════╝  ╚═╝  ╚═══╝ ╚═╝    ╚═╝       ╚═╝
--  ██████╗ ██╗  ██╗  █████╗  ████████╗
-- ██╔════╝ ██║  ██║ ██╔══██╗ ╚══██╔══╝
-- ██║      ███████║ ███████║    ██║
-- ██║      ██╔══██║ ██╔══██║    ██║
-- ╚██████╗ ██║  ██║ ██║  ██║    ██║
--  ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝    ╚═╝
-- ═══════════════════════════════════════════════════════════════════════════════════════════

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Namespace                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local addonName, AddOn = ...
local Version = C_AddOns.GetAddOnMetadata(addonName, "Version")
local Author = C_AddOns.GetAddOnMetadata(addonName, "Author")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                        Libs                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

iCC = LibStub("AceAddon-3.0"):NewAddon(
    "iCC",
    "AceEvent-3.0",
    "AceSerializer-3.0",
    "AceComm-3.0",
    "AceTimer-3.0",
    "AceHook-3.0"
)
local L = LibStub("AceLocale-3.0"):GetLocale("iCC")
iCC.L = L
LDBroker = LibStub("LibDataBroker-1.1")
LDBIcon = LibStub("LibDBIcon-1.0")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Version & Metadata                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

iCC.Version = Version
iCC.Author = Author
iCC.AddonPath = "Interface\\AddOns\\iCommunityChat\\"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Game Version Detection                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

iCC.GameVersion, iCC.GameBuild, iCC.GameBuildDate, iCC.GameTocVersion = GetBuildInfo()
iCC.GameVersionName = "Classic TBC"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                    Constants                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

iCC.CONSTANTS = {
    -- Timing
    LOGIN_DELAY = 5,
    HEARTBEAT_INTERVAL = 90,
    OFFLINE_THRESHOLD = 270,

    -- Limits
    MAX_COMMUNITY_NAME = 24,
    MAX_COMMUNITY_MEMBERS = 100,
    MAX_CHAT_MESSAGE_LENGTH = 255,
    MAX_MESSAGE_HISTORY = 200,
    MAX_COMMUNITIES_PER_PLAYER = 5,
    MAX_COMMUNITY_DESCRIPTION = 200,
    MAX_COMMUNITY_RULES = 300,

    -- Roles
    ROLE_LEADER = "Leader",
    ROLE_OFFICER = "Officer",
    ROLE_MEMBER = "Member",
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Community Icons                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

iCC.COMMUNITY_ICONS = {
    -- Faction & PvP
    "Interface\\Icons\\Racial_Orc_BerserkerStrength",
    "Interface\\Icons\\Racial_Dwarf_FindTreasure",
    "Interface\\Icons\\Spell_Holy_ChampionsBond",
    "Interface\\Icons\\Ability_Warrior_BattleShout",
    -- Raid Markers
    "Interface\\Icons\\INV_Misc_QirajiCrystal_05",         -- Star
    "Interface\\Icons\\INV_Misc_Gem_FlameSpessarite_02",    -- Circle
    "Interface\\Icons\\INV_Misc_Gem_Variety_02",            -- Diamond
    "Interface\\Icons\\INV_Misc_Gem_Pearl_06",              -- Triangle
    "Interface\\Icons\\INV_Misc_Gem_Opal_01",               -- Moon
    "Interface\\Icons\\INV_Misc_Gem_Emerald_03",            -- Square
    "Interface\\Icons\\Spell_Shadow_SacrificialShield",     -- Cross
    "Interface\\Icons\\Spell_Shadow_DeathCoil",              -- Skull
    -- Classes
    "Interface\\Icons\\INV_Sword_04",                       -- Warrior
    "Interface\\Icons\\INV_Hammer_01",                      -- Paladin
    "Interface\\Icons\\INV_Weapon_Bow_07",                  -- Hunter
    "Interface\\Icons\\INV_ThrowingKnife_02",               -- Rogue
    "Interface\\Icons\\INV_Staff_30",                       -- Priest
    "Interface\\Icons\\Spell_Shadow_DemonBreath",           -- DK (TBC-safe)
    "Interface\\Icons\\INV_Jewelry_Talisman_04",            -- Shaman
    "Interface\\Icons\\INV_Staff_13",                       -- Mage
    "Interface\\Icons\\Spell_Nature_FaerieFire",            -- Warlock
    "Interface\\Icons\\INV_Staff_01",                       -- Druid
    -- Social
    "Interface\\Icons\\INV_Misc_GroupLooking",
    "Interface\\Icons\\INV_Misc_GroupNeedMore",
    "Interface\\Icons\\Ability_Warrior_RallyingCry",
    "Interface\\Icons\\INV_Misc_Note_01",
    "Interface\\Icons\\INV_Misc_Note_06",
    "Interface\\Icons\\INV_Letter_15",
    "Interface\\Icons\\INV_Shield_07",
    "Interface\\Icons\\Ability_Parry",
    "Interface\\Icons\\Spell_Holy_AuraOfLight",
    "Interface\\Icons\\Spell_Fire_Flare",
    -- Nature & Magic
    "Interface\\Icons\\Spell_Nature_StormReach",
    "Interface\\Icons\\Spell_Shadow_Twilight",
    "Interface\\Icons\\Spell_Arcane_TeleportStormwind",
    "Interface\\Icons\\Spell_Frost_FrostBolt02",
    "Interface\\Icons\\Spell_Nature_Regeneration",
    "Interface\\Icons\\Spell_Holy_PowerWordShield",
    "Interface\\Icons\\Spell_Fire_Immolation",
    "Interface\\Icons\\Spell_Nature_EarthBind",
    -- Items & Professions
    "Interface\\Icons\\INV_Chest_Plate16",
    "Interface\\Icons\\INV_Helmet_47",
    "Interface\\Icons\\Ability_Rogue_Sprint",
    "Interface\\Icons\\INV_Misc_Coin_02",
    "Interface\\Icons\\Trade_Blacksmithing",
    "Interface\\Icons\\INV_Pick_02",
    "Interface\\Icons\\INV_Misc_Herb_Flamecap",
    "Interface\\Icons\\Trade_Alchemy",
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Colors                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

iCC.Colors = {
    iCC     = "|cFFFF9716",  -- Addon orange
    Green   = "|cFF00FF00",
    Red     = "|cFFFF0000",
    Gray    = "|cFF808080",
    White   = "|cFFFFFFFF",
    Yellow  = "|cFFFFFF00",
    Orange  = "|cFFFFA500",
    Reset   = "|r",

    Online  = "|cFF00FF00",  -- Green for online
    Offline = "|cFF808080",  -- Gray for offline

    -- Roles
    Leader  = "|cFFFFD700",  -- Gold
    Officer = "|cFF00BFFF",  -- Deep sky blue
    Member  = "|cFFFFFFFF",  -- White

    -- WoW Class Colors
    Classes = {
        ["WARRIOR"]     = "|cFFC79C6E",
        ["PALADIN"]     = "|cFFF58CBA",
        ["HUNTER"]      = "|cFFABD473",
        ["ROGUE"]       = "|cFFFFF569",
        ["PRIEST"]      = "|cFFFFFFFF",
        ["DEATHKNIGHT"] = "|cFFC41F3B",
        ["SHAMAN"]      = "|cFF0070DE",
        ["MAGE"]        = "|cFF69CCF0",
        ["WARLOCK"]     = "|cFF9482C9",
        ["MONK"]        = "|cFF00FF96",
        ["DRUID"]       = "|cFFFF7D0A",
        ["DEMONHUNTER"] = "|cFFA330C9",
        ["EVOKER"]      = "|cFF33937F",
    },
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Realm & Player                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

iCC.CurrentRealm = GetRealmName()

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Runtime State                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

iCC.State = {
    InCombat = false,
    PopupActive = false,
    ActiveCommunity = nil,  -- Currently viewed community key
}

iCC.ActiveTimers = {}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Settings Defaults                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

iCC.SettingsDefault = {
    DebugMode = false,
    MinimapButton = { hide = false, minimapPos = -30 },
    WelcomeMessage = "0",
    ShowTimestamps = true,
    ChatFontSize = 12,
    PlaySoundOnMessage = false,
    MaxMessageHistory = 200,
    HeartbeatInterval = 90,
    OfflineThreshold = 270,
    MyCharacters = {},
    ChatFrames = {},  -- [frameIndex] = true for extra chat tabs to output to
}

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Template Compatibility                             │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Retail 10.0+ removed InterfaceOptionsCheckButtonTemplate
iCC.CHECKBOX_TEMPLATE = InterfaceOptionsCheckButtonTemplate and "InterfaceOptionsCheckButtonTemplate" or "UICheckButtonTemplate"
-- Retail requires BackdropTemplateMixin for BackdropTemplate
iCC.BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil
