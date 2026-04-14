BINDING_HEADER_ABUC = "AB Ultracommander"

local ABUC_CHANNEL = "BATTLEGROUND"
local ABUC_BASES = { "FM", "BS", "LM", "GM", "ST" }
local ABUC_NUMBER_ROWS = {
    { label = "1", main = "1", inc = "1 inc" },
    { label = "2", main = "2", inc = "2 inc" },
    { label = "3", main = "3", inc = "3 inc" },
    { label = "4", main = "4", inc = "4 inc" },
    { label = "5", main = "5", inc = "5 inc" },
    { label = "6+", main = "6+", inc = "6+ inc" }
}

local ABUC_DEFAULTS = {
    posX = 120,
    posY = 120,
    scale = 0.70,
    shown = nil,
    autoShown = nil,
    minimapAngle = 220
}

local ABUC_Frame = nil
local ABUC_MinimapButton = nil
local ABUC_LastInAB = nil
local ABUC_MIN_SCALE = 0.50
local ABUC_MAX_SCALE = 1.00
local ABUC_WIDTH = 606
local ABUC_HEIGHT = 495

local function ABUC_Count(t)
    return table.getn(t)
end

local function ABUC_Print(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffABUC:|r " .. msg)
    end
end

local function ABUC_EnsureDB()
    if not ABUC_DB then
        ABUC_DB = {}
    end
    if ABUC_DB.posX == nil then ABUC_DB.posX = ABUC_DEFAULTS.posX end
    if ABUC_DB.posY == nil then ABUC_DB.posY = ABUC_DEFAULTS.posY end
    if ABUC_DB.scale == nil then ABUC_DB.scale = ABUC_DEFAULTS.scale end
    if ABUC_DB.shown == nil then ABUC_DB.shown = ABUC_DEFAULTS.shown end
    if ABUC_DB.autoShown == nil then ABUC_DB.autoShown = ABUC_DEFAULTS.autoShown end
    if ABUC_DB.minimapAngle == nil then ABUC_DB.minimapAngle = ABUC_DEFAULTS.minimapAngle end
end

local function ABUC_ClampScale(v)
    if v < ABUC_MIN_SCALE then v = ABUC_MIN_SCALE end
    if v > ABUC_MAX_SCALE then v = ABUC_MAX_SCALE end
    return v
end

local function ABUC_SavePosition()
    local left
    local bottom
    local frameScale
    local parentScale

    if not ABUC_Frame then return end

    left = ABUC_Frame:GetLeft()
    bottom = ABUC_Frame:GetBottom()
    if not left or not bottom then return end

    frameScale = ABUC_Frame:GetEffectiveScale()
    parentScale = UIParent:GetEffectiveScale()
    if not frameScale or frameScale == 0 then frameScale = 1 end
    if not parentScale or parentScale == 0 then parentScale = 1 end

    ABUC_DB.posX = left * frameScale / parentScale
    ABUC_DB.posY = bottom * frameScale / parentScale
end

local function ABUC_ApplyPosition()
    if not ABUC_Frame then return end
    ABUC_Frame:ClearAllPoints()
    ABUC_Frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", ABUC_DB.posX, ABUC_DB.posY)
end

local function ABUC_ApplyScale()
    local scale
    if not ABUC_Frame then return end
    scale = ABUC_ClampScale(ABUC_DB.scale)
    ABUC_DB.scale = scale
    ABUC_Frame:SetScale(scale)
    ABUC_ApplyPosition()
end

local function ABUC_IsInAB()
    local zoneName = ""
    if GetRealZoneText then
        zoneName = GetRealZoneText() or ""
    end
    if zoneName == "Arathi Basin" then
        return 1
    end
    if GetZoneText then
        zoneName = GetZoneText() or ""
    end
    if zoneName == "Arathi Basin" then
        return 1
    end
    return nil
end

local function ABUC_Show(auto)
    if not ABUC_Frame then return end
    ABUC_Frame:Show()
    ABUC_DB.shown = 1
    if auto then
        ABUC_DB.autoShown = 1
    else
        ABUC_DB.autoShown = nil
    end
end

local function ABUC_Hide(manual)
    if not ABUC_Frame then return end
    ABUC_Frame:Hide()
    ABUC_DB.shown = nil
    if manual then
        ABUC_DB.autoShown = nil
    end
end

local function ABUC_UpdateZoneState(force)
    local inAB = ABUC_IsInAB()

    if force then
        ABUC_LastInAB = inAB
        if inAB then
            ABUC_Show(1)
        else
            ABUC_Hide(1)
        end
        return
    end

    if inAB and not ABUC_LastInAB then
        ABUC_Show(1)
    elseif (not inAB) and ABUC_LastInAB then
        if ABUC_DB.autoShown then
            ABUC_Hide(1)
        end
    end

    ABUC_LastInAB = inAB
end

local function ABUC_Send(msg)
    if msg and msg ~= "" then
        SendChatMessage(msg, ABUC_CHANNEL)
    end
end

local function ABUC_SetFS(fs, size, r, g, b)
    if not fs then return end
    fs:SetFontObject(GameFontNormal)
    fs:SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE")
    fs:SetTextColor(r, g, b)
end

local function ABUC_StyleButton(btn, text, width, height, fontSize, styleKind)
    local fs
    btn:SetWidth(width)
    btn:SetHeight(height)
    btn:SetNormalTexture("")
    btn:SetPushedTexture("")
    btn:SetHighlightTexture("")
    btn:SetDisabledTexture("")

    if not btn.bg then
        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
        btn.bg:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)

        btn.topLine = btn:CreateTexture(nil, "BORDER")
        btn.topLine:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
        btn.topLine:SetPoint("TOPRIGHT", btn, "TOPRIGHT", 0, 0)
        btn.topLine:SetHeight(1)

        btn.bottomLine = btn:CreateTexture(nil, "BORDER")
        btn.bottomLine:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
        btn.bottomLine:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
        btn.bottomLine:SetHeight(1)

        btn.leftLine = btn:CreateTexture(nil, "BORDER")
        btn.leftLine:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
        btn.leftLine:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
        btn.leftLine:SetWidth(1)

        btn.rightLine = btn:CreateTexture(nil, "BORDER")
        btn.rightLine:SetPoint("TOPRIGHT", btn, "TOPRIGHT", 0, 0)
        btn.rightLine:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
        btn.rightLine:SetWidth(1)

        btn.glow = btn:CreateTexture(nil, "HIGHLIGHT")
        btn.glow:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1)
        btn.glow:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 1)
        btn.glow:SetTexture(1, 1, 1, 0.05)
    end

    if styleKind == "sos" then
        btn.bg:SetTexture(0.62, 0.10, 0.10, 0.96)
    elseif styleKind == "clear" then
        btn.bg:SetTexture(0.12, 0.22, 0.10, 0.96)
    elseif styleKind == "push" then
        btn.bg:SetTexture(0.10, 0.18, 0.45, 0.96)
    elseif styleKind == "report" then
        btn.bg:SetTexture(0.27, 0.17, 0.08, 0.96)
    elseif styleKind == "stealth" then
        btn.bg:SetTexture(0.30, 0.26, 0.08, 0.96)
    elseif styleKind == "flag" then
        btn.bg:SetTexture(0.28, 0.12, 0.36, 0.96)
    else
        btn.bg:SetTexture(0.08, 0.08, 0.09, 0.96)
    end
    btn.topLine:SetTexture(0.42, 0.42, 0.44, 1)
    btn.leftLine:SetTexture(0.42, 0.42, 0.44, 1)
    btn.bottomLine:SetTexture(0.02, 0.02, 0.02, 1)
    btn.rightLine:SetTexture(0.02, 0.02, 0.02, 1)

    fs = getglobal(btn:GetName() .. "Text")
    if fs then
        fs:ClearAllPoints()
        fs:SetPoint("CENTER", btn, "CENTER", 0, 0)
        if styleKind == "sos" then
            ABUC_SetFS(fs, fontSize, 1, 1, 1)
        elseif styleKind == "clear" then
            ABUC_SetFS(fs, fontSize, 0.80, 1.00, 0.80)
        elseif styleKind == "push" then
            ABUC_SetFS(fs, fontSize, 0.78, 0.88, 1.00)
        elseif styleKind == "report" then
            ABUC_SetFS(fs, fontSize, 1.00, 0.84, 0.62)
        elseif styleKind == "stealth" then
            ABUC_SetFS(fs, fontSize, 1.00, 0.92, 0.45)
        elseif styleKind == "flag" then
            ABUC_SetFS(fs, fontSize, 0.92, 0.80, 1.00)
        else
            ABUC_SetFS(fs, fontSize, 1, 0.82, 0)
        end
    end
    btn:SetText(text)
