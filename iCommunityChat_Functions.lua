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
-- │                                 iCC Functions                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local L = iCC.L

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              UTF-8 Safe Helpers                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Returns byte length of the first UTF-8 character in a string
local function UTF8FirstCharLen(str)
    if not str or str == "" then return 0 end
    local byte = string.byte(str, 1)
    if byte < 128 then return 1
    elseif byte < 224 then return 2
    elseif byte < 240 then return 3
    else return 4
    end
end

-- Uppercase the first character of a string, UTF-8 safe
-- Only applies upper() to single-byte (ASCII) first chars; leaves multi-byte chars as-is
local function UTF8UcFirst(str)
    if not str or str == "" then return str end
    local len = UTF8FirstCharLen(str)
    if len == 1 then
        return str:sub(1, 1):upper() .. str:sub(2)
    end
    -- Multi-byte first char: return unchanged (WoW already provides correct casing)
    return str
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Strip Color Codes                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function StripColorCodes(input)
    return input:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                  Debug & Chat                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Print debug message if Debug mode is active
function iCC:DebugMsg(message, level)
    if iCCSettings.DebugMode then
        if level == 3 then
            print(L["DebugInfo"] .. message)
        elseif level == 2 then
            print(L["DebugWarning"] .. message)
        else
            print(L["DebugError"] .. message)
        end
    end
end

-- Print a standard addon message to chat
function iCC:Msg(message, communityKey)
    iCC:PrintToAllChatFrames(iCC.Colors.iCC .. "[iCC]:|r " .. message, communityKey)
end

-- Build a clickable community name link for chat output
function iCC:MakeCommunityLink(communityName, communityKey)
    return "|HgarrMission:iCC:" .. communityKey .. "|h" .. iCC.Colors.iCC .. "[" .. communityName .. "]|h|r"
end

-- Print a message to General (ChatFrame1) + enabled custom chat tabs
-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Sticky Chat Mode                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Store the original chat tab name so we can restore it
local originalTabName = nil
local originalTextInsets = nil

-- Apply the community header to the chat edit box
local function ApplyChatModeHeader()
    if not iCC.State.ChatMode or not iCC.State.ChatModeCommunity then return end
    local community = iCCCommunities[iCC.State.ChatModeCommunity]
    if not community then return end

    local editBox = ChatFrame1EditBox
    if not originalTextInsets then
        local l, r, t, b = editBox:GetTextInsets()
        originalTextInsets = { l, r, t, b }
    end
    editBox:SetAttribute("chatType", "SAY")
    editBox.header:SetText(iCC.Colors.iCC .. community.name .. ":|r ")
    editBox.header:SetTextColor(1, 0.59, 0.09)
    editBox:SetTextColor(1, 0.59, 0.09)
    editBox:SetTextInsets(editBox.header:GetStringWidth() + 15, 0, 0, 0)
end

-- Enter "sticky" community chat mode — like /g for guild chat
-- Renames the chat tab, replaces the edit box header, and intercepts messages.
-- Mode persists until explicitly exited with /s, /g, /p, /w, or /cc toggle.
function iCC:EnterChatMode(communityKey)
    if not communityKey or not iCCCommunities[communityKey] then return end

    iCC.State.ChatMode = true
    iCC.State.ChatModeCommunity = communityKey

    local communityName = iCCCommunities[communityKey].name or communityKey

    -- Rename the chat tab to the community name
    local tab = _G["ChatFrame1Tab"]
    if tab then
        if not originalTabName then
            originalTabName = tab:GetText()
        end
        tab:SetText(iCC.Colors.iCC .. communityName .. "|r")
    end

    iCC:Msg("Community chat mode " .. iCC.Colors.Green .. "on|r: " .. iCC.Colors.iCC .. communityName .. "|r", communityKey)

    -- Open the chat edit box after a frame delay (slash command closes it otherwise)
    C_Timer.After(0, function()
        if not iCC.State.ChatMode then return end
        ChatFrame_OpenChat("", ChatFrame1)
        ApplyChatModeHeader()
    end)
end

-- Exit sticky chat mode and restore the chat tab name
function iCC:ExitChatMode()
    iCC.State.ChatMode = false
    iCC.State.ChatModeCommunity = nil

    -- Restore original tab name
    local tab = _G["ChatFrame1Tab"]
    if tab and originalTabName then
        tab:SetText(originalTabName)
        originalTabName = nil
    end

    -- Restore original text color and insets
    local editBox = ChatFrame1EditBox
    editBox:SetTextColor(1, 1, 1)
    if originalTextInsets then
        editBox:SetTextInsets(unpack(originalTextInsets))
        originalTextInsets = nil
    end
end

