--[[
    NexusLib v1.2 — UI Library for Roblox Scripts
    - Dynamic title: "Title | GameName"
    - Tab ordering: Home pinned top, system tabs pinned bottom
    - Key system with 24h timer
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ============================================================
-- CONFIG SYSTEM
-- ============================================================

local Configs      = {}
local ConfigFolder = "AetherX"

local hasFileFunctions = pcall(function()
    return isfolder and makefolder and readfile and writefile
end)

local function ensureFolder()
    if not hasFileFunctions then return false end
    pcall(function() if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end end)
    return true
end

function Configs:Load(name)
    if not name or type(name) ~= "string" then return {} end
    if not hasFileFunctions then return {} end
    ensureFolder()
    local ok, data = pcall(readfile, ConfigFolder.."/"..name..".json")
    if ok and data and data ~= "" then
        local ok2, dec = pcall(HttpService.JSONDecode, HttpService, data)
        if ok2 and dec then return dec end
    end
    return {}
end

function Configs:Save(name, data)
    if not name or type(name) ~= "string" then return end
    if not hasFileFunctions then return end
    ensureFolder()
    local ok, enc = pcall(HttpService.JSONEncode, HttpService, data)
    if ok and enc then pcall(writefile, ConfigFolder.."/"..name..".json", enc) end
end

-- ============================================================
-- KEY SYSTEM
-- ============================================================
-- Keys are stored in AetherX/keys.json
-- Format: { ["keyName"] = { expiry = unixTimestamp } }
-- AddKeyTime("keypass") adds 24 hours to the key timer

local KeySystem = {}
local KEY_FILE  = "keys"

function KeySystem:GetData()
    return Configs:Load(KEY_FILE)
end

function KeySystem:SaveData(data)
    Configs:Save(KEY_FILE, data)
end

-- Returns remaining seconds for a key (0 = expired or not found)
function KeySystem:GetRemaining(key)
    if not key then return 0 end
    local data = self:GetData()
    if not data[key] then return 0 end
    return math.max(0, data[key].expiry - os.time())
end

function KeySystem:IsValid(key)
    return self:GetRemaining(key) > 0
end

-- Adds seconds to a key (default 86400 = 24h). Creates it if needed.
function KeySystem:AddTime(key, seconds)
    seconds = seconds or 86400
    local data  = self:GetData()
    local now   = os.time()
    if not data[key] then
        data[key] = { expiry = now + seconds }
    else
        data[key].expiry = math.max(data[key].expiry, now) + seconds
    end
    self:SaveData(data)
    return data[key].expiry
end

-- Formats seconds into "Xd Xh Xm"
function KeySystem:FormatTime(secs)
    if secs <= 0 then return "Expired" end
    local d = math.floor(secs / 86400)
    local h = math.floor((secs % 86400) / 3600)
    local m = math.floor((secs % 3600) / 60)
    if d > 0 then return d.."d "..h.."h "..m.."m"
    elseif h > 0 then return h.."h "..m.."m"
    else return m.."m" end
end

-- ============================================================
-- THEME
-- ============================================================

local DefaultTheme = {
    Background    = Color3.fromRGB(18, 18, 24),
    TopBar        = Color3.fromRGB(23, 23, 32),
    Border        = Color3.fromRGB(44, 44, 62),
    Accent        = Color3.fromRGB(110, 90, 230),
    TabActive     = Color3.fromRGB(110, 90, 230),
    TabInactive   = Color3.fromRGB(28, 28, 40),
    TabText       = Color3.fromRGB(248, 248, 255),
    TabTextOff    = Color3.fromRGB(130, 130, 155),
    ElementBg     = Color3.fromRGB(24, 24, 34),
    ElementHover  = Color3.fromRGB(32, 32, 46),
    ElementBorder = Color3.fromRGB(40, 40, 58),
    TextPrimary   = Color3.fromRGB(225, 225, 240),
    TextSecondary = Color3.fromRGB(135, 135, 160),
    TitleColor    = Color3.fromRGB(235, 235, 250),
    SubtitleColor = Color3.fromRGB(130, 130, 155),
    ToggleOn      = Color3.fromRGB(110, 90, 230),
    ToggleOff     = Color3.fromRGB(42, 42, 60),
    ToggleKnob    = Color3.fromRGB(245, 245, 255),
    SliderFill    = Color3.fromRGB(110, 90, 230),
    SliderBg      = Color3.fromRGB(36, 36, 52),
    SliderKnob    = Color3.fromRGB(245, 245, 255),
    DropdownBg    = Color3.fromRGB(20, 20, 30),
    DropdownItem  = Color3.fromRGB(26, 26, 38),
    DropdownHover = Color3.fromRGB(34, 34, 50),
    ButtonBg      = Color3.fromRGB(32, 32, 44),
    ButtonHover   = Color3.fromRGB(42, 42, 58),
    ButtonBorder  = Color3.fromRGB(55, 55, 75),
    ButtonText    = Color3.fromRGB(225, 225, 240),
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
local function UpdateTheme(t)
    for k, v in pairs(t) do if Theme[k] ~= nil then Theme[k] = v end end
    for _, cb in ipairs(ThemeCallbacks) do pcall(cb, Theme) end
end
local function OnThemeChange(cb)
    table.insert(ThemeCallbacks, cb)
end

-- ============================================================
-- UTILITIES
-- ============================================================

local Utility = {}

function Utility.Tween(obj, props, dur, style, dir)
    TweenService:Create(obj, TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
end

function Utility.Corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = r or Theme.CornerRadius; c.Parent = p; return c
end

function Utility.Stroke(p, col, th)
    for _, ch in ipairs(p:GetChildren()) do if ch:IsA("UIStroke") then ch:Destroy() end end
    local s = Instance.new("UIStroke"); s.Color = col or Theme.Border; s.Thickness = th or 1; s.Parent = p; return s
end

function Utility.Padding(p, t, b, l, r)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0,t or 0); pad.PaddingBottom = UDim.new(0,b or 0)
    pad.PaddingLeft = UDim.new(0,l or 0); pad.PaddingRight = UDim.new(0,r or 0)
    pad.Parent = p; return pad
end

function Utility.Frame(p)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = p.Color or Color3.fromRGB(255,255,255)
    f.Size = p.Size or UDim2.new(1,0,0,30); f.Position = p.Position or UDim2.new(0,0,0,0)
    f.BorderSizePixel = 0; f.Name = p.Name or "Frame"
    if p.Parent then f.Parent = p.Parent end; return f
end

function Utility.Label(p)
    local l = Instance.new("TextLabel")
    l.Text = p.Text or ""; l.TextColor3 = p.Color or Theme.TextPrimary
    l.TextSize = p.Size or Theme.FontSize; l.Font = p.Font or Theme.Font
    l.BackgroundTransparency = 1; l.TextXAlignment = p.Align or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Size = p.FrameSize or UDim2.new(1,0,1,0); l.Position = p.Position or UDim2.new(0,0,0,0)
    l.Name = p.Name or "Label"; if p.Parent then l.Parent = p.Parent end; return l
end

function Utility.Button(p)
    local b = Instance.new("TextButton")
    b.Text = p.Text or ""; b.TextColor3 = p.Color or Theme.TextPrimary
    b.TextSize = p.Size or Theme.FontSize; b.Font = p.Font or Theme.Font
    b.BackgroundColor3 = p.BgColor or Color3.fromRGB(255,255,255)
    b.BorderSizePixel = 0; b.AutoButtonColor = false
    b.Size = p.FrameSize or UDim2.new(1,0,0,30); b.Position = p.Position or UDim2.new(0,0,0,0)
    b.Name = p.Name or "Button"; if p.Parent then b.Parent = p.Parent end; return b
end

function Utility.TextBox(p)
    local t = Instance.new("TextBox")
    t.Text = p.Text or ""; t.PlaceholderText = p.Placeholder or ""
    t.TextColor3 = p.Color or Theme.TextPrimary; t.PlaceholderColor3 = Theme.TextSecondary
    t.TextSize = p.Size or Theme.FontSize; t.Font = p.Font or Theme.Font
    t.BackgroundColor3 = p.BgColor or Theme.ElementBg; t.BorderSizePixel = 0
    t.ClearTextOnFocus = p.ClearOnFocus or false; t.TextXAlignment = Enum.TextXAlignment.Left
    t.Size = p.FrameSize or UDim2.new(1,0,0,30); t.Name = p.Name or "TextBox"
    if p.Parent then t.Parent = p.Parent end; return t
end

function Utility.MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, mousePos, framePos = false
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; mousePos = i.Position; framePos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then dragInput = i end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i == dragInput then
            local d = i.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset+d.X, framePos.Y.Scale, framePos.Y.Offset+d.Y)
        end
    end)
end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================

local NotificationHolder = nil

local function InitNotifications(screenGui)
    NotificationHolder = Utility.Frame({ Name="NotifHolder", Color=Color3.fromRGB(0,0,0), Size=UDim2.new(0,280,1,-12), Position=UDim2.new(1,-12,1,-12) })
    NotificationHolder.BackgroundTransparency = 1; NotificationHolder.AnchorPoint = Vector2.new(1,1)
    NotificationHolder.Parent = screenGui
    local l = Instance.new("UIListLayout"); l.VerticalAlignment=Enum.VerticalAlignment.Bottom
    l.HorizontalAlignment=Enum.HorizontalAlignment.Right; l.Padding=UDim.new(0,6)
    l.SortOrder=Enum.SortOrder.LayoutOrder; l.Parent=NotificationHolder
end

local function Notify(opts)
    if not NotificationHolder then return end
    local title=opts.Title or "Notification"; local message=opts.Message or ""
    local duration=opts.Duration or 3; local ntype=opts.Type or "Info"
    local accent=Theme.Accent
    if ntype=="Success" then accent=Theme.NotifySuccess
    elseif ntype=="Warning" then accent=Theme.NotifyWarning
    elseif ntype=="Error" then accent=Theme.NotifyError end

    local notif=Utility.Frame({Name="Notif",Color=Theme.NotifyBg,Size=UDim2.new(1,0,0,72)})
    notif.ClipsDescendants=true; Utility.Corner(notif,UDim.new(0,8)); Utility.Stroke(notif,Theme.ElementBorder,1)
    notif.Parent=NotificationHolder
    Utility.Frame({Name="Bar",Color=accent,Size=UDim2.new(0,3,1,0),Parent=notif})
    Utility.Label({Text=title,Color=Theme.TextPrimary,Font=Theme.FontBold,Size=13,FrameSize=UDim2.new(1,-20,0,18),Position=UDim2.new(0,12,0,10),Parent=notif})
    local msg=Instance.new("TextLabel"); msg.Text=message; msg.TextColor3=Theme.TextSecondary; msg.TextSize=12
    msg.Font=Theme.Font; msg.BackgroundTransparency=1; msg.TextXAlignment=Enum.TextXAlignment.Left
    msg.TextYAlignment=Enum.TextYAlignment.Top; msg.TextWrapped=true
    msg.Size=UDim2.new(1,-20,0,36); msg.Position=UDim2.new(0,12,0,30); msg.Parent=notif
    local pb=Utility.Frame({Name="PB",Color=Theme.ElementBorder,Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),Parent=notif})
    local p=Utility.Frame({Name="P",Color=accent,Size=UDim2.new(1,0,1,0),Parent=pb})
    notif.Position=UDim2.new(1,300,0,0)
    Utility.Tween(notif,{Position=UDim2.new(0,0,0,0)},0.3)
    Utility.Tween(p,{Size=UDim2.new(0,0,1,0)},duration,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
    task.delay(duration,function()
        Utility.Tween(notif,{Position=UDim2.new(1,300,0,0)},0.3)
        task.delay(0.35,function() notif:Destroy() end)
    end)
end

-- ============================================================
-- PLAYER PROFILE  (username + key timer)
-- ============================================================

local function CreatePlayerProfile(parent, keyName)
    local card=Utility.Frame({Name="PlayerProfile",Color=Theme.ElementBg,Size=UDim2.new(1,-24,0,70),Position=UDim2.new(0,12,0,12),Parent=parent})
    Utility.Corner(card,UDim.new(0,10)); Utility.Stroke(card,Theme.ElementBorder,1)

    local av=Instance.new("ImageLabel"); av.Size=UDim2.new(0,50,0,50); av.Position=UDim2.new(0,12,0.5,-25)
    av.BackgroundTransparency=1; av.Parent=card; Utility.Corner(av,UDim.new(0,12))
    av.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=150&height=150&format=png"

    Utility.Label({Text=LocalPlayer.Name,Color=Theme.TextPrimary,Font=Theme.FontBold,Size=14,FrameSize=UDim2.new(1,-80,0,22),Position=UDim2.new(0,72,0,10),Parent=card})
    local dot=Utility.Frame({Color=Theme.NotifySuccess,Size=UDim2.new(0,8,0,8),Position=UDim2.new(0,72,0,38),Parent=card}); Utility.Corner(dot,UDim.new(0,4))

    -- Key label (right side of the card)
    local rem    = keyName and KeySystem:GetRemaining(keyName) or 0
    local keyTxt = rem > 0 and KeySystem:FormatTime(rem) or "Expired key"
    local keyCol = rem > 0 and Theme.NotifySuccess or Theme.NotifyError

    local keyLabel=Utility.Label({Text=keyTxt,Color=keyCol,Size=11,Font=Theme.FontBold,Align=Enum.TextXAlignment.Right,FrameSize=UDim2.new(0,110,0,18),Position=UDim2.new(1,-122,0.5,-9),Parent=card})

    -- Live update every 60 seconds
    task.spawn(function()
        while card.Parent do
            task.wait(60)
            local r = keyName and KeySystem:GetRemaining(keyName) or 0
            keyLabel.Text       = r>0 and KeySystem:FormatTime(r) or "Expired key"
            keyLabel.TextColor3 = r>0 and Theme.NotifySuccess or Theme.NotifyError
        end
    end)

    card.Position=UDim2.new(0,12,0,-70)
    Utility.Tween(card,{Position=UDim2.new(0,12,0,12)},0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    return card, keyLabel
end

-- ============================================================
-- RGB COLOR PICKER
-- ============================================================

local function CreateRGBPickerContent(parent, currentColor, callback)
    local container=Utility.Frame({Name="RGBContainer",Color=Theme.DropdownBg,Size=UDim2.new(1,-28,0,120),Position=UDim2.new(0,14,0,0),Parent=parent})
    Utility.Corner(container,UDim.new(0,8)); Utility.Stroke(container,Theme.ElementBorder,1)
    local r,g,b=currentColor.R,currentColor.G,currentColor.B

    local prev=Utility.Frame({Name="Preview",Color=currentColor,Size=UDim2.new(0,36,0,36),Position=UDim2.new(1,-48,0,10),Parent=container})
    Utility.Corner(prev,UDim.new(0,6)); Utility.Stroke(prev,Theme.ElementBorder,1)
    local hex=Utility.Label({Text=string.format("#%02X%02X%02X",math.floor(r*255),math.floor(g*255),math.floor(b*255)),Color=Theme.TextSecondary,Size=10,Align=Enum.TextXAlignment.Center,FrameSize=UDim2.new(0,48,0,14),Position=UDim2.new(1,-52,0,50),Parent=container})

    local function upPrev()
        local nc=Color3.new(r,g,b); prev.BackgroundColor3=nc
        hex.Text=string.format("#%02X%02X%02X",math.floor(r*255),math.floor(g*255),math.floor(b*255))
        pcall(callback,nc)
    end

    local function makeChannel(lbl,col,yPos,init,idx)
        Utility.Label({Text=lbl,Color=col,Font=Theme.FontBold,Size=11,FrameSize=UDim2.new(0,14,0,18),Position=UDim2.new(0,10,0,yPos+1),Parent=container})
        local vl=Utility.Label({Text=tostring(math.floor(init*255)),Color=Theme.TextSecondary,Size=10,Align=Enum.TextXAlignment.Right,FrameSize=UDim2.new(0,26,0,18),Position=UDim2.new(1,-80,0,yPos+1),Parent=container})
        local track=Utility.Frame({Color=Theme.SliderBg,Size=UDim2.new(1,-100,0,5),Position=UDim2.new(0,28,0,yPos+7),Parent=container}); Utility.Corner(track,UDim.new(0,3))
        local fill=Utility.Frame({Color=col,Size=UDim2.new(init,0,1,0),Parent=track}); Utility.Corner(fill,UDim.new(0,3))
        local knob=Utility.Frame({Color=Color3.fromRGB(240,240,248),Size=UDim2.new(0,13,0,13),Position=UDim2.new(init,-7,0.5,-7),Parent=track}); Utility.Corner(knob,UDim.new(0,7)); Utility.Stroke(knob,col,1)
        return {track=track,fill=fill,knob=knob,vl=vl,value=init,
            update=function(self,val)
                self.value=val; self.fill.Size=UDim2.new(val,0,1,0); self.knob.Position=UDim2.new(val,-7,0.5,-7)
                self.vl.Text=tostring(math.floor(val*255))
                if idx==1 then r=val elseif idx==2 then g=val else b=val end; upPrev()
            end}
    end

    local sliders={makeChannel("R",Color3.fromRGB(210,80,80),12,r,1),makeChannel("G",Color3.fromRGB(80,185,100),42,g,2),makeChannel("B",Color3.fromRGB(80,140,220),72,b,3)}
    local drag={false,false,false}

    for i,s in ipairs(sliders) do
        s.track.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                drag[i]=true; s:update(math.clamp((Mouse.X-s.track.AbsolutePosition.X)/s.track.AbsoluteSize.X,0,1))
            end
        end)
    end
    UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
        for i,s in ipairs(sliders) do
            if drag[i] then s:update(math.clamp((Mouse.X-s.track.AbsolutePosition.X)/s.track.AbsoluteSize.X,0,1)) end
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then drag[1],drag[2],drag[3]=false,false,false end
    end)
    return container