end

local function ABUC_MakeButton(parent, name, text, width, height, fontSize, commandText, styleKind)
    local btn = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    ABUC_StyleButton(btn, text, width, height, fontSize, styleKind)
    btn.commandText = commandText
    btn:RegisterForClicks("LeftButtonUp")
    btn:SetScript("OnClick", function()
        ABUC_Send(this.commandText)
    end)
    return btn
end

local function ABUC_ResetWindow()
    ABUC_DB.posX = ABUC_DEFAULTS.posX
    ABUC_DB.posY = ABUC_DEFAULTS.posY
    ABUC_DB.scale = ABUC_DEFAULTS.scale
    ABUC_ApplyScale()
    ABUC_SavePosition()
end

local function ABUC_Toggle()
    if not ABUC_Frame then return end
    if ABUC_Frame:IsShown() then
        ABUC_Hide(1)
    else
        ABUC_Show(nil)
    end
end

local function ABUC_ParseSlash(msg)
    local _, _, cmd, arg = string.find(msg or "", "^(%S*)%s*(.-)$")
    if not cmd then cmd = "" end
    if not arg then arg = "" end
    cmd = string.lower(cmd)
    return cmd, arg
end

local function ABUC_StartDrag()
    ABUC_Frame:StartMoving()
end

local function ABUC_StopDrag()
    ABUC_Frame:StopMovingOrSizing()
    ABUC_SavePosition()