-- Install the OnEnterPressed hook — called once from OnEnable
function iCC:InstallChatModeHook()
    local editBox = ChatFrame1EditBox
    local origOnEnterPressed = editBox:GetScript("OnEnterPressed")

    editBox:SetScript("OnEnterPressed", function(self)
        if iCC.State.ChatMode then
            local text = self:GetText()

            -- If text starts with /, exit chat mode and let WoW handle it
            if text and text:sub(1, 1) == "/" then
                iCC:ExitChatMode()
                if origOnEnterPressed then
                    origOnEnterPressed(self)
                end
                return
            end

            -- Send non-slash text to the community
            if text and text ~= "" then
                local cKey = iCC.State.ChatModeCommunity
                if cKey and iCCCommunities[cKey] then
                    iCC:SendChatMessage(cKey, text)
                end
            end

            -- Close edit box normally (like WoW default)
            self:SetText("")
            self:ClearFocus()
            return
        end

        -- Not in chat mode — call original handler
        if origOnEnterPressed then
            origOnEnterPressed(self)
        end
    end)

    -- When edit box opens (user presses Enter), re-apply header if in chat mode
    editBox:HookScript("OnShow", function()
        if iCC.State.ChatMode then
            C_Timer.After(0, function()
                ApplyChatModeHeader()
            end)
        end
    end)

    -- Detect slash commands typed in the edit box
    editBox:HookScript("OnTextChanged", function(self, userInput)
        if not userInput then return end
        local text = self:GetText()

        -- /cc typed while NOT in chat mode — activate immediately (like /g, /s)
        if not iCC.State.ChatMode and text then
            local lower = text:lower()
            if lower == "/cc " then
                self:SetText("")
                -- Resolve community
                local communityKey = iCC.State.ActiveCommunity
                if not communityKey then
                    local communities = iCC:GetMyCommunities()
                    if #communities > 0 then
                        communityKey = communities[1].key
                        iCC.State.ActiveCommunity = communityKey
                    end
                end
                if communityKey and iCCCommunities[communityKey] then
                    iCC.State.ChatMode = true
                    iCC.State.ChatModeCommunity = communityKey
                    local communityName = iCCCommunities[communityKey].name or communityKey
                    local tab = _G["ChatFrame1Tab"]
                    if tab then
                        if not originalTabName then originalTabName = tab:GetText() end
                        tab:SetText(iCC.Colors.iCC .. communityName .. "|r")
                    end
                    ApplyChatModeHeader()
                    iCC:Msg("Community chat mode " .. iCC.Colors.Green .. "on|r: " .. iCC.Colors.iCC .. communityName .. "|r", communityKey)
                else
                    iCC:Msg("No community to chat in.")
                end
                return
            end
        end

        -- /cc typed while IN chat mode — toggle off
        if iCC.State.ChatMode and text then
            local lower = text:lower()
            if lower == "/cc " then
                self:SetText("")
                local cKey = iCC.State.ChatModeCommunity
                iCC:ExitChatMode()
                iCC:Msg("Community chat mode " .. iCC.Colors.Red .. "off|r.", cKey)
                return
            end
        end

        -- In chat mode — detect when WoW processes a slash command and exit
        if iCC.State.ChatMode then
            -- WoW changed chat type to something other than SAY (e.g. /g, /p, /w)
            if self.chatType and self.chatType ~= "SAY" then
                iCC:ExitChatMode()
                return
            end
            -- WoW processed /s — chatType is still SAY but WoW rewrote the header
            local headerText = self.header and self.header:GetText() or ""
            local community = iCCCommunities[iCC.State.ChatModeCommunity]
            if community and not headerText:find(community.name, 1, true) then
                iCC:ExitChatMode()
            end
        end
    end)
end

-- If communityKey is provided, use per-community ChatFrames settings
-- Falls back to global iCCSettings.ChatFrames if no per-community setting
function iCC:PrintToAllChatFrames(message, communityKey)
    -- Get chat frame settings for this community
    local enabledFrames
    if communityKey and iCCCommunities and iCCCommunities[communityKey] then
        enabledFrames = iCCCommunities[communityKey].chatFrames
    end
    if not enabledFrames then
        enabledFrames = iCCSettings and iCCSettings.ChatFrames or {}
    end

    -- Check if muted (General disabled)
    if enabledFrames.muted then return end

    -- Always write to General tab (ChatFrame1)
    if ChatFrame1 then
        ChatFrame1:AddMessage(message)
    end

    -- Write to enabled custom tabs
    for i = 2, NUM_CHAT_WINDOWS do
        if enabledFrames[i] then
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame then
                chatFrame:AddMessage(message)
            end
        end
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Player & Realm                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Returns "PlayerName-RealmName" for the current player
function iCC:GetPlayerKey()
    local name = UnitName("player")
    return name .. "-" .. iCC.CurrentRealm
end

-- Ensure a player name has a realm suffix, add current realm if missing
function iCC:VerifyRealm(playerName)
    if not playerName:find("-") then
        return playerName .. "-" .. iCC.CurrentRealm
    else
        return playerName
    end
