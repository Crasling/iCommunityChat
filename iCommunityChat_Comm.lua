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
-- │                           Communication Protocol                               │
-- │                        All messages via AceComm WHISPER                         │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local L = iCC.L

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Register Comm Channels                              │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:RegisterCommChannels()
    self:RegisterComm("iCCChat",      "OnChatMessage")
    self:RegisterComm("iCCHeartbeat", "OnHeartbeat")
    self:RegisterComm("iCCInvite",    "OnInviteReceived")
    self:RegisterComm("iCCInvAck",    "OnInviteAck")
    self:RegisterComm("iCCInvReply",  "OnInviteReply")
    self:RegisterComm("iCCRoster",    "OnRosterUpdate")
    self:RegisterComm("iCCSync",      "OnSyncMessage")
    self:RegisterComm("iCCVersion",   "OnVersionCheck")

    iCC:DebugMsg("Comm channels registered.", 3)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Broadcast To Community                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Send a message to all (online) members of a community via WHISPER
-- If onlineOnly is true, skips offline members
function iCC:BroadcastToCommunity(prefix, data, communityKey, onlineOnly)
    if not iCCCommunities or not iCCCommunities[communityKey] then return end

    local playerKey = iCC:GetPlayerKey()
    local serialized = iCC:Serialize(data)

    for memberKey, member in pairs(iCCCommunities[communityKey].members) do
        if memberKey ~= playerKey then
            if not onlineOnly or member.online then
                local name = strsplit("-", memberKey)
                iCC:SendCommMessage(prefix, serialized, "WHISPER", name)
            end
        end
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Sender Validation                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Verify that a sender is a member of a given community
local function ValidateSender(communityKey, senderKey)
    if not iCCCommunities or not iCCCommunities[communityKey] then
        return false
    end
    return iCCCommunities[communityKey].members[senderKey] ~= nil
end