end

local function ABUC_CreateMinimapButton()
    local btn
    local icon
    local border

    if ABUC_MinimapButton then return end

    btn = CreateFrame("Button", "ABUC_MinimapButton", Minimap)
    ABUC_MinimapButton = btn
    btn:SetFrameStrata("MEDIUM")
    btn:SetWidth(31)
    btn:SetHeight(31)
    btn:EnableMouse(1)
    btn:RegisterForClicks("LeftButtonUp")

    icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", btn, "CENTER", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_BannerPVP_02")
    btn.icon = icon

    border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetWidth(54)
    border:SetHeight(54)
    border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
    btn.border = border

    btn:SetScript("OnClick", function()
        ABUC_Toggle()
    end)

    btn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:AddLine("AB Ultracommander")
        GameTooltip:AddLine("Left-click to show/hide", 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    btn:ClearAllPoints()
    btn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -2, 2)
end

local function ABUC_CreateMainFrame()
    local frame
    local bg
    local innerShade
    local divider
    local edgeTop
    local edgeBottom
    local edgeLeft
    local edgeRight
    local closeBtn
    local minusBtn
    local resetBtn
    local plusBtn
    local header
    local dragOverlay
    local colIndex
    local rowIndex
    local xBase
    local yBase
    local base
    local row
    local leftBtn
    local incBtn
    local sosBtn
    local clearBtn
    local pushBtn
    local reportBtn
    local stealthBtn
    local flagBtn

    frame = CreateFrame("Frame", "ABUC_MainFrame", UIParent)
    ABUC_Frame = frame
    frame:SetWidth(ABUC_WIDTH)
    frame:SetHeight(ABUC_HEIGHT)
    frame:SetMovable(1)
    frame:EnableMouse(1)
    frame:SetClampedToScreen(1)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", ABUC_StartDrag)
    frame:SetScript("OnDragStop", ABUC_StopDrag)

    bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    bg:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
    bg:SetVertexColor(0.01, 0.01, 0.02, 0.68)

    innerShade = frame:CreateTexture(nil, "ARTWORK")
    innerShade:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    innerShade:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    innerShade:SetTexture(0.03, 0.04, 0.06, 0.28)

    local topStrip = frame:CreateTexture(nil, "ARTWORK")
    topStrip:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    topStrip:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    topStrip:SetHeight(18)
    topStrip:SetTexture(0.10, 0.10, 0.12, 0.14)

    edgeTop = frame:CreateTexture(nil, "BORDER")
    edgeTop:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    edgeTop:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    edgeTop:SetHeight(1)
    edgeTop:SetTexture(0.45, 0.45, 0.48, 1)

    edgeBottom = frame:CreateTexture(nil, "BORDER")
    edgeBottom:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    edgeBottom:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    edgeBottom:SetHeight(1)
    edgeBottom:SetTexture(0.45, 0.45, 0.48, 1)

    edgeLeft = frame:CreateTexture(nil, "BORDER")
    edgeLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    edgeLeft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    edgeLeft:SetWidth(1)
    edgeLeft:SetTexture(0.45, 0.45, 0.48, 1)

    edgeRight = frame:CreateTexture(nil, "BORDER")
    edgeRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    edgeRight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    edgeRight:SetWidth(1)
    edgeRight:SetTexture(0.45, 0.45, 0.48, 1)

    minusBtn = ABUC_MakeButton(frame, "ABUC_ScaleMinus", "-", 18, 16, 11, "", nil)
    minusBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -74, -1)
    minusBtn:SetScript("OnClick", function()
        ABUC_DB.scale = ABUC_ClampScale(ABUC_DB.scale - 0.05)
        ABUC_ApplyScale()
    end)

    resetBtn = ABUC_MakeButton(frame, "ABUC_ScaleReset", "R", 18, 16, 11, "", nil)
    resetBtn:SetPoint("LEFT", minusBtn, "RIGHT", 2, 0)
    resetBtn:SetScript("OnClick", ABUC_ResetWindow)

    plusBtn = ABUC_MakeButton(frame, "ABUC_ScalePlus", "+", 18, 16, 11, "", nil)
    plusBtn:SetPoint("LEFT", resetBtn, "RIGHT", 2, 0)
    plusBtn:SetScript("OnClick", function()
        ABUC_DB.scale = ABUC_ClampScale(ABUC_DB.scale + 0.05)
        ABUC_ApplyScale()
    end)

    closeBtn = ABUC_MakeButton(frame, "ABUC_CloseButton", "X", 20, 16, 11, "", nil)
    closeBtn:SetPoint("LEFT", plusBtn, "RIGHT", 2, 0)
    closeBtn:SetScript("OnClick", function()
        ABUC_Hide(1)
    end)

    dragOverlay = CreateFrame("Frame", "ABUC_DragOverlay", frame)
    dragOverlay:SetFrameStrata("HIGH")
    dragOverlay:SetWidth(ABUC_WIDTH - 100)
    dragOverlay:SetHeight(18)
    dragOverlay:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    dragOverlay:EnableMouse(1)
    dragOverlay:RegisterForDrag("LeftButton")
    dragOverlay:SetScript("OnDragStart", ABUC_StartDrag)
    dragOverlay:SetScript("OnDragStop", ABUC_StopDrag)

    for colIndex = 1, ABUC_Count(ABUC_BASES) do
        xBase = 10 + ((colIndex - 1) * 123)
        base = ABUC_BASES[colIndex]

        header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header:SetPoint("TOPLEFT", frame, "TOPLEFT", xBase + 23, -18)
        header:SetJustifyH("CENTER")
        header:SetText(base)
        ABUC_SetFS(header, 20, 1, 0.82, 0)

        if colIndex < ABUC_Count(ABUC_BASES) then
            divider = frame:CreateTexture(nil, "ARTWORK")
            divider:SetPoint("TOPLEFT", frame, "TOPLEFT", xBase + 114, -18)
            divider:SetWidth(1)
            divider:SetHeight(370)
            divider:SetTexture(0.34, 0.28, 0.07, 0.80)
        end

        for rowIndex = 1, ABUC_Count(ABUC_NUMBER_ROWS) do
            row = ABUC_NUMBER_ROWS[rowIndex]
            yBase = -40 - ((rowIndex - 1) * 41)

            leftBtn = ABUC_MakeButton(
                frame,
                "ABUC_" .. base .. "_MAIN_" .. rowIndex,
                row.label,
                54,
                28,
                15,
                base .. " " .. row.main,
                nil
            )
            leftBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", xBase, yBase)

            incBtn = ABUC_MakeButton(
                frame,
                "ABUC_" .. base .. "_INC_" .. rowIndex,
                "inc",
                38,
                28,
                14,
                base .. " " .. row.inc,
                nil
            )
            incBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", xBase + 58, yBase)
        end

        sosBtn = ABUC_MakeButton(frame, "ABUC_" .. base .. "_SOS", "SOS!!!", 96, 28, 16, base .. "!!! SOS NEED HELP!!!", "sos")
        sosBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", xBase, -292)

        clearBtn = ABUC_MakeButton(frame, "ABUC_" .. base .. "_CLEAR", "CLEAR", 96, 28, 16, base .. " Clear", "clear")
        clearBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", xBase, -323)

        pushBtn = ABUC_MakeButton(frame, "ABUC_" .. base .. "_PUSH", "PUSH!", 96, 28, 16, "PUSH " .. base, "push")
        pushBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", xBase, -355)

        reportBtn = ABUC_MakeButton(frame, "ABUC_" .. base .. "_REPORT", "Report?", 96, 28, 15, "Report " .. base .. "?", "report")
        reportBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", xBase, -387)

        stealthBtn = ABUC_MakeButton(frame, "ABUC_" .. base .. "_STEALTH", "Stealth", 96, 28, 14, "Rogue / Feral - go stealth terror " .. base, "stealth")
        stealthBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", xBase, -419)

        flagBtn = ABUC_MakeButton(frame, "ABUC_" .. base .. "_FLAG", "FLAG", 96, 28, 15, "FLAG " .. base .. "!!! CARE!!! SPIN!!!", "flag")
        flagBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", xBase, -451)
    end
