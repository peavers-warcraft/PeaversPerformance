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

-- Functions re-run whenever a preset is applied/restored, so every page
-- always reflects the live state (active preset, current CVar values).
-- One bucket per tab: tabs are built lazily and cached, so a rebuild of one
-- page must not wipe another page's refreshers.
local refreshers = {
    presets = {},
    autoswitch = {},
    transparency = {},
}

function ConfigUI:Refresh()
    for _, list in pairs(refreshers) do
        for _, fn in ipairs(list) do
            pcall(fn)
        end
    end
end

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
local function CreateDetailSection(parentFrame, preset, width, anchorTo, indent, firstY, pageState, refreshList)
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
        table.insert(refreshList, UpdateRow)
    end

    section.content:SetHeight(contentHeight)
    SizeSection(false)

    return section
end

--------------------------------------------------------------------------------
-- Presets tab
--------------------------------------------------------------------------------

function ConfigUI:BuildPresetsPage(parentFrame)
    local list = refreshers.presets
    wipe(list)

    local y = -10
    local indent = 25
    local width = ResolveWidth(parentFrame, indent)
    local PresetManager = addon.PresetManager
    local Presets = addon.Presets

    local _, newY = W:CreateSectionHeader(parentFrame, "Graphics Presets", indent, y)
    y = newY - 8

    local intro = W:CreateLabel(parentFrame,
        "These buttons just change graphics CVars - the same thing 'FPS boost' UI packs do quietly. "
            .. "The Transparency tab shows exactly what each one sets, and Restore puts everything back.",
        { color = C.textSec })
    intro:SetPoint("TOPLEFT", indent, y)
    intro:SetWidth(width)
    intro:SetJustifyH("LEFT")
    intro:SetSpacing(2)
    y = y - intro:GetStringHeight() - 14

    local status = W:CreateLabel(parentFrame, "", { color = C.gold })
    status:SetPoint("TOPLEFT", indent, y)
    y = y - 26

    table.insert(list, function()
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

    table.insert(list, function()
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

    table.insert(list, function()
        local state = PresetManager.GetStatus()
        if state.hasSnapshot then
            restoreBtn:EnableMouse(true)
            restoreBtn:SetAlpha(1)
        else
            restoreBtn:EnableMouse(false)
            restoreBtn:SetAlpha(0.4)
        end
    end)

    parentFrame:SetHeight(math.abs(y) + 20)
    parentFrame:SetScript("OnShow", function() ConfigUI:Refresh() end)
    self:Refresh()
end

--------------------------------------------------------------------------------
-- Auto-Switch tab
--------------------------------------------------------------------------------

function ConfigUI:BuildAutoSwitchPage(parentFrame)
    local list = refreshers.autoswitch
    wipe(list)

    local y = -10
    local indent = 25
    local width = ResolveWidth(parentFrame, indent)
    local Presets = addon.Presets

    local _, newY = W:CreateSectionHeader(parentFrame, "Auto-Switch", indent, y)
    y = newY - 8

    local intro = W:CreateLabel(parentFrame,
        "Automatically apply a preset when you zone into a raid, Mythic+, or dungeon, "
            .. "and switch back in the open world. 'No change' leaves that location alone. "
            .. "Every automatic switch is announced in chat.",
        { color = C.textSec })
    intro:SetPoint("TOPLEFT", indent, y)
    intro:SetWidth(width)
    intro:SetJustifyH("LEFT")
    intro:SetSpacing(2)
    y = y - intro:GetStringHeight() - 12

    local enableBox = W:CreateCheckbox(parentFrame, "Enable auto-switching", {
        checked = addon.Config.autoSwitchEnabled,
        onChange = function(checked)
            addon.Config.autoSwitchEnabled = checked
            addon.Config:Save()
            if checked then
                addon.AutoSwitch.Evaluate(true)
            end
        end,
    })
    enableBox:SetPoint("TOPLEFT", indent, y)
    y = y - 32

    table.insert(list, function()
        enableBox:SetChecked(addon.Config.autoSwitchEnabled)
    end)

    local targetOptions = { { value = "none", label = "No change" } }
    for _, key in ipairs(Presets.order) do
        table.insert(targetOptions, { value = key, label = Presets.GetName(key) })
    end
    table.insert(targetOptions, { value = "restore", label = "My original settings" })

    local colWidth = math.floor((width - 20) / 2)
    for i, ctx in ipairs(addon.AutoSwitch.contexts) do
        local col = (i - 1) % 2
        local dropdown = W:CreateDropdown(parentFrame, ctx.name, {
            width = colWidth,
            selected = addon.Config[ctx.configKey],
            options = targetOptions,
            onChange = function(value)
                addon.Config[ctx.configKey] = value
                addon.Config:Save()
                addon.AutoSwitch.Evaluate(true)
            end,
        })
        dropdown:SetPoint("TOPLEFT", indent + col * (colWidth + 20), y)

        table.insert(list, function()
            dropdown:SetSelected(addon.Config[ctx.configKey])
        end)

        if col == 1 or i == #addon.AutoSwitch.contexts then
            y = y - 58
        end
    end

    y = y - 4

    local location = W:CreateLabel(parentFrame, "", { color = C.textMuted, size = 10 })
    location:SetPoint("TOPLEFT", indent, y)
    y = y - 20

    table.insert(list, function()
        local context = addon.AutoSwitch.GetContext()
        local name = context and addon.AutoSwitch.GetContextName(context) or "Unmanaged (battleground, arena, scenario)"
        location:SetText("You are currently in: " .. name)
    end)

    parentFrame:SetHeight(math.abs(y) + 20)
    parentFrame:SetScript("OnShow", function() ConfigUI:Refresh() end)
    self:Refresh()
end

--------------------------------------------------------------------------------
-- Transparency tab
--------------------------------------------------------------------------------

function ConfigUI:BuildTransparencyPage(parentFrame)
    local list = refreshers.transparency
    wipe(list)

    local y = -10
    local indent = 25
    local width = ResolveWidth(parentFrame, indent)
    local Presets = addon.Presets

    local _, newY = W:CreateSectionHeader(parentFrame, "Full Transparency", indent, y)
    y = newY - 8

    local intro = W:CreateLabel(parentFrame,
        "Every CVar each preset sets, with your current value on the left of the arrow. "
            .. "Nothing outside these lists is ever touched.",
        { color = C.textSec })
    intro:SetPoint("TOPLEFT", indent, y)
    intro:SetWidth(width)
    intro:SetJustifyH("LEFT")
    intro:SetSpacing(2)
    y = y - intro:GetStringHeight() - 14

    local sections = {}
    local pageState = {}
    local previous = nil
    local sectionsTopY = y
    for _, key in ipairs(Presets.order) do
        local section = CreateDetailSection(parentFrame, Presets.Get(key), width, previous, indent, sectionsTopY, pageState, list)
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
    parentFrame:SetScript("OnShow", function() ConfigUI:Refresh() end)
    self:Refresh()
end

--------------------------------------------------------------------------------
-- Information tab
--------------------------------------------------------------------------------

function ConfigUI:BuildInfoPage(parentFrame)
    PeaversCommons.ConfigUIUtils.BuildInfoPage(parentFrame, "Performance", {
        "One-click graphics presets spanning the whole scale - Maximum, " ..
            "Quality, Balanced, Performance, and Minimum. Popular FPS-boost UI " ..
            "packs get much of their reputation by quietly lowering graphics " ..
            "settings; this addon does the same thing honestly and shows you " ..
            "exactly what changes.",
        { command = "/pperf", desc = "open the preset panel" },
        { command = "/pperf max", desc = "everything cranked, for beefy rigs" },
        { command = "/pperf quality", desc = "mild FPS wins, keeps it pretty" },
        { command = "/pperf balanced", desc = "noticeable gains, moderate visual cost" },
        { command = "/pperf performance", desc = "maximum FPS, potato mode" },
        { command = "/pperf min", desc = "absolute floor, everything off that can be off" },
        { command = "/pperf restore", desc = "restore your original settings" },
        { command = "/pperf auto", desc = "toggle auto-switching by location" },
        { command = "/pperf status", desc = "show the active preset" },

        { header = "Auto-switch by location" },
        "Optionally apply a preset automatically when you zone into a raid, " ..
            "Mythic+, or dungeon, and return to your original settings in the " ..
            "open world. Pick a preset per location on the Auto-Switch tab - " ..
            "any location set to 'No change' is left alone, and every " ..
            "automatic switch is announced in chat.",

        { header = "Nothing is hidden, nothing is lost" },
        "Every preset lists each console variable it changes with the current " ..
            "and new value - see the Transparency tab before applying. " ..
            "Your original settings are snapshotted before the first preset and " ..
            "one click restores every one of them.",

        { header = "Safety floor" },
        "Every tier keeps ground danger indicators on and essential spell " ..
            "effects visible - the addon will not trade mechanics visibility " ..
            "for frames. Presets apply in raids and battlegrounds too, and " ..
            "queue safely if you are in combat.",
    })
end

--------------------------------------------------------------------------------
-- Registration plumbing
--------------------------------------------------------------------------------

function ConfigUI:GetPages()
    return {
        { key = "info", label = "Information", builder = function(f) ConfigUI:BuildInfoPage(f) end },
        { key = "presets", label = "Presets", builder = function(f) ConfigUI:BuildPresetsPage(f) end },
        { key = "autoswitch", label = "Auto-Switch", builder = function(f) ConfigUI:BuildAutoSwitchPage(f) end },
        { key = "transparency", label = "Transparency", builder = function(f) ConfigUI:BuildTransparencyPage(f) end },
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
