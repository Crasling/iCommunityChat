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
-- │                              English Localization                              │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local L = LibStub("AceLocale-3.0"):NewLocale("iCC", "enUS", true)
if not L then return end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                     Colors                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local Colors = {
    iCC = "|cFFFF9716",
    White = "|cFFFFFFFF",
    Red = "|cFFFF0000",
    Green = "|cFF00FF00",
    Yellow = "|cFFFFFF00",
    Orange = "|cFFFFA500",
    Gray = "|cFF808080",
    Reset = "|r",
}

local function Msg(message)
    return Colors.iCC .. "[iCC]: " .. message
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Addon Messages                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["iCCLoaded"] = Msg("iCommunityChat")
L["InCombat"] = Msg("Cannot be used in combat.")
L["NewVersionAvailable"] = Msg("A new version of iCommunityChat is available!")
L["VersionWarning"] = Msg(Colors.Yellow .. "WARNING" .. Colors.iCC .. ": This is an alpha version and may be unstable. Downgrade to the latest release if you encounter issues.")
L["WelcomeMessage"] = Msg("Welcome! Type " .. Colors.iCC .. "/icc help" .. Colors.Reset .. " to get started.")
L["iCCWelcomeStart"] = Msg("Thank you ")
L["iCCWelcomeEnd"] = Colors.iCC .. " for being part of the development of iCommunityChat, if you get into any issues please reach out on CurseForge in the comment section or Discord."

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Community Messages                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["CommunityCreated"] = Msg("Community " .. Colors.iCC .. "%s" .. Colors.Reset .. " created!")
L["CommunityDisbanded"] = Msg("Community " .. Colors.iCC .. "%s" .. Colors.Reset .. " has been disbanded.")
L["CommunityJoined"] = Msg("You joined " .. Colors.iCC .. "%s" .. Colors.Reset .. "!")
L["CommunityLeft"] = Msg("You left " .. Colors.iCC .. "%s" .. Colors.Reset .. ".")
L["CommunityKicked"] = Msg("You have been removed from " .. Colors.iCC .. "%s" .. Colors.Reset .. ".")
L["CommunityNameEmpty"] = Msg(Colors.Red .. "Community name cannot be empty." .. Colors.Reset)
L["CommunityNameTooLong"] = Msg(Colors.Red .. "Community name is too long." .. Colors.Reset)
L["CommunityAlreadyExists"] = Msg(Colors.Red .. "A community with that name already exists." .. Colors.Reset)
L["CommunityMaxReached"] = Msg(Colors.Red .. "You have reached the maximum number of communities." .. Colors.Reset)
L["CommunityFull"] = Msg(Colors.Red .. "Community is full." .. Colors.Reset)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Member Messages                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["MemberJoined"] = "%s joined the community!"
L["MemberLeft"] = "%s left the community."
L["MemberKicked"] = "%s has been removed from the community."
L["MemberAlreadyExists"] = Msg(Colors.Red .. "Player is already a member." .. Colors.Reset)
L["MemberNotFound"] = Msg(Colors.Red .. "Player is not a member." .. Colors.Reset)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Invite Messages                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["InviteSent"] = Msg("Invitation sent to " .. Colors.iCC .. "%s" .. Colors.Reset .. ".")
L["InviteDeclined"] = Msg(Colors.Red .. "%s" .. Colors.Reset .. " declined the invitation.")
L["InviteDeclinedMaxCommunities"] = Msg(Colors.Red .. "%s" .. Colors.Reset .. " declined the invitation (too many communities).")
L["InviteNoPermission"] = Msg("You do not have permission to invite.")
L["InviteNoCommunity"] = Msg("No community selected.")
L["InvitePopupText"] = "%s has invited you to join the community:\n" .. Colors.iCC .. "%s" .. Colors.Reset

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Role Messages                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["RoleNoPermission"] = Msg("You do not have permission to change roles.")
L["LeaderTransferRequired"] = Msg("You must transfer leadership before leaving.")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Slash Command Help                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["SlashHelp"] = Msg("Commands:")
L["SlashHelpRoster"] = "  /icc — Toggle roster window"
L["SlashHelpCreate"] = "  /icc create <name> — Create a community"
L["SlashHelpInvite"] = "  /icc invite <player> — Invite a player"
L["SlashHelpLeave"] = "  /icc leave — Leave the active community"
L["SlashHelpSettings"] = "  /icc settings — Open settings"
L["SlashHelpHelp"] = "  /icc help — Show this help"
L["SlashUnknown"] = Msg("Unknown command. Type /icc help for usage.")
L["UsageCreate"] = Msg("Usage: /icc create <community name>")
L["UsageInvite"] = Msg("Usage: /icc invite <player name>")
L["SelectCommunityFirst"] = Msg("Select a community first (open the roster window).")
L["NoCommunitySelected"] = Msg("No active community selected. Open the roster window first.")

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Settings Labels                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["SettingsTitle"] = Colors.iCC .. "iCC Settings" .. Colors.Reset
L["SettingsGeneral"] = "General"
L["SettingsAbout"] = "About"
L["DebugMode"] = "Debug Mode"
L["DebugModeDesc"] = "Print detailed debug messages to the chat frame."
L["ShowTimestamps"] = "Show Timestamps in Chat"
L["ShowTimestampsDesc"] = "Display [HH:MM] timestamps next to chat messages."
L["PlaySoundOnMessage"] = "Play Sound on New Message"
L["PlaySoundOnMessageDesc"] = "Play a notification sound when a new community message arrives."
L["ShowMinimapButton"] = "Show Minimap Button"
L["ShowMinimapButtonDesc"] = "Show or hide the iCC minimap button."
L["SectionGeneral"] = "General"
L["SectionChat"] = "Chat"
L["SectionUI"] = "Interface"
L["SectionChatFrames"] = "Chat Output"
L["ChatFrameAlwaysOn"] = "(always on)"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Minimap Tooltip                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["MinimapLeftClick"] = Colors.Yellow .. "Left-Click: " .. Colors.iCC .. "Toggle Roster"
L["MinimapRightClick"] = Colors.Yellow .. "Right-Click: " .. Colors.iCC .. "Settings"
L["NoCommunities"] = Colors.Gray .. "No communities" .. Colors.Reset

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Roster Window                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["ColumnName"] = "Name"
L["ColumnRank"] = "Rank"
L["ColumnLevel"] = "Lvl"
L["InviteButton"] = "Invite"
L["LeaveButton"] = "Leave"
L["SendButton"] = "Send"
L["Accept"] = "Accept"
L["Decline"] = "Decline"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Context Menu                                      │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["Whisper"] = "Whisper"
L["PromoteToOfficer"] = "Promote to Officer"
L["PromoteToLeader"] = "Promote to Leader"
L["DemoteToMember"] = "Demote to Member"
L["Kick"] = "|cFFFF0000Kick|r"
L["Cancel"] = "Cancel"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Confirm Dialogs                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["LeaveConfirm"] = "Are you sure you want to leave %s?"
L["InviteDialogText"] = "Enter a player name to invite:"
L["CreateButton"] = "Create Community"
L["CreateCommunityDialogText"] = "Enter a name for the new community:"
L["CreateCommunityTooltip"] = "Create a new community"
L["CreateCommunityHint"] = "or use /icc create <name>"

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Debug Messages                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["DebugError"] = Msg(Colors.Red .. "ERROR: " .. Colors.iCC)
L["DebugWarning"] = Msg(Colors.Yellow .. "WARNING: " .. Colors.iCC)
L["DebugInfo"] = Msg(Colors.White .. "INFO: " .. Colors.iCC)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                About Tab                                      │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

