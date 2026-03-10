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
-- │                                Options Panel                                  │
-- │                          Settings UI (iWR/iSP Style)                          │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local L = iCC.L

local CHECKBOX_TEMPLATE = InterfaceOptionsCheckButtonTemplate and "InterfaceOptionsCheckButtonTemplate" or "UICheckButtonTemplate"
local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                             Helper: Section Header                            │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local function CreateSectionHeader(parent, text, yOffset)
    local header = CreateFrame("Frame", nil, parent, BACKDROP_TEMPLATE)
    header:SetHeight(24)
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, yOffset)
    header:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
    })
    header:SetBackdropColor(0.15, 0.15, 0.2, 0.6)

    local accent = header:CreateTexture(nil, "ARTWORK")
    accent:SetHeight(1)
    accent:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
    accent:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
    accent:SetColorTexture(1, 0.59, 0.09, 0.4)

    local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", header, "LEFT", 8, 0)
    label:SetText(text)

    return header, yOffset - 28
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Helper: Settings Checkbox                          │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local function CreateSettingsCheckbox(parent, label, descText, yOffset, settingKey, getFunc, setFunc)
    local cb = CreateFrame("CheckButton", nil, parent, CHECKBOX_TEMPLATE)
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)

    -- UICheckButtonTemplate (retail) doesn't have .Text, create it if missing
    if not cb.Text then
        cb.Text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        cb.Text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    end
    cb.Text:SetText(label)
    cb.Text:SetFontObject(GameFontHighlight)

    if getFunc then
        cb:SetChecked(getFunc())
    else
        cb:SetChecked(iCCSettings[settingKey])
    end

    cb:SetScript("OnClick", function(self)
        local checked = self:GetChecked() and true or false
        if setFunc then
            setFunc(checked)
        else
            iCCSettings[settingKey] = checked
        end
    end)

    local nextY = yOffset - 22
    if descText and descText ~= "" then
        local desc = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        desc:SetPoint("TOPLEFT", parent, "TOPLEFT", 48, nextY)
        desc:SetWidth(480)
        desc:SetJustifyH("LEFT")
        desc:SetText(descText)
        local height = desc:GetStringHeight()
        if height < 12 then height = 12 end
        nextY = nextY - height - 6
    end

    return cb, nextY
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                             Helper: Settings Button                           │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local function CreateSettingsButton(parent, text, width, yOffset, onClick)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(width, 26)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    btn:SetText(text)
    btn:SetScript("OnClick", onClick)
    return btn, yOffset - 34
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                              Helper: Info Text                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local function CreateInfoText(parent, text, yOffset, fontObj)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontObj or "GameFontHighlight")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 25, yOffset)
    fs:SetWidth(500)
    fs:SetJustifyH("LEFT")
    fs:SetText(text)
    local height = fs:GetStringHeight()
    if height < 14 then height = 14 end
    return fs, yOffset - height - 4
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Close Other Addon Settings                           │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local function CloseOtherAddonSettings()
    local iWRFrame = _G.iWR and _G.iWR.SettingsFrame
    if iWRFrame and iWRFrame:IsShown() then iWRFrame:Hide() end
    local iSPFrame = _G.iSP and _G.iSP.SettingsFrame
    if iSPFrame and iSPFrame:IsShown() then iSPFrame:Hide() end
    local iNIFFrame = _G["iNIFSettingsFrame"]
    if iNIFFrame and iNIFFrame:IsShown() then iNIFFrame:Hide() end
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Create Settings Frame                                │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:CreateOptionsPanel()
    -- ╭──────────────────────────╮
    -- │       Main Frame         │
    -- ╰──────────────────────────╯

    local settingsFrame = iCC:CreateiCCStyleFrame(UIParent, 750, 520, {"CENTER", UIParent, "CENTER"})
    settingsFrame:Hide()
    settingsFrame:EnableMouse(true)
    settingsFrame:SetMovable(true)
    settingsFrame:SetFrameStrata("HIGH")
    settingsFrame:SetClampedToScreen(true)
    settingsFrame:SetBackdropColor(0.05, 0.05, 0.1, 0.95)
    settingsFrame:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
    iCC.SettingsFrame = settingsFrame

    -- ╭──────────────────────────╮
    -- │      Shadow Overlay      │
    -- ╰──────────────────────────╯

    local shadow = CreateFrame("Frame", nil, settingsFrame, BACKDROP_TEMPLATE)
    shadow:SetPoint("TOPLEFT", settingsFrame, -1, 1)
    shadow:SetPoint("BOTTOMRIGHT", settingsFrame, 1, -1)
    shadow:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 5,
    })
    shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

    -- ╭──────────────────────────╮
    -- │      Drag Handlers       │
    -- ╰──────────────────────────╯

    settingsFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    settingsFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
    settingsFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing(); self:SetUserPlaced(true) end)
    settingsFrame:RegisterForDrag("LeftButton", "RightButton")

    -- ╭──────────────────────────╮
    -- │       Title Bar          │
    -- ╰──────────────────────────╯

    local titleBar = CreateFrame("Frame", nil, settingsFrame, BACKDROP_TEMPLATE)
    titleBar:SetHeight(31)
    titleBar:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    titleBar:SetBackdropColor(0.07, 0.07, 0.12, 1)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleText:SetText(iCC.Colors.iCC .. "iCommunityChat" .. iCC.Colors.Green .. " v" .. iCC.Version)

    -- ╭──────────────────────────╮
    -- │      Close Button        │
    -- ╰──────────────────────────╯

    local closeButton = CreateFrame("Button", nil, settingsFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", 0, 0)
    closeButton:SetScript("OnClick", function() iCC:SettingsClose() end)

    -- ╭──────────────────────────╮
    -- │        Sidebar           │
    -- ╰──────────────────────────╯

    local sidebarWidth = 150
    local sidebar = CreateFrame("Frame", nil, settingsFrame, BACKDROP_TEMPLATE)
    sidebar:SetWidth(sidebarWidth)
    sidebar:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 10, -35)
    sidebar:SetPoint("BOTTOMLEFT", settingsFrame, "BOTTOMLEFT", 10, 10)
    sidebar:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
    sidebar:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
    sidebar:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.6)

    -- ╭──────────────────────────╮
    -- │      Content Area        │
    -- ╰──────────────────────────╯

    local contentArea = CreateFrame("Frame", nil, settingsFrame, BACKDROP_TEMPLATE)
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 6, 0)
    contentArea:SetPoint("BOTTOMRIGHT", settingsFrame, "BOTTOMRIGHT", -10, 10)
    contentArea:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4},
    })
    contentArea:SetBackdropBorderColor(0.6, 0.6, 0.7, 1)
    contentArea:SetBackdropColor(0.08, 0.08, 0.1, 0.95)

    -- ╭──────────────────────────╮
    -- │    Tab Content Factory   │
    -- ╰──────────────────────────╯

    local scrollFrames = {}
    local scrollChildren = {}
    local contentWidth = 550

    local function CreateTabContent()
        local container = CreateFrame("Frame", nil, contentArea)
        container:SetPoint("TOPLEFT", contentArea, "TOPLEFT", 5, -5)
        container:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", -5, 5)
        container:Hide()

        local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        scrollFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -22, 0)

        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetWidth(contentWidth)
        scrollChild:SetHeight(1)
        scrollFrame:SetScrollChild(scrollChild)

        container:EnableMouseWheel(true)
        container:SetScript("OnMouseWheel", function(_, delta)
            local current = scrollFrame:GetVerticalScroll()
            local maxScroll = scrollChild:GetHeight() - scrollFrame:GetHeight()
            if maxScroll < 0 then maxScroll = 0 end
            local newScroll = current - (delta * 30)
            if newScroll < 0 then newScroll = 0 end
            if newScroll > maxScroll then newScroll = maxScroll end
            scrollFrame:SetVerticalScroll(newScroll)
        end)

        table.insert(scrollFrames, scrollFrame)
        table.insert(scrollChildren, scrollChild)

        return container, scrollChild
    end

    -- ╭──────────────────────────╮
    -- │     Create Tab Pages     │
    -- ╰──────────────────────────╯

    local generalContainer, generalContent = CreateTabContent()
    local aboutContainer, aboutContent = CreateTabContent()

    local tabContents = { generalContainer, aboutContainer }
    local sidebarButtons = {}
    local activeIndex = 1

    -- ╭──────────────────────────╮
    -- │     Tab Switch Logic     │
    -- ╰──────────────────────────╯

    local function ShowTab(index)
        activeIndex = index
        for i, content in ipairs(tabContents) do
            content:SetShown(i == index)
        end
        for i, btn in ipairs(sidebarButtons) do
            if i == index then
                btn.bg:SetColorTexture(1, 0.59, 0.09, 0.25)
                btn.text:SetFontObject(GameFontHighlight)
            else
                btn.bg:SetColorTexture(0, 0, 0, 0)
                btn.text:SetFontObject(GameFontNormal)
            end
        end
    end

    -- ╭──────────────────────────╮
    -- │   Sidebar Tab Buttons    │
    -- ╰──────────────────────────╯

    local tabNames = { L["SettingsGeneral"], L["SettingsAbout"] }
    local tabY = -12

    -- Sidebar header
    local sideHeader = sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sideHeader:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 10, tabY)
    sideHeader:SetText(iCC.Colors.iCC .. "iCC" .. iCC.Colors.Reset)
    tabY = tabY - 20

    for i, tabName in ipairs(tabNames) do
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetSize(138, 26)
        btn:SetPoint("TOP", sidebar, "TOP", 0, tabY)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(btn)
        bg:SetColorTexture(0, 0, 0, 0)
        btn.bg = bg

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", btn, "LEFT", 10, 0)
        text:SetText(tabName)
        btn.text = text

        btn:SetScript("OnClick", function()
            ShowTab(i)
        end)

        btn:SetScript("OnEnter", function(self)
            if activeIndex ~= i then
                self.bg:SetColorTexture(1, 1, 1, 0.05)
            end
        end)

        btn:SetScript("OnLeave", function(self)
            if activeIndex ~= i then
                self.bg:SetColorTexture(0, 0, 0, 0)
            end
        end)

        sidebarButtons[i] = btn
        tabY = tabY - 28
    end

    -- ╭──────────────────────────────────────────────────────────────────────────╮
    -- │                         TAB 1: General Settings                         │
    -- ╰──────────────────────────────────────────────────────────────────────────╯

    local y = -10

    -- Section: General
    _, y = CreateSectionHeader(generalContent, L["SectionGeneral"], y)

    -- Section: Chat
    _, y = CreateSectionHeader(generalContent, L["SectionChat"], y - 6)

    _, y = CreateSettingsCheckbox(
        generalContent,
        L["ShowTimestamps"],
        L["ShowTimestampsDesc"],
        y,
        "ShowTimestamps",
        nil,
        function(checked)
            iCCSettings.ShowTimestamps = checked
            if iCC.RosterFrame and iCC.RosterFrame:IsShown() then
                iCC:UpdateChatDisplay()
            end
        end
    )

    _, y = CreateSettingsCheckbox(
        generalContent,
        L["PlaySoundOnMessage"],
        L["PlaySoundOnMessageDesc"],
        y,
        "PlaySoundOnMessage"
    )

    -- Section: UI
    _, y = CreateSectionHeader(generalContent, L["SectionUI"], y - 6)

    _, y = CreateSettingsCheckbox(
        generalContent,
        L["ShowMinimapButton"],
        L["ShowMinimapButtonDesc"],
        y,
        nil,
        function()
            return iCCSettings and iCCSettings.MinimapButton and not iCCSettings.MinimapButton.hide
        end,
        function(checked)
            iCCSettings.MinimapButton.hide = not checked
            if iCCSettings.MinimapButton.hide then
                LDBIcon:Hide("iCommunityChat")
            else
                LDBIcon:Show("iCommunityChat")
            end
        end
    )

    -- Section: Chat Frames
    _, y = CreateSectionHeader(generalContent, L["SectionChatFrames"], y - 6)

    -- General tab (always on, disabled checkbox)
    local generalCb = CreateFrame("CheckButton", nil, generalContent, CHECKBOX_TEMPLATE)
    generalCb:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 20, y)
    if not generalCb.Text then
        generalCb.Text = generalCb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        generalCb.Text:SetPoint("LEFT", generalCb, "RIGHT", 4, 0)
    end
    generalCb.Text:SetText(iCC.Colors.Gray .. "General " .. L["ChatFrameAlwaysOn"] .. iCC.Colors.Reset)
    generalCb:SetChecked(true)
    generalCb:Disable()
    y = y - 22

    -- Dynamic checkboxes for custom chat tabs (2+)
    if not iCCSettings.ChatFrames then
        iCCSettings.ChatFrames = {}
    end

    local skipTabs = { ["Combat Log"] = true, ["Voice"] = true }

    for i = 2, NUM_CHAT_WINDOWS do
        local name = GetChatWindowInfo(i)
        if name and name ~= "" and not skipTabs[name] then
            local frameIndex = i
            local cb = CreateFrame("CheckButton", nil, generalContent, CHECKBOX_TEMPLATE)
            cb:SetPoint("TOPLEFT", generalContent, "TOPLEFT", 20, y)
            if not cb.Text then
                cb.Text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                cb.Text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
            end
            cb.Text:SetText(name)
            cb:SetChecked(iCCSettings.ChatFrames[frameIndex] or false)
            cb:SetScript("OnClick", function(self)
                iCCSettings.ChatFrames[frameIndex] = self:GetChecked() and true or false
            end)
            y = y - 22
        end
    end

    -- Set scroll child height
    generalContent:SetHeight(math.abs(y) + 20)

    -- ╭──────────────────────────────────────────────────────────────────────────╮
    -- │                           TAB 2: About                                  │
    -- ╰──────────────────────────────────────────────────────────────────────────╯

    y = -10

    -- About Section
    _, y = CreateSectionHeader(aboutContent, L["AboutHeader"], y)
    y = y - 20

    -- Centered logo (64x64)
    local aboutIcon = aboutContent:CreateTexture(nil, "ARTWORK")
    aboutIcon:SetSize(64, 64)
    aboutIcon:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutIcon:SetTexture(iCC.AddonPath .. "Images\\Logo_iCC")
    y = y - 70

    -- Centered title
    local aboutTitle = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    aboutTitle:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutTitle:SetText(iCC.Colors.iCC .. "iCommunityChat|r " .. iCC.Colors.Green .. "v" .. iCC.Version .. "|r")
    y = y - 20

    -- Centered author
    local aboutAuthor = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutAuthor:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutAuthor:SetText(L["CreatedBy"] .. "|cFF00FFFF" .. (iCC.Author or "Crasling") .. "|r")
    y = y - 16

    -- Centered game version
    local aboutGameVer = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    aboutGameVer:SetPoint("TOP", aboutContent, "TOP", 0, y)
    aboutGameVer:SetText(iCC.GameVersionName or "")
    y = y - 20

    -- Description
    local aboutInfo = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    aboutInfo:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    aboutInfo:SetWidth(500)
    aboutInfo:SetJustifyH("LEFT")
    aboutInfo:SetText(L["AboutDescription"] .. "\n\n" .. L["AboutEarlyDev"])
    local aih = aboutInfo:GetStringHeight()
    if aih < 14 then aih = 14 end
    y = y - aih - 8

    -- Discord Section
    _, y = CreateSectionHeader(aboutContent, L["DiscordHeader"], y)
    y = y - 2

    local discordDesc = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    discordDesc:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    discordDesc:SetText(L["DiscordLinkMessage"])
    y = y - 16

    local discordBox = CreateFrame("EditBox", nil, aboutContent, "InputBoxTemplate")
    discordBox:SetSize(280, 22)
    discordBox:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    discordBox:SetAutoFocus(false)
    discordBox:SetText(L["DiscordLink"])
    discordBox:SetFontObject(GameFontHighlight)
    discordBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    discordBox:SetScript("OnEditFocusLost", function(self)
        self:HighlightText(0, 0)
        self:SetText(L["DiscordLink"])
    end)
    discordBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    y = y - 30

    -- Translations Section
    _, y = CreateSectionHeader(aboutContent, L["TranslationsHeader"], y)
    y = y - 2

    local translatorText = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    translatorText:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
    translatorText:SetText("|T" .. iCC.AddonPath .. "Images\\Locale\\ruRU.blp:16|t |cFF808080AI Translated|r - " .. L["Russian"])
    y = y - 22

    -- Developer Section
    y = y - 4
    _, y = CreateSectionHeader(aboutContent, L["DeveloperHeader"], y)

    local cbDebug
    cbDebug, y = CreateSettingsCheckbox(aboutContent, L["EnableDebugMode"],
        L["DescEnableDebugMode"], y, "DebugMode", nil,
        function(checked)
            iCCSettings.DebugMode = checked
            for _, f in ipairs(iCC._debugInfoFrames or {}) do
                f:SetShown(checked)
            end
        end)

    -- Version info (shown only when debug mode on)
    iCC._debugInfoFrames = {}

    local versionLabels = {
        {L["GameVersionLabel"], iCC.GameVersion or "N/A"},
        {L["TOCVersionLabel"], iCC.GameTocVersion or "N/A"},
        {L["BuildVersionLabel"], iCC.GameBuild or "N/A"},
        {L["BuildDateLabel"], iCC.GameBuildDate or "N/A"},
    }

    for _, vl in ipairs(versionLabels) do
        local vText = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        vText:SetPoint("TOPLEFT", aboutContent, "TOPLEFT", 25, y)
        vText:SetText(vl[1] .. vl[2])
        vText:SetShown(iCCSettings.DebugMode)
        table.insert(iCC._debugInfoFrames, vText)
        y = y - 16
    end

    -- Set scroll child height
    aboutContent:SetHeight(math.abs(y) + 20)

    -- ╭──────────────────────────╮
    -- │    Show Default Tab      │
    -- ╰──────────────────────────╯

    ShowTab(1)
end

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                          Settings Toggle / Open / Close                       │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:SettingsToggle()
    if iCC.State.InCombat then
        print(L["InCombat"])
        return
    end
    if not iCC.SettingsFrame then
        iCC:CreateOptionsPanel()
    end
    if iCC.SettingsFrame:IsVisible() then
        iCC.SettingsFrame:Hide()
    else
        CloseOtherAddonSettings()
        iCC.SettingsFrame:Show()
    end
end

function iCC:SettingsOpen()
    if iCC.State.InCombat then
        print(L["InCombat"])
        return
    end
    if not iCC.SettingsFrame then
        iCC:CreateOptionsPanel()
    end
    CloseOtherAddonSettings()
    iCC.SettingsFrame:Show()
end

function iCC:SettingsClose()
    if iCC.SettingsFrame then
        iCC.SettingsFrame:Hide()
    end
end
