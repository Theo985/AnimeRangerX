--[[
    NexusLib v1.1 — UI Library for Roblox Scripts
    RGB picker redesigned, softer theme
]]

-- ============================================================
-- SERVICES & CONSTANTS
-- ============================================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ============================================================
-- CONFIGURATION SYSTEM
-- ============================================================

local Configs = {}
local ConfigFolder = "AetherX"

local hasFileFunctions = pcall(function()
    return isfolder and makefolder and readfile and writefile
end)

local function ensureFolder()
    if not hasFileFunctions then return false end
    pcall(function()
        if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    end)
    return true
end

function Configs:Load(configName)
    if not configName or type(configName) ~= "string" then return {} end
    if not hasFileFunctions then return {} end
    ensureFolder()
    local filePath = ConfigFolder .. "/" .. configName .. ".json"
    local success, data = pcall(readfile, filePath)
    if success and data and data ~= "" then
        local ok, decoded = pcall(HttpService.JSONDecode, HttpService, data)
        if ok and decoded then return decoded end
    end
    return {}
end

function Configs:Save(configName, data)
    if not configName or type(configName) ~= "string" then return end
    if not hasFileFunctions then return end
    ensureFolder()
    local filePath = ConfigFolder .. "/" .. configName .. ".json"
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if ok and encoded then pcall(writefile, filePath, encoded) end
end

-- ============================================================
-- DEFAULT THEME  (couleurs adoucies / "vivables")
-- ============================================================

local DefaultTheme = {
    -- Fonds : moins sombres, plus chauds
    Background    = Color3.fromRGB(18, 18, 24),
    TopBar        = Color3.fromRGB(23, 23, 32),
    Border        = Color3.fromRGB(44, 44, 62),

    -- Accent : violet un peu moins saturé, plus doux
    Accent        = Color3.fromRGB(110, 90, 230),

    -- Tabs
    TabActive     = Color3.fromRGB(110, 90, 230),
    TabInactive   = Color3.fromRGB(28, 28, 40),
    TabText       = Color3.fromRGB(248, 248, 255),
    TabTextOff    = Color3.fromRGB(130, 130, 155),

    -- Éléments
    ElementBg     = Color3.fromRGB(24, 24, 34),
    ElementHover  = Color3.fromRGB(32, 32, 46),
    ElementBorder = Color3.fromRGB(40, 40, 58),

    -- Texte : moins blanc pur, plus agréable
    TextPrimary   = Color3.fromRGB(225, 225, 240),
    TextSecondary = Color3.fromRGB(135, 135, 160),
    TitleColor    = Color3.fromRGB(235, 235, 250),
    SubtitleColor = Color3.fromRGB(130, 130, 155),

    -- Toggle
    ToggleOn      = Color3.fromRGB(110, 90, 230),
    ToggleOff     = Color3.fromRGB(42, 42, 60),
    ToggleKnob    = Color3.fromRGB(245, 245, 255),

    -- Slider
    SliderFill    = Color3.fromRGB(110, 90, 230),
    SliderBg      = Color3.fromRGB(36, 36, 52),
    SliderKnob    = Color3.fromRGB(245, 245, 255),

    -- Dropdown
    DropdownBg    = Color3.fromRGB(20, 20, 30),
    DropdownItem  = Color3.fromRGB(26, 26, 38),
    DropdownHover = Color3.fromRGB(34, 34, 50),

    -- Boutons : neutres, pas trop violets
    ButtonBg      = Color3.fromRGB(32, 32, 44),
    ButtonHover   = Color3.fromRGB(42, 42, 58),
    ButtonBorder  = Color3.fromRGB(55, 55, 75),
    ButtonText    = Color3.fromRGB(225, 225, 240),

    -- Notifs : teintes moins criardes
    NotifyBg      = Color3.fromRGB(20, 20, 30),
    NotifySuccess = Color3.fromRGB(72, 190, 120),
    NotifyWarning = Color3.fromRGB(210, 165, 60),
    NotifyError   = Color3.fromRGB(200, 70, 70),

    CornerRadius  = UDim.new(0, 6),
    Font          = Enum.Font.GothamMedium,
    FontBold      = Enum.Font.GothamBold,
    FontSize      = 13,
}

local Theme = {}
for k, v in pairs(DefaultTheme) do Theme[k] = v end

local ThemeCallbacks = {}
local function UpdateTheme(newTheme)
    for k, v in pairs(newTheme) do
        if Theme[k] ~= nil then Theme[k] = v end
    end
    for _, cb in ipairs(ThemeCallbacks) do pcall(cb, Theme) end
end
local function OnThemeChange(cb)
    table.insert(ThemeCallbacks, cb)
end

-- ============================================================
-- UTILITIES
-- ============================================================

local Utility = {}

function Utility.Tween(obj, props, duration, style, dir)
    style    = style    or Enum.EasingStyle.Quart
    dir      = dir      or Enum.EasingDirection.Out
    duration = duration or 0.2
    TweenService:Create(obj, TweenInfo.new(duration, style, dir), props):Play()
end

function Utility.Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or Theme.CornerRadius
    c.Parent = parent
    return c
end

function Utility.Stroke(parent, color, thickness)
    -- Supprime l'ancien stroke d'abord pour éviter les doublons
    for _, ch in ipairs(parent:GetChildren()) do
        if ch:IsA("UIStroke") then ch:Destroy() end
    end
    local s = Instance.new("UIStroke")
    s.Color     = color     or Theme.Border
    s.Thickness = thickness or 1
    s.Parent    = parent
    return s
end

function Utility.Padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent        = parent
    return p
end

