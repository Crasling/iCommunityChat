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

local FRAME_WIDTH = 880
local FRAME_HEIGHT = 480
local ROSTER_ROW_HEIGHT = 20
local HEADER_HEIGHT = 31
local SIDEBAR_WIDTH = 150
local ROSTER_PANEL_WIDTH = 280

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

    -- Capture Enter key to focus chat input when frame is shown
    frame:EnableKeyboard(true)
    frame:SetPropagateKeyboardInput(true)
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ENTER" and self.chatInput and not self.chatInput:HasFocus() then
            self:SetPropagateKeyboardInput(false)
            self.chatInput:SetFocus()
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)

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

    -- ╭──────────────────────────╮
    -- │  Selected Community Icon │
    -- ╰──────────────────────────╯

    local iconArea = CreateFrame("Frame", nil, sidebar)
    iconArea:SetSize(SIDEBAR_WIDTH - 12, 62)
    iconArea:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 6, -6)

    local iconTexture = iconArea:CreateTexture(nil, "ARTWORK")
    iconTexture:SetSize(48, 48)
    iconTexture:SetPoint("CENTER", iconArea, "CENTER", 0, 0)
    iconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    iconTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    frame.communityIcon = iconTexture
    frame.communityIconArea = iconArea

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
    -- │        Info Bar          │
    -- ╰──────────────────────────╯

    local infoBar = CreateFrame("Frame", nil, contentArea)
    infoBar:SetHeight(24)
    infoBar:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 4, -4)
    infoBar:SetPoint("TOPRIGHT", contentArea, "TOPRIGHT", -4, -4)
    frame.infoBar = infoBar

    local communityNameText = infoBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    communityNameText:SetPoint("LEFT", infoBar, "LEFT", 8, 0)
    communityNameText:SetJustifyH("LEFT")
    frame.communityNameText = communityNameText

    local onlineText = infoBar:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    onlineText:SetPoint("RIGHT", infoBar, "RIGHT", -8, 0)
    frame.onlineText = onlineText

    -- ╭──────────────────────────╮
    -- │   Roster Panel (right)   │
    -- ╰──────────────────────────╯

    local rosterPanel = CreateFrame("Frame", nil, contentArea, iCC.BACKDROP_TEMPLATE)
    rosterPanel:SetWidth(ROSTER_PANEL_WIDTH)
    rosterPanel:SetPoint("TOPRIGHT", contentArea, "TOPRIGHT", -4, -30)
    rosterPanel:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -4, 30)
    rosterPanel:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    rosterPanel:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
    rosterPanel:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)
    frame.rosterPanel = rosterPanel

    -- Roster column headers
    local rosterHeader = CreateFrame("Frame", nil, rosterPanel)
    rosterHeader:SetHeight(18)
    rosterHeader:SetPoint("TOPLEFT", rosterPanel, "TOPLEFT", 4, -4)
    rosterHeader:SetPoint("TOPRIGHT", rosterPanel, "TOPRIGHT", -22, -4)

    local nameHeader = rosterHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameHeader:SetPoint("LEFT", rosterHeader, "LEFT", 16, 0)
    nameHeader:SetText("Name")
    nameHeader:SetTextColor(1, 0.82, 0, 1)

    local guildHeader = rosterHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildHeader:SetPoint("LEFT", rosterHeader, "LEFT", 96, 0)
    guildHeader:SetWidth(78)
    guildHeader:SetJustifyH("CENTER")
    guildHeader:SetText("Guild")
    guildHeader:SetTextColor(1, 0.82, 0, 1)

    local rankHeader = rosterHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rankHeader:SetPoint("LEFT", rosterHeader, "LEFT", 178, 0)
    rankHeader:SetWidth(50)
    rankHeader:SetJustifyH("CENTER")
    rankHeader:SetText("Rank")
    rankHeader:SetTextColor(1, 0.82, 0, 1)

    local levelHeader = rosterHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelHeader:SetPoint("LEFT", rosterHeader, "LEFT", 232, 0)
    levelHeader:SetWidth(24)
    levelHeader:SetJustifyH("CENTER")
    levelHeader:SetText("Lvl")
    levelHeader:SetTextColor(1, 0.82, 0, 1)

    local rosterScroll = CreateFrame("ScrollFrame", "iCCRosterScroll", rosterPanel, "UIPanelScrollFrameTemplate")
    rosterScroll:SetPoint("TOPLEFT", rosterHeader, "BOTTOMLEFT", 0, -2)
    rosterScroll:SetPoint("BOTTOMRIGHT", rosterPanel, "BOTTOMRIGHT", -22, 4)

    local scrollChild = CreateFrame("Frame", nil, rosterScroll)
    scrollChild:SetWidth(rosterScroll:GetWidth() or (ROSTER_PANEL_WIDTH - 30))
    scrollChild:SetHeight(1)
    rosterScroll:SetScrollChild(scrollChild)
    frame.scrollChild = scrollChild
    frame.rosterRows = {}

    -- ╭──────────────────────────╮
    -- │     Chat Panel (center)  │
    -- ╰──────────────────────────╯

    local chatBg = CreateFrame("Frame", nil, contentArea, iCC.BACKDROP_TEMPLATE)
    chatBg:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 4, -30)
    chatBg:SetPoint("BOTTOMRIGHT", rosterPanel, "BOTTOMLEFT", -4, 0)
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
    chatScroll:SetPoint("BOTTOMRIGHT", chatBg, "BOTTOMRIGHT", -24, 30)

    local chatMessages = CreateFrame("Frame", nil, chatScroll)
    chatMessages:SetWidth(chatScroll:GetWidth() or 300)
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

    local chatInput = CreateFrame("EditBox", "iCCChatInput", chatBg, "InputBoxTemplate")
    chatInput:SetHeight(22)
    chatInput:SetPoint("BOTTOMLEFT", chatBg, "BOTTOMLEFT", 10, 6)
    chatInput:SetPoint("BOTTOMRIGHT", chatBg, "BOTTOMRIGHT", -46, 6)
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

    local sendBtn = CreateFrame("Button", nil, chatBg, "UIPanelButtonTemplate")
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
    -- │   Sidebar Action Buttons │
    -- ╰──────────────────────────╯

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
-- │                          Roster Hover Panel                                    │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local function GetOrCreateHoverPanel()
    if iCC.HoverPanel then return iCC.HoverPanel end

    local panel = CreateFrame("Frame", "iCCHoverPanel", UIParent, "BackdropTemplate")
    panel:SetSize(180, 120)
    panel:SetFrameStrata("TOOLTIP")
    panel:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8x8",
        edgeFile = "Interface\\BUTTONS\\WHITE8x8",
        edgeSize = 1,
    })
    panel:SetBackdropColor(0.07, 0.07, 0.12, 0.95)
    panel:SetBackdropBorderColor(0.2, 0.2, 0.25, 1)

    -- Shadow overlay
    local shadow = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    shadow:SetPoint("TOPLEFT", panel, "TOPLEFT", -1, 1)
    shadow:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 1, -1)
    shadow:SetFrameLevel(panel:GetFrameLevel() - 1)
    shadow:SetBackdrop({
        edgeFile = "Interface\\BUTTONS\\WHITE8x8",
        edgeSize = 5,
    })
    shadow:SetBackdropBorderColor(0, 0, 0, 0.6)

    local yOff = -8

    -- Name
    panel.nameText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.nameText:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, yOff)
    panel.nameText:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, yOff)
    panel.nameText:SetJustifyH("LEFT")
    yOff = yOff - 18

    -- Separator
    local sep = panel:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, yOff)
    sep:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, yOff)
    sep:SetColorTexture(1, 0.82, 0, 0.3)
    yOff = yOff - 6

    -- Info labels
    local function MakeLabel(labelText)
        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, yOff)
        label:SetJustifyH("LEFT")
        label:SetTextColor(1, 0.82, 0, 1)
        label:SetText(labelText)

        local value = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        value:SetPoint("LEFT", label, "RIGHT", 4, 0)
        value:SetPoint("RIGHT", panel, "RIGHT", -10, 0)
        value:SetJustifyH("LEFT")
        value:SetTextColor(0.8, 0.8, 0.8, 1)

        yOff = yOff - 14
        return value
    end

    panel.guildValue = MakeLabel("Guild:")
    panel.rankValue = MakeLabel("Rank:")
    panel.levelValue = MakeLabel("Level:")
    panel.statusValue = MakeLabel("Status:")
    panel.lastSeenValue = MakeLabel("Last Seen:")

    panel:SetHeight(math.abs(yOff) + 8)
    panel:Hide()
    panel:EnableMouse(false)

    iCC.HoverPanel = panel
    return panel
