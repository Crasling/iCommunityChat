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
-- │                             Roster Data Operations                             │
-- │                          Pure data — no UI in this file                         │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local L = iCC.L

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Create Community                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Create a new community. The creating player becomes the Leader.
-- Returns communityKey on success, nil + error message on failure.
function iCC:CreateCommunity(name)
    if not name or name == "" then
        return nil, "Community name cannot be empty."
    end

    -- Enforce name length
    if #name > iCC.CONSTANTS.MAX_COMMUNITY_NAME then
        return nil, "Community name is too long (max " .. iCC.CONSTANTS.MAX_COMMUNITY_NAME .. " characters)."
    end

    -- Check max communities
    local count = 0
    for _ in pairs(iCCCommunities) do
        count = count + 1
    end
    if count >= iCC.CONSTANTS.MAX_COMMUNITIES_PER_PLAYER then
        return nil, "You have reached the maximum number of communities (" .. iCC.CONSTANTS.MAX_COMMUNITIES_PER_PLAYER .. ")."
    end

    local communityKey = iCC:GetCommunityKey(name)

    -- Check if already exists
    if iCCCommunities[communityKey] then
        return nil, "A community with that name already exists on this realm."
    end

    local playerKey = iCC:GetPlayerKey()
    local _, classToken = UnitClass("player")
    local level = UnitLevel("player")
    local now = time()

    iCCCommunities[communityKey] = {
        name = name,
        realm = iCC.CurrentRealm,
        createdBy = playerKey,
        createdAt = now,
        myRole = iCC.CONSTANTS.ROLE_LEADER,
        rosterVersion = 1,
        icon = nil,
        description = "",
        rules = "",
        members = {
            [playerKey] = {
                role = iCC.CONSTANTS.ROLE_LEADER,
                joinedAt = now,
                class = classToken,
                level = level,
                guild = GetGuildInfo("player") or "",
                lastSeen = now,
                online = true,
                note = "",
            },
        },
        messages = {},
    }

    iCC:DebugMsg("Created community: " .. communityKey, 3)
    return communityKey
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Disband Community                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Disband a community. Leader only.
-- Returns true on success, false + error on failure.
function iCC:DisbandCommunity(communityKey)
    if not iCC:HasPermission(communityKey, "disband") then
        return false, "Only the Leader can disband a community."
    end

    iCCCommunities[communityKey] = nil

    -- Clear active community if it was the one disbanded
    if iCC.State.ActiveCommunity == communityKey then
        iCC.State.ActiveCommunity = nil
    end

    iCC:DebugMsg("Disbanded community: " .. communityKey, 3)
    return true
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                                Add Member                                      │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Add a member to a community roster.
-- Called when an invite is accepted (locally or via comm).
function iCC:AddMember(communityKey, memberKey, class, level, guild)
    if not iCCCommunities[communityKey] then
        return false, "Community not found."
    end

    local community = iCCCommunities[communityKey]

    -- Check member limit
    local count = 0
    for _ in pairs(community.members) do
        count = count + 1
    end
    if count >= iCC.CONSTANTS.MAX_COMMUNITY_MEMBERS then
        return false, "Community is full (" .. iCC.CONSTANTS.MAX_COMMUNITY_MEMBERS .. " members max)."
    end

    -- Don't add duplicates
    if community.members[memberKey] then
        return false, "Player is already a member."
    end

    community.members[memberKey] = {
        role = iCC.CONSTANTS.ROLE_MEMBER,
        joinedAt = time(),
        class = class or "UNKNOWN",
        level = level or 0,
        guild = guild or "",
        lastSeen = time(),
        online = true,
        note = "",
    }

    community.rosterVersion = community.rosterVersion + 1
    iCC:DebugMsg("Added member: " .. memberKey .. " to " .. communityKey, 3)
    return true
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                               Remove Member                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Remove a member from a community. Requires "kick" permission.
-- Cannot kick the Leader. Cannot kick yourself (use LeaveCommunity instead).
function iCC:RemoveMember(communityKey, memberKey)
    if not iCCCommunities[communityKey] then
        return false, "Community not found."
    end

    local community = iCCCommunities[communityKey]
    local member = community.members[memberKey]

    if not member then
        return false, "Player is not a member."
    end

    -- Cannot kick the Leader
    if member.role == iCC.CONSTANTS.ROLE_LEADER then
        return false, "Cannot remove the Leader."
    end

    -- Check permission
    if not iCC:HasPermission(communityKey, "kick") then
        return false, "You do not have permission to kick members."
    end

    community.members[memberKey] = nil
    community.rosterVersion = community.rosterVersion + 1
    iCC:DebugMsg("Removed member: " .. memberKey .. " from " .. communityKey, 3)
    return true
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Set Member Role                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Change a member's role. Leader only for promote/demote.
function iCC:SetMemberRole(communityKey, memberKey, newRole)
    if not iCCCommunities[communityKey] then
        return false, "Community not found."
    end

    local community = iCCCommunities[communityKey]
    local member = community.members[memberKey]

    if not member then
        return false, "Player is not a member."
    end

    -- Cannot change your own role
    local playerKey = iCC:GetPlayerKey()
    if memberKey == playerKey then
        return false, "Cannot change your own role."
    end

    -- Determine the action
    local action
    if newRole == iCC.CONSTANTS.ROLE_OFFICER or newRole == iCC.CONSTANTS.ROLE_LEADER then
        action = "promote"
    else
        action = "demote"
    end

    if not iCC:HasPermission(communityKey, action) then
        return false, "You do not have permission to " .. action .. " members."
    end

    -- If promoting to Leader, demote self to Officer
    if newRole == iCC.CONSTANTS.ROLE_LEADER then
        member.role = iCC.CONSTANTS.ROLE_LEADER
        community.members[playerKey].role = iCC.CONSTANTS.ROLE_OFFICER
        community.myRole = iCC.CONSTANTS.ROLE_OFFICER
    else
        member.role = newRole
    end

    community.rosterVersion = community.rosterVersion + 1
    iCC:DebugMsg("Set role of " .. memberKey .. " to " .. newRole .. " in " .. communityKey, 3)
    return true
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Update Member Status                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Update a member's online info (called on heartbeat receive)
function iCC:UpdateMemberStatus(communityKey, memberKey, class, level, guild)
    if not iCCCommunities or not iCCCommunities[communityKey] then return end

    local member = iCCCommunities[communityKey].members[memberKey]
    if not member then return end

    member.lastSeen = time()
    member.online = true
    if class then member.class = class end
    if level then member.level = level end
    if guild then member.guild = guild end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Check Offline Members                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Mark members as offline if they haven't sent a heartbeat within threshold
