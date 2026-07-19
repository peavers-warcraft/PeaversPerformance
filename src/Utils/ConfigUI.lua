local addonName, addon = ...

local ConfigUI = {}
addon.ConfigUI = ConfigUI

local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then
    print("|cffff0000Error:|r PeaversCommons not found.")
    return
end

local W = PeaversCommons.Widgets
local C = W.Colors

-- Functions re-run whenever a preset is applied/restored, so the page
-- always reflects the live state (active preset, current CVar values).
local refreshers = {}

local function ResolveWidth(parentFrame, indent)
    local parentWidth = parentFrame:GetWidth() or 0
    if parentWidth > 100 then
        return parentWidth - (indent * 2) - 10
    end
    return 360
end

local ROW_HEIGHT = 18

-- One collapsible "what this changes" section per preset. Sections are
-- chained to each other so collapsing one reflows the ones below it.
-- pageState.recalc is filled in by the page builder once all sections exist.
local function CreateDetailSection(parentFrame, preset, width, anchorTo, indent, firstY, pageState)
    local contentHeight = #preset.cvars * ROW_HEIGHT + 12
    local section

    local function SizeSection(open)
        section:SetHeight(32 + (open and contentHeight or 0))
    end

    section = W:CreateCollapsibleSection(parentFrame, "What '" .. preset.name .. "' changes", {
        defaultOpen = false,
        onToggle = function(open)
            SizeSection(open)
            if pageState.recalc then
                pageState.recalc()
            end
        end,
    })
    section:SetWidth(width)

    if anchorTo then
        section:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, -8)
    else
        section:SetPoint("TOPLEFT", indent, firstY)
    end

    for i, entry in ipairs(preset.cvars) do
        local rowY = -((i - 1) * ROW_HEIGHT) - 6

        local left = section.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        left:SetPoint("TOPLEFT", 10, rowY)
        left:SetWidth(width - 130)
        left:SetJustifyH("LEFT")
        left:SetWordWrap(false)
        left:SetText("|cffffffff" .. entry.cvar .. "|r  |cff8a8a94" .. entry.note .. "|r")

        local right = section.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        right:SetPoint("TOPRIGHT", -10, rowY)
        right:SetWidth(110)
        right:SetJustifyH("RIGHT")
        right:SetTextColor(C.accentLight[1], C.accentLight[2], C.accentLight[3])

        local function UpdateRow()
            local current = C_CVar.GetCVar(entry.cvar)
            right:SetText((current and tostring(current) or "?") .. " > " .. entry.value)
        end
        UpdateRow()
        table.insert(refreshers, UpdateRow)
    end

    section.content:SetHeight(contentHeight)
    SizeSection(false)

    return section
end

function ConfigUI:BuildPresetsPage(parentFrame)
    wipe(refreshers)

    local y = -10
    local indent = 25
    local width = ResolveWidth(parentFrame, indent)
    local PresetManager = addon.PresetManager
    local Presets = addon.Presets

    local _, newY = W:CreateSectionHeader(parentFrame, "Graphics Presets", indent, y)
    y = newY - 8

    local intro = W:CreateLabel(parentFrame,
        "These buttons just change graphics CVars - the same thing 'FPS boost' UI packs do quietly. "
            .. "Here's exactly what each one sets, and Restore puts everything back.",
        { color = C.textSec })
    intro:SetPoint("TOPLEFT", indent, y)
    intro:SetWidth(width)
    intro:SetJustifyH("LEFT")
    intro:SetSpacing(2)
    y = y - intro:GetStringHeight() - 14

    local status = W:CreateLabel(parentFrame, "", { color = C.gold })
    status:SetPoint("TOPLEFT", indent, y)
    y = y - 26

    table.insert(refreshers, function()
        local state = PresetManager.GetStatus()
        if state.active then
            status:SetText("Active preset: " .. Presets.GetName(state.active))
        else
            status:SetText("No preset active - your own settings are in use")
        end
    end)

    local presetButtons = {}
    for _, key in ipairs(Presets.order) do
        local preset = Presets.Get(key)
        local baseLabel = preset.name .. "  -  " .. preset.blurb

        local btn = W:CreateButton(parentFrame, baseLabel, {
            variant = "secondary",
            width = width,
            height = 32,
            onClick = function()
                PresetManager.ApplyPreset(key)
            end,
        })
        btn:SetPoint("TOPLEFT", indent, y)
        y = y - 38

        presetButtons[key] = { button = btn, baseLabel = baseLabel }
    end

    table.insert(refreshers, function()
        local state = PresetManager.GetStatus()
        for key, info in pairs(presetButtons) do
            if state.active == key then
                info.button:SetLabel(info.baseLabel .. "   (active)")
            else
                info.button:SetLabel(info.baseLabel)
            end
        end
    end)

    y = y - 4

    local restoreBtn = W:CreateButton(parentFrame, "Restore my original settings", {
        variant = "danger",
        width = width,
        height = 28,
        onClick = function()
            addon.PresetManager.RestoreOriginal()
        end,
    })
    restoreBtn:SetPoint("TOPLEFT", indent, y)
    y = y - 34

    local restoreHint = W:CreateLabel(parentFrame,
        "Restore returns you to the settings you had before your first preset.",
        { color = C.textMuted, size = 10 })
    restoreHint:SetPoint("TOPLEFT", indent, y)
    y = y - 24

    table.insert(refreshers, function()
        local state = PresetManager.GetStatus()
        if state.hasSnapshot then
            restoreBtn:EnableMouse(true)
            restoreBtn:SetAlpha(1)
        else
            restoreBtn:EnableMouse(false)
            restoreBtn:SetAlpha(0.4)
        end
    end)

    _, newY = W:CreateSectionHeader(parentFrame, "Full Transparency", indent, y)
    y = newY - 8

    local sections = {}
    local pageState = {}
    local previous = nil
    local sectionsTopY = y
    for _, key in ipairs(Presets.order) do
        local section = CreateDetailSection(parentFrame, Presets.Get(key), width, previous, indent, sectionsTopY, pageState)
        table.insert(sections, section)
        previous = section
    end

    pageState.recalc = function()
        local total = 0
        for _, section in ipairs(sections) do
            total = total + section:GetHeight() + 8
        end
        parentFrame:SetHeight(math.abs(sectionsTopY) + total + 30)
    end

    pageState.recalc()
    self:Refresh()