end

local function ShowHoverPanel(row)
    if not row.memberKey or not row.communityKey then return end
    local community = iCCCommunities[row.communityKey]
    if not community then return end
    local member = community.members[row.memberKey]
    if not member then return end

    local panel = GetOrCreateHoverPanel()
    local name = strsplit("-", row.memberKey)

    -- Name (class-colored)
    panel.nameText:SetText(iCC:ColorizePlayerNameByClass(name, member.class))

    -- Guild
    panel.guildValue:SetText((member.guild and member.guild ~= "") and member.guild or "-")

    -- Rank (role-colored)
    panel.rankValue:SetText(iCC:GetRoleColor(member.role) .. iCC:GetRankDisplayName(row.communityKey, member.role) .. iCC.Colors.Reset)

    -- Level
    panel.levelValue:SetText(tostring(member.level or "?"))

    -- Status
    if member.online then
        panel.statusValue:SetText("|cFF00FF00Online|r")
    else
        panel.statusValue:SetText("|cFF808080Offline|r")
    end

    -- Last Seen
    if member.lastSeen then
        local elapsed = time() - member.lastSeen
        if elapsed < 60 then
            panel.lastSeenValue:SetText("Just now")
        elseif elapsed < 3600 then
            panel.lastSeenValue:SetText(math.floor(elapsed / 60) .. "m ago")
        elseif elapsed < 86400 then
            panel.lastSeenValue:SetText(math.floor(elapsed / 3600) .. "h ago")
        else
            panel.lastSeenValue:SetText(math.floor(elapsed / 86400) .. "d ago")
        end
    else
        panel.lastSeenValue:SetText("-")
    end

    -- Position to the left of the roster panel
    panel:ClearAllPoints()
    panel:SetPoint("TOPRIGHT", row, "TOPLEFT", -4, 4)
    panel:Show()