function iCC:CheckOfflineMembers(communityKey)
    if not iCCCommunities or not iCCCommunities[communityKey] then return end

    local now = time()
    local threshold = iCCSettings and iCCSettings.OfflineThreshold or iCC.CONSTANTS.OFFLINE_THRESHOLD
    local playerKey = iCC:GetPlayerKey()

    for memberKey, member in pairs(iCCCommunities[communityKey].members) do
        if memberKey ~= playerKey and member.online then
            if (now - (member.lastSeen or 0)) > threshold then
                member.online = false
                iCC:DebugMsg(memberKey .. " marked offline in " .. communityKey, 3)
            end
        end
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Sorted Roster                                     │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Role priority for sorting: Leader=1, Officer=2, Member=3
local rolePriority = {
    [iCC.CONSTANTS.ROLE_LEADER]  = 1,
    [iCC.CONSTANTS.ROLE_OFFICER] = 2,
    [iCC.CONSTANTS.ROLE_MEMBER]  = 3,
}

-- Return a sorted array of {key, data} for display
-- Sort order: online first, then by role (Leader > Officer > Member), then alphabetical
function iCC:GetSortedRoster(communityKey)
    if not iCCCommunities or not iCCCommunities[communityKey] then
        return {}
    end

    local roster = {}
    for memberKey, member in pairs(iCCCommunities[communityKey].members) do
        roster[#roster + 1] = { key = memberKey, data = member }
    end

    table.sort(roster, function(a, b)
        -- Online first
        if a.data.online ~= b.data.online then
            return a.data.online
        end
        -- Then by role priority
        local aPri = rolePriority[a.data.role] or 3
        local bPri = rolePriority[b.data.role] or 3
        if aPri ~= bPri then
            return aPri < bPri
        end
        -- Then alphabetical
        return a.key < b.key
    end)

    return roster
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Leave Community                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Leave a community. If Leader and members remain, must transfer leadership first.
function iCC:LeaveCommunity(communityKey)
    if not iCCCommunities or not iCCCommunities[communityKey] then
        return false, "Community not found."
    end

    local community = iCCCommunities[communityKey]
    local playerKey = iCC:GetPlayerKey()

    if community.myRole == iCC.CONSTANTS.ROLE_LEADER then
        -- Count remaining members
        local memberCount = 0
        for _ in pairs(community.members) do
            memberCount = memberCount + 1
        end

        if memberCount > 1 then
            return false, "You must transfer leadership before leaving."
        end
        -- Last member = just disband
    end

    -- Remove from SavedVariable entirely
    iCCCommunities[communityKey] = nil

    if iCC.State.ActiveCommunity == communityKey then
        iCC.State.ActiveCommunity = nil
    end

    iCC:DebugMsg("Left community: " .. communityKey, 3)
    return true
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Get My Communities                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Returns an array of {key, name, online, total} for all communities
function iCC:GetMyCommunities()
    local list = {}
    if not iCCCommunities then return list end

    for communityKey, community in pairs(iCCCommunities) do
        local online, total = iCC:GetOnlineCount(communityKey)
        list[#list + 1] = {
            key = communityKey,
            name = community.name,
            online = online,
            total = total,
        }
    end

    -- Sort alphabetically by name
    table.sort(list, function(a, b)
        return a.name < b.name
    end)

    return list
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Apply Roster Sync                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Merge incoming roster data from a sync response
-- Only applies if incoming rosterVersion is higher than ours
function iCC:ApplyRosterSync(communityKey, syncData)
    if not iCCCommunities or not iCCCommunities[communityKey] then
        return false, "Community not found."
    end

    local community = iCCCommunities[communityKey]

    if not syncData.rosterVersion or syncData.rosterVersion <= community.rosterVersion then
        iCC:DebugMsg("Sync skipped: version " .. (syncData.rosterVersion or "nil") .. " <= " .. community.rosterVersion, 3)
        return false, "Already up to date."
    end

    -- Merge members: add new ones, update existing, remove absent
    if syncData.members then
        local newMembers = {}
        for memberKey, memberData in pairs(syncData.members) do
            local existing = community.members[memberKey]
            newMembers[memberKey] = {
                role = memberData.role or iCC.CONSTANTS.ROLE_MEMBER,
                joinedAt = memberData.joinedAt or (existing and existing.joinedAt) or time(),
                class = memberData.class or (existing and existing.class) or "UNKNOWN",
                level = memberData.level or (existing and existing.level) or 0,
                lastSeen = (existing and existing.lastSeen) or 0,
                online = (existing and existing.online) or false,
                note = memberData.note or (existing and existing.note) or "",
            }
        end
        community.members = newMembers
    end

    -- Update myRole based on our entry in the synced roster
    local playerKey = iCC:GetPlayerKey()
    if community.members[playerKey] then
        community.myRole = community.members[playerKey].role
    end

    -- Apply community settings if present in sync data
    if syncData.icon ~= nil then community.icon = syncData.icon end
    if syncData.description then community.description = syncData.description end
    if syncData.rules then community.rules = syncData.rules end

    community.rosterVersion = syncData.rosterVersion
    iCC:DebugMsg("Applied roster sync for " .. communityKey .. " (v" .. syncData.rosterVersion .. ")", 3)
    return true
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Add Chat Message                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

-- Store a chat message in the community's local history
function iCC:AddChatMessage(communityKey, senderKey, message)
    if not iCCCommunities or not iCCCommunities[communityKey] then return end

    local community = iCCCommunities[communityKey]
    if not community.messages then
        community.messages = {}
    end

    community.messages[#community.messages + 1] = {
        sender = senderKey,
        text = message,
        timestamp = time(),
    }

    -- Trim if over max
    local max = iCCSettings and iCCSettings.MaxMessageHistory or iCC.CONSTANTS.MAX_MESSAGE_HISTORY
    while #community.messages > max do
        table.remove(community.messages, 1)
    end
end