function Utility.Frame(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = props.Color    or Color3.fromRGB(255,255,255)
    f.Size             = props.Size     or UDim2.new(1,0,0,30)
    f.Position         = props.Position or UDim2.new(0,0,0,0)
    f.BorderSizePixel  = 0
    f.Name             = props.Name     or "Frame"
    if props.Parent then f.Parent = props.Parent end
    return f
end

function Utility.Label(props)
    local l = Instance.new("TextLabel")
    l.Text             = props.Text      or ""
    l.TextColor3       = props.Color     or Theme.TextPrimary
    l.TextSize         = props.Size      or Theme.FontSize
    l.Font             = props.Font      or Theme.Font
    l.BackgroundTransparency = 1
    l.TextXAlignment   = props.Align     or Enum.TextXAlignment.Left
    l.TextYAlignment   = Enum.TextYAlignment.Center
    l.Size             = props.FrameSize or UDim2.new(1,0,1,0)
    l.Position         = props.Position  or UDim2.new(0,0,0,0)
    l.Name             = props.Name      or "Label"
    if props.Parent then l.Parent = props.Parent end
    return l
end

function Utility.Button(props)
    local b = Instance.new("TextButton")
    b.Text             = props.Text      or ""
    b.TextColor3       = props.Color     or Theme.TextPrimary
    b.TextSize         = props.Size      or Theme.FontSize
    b.Font             = props.Font      or Theme.Font
    b.BackgroundColor3 = props.BgColor   or Color3.fromRGB(255,255,255)
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    b.Size             = props.FrameSize or UDim2.new(1,0,0,30)
    b.Position         = props.Position  or UDim2.new(0,0,0,0)
    b.Name             = props.Name      or "Button"
    if props.Parent then b.Parent = props.Parent end
    return b
end

function Utility.TextBox(props)
    local t = Instance.new("TextBox")
    t.Text              = props.Text        or ""
    t.PlaceholderText   = props.Placeholder or ""
    t.TextColor3        = props.Color       or Theme.TextPrimary
    t.PlaceholderColor3 = Theme.TextSecondary
    t.TextSize          = props.Size        or Theme.FontSize
    t.Font              = props.Font        or Theme.Font
    t.BackgroundColor3  = props.BgColor     or Theme.ElementBg
    t.BorderSizePixel   = 0
    t.ClearTextOnFocus  = props.ClearOnFocus or false
    t.TextXAlignment    = Enum.TextXAlignment.Left
    t.Size              = props.FrameSize   or UDim2.new(1,0,0,30)
    t.Name              = props.Name        or "TextBox"
    if props.Parent then t.Parent = props.Parent end
    return t
end

function Utility.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            mousePos  = input.Position
            framePos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================

local NotificationHolder = nil

local function InitNotifications(screenGui)
    NotificationHolder = Utility.Frame({ Name = "NotificationHolder", Color = Color3.fromRGB(0,0,0), Size = UDim2.new(0, 280, 1, -12), Position = UDim2.new(1, -12, 1, -12) })
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.AnchorPoint = Vector2.new(1, 1)
    NotificationHolder.Parent = screenGui
    local layout = Instance.new("UIListLayout")
    layout.VerticalAlignment   = Enum.VerticalAlignment.Bottom
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding             = UDim.new(0, 6)
    layout.SortOrder           = Enum.SortOrder.LayoutOrder
    layout.Parent              = NotificationHolder
end

local function Notify(opts)
    if not NotificationHolder then return end
    local title    = opts.Title    or "Notification"
    local message  = opts.Message  or ""
    local duration = opts.Duration or 3
    local ntype    = opts.Type     or "Info"

    local accentColor = Theme.Accent
    if ntype == "Success" then accentColor = Theme.NotifySuccess
    elseif ntype == "Warning" then accentColor = Theme.NotifyWarning
    elseif ntype == "Error"   then accentColor = Theme.NotifyError end

    local notif = Utility.Frame({ Name = "Notification", Color = Theme.NotifyBg, Size = UDim2.new(1, 0, 0, 72) })
    notif.ClipsDescendants = true
    Utility.Corner(notif, UDim.new(0, 8))
    Utility.Stroke(notif, Theme.ElementBorder, 1)
    notif.Parent = NotificationHolder

    local bar = Utility.Frame({ Name = "Bar", Color = accentColor, Size = UDim2.new(0, 3, 1, 0), Parent = notif })
    Utility.Corner(bar, UDim.new(0, 2))

    Utility.Label({ Text = title, Color = Theme.TextPrimary, Font = Theme.FontBold, Size = 13, FrameSize = UDim2.new(1,-20,0,18), Position = UDim2.new(0,12,0,10), Parent = notif })

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Text = message; msgLabel.TextColor3 = Theme.TextSecondary; msgLabel.TextSize = 12
    msgLabel.Font = Theme.Font; msgLabel.BackgroundTransparency = 1
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left; msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    msgLabel.TextWrapped = true; msgLabel.Size = UDim2.new(1,-20,0,36); msgLabel.Position = UDim2.new(0,12,0,30)
    msgLabel.Parent = notif

    local progressBg = Utility.Frame({ Name = "ProgressBg", Color = Theme.ElementBorder, Size = UDim2.new(1,0,0,2), Position = UDim2.new(0,0,1,-2), Parent = notif })
    local progress   = Utility.Frame({ Name = "Progress",   Color = accentColor,         Size = UDim2.new(1,0,1,0), Parent = progressBg })

    notif.Position = UDim2.new(1, 300, 0, 0)
    Utility.Tween(notif,     { Position = UDim2.new(0,0,0,0) },          0.3)
    Utility.Tween(progress,  { Size = UDim2.new(0,0,1,0) },              duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    task.delay(duration, function()
        Utility.Tween(notif, { Position = UDim2.new(1,300,0,0) },        0.3)
        task.delay(0.35, function() notif:Destroy() end)
    end)
end

-- ============================================================
-- PLAYER PROFILE
-- ============================================================

local function CreatePlayerProfile(parent)
    local card = Utility.Frame({ Name = "PlayerProfile", Color = Theme.ElementBg, Size = UDim2.new(1,-24,0,70), Position = UDim2.new(0,12,0,12), Parent = parent })
    Utility.Corner(card, UDim.new(0,10))
    Utility.Stroke(card, Theme.ElementBorder, 1)

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "AvatarImage"; avatar.Size = UDim2.new(0,50,0,50); avatar.Position = UDim2.new(0,12,0.5,-25)
    avatar.BackgroundTransparency = 1; avatar.Parent = card
    Utility.Corner(avatar, UDim.new(0,12))
    avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png"

    Utility.Label({ Text = LocalPlayer.Name, Color = Theme.TextPrimary, Font = Theme.FontBold, Size = 14, FrameSize = UDim2.new(1,-80,0,22), Position = UDim2.new(0,72,0,12), Parent = card })
    local dot = Utility.Frame({ Name = "StatusDot", Color = Theme.NotifySuccess, Size = UDim2.new(0,8,0,8), Position = UDim2.new(0,72,0,38), Parent = card })
    Utility.Corner(dot, UDim.new(0,4))
    Utility.Label({ Text = "Freemium", Color = Theme.NotifyWarning, Size = 11, FrameSize = UDim2.new(1,-80,0,18), Position = UDim2.new(0,86,0,36), Parent = card })

    card.Position = UDim2.new(0,12,0,-70)
    Utility.Tween(card, { Position = UDim2.new(0,12,0,12) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    return card
end

-- ============================================================
-- RGB COLOR PICKER  — version propre
-- ============================================================
-- Layout :
--   • Ligne du nom + aperçu couleur (hex) → dans le wrapper principal
--   • Swatches (1 ligne, scrollable horizontalement)
--   • 3 sliders R / G / B avec label + valeur numérique bien alignés
--   • Carré d'aperçu bien visible à droite
-- ============================================================

local function CreateRGBPickerContent(parent, currentColor, callback)

    -- Conteneur principal (fond légèrement distinct, arrondi, bordure)
    local container = Utility.Frame({
        Name   = "RGBContainer",
        Color  = Theme.DropdownBg,
        Size   = UDim2.new(1, -28, 0, 120),
        Position = UDim2.new(0, 14, 0, 0),
        Parent = parent,
    })
    Utility.Corner(container, UDim.new(0, 8))
    Utility.Stroke(container, Theme.ElementBorder, 1)

    -- Valeurs courantes (0–1)
    local r, g, b = currentColor.R, currentColor.G, currentColor.B

    -- ── Aperçu (carré coloré + valeur hex) ──────────────────────

    local previewBox = Utility.Frame({
        Name     = "Preview",
        Color    = currentColor,
        Size     = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(1, -48, 0, 10),
        Parent   = container,
    })
    Utility.Corner(previewBox, UDim.new(0, 6))
    Utility.Stroke(previewBox, Theme.ElementBorder, 1)

    local hexLabel = Utility.Label({
        Text      = string.format("#%02X%02X%02X", math.floor(r*255), math.floor(g*255), math.floor(b*255)),
        Color     = Theme.TextSecondary,
        Size      = 10,
        Font      = Theme.Font,
        Align     = Enum.TextXAlignment.Center,
        FrameSize = UDim2.new(0, 48, 0, 14),
        Position  = UDim2.new(1, -52, 0, 50),
        Parent    = container,
    })

    local function updatePreview()
        local nc = Color3.new(r, g, b)
        previewBox.BackgroundColor3 = nc
        hexLabel.Text = string.format("#%02X%02X%02X", math.floor(r*255), math.floor(g*255), math.floor(b*255))
        pcall(callback, nc)
    end

    -- ── Helper : un slider RGB ───────────────────────────────────
    --   channelColor : couleur de fond de la barre
    --   yPos         : position Y dans le container
    --   initVal      : valeur initiale (0–1)
    --   channelIndex : 1=R 2=G 3=B

    local function makeChannelSlider(label, channelColor, yPos, initVal, channelIndex)
        -- Label "R" / "G" / "B"
        local lbl = Utility.Label({
            Text      = label,
            Color     = channelColor,
            Font      = Theme.FontBold,
            Size      = 11,
            FrameSize = UDim2.new(0, 14, 0, 18),
            Position  = UDim2.new(0, 10, 0, yPos + 1),
            Parent    = container,
        })

        -- Valeur numérique (0–255)
        local valLbl = Utility.Label({
            Text      = tostring(math.floor(initVal * 255)),
            Color     = Theme.TextSecondary,
            Font      = Theme.Font,
            Size      = 10,
            Align     = Enum.TextXAlignment.Right,
            FrameSize = UDim2.new(0, 26, 0, 18),
            Position  = UDim2.new(1, -80, 0, yPos + 1),
            Parent    = container,
        })

        -- Piste (fond gris)
        local trackBg = Utility.Frame({
            Color    = Theme.SliderBg,
            Size     = UDim2.new(1, -100, 0, 5),
            Position = UDim2.new(0, 28, 0, yPos + 7),
            Parent   = container,
        })
        Utility.Corner(trackBg, UDim.new(0, 3))

        -- Remplissage coloré
        local fill = Utility.Frame({
            Color  = channelColor,
            Size   = UDim2.new(initVal, 0, 1, 0),
            Parent = trackBg,
        })
        Utility.Corner(fill, UDim.new(0, 3))

        -- Curseur rond
        local knob = Utility.Frame({
            Color    = Color3.fromRGB(240, 240, 248),
            Size     = UDim2.new(0, 13, 0, 13),
            Position = UDim2.new(initVal, -7, 0.5, -7),
            Parent   = trackBg,
        })
        Utility.Corner(knob, UDim.new(0, 7))
        -- Petite bordure sur le knob pour le faire ressortir
        Utility.Stroke(knob, channelColor, 1)

        return {
            trackBg = trackBg,
            fill    = fill,
            knob    = knob,
            valLbl  = valLbl,
            value   = initVal,

            update  = function(self, val)
                self.value = val
                self.fill.Size     = UDim2.new(val, 0, 1, 0)
                self.knob.Position = UDim2.new(val, -7, 0.5, -7)
                self.valLbl.Text   = tostring(math.floor(val * 255))
                if channelIndex == 1 then r = val
                elseif channelIndex == 2 then g = val
                else b = val end
                updatePreview()
            end,
        }
    end

    -- Espacement vertical entre sliders
    local sliderR = makeChannelSlider("R", Color3.fromRGB(210, 80,  80),  12, r, 1)
    local sliderG = makeChannelSlider("G", Color3.fromRGB(80,  185, 100), 42, g, 2)
    local sliderB = makeChannelSlider("B", Color3.fromRGB(80,  140, 220), 72, b, 3)

    local sliders  = { sliderR, sliderG, sliderB }
    local dragging = { false, false, false }

    for i, s in ipairs(sliders) do
        s.trackBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging[i] = true
                local pct = math.clamp((Mouse.X - s.trackBg.AbsolutePosition.X) / s.trackBg.AbsoluteSize.X, 0, 1)
                s:update(pct)
            end
        end)
    end

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        for i, s in ipairs(sliders) do
            if dragging[i] then
                local pct = math.clamp((Mouse.X - s.trackBg.AbsolutePosition.X) / s.trackBg.AbsoluteSize.X, 0, 1)
                s:update(pct)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging[1], dragging[2], dragging[3] = false, false, false
        end
    end)

    return container, sliders
end

-- ============================================================
-- MAIN LIBRARY
-- ============================================================

local NexusLib = {}
NexusLib.__index = NexusLib

function NexusLib:CreateWindow(opts)
    opts = opts or {}
    local title      = opts.Title      or "NexusLib"
    local subtitle   = opts.Subtitle   or "v1.1"
    local size       = opts.Size       or UDim2.new(0, 580, 0, 520)
    local configName = opts.ConfigName
    local gameName   = opts.GameName   or "Game"

    local savedConfig = {}
    if configName and type(configName) == "string" then
        local ok, res = pcall(Configs.Load, Configs, configName)
        if ok and res then savedConfig = res end
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "NexusLib_" .. title
    screenGui.ResetOnSpawn   = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder   = 100
    screenGui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

    InitNotifications(screenGui)

    local window = Utility.Frame({ Name = "Window", Color = Theme.Background, Size = size, Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2), Parent = screenGui })
    window.ClipsDescendants = true
    Utility.Corner(window, UDim.new(0, 12))
    Utility.Stroke(window, Theme.Border, 1)
    window.Size = UDim2.new(0, 0, 0, 0)
    Utility.Tween(window, { Size = size }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    local shadow = Utility.Frame({ Name = "Shadow", Color = Color3.fromRGB(0,0,0), Size = UDim2.new(1,20,1,20), Position = UDim2.new(0,-10,0,-10), Parent = window })
    shadow.BackgroundTransparency = 0.65; shadow.ZIndex = 0
    Utility.Corner(shadow, UDim.new(0, 16))

    -- Top bar
    local topBar      = Utility.Frame({ Name = "TopBar",      Color = Theme.TopBar,  Size = UDim2.new(1,0,0,56), Parent = window })
    local accentLine  = Utility.Frame({ Name = "AccentLine",  Color = Theme.Accent,  Size = UDim2.new(1,0,0,2),  Position = UDim2.new(0,0,0,56), Parent = window })
    local logoFrame   = Utility.Frame({ Name = "LogoFrame",   Color = Theme.Accent,  Size = UDim2.new(0,4,0,28), Position = UDim2.new(0,16,0.5,-14), Parent = topBar })
    Utility.Corner(logoFrame, UDim.new(0, 2))

    local titleLabel    = Utility.Label({ Text = title,    Font = Theme.FontBold, Size = 17, FrameSize = UDim2.new(0,200,0,24), Position = UDim2.new(0,28,0,10), Parent = topBar })
    local subtitleLabel = Utility.Label({ Text = subtitle, Color = Theme.SubtitleColor, Size = 11, FrameSize = UDim2.new(0,200,0,18), Position = UDim2.new(0,28,0,34), Parent = topBar })

    -- Boutons fenêtre
    local btnGroup = Utility.Frame({ Name = "BtnGroup", Color = Color3.fromRGB(0,0,0), Size = UDim2.new(0,80,0,34), Position = UDim2.new(1,-90,0.5,-17), Parent = topBar })
    btnGroup.BackgroundTransparency = 1

    local minimized  = false
    local normalSize = size

    local function makeWindowBtn(text, xOff, hoverBg, hoverText)
        local btn = Utility.Button({ Name = text.."Btn", Text = text, Color = Theme.TextSecondary, BgColor = Color3.fromRGB(28,28,40), FrameSize = UDim2.new(0,34,0,34), Position = UDim2.new(0,xOff,0,0), Parent = btnGroup })
        btn.TextSize = (text == "−") and 22 or 18
        Utility.Corner(btn, UDim.new(0, 8))
        btn.MouseEnter:Connect(function() Utility.Tween(btn, { BackgroundColor3 = hoverBg, TextColor3 = hoverText }, 0.15) end)
        btn.MouseLeave:Connect(function() Utility.Tween(btn, { BackgroundColor3 = Color3.fromRGB(28,28,40), TextColor3 = Theme.TextSecondary }, 0.15) end)
        return btn
    end

    local minBtn   = makeWindowBtn("−", 0,  Theme.ElementHover,              Theme.Accent)
    local closeBtn = makeWindowBtn("✕", 38, Color3.fromRGB(72,28,28),        Color3.fromRGB(220,100,100))

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            normalSize = window.Size
            Utility.Tween(window, { Size = UDim2.new(0, window.Size.X.Offset, 0, 56) }, 0.25)
        else
            Utility.Tween(window, { Size = normalSize }, 0.25)
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Utility.Tween(window, { Size = UDim2.new(0, window.Size.X.Offset, 0, 0) }, 0.25)
        task.delay(0.3, function() screenGui:Destroy() end)
    end)

    Utility.MakeDraggable(window, topBar)

    -- Tab bar
    local tabBar = Utility.Frame({ Name = "TabBar", Color = Theme.TopBar, Size = UDim2.new(0,160,1,-58), Position = UDim2.new(0,0,0,58), Parent = window })
    Utility.Frame({ Name = "Divider", Color = Theme.Border, Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,0,0,0), Parent = tabBar })

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"; tabScroll.Size = UDim2.new(1,0,1,0); tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0; tabScroll.ScrollBarThickness = 3; tabScroll.ScrollBarImageColor3 = Theme.Accent
    tabScroll.Parent = tabBar
    local tabList = Instance.new("UIListLayout")
    tabList.SortOrder = Enum.SortOrder.LayoutOrder; tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabList.Padding = UDim.new(0, 4); tabList.Parent = tabScroll
    Utility.Padding(tabScroll, 12, 12, 10, 10)

    local contentArea    = Utility.Frame({ Name = "ContentArea",    Color = Theme.Background, Size = UDim2.new(1,-160,1,-58), Position = UDim2.new(0,160,0,58), Parent = window })
    local playerProfile  = CreatePlayerProfile(contentArea)
    local scrollableContent = Utility.Frame({ Name = "ScrollableContent", Color = Theme.Background, Size = UDim2.new(1,0,1,-82), Position = UDim2.new(0,0,0,82), Parent = contentArea })
    scrollableContent.BackgroundTransparency = 1

    local WindowObj  = {}
    local tabs       = {}
    local activeTab  = nil

    local function saveConfig()
        if not configName then return end
        local cfg = { Theme = {} }
        for _, k in ipairs({ "Accent","TabActive","ToggleOn","SliderFill","NotifySuccess","NotifyWarning","NotifyError","TextPrimary","TextSecondary","TitleColor","ButtonBg","ButtonHover","ButtonText" }) do
            cfg.Theme[k] = Theme[k]
        end
        pcall(Configs.Save, Configs, configName, cfg)
    end

    -- ============================================================
    -- AddTab
    -- ============================================================

    function WindowObj:AddTab(name, icon)
        local tabData = {}
        tabData.Name  = name

        local tabBtn = Utility.Button({ Name = name.."Tab", Text = (icon and (icon.."  ") or "")..name, Color = Theme.TabTextOff, BgColor = Theme.TabInactive, Font = Theme.Font, FrameSize = UDim2.new(1,-10,0,36), Parent = tabScroll })
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Utility.Corner(tabBtn, UDim.new(0, 8))
        Utility.Padding(tabBtn, 0, 0, 14, 0)

        local tabContent = Utility.Frame({ Name = name.."Content", Color = Theme.Background, Size = UDim2.new(1,0,1,0), Parent = scrollableContent })
        tabContent.Visible = false; tabContent.BackgroundTransparency = 1

        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "Scroll"; scroll.Size = UDim2.new(1,0,1,0); scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 4; scroll.ScrollBarImageColor3 = Theme.Accent
        scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent = tabContent
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.Padding = UDim.new(0, 8); listLayout.Parent = scroll
        Utility.Padding(scroll, 8, 8, 16, 16)

        local function activateTab()
            if activeTab then
                activeTab.Content.Visible = false
                Utility.Tween(activeTab.Btn, { BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.TabTextOff }, 0.15)
            end
            tabContent.Visible = true
            Utility.Tween(tabContent, { BackgroundTransparency = 0 }, 0.2)
            Utility.Tween(tabBtn,    { BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.TabText }, 0.15)
            activeTab = { Btn = tabBtn, Content = tabContent }
        end

        tabBtn.MouseButton1Click:Connect(activateTab)
        tabBtn.MouseEnter:Connect(function()
            if activeTab and activeTab.Btn ~= tabBtn then
                Utility.Tween(tabBtn, { BackgroundColor3 = Theme.ElementHover, TextColor3 = Theme.TabText }, 0.1)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab and activeTab.Btn ~= tabBtn then
                Utility.Tween(tabBtn, { BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.TabTextOff }, 0.1)
            end
        end)

        if #tabs == 0 then activateTab() end
        table.insert(tabs, tabData)

        -- Wrapper avec fade-in
        local function MakeWrapper(height)
            local wrap = Utility.Frame({ Name = "Element", Color = Theme.ElementBg, Size = UDim2.new(1,0,0,height), Parent = scroll })
            Utility.Corner(wrap)
            Utility.Stroke(wrap, Theme.ElementBorder, 1)
            wrap.BackgroundTransparency = 1; wrap.Position = UDim2.new(0,0,0,20)
            Utility.Tween(wrap, { BackgroundTransparency = 0, Position = UDim2.new(0,0,0,0) }, 0.3)
            return wrap
        end

        -- ── SECTION ──────────────────────────────────────────────────

        function tabData:AddSection(name)
            local lbl = Utility.Label({ Text = name, Color = Theme.Accent, Font = Theme.FontBold, Size = 12, FrameSize = UDim2.new(1,0,0,26), Parent = scroll })
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            Utility.Padding(lbl, 0, 0, 8, 0)
            return lbl
        end

        -- ── TOGGLE ───────────────────────────────────────────────────

        function tabData:AddToggle(opts)
            opts = opts or {}
            local name     = opts.Name     or "Toggle"
            local default  = opts.Default  or false
            local callback = opts.Callback or function() end
            local saveKey  = opts.SaveKey

            local wrap = MakeWrapper(44)
            Utility.Label({ Text = name, FrameSize = UDim2.new(1,-60,1,0), Position = UDim2.new(0,14,0,0), Parent = wrap })

            local track = Utility.Frame({ Name = "Track", Color = default and Theme.ToggleOn or Theme.ToggleOff, Size = UDim2.new(0,42,0,24), Position = UDim2.new(1,-54,0.5,-12), Parent = wrap })
            Utility.Corner(track, UDim.new(0, 12))
            local knob = Utility.Frame({ Name = "Knob", Color = Theme.ToggleKnob, Size = UDim2.new(0,18,0,18), Position = default and UDim2.new(0,22,0.5,-9) or UDim2.new(0,3,0.5,-9), Parent = track })
            Utility.Corner(knob, UDim.new(0, 9))

            local toggled = default
            local togObj  = {}

            local function setToggle(val)
                toggled = val
                Utility.Tween(track, { BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
                Utility.Tween(knob,  { Position = toggled and UDim2.new(0,22,0.5,-9) or UDim2.new(0,3,0.5,-9) }, 0.2)
                pcall(callback, toggled)
                if saveKey and configName then
                    local cfg = Configs.Load(configName)
                    cfg[saveKey] = toggled; Configs.Save(configName, cfg)
                end
            end

            if saveKey and configName and savedConfig[saveKey] ~= nil then setToggle(savedConfig[saveKey]) end

            wrap.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then setToggle(not toggled) end end)
            wrap.MouseEnter:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1) end)
            wrap.MouseLeave:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg   }, 0.1) end)

            function togObj:Set(v) setToggle(v) end
            function togObj:Get() return toggled end
            return togObj
        end

        -- ── BUTTON ───────────────────────────────────────────────────

        function tabData:AddButton(opts)
            opts = opts or {}
            local name     = opts.Name     or "Button"
            local callback = opts.Callback or function() end
            local desc     = opts.Description
            local height   = desc and 58 or 46
            local wrap     = MakeWrapper(height)

            Utility.Label({ Text = name, Font = Theme.FontBold, FrameSize = UDim2.new(1,-110,0,24), Position = UDim2.new(0,14,0, desc and 10 or 11), Parent = wrap })
            if desc then
                Utility.Label({ Text = desc, Color = Theme.TextSecondary, Size = 11, FrameSize = UDim2.new(1,-110,0,16), Position = UDim2.new(0,14,0,36), Parent = wrap })
            end

            local btn = Utility.Button({ Name = "Btn", Text = "▶", Color = Theme.ButtonText, BgColor = Theme.ButtonBg, FrameSize = UDim2.new(0,40,0,30), Position = UDim2.new(1,-50,0.5,-15), Parent = wrap })
            Utility.Corner(btn)
            Utility.Stroke(btn, Theme.ButtonBorder, 1)
            btn.MouseEnter:Connect(function() Utility.Tween(btn, { BackgroundColor3 = Theme.ButtonHover }, 0.1) end)
            btn.MouseLeave:Connect(function() Utility.Tween(btn, { BackgroundColor3 = Theme.ButtonBg    }, 0.1) end)
            btn.MouseButton1Click:Connect(function()
                Utility.Tween(btn, { BackgroundColor3 = Theme.Accent }, 0.1)
                task.delay(0.15, function() Utility.Tween(btn, { BackgroundColor3 = Theme.ButtonBg }, 0.15) end)
                pcall(callback)
            end)
            wrap.MouseEnter:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1) end)
            wrap.MouseLeave:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg   }, 0.1) end)
        end

        -- ── SLIDER ───────────────────────────────────────────────────

        function tabData:AddSlider(opts)
            opts = opts or {}
            local name     = opts.Name     or "Slider"
            local min      = opts.Min      or 0
            local max      = opts.Max      or 100
            local default  = opts.Default  or min
            local suffix   = opts.Suffix   or ""
            local callback = opts.Callback or function() end
            local saveKey  = opts.SaveKey

            local wrap = MakeWrapper(64)
            Utility.Label({ Text = name, FrameSize = UDim2.new(1,-80,0,20), Position = UDim2.new(0,14,0,8), Parent = wrap })
            local valLabel = Utility.Label({ Text = tostring(default)..suffix, Color = Theme.Accent, Font = Theme.FontBold, Align = Enum.TextXAlignment.Right, FrameSize = UDim2.new(0,70,0,20), Position = UDim2.new(1,-84,0,8), Parent = wrap })

            local trackBg = Utility.Frame({ Name = "TrackBg", Color = Theme.SliderBg, Size = UDim2.new(1,-28,0,6), Position = UDim2.new(0,14,0,44), Parent = wrap })
            Utility.Corner(trackBg, UDim.new(0, 3))
            local fill = Utility.Frame({ Name = "Fill", Color = Theme.SliderFill, Size = UDim2.new((default-min)/(max-min),0,1,0), Parent = trackBg })
            Utility.Corner(fill, UDim.new(0, 3))
            local knob = Utility.Frame({ Name = "Knob", Color = Theme.SliderKnob, Size = UDim2.new(0,16,0,16), Position = UDim2.new((default-min)/(max-min),-8,0.5,-8), Parent = trackBg })
            Utility.Corner(knob, UDim.new(0, 8))

            local currentVal = default
            local dragging   = false
            local sliderObj  = {}

            local function setValue(val)
                val = math.clamp(math.round(val), min, max)
                currentVal = val
                local pct = (val-min)/(max-min)
                Utility.Tween(fill,  { Size     = UDim2.new(pct, 0, 1, 0)     }, 0.05)
                Utility.Tween(knob,  { Position = UDim2.new(pct, -8, 0.5, -8) }, 0.05)
                valLabel.Text = tostring(val)..suffix
                pcall(callback, val)
                if saveKey and configName then
                    local cfg = Configs.Load(configName); cfg[saveKey] = val; Configs.Save(configName, cfg)
                end
            end

            if saveKey and configName and savedConfig[saveKey] ~= nil then setValue(savedConfig[saveKey]) end

            trackBg.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    setValue(min + math.clamp((Mouse.X - trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X, 0, 1)*(max-min))
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                    setValue(min + math.clamp((Mouse.X - trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X, 0, 1)*(max-min))
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)

            wrap.MouseEnter:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1) end)
            wrap.MouseLeave:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg   }, 0.1) end)

            function sliderObj:Set(v) setValue(v) end
            function sliderObj:Get() return currentVal end
            return sliderObj
        end

        -- ── DROPDOWN ─────────────────────────────────────────────────

        function tabData:AddDropdown(opts)
            opts = opts or {}
            local name     = opts.Name     or "Dropdown"
            local list     = opts.List     or {}
            local default  = opts.Default  or list[1]
            local callback = opts.Callback or function() end
            local saveKey  = opts.SaveKey

            local wrap = MakeWrapper(44)
            wrap.ClipsDescendants = false; wrap.ZIndex = 5
            Utility.Label({ Text = name, FrameSize = UDim2.new(1,-150,1,0), Position = UDim2.new(0,14,0,0), Parent = wrap })

            local dropBtn = Utility.Button({ Name = "DropBtn", Text = default or "Select...", Color = Theme.TextSecondary, BgColor = Theme.DropdownBg, FrameSize = UDim2.new(0,130,0,32), Position = UDim2.new(1,-142,0.5,-16), Parent = wrap })
            dropBtn.TextXAlignment = Enum.TextXAlignment.Left
            Utility.Corner(dropBtn); Utility.Stroke(dropBtn, Theme.ElementBorder, 1); Utility.Padding(dropBtn, 0, 0, 10, 0)
            local arrow = Utility.Label({ Text = "▼", Color = Theme.TextSecondary, Size = 10, Align = Enum.TextXAlignment.Right, FrameSize = UDim2.new(1,-8,1,0), Parent = dropBtn })

            local dropList = Utility.Frame({ Name = "DropList", Color = Theme.DropdownBg, Size = UDim2.new(0,130,0,0), Position = UDim2.new(1,-142,1,4), Parent = wrap })
            dropList.Visible = false; dropList.ZIndex = 10; dropList.ClipsDescendants = true
            Utility.Corner(dropList); Utility.Stroke(dropList, Theme.ElementBorder, 1)
            local ddLayout = Instance.new("UIListLayout"); ddLayout.SortOrder = Enum.SortOrder.LayoutOrder; ddLayout.Parent = dropList

            local open, selected = false, default
            local ddObj = {}

            local function closeDropdown()
                open = false
                Utility.Tween(dropList, { Size = UDim2.new(0,130,0,0) }, 0.2)
                task.delay(0.2, function() dropList.Visible = false end)
                Utility.Tween(arrow, { Rotation = 0 }, 0.2)
            end

            for _, item in ipairs(list) do
                local itemBtn = Utility.Button({ Name = item, Text = item, Color = Theme.TextSecondary, BgColor = Theme.DropdownItem, FrameSize = UDim2.new(1,0,0,32), Parent = dropList })
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left; Utility.Padding(itemBtn, 0, 0, 10, 0); itemBtn.ZIndex = 11
                itemBtn.MouseEnter:Connect(function() Utility.Tween(itemBtn, { BackgroundColor3 = Theme.DropdownHover }, 0.1) end)
                itemBtn.MouseLeave:Connect(function() Utility.Tween(itemBtn, { BackgroundColor3 = Theme.DropdownItem  }, 0.1) end)
                itemBtn.MouseButton1Click:Connect(function()
                    selected = item; dropBtn.Text = item; closeDropdown(); pcall(callback, item)
                    if saveKey and configName then
                        local cfg = Configs.Load(configName); cfg[saveKey] = item; Configs.Save(configName, cfg)
                    end
                end)
            end

            if saveKey and configName and savedConfig[saveKey] then
                selected = savedConfig[saveKey]; dropBtn.Text = selected; pcall(callback, selected)
            end

            dropBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    dropList.Visible = true
                    Utility.Tween(dropList, { Size = UDim2.new(0,130,0, math.min(#list*32, 160)) }, 0.2)
                    Utility.Tween(arrow, { Rotation = 180 }, 0.2)
                else closeDropdown() end
            end)
            wrap.MouseEnter:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1) end)
            wrap.MouseLeave:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg   }, 0.1) end)

            function ddObj:Set(v) selected = v; dropBtn.Text = v; pcall(callback, v) end
            function ddObj:Get() return selected end
            return ddObj
        end

        -- ── TEXTBOX ──────────────────────────────────────────────────

        function tabData:AddTextBox(opts)
            opts = opts or {}
            local name        = opts.Name        or "Input"
            local placeholder = opts.Placeholder or "Type here..."
            local default     = opts.Default     or ""
            local numeric     = opts.Numeric     or false
            local callback    = opts.Callback    or function() end
            local saveKey     = opts.SaveKey

            local wrap = MakeWrapper(44)
            Utility.Label({ Text = name, FrameSize = UDim2.new(1,-150,1,0), Position = UDim2.new(0,14,0,0), Parent = wrap })

            local inputFrame = Utility.Frame({ Name = "InputFrame", Color = Theme.DropdownBg, Size = UDim2.new(0,130,0,32), Position = UDim2.new(1,-142,0.5,-16), Parent = wrap })
            Utility.Corner(inputFrame); Utility.Stroke(inputFrame, Theme.ElementBorder, 1)
            local input = Utility.TextBox({ Text = default, Placeholder = placeholder, FrameSize = UDim2.new(1,-16,1,0), Position = UDim2.new(0,8,0,0), Parent = inputFrame })

            if saveKey and configName and savedConfig[saveKey] then input.Text = tostring(savedConfig[saveKey]) end

            input.Focused:Connect(function()
                Utility.Tween(inputFrame, { BackgroundColor3 = Theme.ElementHover }, 0.1)
                Utility.Stroke(inputFrame, Theme.Accent, 1)
            end)
            input.FocusLost:Connect(function(enter)
                Utility.Tween(inputFrame, { BackgroundColor3 = Theme.DropdownBg }, 0.1)
                Utility.Stroke(inputFrame, Theme.ElementBorder, 1)
                local txt = input.Text
                if numeric then txt = tonumber(txt) or 0; input.Text = tostring(txt) end
                pcall(callback, txt, enter)
                if saveKey and configName then
                    local cfg = Configs.Load(configName); cfg[saveKey] = txt; Configs.Save(configName, cfg)
                end
            end)

            wrap.MouseEnter:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1) end)
            wrap.MouseLeave:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg   }, 0.1) end)

            local tbObj = {}
            function tbObj:Get() return input.Text end
            function tbObj:Set(v) input.Text = tostring(v) end
            return tbObj
        end

        -- ── KEYBIND ──────────────────────────────────────────────────

        function tabData:AddKeybind(opts)
            opts = opts or {}
            local name     = opts.Name     or "Keybind"
            local default  = opts.Default  or Enum.KeyCode.F
            local callback = opts.Callback or function() end
            local saveKey  = opts.SaveKey

            local wrap = MakeWrapper(44)
            Utility.Label({ Text = name, FrameSize = UDim2.new(1,-150,1,0), Position = UDim2.new(0,14,0,0), Parent = wrap })
            local keyBtn = Utility.Button({ Name = "KeyBtn", Text = "["..default.Name.."]", Color = Theme.Accent, BgColor = Theme.DropdownBg, Font = Theme.FontBold, Size = 12, FrameSize = UDim2.new(0,90,0,32), Position = UDim2.new(1,-102,0.5,-16), Parent = wrap })
            Utility.Corner(keyBtn); Utility.Stroke(keyBtn, Theme.ElementBorder, 1)

            local currentKey = default
            local listening  = false
            local kbObj      = {}

            if saveKey and configName and savedConfig[saveKey] then
                currentKey = Enum.KeyCode[savedConfig[saveKey]] or default
                keyBtn.Text = "["..currentKey.Name.."]"
            end

            keyBtn.MouseButton1Click:Connect(function()
                listening = true; keyBtn.Text = "[...]"; keyBtn.TextColor3 = Theme.TextSecondary
            end)
            UserInputService.InputBegan:Connect(function(i, gp)
                if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false; currentKey = i.KeyCode
                    keyBtn.Text = "["..i.KeyCode.Name.."]"; keyBtn.TextColor3 = Theme.Accent
                    if saveKey and configName then
                        local cfg = Configs.Load(configName); cfg[saveKey] = i.KeyCode.Name; Configs.Save(configName, cfg)
                    end
                elseif not listening and i.KeyCode == currentKey and not gp then
                    pcall(callback, currentKey)
                end
            end)

            wrap.MouseEnter:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1) end)
            wrap.MouseLeave:Connect(function() Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg   }, 0.1) end)

            function kbObj:Get() return currentKey end
            return kbObj
        end

        -- ── COLOR PICKER ─────────────────────────────────────────────
        --   Layout dans le wrapper (height = 200) :
        --     Y=  0..43  → ligne du nom
        --     Y= 44..71  → swatches
        --     Y= 76..195 → RGB picker (container interne 120px)

        function tabData:AddColorPicker(opts)
            opts = opts or {}
            local name     = opts.Name     or "Color"
            local default  = opts.Default  or Theme.Accent
            local callback = opts.Callback or function() end
            local saveKey  = opts.SaveKey

            -- Hauteur totale = ligne nom (44) + swatches (32) + séparateur (4) + RGB (120) = 200
            local wrap = MakeWrapper(200)

            -- ── Ligne du haut : nom ──────────────────────────────────
            Utility.Label({ Text = name, Font = Theme.FontBold, FrameSize = UDim2.new(1,0,0,44), Position = UDim2.new(0,14,0,0), Parent = wrap })

            -- ── Séparateur fin ───────────────────────────────────────
            Utility.Frame({ Name = "Sep1", Color = Theme.ElementBorder, Size = UDim2.new(1,-28,0,1), Position = UDim2.new(0,14,0,44), Parent = wrap })

            -- ── Swatches ─────────────────────────────────────────────
            local swatchRow = Utility.Frame({ Name = "Swatches", Color = Color3.fromRGB(0,0,0), Size = UDim2.new(1,-28,0,32), Position = UDim2.new(0,14,0,48), Parent = wrap })
            swatchRow.BackgroundTransparency = 1
            local swatchLayout = Instance.new("UIListLayout")
            swatchLayout.FillDirection        = Enum.FillDirection.Horizontal
            swatchLayout.VerticalAlignment    = Enum.VerticalAlignment.Center
            swatchLayout.Padding              = UDim.new(0, 6)
            swatchLayout.Parent               = swatchRow

            local presets = {
                Color3.fromRGB(110, 90,  230),  -- violet (accent par défaut)
                Color3.fromRGB(210, 70,  70),   -- rouge doux
                Color3.fromRGB(70,  140, 220),  -- bleu
                Color3.fromRGB(70,  185, 100),  -- vert
                Color3.fromRGB(220, 160, 50),   -- orange/doré
                Color3.fromRGB(180, 70,  200),  -- violet rose
                Color3.fromRGB(60,  190, 185),  -- teal
                Color3.fromRGB(220, 220, 230),  -- blanc cassé
            }

            local currentColor = default
            if saveKey and configName and savedConfig[saveKey] and savedConfig[saveKey].r then
                local s = savedConfig[saveKey]
                currentColor = Color3.new(s.r, s.g, s.b)
            end

            -- Référence au conteneur RGB pour le recréer si swatch cliquée
            local rgbContainer = nil

            local function rebuildRGB(color)
                if rgbContainer then rgbContainer:Destroy() end
                local cont, _ = CreateRGBPickerContent(wrap, color, function(c)
                    currentColor = c
                    pcall(callback, c)
                    if saveKey and configName then
                        local cfg = Configs.Load(configName)
                        cfg[saveKey] = { r = c.R, g = c.G, b = c.B }
                        Configs.Save(configName, cfg)
                    end
                end)
                cont.Position = UDim2.new(0, 14, 0, 82)
                rgbContainer = cont
            end

            -- Construire les swatches
            for _, col in ipairs(presets) do
                local sw = Utility.Button({ Name = "Swatch", Text = "", BgColor = col, FrameSize = UDim2.new(0, 20, 0, 20), Parent = swatchRow })
                Utility.Corner(sw, UDim.new(0, 5))
                sw.MouseEnter:Connect(function() Utility.Tween(sw, { Size = UDim2.new(0,22,0,22) }, 0.1) end)
                sw.MouseLeave:Connect(function() Utility.Tween(sw, { Size = UDim2.new(0,20,0,20) }, 0.1) end)
                sw.MouseButton1Click:Connect(function()
                    currentColor = col
                    rebuildRGB(col)
                    pcall(callback, col)
                    if saveKey and configName then
                        local cfg = Configs.Load(configName)
                        cfg[saveKey] = { r = col.R, g = col.G, b = col.B }
                        Configs.Save(configName, cfg)
                    end
                end)
            end

            -- Séparateur avant RGB
            Utility.Frame({ Name = "Sep2", Color = Theme.ElementBorder, Size = UDim2.new(1,-28,0,1), Position = UDim2.new(0,14,0,80), Parent = wrap })

            -- Construction initiale du RGB picker
            rebuildRGB(currentColor)

            local cpObj = {}
            function cpObj:Get() return currentColor end
            function cpObj:Set(col)
                currentColor = col
                rebuildRGB(col)
                pcall(callback, col)
            end
            return cpObj
        end

        -- ── LABEL ────────────────────────────────────────────────────

        function tabData:AddLabel(text)
            local lbl = Utility.Label({ Text = text, Color = Theme.TextSecondary, Size = 12, FrameSize = UDim2.new(1,0,0,30), Parent = scroll })
            lbl.TextWrapped = true; Utility.Padding(lbl, 0, 0, 16, 0)
            local lObj = {}
            function lObj:Set(t) lbl.Text = t end
            return lObj
        end

        -- ── SEPARATOR ────────────────────────────────────────────────

        function tabData:AddSeparator()
            Utility.Frame({ Name = "Separator", Color = Theme.Border, Size = UDim2.new(1,0,0,1), Parent = scroll })
        end

        return tabData
    end

    -- Exposer Notify
    function WindowObj:Notify(opts)
        Notify(opts)
    end

    -- Réagir aux changements de thème pour la fenêtre
    OnThemeChange(function(t)
        window.BackgroundColor3       = t.Background
        topBar.BackgroundColor3       = t.TopBar
        accentLine.BackgroundColor3   = t.Accent
        logoFrame.BackgroundColor3    = t.Accent
        titleLabel.TextColor3         = t.TitleColor
        subtitleLabel.TextColor3      = t.SubtitleColor
        tabBar.BackgroundColor3       = t.TopBar
        contentArea.BackgroundColor3  = t.Background
        saveConfig()
    end)

    return WindowObj
end

NexusLib.SetTheme = UpdateTheme

return NexusLib