end

local function HideHoverPanel()
    if iCC.HoverPanel then
        iCC.HoverPanel:Hide()
    end
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
    statusDot:SetPoint("LEFT", row, "LEFT", 4, 0)
    statusDot:SetTexture("Interface\\COMMON\\Indicator-Green")
    row.statusDot = statusDot

    -- Name
    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("LEFT", statusDot, "RIGHT", 4, 0)
    nameText:SetWidth(76)
    nameText:SetJustifyH("LEFT")
    nameText:SetWordWrap(false)
    row.nameText = nameText

    -- Guild
    local guildText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildText:SetPoint("LEFT", row, "LEFT", 96, 0)
    guildText:SetWidth(78)
    guildText:SetJustifyH("CENTER")
    guildText:SetWordWrap(false)
    guildText:SetTextColor(0.5, 0.5, 0.5, 1)
    row.guildText = guildText

    -- Rank
    local rankText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rankText:SetPoint("LEFT", row, "LEFT", 178, 0)
    rankText:SetWidth(50)
    rankText:SetJustifyH("CENTER")
    row.rankText = rankText

    -- Level
    local levelText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    levelText:SetPoint("LEFT", row, "LEFT", 232, 0)
    levelText:SetWidth(24)
    levelText:SetJustifyH("CENTER")
    row.levelText = levelText

    -- Hover panel
    row:SetScript("OnEnter", function(self)
        ShowHoverPanel(self)
    end)
    row:SetScript("OnLeave", function()
        HideHoverPanel()
    end)

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
        -- No active community — show empty state, hide content frames
        iCC.RosterFrame.titleText:SetText(iCC.Colors.iCC .. "iCommunityChat" .. iCC.Colors.Reset)
        local isEmpty = not hasCommunities
        iCC.RosterFrame.emptyPanel:SetShown(isEmpty)
        iCC.RosterFrame.infoBar:SetShown(not isEmpty)
        iCC.RosterFrame.rosterPanel:SetShown(not isEmpty)
        iCC.RosterFrame.chatBg:SetShown(not isEmpty)
        -- Hide all rows
        for _, row in ipairs(iCC.RosterFrame.rosterRows) do
            row:Hide()
        end
        return
    end

    -- Has active community — hide empty panel, show content frames
    iCC.RosterFrame.emptyPanel:Hide()
    iCC.RosterFrame.infoBar:Show()
    iCC.RosterFrame.rosterPanel:Show()
    iCC.RosterFrame.chatBg:Show()

    -- Update title (always show addon name, community is visible in info bar)
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
        row.rankText:SetText(iCC:GetRoleColor(member.role) .. iCC:GetRankDisplayName(communityKey, member.role) .. iCC.Colors.Reset)

        -- Guild
        row.guildText:SetText(member.guild or "")

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
    iCC.RosterFrame.chatMessages:SetWidth(iCC.RosterFrame.chatScroll:GetWidth() or 300)
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
    frame.infoBar:SetShown(not showing)
    frame.rosterPanel:SetShown(not showing)
    frame.chatBg:SetShown(not showing)
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
    -- │   Name Section   │
    -- ╰──────────────────╯

    local nameHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    nameHeader:SetText(L["CommunityName"] or "Community Name")
    children[#children + 1] = nameHeader
    y = y - 20

    if isLeader then
        local nameBg = CreateFrame("Frame", nil, parent, iCC.BACKDROP_TEMPLATE)
        nameBg:SetSize(380, 28)
        nameBg:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
        nameBg:SetBackdrop({
            bgFile = "Interface\\BUTTONS\\WHITE8x8",
            edgeFile = "Interface\\BUTTONS\\WHITE8x8",
            edgeSize = 1,
        })
        nameBg:SetBackdropColor(0.05, 0.05, 0.08, 1)
        nameBg:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)
        children[#children + 1] = nameBg

        local nameEdit = CreateFrame("EditBox", "iCCNameEdit", nameBg)
        nameEdit:SetPoint("TOPLEFT", nameBg, "TOPLEFT", 6, -4)
        nameEdit:SetPoint("BOTTOMRIGHT", nameBg, "BOTTOMRIGHT", -6, 4)
        nameEdit:SetFontObject(GameFontHighlightSmall)
        nameEdit:SetAutoFocus(false)
        nameEdit:SetMaxLetters(iCC.CONSTANTS.MAX_COMMUNITY_NAME)
        nameEdit:SetText(community.name or "")
        nameEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        nameEdit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        frame._nameEdit = nameEdit
        children[#children + 1] = nameEdit

        y = y - 34
    else
        local nameText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameText:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
        nameText:SetText(community.name or "")
        children[#children + 1] = nameText
        y = y - 18
    end

    -- ╭──────────────────╮
    -- │  Rank Names      │
    -- ╰──────────────────╯

    local rankHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rankHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
    rankHeader:SetText("Rank Names")
    children[#children + 1] = rankHeader
    y = y - 20

    local rankNames = community.rankNames or {}
    local roles = {
        { key = iCC.CONSTANTS.ROLE_LEADER, default = "Leader" },
        { key = iCC.CONSTANTS.ROLE_OFFICER, default = "Officer" },
        { key = iCC.CONSTANTS.ROLE_MEMBER, default = "Member" },
    }

    if isLeader then
        frame._rankEdits = {}
        for _, roleInfo in ipairs(roles) do
            local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            label:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
            label:SetText(iCC:GetRoleColor(roleInfo.key) .. roleInfo.default .. ":|r")
            label:SetWidth(60)
            label:SetJustifyH("LEFT")
            children[#children + 1] = label

            local editBg = CreateFrame("Frame", nil, parent, iCC.BACKDROP_TEMPLATE)
            editBg:SetSize(200, 22)
            editBg:SetPoint("LEFT", label, "RIGHT", 6, 0)
            editBg:SetBackdrop({
                bgFile = "Interface\\BUTTONS\\WHITE8x8",
                edgeFile = "Interface\\BUTTONS\\WHITE8x8",
                edgeSize = 1,
            })
            editBg:SetBackdropColor(0.05, 0.05, 0.08, 1)
            editBg:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)
            children[#children + 1] = editBg

            local edit = CreateFrame("EditBox", nil, editBg)
            edit:SetPoint("TOPLEFT", editBg, "TOPLEFT", 4, -3)
            edit:SetPoint("BOTTOMRIGHT", editBg, "BOTTOMRIGHT", -4, 3)
            edit:SetFontObject(GameFontHighlightSmall)
            edit:SetAutoFocus(false)
            edit:SetMaxLetters(20)
            edit:SetText(rankNames[roleInfo.key] or roleInfo.default)
            edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
            edit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
            children[#children + 1] = edit

            frame._rankEdits[roleInfo.key] = edit
            y = y - 24
        end
    else
        for _, roleInfo in ipairs(roles) do
            local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            label:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
            label:SetText(iCC:GetRoleColor(roleInfo.key) .. roleInfo.default .. ": |r" .. (rankNames[roleInfo.key] or roleInfo.default))
            children[#children + 1] = label
            y = y - 16
        end
    end

    y = y - 8

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

        -- ╭──────────────────────────╮
        -- │   Chat Output Section    │
        -- ╰──────────────────────────╯

        local chatHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        chatHeader:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)
        chatHeader:SetText(L["SectionChatFrames"] or "Chat Output")
        children[#children + 1] = chatHeader
        y = y - 20

        if not community.chatFrames then community.chatFrames = {} end

        -- Mute toggle
        local muteCb = CreateFrame("CheckButton", nil, parent, iCC.CHECKBOX_TEMPLATE or "InterfaceOptionsCheckButtonTemplate")
        muteCb:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
        if not muteCb.Text then
            muteCb.Text = muteCb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            muteCb.Text:SetPoint("LEFT", muteCb, "RIGHT", 4, 0)
        end
        muteCb.Text:SetText("|cFFFF0000Mute|r — hide all chat output for this community")
        muteCb:SetChecked(community.chatFrames.muted or false)
        muteCb:SetScript("OnClick", function(self)
            community.chatFrames.muted = self:GetChecked() and true or false
        end)
        children[#children + 1] = muteCb
        y = y - 22

        -- General (always on unless muted)
        local genCb = CreateFrame("CheckButton", nil, parent, iCC.CHECKBOX_TEMPLATE or "InterfaceOptionsCheckButtonTemplate")
        genCb:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
        if not genCb.Text then
            genCb.Text = genCb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            genCb.Text:SetPoint("LEFT", genCb, "RIGHT", 4, 0)
        end
        genCb.Text:SetText(iCC.Colors.Gray .. "General " .. (L["ChatFrameAlwaysOn"] or "(always on)") .. iCC.Colors.Reset)
        genCb:SetChecked(true)
        genCb:Disable()
        children[#children + 1] = genCb
        y = y - 22

        -- Dynamic chat tab checkboxes
        local skipTabs = { ["Combat Log"] = true, ["Voice"] = true }
        frame._chatFrameCbs = {}
        for i = 2, NUM_CHAT_WINDOWS do
            local tabName = GetChatWindowInfo(i)
            if tabName and tabName ~= "" and not skipTabs[tabName] then
                local frameIndex = i
                local cb = CreateFrame("CheckButton", nil, parent, iCC.CHECKBOX_TEMPLATE or "InterfaceOptionsCheckButtonTemplate")
                cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
                if not cb.Text then
                    cb.Text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    cb.Text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
                end
                cb.Text:SetText(tabName)
                cb:SetChecked(community.chatFrames[frameIndex] or false)
                cb:SetScript("OnClick", function(self)
                    community.chatFrames[frameIndex] = self:GetChecked() and true or false
                end)
                children[#children + 1] = cb
                frame._chatFrameCbs[frameIndex] = cb
                y = y - 22
            end
        end

        y = y - 8

        -- Save Button
        local saveBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        saveBtn:SetSize(120, 26)
        saveBtn:SetPoint("TOPLEFT", parent, "TOPLEFT", 14, y)
        saveBtn:SetText(L["SaveSettings"])
        saveBtn:SetScript("OnClick", function()
            local newName = frame._nameEdit and frame._nameEdit:GetText() or community.name
            if newName and newName ~= "" then
                community.name = newName
            end
            community.icon = iCC._selectedIcon
            community.description = frame._descEdit:GetText() or ""
            community.rules = frame._rulesEdit:GetText() or ""

            -- Save custom rank names
            if frame._rankEdits then
                if not community.rankNames then community.rankNames = {} end
                for roleKey, edit in pairs(frame._rankEdits) do
                    local val = edit:GetText()
                    if val and val ~= "" then
                        community.rankNames[roleKey] = val
                    end
                end
            end

            iCC:BroadcastSettingsChange(communityKey)
            iCC:Msg(L["SettingsSaved"])
            iCC:ToggleSettingsPanel()
            iCC:UpdateCommunityTabs()
            iCC:UpdateRosterDisplay()
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
        iCC.RosterFrame.communityNameText:SetText("")
        iCC.RosterFrame.onlineText:SetText("")
        return
    end

    -- Auto-select first if none active
    if not iCC.State.ActiveCommunity then
        iCC.State.ActiveCommunity = communities[1].key
    end

    local BUTTON_HEIGHT = 50
    local yOffset = -74  -- Below icon area (62px + padding)

    for i, communityInfo in ipairs(communities) do
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetSize(SIDEBAR_WIDTH - 12, BUTTON_HEIGHT)
        btn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 6, yOffset)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(btn)
        btn.bg = bg

        -- Community icon (32x32)
        local comIcon = btn:CreateTexture(nil, "ARTWORK")
        comIcon:SetSize(32, 32)
        comIcon:SetPoint("LEFT", btn, "LEFT", 6, 0)
        comIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        local iconPath = iCCCommunities[communityInfo.key] and iCCCommunities[communityInfo.key].icon
        comIcon:SetTexture(iconPath or "Interface\\Icons\\INV_Misc_QuestionMark")
        btn.icon = comIcon

        -- Community name (right of icon)
        local label = communityInfo.name
        if #label > 12 then label = label:sub(1, 11) .. ".." end

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", comIcon, "RIGHT", 6, 0)
        text:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
        text:SetJustifyH("LEFT")
        text:SetWordWrap(true)
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
        yOffset = yOffset - BUTTON_HEIGHT - 2
    end

    -- Update info bar with active community
    local activeKey = iCC.State.ActiveCommunity
    if activeKey and iCCCommunities[activeKey] then
        local community = iCCCommunities[activeKey]
        iCC.RosterFrame.communityNameText:SetText(iCC.Colors.iCC .. community.name .. iCC.Colors.Reset)

        local online, total = iCC:GetOnlineCount(activeKey)
        iCC.RosterFrame.onlineText:SetText("|cFF808080" .. online .. "/" .. total .. " Online|r")

        -- Update selected community icon
        local icon = community.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
        iCC.RosterFrame.communityIcon:SetTexture(icon)
    else
        iCC.RosterFrame.communityNameText:SetText("")
        iCC.RosterFrame.onlineText:SetText("")
        iCC.RosterFrame.communityIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
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
            C_FriendList.SendWho('n-"' .. memberName .. '"')
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
