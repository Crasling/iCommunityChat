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
-- │                                 Data Broker                                    │
-- │                    Minimap Button via LibDataBroker & LibDBIcon                 │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

local L = iCC.L

local iCCLDB = LDBroker:NewDataObject("iCommunityChat", {
    type = "launcher",
    text = "iCommunityChat",
    icon = "Interface\\AddOns\\iCommunityChat\\Images\\Logo_iCC",
    OnClick = function(self, button)
        if button == "LeftButton" then
            if iCC.State.InCombat then
                iCC:Msg("Cannot open UI during combat.")
                return
            end
            iCC:ToggleRosterFrame()
        elseif button == "RightButton" then
            if iCC.State.InCombat then
                iCC:Msg("Cannot open UI during combat.")
                return
            end
            if iCC.SettingsToggle then
                iCC:SettingsToggle()
            end
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:SetText(iCC.Colors.iCC .. "iCommunityChat" .. iCC.Colors.Green .. " v" .. iCC.Version, 1, 1, 1)
        tooltip:AddLine(" ")

        -- Show communities with online counts
        local communities = iCC:GetMyCommunities()
        if #communities > 0 then
            for _, info in ipairs(communities) do
                local online, total = info.online, info.total
                tooltip:AddDoubleLine(
                    iCC.Colors.iCC .. info.name .. "|r",
                    iCC.Colors.Online .. online .. "|r/" .. total,
                    1, 1, 1, 1, 1, 1
                )
            end
        else
            tooltip:AddLine(L["NoCommunities"], 1, 1, 1)
        end

        tooltip:AddLine(" ", 1, 1, 1)
        tooltip:AddLine(L["MinimapLeftClick"], 1, 1, 1)
        tooltip:AddLine(L["MinimapRightClick"], 1, 1, 1)
    end,
})

-- ╭────────────────────────────────────────────────────────────────────────────────╮
-- │                            Register Minimap Icon                               │
-- ╰────────────────────────────────────────────────────────────────────────────────╯

function iCC:SetupMinimapButton()
    if not iCCSettings then return end

    LDBIcon:Register("iCommunityChat", iCCLDB, iCCSettings.MinimapButton)

    if iCCSettings.MinimapButton.hide then
        LDBIcon:Hide("iCommunityChat")
    else
        LDBIcon:Show("iCommunityChat")
    end
end