end

-- Split "Name-Realm" into name and realm parts
function iCC:SplitPlayerKey(playerKey)
    local name, realm = strsplit("-", playerKey)
    return name, realm
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Community Key Helpers                              │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Returns "CommunityName-RealmName" key
function iCC:GetCommunityKey(communityName, realm)
    realm = realm or iCC.CurrentRealm
    return communityName .. "-" .. realm
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Role & Permission                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Check if the current player has permission for an action in a community
-- Actions: "invite", "kick", "promote", "demote", "disband"
function iCC:HasPermission(communityKey, action)
    if not iCCCommunities or not iCCCommunities[communityKey] then
        return false
    end

    local myRole = iCCCommunities[communityKey].myRole

    if myRole == iCC.CONSTANTS.ROLE_LEADER then
        -- Leader can do everything
        return true
    elseif myRole == iCC.CONSTANTS.ROLE_OFFICER then
        -- Officers can invite and kick
        return action == "invite" or action == "kick"
    else
        -- Members have no management permissions
        return false
    end
end

-- Get role display color
function iCC:GetRoleColor(role)
    if role == iCC.CONSTANTS.ROLE_LEADER then
        return iCC.Colors.Leader
    elseif role == iCC.CONSTANTS.ROLE_OFFICER then
        return iCC.Colors.Officer
    else
        return iCC.Colors.Member
    end
end

-- Get custom rank display name for a role in a community
function iCC:GetRankDisplayName(communityKey, role)
    if communityKey and iCCCommunities[communityKey] then
        local rankNames = iCCCommunities[communityKey].rankNames
        if rankNames and rankNames[role] and rankNames[role] ~= "" then
            return rankNames[role]
        end
    end
    return role
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Online Status Helpers                              │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Count online members in a community
function iCC:GetOnlineCount(communityKey)
    if not iCCCommunities or not iCCCommunities[communityKey] then
        return 0, 0
    end

    local online = 0
    local total = 0
    for _, member in pairs(iCCCommunities[communityKey].members) do
        total = total + 1
        if member.online then
            online = online + 1
        end
    end
    return online, total
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                             Class Color Helpers                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Colorize a player name by their class
function iCC:ColorizePlayerNameByClass(playerName, class)
    if iCC.Colors.Classes[class] then
        return iCC.Colors.Classes[class] .. playerName .. iCC.Colors.Reset
    else
        return iCC.Colors.iCC .. playerName .. iCC.Colors.Reset
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                 Frame Helpers                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Create a standard iCC styled frame with backdrop
function iCC:CreateiCCStyleFrame(parent, width, height, point, backdrop)
    local frameName = "iCCFrame_" .. tostring(math.random(1, 100000))
    local frame = CreateFrame("Frame", frameName, parent, iCC.BACKDROP_TEMPLATE)
    frame:SetSize(width, height)
    frame:SetPoint(unpack(point))
    frame:SetBackdrop(backdrop or {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    -- Add to UISpecialFrames for ESC functionality
    if not tContains(UISpecialFrames, frame:GetName()) then
        tinsert(UISpecialFrames, frame:GetName())
    end
    return frame
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Text Utilities                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Split text at the last space within maxLength
function iCC:SplitOnSpace(text, maxLength)
    local spacePos = text:sub(1, maxLength):match(".*() ")
    if not spacePos then
        spacePos = maxLength
    end
    return text:sub(1, spacePos), text:sub(spacePos + 1)
end

-- Format a timestamp for chat display
function iCC:FormatTimestamp(timestamp)
    if not timestamp then return "" end
    return date("%H:%M", timestamp)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Initialization                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Initialize settings with defaults for any missing keys
function iCC:InitializeSettings()
    if not iCCSettings then
        iCCSettings = {}
    end
    for key, value in pairs(iCC.SettingsDefault) do
        if iCCSettings[key] == nil then
            if type(value) == "table" then
                -- Deep copy table defaults
                iCCSettings[key] = {}
                for k, v in pairs(value) do
                    iCCSettings[key][k] = v
                end
            else
                iCCSettings[key] = value
            end
        end
    end
end

-- Initialize communities SavedVariable
function iCC:InitializeCommunities()
    if not iCCCommunities then
        iCCCommunities = {}
    end

    -- Reset all online statuses on load (runtime only)
    for communityKey, community in pairs(iCCCommunities) do
        if community.members then
            for memberKey, member in pairs(community.members) do
                member.online = false
            end
        end
        -- Clear any stale message history beyond max
        if community.messages and #community.messages > iCC.CONSTANTS.MAX_MESSAGE_HISTORY then
            local trimmed = {}
            local startIdx = #community.messages - iCC.CONSTANTS.MAX_MESSAGE_HISTORY + 1
            for i = startIdx, #community.messages do
                trimmed[#trimmed + 1] = community.messages[i]
            end
            community.messages = trimmed
        end
    end
end