end

SLASH_ABUC1 = "/abuc"
SlashCmdList["ABUC"] = function(msg)
    local cmd, arg, value

    cmd, arg = ABUC_ParseSlash(msg)

    if cmd == "" then
        ABUC_Toggle()
        return
    end
    if cmd == "hide" then
        ABUC_Hide(1)
        return
    end
    if cmd == "show" then
        ABUC_Show(nil)
        return
    end
    if cmd == "reset" then
        ABUC_ResetWindow()
        return
    end
    if cmd == "scale" then
        value = tonumber(arg)
        if value then
            ABUC_DB.scale = ABUC_ClampScale(value)
            ABUC_ApplyScale()
        else
            ABUC_Print("usage: /abuc scale 0.70")
        end
        return
    end

    ABUC_Print("commands: /abuc, /abuc hide, /abuc show, /abuc reset, /abuc scale 0.70")
end

local ABUC_Startup = CreateFrame("Frame")
ABUC_Startup:RegisterEvent("PLAYER_LOGIN")
ABUC_Startup:RegisterEvent("PLAYER_ENTERING_WORLD")
ABUC_Startup:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ABUC_Startup:RegisterEvent("ZONE_CHANGED")
ABUC_Startup:RegisterEvent("ZONE_CHANGED_INDOORS")
ABUC_Startup:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        ABUC_EnsureDB()
        ABUC_CreateMainFrame()
        ABUC_CreateMinimapButton()
        ABUC_ApplyScale()
        ABUC_ApplyPosition()
        ABUC_UpdateZoneState(1)
        return
    end

    if not ABUC_Frame then return end
    ABUC_UpdateZoneState(nil)
end)
