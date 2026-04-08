--[[
    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗    ██╗     ██╗██████╗
    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ██║     ██║██╔══██╗
    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ██║     ██║██████╔╝
    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ██║     ██║██╔══██╗
    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ███████╗██║██████╔╝
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚══════╝╚═╝╚═════╝

    NexusLib v1.0 — UI Library for Roblox Scripts
    A clean, modular library to build GUI panels quickly.

    USAGE:
        local NexusLib = loadstring(game:HttpGet("..."))()
        local Window = NexusLib:CreateWindow({ Title = "My Script" })
        local Tab = Window:AddTab("Main")
        Tab:AddToggle({ Name = "Auto Farm", Callback = function(v) print(v) end })
]]

-- ============================================================
-- SERVICES & CONSTANTS
-- ============================================================

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ============================================================
-- THEME
-- ============================================================

local Theme = {
    -- Window
    Background    = Color3.fromRGB(15, 15, 20),
    TopBar        = Color3.fromRGB(20, 20, 28),
    Border        = Color3.fromRGB(50, 50, 70),
    Accent        = Color3.fromRGB(100, 80, 255),   -- Purple accent
    AccentDark    = Color3.fromRGB(70, 55, 180),

    -- Tabs
    TabActive     = Color3.fromRGB(100, 80, 255),
    TabInactive   = Color3.fromRGB(30, 30, 42),
    TabText       = Color3.fromRGB(255, 255, 255),
    TabTextOff    = Color3.fromRGB(140, 140, 160),

    -- Elements
    ElementBg     = Color3.fromRGB(22, 22, 32),
    ElementHover  = Color3.fromRGB(30, 30, 45),
    ElementBorder = Color3.fromRGB(45, 45, 65),

    -- Text
    TextPrimary   = Color3.fromRGB(240, 240, 255),
    TextSecondary = Color3.fromRGB(150, 150, 175),
    TextDisabled  = Color3.fromRGB(80, 80, 100),

    -- Toggle
    ToggleOn      = Color3.fromRGB(100, 80, 255),
    ToggleOff     = Color3.fromRGB(45, 45, 65),
    ToggleKnob    = Color3.fromRGB(255, 255, 255),

    -- Slider
    SliderFill    = Color3.fromRGB(100, 80, 255),
    SliderBg      = Color3.fromRGB(40, 40, 58),
    SliderKnob    = Color3.fromRGB(255, 255, 255),

    -- Dropdown
    DropdownBg    = Color3.fromRGB(18, 18, 26),
    DropdownItem  = Color3.fromRGB(25, 25, 36),
    DropdownHover = Color3.fromRGB(35, 35, 52),

    -- Button
    ButtonBg      = Color3.fromRGB(35, 30, 70),
    ButtonHover   = Color3.fromRGB(60, 50, 120),
    ButtonBorder  = Color3.fromRGB(100, 80, 255),

    -- Notify
    NotifyBg      = Color3.fromRGB(20, 20, 30),
    NotifyBorder  = Color3.fromRGB(100, 80, 255),
    NotifySuccess = Color3.fromRGB(60, 200, 120),
    NotifyWarning = Color3.fromRGB(230, 180, 50),
    NotifyError   = Color3.fromRGB(220, 70, 70),

    -- Sizes
    CornerRadius  = UDim.new(0, 6),
    Font          = Enum.Font.GothamMedium,
    FontBold      = Enum.Font.GothamBold,
    FontSize      = 13,
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local Utility = {}

-- Tween helper
function Utility.Tween(obj, props, duration, style, dir)
    style    = style or Enum.EasingStyle.Quart
    dir      = dir or Enum.EasingDirection.Out
    duration = duration or 0.2
    local info = TweenInfo.new(duration, style, dir)
    TweenService:Create(obj, info, props):Play()
end

-- Create and style a UICorner
function Utility.Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or Theme.CornerRadius
    c.Parent = parent
    return c
end

-- Create a UIStroke
function Utility.Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color or Theme.Border
    s.Thickness = thickness or 1
    s.Parent    = parent
    return s
end

-- Create a UIPadding
function Utility.Padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent        = parent
    return p
end

-- Create base Frame
function Utility.Frame(props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = props.Color     or Color3.fromRGB(255,255,255)
    f.Size             = props.Size      or UDim2.new(1,0,0,30)
    f.Position         = props.Position  or UDim2.new(0,0,0,0)
    f.BorderSizePixel  = 0
    f.Name             = props.Name      or "Frame"
    if props.Parent then f.Parent = props.Parent end
    return f
end

-- Create TextLabel
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

-- Create TextButton
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

-- Create TextBox
function Utility.TextBox(props)
    local t = Instance.new("TextBox")
    t.Text             = props.Text       or ""
    t.PlaceholderText  = props.Placeholder or ""
    t.TextColor3       = props.Color      or Theme.TextPrimary
    t.PlaceholderColor3= Theme.TextDisabled
    t.TextSize         = props.Size       or Theme.FontSize
    t.Font             = props.Font       or Theme.Font
    t.BackgroundColor3 = props.BgColor    or Theme.ElementBg
    t.BorderSizePixel  = 0
    t.ClearTextOnFocus = props.ClearOnFocus ~= nil and props.ClearOnFocus or false
    t.TextXAlignment   = Enum.TextXAlignment.Left
    t.Size             = props.FrameSize  or UDim2.new(1,0,0,30)
    t.Name             = props.Name       or "TextBox"
    if props.Parent then t.Parent = props.Parent end
    return t
end

-- Draggable function
function Utility.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            mousePos  = input.Position
            framePos  = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================

local NotificationHolder = nil

local function InitNotifications(screenGui)
    NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.AnchorPoint = Vector2.new(1, 1)
    NotificationHolder.Position = UDim2.new(1, -12, 1, -12)
    NotificationHolder.Size = UDim2.new(0, 280, 1, -12)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.VerticalAlignment  = Enum.VerticalAlignment.Bottom
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding            = UDim.new(0, 6)
    layout.SortOrder          = Enum.SortOrder.LayoutOrder
    layout.Parent             = NotificationHolder
end

local function Notify(opts)
    if not NotificationHolder then return end

    local title    = opts.Title    or "Notification"
    local message  = opts.Message  or ""
    local duration = opts.Duration or 3
    local ntype    = opts.Type     or "Info"   -- "Info", "Success", "Warning", "Error"

    local accentColor = Theme.Accent
    if ntype == "Success" then accentColor = Theme.NotifySuccess
    elseif ntype == "Warning" then accentColor = Theme.NotifyWarning
    elseif ntype == "Error"   then accentColor = Theme.NotifyError
    end

    -- Container
    local notif = Utility.Frame({
        Name  = "Notification",
        Color = Theme.NotifyBg,
        Size  = UDim2.new(1, 0, 0, 72),
    })
    notif.ClipsDescendants = true
    Utility.Corner(notif, UDim.new(0, 8))
    Utility.Stroke(notif, Theme.ElementBorder, 1)
    notif.Parent = NotificationHolder

    -- Left accent bar
    local bar = Utility.Frame({
        Name   = "Bar",
        Color  = accentColor,
        Size   = UDim2.new(0, 3, 1, 0),
        Parent = notif,
    })
    Utility.Corner(bar, UDim.new(0, 2))

    -- Title
    Utility.Label({
        Text     = title,
        Color    = Theme.TextPrimary,
        Font     = Theme.FontBold,
        Size     = 13,
        FrameSize = UDim2.new(1, -20, 0, 18),
        Position  = UDim2.new(0, 12, 0, 10),
        Parent   = notif,
    })

    -- Message
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Text = message
    msgLabel.TextColor3 = Theme.TextSecondary
    msgLabel.TextSize   = 12
    msgLabel.Font       = Theme.Font
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    msgLabel.TextWrapped    = true
    msgLabel.Size = UDim2.new(1, -20, 0, 36)
    msgLabel.Position = UDim2.new(0, 12, 0, 30)
    msgLabel.Parent = notif

    -- Progress bar
    local progressBg = Utility.Frame({
        Name   = "ProgressBg",
        Color  = Theme.ElementBorder,
        Size   = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        Parent = notif,
    })
    local progress = Utility.Frame({
        Name   = "Progress",
        Color  = accentColor,
        Size   = UDim2.new(1, 0, 1, 0),
        Parent = progressBg,
    })

    -- Animate in
    notif.Position = UDim2.new(1, 300, 0, 0)
    Utility.Tween(notif, { Position = UDim2.new(0, 0, 0, 0) }, 0.3)

    -- Progress shrink
    Utility.Tween(progress, { Size = UDim2.new(0, 0, 1, 0) }, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    task.delay(duration, function()
        Utility.Tween(notif, { Position = UDim2.new(1, 300, 0, 0) }, 0.3)
        task.delay(0.35, function()
            notif:Destroy()
        end)
    end)
end

-- ============================================================
-- NEXUSLIB CORE
-- ============================================================

local NexusLib = {}
NexusLib.__index = NexusLib

-- ============================================================
-- WINDOW
-- ============================================================

function NexusLib:CreateWindow(opts)
    opts = opts or {}
    local title    = opts.Title    or "NexusLib"
    local subtitle = opts.Subtitle or "v1.0"
    local size     = opts.Size     or UDim2.new(0, 520, 0, 380)

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name             = "NexusLib_" .. title
    screenGui.ResetOnSpawn     = false
    screenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder     = 100
    screenGui.Parent           = LocalPlayer:WaitForChild("PlayerGui")

    InitNotifications(screenGui)

    -- Main window frame
    local window = Utility.Frame({
        Name     = "Window",
        Color    = Theme.Background,
        Size     = size,
        Position = UDim2.new(0.5, -(size.X.Offset/2), 0.5, -(size.Y.Offset/2)),
        Parent   = screenGui,
    })
    window.ClipsDescendants = true
    Utility.Corner(window, UDim.new(0, 10))
    Utility.Stroke(window, Theme.Border, 1)

    -- Drop shadow (simulated via outer frame)
    local shadow = Utility.Frame({
        Name     = "Shadow",
        Color    = Color3.fromRGB(0,0,0),
        Size     = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        Parent   = window,
    })
    shadow.BackgroundTransparency = 0.65
    shadow.ZIndex = 0
    Utility.Corner(shadow, UDim.new(0, 14))

    -- Top bar
    local topBar = Utility.Frame({
        Name   = "TopBar",
        Color  = Theme.TopBar,
        Size   = UDim2.new(1, 0, 0, 44),
        Parent = window,
    })

    -- Accent line under top bar
    local accentLine = Utility.Frame({
        Name     = "AccentLine",
        Color    = Theme.Accent,
        Size     = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 44),
        Parent   = window,
    })

    -- Logo / Title area
    local logoFrame = Utility.Frame({
        Name     = "LogoFrame",
        Color    = Theme.Accent,
        Size     = UDim2.new(0, 4, 0, 22),
        Position = UDim2.new(0, 14, 0.5, -11),
        Parent   = topBar,
    })
    Utility.Corner(logoFrame, UDim.new(0, 2))

    Utility.Label({
        Text      = title,
        Font      = Theme.FontBold,
        Size      = 15,
        FrameSize = UDim2.new(0, 200, 0, 22),
        Position  = UDim2.new(0, 24, 0.5, -11),
        Parent    = topBar,
    })

    Utility.Label({
        Text      = subtitle,
        Color     = Theme.TextSecondary,
        Size      = 11,
        FrameSize = UDim2.new(0, 100, 0, 22),
        Position  = UDim2.new(0, 24, 0.5, 9),
        Parent    = topBar,
    })

    -- Close button
    local closeBtn = Utility.Button({
        Name      = "CloseBtn",
        Text      = "✕",
        Color     = Theme.TextSecondary,
        BgColor   = Color3.fromRGB(0,0,0),
        FrameSize = UDim2.new(0, 28, 0, 28),
        Position  = UDim2.new(1, -36, 0.5, -14),
        Parent    = topBar,
    })
    closeBtn.BackgroundTransparency = 1

    closeBtn.MouseEnter:Connect(function()
        Utility.Tween(closeBtn, { TextColor3 = Color3.fromRGB(220,70,70) }, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        Utility.Tween(closeBtn, { TextColor3 = Theme.TextSecondary }, 0.15)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Utility.Tween(window, { Size = UDim2.new(0, window.Size.X.Offset, 0, 0) }, 0.25)
        task.delay(0.3, function()
            screenGui:Destroy()
        end)
    end)

    -- Minimize button
    local minimized = false
    local normalSize = size
    local minBtn = Utility.Button({
        Name      = "MinBtn",
        Text      = "─",
        Color     = Theme.TextSecondary,
        BgColor   = Color3.fromRGB(0,0,0),
        FrameSize = UDim2.new(0, 28, 0, 28),
        Position  = UDim2.new(1, -68, 0.5, -14),
        Parent    = topBar,
    })
    minBtn.BackgroundTransparency = 1

    minBtn.MouseEnter:Connect(function()
        Utility.Tween(minBtn, { TextColor3 = Theme.Accent }, 0.15)
    end)
    minBtn.MouseLeave:Connect(function()
        Utility.Tween(minBtn, { TextColor3 = Theme.TextSecondary }, 0.15)
    end)
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            normalSize = window.Size
            Utility.Tween(window, { Size = UDim2.new(0, window.Size.X.Offset, 0, 44) }, 0.25)
        else
            Utility.Tween(window, { Size = normalSize }, 0.25)
        end
    end)

    -- Make draggable
    Utility.MakeDraggable(window, topBar)

    -- Tab bar
    local tabBar = Utility.Frame({
        Name     = "TabBar",
        Color    = Theme.TopBar,
        Size     = UDim2.new(0, 130, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        Parent   = window,
    })

    local tabBarDivider = Utility.Frame({
        Name     = "Divider",
        Color    = Theme.Border,
        Size     = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Parent   = tabBar,
    })

    local tabList = Instance.new("UIListLayout")
    tabList.SortOrder          = Enum.SortOrder.LayoutOrder
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabList.Padding            = UDim.new(0, 3)
    tabList.Parent             = tabBar
    Utility.Padding(tabBar, 8, 8, 6, 6)

    -- Content area
    local contentArea = Utility.Frame({
        Name     = "ContentArea",
        Color    = Theme.Background,
        Size     = UDim2.new(1, -130, 1, -45),
        Position = UDim2.new(0, 130, 0, 45),
        Parent   = window,
    })

    -- Window object
    local WindowObj  = {}
    local tabs       = {}
    local activeTab  = nil

    function WindowObj:AddTab(name, icon)
        local tabData = {}
        tabData.Name = name

        -- Tab button
        local tabBtn = Utility.Button({
            Name      = name .. "Tab",
            Text      = (icon and (icon .. "  ") or "") .. name,
            Color     = Theme.TabTextOff,
            BgColor   = Theme.TabInactive,
            Font      = Theme.Font,
            FrameSize = UDim2.new(1, 0, 0, 32),
            Parent    = tabBar,
        })
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Utility.Corner(tabBtn, UDim.new(0, 6))
        Utility.Padding(tabBtn, 0, 0, 10, 0)

        -- Tab content frame
        local tabContent = Utility.Frame({
            Name     = name .. "Content",
            Color    = Theme.Background,
            Size     = UDim2.new(1, 0, 1, 0),
            Parent   = contentArea,
        })
        tabContent.Visible = false

        -- Scroll frame inside tab
        local scroll = Instance.new("ScrollingFrame")
        scroll.Name               = "Scroll"
        scroll.Size               = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel    = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = Theme.Accent
        scroll.CanvasSize         = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.Parent             = tabContent

        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder  = Enum.SortOrder.LayoutOrder
        listLayout.Padding    = UDim.new(0, 5)
        listLayout.Parent     = scroll
        Utility.Padding(scroll, 8, 8, 10, 10)

        -- Switch to this tab
        local function activateTab()
            if activeTab then
                activeTab.Content.Visible = false
                Utility.Tween(activeTab.Btn, {
                    BackgroundColor3 = Theme.TabInactive,
                    TextColor3 = Theme.TabTextOff,
                }, 0.15)
            end
            tabContent.Visible = true
            Utility.Tween(tabBtn, {
                BackgroundColor3 = Theme.TabActive,
                TextColor3 = Theme.TabText,
            }, 0.15)
            activeTab = { Btn = tabBtn, Content = tabContent }
        end

        tabBtn.MouseButton1Click:Connect(activateTab)
        tabBtn.MouseEnter:Connect(function()
            if activeTab and activeTab.Btn ~= tabBtn then
                Utility.Tween(tabBtn, { BackgroundColor3 = Theme.ElementHover }, 0.1)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab and activeTab.Btn ~= tabBtn then
                Utility.Tween(tabBtn, { BackgroundColor3 = Theme.TabInactive }, 0.1)
            end
        end)

        -- Auto-activate first tab
        if #tabs == 0 then
            activateTab()
        end

        table.insert(tabs, tabData)

        -- ============================================================
        -- ELEMENTS
        -- ============================================================

        -- Helper: create element wrapper
        local function MakeWrapper(height)
            local wrap = Utility.Frame({
                Name   = "Element",
                Color  = Theme.ElementBg,
                Size   = UDim2.new(1, 0, 0, height or 40),
                Parent = scroll,
            })
            Utility.Corner(wrap)
            Utility.Stroke(wrap, Theme.ElementBorder, 1)
            return wrap
        end

        -- ── SECTION LABEL ────────────────────────────────────────────

        function tabData:AddSection(name)
            local sectionLabel = Utility.Label({
                Text      = name,
                Color     = Theme.TextSecondary,
                Font      = Theme.FontBold,
                Size      = 11,
                FrameSize = UDim2.new(1, 0, 0, 18),
                Parent    = scroll,
            })
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            Utility.Padding(sectionLabel, 0, 0, 4, 0)
        end

        -- ── TOGGLE ────────────────────────────────────────────────────

        function tabData:AddToggle(opts)
            opts = opts or {}
            local name     = opts.Name     or "Toggle"
            local default  = opts.Default  or false
            local callback = opts.Callback or function() end

            local wrap = MakeWrapper(40)

            Utility.Label({
                Text      = name,
                FrameSize = UDim2.new(1, -60, 1, 0),
                Position  = UDim2.new(0, 12, 0, 0),
                Parent    = wrap,
            })

            local trackBg = Utility.Frame({
                Name     = "TrackBg",
                Color    = default and Theme.ToggleOn or Theme.ToggleOff,
                Size     = UDim2.new(0, 38, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                Parent   = wrap,
            })
            Utility.Corner(trackBg, UDim.new(0, 10))

            local knob = Utility.Frame({
                Name     = "Knob",
                Color    = Theme.ToggleKnob,
                Size     = UDim2.new(0, 14, 0, 14),
                Position = default and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
                Parent   = trackBg,
            })
            Utility.Corner(knob, UDim.new(0, 7))

            local toggled = default
            local togObj  = {}

            local function setToggle(val)
                toggled = val
                Utility.Tween(trackBg, { BackgroundColor3 = toggled and Theme.ToggleOn or Theme.ToggleOff }, 0.2)
                Utility.Tween(knob, {
                    Position = toggled and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                }, 0.2)
                pcall(callback, toggled)
            end

            wrap.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    setToggle(not toggled)
                end
            end)
            wrap.MouseEnter:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1)
            end)
            wrap.MouseLeave:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg }, 0.1)
            end)

            function togObj:Set(val) setToggle(val) end
            function togObj:Get()    return toggled  end

            return togObj
        end

        -- ── BUTTON ────────────────────────────────────────────────────

        function tabData:AddButton(opts)
            opts = opts or {}
            local name     = opts.Name     or "Button"
            local callback = opts.Callback or function() end
            local desc      = opts.Description

            local height = desc and 52 or 40
            local wrap   = MakeWrapper(height)

            Utility.Label({
                Text      = name,
                Font      = Theme.FontBold,
                FrameSize = UDim2.new(1, -110, 0, 24),
                Position  = UDim2.new(0, 12, 0, desc and 8 or 0),
                Parent    = wrap,
            })

            if desc then
                Utility.Label({
                    Text      = desc,
                    Color     = Theme.TextSecondary,
                    Size      = 11,
                    FrameSize = UDim2.new(1, -110, 0, 16),
                    Position  = UDim2.new(0, 12, 0, 30),
                    Parent    = wrap,
                })
            end

            local btn = Utility.Button({
                Name      = "Btn",
                Text      = "Execute",
                Color     = Theme.TextPrimary,
                BgColor   = Theme.ButtonBg,
                FrameSize = UDim2.new(0, 80, 0, 26),
                Position  = UDim2.new(1, -90, 0.5, -13),
                Parent    = wrap,
            })
            Utility.Corner(btn)
            Utility.Stroke(btn, Theme.ButtonBorder, 1)

            btn.MouseEnter:Connect(function()
                Utility.Tween(btn, { BackgroundColor3 = Theme.ButtonHover }, 0.1)
            end)
            btn.MouseLeave:Connect(function()
                Utility.Tween(btn, { BackgroundColor3 = Theme.ButtonBg }, 0.1)
            end)
            btn.MouseButton1Click:Connect(function()
                Utility.Tween(btn, { BackgroundColor3 = Theme.Accent }, 0.1)
                task.delay(0.15, function()
                    Utility.Tween(btn, { BackgroundColor3 = Theme.ButtonBg }, 0.15)
                end)
                pcall(callback)
            end)
            wrap.MouseEnter:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1)
            end)
            wrap.MouseLeave:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg }, 0.1)
            end)
        end

        -- ── SLIDER ────────────────────────────────────────────────────

        function tabData:AddSlider(opts)
            opts = opts or {}
            local name     = opts.Name     or "Slider"
            local min      = opts.Min      or 0
            local max      = opts.Max      or 100
            local default  = opts.Default  or min
            local suffix   = opts.Suffix   or ""
            local callback = opts.Callback or function() end

            local wrap = MakeWrapper(56)

            local nameLabel = Utility.Label({
                Text      = name,
                FrameSize = UDim2.new(1, -80, 0, 20),
                Position  = UDim2.new(0, 12, 0, 8),
                Parent    = wrap,
            })

            local valLabel = Utility.Label({
                Text      = tostring(default) .. suffix,
                Color     = Theme.Accent,
                Font      = Theme.FontBold,
                Align     = Enum.TextXAlignment.Right,
                FrameSize = UDim2.new(0, 70, 0, 20),
                Position  = UDim2.new(1, -80, 0, 8),
                Parent    = wrap,
            })

            local trackBg = Utility.Frame({
                Name     = "TrackBg",
                Color    = Theme.SliderBg,
                Size     = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 0, 38),
                Parent   = wrap,
            })
            Utility.Corner(trackBg, UDim.new(0, 3))

            local fill = Utility.Frame({
                Name   = "Fill",
                Color  = Theme.SliderFill,
                Size   = UDim2.new((default - min) / (max - min), 0, 1, 0),
                Parent = trackBg,
            })
            Utility.Corner(fill, UDim.new(0, 3))

            local knob = Utility.Frame({
                Name     = "Knob",
                Color    = Theme.SliderKnob,
                Size     = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
                Parent   = trackBg,
            })
            Utility.Corner(knob, UDim.new(0, 7))

            local sliderObj = {}
            local currentVal = default
            local dragging  = false

            local function setValue(val)
                val = math.clamp(math.round(val), min, max)
                currentVal = val
                local pct = (val - min) / (max - min)
                Utility.Tween(fill,  { Size     = UDim2.new(pct, 0, 1, 0) }, 0.05)
                Utility.Tween(knob,  { Position = UDim2.new(pct, -7, 0.5, -7) }, 0.05)
                valLabel.Text = tostring(val) .. suffix
                pcall(callback, val)
            end

            local function updateFromMouse()
                local trackPos  = trackBg.AbsolutePosition.X
                local trackSize = trackBg.AbsoluteSize.X
                local mouseX    = Mouse.X
                local pct = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
                setValue(min + pct * (max - min))
            end

            trackBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateFromMouse()
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateFromMouse()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            wrap.MouseEnter:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1)
            end)
            wrap.MouseLeave:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg }, 0.1)
            end)

            function sliderObj:Set(val) setValue(val) end
            function sliderObj:Get()   return currentVal end

            return sliderObj
        end

        -- ── DROPDOWN ─────────────────────────────────────────────────

        function tabData:AddDropdown(opts)
            opts = opts or {}
            local name     = opts.Name     or "Dropdown"
            local list     = opts.List     or {}
            local default  = opts.Default  or list[1]
            local callback = opts.Callback or function() end

            local wrap = MakeWrapper(40)
            wrap.ClipsDescendants = false
            wrap.ZIndex = 5

            Utility.Label({
                Text      = name,
                FrameSize = UDim2.new(1, -150, 1, 0),
                Position  = UDim2.new(0, 12, 0, 0),
                Parent    = wrap,
            })

            local dropBtn = Utility.Button({
                Name      = "DropBtn",
                Text      = default or "Select...",
                Color     = Theme.TextSecondary,
                BgColor   = Theme.DropdownBg,
                FrameSize = UDim2.new(0, 120, 0, 28),
                Position  = UDim2.new(1, -130, 0.5, -14),
                Parent    = wrap,
            })
            dropBtn.TextXAlignment = Enum.TextXAlignment.Left
            Utility.Corner(dropBtn)
            Utility.Stroke(dropBtn, Theme.ElementBorder, 1)
            Utility.Padding(dropBtn, 0, 0, 8, 0)

            -- Arrow icon
            local arrow = Utility.Label({
                Text      = "▾",
                Color     = Theme.TextSecondary,
                Size      = 11,
                Align     = Enum.TextXAlignment.Right,
                FrameSize = UDim2.new(1, -8, 1, 0),
                Parent    = dropBtn,
            })

            -- Dropdown list frame
            local dropList = Utility.Frame({
                Name     = "DropList",
                Color    = Theme.DropdownBg,
                Size     = UDim2.new(0, 120, 0, 0),
                Position = UDim2.new(1, -130, 1, 4),
                Parent   = wrap,
            })
            dropList.Visible         = false
            dropList.ZIndex          = 10
            dropList.ClipsDescendants = true
            Utility.Corner(dropList)
            Utility.Stroke(dropList, Theme.ElementBorder, 1)

            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Parent    = dropList

            local open    = false
            local selected = default
            local ddObj   = {}

            local function closeDropdown()
                open = false
                Utility.Tween(dropList, { Size = UDim2.new(0, 120, 0, 0) }, 0.2)
                task.delay(0.2, function()
                    dropList.Visible = false
                end)
                Utility.Tween(arrow, { Rotation = 0 }, 0.2)
            end

            -- Populate items
            for _, item in ipairs(list) do
                local itemBtn = Utility.Button({
                    Name      = item,
                    Text      = item,
                    Color     = Theme.TextSecondary,
                    BgColor   = Theme.DropdownItem,
                    FrameSize = UDim2.new(1, 0, 0, 28),
                    Parent    = dropList,
                })
                itemBtn.TextXAlignment = Enum.TextXAlignment.Left
                Utility.Padding(itemBtn, 0, 0, 8, 0)
                itemBtn.ZIndex = 11

                itemBtn.MouseEnter:Connect(function()
                    Utility.Tween(itemBtn, { BackgroundColor3 = Theme.DropdownHover }, 0.1)
                end)
                itemBtn.MouseLeave:Connect(function()
                    Utility.Tween(itemBtn, { BackgroundColor3 = Theme.DropdownItem }, 0.1)
                end)
                itemBtn.MouseButton1Click:Connect(function()
                    selected = item
                    dropBtn.Text = item
                    closeDropdown()
                    pcall(callback, item)
                end)
            end

            local itemCount = #list
            local listHeight = itemCount * 28

            dropBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    dropList.Visible = true
                    Utility.Tween(dropList, { Size = UDim2.new(0, 120, 0, math.min(listHeight, 140)) }, 0.2)
                    Utility.Tween(arrow, { Rotation = 180 }, 0.2)
                else
                    closeDropdown()
                end
            end)
            wrap.MouseEnter:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1)
            end)
            wrap.MouseLeave:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg }, 0.1)
            end)

            function ddObj:Set(val)
                selected = val
                dropBtn.Text = val
                pcall(callback, val)
            end
            function ddObj:Get() return selected end

            return ddObj
        end

        -- ── TEXTBOX ───────────────────────────────────────────────────

        function tabData:AddTextBox(opts)
            opts = opts or {}
            local name        = opts.Name        or "Input"
            local placeholder = opts.Placeholder or "Type here..."
            local default     = opts.Default     or ""
            local numeric     = opts.Numeric     or false
            local callback    = opts.Callback    or function() end

            local wrap = MakeWrapper(40)

            Utility.Label({
                Text      = name,
                FrameSize = UDim2.new(1, -150, 1, 0),
                Position  = UDim2.new(0, 12, 0, 0),
                Parent    = wrap,
            })

            local inputFrame = Utility.Frame({
                Name     = "InputFrame",
                Color    = Theme.DropdownBg,
                Size     = UDim2.new(0, 120, 0, 28),
                Position = UDim2.new(1, -130, 0.5, -14),
                Parent   = wrap,
            })
            Utility.Corner(inputFrame)
            Utility.Stroke(inputFrame, Theme.ElementBorder, 1)

            local input = Utility.TextBox({
                Text        = default,
                Placeholder = placeholder,
                FrameSize   = UDim2.new(1, -16, 1, 0),
                Position    = UDim2.new(0, 8, 0, 0),
                Parent      = inputFrame,
            })

            input.Focused:Connect(function()
                Utility.Tween(inputFrame, { BackgroundColor3 = Theme.ElementHover }, 0.1)
                Utility.Stroke(inputFrame, Theme.Accent, 1)
            end)
            input.FocusLost:Connect(function(enterPressed)
                Utility.Tween(inputFrame, { BackgroundColor3 = Theme.DropdownBg }, 0.1)
                Utility.Stroke(inputFrame, Theme.ElementBorder, 1)
                local txt = input.Text
                if numeric then
                    txt = tonumber(txt) or 0
                    input.Text = tostring(txt)
                end
                pcall(callback, txt, enterPressed)
            end)

            wrap.MouseEnter:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1)
            end)
            wrap.MouseLeave:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg }, 0.1)
            end)

            local tbObj = {}
            function tbObj:Get()    return input.Text end
            function tbObj:Set(val) input.Text = tostring(val) end
            return tbObj
        end

        -- ── KEYBIND ───────────────────────────────────────────────────

        function tabData:AddKeybind(opts)
            opts = opts or {}
            local name     = opts.Name     or "Keybind"
            local default  = opts.Default  or Enum.KeyCode.F
            local callback = opts.Callback or function() end

            local wrap = MakeWrapper(40)

            Utility.Label({
                Text      = name,
                FrameSize = UDim2.new(1, -150, 1, 0),
                Position  = UDim2.new(0, 12, 0, 0),
                Parent    = wrap,
            })

            local keyBtn = Utility.Button({
                Name      = "KeyBtn",
                Text      = "[" .. default.Name .. "]",
                Color     = Theme.Accent,
                BgColor   = Theme.DropdownBg,
                Font      = Theme.FontBold,
                Size      = 12,
                FrameSize = UDim2.new(0, 80, 0, 28),
                Position  = UDim2.new(1, -90, 0.5, -14),
                Parent    = wrap,
            })
            Utility.Corner(keyBtn)
            Utility.Stroke(keyBtn, Theme.ElementBorder, 1)

            local currentKey = default
            local listening  = false
            local kbObj      = {}

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "[...]"
                keyBtn.TextColor3 = Theme.TextSecondary
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening  = false
                    currentKey = input.KeyCode
                    keyBtn.Text = "[" .. input.KeyCode.Name .. "]"
                    keyBtn.TextColor3 = Theme.Accent
                elseif not listening and input.KeyCode == currentKey then
                    pcall(callback, currentKey)
                end
            end)

            wrap.MouseEnter:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementHover }, 0.1)
            end)
            wrap.MouseLeave:Connect(function()
                Utility.Tween(wrap, { BackgroundColor3 = Theme.ElementBg }, 0.1)
            end)

            function kbObj:Get() return currentKey end
            return kbObj
        end

        -- ── COLOR PICKER (simple) ─────────────────────────────────────

        function tabData:AddColorPicker(opts)
            opts = opts or {}
            local name     = opts.Name     or "Color"
            local default  = opts.Default  or Color3.fromRGB(255, 80, 80)
            local callback = opts.Callback or function() end

            local wrap = MakeWrapper(40)

            Utility.Label({
                Text      = name,
                FrameSize = UDim2.new(1, -150, 1, 0),
                Position  = UDim2.new(0, 12, 0, 0),
                Parent    = wrap,
            })

            local presets = {
                Color3.fromRGB(255, 80,  80),
                Color3.fromRGB(80,  180, 255),
                Color3.fromRGB(80,  230, 120),
                Color3.fromRGB(255, 200, 50),
                Color3.fromRGB(200, 80,  255),
                Color3.fromRGB(255, 255, 255),
            }

            local currentColor = default
            local cpObj = {}

            local swatchHolder = Utility.Frame({
                Name     = "Swatches",
                Color    = Color3.fromRGB(0,0,0),
                Size     = UDim2.new(0, 132, 0, 22),
                Position = UDim2.new(1, -142, 0.5, -11),
                Parent   = wrap,
            })
            swatchHolder.BackgroundTransparency = 1

            local swatchList = Instance.new("UIListLayout")
            swatchList.FillDirection = Enum.FillDirection.Horizontal
            swatchList.Padding       = UDim.new(0, 3)
            swatchList.Parent        = swatchHolder

            for _, col in ipairs(presets) do
                local sw = Utility.Button({
                    Name      = "Swatch",
                    Text      = "",
                    BgColor   = col,
                    FrameSize = UDim2.new(0, 18, 0, 18),
                    Parent    = swatchHolder,
                })
                Utility.Corner(sw, UDim.new(0, 4))
                sw.MouseButton1Click:Connect(function()
                    currentColor = col
                    pcall(callback, col)
                end)
            end

            function cpObj:Get() return currentColor end
            return cpObj
        end

        -- ── LABEL (info text) ─────────────────────────────────────────

        function tabData:AddLabel(text)
            local lbl = Utility.Label({
                Text      = text,
                Color     = Theme.TextSecondary,
                Size      = 12,
                FrameSize = UDim2.new(1, 0, 0, 26),
                Position  = UDim2.new(0, 0, 0, 0),
                Parent    = scroll,
            })
            lbl.TextWrapped = true
            Utility.Padding(lbl, 0, 0, 12, 0)

            local lObj = {}
            function lObj:Set(t) lbl.Text = t end
            return lObj
        end

        -- ── SEPARATOR ─────────────────────────────────────────────────

        function tabData:AddSeparator()
            local sep = Utility.Frame({
                Name   = "Separator",
                Color  = Theme.Border,
                Size   = UDim2.new(1, 0, 0, 1),
                Parent = scroll,
            })
        end

        return tabData
    end

    -- Expose Notify on the window
    function WindowObj:Notify(opts)
        Notify(opts)
    end

    return WindowObj
end

-- ============================================================
-- RETURN
-- ============================================================

return NexusLib
