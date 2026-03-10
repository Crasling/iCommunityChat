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
-- │                                    Frames                                      │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local L = iCC.L

local FRAME_WIDTH = 620
local FRAME_HEIGHT = 420
local ROSTER_ROW_HEIGHT = 20
local CHAT_HEIGHT = 180
local HEADER_HEIGHT = 31
local SIDEBAR_WIDTH = 130

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Create Roster Frame                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local function CreateRosterFrame()
    -- ╭──────────────────────────╮
    -- │       Main Frame         │
    -- ╰──────────────────────────╯

    local frame = iCC:CreateiCCStyleFrame(UIParent, FRAME_WIDTH, FRAME_HEIGHT, {"CENTER", UIParent, "CENTER", 0, 0})
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
    frame:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
    frame:Hide()

    -- ╭──────────────────────────╮
    -- │      Shadow Overlay      │
    -- ╰──────────────────────────╯

    local shadow = CreateFrame("Frame", nil, frame, iCC.BACKDROP_TEMPLATE)
    shadow:SetPoint("TOPLEFT", frame, -1, 1)
    shadow:SetPoint("BOTTOMRIGHT", frame, 1, -1)
    shadow:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 5,
    })
    shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

    -- ╭──────────────────────────╮
    -- │      Drag Handlers       │
    -- ╰──────────────────────────╯

    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); self:SetUserPlaced(true) end)
    frame:RegisterForDrag("LeftButton", "RightButton")

    -- ╭──────────────────────────╮
    -- │       Title Bar          │
    -- ╰──────────────────────────╯

    local titleBar = CreateFrame("Frame", nil, frame, iCC.BACKDROP_TEMPLATE)
    titleBar:SetHeight(HEADER_HEIGHT)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    titleBar:SetBackdropColor(0.07, 0.07, 0.12, 1)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleText:SetText(iCC.Colors.iCC .. "iCommunityChat" .. iCC.Colors.Reset)
    frame.titleText = titleText

    -- ╭──────────────────────────╮
    -- │      Close Button        │
    -- ╰──────────────────────────╯

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- ╭──────────────────────────╮
    -- │     Settings Button      │
    -- ╰──────────────────────────╯

    local settingsBtn = CreateFrame("Button", nil, titleBar)
    settingsBtn:SetSize(24, 24)
    settingsBtn:SetPoint("RIGHT", closeBtn, "LEFT", -2, 0)

    local settingsIcon = settingsBtn:CreateTexture(nil, "ARTWORK")
    settingsIcon:SetSize(16, 16)
    settingsIcon:SetPoint("CENTER")
    settingsIcon:SetTexture("Interface\\Buttons\\UI-OptionsButton")

    local settingsHighlight = settingsBtn:CreateTexture(nil, "HIGHLIGHT")
    settingsHighlight:SetAllPoints(settingsBtn)
    settingsHighlight:SetColorTexture(1, 1, 1, 0.1)

    settingsBtn:SetScript("OnClick", function()
        iCC:ToggleSettingsPanel()
    end)
    settingsBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["CommunitySettings"])
        GameTooltip:Show()
    end)
    settingsBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    frame.settingsBtn = settingsBtn

    -- ╭──────────────────────────╮
    -- │        Sidebar           │
    -- ╰──────────────────────────╯

    local sidebar = CreateFrame("Frame", nil, frame, iCC.BACKDROP_TEMPLATE)
    sidebar:SetWidth(SIDEBAR_WIDTH)
    sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -35)
    sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
    sidebar:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    sidebar:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
    sidebar:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)
    frame.sidebar = sidebar
    frame.sidebarButtons = {}

    -- Online count (positioned dynamically below active community tab)
    local sidebarOnline = sidebar:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sidebarOnline:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 20, -8)
    sidebarOnline:SetText("")
    frame.sidebarOnline = sidebarOnline

    -- "Create Community" button (bottom of sidebar)
    local createBtn = CreateFrame("Button", nil, sidebar)
    createBtn:SetSize(SIDEBAR_WIDTH - 12, 26)
    createBtn:SetPoint("BOTTOMLEFT", sidebar, "BOTTOMLEFT", 6, 8)

    local createBg = createBtn:CreateTexture(nil, "BACKGROUND")
    createBg:SetAllPoints(createBtn)
    createBg:SetColorTexture(0, 0, 0, 0)

    local createBtnText = createBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    createBtnText:SetPoint("LEFT", createBtn, "LEFT", 14, 0)
    createBtnText:SetText("|cFF00FF00+ Create|r")

    local createHighlight = createBtn:CreateTexture(nil, "HIGHLIGHT")
    createHighlight:SetAllPoints(createBtn)
    createHighlight:SetColorTexture(1, 1, 1, 0.08)

    createBtn:SetScript("OnClick", function()
        iCC:ShowCreateCommunityDialog()
    end)
    createBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["CreateCommunityTooltip"])
        GameTooltip:Show()
    end)
    createBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    frame.createBtn = createBtn

    -- Invite button (above Create)
    local inviteBtn = CreateFrame("Button", nil, sidebar)
    inviteBtn:SetSize(SIDEBAR_WIDTH - 12, 22)
    inviteBtn:SetPoint("BOTTOMLEFT", createBtn, "TOPLEFT", 0, 16)

    local inviteBg = inviteBtn:CreateTexture(nil, "BACKGROUND")
    inviteBg:SetAllPoints(inviteBtn)
    inviteBg:SetColorTexture(0, 0, 0, 0)

    local inviteBtnText = inviteBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    inviteBtnText:SetPoint("LEFT", inviteBtn, "LEFT", 14, 0)
    inviteBtnText:SetText("Invite")

    local inviteHighlight = inviteBtn:CreateTexture(nil, "HIGHLIGHT")
    inviteHighlight:SetAllPoints(inviteBtn)
    inviteHighlight:SetColorTexture(1, 1, 1, 0.08)

    inviteBtn:SetScript("OnClick", function()
        iCC:ShowInviteDialog()
    end)
    frame.inviteBtn = inviteBtn

    -- Leave button (above Invite)
    local leaveBtn = CreateFrame("Button", nil, sidebar)
    leaveBtn:SetSize(SIDEBAR_WIDTH - 12, 22)
    leaveBtn:SetPoint("BOTTOMLEFT", inviteBtn, "TOPLEFT", 0, 2)

    local leaveBg = leaveBtn:CreateTexture(nil, "BACKGROUND")
    leaveBg:SetAllPoints(leaveBtn)
    leaveBg:SetColorTexture(0, 0, 0, 0)

    local leaveBtnText = leaveBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    leaveBtnText:SetPoint("LEFT", leaveBtn, "LEFT", 14, 0)
    leaveBtnText:SetText("|cFFFF4444Leave|r")

    local leaveHighlight = leaveBtn:CreateTexture(nil, "HIGHLIGHT")
    leaveHighlight:SetAllPoints(leaveBtn)
    leaveHighlight:SetColorTexture(1, 1, 1, 0.08)

    leaveBtn:SetScript("OnClick", function()
        local activeCommunity = iCC.State.ActiveCommunity
        if not activeCommunity then return end
        SlashCmdList["ICC"]("leave")
    end)
    frame.leaveBtn = leaveBtn

    -- ╭──────────────────────────╮
    -- │      Content Area        │
    -- ╰──────────────────────────╯

    local contentArea = CreateFrame("Frame", nil, frame, iCC.BACKDROP_TEMPLATE)
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 6, 0)
    contentArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    contentArea:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    contentArea:SetBackdropBorderColor(0.6, 0.6, 0.7, 1)
    contentArea:SetBackdropColor(0.08, 0.08, 0.1, 0.95)

    -- ╭──────────────────────────╮
    -- │     Empty State Panel    │
    -- ╰──────────────────────────╯

    local emptyPanel = CreateFrame("Frame", nil, contentArea)
    emptyPanel:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 4, -4)
    emptyPanel:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -4, 4)
    emptyPanel:Hide()

    local emptyText = emptyPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    emptyText:SetPoint("CENTER", emptyPanel, "CENTER", 0, 30)
    emptyText:SetText(iCC.Colors.Gray .. L["NoCommunities"] .. iCC.Colors.Reset)

    local emptyCreateBtn = CreateFrame("Button", nil, emptyPanel, "UIPanelButtonTemplate")
    emptyCreateBtn:SetSize(180, 28)
    emptyCreateBtn:SetPoint("CENTER", emptyPanel, "CENTER", 0, -10)
    emptyCreateBtn:SetText(L["CreateButton"])
    emptyCreateBtn:SetScript("OnClick", function()
        iCC:ShowCreateCommunityDialog()
    end)

    local emptyHint = emptyPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    emptyHint:SetPoint("TOP", emptyCreateBtn, "BOTTOM", 0, -8)
    emptyHint:SetText(L["CreateCommunityHint"])

    frame.emptyPanel = emptyPanel

    -- ╭──────────────────────────╮
    -- │     Column Headers       │
    -- ╰──────────────────────────╯

    local headerFrame = CreateFrame("Frame", nil, contentArea)
    headerFrame:SetHeight(20)
    headerFrame:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 4, -4)
    headerFrame:SetPoint("TOPRIGHT", contentArea, "TOPRIGHT", -4, -4)
    frame.headerFrame = headerFrame

    local statusHeader = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusHeader:SetPoint("LEFT", headerFrame, "LEFT", 8, 0)
    statusHeader:SetText("")
    statusHeader:SetWidth(16)

    local nameHeader = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameHeader:SetPoint("LEFT", statusHeader, "RIGHT", 4, 0)
    nameHeader:SetText("Name")
    nameHeader:SetTextColor(1, 0.82, 0, 1)

    local rankHeader = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rankHeader:SetPoint("RIGHT", headerFrame, "RIGHT", -60, 0)
    rankHeader:SetWidth(60)
    rankHeader:SetJustifyH("CENTER")
    rankHeader:SetText("Rank")
    rankHeader:SetTextColor(1, 0.82, 0, 1)

    local levelHeader = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelHeader:SetPoint("RIGHT", headerFrame, "RIGHT", -8, 0)
    levelHeader:SetWidth(30)
    levelHeader:SetJustifyH("CENTER")
    levelHeader:SetText("Lvl")
    levelHeader:SetTextColor(1, 0.82, 0, 1)

    -- ╭──────────────────────────╮
    -- │     Roster ScrollFrame   │
    -- ╰──────────────────────────╯

    local rosterContainer = CreateFrame("Frame", nil, contentArea)
    rosterContainer:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -2)
    rosterContainer:SetPoint("TOPRIGHT", headerFrame, "BOTTOMRIGHT", 0, -2)
    rosterContainer:SetPoint("BOTTOM", contentArea, "BOTTOM", 0, CHAT_HEIGHT + 6)
    frame.rosterContainer = rosterContainer

    local scrollFrame = CreateFrame("ScrollFrame", "iCCRosterScroll", rosterContainer, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", rosterContainer, "TOPLEFT", 4, -2)
    scrollFrame:SetPoint("BOTTOMRIGHT", rosterContainer, "BOTTOMRIGHT", -24, 2)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(scrollFrame:GetWidth() or (FRAME_WIDTH - SIDEBAR_WIDTH - 68))
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)
    frame.scrollChild = scrollChild
    frame.rosterRows = {}

    -- ╭──────────────────────────╮
    -- │     Chat Panel           │
    -- ╰──────────────────────────╯

    local chatBg = CreateFrame("Frame", nil, contentArea, iCC.BACKDROP_TEMPLATE)
    chatBg:SetHeight(CHAT_HEIGHT)
    chatBg:SetPoint("BOTTOMLEFT", contentArea, "BOTTOMLEFT", 4, 30)
    chatBg:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -4, 30)
    chatBg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    chatBg:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
    chatBg:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)
    frame.chatBg = chatBg

    local chatScroll = CreateFrame("ScrollFrame", "iCCChatScroll", chatBg, "UIPanelScrollFrameTemplate")
    chatScroll:SetPoint("TOPLEFT", chatBg, "TOPLEFT", 6, -6)
    chatScroll:SetPoint("BOTTOMRIGHT", chatBg, "BOTTOMRIGHT", -24, 6)

    local chatMessages = CreateFrame("Frame", nil, chatScroll)
    chatMessages:SetWidth(chatScroll:GetWidth() or (FRAME_WIDTH - SIDEBAR_WIDTH - 68))
    chatMessages:SetHeight(1)
    chatScroll:SetScrollChild(chatMessages)

    local chatText = chatMessages:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    chatText:SetPoint("TOPLEFT", chatMessages, "TOPLEFT", 0, 0)
    chatText:SetPoint("TOPRIGHT", chatMessages, "TOPRIGHT", 0, 0)
    chatText:SetJustifyH("LEFT")
    chatText:SetJustifyV("TOP")
    chatText:SetWordWrap(true)
    chatText:SetSpacing(2)
    frame.chatText = chatText
    frame.chatScroll = chatScroll
    frame.chatMessages = chatMessages

    -- ╭──────────────────────────╮
    -- │     Chat Input Box       │
    -- ╰──────────────────────────╯

    local chatInput = CreateFrame("EditBox", "iCCChatInput", contentArea, "InputBoxTemplate")
    chatInput:SetHeight(22)
    chatInput:SetPoint("BOTTOMLEFT", contentArea, "BOTTOMLEFT", 10, 6)
    chatInput:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -46, 6)
    chatInput:SetAutoFocus(false)
    chatInput:SetMaxLetters(iCC.CONSTANTS.MAX_CHAT_MESSAGE_LENGTH)

    chatInput:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        if text and text ~= "" then
            local activeCommunity = iCC.State.ActiveCommunity
            if activeCommunity then
                iCC:SendChatMessage(activeCommunity, text)
            else
                iCC:Msg("No community selected.")
            end
            self:SetText("")
        end
        self:ClearFocus()
    end)

    chatInput:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)

    local sendBtn = CreateFrame("Button", nil, contentArea, "UIPanelButtonTemplate")
    sendBtn:SetSize(36, 22)
    sendBtn:SetPoint("LEFT", chatInput, "RIGHT", 4, 0)
    sendBtn:SetText("Send")
    sendBtn:SetScript("OnClick", function()
        local text = chatInput:GetText()
        if text and text ~= "" then
            local activeCommunity = iCC.State.ActiveCommunity
            if activeCommunity then
                iCC:SendChatMessage(activeCommunity, text)
            end
            chatInput:SetText("")
            chatInput:ClearFocus()
        end
    end)
    frame.chatInput = chatInput
    frame.sendBtn = sendBtn

    -- ╭──────────────────────────╮
    -- │     Settings Panel       │
    -- ╰──────────────────────────╯

    local settingsPanel = CreateFrame("Frame", nil, contentArea)
    settingsPanel:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 4, -4)
    settingsPanel:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -4, 4)
    settingsPanel:Hide()
    frame.settingsPanel = settingsPanel

    local settingsScroll = CreateFrame("ScrollFrame", "iCCSettingsScroll", settingsPanel, "UIPanelScrollFrameTemplate")
    settingsScroll:SetPoint("TOPLEFT", settingsPanel, "TOPLEFT", 0, 0)
    settingsScroll:SetPoint("BOTTOMRIGHT", settingsPanel, "BOTTOMRIGHT", -22, 0)

    local settingsContent = CreateFrame("Frame", nil, settingsScroll)
    settingsContent:SetWidth(settingsScroll:GetWidth() or 380)
    settingsContent:SetHeight(500)
    settingsScroll:SetScrollChild(settingsContent)
    frame.settingsContent = settingsContent

    -- ╭──────────────────────────╮
    -- │      Icon Picker         │
    -- ╰──────────────────────────╯

    local iconPicker = CreateFrame("Frame", "iCCIconPicker", UIParent, iCC.BACKDROP_TEMPLATE)
    iconPicker:SetSize(310, 220)
    iconPicker:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    iconPicker:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    iconPicker:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
    iconPicker:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
    iconPicker:SetFrameStrata("DIALOG")
    iconPicker:EnableMouse(true)
    iconPicker:Hide()
    frame.iconPicker = iconPicker

    local iconPickerTitle = iconPicker:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    iconPickerTitle:SetPoint("TOP", iconPicker, "TOP", 0, -10)
    iconPickerTitle:SetText(L["IconPicker"])

    local iconPickerClose = CreateFrame("Button", nil, iconPicker, "UIPanelCloseButton")
    iconPickerClose:SetPoint("TOPRIGHT", iconPicker, "TOPRIGHT", 0, 0)
    iconPickerClose:SetScript("OnClick", function() iconPicker:Hide() end)

    local ICON_SIZE = 32
    local ICON_PADDING = 4
    local ICONS_PER_ROW = 8
    local iconStartY = -30

    iconPicker.iconButtons = {}
    for i, iconPath in ipairs(iCC.COMMUNITY_ICONS) do
        local row = math.floor((i - 1) / ICONS_PER_ROW)
        local col = (i - 1) % ICONS_PER_ROW
        local x = 12 + col * (ICON_SIZE + ICON_PADDING)
        local y = iconStartY - row * (ICON_SIZE + ICON_PADDING)

        local btn = CreateFrame("Button", nil, iconPicker)
        btn:SetSize(ICON_SIZE, ICON_SIZE)
        btn:SetPoint("TOPLEFT", iconPicker, "TOPLEFT", x, y)

        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints(btn)
        tex:SetTexture(iconPath)

        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(btn)
        highlight:SetColorTexture(1, 0.59, 0.09, 0.4)

        btn:SetScript("OnClick", function()
            iCC._selectedIcon = iconPath
            if frame.settingsIconPreview then
                frame.settingsIconPreview:SetTexture(iconPath)
                frame.settingsIconPreview:Show()
            end
            iconPicker:Hide()
        end)

        iconPicker.iconButtons[i] = btn
    end

    -- Size the icon picker to fit
    local totalRows = math.ceil(#iCC.COMMUNITY_ICONS / ICONS_PER_ROW)
    iconPicker:SetHeight(40 + totalRows * (ICON_SIZE + ICON_PADDING))

    return frame
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Create Roster Row                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local function CreateRosterRow(parent, index)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(ROSTER_ROW_HEIGHT)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * ROSTER_ROW_HEIGHT)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, -(index - 1) * ROSTER_ROW_HEIGHT)

    -- Highlight on hover
    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(row)
    highlight:SetColorTexture(1, 1, 1, 0.1)

    -- Status dot (circle indicator)
    local statusDot = row:CreateTexture(nil, "OVERLAY")
    statusDot:SetSize(8, 8)
    statusDot:SetPoint("LEFT", row, "LEFT", 10, 0)
    statusDot:SetTexture("Interface\\COMMON\\Indicator-Green")
    row.statusDot = statusDot

    -- Name
    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("LEFT", statusDot, "RIGHT", 6, 0)
    nameText:SetWidth(160)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    -- Rank
    local rankText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rankText:SetPoint("RIGHT", row, "RIGHT", -60, 0)
    rankText:SetWidth(60)
    rankText:SetJustifyH("CENTER")
    row.rankText = rankText

    -- Level
    local levelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    levelText:SetWidth(30)
    levelText:SetJustifyH("CENTER")
    row.levelText = levelText

    -- Right-click context menu
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    row:SetScript("OnClick", function(self, button)
        if button == "RightButton" and self.memberKey then
            iCC:ShowMemberContextMenu(self, self.memberKey, self.communityKey)
        end
    end)

    return row
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Update Roster Display                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:UpdateRosterDisplay()
    if not iCC.RosterFrame or not iCC.RosterFrame:IsShown() then return end

    local communityKey = iCC.State.ActiveCommunity
    local communities = iCC:GetMyCommunities()
    local hasCommunities = (#communities > 0)

    if not communityKey or not iCCCommunities[communityKey] then
        -- No active community — show empty state
        iCC.RosterFrame.titleText:SetText(iCC.Colors.iCC .. "iCommunityChat" .. iCC.Colors.Reset)
        iCC.RosterFrame.emptyPanel:SetShown(not hasCommunities)
        -- Hide all rows
        for _, row in ipairs(iCC.RosterFrame.rosterRows) do
            row:Hide()
        end
        return
    end

    -- Has active community — hide empty panel
    iCC.RosterFrame.emptyPanel:Hide()

    local community = iCCCommunities[communityKey]

    -- Update title (always show addon name, community is visible in sidebar)
    iCC.RosterFrame.titleText:SetText(iCC.Colors.iCC .. "iCommunityChat" .. iCC.Colors.Reset)

    -- Get sorted roster
    local roster = iCC:GetSortedRoster(communityKey)

    -- Create or reuse rows
    local scrollChild = iCC.RosterFrame.scrollChild
    for i, entry in ipairs(roster) do
        local row = iCC.RosterFrame.rosterRows[i]
        if not row then
            row = CreateRosterRow(scrollChild, i)
            iCC.RosterFrame.rosterRows[i] = row
        end

        local memberKey = entry.key
        local member = entry.data
        local name = strsplit("-", memberKey)

        -- Status dot
        if member.online then
            row.statusDot:SetTexture("Interface\\COMMON\\Indicator-Green")
        else
            row.statusDot:SetTexture("Interface\\COMMON\\Indicator-Gray")
        end

        -- Class-colored name
        row.nameText:SetText(iCC:ColorizePlayerNameByClass(name, member.class))

        -- Rank (colored by role)
        row.rankText:SetText(iCC:GetRoleColor(member.role) .. member.role .. iCC.Colors.Reset)

        -- Level
        row.levelText:SetText(tostring(member.level or "?"))

        -- Store references for context menu
        row.memberKey = memberKey
        row.communityKey = communityKey

        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(i - 1) * ROSTER_ROW_HEIGHT)
        row:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -(i - 1) * ROSTER_ROW_HEIGHT)
        row:Show()
    end

    -- Hide extra rows
    for i = #roster + 1, #iCC.RosterFrame.rosterRows do
        iCC.RosterFrame.rosterRows[i]:Hide()
    end

    -- Update scroll child height
    scrollChild:SetHeight(#roster * ROSTER_ROW_HEIGHT)

    -- Update invite button visibility
    if iCC:HasPermission(communityKey, "invite") then
        iCC.RosterFrame.inviteBtn:Enable()
    else
        iCC.RosterFrame.inviteBtn:Disable()
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Update Chat Display                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:UpdateChatDisplay()
    if not iCC.RosterFrame or not iCC.RosterFrame:IsShown() then return end

    local communityKey = iCC.State.ActiveCommunity
    if not communityKey or not iCCCommunities[communityKey] then
        iCC.RosterFrame.chatText:SetText("")
        return
    end

    local community = iCCCommunities[communityKey]
    local messages = community.messages or {}
    local showTimestamps = iCCSettings and iCCSettings.ShowTimestamps

    local lines = {}
    local lastDateKey = nil
    local todayKey = date("%Y-%m-%d", time())
    local yesterdayKey = date("%Y-%m-%d", time() - 86400)

    for _, msg in ipairs(messages) do
        -- Insert date separator when the day changes
        if msg.timestamp then
            local msgDateKey = date("%Y-%m-%d", msg.timestamp)
            if msgDateKey ~= lastDateKey then
                local dateLabel
                if msgDateKey == todayKey then
                    dateLabel = L["DateToday"]
                elseif msgDateKey == yesterdayKey then
                    dateLabel = L["DateYesterday"]
                else
                    dateLabel = date("%B %d", msg.timestamp)
                end
                lines[#lines + 1] = iCC.Colors.Gray .. "--- " .. dateLabel .. " ---|r"
                lastDateKey = msgDateKey
            end
        end

        local senderName = strsplit("-", msg.sender)
        local senderClass = "UNKNOWN"
        if community.members[msg.sender] then
            senderClass = community.members[msg.sender].class or "UNKNOWN"
        end

        local line = ""
        if showTimestamps and msg.timestamp then
            line = iCC.Colors.Gray .. "[" .. iCC:FormatTimestamp(msg.timestamp) .. "] " .. iCC.Colors.Reset
        end
        line = line .. iCC:ColorizePlayerNameByClass(senderName, senderClass) .. ": " .. msg.text

        lines[#lines + 1] = line
    end

    iCC.RosterFrame.chatText:SetText(table.concat(lines, "\n"))

    -- Update chat scroll child height to fit text
    local textHeight = iCC.RosterFrame.chatText:GetStringHeight() or 0
    iCC.RosterFrame.chatMessages:SetWidth(iCC.RosterFrame.chatScroll:GetWidth() or (FRAME_WIDTH - SIDEBAR_WIDTH - 68))
    iCC.RosterFrame.chatMessages:SetHeight(textHeight + 10)

    -- Scroll to bottom
    C_Timer.After(0.05, function()
        if iCC.RosterFrame and iCC.RosterFrame.chatScroll then
            local maxScroll = iCC.RosterFrame.chatScroll:GetVerticalScrollRange()
            iCC.RosterFrame.chatScroll:SetVerticalScroll(maxScroll or 0)
        end
    end)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                         Settings Panel                                         │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:ToggleSettingsPanel()
    if not iCC.RosterFrame then return end
    local frame = iCC.RosterFrame
    local showing = not frame.settingsPanel:IsShown()

    -- Toggle content visibility
    frame.headerFrame:SetShown(not showing)
    frame.rosterContainer:SetShown(not showing)
    frame.chatBg:SetShown(not showing)
    frame.chatInput:SetShown(not showing)
    frame.sendBtn:SetShown(not showing)
    frame.settingsPanel:SetShown(showing)

    if showing then
        iCC:PopulateSettingsPanel()
    else
        -- Hide icon picker if open
        if frame.iconPicker then
            frame.iconPicker:Hide()
        end
    end
end

function iCC:PopulateSettingsPanel()
    if not iCC.RosterFrame then return end
    local frame = iCC.RosterFrame
    local parent = frame.settingsContent

    -- Clear old children
    if frame._settingsChildren then
        for _, child in ipairs(frame._settingsChildren) do
            child:Hide()
            child:SetParent(nil)
        end
    end
    frame._settingsChildren = {}

    local communityKey = iCC.State.ActiveCommunity
    if not communityKey or not iCCCommunities[communityKey] then return end

    local community = iCCCommunities[communityKey]
    local isLeader = iCC:HasPermission(communityKey, "promote")

    -- Track temp state for editing
    iCC._selectedIcon = community.icon

    local y = -8
    local children = frame._settingsChildren

    -- ╭──────────────────╮
    -- │   Icon Section   │
    -- ╰──────────────────╯

    local iconHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    iconHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    iconHeader:SetText(L["CommunityIcon"])
    children[#children + 1] = iconHeader
    y = y - 20

    local iconPreview = parent:CreateTexture(nil, "ARTWORK")
    iconPreview:SetSize(48, 48)
    iconPreview:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
    if community.icon then
        iconPreview:SetTexture(community.icon)
        iconPreview:Show()
    else
        iconPreview:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        iconPreview:Show()
    end
    frame.settingsIconPreview = iconPreview
    children[#children + 1] = iconPreview

    if isLeader then
        local chooseBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        chooseBtn:SetSize(100, 22)
        chooseBtn:SetPoint("LEFT", iconPreview, "RIGHT", 10, 8)
        chooseBtn:SetText(L["ChooseIcon"])
        chooseBtn:SetScript("OnClick", function()
            frame.iconPicker:Show()
        end)
        children[#children + 1] = chooseBtn

        local removeBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        removeBtn:SetSize(100, 22)
        removeBtn:SetPoint("LEFT", iconPreview, "RIGHT", 10, -16)
        removeBtn:SetText(L["RemoveIcon"])
        removeBtn:SetScript("OnClick", function()
            iCC._selectedIcon = nil
            iconPreview:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            frame.iconPicker:Hide()
        end)
        children[#children + 1] = removeBtn
    end

    y = y - 56

    -- ╭──────────────────────╮
    -- │  Description Section │
    -- ╰──────────────────────╯

    local descHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    descHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    descHeader:SetText(L["CommunityDescription"])
    children[#children + 1] = descHeader
    y = y - 18

    if isLeader then
        local descBg = CreateFrame("Frame", nil, parent, iCC.BACKDROP_TEMPLATE)
        descBg:SetSize(380, 70)
        descBg:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
        descBg:SetBackdrop({
            bgFile = "Interface\\BUTTONS\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = {left = 3, right = 3, top = 3, bottom = 3},
        })
        descBg:SetBackdropColor(0.05, 0.05, 0.08, 1)
        descBg:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)
        children[#children + 1] = descBg

        local descScroll = CreateFrame("ScrollFrame", "iCCDescScroll", descBg, "UIPanelScrollFrameTemplate")
        descScroll:SetPoint("TOPLEFT", descBg, "TOPLEFT", 6, -6)
        descScroll:SetPoint("BOTTOMRIGHT", descBg, "BOTTOMRIGHT", -22, 6)
        children[#children + 1] = descScroll

        local descEdit = CreateFrame("EditBox", "iCCDescEdit", descScroll)
        descEdit:SetWidth(descScroll:GetWidth() or 340)
        descEdit:SetFontObject(GameFontHighlightSmall)
        descEdit:SetMultiLine(true)
        descEdit:SetAutoFocus(false)
        descEdit:SetMaxLetters(iCC.CONSTANTS.MAX_COMMUNITY_DESCRIPTION)
        descEdit:SetText(community.description or "")
        descEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        descScroll:SetScrollChild(descEdit)
        frame._descEdit = descEdit
        children[#children + 1] = descEdit

        y = y - 76
    else
        local descText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        descText:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
        descText:SetWidth(380)
        descText:SetJustifyH("LEFT")
        local desc = community.description or ""
        if desc == "" then
            descText:SetText(iCC.Colors.Gray .. L["NoDescription"] .. "|r")
        else
            descText:SetText(desc)
        end
        children[#children + 1] = descText
        local h = descText:GetStringHeight() or 14
        if h < 14 then h = 14 end
        y = y - h - 8
    end

    -- ╭──────────────────╮
    -- │  Rules Section   │
    -- ╰──────────────────╯

    local rulesHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rulesHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    rulesHeader:SetText(L["CommunityRules"])
    children[#children + 1] = rulesHeader
    y = y - 18

    if isLeader then
        local rulesBg = CreateFrame("Frame", nil, parent, iCC.BACKDROP_TEMPLATE)
        rulesBg:SetSize(380, 90)
        rulesBg:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
        rulesBg:SetBackdrop({
            bgFile = "Interface\\BUTTONS\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = {left = 3, right = 3, top = 3, bottom = 3},
        })
        rulesBg:SetBackdropColor(0.05, 0.05, 0.08, 1)
        rulesBg:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)
        children[#children + 1] = rulesBg

        local rulesScroll = CreateFrame("ScrollFrame", "iCCRulesScroll", rulesBg, "UIPanelScrollFrameTemplate")
        rulesScroll:SetPoint("TOPLEFT", rulesBg, "TOPLEFT", 6, -6)
        rulesScroll:SetPoint("BOTTOMRIGHT", rulesBg, "BOTTOMRIGHT", -22, 6)
        children[#children + 1] = rulesScroll

        local rulesEdit = CreateFrame("EditBox", "iCCRulesEdit", rulesScroll)
        rulesEdit:SetWidth(rulesScroll:GetWidth() or 340)
        rulesEdit:SetFontObject(GameFontHighlightSmall)
        rulesEdit:SetMultiLine(true)
        rulesEdit:SetAutoFocus(false)
        rulesEdit:SetMaxLetters(iCC.CONSTANTS.MAX_COMMUNITY_RULES)
        rulesEdit:SetText(community.rules or "")
        rulesEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        rulesScroll:SetScrollChild(rulesEdit)
        frame._rulesEdit = rulesEdit
        children[#children + 1] = rulesEdit

        y = y - 96

        -- Save Button
        local saveBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        saveBtn:SetSize(120, 26)
        saveBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
        saveBtn:SetText(L["SaveSettings"])
        saveBtn:SetScript("OnClick", function()
            community.icon = iCC._selectedIcon
            community.description = frame._descEdit:GetText() or ""
            community.rules = frame._rulesEdit:GetText() or ""

            iCC:BroadcastSettingsChange(communityKey)
            iCC:Msg(L["SettingsSaved"])
            iCC:ToggleSettingsPanel()
        end)
        children[#children + 1] = saveBtn

        y = y - 34
    else
        local rulesText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        rulesText:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
        rulesText:SetWidth(380)
        rulesText:SetJustifyH("LEFT")
        local rules = community.rules or ""
        if rules == "" then
            rulesText:SetText(iCC.Colors.Gray .. L["NoRules"] .. "|r")
        else
            rulesText:SetText(rules)
        end
        children[#children + 1] = rulesText
        local h = rulesText:GetStringHeight() or 14
        if h < 14 then h = 14 end
        y = y - h - 8
    end

    parent:SetHeight(math.abs(y) + 20)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                         Update Community Tabs                                  │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:UpdateCommunityTabs()
    if not iCC.RosterFrame then return end

    local sidebar = iCC.RosterFrame.sidebar

    -- Clear old sidebar buttons
    for _, btn in ipairs(iCC.RosterFrame.sidebarButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    iCC.RosterFrame.sidebarButtons = {}

    local communities = iCC:GetMyCommunities()

    if #communities == 0 then
        iCC.RosterFrame.sidebarOnline:SetText("")
        return
    end

    -- Auto-select first if none active
    if not iCC.State.ActiveCommunity then
        iCC.State.ActiveCommunity = communities[1].key
    end

    local yOffset = -8

    for i, communityInfo in ipairs(communities) do
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetSize(SIDEBAR_WIDTH - 12, 26)
        btn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 6, yOffset)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(btn)
        btn.bg = bg

        local label = communityInfo.name
        if #label > 14 then label = label:sub(1, 13) .. ".." end

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", btn, "LEFT", 14, 0)
        text:SetText(label)
        btn.text = text

        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(btn)
        highlight:SetColorTexture(1, 1, 1, 0.08)

        -- Active/inactive styling
        local isActive = (iCC.State.ActiveCommunity == communityInfo.key)
        if isActive then
            bg:SetColorTexture(1, 0.59, 0.09, 0.25)
            text:SetFontObject(GameFontHighlight)
        else
            bg:SetColorTexture(0, 0, 0, 0)
            text:SetFontObject(GameFontNormal)
        end

        btn:SetScript("OnClick", function()
            iCC.State.ActiveCommunity = communityInfo.key
            -- Close settings panel if open when switching community
            if iCC.RosterFrame.settingsPanel:IsShown() then
                iCC:ToggleSettingsPanel()
            end
            iCC:UpdateCommunityTabs()
            iCC:UpdateRosterDisplay()
            iCC:UpdateChatDisplay()
        end)

        iCC.RosterFrame.sidebarButtons[i] = btn
        yOffset = yOffset - 26

        -- Reserve extra space below active tab for online count text
        if isActive then
            yOffset = yOffset - 16
        end
    end

    -- Update online count below active community tab
    local activeKey = iCC.State.ActiveCommunity
    if activeKey and iCCCommunities[activeKey] then
        local online, total = iCC:GetOnlineCount(activeKey)
        iCC.RosterFrame.sidebarOnline:SetText("|cFF808080" .. online .. "/" .. total .. " online|r")

        -- Position below the active tab
        for i, communityInfo in ipairs(communities) do
            if communityInfo.key == activeKey then
                iCC.RosterFrame.sidebarOnline:ClearAllPoints()
                iCC.RosterFrame.sidebarOnline:SetPoint(
                    "TOPLEFT", iCC.RosterFrame.sidebarButtons[i],
                    "BOTTOMLEFT", 14, -2
                )
                break
            end
        end
    else
        iCC.RosterFrame.sidebarOnline:SetText("")
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Toggle Roster Frame                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:ToggleRosterFrame()
    if not iCC.RosterFrame then
        iCC.RosterFrame = CreateRosterFrame()

        -- Register for updates
        iCC:RegisterMessage("ICC_ROSTER_UPDATED", function(_, communityKey)
            iCC:UpdateCommunityTabs()
            iCC:UpdateRosterDisplay()
        end)

        iCC:RegisterMessage("ICC_CHAT_MESSAGE_RECEIVED", function(_, communityKey)
            iCC:UpdateChatDisplay()
        end)
    end

    if iCC.RosterFrame:IsShown() then
        iCC.RosterFrame:Hide()
    else
        -- Set active community if none set
        if not iCC.State.ActiveCommunity then
            local communities = iCC:GetMyCommunities()
            if #communities > 0 then
                iCC.State.ActiveCommunity = communities[1].key
            end
        end

        iCC.RosterFrame:Show()
        iCC:UpdateCommunityTabs()
        iCC:UpdateRosterDisplay()
        iCC:UpdateChatDisplay()
    end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Member Context Menu                                   │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:ShowMemberContextMenu(anchorFrame, memberKey, communityKey)
    if not memberKey or not communityKey then return end
    if not iCCCommunities[communityKey] then return end

    local member = iCCCommunities[communityKey].members[memberKey]
    if not member then return end

    local playerKey = iCC:GetPlayerKey()
    local isMe = (memberKey == playerKey)
    local memberName = strsplit("-", memberKey)

    -- Build menu
    local menu = {}

    -- Header
    menu[#menu + 1] = {
        text = iCC:ColorizePlayerNameByClass(memberName, member.class),
        isTitle = true,
        notCheckable = true,
    }

    -- Whisper (not for self)
    if not isMe then
        menu[#menu + 1] = {
            text = "Whisper",
            notCheckable = true,
            func = function()
                ChatFrame_OpenChat("/w " .. memberName .. " ")
            end,
        }
    end

    -- Who
    menu[#menu + 1] = {
        text = "Who",
        notCheckable = true,
        func = function()
            SendWho('n-"' .. memberName .. '"')
        end,
    }

    -- Invite to group (not for self)
    if not isMe then
        menu[#menu + 1] = {
            text = "Invite",
            notCheckable = true,
            func = function()
                InviteUnit(memberName)
            end,
        }
    end

    -- Create iWR note
    if iWR then
        menu[#menu + 1] = {
            text = "Create Note (iWR)",
            notCheckable = true,
            func = function()
                SlashCmdList["IWR"](memberName)
            end,
        }
    end

    -- Promote to Officer (Leader only, not self, not already Officer/Leader)
    if iCC:HasPermission(communityKey, "promote") and not isMe and member.role == iCC.CONSTANTS.ROLE_MEMBER then
        menu[#menu + 1] = {
            text = "Promote to Officer",
            notCheckable = true,
            func = function()
                local ok, err = iCC:SetMemberRole(communityKey, memberKey, iCC.CONSTANTS.ROLE_OFFICER)
                if ok then
                    iCC:BroadcastRosterChange(communityKey, "role", memberKey, { role = iCC.CONSTANTS.ROLE_OFFICER })
                    iCC:UpdateRosterDisplay()
                else
                    iCC:Msg(iCC.Colors.Red .. (err or "Failed.") .. iCC.Colors.Reset)
                end
            end,
        }
    end

    -- Promote to Leader (Leader only, not self)
    if iCC:HasPermission(communityKey, "promote") and not isMe and member.role == iCC.CONSTANTS.ROLE_OFFICER then
        menu[#menu + 1] = {
            text = "Promote to Leader",
            notCheckable = true,
            func = function()
                local ok, err = iCC:SetMemberRole(communityKey, memberKey, iCC.CONSTANTS.ROLE_LEADER)
                if ok then
                    iCC:BroadcastRosterChange(communityKey, "role", memberKey, { role = iCC.CONSTANTS.ROLE_LEADER })
                    iCC:BroadcastRosterChange(communityKey, "role", playerKey, { role = iCC.CONSTANTS.ROLE_OFFICER })
                    iCC:UpdateRosterDisplay()
                else
                    iCC:Msg(iCC.Colors.Red .. (err or "Failed.") .. iCC.Colors.Reset)
                end
            end,
        }
    end

    -- Demote (Leader only, Officers can be demoted)
    if iCC:HasPermission(communityKey, "demote") and not isMe and member.role == iCC.CONSTANTS.ROLE_OFFICER then
        menu[#menu + 1] = {
            text = "Demote to Member",
            notCheckable = true,
            func = function()
                local ok, err = iCC:SetMemberRole(communityKey, memberKey, iCC.CONSTANTS.ROLE_MEMBER)
                if ok then
                    iCC:BroadcastRosterChange(communityKey, "role", memberKey, { role = iCC.CONSTANTS.ROLE_MEMBER })
                    iCC:UpdateRosterDisplay()
                else
                    iCC:Msg(iCC.Colors.Red .. (err or "Failed.") .. iCC.Colors.Reset)
                end
            end,
        }
    end

    -- Kick (Leader/Officer, not self, not Leader)
    if iCC:HasPermission(communityKey, "kick") and not isMe and member.role ~= iCC.CONSTANTS.ROLE_LEADER then
        menu[#menu + 1] = {
            text = "|cFFFF0000Kick|r",
            notCheckable = true,
            func = function()
                local ok, err = iCC:RemoveMember(communityKey, memberKey)
                if ok then
                    iCC:BroadcastRosterChange(communityKey, "remove", memberKey)
                    iCC:Msg(memberName .. " has been removed from the community.")
                    iCC:UpdateRosterDisplay()
                else
                    iCC:Msg(iCC.Colors.Red .. (err or "Failed.") .. iCC.Colors.Reset)
                end
            end,
        }
    end

    -- Cancel
    menu[#menu + 1] = {
        text = "Cancel",
        notCheckable = true,
    }

    -- Show dropdown
    if not iCC.ContextMenu then
        iCC.ContextMenu = CreateFrame("Frame", "iCCContextMenu", UIParent, "UIDropDownMenuTemplate")
    end

    UIDropDownMenu_Initialize(iCC.ContextMenu, function(self, level)
        for _, item in ipairs(menu) do
            UIDropDownMenu_AddButton(item, level)
        end
    end, "MENU")
    ToggleDropDownMenu(1, nil, iCC.ContextMenu, "cursor", 0, 0)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                           Invite Player Dialog                                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:ShowInviteDialog()
    local activeCommunity = iCC.State.ActiveCommunity
    if not activeCommunity then
        iCC:Msg("No community selected.")
        return
    end

    if not iCC:HasPermission(activeCommunity, "invite") then
        iCC:Msg("You do not have permission to invite.")
        return
    end

    if not StaticPopupDialogs["ICC_INVITE_DIALOG"] then
        StaticPopupDialogs["ICC_INVITE_DIALOG"] = {
            text = "Enter a player name to invite:",
            button1 = "Invite",
            button2 = "Cancel",
            hasEditBox = true,
            timeout = 30,
            whileDead = true,
            hideOnEscape = true,
            OnAccept = function(self)
                local name = self.EditBox:GetText()
                if name and name ~= "" then
                    iCC:SendInvite(iCC.State.ActiveCommunity, name)
                end
            end,
            EditBoxOnEnterPressed = function(self)
                local name = self:GetText()
                if name and name ~= "" then
                    iCC:SendInvite(iCC.State.ActiveCommunity, name)
                end
                self:GetParent():Hide()
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end,
        }
    end

    StaticPopup_Show("ICC_INVITE_DIALOG")
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                        Create Community Dialog                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:ShowCreateCommunityDialog()
    if iCC.State.InCombat then
        print(L["InCombat"])
        return
    end

    -- Check max communities
    local communities = iCC:GetMyCommunities()
    if #communities >= iCC.CONSTANTS.MAX_COMMUNITIES_PER_PLAYER then
        iCC:Msg(iCC.Colors.Red .. L["CommunityMaxReached"] .. iCC.Colors.Reset)
        return
    end

    if not StaticPopupDialogs["ICC_CREATE_COMMUNITY"] then
        StaticPopupDialogs["ICC_CREATE_COMMUNITY"] = {
            text = L["CreateCommunityDialogText"],
            button1 = L["CreateButton"],
            button2 = L["Cancel"],
            hasEditBox = true,
            maxLetters = iCC.CONSTANTS.MAX_COMMUNITY_NAME,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            OnAccept = function(self)
                local name = self.EditBox:GetText()
                if name and name ~= "" then
                    local ok, err = iCC:CreateCommunity(name)
                    if ok then
                        local communityKey = iCC:GetCommunityKey(name, iCC.CurrentRealm)
                        iCC.State.ActiveCommunity = communityKey
                        iCC:StartHeartbeatTimer()
                        iCC:SendMessage("ICC_ROSTER_UPDATED", communityKey)
                        if iCC.RosterFrame and iCC.RosterFrame:IsShown() then
                            iCC:UpdateCommunityTabs()
                            iCC:UpdateRosterDisplay()
                            iCC:UpdateChatDisplay()
                        end
                    end
                end
            end,
            EditBoxOnEnterPressed = function(self)
                local name = self:GetText()
                if name and name ~= "" then
                    local ok, err = iCC:CreateCommunity(name)
                    if ok then
                        local communityKey = iCC:GetCommunityKey(name, iCC.CurrentRealm)
                        iCC.State.ActiveCommunity = communityKey
                        iCC:StartHeartbeatTimer()
                        iCC:SendMessage("ICC_ROSTER_UPDATED", communityKey)
                        if iCC.RosterFrame and iCC.RosterFrame:IsShown() then
                            iCC:UpdateCommunityTabs()
                            iCC:UpdateRosterDisplay()
                            iCC:UpdateChatDisplay()
                        end
                    end
                end
                self:GetParent():Hide()
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end,
        }
    end

    StaticPopup_Show("ICC_CREATE_COMMUNITY")
end