L["AboutHeader"] = Colors.iCC .. "About"
L["AboutDescription"] = "Cross-guild community addon. Create private communities, chat with members across guilds, and manage your own roster — all via secure whisper protocol."
L["AboutEarlyDev"] = Colors.iCC .. "iCC " .. Colors.Reset .. "is in early development. Join the Discord for help with issues, questions, or suggestions."
L["CreatedBy"] = "Created by: "
L["DiscordHeader"] = Colors.iCC .. "Discord"
L["DiscordLinkMessage"] = "Copy this link to join our Discord for support and updates."
L["DiscordLink"] = "https://discord.gg/8nnt25aw8B"
L["TranslationsHeader"] = Colors.iCC .. "Translations"
L["Russian"] = "Russian"
L["DeveloperHeader"] = Colors.iCC .. "Developer"
L["EnableDebugMode"] = "Enable Debug Mode"
L["DescEnableDebugMode"] = "|cFF808080Enables verbose debug messages in chat. Not recommended for normal use.|r"
L["GameVersionLabel"] = Colors.iCC .. "Game Version: |r"
L["TOCVersionLabel"] = Colors.iCC .. "TOC Version: |r"
L["BuildVersionLabel"] = Colors.iCC .. "Build Version: |r"
L["BuildDateLabel"] = Colors.iCC .. "Build Date: |r"

-- Chat Date Separators
L["DateToday"] = "Today"
L["DateYesterday"] = "Yesterday"

-- Community Settings
L["CommunitySettings"] = "Community Settings"
L["CommunityIcon"] = Colors.iCC .. "Icon"
L["ChooseIcon"] = "Choose Icon"
L["RemoveIcon"] = "Remove Icon"
L["CommunityDescription"] = Colors.iCC .. "Description"
L["CommunityRules"] = Colors.iCC .. "Rules"
L["SaveSettings"] = "Save"
L["NoDescription"] = "No description set."
L["NoRules"] = "No rules set."
L["SettingsSaved"] = "Community settings saved."
L["IconPicker"] = Colors.iCC .. "Choose Icon"
