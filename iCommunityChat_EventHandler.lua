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
-- │                                 Event Handler                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local L = iCC.L

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                             Combat State Handling                              │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local combatEventFrame = CreateFrame("Frame")
iCC.State.InCombat = false

combatEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

combatEventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        iCC.State.InCombat = true

        -- Hide iCC frames during combat
        if iCC.RosterFrame then iCC.RosterFrame:Hide() end
        if iCC.SettingsFrame then iCC.SettingsFrame:Hide() end

        if StaticPopup_Visible("ICC_INVITE_POPUP") then
            StaticPopup_Hide("ICC_INVITE_POPUP")
        end

        iCC:DebugMsg("Entered combat, UI hidden.", 3)

    elseif event == "PLAYER_REGEN_ENABLED" then
        iCC.State.InCombat = false
        iCC:DebugMsg("Left combat, UI enabled.", 3)
    end
end)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                       Clickable Community Link Handler                        │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local origSetItemRef = SetItemRef
SetItemRef = function(link, text, button, chatFrame)
    local linkType, communityKey = strsplit(":", link, 3)
    if linkType == "garrMission" then
        local prefix
        prefix, communityKey = strsplit(":", link:sub(#linkType + 2))
        if prefix == "iCC" and communityKey and iCCCommunities and iCCCommunities[communityKey] then
            iCC.State.ActiveCommunity = communityKey

            if not iCC.RosterFrame or not iCC.RosterFrame:IsShown() then
                iCC:ToggleRosterFrame()
            else
                iCC:UpdateCommunityTabs()
                iCC:UpdateRosterDisplay()
                iCC:UpdateChatDisplay()
            end

            -- Focus chat input
            if iCC.RosterFrame and iCC.RosterFrame.chatInput then
                iCC.RosterFrame.chatInput:SetFocus()
            end
            return
        end
    end
    return origSetItemRef(link, text, button, chatFrame)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Player Login (Delayed)                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")

loginFrame:SetScript("OnEvent", function()
    C_Timer.After(iCC.CONSTANTS.LOGIN_DELAY, function()
        -- Send initial heartbeat to all communities
        if iCC.SendHeartbeat then
            iCC:SendHeartbeat()
        end

        -- Request roster sync from each community
        if iCC.RequestSync and iCCCommunities then
            for communityKey in pairs(iCCCommunities) do
                iCC:RequestSync(communityKey)
            end
        end

        -- Version check
        if iCC.CheckLatestVersion then
            iCC:CheckLatestVersion()
        end
    end)
end)

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Addon OnEnable                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:OnEnable()
    -- ╭────────────────────────────────────────╮
    -- │          Initialize Data               │
    -- ╰────────────────────────────────────────╯

    iCC:InitializeSettings()
    iCC:InitializeCommunities()
    iCC:SetupMinimapButton()

    -- ╭────────────────────────────────────────╮
    -- │          Debug Mode Warning            │
    -- ╰────────────────────────────────────────╯

    iCC:DebugMsg(
        "Debug Mode is activated." .. iCC.Colors.Red ..
        " This is not recommended for common use and will cause message spam.",
        3
    )

    -- ╭────────────────────────────────────────╮
    -- │          Loaded Message                │
    -- ╰────────────────────────────────────────╯

    print(
        iCC.Colors.iCC .. "[iCC]: " ..
        "iCommunityChat " ..
        iCC.GameVersionName ..
        iCC.Colors.Green .. " v" .. iCC.Version ..
        iCC.Colors.iCC .. " Loaded."
    )

    -- ╭────────────────────────────────────────╮
    -- │          Register Comms                │
    -- ╰────────────────────────────────────────╯

    iCC:RegisterCommChannels()

    -- ╭────────────────────────────────────────╮
    -- │          Start Heartbeat               │
    -- ╰────────────────────────────────────────╯

    -- Only start if we're in at least one community
    if iCCCommunities then
        local hasCommunity = false
        for _ in pairs(iCCCommunities) do
            hasCommunity = true
            break
        end
        if hasCommunity then
            iCC:StartHeartbeatTimer()
        end
    end

    -- ╭────────────────────────────────────────╮
    -- │          Slash Commands                │
    -- ╰────────────────────────────────────────╯

    SLASH_ICC1 = "/icc"
    SLASH_ICC2 = "/icommunity"
    SlashCmdList["ICC"] = function(msg)
        local cmd, arg = strsplit(" ", msg, 2)
        cmd = (cmd or ""):lower()

        if cmd == "" or cmd == "roster" then
            -- Toggle roster window
            iCC:ToggleRosterFrame()

        elseif cmd == "create" then
            if not arg or arg == "" then
                iCC:Msg("Usage: /icc create <community name>")
                return
            end
            local key, err = iCC:CreateCommunity(arg)
            if key then
                iCC:Msg("Community " .. iCC.Colors.iCC .. arg .. iCC.Colors.Reset .. " created!")
                iCC:StartHeartbeatTimer()
                iCC:SendMessage("ICC_ROSTER_UPDATED", key)
            else
                iCC:Msg(iCC.Colors.Red .. (err or "Failed to create community.") .. iCC.Colors.Reset)
            end

        elseif cmd == "invite" then
            if not arg or arg == "" then
                iCC:Msg("Usage: /icc invite <player name>")
                return
            end
            local activeCommunity = iCC.State.ActiveCommunity
            if not activeCommunity then
                -- Use first community if only one
                local communities = iCC:GetMyCommunities()
                if #communities == 1 then
                    activeCommunity = communities[1].key
                else
                    iCC:Msg("Select a community first (open the roster window).")
                    return
                end
            end
            iCC:SendInvite(activeCommunity, arg)

        elseif cmd == "settings" or cmd == "options" then
            if iCC.SettingsToggle then
                iCC:SettingsToggle()
            end

        elseif cmd == "leave" then
            local activeCommunity = iCC.State.ActiveCommunity
            if not activeCommunity then
                iCC:Msg("No active community selected. Open the roster window first.")
                return
            end
            local community = iCCCommunities[activeCommunity]
            if not community then return end

            -- Show confirmation popup
            if not StaticPopupDialogs["ICC_LEAVE_CONFIRM"] then
                StaticPopupDialogs["ICC_LEAVE_CONFIRM"] = {
                    text = "Are you sure you want to leave %s?",
                    button1 = "Leave",
                    button2 = "Cancel",
                    timeout = 30,
                    whileDead = true,
                    hideOnEscape = true,
                    OnAccept = function(self)
                        local popupData = self.data
                        if not popupData then return end

                        -- Broadcast removal to online members before leaving
                        iCC:BroadcastRosterChange(popupData.key, "remove", iCC:GetPlayerKey())

                        local ok, err = iCC:LeaveCommunity(popupData.key)
                        if ok then
                            iCC:Msg("You left " .. iCC.Colors.iCC .. popupData.name .. iCC.Colors.Reset .. ".")
                            iCC:SendMessage("ICC_ROSTER_UPDATED")
                        else
                            iCC:Msg(iCC.Colors.Red .. (err or "Failed to leave.") .. iCC.Colors.Reset)
                        end
                    end,
                }
            end
            local popup = StaticPopup_Show("ICC_LEAVE_CONFIRM", community.name)
            if popup then
                popup.data = { key = activeCommunity, name = community.name }
            end

        elseif cmd == "help" then
            iCC:Msg("Commands:")
            print("  /icc — Toggle roster window")
            print("  /icc create <name> — Create a community")
            print("  /icc invite <player> — Invite a player")
            print("  /icc leave — Leave the active community")
            print("  /icc settings — Open settings")
            print("  /icc help — Show this help")

        else
            iCC:Msg("Unknown command. Type /icc help for usage.")
        end
    end

    -- ╭────────────────────────────────────────╮
    -- │          Welcome Message               │
    -- ╰────────────────────────────────────────╯

    if iCCSettings.WelcomeMessage ~= iCC.Version then
        local playerName = UnitName("player")
        local _, class = UnitClass("player")

        print(
            L["iCCWelcomeStart"] ..
            iCC.Colors.Classes[class] ..
            playerName ..
            L["iCCWelcomeEnd"]
        )

        iCCSettings.WelcomeMessage = iCC.Version
    end
end