-- Find which communities a sender belongs to (returns list of keys)
local function FindSenderCommunities(senderKey)
    local communities = {}
    if not iCCCommunities then return communities end

    for communityKey, community in pairs(iCCCommunities) do
        if community.members[senderKey] then
            communities[#communities + 1] = communityKey
        end
    end
    return communities
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Send: Chat Message                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Send a chat message to all online members of the active community
function iCC:SendChatMessage(communityKey, text)
    if not text or text == "" then return end
    if not communityKey then return end

    -- Truncate to max length
    if #text > iCC.CONSTANTS.MAX_CHAT_MESSAGE_LENGTH then
        text = text:sub(1, iCC.CONSTANTS.MAX_CHAT_MESSAGE_LENGTH)
    end

    local playerKey = iCC:GetPlayerKey()
    local data = {
        communityKey = communityKey,
        sender = playerKey,
        text = text,
        timestamp = time(),
    }

    iCC:BroadcastToCommunity("iCCChat", data, communityKey, true)

    -- Store locally
    iCC:AddChatMessage(communityKey, playerKey, text)

    -- Print to all chat frames
    local communityName = iCCCommunities[communityKey] and iCCCommunities[communityKey].name or communityKey
    local playerName = strsplit("-", playerKey)
    local _, classToken = UnitClass("player")
    iCC:PrintToAllChatFrames(iCC.Colors.iCC .. "[" .. communityName .. "] " .. iCC:ColorizePlayerNameByClass(playerName, classToken) .. ": |r" .. text)

    -- Fire callback so Frames can update the chat display
    iCC:SendMessage("ICC_CHAT_MESSAGE_RECEIVED", communityKey)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                             Receive: Chat Message                              │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:OnChatMessage(prefix, message, distribution, sender)
    if sender == UnitName("player") then return end

    local success, data = iCC:Deserialize(message)
    if not success or not data then
        iCC:DebugMsg("Chat deserialization failed from " .. sender, 1)
        return
    end

    local senderKey = iCC:VerifyRealm(sender)
    local communityKey = data.communityKey

    -- Validate sender is in this community
    if not ValidateSender(communityKey, senderKey) then
        iCC:DebugMsg("Chat rejected from non-member: " .. senderKey, 2)
        return
    end

    -- Store message locally
    iCC:AddChatMessage(communityKey, senderKey, data.text)

    -- Update sender's last seen
    iCC:UpdateMemberStatus(communityKey, senderKey)

    -- Print to all chat frames
    local communityName = iCCCommunities[communityKey] and iCCCommunities[communityKey].name or communityKey
    local senderName = strsplit("-", senderKey)
    local senderClass = iCCCommunities[communityKey].members[senderKey] and iCCCommunities[communityKey].members[senderKey].class or "UNKNOWN"
    iCC:PrintToAllChatFrames(iCC.Colors.iCC .. "[" .. communityName .. "] " .. iCC:ColorizePlayerNameByClass(senderName, senderClass) .. ": |r" .. data.text)

    -- Fire callback for UI
    iCC:SendMessage("ICC_CHAT_MESSAGE_RECEIVED", communityKey)

    -- Play sound if enabled
    if iCCSettings and iCCSettings.PlaySoundOnMessage then
        PlaySound(SOUNDKIT.TELL_MESSAGE)
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Send: Heartbeat                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Broadcast heartbeat to all communities
function iCC:SendHeartbeat()
    if not iCCCommunities then return end

    local playerKey = iCC:GetPlayerKey()
    local _, classToken = UnitClass("player")
    local level = UnitLevel("player")

    for communityKey, community in pairs(iCCCommunities) do
        local data = {
            communityKey = communityKey,
            sender = playerKey,
            class = classToken,
            level = level,
        }

        iCC:BroadcastToCommunity("iCCHeartbeat", data, communityKey, false)

        -- Update own status
        if community.members[playerKey] then
            community.members[playerKey].lastSeen = time()
            community.members[playerKey].online = true
            community.members[playerKey].class = classToken
            community.members[playerKey].level = level
        end

        -- Check timeouts
        iCC:CheckOfflineMembers(communityKey)
    end

    iCC:DebugMsg("Heartbeat sent to all communities.", 3)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                             Receive: Heartbeat                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:OnHeartbeat(prefix, message, distribution, sender)
    if sender == UnitName("player") then return end

    local success, data = iCC:Deserialize(message)
    if not success or not data then return end

    local senderKey = iCC:VerifyRealm(sender)
    local communityKey = data.communityKey

    if not ValidateSender(communityKey, senderKey) then return end

    local wasOffline = false
    local member = iCCCommunities[communityKey].members[senderKey]
    if member and not member.online then
        wasOffline = true
    end

    iCC:UpdateMemberStatus(communityKey, senderKey, data.class, data.level)

    -- Notify UI if status changed
    if wasOffline then
        iCC:SendMessage("ICC_ROSTER_UPDATED", communityKey)
        iCC:DebugMsg(senderKey .. " came online in " .. communityKey, 3)
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Send: Invite                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Send an invitation to a specific player
function iCC:SendInvite(communityKey, targetPlayer)
    if not iCC:HasPermission(communityKey, "invite") then
        iCC:Msg("You do not have permission to invite.")
        return
    end

    local community = iCCCommunities[communityKey]
    if not community then return end

    local playerKey = iCC:GetPlayerKey()
    local data = {
        communityKey = communityKey,
        communityName = community.name,
        inviter = playerKey,
    }

    local serialized = iCC:Serialize(data)
    iCC:SendCommMessage("iCCInvite", serialized, "WHISPER", targetPlayer)
    iCC:Msg("Invitation sent to " .. iCC.Colors.iCC .. targetPlayer .. iCC.Colors.Reset .. ".")
    iCC:DebugMsg("Invite sent to " .. targetPlayer .. " for " .. communityKey, 3)

    -- Track pending invite — if no ack within 5s, target doesn't have the addon
    iCC.PendingInvites = iCC.PendingInvites or {}
    iCC.PendingInvites[targetPlayer] = true
    local inviterName = UnitName("player")
    local communityName = community.name
    C_Timer.After(5, function()
        if iCC.PendingInvites[targetPlayer] then
            SendChatMessage(
                inviterName .. ' has invited you to join "' .. communityName .. '" via "iCommunityChat" on CurseForge!',
                "WHISPER", nil, targetPlayer
            )
            iCC.PendingInvites[targetPlayer] = nil
        end
    end)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Receive: Invite Ack                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:OnInviteAck(prefix, message, distribution, sender)
    local senderName = strsplit("-", sender)
    if iCC.PendingInvites then
        iCC.PendingInvites[senderName] = nil
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                             Receive: Invite                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:OnInviteReceived(prefix, message, distribution, sender)
    if sender == UnitName("player") then return end

    -- Ack back so sender knows we have the addon
    local senderName = strsplit("-", sender)
    iCC:SendCommMessage("iCCInvAck", "ack", "WHISPER", senderName)

    local success, data = iCC:Deserialize(message)
    if not success or not data then return end

    local communityKey = data.communityKey
    local communityName = data.communityName
    local inviter = data.inviter or iCC:VerifyRealm(sender)

    -- Check if already in this community
    if iCCCommunities and iCCCommunities[communityKey] then
        iCC:DebugMsg("Already in community: " .. communityKey .. ", ignoring invite.", 3)
        return
    end

    -- Check max communities
    local count = 0
    if iCCCommunities then
        for _ in pairs(iCCCommunities) do
            count = count + 1
        end
    end
    if count >= iCC.CONSTANTS.MAX_COMMUNITIES_PER_PLAYER then
        iCC:SendInviteReply(sender, communityKey, false, "max_communities")
        iCC:Msg("Cannot join " .. communityName .. " — you are in too many communities.")
        return
    end

    -- Show popup to accept or decline
    iCC:ShowInvitePopup(communityName, inviter, communityKey, sender)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Send: Invite Reply                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:SendInviteReply(targetPlayer, communityKey, accepted, reason)
    local playerKey = iCC:GetPlayerKey()
    local _, classToken = UnitClass("player")
    local level = UnitLevel("player")

    local data = {
        communityKey = communityKey,
        sender = playerKey,
        accepted = accepted,
        class = classToken,
        level = level,
        reason = reason,
    }

    local serialized = iCC:Serialize(data)
    iCC:SendCommMessage("iCCInvReply", serialized, "WHISPER", targetPlayer)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Receive: Invite Reply                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:OnInviteReply(prefix, message, distribution, sender)
    if sender == UnitName("player") then return end

    local success, data = iCC:Deserialize(message)
    if not success or not data then return end

    local communityKey = data.communityKey
    local senderKey = data.sender or iCC:VerifyRealm(sender)

    if data.accepted then
        -- Add them to our roster
        local ok, err = iCC:AddMember(communityKey, senderKey, data.class, data.level)
        if ok then
            local name = strsplit("-", senderKey)
            iCC:Msg(iCC:ColorizePlayerNameByClass(name, data.class) .. " joined the community!")

            -- Broadcast roster change to all online members
            iCC:BroadcastRosterChange(communityKey, "add", senderKey, data)

            -- Send full roster sync to the new member
            iCC:SendSyncResponse(sender, communityKey)

            -- Notify UI
            iCC:SendMessage("ICC_ROSTER_UPDATED", communityKey)
        else
            iCC:DebugMsg("Failed to add " .. senderKey .. ": " .. (err or ""), 1)
        end
    else
        local name = strsplit("-", senderKey)
        local reasonText = ""
        if data.reason == "max_communities" then
            reasonText = " (too many communities)"
        end
        iCC:Msg(iCC.Colors.Red .. name .. iCC.Colors.Reset .. " declined the invitation" .. reasonText .. ".")
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Broadcast Roster Change                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Notify all online members of a roster change (add, remove, role change)
function iCC:BroadcastRosterChange(communityKey, action, memberKey, memberData)
    local community = iCCCommunities[communityKey]
    if not community then return end

    local data = {
        communityKey = communityKey,
        action = action,           -- "add", "remove", "role"
        memberKey = memberKey,
        memberData = memberData,   -- Full member data for "add", role for "role"
        rosterVersion = community.rosterVersion,
    }

    iCC:BroadcastToCommunity("iCCRoster", data, communityKey, true)
end

function iCC:BroadcastSettingsChange(communityKey)
    local community = iCCCommunities[communityKey]
    if not community then return end

    community.rosterVersion = community.rosterVersion + 1

    local data = {
        communityKey = communityKey,
        action = "settings",
        icon = community.icon,
        description = community.description,
        rules = community.rules,
        rosterVersion = community.rosterVersion,
    }

    iCC:BroadcastToCommunity("iCCRoster", data, communityKey, true)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Receive: Roster Update                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:OnRosterUpdate(prefix, message, distribution, sender)
    if sender == UnitName("player") then return end

    local success, data = iCC:Deserialize(message)
    if not success or not data then return end

    local senderKey = iCC:VerifyRealm(sender)
    local communityKey = data.communityKey

    if not ValidateSender(communityKey, senderKey) then return end

    local community = iCCCommunities[communityKey]
    if not community then return end

    if data.action == "add" and data.memberKey and data.memberData then
        -- Add new member if not already present
        if not community.members[data.memberKey] then
            community.members[data.memberKey] = {
                role = data.memberData.role or iCC.CONSTANTS.ROLE_MEMBER,
                joinedAt = data.memberData.joinedAt or time(),
                class = data.memberData.class or "UNKNOWN",
                level = data.memberData.level or 0,
                lastSeen = time(),
                online = true,
                note = "",
            }
            community.rosterVersion = data.rosterVersion or (community.rosterVersion + 1)

            local name = strsplit("-", data.memberKey)
            iCC:Msg(iCC:ColorizePlayerNameByClass(name, data.memberData.class or "UNKNOWN") .. " joined the community!")
        end

    elseif data.action == "remove" and data.memberKey then
        -- Remove member
        local playerKey = iCC:GetPlayerKey()
        if data.memberKey == playerKey then
            -- We got kicked
            iCCCommunities[communityKey] = nil
            if iCC.State.ActiveCommunity == communityKey then
                iCC.State.ActiveCommunity = nil
            end
            iCC:Msg("You have been removed from " .. iCC.Colors.iCC .. community.name .. iCC.Colors.Reset .. ".")
        else
            local name = strsplit("-", data.memberKey)
            local memberClass = community.members[data.memberKey] and community.members[data.memberKey].class
            community.members[data.memberKey] = nil
            community.rosterVersion = data.rosterVersion or (community.rosterVersion + 1)
            iCC:Msg(iCC:ColorizePlayerNameByClass(name, memberClass or "UNKNOWN") .. " left the community.")
        end

    elseif data.action == "role" and data.memberKey and data.memberData then
        -- Role change
        local member = community.members[data.memberKey]
        if member then
            member.role = data.memberData.role or member.role
            community.rosterVersion = data.rosterVersion or (community.rosterVersion + 1)

            -- Update myRole if it's us
            local playerKey = iCC:GetPlayerKey()
            if data.memberKey == playerKey then
                community.myRole = member.role
            end
        end

    elseif data.action == "settings" then
        -- Community settings update from leader
        if data.icon ~= nil then community.icon = data.icon end
        community.description = data.description or community.description or ""
        community.rules = data.rules or community.rules or ""
        community.rosterVersion = data.rosterVersion or (community.rosterVersion + 1)
    end

    -- Notify UI
    iCC:SendMessage("ICC_ROSTER_UPDATED", communityKey)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Request: Roster Sync                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Request a full roster sync from a member (typically on login)
function iCC:RequestSync(communityKey)
    if not iCCCommunities or not iCCCommunities[communityKey] then return end

    local playerKey = iCC:GetPlayerKey()
    local data = {
        communityKey = communityKey,
        sender = playerKey,
        action = "request",
        rosterVersion = iCCCommunities[communityKey].rosterVersion,
    }

    -- Send to the first online member that isn't us
    for memberKey, member in pairs(iCCCommunities[communityKey].members) do
        if memberKey ~= playerKey and member.online then
            local name = strsplit("-", memberKey)
            local serialized = iCC:Serialize(data)
            iCC:SendCommMessage("iCCSync", serialized, "WHISPER", name)
            iCC:DebugMsg("Sync requested from " .. memberKey .. " for " .. communityKey, 3)
            return
        end
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Send: Sync Response                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Send a full roster to a specific player
function iCC:SendSyncResponse(targetPlayer, communityKey)
    if not iCCCommunities or not iCCCommunities[communityKey] then return end

    local community = iCCCommunities[communityKey]

    -- Build sync payload: members without runtime-only fields
    local syncMembers = {}
    for memberKey, member in pairs(community.members) do
        syncMembers[memberKey] = {
            role = member.role,
            joinedAt = member.joinedAt,
            class = member.class,
            level = member.level,
            note = member.note,
        }
    end

    local data = {
        communityKey = communityKey,
        action = "response",
        rosterVersion = community.rosterVersion,
        members = syncMembers,
        communityName = community.name,
        realm = community.realm,
        createdBy = community.createdBy,
        createdAt = community.createdAt,
        icon = community.icon,
        description = community.description,
        rules = community.rules,
    }

    local serialized = iCC:Serialize(data)
    iCC:SendCommMessage("iCCSync", serialized, "WHISPER", targetPlayer)
    iCC:DebugMsg("Sync response sent to " .. targetPlayer .. " for " .. communityKey, 3)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Receive: Sync Message                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:OnSyncMessage(prefix, message, distribution, sender)
    if sender == UnitName("player") then return end

    local success, data = iCC:Deserialize(message)
    if not success or not data then return end

    local senderKey = iCC:VerifyRealm(sender)
    local communityKey = data.communityKey

    if data.action == "request" then
        -- Someone is requesting our roster
        if not ValidateSender(communityKey, senderKey) then return end

        -- Only respond if our version is higher
        local community = iCCCommunities[communityKey]
        if community and (not data.rosterVersion or community.rosterVersion > data.rosterVersion) then
            iCC:SendSyncResponse(sender, communityKey)
        end

    elseif data.action == "response" then
        -- We received a full roster sync
        if iCCCommunities[communityKey] then
            local ok = iCC:ApplyRosterSync(communityKey, data)
            if ok then
                iCC:SendMessage("ICC_ROSTER_UPDATED", communityKey)
            end
        end
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Version Check                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Convert version string to comparable number
function iCC:ConvertVersionToNumber(versionString)
    local major, minor, patch, build = string.match(versionString, "(%d+)%.(%d+)%.(%d+)%.?(%d*)")
    if major and minor and patch then
        local hasBuild = build and build ~= ""
        return tonumber(major) * 1000000 + tonumber(minor) * 10000 + tonumber(patch) * 100 + (tonumber(build) or 0), hasBuild
    end
    return 0, false
end

-- Send version to all community members
function iCC:CheckLatestVersion()
    local versionNumber, isAlphaVersion = iCC:ConvertVersionToNumber(iCC.Version)

    if isAlphaVersion then
        print(L["VersionWarning"])
        iCC:DebugMsg("Alpha version detected: " .. iCC.Version .. ". Version check skipped.", 2)
        return
    end

    local serialized = iCC:Serialize(versionNumber)

    for communityKey, community in pairs(iCCCommunities) do
        local playerKey = iCC:GetPlayerKey()
        for memberKey, member in pairs(community.members) do
            if memberKey ~= playerKey and member.online then
                local name = strsplit("-", memberKey)
                iCC:SendCommMessage("iCCVersion", serialized, "WHISPER", name)
            end
        end
    end
end

-- Receive version from another player
function iCC:OnVersionCheck(prefix, message, distribution, sender)
    if sender == UnitName("player") then return end

    local versionNumber, isAlphaVersion = iCC:ConvertVersionToNumber(iCC.Version)
    if isAlphaVersion then return end

    local success, retrievedVersion = iCC:Deserialize(message)
    if not success then return end

    if retrievedVersion > versionNumber and not iCC.State.VersionMessaged then
        iCC:Msg("A newer version of iCommunityChat is available!")
        iCC.State.VersionMessaged = true
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                             Heartbeat Timer                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Start the recurring heartbeat timer
function iCC:StartHeartbeatTimer()
    -- Cancel existing timer if any
    if iCC.ActiveTimers.heartbeat then
        iCC:CancelTimer(iCC.ActiveTimers.heartbeat)
        iCC.ActiveTimers.heartbeat = nil
    end

    local interval = iCCSettings and iCCSettings.HeartbeatInterval or iCC.CONSTANTS.HEARTBEAT_INTERVAL

    -- Auto-adjust for large communities
    local totalMembers = 0
    if iCCCommunities then
        for _, community in pairs(iCCCommunities) do
            for _ in pairs(community.members) do
                totalMembers = totalMembers + 1
            end
        end
    end
    if totalMembers > 20 then
        interval = interval * 1.5
    end

    iCC.ActiveTimers.heartbeat = iCC:ScheduleRepeatingTimer("SendHeartbeat", interval)
    iCC:DebugMsg("Heartbeat timer started: " .. interval .. "s interval.", 3)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Invite Popup (Static)                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Show a StaticPopup for an incoming invitation
function iCC:ShowInvitePopup(communityName, inviter, communityKey, senderName)
    -- Register the popup dialog if not already done
    if not StaticPopupDialogs["ICC_INVITE_POPUP"] then
        StaticPopupDialogs["ICC_INVITE_POPUP"] = {
            text = "%s",
            button1 = "Accept",
            button2 = "Decline",
            timeout = 60,
            whileDead = true,
            hideOnEscape = true,
            OnAccept = function(self)
                local popupData = self.data
                if not popupData then return end

                -- Create the community locally with Member role
                local playerKey = iCC:GetPlayerKey()
                local _, classToken = UnitClass("player")
                local level = UnitLevel("player")

                iCCCommunities[popupData.communityKey] = {
                    name = popupData.communityName,
                    realm = iCC.CurrentRealm,
                    createdBy = popupData.inviter,
                    createdAt = time(),
                    myRole = iCC.CONSTANTS.ROLE_MEMBER,
                    rosterVersion = 0,  -- Will be updated on sync
                    members = {
                        [playerKey] = {
                            role = iCC.CONSTANTS.ROLE_MEMBER,
                            joinedAt = time(),
                            class = classToken,
                            level = level,
                            lastSeen = time(),
                            online = true,
                            note = "",
                        },
                    },
                    messages = {},
                }

                -- Send accept reply
                iCC:SendInviteReply(popupData.senderName, popupData.communityKey, true)
                iCC:Msg("You joined " .. iCC.Colors.iCC .. popupData.communityName .. iCC.Colors.Reset .. "!")

                -- Start heartbeat if not already running
                iCC:StartHeartbeatTimer()

                -- Notify UI
                iCC:SendMessage("ICC_ROSTER_UPDATED", popupData.communityKey)
            end,
            OnCancel = function(self)
                local popupData = self.data
                if not popupData then return end
                iCC:SendInviteReply(popupData.senderName, popupData.communityKey, false)
            end,
        }
    end

    local inviterName = strsplit("-", inviter)
    local popupText = inviterName .. " has invited you to join the community:\n|cFFFF9716" .. communityName .. "|r"

    local popup = StaticPopup_Show("ICC_INVITE_POPUP", popupText)
    if popup then
        popup.data = {
            communityName = communityName,
            communityKey = communityKey,
            inviter = inviter,
            senderName = senderName,
        }
    end
end