end

-- ============================================================
-- MAIN LIBRARY
-- ============================================================

local NexusLib = {}
NexusLib.__index = NexusLib

function NexusLib:CreateWindow(opts)
    opts = opts or {}
    local scriptTitle = opts.Title    or "NexusLib"
    local gameName    = opts.GameName  -- if provided, title becomes "Title | GameName"
    local subtitle    = opts.Subtitle or "v1.2"
    local size        = opts.Size     or UDim2.new(0,580,0,520)
    local configName  = opts.ConfigName
    local keyName     = opts.KeyName   -- key identifier for the timer display

    -- "AetherX | ARX"  or just  "AetherX"
    local displayTitle = gameName and (scriptTitle.." | "..gameName) or scriptTitle

    local savedConfig = {}
    if configName then
        local ok, res = pcall(Configs.Load, Configs, configName)
        if ok and res then savedConfig = res end
    end

    local screenGui=Instance.new("ScreenGui"); screenGui.Name="NexusLib_"..scriptTitle
    screenGui.ResetOnSpawn=false; screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder=100; screenGui.Parent=LocalPlayer:WaitForChild("PlayerGui")
    InitNotifications(screenGui)

    local window=Utility.Frame({Name="Window",Color=Theme.Background,Size=size,Position=UDim2.new(0.5,-size.X.Offset/2,0.5,-size.Y.Offset/2),Parent=screenGui})
    window.ClipsDescendants=true; Utility.Corner(window,UDim.new(0,12)); Utility.Stroke(window,Theme.Border,1)
    window.Size=UDim2.new(0,0,0,0); Utility.Tween(window,{Size=size},0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

    local shadow=Utility.Frame({Name="Shadow",Color=Color3.fromRGB(0,0,0),Size=UDim2.new(1,20,1,20),Position=UDim2.new(0,-10,0,-10),Parent=window})
    shadow.BackgroundTransparency=0.65; shadow.ZIndex=0; Utility.Corner(shadow,UDim.new(0,16))

    -- Top bar
    local topBar    =Utility.Frame({Name="TopBar",   Color=Theme.TopBar,Size=UDim2.new(1,0,0,56),Parent=window})
    local accentLine=Utility.Frame({Name="Accent",   Color=Theme.Accent,Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,0,56),Parent=window})
    local logoBar   =Utility.Frame({Name="LogoBar",  Color=Theme.Accent,Size=UDim2.new(0,4,0,28),Position=UDim2.new(0,16,0.5,-14),Parent=topBar})
    Utility.Corner(logoBar,UDim.new(0,2))

    local titleLabel   =Utility.Label({Text=displayTitle,Font=Theme.FontBold,Size=17,FrameSize=UDim2.new(0,380,0,24),Position=UDim2.new(0,28,0,10),Parent=topBar})
    local subtitleLabel=Utility.Label({Text=subtitle,Color=Theme.SubtitleColor,Size=11,FrameSize=UDim2.new(0,380,0,18),Position=UDim2.new(0,28,0,34),Parent=topBar})

    local btnGroup=Utility.Frame({Name="BtnGroup",Color=Color3.fromRGB(0,0,0),Size=UDim2.new(0,80,0,34),Position=UDim2.new(1,-90,0.5,-17),Parent=topBar})
    btnGroup.BackgroundTransparency=1
    local minimized=false; local normalSize=size

    local function makeBtn(text,xOff,hoverBg,hoverText)
        local b=Utility.Button({Name=text.."Btn",Text=text,Color=Theme.TextSecondary,BgColor=Color3.fromRGB(28,28,40),FrameSize=UDim2.new(0,34,0,34),Position=UDim2.new(0,xOff,0,0),Parent=btnGroup})
        b.TextSize=text=="−" and 22 or 18; Utility.Corner(b,UDim.new(0,8))
        b.MouseEnter:Connect(function() Utility.Tween(b,{BackgroundColor3=hoverBg,TextColor3=hoverText},0.15) end)
        b.MouseLeave:Connect(function() Utility.Tween(b,{BackgroundColor3=Color3.fromRGB(28,28,40),TextColor3=Theme.TextSecondary},0.15) end)
        return b
    end
    local minBtn  =makeBtn("−",0,Theme.ElementHover,Theme.Accent)
    local closeBtn=makeBtn("✕",38,Color3.fromRGB(72,28,28),Color3.fromRGB(220,100,100))
    minBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        if minimized then normalSize=window.Size; Utility.Tween(window,{Size=UDim2.new(0,window.Size.X.Offset,0,56)},0.25)
        else Utility.Tween(window,{Size=normalSize},0.25) end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Utility.Tween(window,{Size=UDim2.new(0,window.Size.X.Offset,0,0)},0.25)
        task.delay(0.3,function() screenGui:Destroy() end)
    end)
    Utility.MakeDraggable(window,topBar)

    -- ============================================================
    -- TAB BAR — 3-zone ordering
    --
    --  ZONE A (top scroll)    : Home (LayoutOrder=0) + user tabs (1,2,3…)
    --  ZONE B (bottom pinned) : Customization(0) / Settings(1) / Info(2)
    --
    -- bottomSection height = 3 tabs × 40px + padding + separator = ~148px
    -- ============================================================

    local tabBar=Utility.Frame({Name="TabBar",Color=Theme.TopBar,Size=UDim2.new(0,160,1,-58),Position=UDim2.new(0,0,0,58),Parent=window})
    Utility.Frame({Name="Divider",Color=Theme.Border,Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),Parent=tabBar})

    -- Top scroll (Home + user tabs)
    local topScroll=Instance.new("ScrollingFrame"); topScroll.Name="TopScroll"
    topScroll.BackgroundTransparency=1; topScroll.BorderSizePixel=0
    topScroll.ScrollBarThickness=3; topScroll.ScrollBarImageColor3=Theme.Accent
    topScroll.CanvasSize=UDim2.new(0,0,0,0); topScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    topScroll.Size=UDim2.new(1,0,1,-152); topScroll.Position=UDim2.new(0,0,0,0); topScroll.Parent=tabBar
    local topList=Instance.new("UIListLayout"); topList.SortOrder=Enum.SortOrder.LayoutOrder
    topList.HorizontalAlignment=Enum.HorizontalAlignment.Center; topList.Padding=UDim.new(0,4); topList.Parent=topScroll
    Utility.Padding(topScroll,12,4,10,10)

    -- Bottom section (system tabs)
    local bottomSection=Utility.Frame({Name="BottomTabs",Color=Theme.TopBar,Size=UDim2.new(1,0,0,152),Position=UDim2.new(0,0,1,-152),Parent=tabBar})
    Utility.Frame({Name="Sep",Color=Theme.Border,Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,0),Parent=bottomSection})
    local bottomList=Instance.new("UIListLayout"); bottomList.SortOrder=Enum.SortOrder.LayoutOrder
    bottomList.HorizontalAlignment=Enum.HorizontalAlignment.Center; bottomList.Padding=UDim.new(0,4); bottomList.Parent=bottomSection
    Utility.Padding(bottomSection,8,8,10,10)

    local contentArea=Utility.Frame({Name="ContentArea",Color=Theme.Background,Size=UDim2.new(1,-160,1,-58),Position=UDim2.new(0,160,0,58),Parent=window})
    local playerProfile, keyLabel = CreatePlayerProfile(contentArea, keyName)
    local scrollableContent=Utility.Frame({Name="ScrollableContent",Color=Theme.Background,Size=UDim2.new(1,0,1,-82),Position=UDim2.new(0,0,0,82),Parent=contentArea})
    scrollableContent.BackgroundTransparency=1

    local WindowObj={}; local tabs={}; local activeTab=nil; local userTabCount=0

    local function saveConfig()
        if not configName then return end
        local cfg={Theme={}}
        for _,k in ipairs({"Accent","TabActive","ToggleOn","SliderFill","NotifySuccess","NotifyWarning","NotifyError","TextPrimary","TextSecondary","TitleColor","ButtonBg","ButtonHover","ButtonText"}) do cfg.Theme[k]=Theme[k] end
        pcall(Configs.Save,Configs,configName,cfg)
    end

    -- ── Core tab builder (used by all three AddXxxTab methods) ──

    local function buildTab(name, icon, parentContainer, layoutOrder)
        local tabBtn=Utility.Button({Name=name.."Tab",Text=(icon and (icon.."  ") or "")..name,Color=Theme.TabTextOff,BgColor=Theme.TabInactive,Font=Theme.Font,FrameSize=UDim2.new(1,-10,0,36),Parent=parentContainer})
        tabBtn.TextXAlignment=Enum.TextXAlignment.Left; tabBtn.LayoutOrder=layoutOrder
        Utility.Corner(tabBtn,UDim.new(0,8)); Utility.Padding(tabBtn,0,0,14,0)

        local tabContent=Utility.Frame({Name=name.."Content",Color=Theme.Background,Size=UDim2.new(1,0,1,0),Parent=scrollableContent})
        tabContent.Visible=false; tabContent.BackgroundTransparency=1

        local scroll=Instance.new("ScrollingFrame"); scroll.Name="Scroll"
        scroll.Size=UDim2.new(1,0,1,0); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
        scroll.ScrollBarThickness=4; scroll.ScrollBarImageColor3=Theme.Accent
        scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.Parent=tabContent
        local ll=Instance.new("UIListLayout"); ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,8); ll.Parent=scroll
        Utility.Padding(scroll,8,8,16,16)

        local function activate()
            if activeTab then
                activeTab.Content.Visible=false
                Utility.Tween(activeTab.Btn,{BackgroundColor3=Theme.TabInactive,TextColor3=Theme.TabTextOff},0.15)
            end
            tabContent.Visible=true; Utility.Tween(tabContent,{BackgroundTransparency=0},0.2)
            Utility.Tween(tabBtn,{BackgroundColor3=Theme.TabActive,TextColor3=Theme.TabText},0.15)
            activeTab={Btn=tabBtn,Content=tabContent}
        end

        tabBtn.MouseButton1Click:Connect(activate)
        tabBtn.MouseEnter:Connect(function()
            if activeTab and activeTab.Btn~=tabBtn then Utility.Tween(tabBtn,{BackgroundColor3=Theme.ElementHover,TextColor3=Theme.TabText},0.1) end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab and activeTab.Btn~=tabBtn then Utility.Tween(tabBtn,{BackgroundColor3=Theme.TabInactive,TextColor3=Theme.TabTextOff},0.1) end
        end)

        local tabData={Name=name,_activate=activate}

        local function MakeWrapper(h)
            local w=Utility.Frame({Name="Element",Color=Theme.ElementBg,Size=UDim2.new(1,0,0,h),Parent=scroll})
            Utility.Corner(w); Utility.Stroke(w,Theme.ElementBorder,1)
            w.BackgroundTransparency=1; w.Position=UDim2.new(0,0,0,20)
            Utility.Tween(w,{BackgroundTransparency=0,Position=UDim2.new(0,0,0,0)},0.3); return w
        end

        function tabData:AddSection(n)
            local l=Utility.Label({Text=n,Color=Theme.Accent,Font=Theme.FontBold,Size=12,FrameSize=UDim2.new(1,0,0,26),Parent=scroll})
            l.TextXAlignment=Enum.TextXAlignment.Left; Utility.Padding(l,0,0,8,0); return l
        end

        function tabData:AddToggle(opts)
            opts=opts or {}; local n=opts.Name or "Toggle"; local def=opts.Default or false
            local cb=opts.Callback or function()end; local sk=opts.SaveKey
            local w=MakeWrapper(44)
            Utility.Label({Text=n,FrameSize=UDim2.new(1,-60,1,0),Position=UDim2.new(0,14,0,0),Parent=w})
            local track=Utility.Frame({Color=def and Theme.ToggleOn or Theme.ToggleOff,Size=UDim2.new(0,42,0,24),Position=UDim2.new(1,-54,0.5,-12),Parent=w}); Utility.Corner(track,UDim.new(0,12))
            local knob=Utility.Frame({Color=Theme.ToggleKnob,Size=UDim2.new(0,18,0,18),Position=def and UDim2.new(0,22,0.5,-9) or UDim2.new(0,3,0.5,-9),Parent=track}); Utility.Corner(knob,UDim.new(0,9))
            local toggled=def; local obj={}
            local function set(v)
                toggled=v; Utility.Tween(track,{BackgroundColor3=toggled and Theme.ToggleOn or Theme.ToggleOff},0.2)
                Utility.Tween(knob,{Position=toggled and UDim2.new(0,22,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.2); pcall(cb,toggled)
                if sk and configName then local cfg=Configs:Load(configName); cfg[sk]=toggled; Configs:Save(configName,cfg) end
            end
            if sk and configName and savedConfig[sk]~=nil then set(savedConfig[sk]) end
            w.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then set(not toggled) end end)
            w.MouseEnter:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementHover},0.1) end)
            w.MouseLeave:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementBg},0.1) end)
            function obj:Set(v) set(v) end; function obj:Get() return toggled end; return obj
        end

        function tabData:AddButton(opts)
            opts=opts or {}; local n=opts.Name or "Button"; local cb=opts.Callback or function()end; local desc=opts.Description
            local w=MakeWrapper(desc and 58 or 46)
            Utility.Label({Text=n,Font=Theme.FontBold,FrameSize=UDim2.new(1,-110,0,24),Position=UDim2.new(0,14,0,desc and 10 or 11),Parent=w})
            if desc then Utility.Label({Text=desc,Color=Theme.TextSecondary,Size=11,FrameSize=UDim2.new(1,-110,0,16),Position=UDim2.new(0,14,0,36),Parent=w}) end
            local b=Utility.Button({Name="Btn",Text="▶",Color=Theme.ButtonText,BgColor=Theme.ButtonBg,FrameSize=UDim2.new(0,40,0,30),Position=UDim2.new(1,-50,0.5,-15),Parent=w})
            Utility.Corner(b); Utility.Stroke(b,Theme.ButtonBorder,1)
            b.MouseEnter:Connect(function() Utility.Tween(b,{BackgroundColor3=Theme.ButtonHover},0.1) end)
            b.MouseLeave:Connect(function() Utility.Tween(b,{BackgroundColor3=Theme.ButtonBg},0.1) end)
            b.MouseButton1Click:Connect(function()
                Utility.Tween(b,{BackgroundColor3=Theme.Accent},0.1)
                task.delay(0.15,function() Utility.Tween(b,{BackgroundColor3=Theme.ButtonBg},0.15) end)
                pcall(cb)
            end)
            w.MouseEnter:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementHover},0.1) end)
            w.MouseLeave:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementBg},0.1) end)
        end

        function tabData:AddSlider(opts)
            opts=opts or {}; local n=opts.Name or "Slider"; local mn=opts.Min or 0; local mx=opts.Max or 100
            local def=opts.Default or mn; local suf=opts.Suffix or ""; local cb=opts.Callback or function()end; local sk=opts.SaveKey
            local w=MakeWrapper(64)
            Utility.Label({Text=n,FrameSize=UDim2.new(1,-80,0,20),Position=UDim2.new(0,14,0,8),Parent=w})
            local vl=Utility.Label({Text=tostring(def)..suf,Color=Theme.Accent,Font=Theme.FontBold,Align=Enum.TextXAlignment.Right,FrameSize=UDim2.new(0,70,0,20),Position=UDim2.new(1,-84,0,8),Parent=w})
            local track=Utility.Frame({Color=Theme.SliderBg,Size=UDim2.new(1,-28,0,6),Position=UDim2.new(0,14,0,44),Parent=w}); Utility.Corner(track,UDim.new(0,3))
            local fill=Utility.Frame({Color=Theme.SliderFill,Size=UDim2.new((def-mn)/(mx-mn),0,1,0),Parent=track}); Utility.Corner(fill,UDim.new(0,3))
            local knob=Utility.Frame({Color=Theme.SliderKnob,Size=UDim2.new(0,16,0,16),Position=UDim2.new((def-mn)/(mx-mn),-8,0.5,-8),Parent=track}); Utility.Corner(knob,UDim.new(0,8))
            local cur=def; local drag=false; local obj={}
            local function set(v)
                v=math.clamp(math.round(v),mn,mx); cur=v; local pct=(v-mn)/(mx-mn)
                Utility.Tween(fill,{Size=UDim2.new(pct,0,1,0)},0.05); Utility.Tween(knob,{Position=UDim2.new(pct,-8,0.5,-8)},0.05)
                vl.Text=tostring(v)..suf; pcall(cb,v)
                if sk and configName then local cfg=Configs:Load(configName); cfg[sk]=v; Configs:Save(configName,cfg) end
            end
            if sk and configName and savedConfig[sk]~=nil then set(savedConfig[sk]) end
            track.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; set(mn+math.clamp((Mouse.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(mx-mn)) end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if drag and i.UserInputType==Enum.UserInputType.MouseMovement then set(mn+math.clamp((Mouse.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)*(mx-mn)) end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
            end)
            w.MouseEnter:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementHover},0.1) end)
            w.MouseLeave:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementBg},0.1) end)
            function obj:Set(v) set(v) end; function obj:Get() return cur end; return obj
        end

        function tabData:AddDropdown(opts)
            opts=opts or {}; local n=opts.Name or "Dropdown"; local list=opts.List or {}; local def=opts.Default or list[1]
            local cb=opts.Callback or function()end; local sk=opts.SaveKey
            local w=MakeWrapper(44); w.ClipsDescendants=false; w.ZIndex=5
            Utility.Label({Text=n,FrameSize=UDim2.new(1,-150,1,0),Position=UDim2.new(0,14,0,0),Parent=w})
            local db=Utility.Button({Name="DropBtn",Text=def or "Select...",Color=Theme.TextSecondary,BgColor=Theme.DropdownBg,FrameSize=UDim2.new(0,130,0,32),Position=UDim2.new(1,-142,0.5,-16),Parent=w})
            db.TextXAlignment=Enum.TextXAlignment.Left; Utility.Corner(db); Utility.Stroke(db,Theme.ElementBorder,1); Utility.Padding(db,0,0,10,0)
            local arr=Utility.Label({Text="▼",Color=Theme.TextSecondary,Size=10,Align=Enum.TextXAlignment.Right,FrameSize=UDim2.new(1,-8,1,0),Parent=db})
            local dl=Utility.Frame({Color=Theme.DropdownBg,Size=UDim2.new(0,130,0,0),Position=UDim2.new(1,-142,1,4),Parent=w})
            dl.Visible=false; dl.ZIndex=10; dl.ClipsDescendants=true; Utility.Corner(dl); Utility.Stroke(dl,Theme.ElementBorder,1)
            local dll=Instance.new("UIListLayout"); dll.SortOrder=Enum.SortOrder.LayoutOrder; dll.Parent=dl
            local open=false; local sel=def; local obj={}
            local function close()
                open=false; Utility.Tween(dl,{Size=UDim2.new(0,130,0,0)},0.2)
                task.delay(0.2,function() dl.Visible=false end); Utility.Tween(arr,{Rotation=0},0.2)
            end
            for _,item in ipairs(list) do
                local ib=Utility.Button({Name=item,Text=item,Color=Theme.TextSecondary,BgColor=Theme.DropdownItem,FrameSize=UDim2.new(1,0,0,32),Parent=dl})
                ib.TextXAlignment=Enum.TextXAlignment.Left; Utility.Padding(ib,0,0,10,0); ib.ZIndex=11
                ib.MouseEnter:Connect(function() Utility.Tween(ib,{BackgroundColor3=Theme.DropdownHover},0.1) end)
                ib.MouseLeave:Connect(function() Utility.Tween(ib,{BackgroundColor3=Theme.DropdownItem},0.1) end)
                ib.MouseButton1Click:Connect(function()
                    sel=item; db.Text=item; close(); pcall(cb,item)
                    if sk and configName then local cfg=Configs:Load(configName); cfg[sk]=item; Configs:Save(configName,cfg) end
                end)
            end
            if sk and configName and savedConfig[sk] then sel=savedConfig[sk]; db.Text=sel; pcall(cb,sel) end
            db.MouseButton1Click:Connect(function()
                open=not open
                if open then dl.Visible=true; Utility.Tween(dl,{Size=UDim2.new(0,130,0,math.min(#list*32,160))},0.2); Utility.Tween(arr,{Rotation=180},0.2)
                else close() end
            end)
            w.MouseEnter:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementHover},0.1) end)
            w.MouseLeave:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementBg},0.1) end)
            function obj:Set(v) sel=v; db.Text=v; pcall(cb,v) end; function obj:Get() return sel end; return obj
        end

        function tabData:AddTextBox(opts)
            opts=opts or {}; local n=opts.Name or "Input"; local ph=opts.Placeholder or "Type here..."
            local def=opts.Default or ""; local num=opts.Numeric or false; local cb=opts.Callback or function()end; local sk=opts.SaveKey
            local w=MakeWrapper(44)
            Utility.Label({Text=n,FrameSize=UDim2.new(1,-150,1,0),Position=UDim2.new(0,14,0,0),Parent=w})
            local frm=Utility.Frame({Color=Theme.DropdownBg,Size=UDim2.new(0,130,0,32),Position=UDim2.new(1,-142,0.5,-16),Parent=w})
            Utility.Corner(frm); Utility.Stroke(frm,Theme.ElementBorder,1)
            local inp=Utility.TextBox({Text=def,Placeholder=ph,FrameSize=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),Parent=frm})
            if sk and configName and savedConfig[sk] then inp.Text=tostring(savedConfig[sk]) end
            inp.Focused:Connect(function() Utility.Tween(frm,{BackgroundColor3=Theme.ElementHover},0.1); Utility.Stroke(frm,Theme.Accent,1) end)
            inp.FocusLost:Connect(function(e)
                Utility.Tween(frm,{BackgroundColor3=Theme.DropdownBg},0.1); Utility.Stroke(frm,Theme.ElementBorder,1)
                local t=inp.Text; if num then t=tonumber(t) or 0; inp.Text=tostring(t) end
                pcall(cb,t,e)
                if sk and configName then local cfg=Configs:Load(configName); cfg[sk]=t; Configs:Save(configName,cfg) end
            end)
            w.MouseEnter:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementHover},0.1) end)
            w.MouseLeave:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementBg},0.1) end)
            local obj={}; function obj:Get() return inp.Text end; function obj:Set(v) inp.Text=tostring(v) end; return obj
        end

        function tabData:AddKeybind(opts)
            opts=opts or {}; local n=opts.Name or "Keybind"; local def=opts.Default or Enum.KeyCode.F
            local cb=opts.Callback or function()end; local sk=opts.SaveKey
            local w=MakeWrapper(44)
            Utility.Label({Text=n,FrameSize=UDim2.new(1,-150,1,0),Position=UDim2.new(0,14,0,0),Parent=w})
            local kb=Utility.Button({Name="KeyBtn",Text="["..def.Name.."]",Color=Theme.Accent,BgColor=Theme.DropdownBg,Font=Theme.FontBold,Size=12,FrameSize=UDim2.new(0,90,0,32),Position=UDim2.new(1,-102,0.5,-16),Parent=w})
            Utility.Corner(kb); Utility.Stroke(kb,Theme.ElementBorder,1)
            local cur=def; local listening=false; local obj={}
            if sk and configName and savedConfig[sk] then cur=Enum.KeyCode[savedConfig[sk]] or def; kb.Text="["..cur.Name.."]" end
            kb.MouseButton1Click:Connect(function() listening=true; kb.Text="[...]"; kb.TextColor3=Theme.TextSecondary end)
            UserInputService.InputBegan:Connect(function(i,gp)
                if listening and i.UserInputType==Enum.UserInputType.Keyboard then
                    listening=false; cur=i.KeyCode; kb.Text="["..i.KeyCode.Name.."]"; kb.TextColor3=Theme.Accent
                    if sk and configName then local cfg=Configs:Load(configName); cfg[sk]=i.KeyCode.Name; Configs:Save(configName,cfg) end
                elseif not listening and i.KeyCode==cur and not gp then pcall(cb,cur) end
            end)
            w.MouseEnter:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementHover},0.1) end)
            w.MouseLeave:Connect(function() Utility.Tween(w,{BackgroundColor3=Theme.ElementBg},0.1) end)
            function obj:Get() return cur end; return obj
        end

        function tabData:AddColorPicker(opts)
            opts=opts or {}; local n=opts.Name or "Color"; local def=opts.Default or Theme.Accent
            local cb=opts.Callback or function()end; local sk=opts.SaveKey
            if sk and configName and savedConfig[sk] and savedConfig[sk].r then
                local s=savedConfig[sk]; def=Color3.new(s.r,s.g,s.b) end
            local w=MakeWrapper(200)
            Utility.Label({Text=n,Font=Theme.FontBold,FrameSize=UDim2.new(1,0,0,44),Position=UDim2.new(0,14,0,0),Parent=w})
            Utility.Frame({Color=Theme.ElementBorder,Size=UDim2.new(1,-28,0,1),Position=UDim2.new(0,14,0,44),Parent=w})
            local swRow=Utility.Frame({Color=Color3.fromRGB(0,0,0),Size=UDim2.new(1,-28,0,32),Position=UDim2.new(0,14,0,48),Parent=w}); swRow.BackgroundTransparency=1
            local swL=Instance.new("UIListLayout"); swL.FillDirection=Enum.FillDirection.Horizontal; swL.VerticalAlignment=Enum.VerticalAlignment.Center; swL.Padding=UDim.new(0,6); swL.Parent=swRow
            local presets={Color3.fromRGB(110,90,230),Color3.fromRGB(210,70,70),Color3.fromRGB(70,140,220),Color3.fromRGB(70,185,100),Color3.fromRGB(220,160,50),Color3.fromRGB(180,70,200),Color3.fromRGB(60,190,185),Color3.fromRGB(220,220,230)}
            local cur=def; local rgb=nil
            local function rebuild(col)
                if rgb then rgb:Destroy() end
                local c=CreateRGBPickerContent(w,col,function(nc)
                    cur=nc; pcall(cb,nc)
                    if sk and configName then local cfg=Configs:Load(configName); cfg[sk]={r=nc.R,g=nc.G,b=nc.B}; Configs:Save(configName,cfg) end
                end); c.Position=UDim2.new(0,14,0,82); rgb=c
            end
            for _,col in ipairs(presets) do
                local sw=Utility.Button({Name="Swatch",Text="",BgColor=col,FrameSize=UDim2.new(0,20,0,20),Parent=swRow}); Utility.Corner(sw,UDim.new(0,5))
                sw.MouseEnter:Connect(function() Utility.Tween(sw,{Size=UDim2.new(0,22,0,22)},0.1) end)
                sw.MouseLeave:Connect(function() Utility.Tween(sw,{Size=UDim2.new(0,20,0,20)},0.1) end)
                sw.MouseButton1Click:Connect(function()
                    cur=col; rebuild(col); pcall(cb,col)
                    if sk and configName then local cfg=Configs:Load(configName); cfg[sk]={r=col.R,g=col.G,b=col.B}; Configs:Save(configName,cfg) end
                end)
            end
            Utility.Frame({Color=Theme.ElementBorder,Size=UDim2.new(1,-28,0,1),Position=UDim2.new(0,14,0,80),Parent=w})
            rebuild(def)
            local obj={}; function obj:Get() return cur end; function obj:Set(col) cur=col; rebuild(col); pcall(cb,col) end; return obj
        end

        function tabData:AddLabel(text)
            local l=Utility.Label({Text=text,Color=Theme.TextSecondary,Size=12,FrameSize=UDim2.new(1,0,0,30),Parent=scroll})
            l.TextWrapped=true; Utility.Padding(l,0,0,16,0)
            local obj={}; function obj:Set(t) l.Text=t end; return obj
        end

        function tabData:AddSeparator()
            Utility.Frame({Name="Separator",Color=Theme.Border,Size=UDim2.new(1,0,0,1),Parent=scroll})
        end

        return tabData, activate
    end

    -- ── Home tab (always first, LayoutOrder = 0)
    function WindowObj:AddHomeTab(name, icon)
        name = name or "Home"
        local tabData, activate = buildTab(name, icon, topScroll, 0)
        if #tabs == 0 then activate() end  -- Home is the default active tab
        table.insert(tabs, 1, tabData)
        return tabData
    end

    -- ── Regular user tabs (LayoutOrder = 1, 2, 3…)
    function WindowObj:AddTab(name, icon)
        userTabCount = userTabCount + 1
        local tabData, activate = buildTab(name, icon, topScroll, userTabCount)
        -- If somehow no tab is active yet, activate this one
        if not activeTab then activate() end
        table.insert(tabs, tabData)
        return tabData
    end

    -- ── System tabs pinned at bottom (LayoutOrder matters within bottomSection)
    -- Call order: Customization=0, Settings=1, Info=2
    function WindowObj:AddSystemTab(name, icon, order)
        local tabData, _ = buildTab(name, icon, bottomSection, order or 0)
        table.insert(tabs, tabData)
        return tabData
    end

    -- ── Notify
    function WindowObj:Notify(opts) Notify(opts) end

    -- ── Key management
    -- Pass the key name (e.g. "keypass") to add 24h
    function WindowObj:AddKeyTime(key, seconds)
        local expiry = KeySystem:AddTime(key, seconds or 86400)
        if keyLabel then
            local rem = KeySystem:GetRemaining(key)
            keyLabel.Text       = KeySystem:FormatTime(rem)
            keyLabel.TextColor3 = Theme.NotifySuccess
        end
        return expiry
    end

    function WindowObj:KeyIsValid(key)
        return KeySystem:IsValid(key)
    end

    OnThemeChange(function(t)
        window.BackgroundColor3     = t.Background; topBar.BackgroundColor3      = t.TopBar
        accentLine.BackgroundColor3 = t.Accent;     logoBar.BackgroundColor3     = t.Accent
        titleLabel.TextColor3       = t.TitleColor; subtitleLabel.TextColor3     = t.SubtitleColor
        tabBar.BackgroundColor3     = t.TopBar;     contentArea.BackgroundColor3 = t.Background
        saveConfig()
    end)

    return WindowObj
end

NexusLib.SetTheme  = UpdateTheme
NexusLib.KeySystem = KeySystem

return NexusLib