end

function ConfigUI:Refresh()
    for _, fn in ipairs(refreshers) do
        pcall(fn)
    end
end

function ConfigUI:BuildInfoPage(parentFrame)
    PeaversCommons.ConfigUIUtils.BuildInfoPage(parentFrame, "Performance", {
        "Boosts FPS with three one-click graphics presets - Quality, Balanced, " ..
            "and Performance. Popular FPS-boost UI packs get much of their " ..
            "reputation by quietly lowering graphics settings; this addon does " ..
            "the same thing honestly and shows you exactly what changes.",
        { command = "/pperf", desc = "open the preset panel" },
        { command = "/pperf quality", desc = "mild FPS wins, keeps it pretty" },
        { command = "/pperf balanced", desc = "noticeable gains, moderate visual cost" },
        { command = "/pperf performance", desc = "maximum FPS, potato mode" },
        { command = "/pperf restore", desc = "restore your original settings" },
        { command = "/pperf status", desc = "show the active preset" },

        { header = "Nothing is hidden, nothing is lost" },
        "Every preset lists each console variable it changes with the current " ..
            "and new value - expand the transparency section before applying. " ..
            "Your original settings are snapshotted before the first preset and " ..
            "one click restores every one of them.",

        { header = "Safety floor" },
        "Every tier keeps ground danger indicators on and essential spell " ..
            "effects visible - the addon will not trade mechanics visibility " ..
            "for frames. Presets apply in raids and battlegrounds too, and " ..
            "queue safely if you are in combat.",
    })
end

function ConfigUI:GetPages()
    return {
        { key = "info", label = "Information", builder = function(f) ConfigUI:BuildInfoPage(f) end },
        { key = "presets", label = "Presets", builder = function(f) ConfigUI:BuildPresetsPage(f) end },
    }
end

function ConfigUI:BuildIntoFrame(parentFrame)
    self:BuildPresetsPage(parentFrame)
    return parentFrame
end

function ConfigUI:OpenOptions()
    if _G.PeaversConfig and _G.PeaversConfig.MainFrame then
        _G.PeaversConfig.MainFrame:Show()
        _G.PeaversConfig.MainFrame:SelectAddon("PeaversPerformance")
        return
    end

    if Settings and Settings.OpenToCategory then
        if addon.directSettingsCategoryID then
            local success = pcall(Settings.OpenToCategory, addon.directSettingsCategoryID)
            if success then return end
        end
        if addon.directCategoryID then
            local success = pcall(Settings.OpenToCategory, addon.directCategoryID)
            if success then return end
        end
    end

    if SettingsPanel then
        SettingsPanel:Open()
    end
end

function ConfigUI:Initialize()
end

return ConfigUI
