--[[
  ⚡  G L U H F I X  v 1 0 . 0  —  FINAL ULTRA BYPASS
  Toggle: [Insert] (customizable)

  MAX FPS + LAG-FIX EDITION:
  - FPS Booster startet AUTOMATISCH beim Script-Start (max FPS sofort)
  - Alle Keybinds leer am Anfang — Spieler bindet selbst im Keybinds-Tab
  - ESP Preview komplett neu gebaut — alle Labels sichtbar
  - ESP: gecachte Frames pro Spieler, kein globales ClearAllChildren mehr
  - 1x Master RenderStep + 1x Master Heartbeat (statt ~10 separate Loops)
  - Noclip: Parts werden gecacht, kein GetDescendants() jeden Frame
  - AntiLag: einmalige Anwendung, kein Loop
  - Speed/Jump: nur apply wenn Wert abweicht
  - Features: laufen NUR wenn aktiv (echtes 0-overhead wenn OFF)
  
  ESP FIX v10.1:
  - ESP_REFRESH_RATE erhöht auf 8 (statt 3) — 60% weniger ESP-Overhead
  - Corner Box: komplett neu gezeichnet, korrekte Koordinaten ohne Drift
  - BillboardGui Update nur alle 12 frames (Health/Name/Dist) — war jeden Frame
  - Skeleton/Tracer nur alle 8 frames
  - Alle ESP-Berechnungen in task.spawn ausgelagert wenn Spieler weit entfernt
  - Pool-Size reduziert auf 40 (war 80) da Corner nur 8 Lines braucht
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local Debris           = game:GetService("Debris")
local StarterGui       = game:GetService("StarterGui")
local TeleportService  = game:GetService("TeleportService")

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera

local function getChar() return lp.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ============================================================
-- BYPASS CORE
-- ============================================================
local bypass = {}
function bypass.set(obj, prop, val)
    if not obj then return end
    pcall(function()
        if sethiddenproperty then sethiddenproperty(obj, prop, val)
        else obj[prop] = val end
    end)
    pcall(function() obj[prop] = val end)
end
function bypass.setWalkSpeed(speed)
    local hum=getHum(); local hrp=getHRP()
    if not hum or not hrp then return end
    pcall(function() hrp:SetNetworkOwner(nil) end)
    bypass.set(hum, "WalkSpeed", speed)
end
function bypass.setJumpPower(power)
    local hum=getHum(); if not hum then return end
    bypass.set(hum, "UseJumpPower", true)
    bypass.set(hum, "JumpPower", power)
end
function bypass.silentTP(hrp, cf)
    if not hrp then return end
    pcall(function() hrp:SetNetworkOwner(nil) end)
    pcall(function() hrp.CFrame = cf end)
end

-- ============================================================
-- CONFIG
-- ============================================================
local CFG = {
    toggleKey  = Enum.KeyCode.Insert,
    accentH=0.0, accentS=0.0,
    layoutMode = "sidebar",
    keybinds = {},
    fly=false,      flySpeed=80,
    noclip=false,
    speed=false,    speedMult=24,
    highJump=false, jumpPower=180,
    spinBot=false,  spinSpeed=12,
    bunnyHop=false,
    autoJump=false,
    antiAfk=false,  antiLag=false,
    infinite_jump=false,
    aimbot=false,   aimbotFOV=120,  aimbotSmooth=18,
    aimbotBone="Head", aimbotVisCheck=true,
    aimbotMouseBtn="RMB", aimbotMouseMode=true,
    antiKick=false, antiDetect=false,
    invisible=false, headless=false,
    esp=false,        espHealth=true,  espNames=true,
    espDist=true,     espChams=false,
    espCorner=true,   espSkeleton=false, espHeadDot=false,
    espBoxFull=false, espTracer=false,
    espMaxDist=600,
    espColorH=0.0,   espColorS=0.0,   espColorV=1.0,
    espLineThick=2,
    fullbright=false, noFog=false,
    crosshair=false,  crosshairStyle=1,
    crosshairColorH=0.0, crosshairSize=22,
    freezeTime=false, frozenTime=14,
    gravity=196,
    showCoords=false, showFPS=false, chatSpy=false,
    scannerRange=200, scannerAuto=false, scannerInterval=30,
    pwSaved=true,
    _origBright = Lighting.Brightness,
    _origFogEnd = Lighting.FogEnd,
    _origAmbient= Lighting.Ambient,
    _origOutdoor= Lighting.OutdoorAmbient,
}

CFG.keybinds = {}

-- ============================================================
-- SAVE / LOAD
-- ============================================================
local function encodeKB(kb)
    if not kb then return "" end
    if kb.type=="key" then
        return "key:"..tostring(kb.value):match("%.(%a+)$")
    else
        return "mouse:"..tostring(kb.value)
    end
end
local function decodeKB(s)
    if not s or s=="" then return nil end
    local t,v=s:match("^(%a+):(.+)$")
    if t=="key" then
        local ok,kc=pcall(function() return Enum.KeyCode[v] end)
        if ok and kc then return {type="key",value=kc} end
    elseif t=="mouse" then
        return {type="mouse",value=v}
    end
    return nil
end

local function saveConfig()
    pcall(function()
        local nums={"accentH","accentS","flySpeed","speedMult","jumpPower","spinSpeed",
            "aimbotFOV","aimbotSmooth","espMaxDist","espColorH","espColorS","espColorV",
            "espLineThick","crosshairStyle","crosshairColorH","crosshairSize","frozenTime",
            "gravity","scannerRange","scannerInterval","aimbotMouseBtn"}
        for _,k in ipairs(nums) do
            lp:SetAttribute("GF10_"..k, tostring(CFG[k]))
        end
        local bools={"fly","noclip","speed","highJump","spinBot","bunnyHop","autoJump",
            "antiAfk","antiLag","infinite_jump","aimbot","aimbotVisCheck","aimbotMouseMode",
            "antiKick","antiDetect","invisible","headless",
            "esp","espHealth","espNames","espDist","espChams","espCorner","espSkeleton",
            "espHeadDot","espBoxFull","espTracer","fullbright","noFog","crosshair","freezeTime",
            "showCoords","showFPS","chatSpy","scannerAuto","pwSaved"}
        for _,k in ipairs(bools) do
            lp:SetAttribute("GF10_b_"..k, CFG[k] and "1" or "0")
        end
        lp:SetAttribute("GF10_layoutMode", CFG.layoutMode)
        lp:SetAttribute("GF10_toggleKey", tostring(CFG.toggleKey):match("%.(%a+)$") or "Insert")
        for feat,kb in pairs(CFG.keybinds) do
            lp:SetAttribute("GF10_kb_"..feat, encodeKB(kb))
        end
    end)
end

local function loadConfig()
    pcall(function()
        local nums={"accentH","accentS","flySpeed","speedMult","jumpPower","spinSpeed",
            "aimbotFOV","aimbotSmooth","espMaxDist","espColorH","espColorS","espColorV",
            "espLineThick","crosshairStyle","crosshairColorH","crosshairSize","frozenTime",
            "gravity","scannerRange","scannerInterval"}
        for _,k in ipairs(nums) do
            local v=lp:GetAttribute("GF10_"..k)
            if v then CFG[k]=tonumber(v) or CFG[k] end
        end
        local strs={"aimbotMouseBtn"}
        for _,k in ipairs(strs) do
            local v=lp:GetAttribute("GF10_"..k)
            if v then CFG[k]=v end
        end
        local bools={"fly","noclip","speed","highJump","spinBot","bunnyHop","autoJump",
            "antiAfk","antiLag","infinite_jump","aimbot","aimbotVisCheck","aimbotMouseMode",
            "antiKick","antiDetect","invisible","headless",
            "esp","espHealth","espNames","espDist","espChams","espCorner","espSkeleton",
            "espHeadDot","espBoxFull","espTracer","fullbright","noFog","crosshair","freezeTime",
            "showCoords","showFPS","chatSpy","scannerAuto","pwSaved"}
        for _,k in ipairs(bools) do
            local v=lp:GetAttribute("GF10_b_"..k)
            if v then CFG[k]=(v=="1") end
        end
        local lm=lp:GetAttribute("GF10_layoutMode"); if lm then CFG.layoutMode=lm end
        local tk=lp:GetAttribute("GF10_toggleKey")
        if tk then
            local ok,kc=pcall(function() return Enum.KeyCode[tk] end)
            if ok and kc then CFG.toggleKey=kc end
        end
        local allFeats={"fly","noclip","speed","highJump","aimbot","esp","invisible","fullbright",
            "spinBot","bunnyHop","crosshair","infinite_jump","headless","antiLag","freezeTime"}
        for _,feat in ipairs(allFeats) do
            local v=lp:GetAttribute("GF10_kb_"..feat)
            if v then
                local kb=decodeKB(v)
                if kb then CFG.keybinds[feat]=kb end
            end
        end
    end)
end
loadConfig()

-- ============================================================
-- THEME
-- ============================================================
local T={}; local thCBs={}
local function rTC(fn) table.insert(thCBs,fn) end
local function refreshT()
    local h,s=CFG.accentH,CFG.accentS
    local mono=(s<.05)
    T.accent  = mono and Color3.fromRGB(230,230,230) or Color3.fromHSV(h,s,1)
    T.accent2 = mono and Color3.fromRGB(170,170,170) or Color3.fromHSV(h,s*.6,1)
    T.accDark = mono and Color3.fromRGB(28,28,28)    or Color3.fromHSV(h,s*.8,.16)
    T.accGlow = mono and Color3.fromRGB(16,16,16)    or Color3.fromHSV(h,s*.85,.12)
    T.bg      = Color3.fromRGB(6,6,8)
    T.sidebar = Color3.fromRGB(10,10,12)
    T.panel   = Color3.fromRGB(14,14,16)
    T.row     = Color3.fromRGB(19,19,22)
    T.rowHov  = Color3.fromRGB(30,30,35)
    T.border  = mono and Color3.fromRGB(42,42,48) or Color3.fromHSV(h,s*.3,.30)
    T.txt     = Color3.fromRGB(215,215,220)
    T.dim     = Color3.fromRGB(75,75,85)
    T.green   = Color3.fromRGB(50,220,100)
    T.red     = Color3.fromRGB(255,50,70)
    T.white   = Color3.fromRGB(255,255,255)
    T.orange  = Color3.fromRGB(255,140,0)
    for _,cb in ipairs(thCBs) do pcall(cb) end
end
refreshT()

-- ============================================================
-- MAX FPS BOOSTER — Startet sofort beim Script-Start
-- ============================================================
local function applyMaxFPS()
    pcall(function() if setfpscap then setfpscap(0) end end)
    pcall(function() if syn and syn.set_fps_cap then syn.set_fps_cap(0) end end)
    pcall(function() if KRNL_LOADED and setfpscap then setfpscap(0) end end)
    pcall(function() if fluxus and fluxus.set_fps_cap then fluxus.set_fps_cap(0) end end)

    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function() settings().Rendering.EagerBulkExecution = true end)

    pcall(function() Lighting.GlobalShadows = false end)
    pcall(function() Lighting.FogEnd = 1e9 end)
    pcall(function() Lighting.FogStart = 1e9 end)
    pcall(function() Lighting.Brightness = 2 end)
    for _,v in ipairs(Lighting:GetChildren()) do pcall(function()
        if v:IsA("BloomEffect") then v.Enabled=false
        elseif v:IsA("BlurEffect") then v.Enabled=false; v.Size=0
        elseif v:IsA("ColorCorrectionEffect") then v.Enabled=false
        elseif v:IsA("SunRaysEffect") then v.Enabled=false
        elseif v:IsA("DepthOfFieldEffect") then v.Enabled=false
        elseif v:IsA("Atmosphere") then
            v.Density=0; v.Haze=0; v.Glare=0; v.Offset=0
        end
    end) end

    for _,v in ipairs(workspace:GetDescendants()) do pcall(function()
        if v:IsA("ParticleEmitter") then v.Rate=0; v.Enabled=false
        elseif v:IsA("Fire") then v.Enabled=false
        elseif v:IsA("Smoke") then v.Enabled=false
        elseif v:IsA("Sparkles") then v.Enabled=false
        elseif v:IsA("Trail") then v.Enabled=false
        elseif v:IsA("Beam") then v.Enabled=false
        elseif v:IsA("SelectionBox") and v.Name~="GF_" then v:Destroy()
        elseif v:IsA("Atmosphere") then v.Density=0; v.Haze=0; v.Glare=0
        end
    end) end

    pcall(function() workspace.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01 end)
    pcall(function() workspace.StreamingEnabled = false end)

    pcall(function() collectgarbage("collect") end)
    pcall(function() collectgarbage("collect") end)

    for _,v in ipairs(workspace:GetDescendants()) do pcall(function()
        if v:IsA("Sound") then v.Volume=0; v.Playing=false end
    end) end

    for _,v in ipairs(workspace:GetDescendants()) do pcall(function()
        if v:IsA("BasePart") and v.CastShadow then v.CastShadow=false end
    end) end

    print("[GF10] ⚡ MEGA FPS Booster aktiv")
end
applyMaxFPS()
task.delay(1, applyMaxFPS)
task.delay(5, applyMaxFPS)

workspace.DescendantAdded:Connect(function(v)
    pcall(function()
        if v:IsA("ParticleEmitter") then task.wait(); v.Rate=0; v.Enabled=false
        elseif v:IsA("Fire") then task.wait(); v.Enabled=false
        elseif v:IsA("Smoke") then task.wait(); v.Enabled=false
        elseif v:IsA("Sparkles") then task.wait(); v.Enabled=false
        elseif v:IsA("Trail") then task.wait(); v.Enabled=false
        end
    end)
end)

-- ============================================================
-- GUI ROOT
-- ============================================================
if lp.PlayerGui:FindFirstChild("GF10") then lp.PlayerGui.GF10:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="GF10"; gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset=true; gui.Parent=lp.PlayerGui

local function mk(cls,props,parent)
    local o=Instance.new(cls)
    for k,v in pairs(props or {}) do pcall(function() o[k]=v end) end
    if parent then o.Parent=parent end; return o
end
local function rnd(o,r) mk("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function tw(o,t,p,es,ed)
    TweenService:Create(o,TweenInfo.new(t,es or Enum.EasingStyle.Quart,ed or Enum.EasingDirection.Out),p):Play()
end
local function pad(o,l,r,t,b)
    local p=mk("UIPadding",{},o)
    if l then p.PaddingLeft=UDim.new(0,l) end; if r then p.PaddingRight=UDim.new(0,r) end
    if t then p.PaddingTop=UDim.new(0,t) end;  if b then p.PaddingBottom=UDim.new(0,b) end
end
local function notify(ti,tx,d)
    pcall(function() StarterGui:SetCore("SendNotification",{Title=ti,Text=tx,Duration=d or 3}) end)
end

-- ============================================================
-- MAIN WINDOW  (kein Passwort — lädt sofort)
-- ============================================================
local _guiUnlocked = true

local WIN_W, WIN_H = 820, 640
local SIDEBAR_W = 160

local Win=mk("Frame",{
    Size=UDim2.new(0,WIN_W,0,WIN_H),AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,0,.5,0),BackgroundColor3=T.bg,
    BorderSizePixel=0,ClipsDescendants=false,Visible=false
},gui)
rnd(Win,18)
local winStroke=mk("UIStroke",{Color=T.accent,Thickness=1.8},Win)
rTC(function() winStroke.Color=T.accent end)
local glowF=mk("Frame",{Size=UDim2.new(1,80,1,80),Position=UDim2.new(0,-40,0,-40),
    BackgroundColor3=T.accent,BackgroundTransparency=.92,BorderSizePixel=0,ZIndex=0},Win)
rnd(glowF,40); rTC(function() glowF.BackgroundColor3=T.accent end)

local Hdr=mk("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=T.sidebar,BorderSizePixel=0},Win)
rnd(Hdr,18)
local HdrFill=mk("Frame",{Size=UDim2.new(1,0,.5,0),Position=UDim2.new(0,0,.5,0),
    BackgroundColor3=T.sidebar,BorderSizePixel=0},Hdr)
local hAccentLine=mk("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),
    BackgroundColor3=T.accent,BorderSizePixel=0},Hdr)
rTC(function() hAccentLine.BackgroundColor3=T.accent end)
mk("TextLabel",{Text="⚡",Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,10,0,6),
    BackgroundTransparency=1,TextColor3=T.white,TextSize=28,Font=Enum.Font.GothamBold},Hdr)
local hTitle=mk("TextLabel",{Text="GLUHFIX v10.0",Size=UDim2.new(0,200,0,24),
    Position=UDim2.new(0,46,0,4),BackgroundTransparency=1,TextColor3=T.white,
    TextSize=17,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},Hdr)
local hToggleDisp=mk("TextLabel",{
    Text="["..(tostring(CFG.toggleKey):match("%.(%a+)$") or "Insert").."] toggle",
    Size=UDim2.new(0,160,0,16),Position=UDim2.new(0,46,0,28),
    BackgroundTransparency=1,TextColor3=T.dim,
    TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},Hdr)
local function updateToggleDisp()
    hToggleDisp.Text="["..(tostring(CFG.toggleKey):match("%.(%a+)$") or "Insert").."] toggle"
end

local sPill=mk("Frame",{Size=UDim2.new(0,100,0,22),AnchorPoint=Vector2.new(1,.5),
    Position=UDim2.new(1,-88,.5,0),BackgroundColor3=Color3.fromRGB(6,26,14),BorderSizePixel=0},Hdr)
rnd(sPill,11); mk("UIStroke",{Color=T.green,Thickness=1,Transparency=.5},sPill)
mk("TextLabel",{Text="● BYPASSED",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    TextColor3=T.green,TextSize=10,Font=Enum.Font.GothamBold},sPill)

local layoutBtn=mk("TextButton",{Text="⊞",Size=UDim2.new(0,28,0,28),AnchorPoint=Vector2.new(1,.5),
    Position=UDim2.new(1,-58,.5,0),BackgroundColor3=T.accDark,
    TextColor3=T.accent,TextSize=16,Font=Enum.Font.GothamBold,BorderSizePixel=0},Hdr)
rnd(layoutBtn,7)
rTC(function() layoutBtn.BackgroundColor3=T.accDark; layoutBtn.TextColor3=T.accent end)

local closeBtn=mk("TextButton",{Text="✕",Size=UDim2.new(0,28,0,28),AnchorPoint=Vector2.new(1,.5),
    Position=UDim2.new(1,-12,.5,0),BackgroundColor3=Color3.fromRGB(38,6,14),
    TextColor3=T.red,TextSize=14,Font=Enum.Font.GothamBold,BorderSizePixel=0},Hdr)
rnd(closeBtn,7)
closeBtn.MouseEnter:Connect(function() tw(closeBtn,.1,{BackgroundColor3=Color3.fromRGB(80,12,24)}) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn,.1,{BackgroundColor3=Color3.fromRGB(38,6,14)}) end)

local MiniBtn=mk("TextButton",{Text="⚡",Size=UDim2.new(0,44,0,44),
    Position=UDim2.new(0,10,.5,-22),BackgroundColor3=T.accent,
    TextColor3=T.bg,TextSize=20,Font=Enum.Font.GothamBold,BorderSizePixel=0,Visible=false},gui)
rnd(MiniBtn,22); rTC(function() MiniBtn.BackgroundColor3=T.accent; MiniBtn.TextColor3=T.bg end)

local function showWin(v)
    if not _guiUnlocked then return end
    if v then
        Win.Visible=true; Win.Size=UDim2.new(0,WIN_W,0,0)
        tw(Win,.22,{Size=UDim2.new(0,WIN_W,0,WIN_H)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        MiniBtn.Visible=false
    else
        tw(Win,.18,{Size=UDim2.new(0,WIN_W,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        task.delay(.19,function() Win.Visible=false end); MiniBtn.Visible=true
    end
end
closeBtn.MouseButton1Click:Connect(function() showWin(false) end)
MiniBtn.MouseButton1Click:Connect(function() showWin(true) end)

do
    local drag,ds,sp=false
    Hdr.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;sp=Win.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds; Win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
end

-- ============================================================
-- SIDEBAR
-- ============================================================
local Sidebar=mk("Frame",{
    Size=UDim2.new(0,SIDEBAR_W,1,-50),Position=UDim2.new(0,0,0,50),
    BackgroundColor3=T.sidebar,BorderSizePixel=0
},Win)
local SBStroke=mk("UIStroke",{Color=T.border,Thickness=1},Sidebar)
rTC(function() SBStroke.Color=T.border end)
mk("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},Sidebar)
pad(Sidebar,5,5,8,8)

local ContentArea=mk("Frame",{
    Size=UDim2.new(1,-SIDEBAR_W,1,-50),Position=UDim2.new(0,SIDEBAR_W,0,50),
    BackgroundColor3=T.bg,BorderSizePixel=0,ClipsDescendants=true
},Win)

local tabScrolls={}
local activeTab=""
local sideTabBtns={}

local TABS={
    {id="Move",     icon="✈",  label="Movement",   col=Color3.fromHSV(.60,.90,1),  order=1},
    {id="Combat",   icon="⚔",  label="Combat",     col=Color3.fromHSV(.00,.90,1),  order=2},
    {id="Visual",   icon="👁",  label="Visual",     col=Color3.fromHSV(.13,.90,1),  order=3},
    {id="World",    icon="🌍",  label="World",      col=Color3.fromHSV(.34,.88,1),  order=4},
    {id="Player",   icon="👤",  label="Player",     col=Color3.fromHSV(.72,.88,1),  order=5},
    {id="Anim",     icon="🎭",  label="Animations", col=Color3.fromHSV(.55,.85,1),  order=6},
    {id="ESP",      icon="🎯",  label="ESP",        col=Color3.fromHSV(.40,.90,1),  order=7},
    {id="Scanner",  icon="📡",  label="Scanner",    col=Color3.fromHSV(.10,.82,1),  order=8},
    {id="Map",      icon="🗺",  label="Map",        col=Color3.fromHSV(.16,.82,1),  order=9},
    {id="Scripte",  icon="📜",  label="Scripts",    col=Color3.fromHSV(.50,.85,1),  order=10},
    {id="Keybinds", icon="⌨",  label="Keybinds",   col=Color3.fromHSV(.62,.70,1),  order=11},
    {id="Config",   icon="💾",  label="Config",     col=Color3.fromRGB(170,170,180), order=12},
    {id="Settings", icon="⚙",  label="Settings",   col=Color3.fromRGB(170,170,180), order=13},
}

local function makeScroll(p)
    local sf=mk("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.accent,
        CanvasSize=UDim2.new(0,0,0,0),Visible=false},p)
    rTC(function() sf.ScrollBarImageColor3=T.accent end)
    local ll=mk("UIListLayout",{Padding=UDim.new(0,5)},sf)
    pad(sf,10,14,8,10)
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+20)
    end)
    return sf
end

local function switchTab(id)
    if activeTab==id then return end; activeTab=id
    for n,b in pairs(sideTabBtns) do
        local info; for _,t in ipairs(TABS) do if t.id==n then info=t;break end end
        local on=(n==id)
        if on then
            tw(b,.15,{BackgroundColor3=info and Color3.fromRGB(
                math.floor(info.col.R*50),math.floor(info.col.G*50),math.floor(info.col.B*50)
            ) or T.accDark})
            local lf=b:FindFirstChildOfClass("Frame")
            if lf then tw(lf,.15,{BackgroundColor3=info and info.col or T.accent}) end
            local tl=b:FindFirstChildOfClass("TextLabel")
            if tl then tl.TextColor3=info and info.col or T.accent end
        else
            tw(b,.15,{BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1})
            local lf=b:FindFirstChildOfClass("Frame")
            if lf then tw(lf,.15,{BackgroundColor3=Color3.fromRGB(40,40,46)}) end
            local tl=b:FindFirstChildOfClass("TextLabel")
            if tl then tl.TextColor3=T.dim end
        end
    end
    for n,sf in pairs(tabScrolls) do
        if n==id then
            sf.Visible=true
            sf.Position=UDim2.new(.02,0,0,0)
            tw(sf,.14,{Position=UDim2.new(0,0,0,0)})
        else sf.Visible=false end
    end
end

-- ============================================================
-- TOOLTIP
-- ============================================================
local Tip=mk("Frame",{Size=UDim2.new(0,280,0,34),BackgroundColor3=Color3.fromRGB(10,10,14),
    BorderSizePixel=0,Visible=false,ZIndex=900},gui)
rnd(Tip,8); mk("UIStroke",{Color=T.border,Thickness=1},Tip)
local TipL=mk("TextLabel",{Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,7,0,0),
    BackgroundTransparency=1,TextColor3=T.txt,TextSize=11,Font=Enum.Font.Gotham,
    ZIndex=901,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},Tip)
local function tip(o,txt)
    o.MouseEnter:Connect(function() TipL.Text=txt; Tip.Visible=true end)
    o.MouseMoved:Connect(function(x,y) Tip.Position=UDim2.new(0,x+14,0,y+10) end)
    o.MouseLeave:Connect(function() Tip.Visible=false end)
end

-- ============================================================
-- WIDGET BUILDERS
-- ============================================================
local function sec(tab,title)
    local f=mk("Frame",{Size=UDim2.new(1,0,0,26),BackgroundColor3=T.accDark,BorderSizePixel=0},tabScrolls[tab])
    rnd(f,7)
    local l=mk("TextLabel",{Text="  ▸  "..title:upper(),Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,TextColor3=T.accent2,TextSize=10,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},f)
    rTC(function() l.TextColor3=T.accent2 end)
    return f
end

local function tog(tab,label,key,tipTxt,cb)
    local row=mk("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=T.row,BorderSizePixel=0},tabScrolls[tab])
    rnd(row,10)
    local rowStroke=mk("UIStroke",{Color=Color3.fromRGB(24,24,28),Thickness=1},row)
    local hb=mk("TextButton",{Size=UDim2.new(1,-70,1,0),BackgroundTransparency=1,Text="",ZIndex=3},row)
    hb.MouseEnter:Connect(function() tw(row,.1,{BackgroundColor3=T.rowHov}); rowStroke.Color=T.border end)
    hb.MouseLeave:Connect(function() tw(row,.1,{BackgroundColor3=T.row}); rowStroke.Color=Color3.fromRGB(24,24,28) end)
    local lbl=mk("TextLabel",{Text=label,Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,13,0,0),
        BackgroundTransparency=1,TextColor3=T.txt,TextSize=12,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},row)
    local swBg=mk("Frame",{Size=UDim2.new(0,50,0,26),AnchorPoint=Vector2.new(1,.5),
        Position=UDim2.new(1,-13,.5,0),BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0,ZIndex=2},row)
    rnd(swBg,13)
    local knob=mk("Frame",{Size=UDim2.new(0,20,0,20),AnchorPoint=Vector2.new(0,.5),
        Position=UDim2.new(0,3,.5,0),BackgroundColor3=Color3.fromRGB(60,60,70),BorderSizePixel=0,ZIndex=3},swBg)
    rnd(knob,10)
    local function refresh()
        local on=CFG[key]
        tw(knob,.18,{Position=on and UDim2.new(1,-23,.5,0) or UDim2.new(0,3,.5,0),
            BackgroundColor3=on and T.accent or Color3.fromRGB(60,60,70)})
        tw(swBg,.18,{BackgroundColor3=on and T.accDark or Color3.fromRGB(20,20,24)})
        local s=swBg:FindFirstChildOfClass("UIStroke")
        if on then if not s then mk("UIStroke",{Color=T.accent,Thickness=1.5},swBg) end
        else if s then s:Destroy() end end
        lbl.TextColor3=on and T.accent or T.txt
    end
    rTC(function()
        knob.BackgroundColor3=CFG[key] and T.accent or Color3.fromRGB(60,60,70)
        swBg.BackgroundColor3=CFG[key] and T.accDark or Color3.fromRGB(20,20,24)
        lbl.TextColor3=CFG[key] and T.accent or T.txt
    end)
    hb.MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]; refresh()
        tw(row,.05,{Size=UDim2.new(1,-4,0,42)}); task.delay(.06,function() tw(row,.09,{Size=UDim2.new(1,0,0,46)}) end)
        if cb then pcall(function() cb(CFG[key]) end) end; saveConfig()
    end)
    if tipTxt then tip(row,tipTxt) end; refresh()
    return row,refresh
end

local function sld(tab,label,minV,maxV,defV,step,tipTxt,cb)
    step=step or 1
    local row=mk("Frame",{Size=UDim2.new(1,0,0,60),BackgroundColor3=T.row,BorderSizePixel=0},tabScrolls[tab])
    rnd(row,10); mk("UIStroke",{Color=Color3.fromRGB(24,24,28),Thickness=1},row)
    local lbl=mk("TextLabel",{Text=label.."   "..defV,Size=UDim2.new(1,-14,0,24),
        Position=UDim2.new(0,13,0,4),BackgroundTransparency=1,TextColor3=T.txt,
        TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},row)
    local track=mk("Frame",{Size=UDim2.new(1,-26,0,5),Position=UDim2.new(0,13,0,38),
        BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},row)
    rnd(track,3)
    local fill=mk("Frame",{Size=UDim2.new((defV-minV)/(maxV-minV),0,1,0),
        BackgroundColor3=T.accent,BorderSizePixel=0},track)
    rnd(fill,3); rTC(function() fill.BackgroundColor3=T.accent end)
    local knob=mk("Frame",{Size=UDim2.new(0,14,0,14),AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new((defV-minV)/(maxV-minV),0,.5,0),BackgroundColor3=T.white,BorderSizePixel=0},track)
    rnd(knob,7)
    local dragging=false
    local function update(px)
        local rel=math.clamp((px-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val=math.clamp(math.floor((minV+rel*(maxV-minV))/step+.5)*step,minV,maxV)
        local fr=(val-minV)/(maxV-minV)
        fill.Size=UDim2.new(fr,0,1,0); knob.Position=UDim2.new(fr,0,.5,0)
        lbl.Text=label.."   "..val
        if cb then pcall(function() cb(val) end) end; saveConfig()
    end
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; tw(knob,.1,{Size=UDim2.new(0,18,0,18)}) end end)
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; update(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; tw(knob,.1,{Size=UDim2.new(0,14,0,14)}) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
    if tipTxt then tip(row,tipTxt) end; return lbl
end

local function btn(tab,label,tipTxt,cb)
    local b=mk("TextButton",{Size=UDim2.new(1,0,0,40),BackgroundColor3=T.row,
        TextColor3=T.txt,TextSize=12,Text=label,Font=Enum.Font.GothamBold,BorderSizePixel=0},tabScrolls[tab])
    rnd(b,10); local bs=mk("UIStroke",{Color=T.border,Thickness=1.2},b)
    rTC(function() b.BackgroundColor3=T.row; bs.Color=T.border end)
    b.MouseEnter:Connect(function()
        tw(b,.1,{BackgroundColor3=T.rowHov}); bs.Color=T.accent; bs.Thickness=1.8; b.TextColor3=T.white
    end)
    b.MouseLeave:Connect(function()
        tw(b,.1,{BackgroundColor3=T.row}); bs.Color=T.border; bs.Thickness=1.2; b.TextColor3=T.txt
    end)
    b.MouseButton1Click:Connect(function()
        tw(b,.05,{Size=UDim2.new(1,-6,0,36)}); task.delay(.06,function() tw(b,.09,{Size=UDim2.new(1,0,0,40)}) end)
        if cb then pcall(cb) end
    end)
    if tipTxt then tip(b,tipTxt) end; return b
end

local function note(tab,txt)
    mk("TextLabel",{Text="  ↳  "..txt,Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,
        TextColor3=T.dim,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},tabScrolls[tab])
end

local function playerPopup(title,onPick)
    local plrs=Players:GetPlayers()
    local ph=math.min(60+#plrs*38,420)
    local pop=mk("Frame",{Size=UDim2.new(0,280,0,ph),AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new(.5,0,.6,0),BackgroundColor3=T.panel,BorderSizePixel=0,ZIndex=200,BackgroundTransparency=1},gui)
    rnd(pop,14); mk("UIStroke",{Color=T.accent,Thickness=2,ZIndex=201},pop)
    tw(pop,.22,{BackgroundTransparency=0,Position=UDim2.new(.5,0,.5,0)},Enum.EasingStyle.Back)
    mk("TextLabel",{Text=title,Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,
        TextColor3=T.white,TextSize=14,Font=Enum.Font.GothamBold,ZIndex=201},pop)
    local cl=mk("TextButton",{Text="✕",Size=UDim2.new(0,26,0,26),AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-8,0,8),BackgroundColor3=Color3.fromRGB(38,6,14),
        TextColor3=T.red,TextSize=11,Font=Enum.Font.GothamBold,BorderSizePixel=0,ZIndex=202},pop)
    rnd(cl,7)
    cl.MouseButton1Click:Connect(function()
        tw(pop,.14,{BackgroundTransparency=1}); task.delay(.15,function() pop:Destroy() end)
    end)
    local ll=mk("UIListLayout",{Padding=UDim.new(0,3)},pop); pad(pop,8,8,44,8)
    for _,p in ipairs(plrs) do
        if p~=lp then
            local pb=mk("TextButton",{Size=UDim2.new(1,0,0,34),BackgroundColor3=T.accGlow,
                TextColor3=T.txt,Text="  "..p.Name,TextSize=12,Font=Enum.Font.GothamBold,
                BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},pop)
            rnd(pb,9)
            pb.MouseEnter:Connect(function() tw(pb,.1,{BackgroundColor3=T.accent}); pb.TextColor3=Color3.fromRGB(0,0,0) end)
            pb.MouseLeave:Connect(function() tw(pb,.1,{BackgroundColor3=T.accGlow}); pb.TextColor3=T.txt end)
            pb.MouseButton1Click:Connect(function()
                tw(pop,.14,{BackgroundTransparency=1}); task.delay(.15,function() pop:Destroy() end); onPick(p)
            end)
        end
    end
end

-- ============================================================
-- KEYBIND SYSTEM
-- ============================================================
local function kbWidget(tab, featKey, label)
    local row=mk("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=T.row,BorderSizePixel=0},tabScrolls[tab])
    rnd(row,10); mk("UIStroke",{Color=Color3.fromRGB(24,24,28),Thickness=1},row)
    mk("TextLabel",{Text=label,Size=UDim2.new(.55,0,1,0),Position=UDim2.new(0,13,0,0),
        BackgroundTransparency=1,TextColor3=T.txt,TextSize=12,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},row)
    local kb=CFG.keybinds[featKey]
    local function kbDisplay()
        if not kb then return "NONE" end
        if kb.type=="key" then return tostring(kb.value):match("%.(%a+)$") or "?" end
        return kb.value
    end
    local pill=mk("Frame",{Size=UDim2.new(0,80,0,28),AnchorPoint=Vector2.new(1,.5),
        Position=UDim2.new(1,-13,.5,0),BackgroundColor3=T.accDark,BorderSizePixel=0,ZIndex=3},row)
    rnd(pill,8); mk("UIStroke",{Color=T.border,Thickness=1.2},pill)
    local pillTxt=mk("TextLabel",{Text=kbDisplay(),Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,TextColor3=T.accent,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=4},pill)
    rTC(function() pillTxt.TextColor3=T.accent end)
    local listening=false
    local hitBtn=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},pill)
    hitBtn.MouseButton1Click:Connect(function()
        if listening then return end; listening=true
        pillTxt.Text="..."; pillTxt.TextColor3=T.orange
        local kconn
        kconn=UserInputService.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            local ut=inp.UserInputType
            if ut==Enum.UserInputType.Keyboard then
                CFG.keybinds[featKey]={type="key",value=inp.KeyCode}
                kb=CFG.keybinds[featKey]
                pillTxt.Text=kbDisplay(); pillTxt.TextColor3=T.accent
                listening=false; kconn:Disconnect(); saveConfig()
            elseif ut==Enum.UserInputType.MouseButton1 then
                CFG.keybinds[featKey]={type="mouse",value="LMB"}
                kb=CFG.keybinds[featKey]
                pillTxt.Text="LMB"; pillTxt.TextColor3=T.accent
                listening=false; kconn:Disconnect(); saveConfig()
            elseif ut==Enum.UserInputType.MouseButton2 then
                CFG.keybinds[featKey]={type="mouse",value="RMB"}
                kb=CFG.keybinds[featKey]
                pillTxt.Text="RMB"; pillTxt.TextColor3=T.accent
                listening=false; kconn:Disconnect(); saveConfig()
            end
        end)
    end)
    hitBtn.MouseButton2Click:Connect(function()
        CFG.keybinds[featKey]=nil; kb=nil
        pillTxt.Text="NONE"; pillTxt.TextColor3=T.dim; saveConfig()
    end)
    return row
end

local mouseHeld={LMB=false, RMB=false}
UserInputService.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then mouseHeld.LMB=true end
    if inp.UserInputType==Enum.UserInputType.MouseButton2 then mouseHeld.RMB=true end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then mouseHeld.LMB=false end
    if inp.UserInputType==Enum.UserInputType.MouseButton2 then mouseHeld.RMB=false end
end)

local function isKbHeld(featKey)
    local kb=CFG.keybinds[featKey]
    if not kb then
        if featKey=="aimbot" then return mouseHeld.RMB end
        return false
    end
    if kb.type=="key" then return UserInputService:IsKeyDown(kb.value)
    elseif kb.type=="mouse" then return mouseHeld[kb.value] or false end
    return false
end

-- ============================================================
-- BUILD SIDEBAR TABS
-- ============================================================
for _,t in ipairs(TABS) do
    tabScrolls[t.id]=makeScroll(ContentArea)
    local b=mk("Frame",{
        Size=UDim2.new(1,-10,0,38),BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=t.order
    },Sidebar)
    rnd(b,9)
    local indBar=mk("Frame",{Size=UDim2.new(0,3,0,22),AnchorPoint=Vector2.new(0,.5),
        Position=UDim2.new(0,0,.5,0),BackgroundColor3=Color3.fromRGB(40,40,46),BorderSizePixel=0},b)
    rnd(indBar,2)
    mk("TextLabel",{Text=t.icon,Size=UDim2.new(0,28,1,0),Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,TextColor3=T.dim,TextSize=16,Font=Enum.Font.GothamBold,ZIndex=2},b)
    local lbl=mk("TextLabel",{Text=t.label,Size=UDim2.new(1,-40,1,0),Position=UDim2.new(0,36,0,0),
        BackgroundTransparency=1,TextColor3=T.dim,TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},b)
    local hit=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=3},b)
    hit.MouseEnter:Connect(function()
        if activeTab~=t.id then tw(b,.1,{BackgroundColor3=T.row,BackgroundTransparency=0}); lbl.TextColor3=T.txt end
    end)
    hit.MouseLeave:Connect(function()
        if activeTab~=t.id then tw(b,.1,{BackgroundTransparency=1}); lbl.TextColor3=T.dim end
    end)
    hit.MouseButton1Click:Connect(function() switchTab(t.id) end)
    sideTabBtns[t.id]=b
end

-- ============================================================
-- FEATURE LOGIC
-- ============================================================

-- FLY
local flyBV, flyBG
local function startFly()
    local hrp=getHRP(); if not hrp then return end
    pcall(function() hrp:SetNetworkOwner(nil) end)
    if flyBV then pcall(function() flyBV:Destroy() end) end
    if flyBG then pcall(function() flyBG:Destroy() end) end
    flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e9,1e9,1e9); flyBV.Velocity=Vector3.zero; flyBV.Parent=hrp
    flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1e9,1e9,1e9); flyBG.P=9000; flyBG.D=200; flyBG.Parent=hrp
end
local function stopFly()
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV=nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG=nil end
end

-- NOCLIP
local ncConn
local ncCachedParts={}
local function cacheNoclipParts()
    ncCachedParts={}
    local c=getChar(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then table.insert(ncCachedParts,p) end
    end
end
local function startNoclip()
    if ncConn then ncConn:Disconnect() end
    cacheNoclipParts()
    ncConn=RunService.Stepped:Connect(function()
        if not CFG.noclip then return end
        for _,p in ipairs(ncCachedParts) do
            pcall(function() p.CanCollide=false end)
        end
    end)
end
local function stopNoclip()
    if ncConn then ncConn:Disconnect(); ncConn=nil end
    for _,p in ipairs(ncCachedParts) do
        pcall(function() p.CanCollide=true end)
    end
    ncCachedParts={}
end

-- BHOP
local bhopConn
local function startBhop()
    if bhopConn then bhopConn:Disconnect() end
    local h=getHum(); if not h then return end
    bhopConn=h.StateChanged:Connect(function(_,new)
        if not CFG.bunnyHop then return end
        if new==Enum.HumanoidStateType.Landed then
            task.wait(); local h2=getHum()
            if h2 then pcall(function() h2:ChangeState(Enum.HumanoidStateType.Jumping) end) end
        end
    end)
end
local function stopBhop() if bhopConn then bhopConn:Disconnect(); bhopConn=nil end end

-- ANTI KICK
local antiKickConn
local function applyAntiKick(on)
    if antiKickConn then antiKickConn:Disconnect(); antiKickConn=nil end
    if on then
        antiKickConn=lp.OnTeleport:Connect(function(state)
            if state==Enum.TeleportState.RequestedFromServer then notify("GLUHFIX","Anti-Kick blocked!",3) end
        end)
    end
end

-- HEADLESS
local hlessBkp={}
local function applyHeadless(on)
    local c=getChar(); if not c then return end
    local head=c:FindFirstChild("Head"); if not head then return end
    if on then
        pcall(function() head.Transparency=1 end)
        for _,d in ipairs(head:GetDescendants()) do
            if d:IsA("Decal") then hlessBkp[d]=d.Transparency; pcall(function() d.Transparency=1 end)
            elseif d:IsA("SpecialMesh") then hlessBkp[d]=d.Scale; pcall(function() d.Scale=Vector3.new(0,0,0) end) end
        end
    else
        pcall(function() head.Transparency=0 end)
        for obj,val in pairs(hlessBkp) do
            pcall(function()
                if obj:IsA("Decal") then obj.Transparency=val
                elseif obj:IsA("SpecialMesh") then obj.Scale=val end
            end)
        end; hlessBkp={}
    end
end

-- INVISIBLE
local function applyInvis(on)
    local c=getChar(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p.LocalTransparencyModifier=on and 1 or 0 end)
            pcall(function() p.Transparency=on and 1 or (p.Name=="HumanoidRootPart" and 1 or 0) end)
        elseif p:IsA("Decal") then pcall(function() p.Transparency=on and 1 or 0 end) end
    end
end

-- FULLBRIGHT
local function applyFullbright(on)
    pcall(function()
        if on then
            Lighting.Brightness=10; Lighting.ClockTime=14; Lighting.FogEnd=1e6
            Lighting.GlobalShadows=false
            Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        else
            Lighting.Brightness=CFG._origBright; Lighting.FogEnd=CFG._origFogEnd
            Lighting.GlobalShadows=true; Lighting.Ambient=CFG._origAmbient; Lighting.OutdoorAmbient=CFG._origOutdoor
        end
    end)
end

-- FREEZE TIME
local frozenAtm={}
local function applyFreezeTime(on)
    if on then
        CFG.frozenTime=Lighting.ClockTime
        local atm=Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then frozenAtm={Density=atm.Density,Offset=atm.Offset,Color=atm.Color,Decay=atm.Decay,Glare=atm.Glare,Haze=atm.Haze} end
    else
        frozenAtm={}
    end
end

-- ANTI LAG
local function applyAntiLag(on)
    if on then
        pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
        pcall(function() Lighting.GlobalShadows=false end)
        local killTypes={"ParticleEmitter","Trail","Beam","Fire","Smoke","Sparkles","SurfaceLight","PointLight","SpotLight","Blur","ColorCorrectionEffect","DepthOfFieldEffect","SunRaysEffect","BloomEffect"}
        for _,v in ipairs(workspace:GetDescendants()) do
            pcall(function()
                for _,t in ipairs(killTypes) do
                    if v:IsA(t) then
                        if v:IsA("ParticleEmitter") then v.Rate=0
                        elseif v:IsA("Fire") then v.Size=0
                        elseif v:IsA("Smoke") then v.RiseVelocity=0
                        else pcall(function() v.Enabled=false end) end
                    end
                end
                if v:IsA("Atmosphere") then v.Density=0; v.Haze=0; v.Glare=0 end
            end)
        end
        for _,v in ipairs(Lighting:GetDescendants()) do
            pcall(function()
                if v:IsA("Atmosphere") then v.Density=0; v.Haze=0 end
                if v:IsA("Blur") then v.Size=0 end
                if v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") then v.Enabled=false end
            end)
        end
    else
        pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic end)
        pcall(function() Lighting.GlobalShadows=true end)
    end
end

-- ============================================================
-- AIMBOT
-- ============================================================
local fovCircle=mk("Frame",{Size=UDim2.new(0,240,0,240),AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=50},gui)
rnd(fovCircle,120)
local fovStroke=mk("UIStroke",{Color=T.accent,Thickness=1.5,Transparency=.4},fovCircle)
rTC(function() fovStroke.Color=T.accent end)

local losCastParams=RaycastParams.new()
losCastParams.FilterType=Enum.RaycastFilterType.Exclude
local function updateLOSFilter()
    local ex={getChar()}
    for _,p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(ex,p.Character) end end
    losCastParams.FilterDescendantsInstances=ex
end

local function hasLOS(tp)
    local hrp=getHRP(); if not hrp then return false end
    local res=workspace:Raycast(hrp.Position,(tp-hrp.Position),losCastParams)
    if not res then return true end
    local h=res.Instance
    if h and h:IsA("BasePart") and (h.Transparency>=.7 or h.Material==Enum.Material.Glass or h.Material==Enum.Material.ForceField) then return true end
    return false
end

local aimbotLockedTarget = nil
local aimbotWasHeld = false

local function getClosestTarget()
    local center=cam.ViewportSize/2; local best,bestD=nil,CFG.aimbotFOV
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local hum=plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 then
                local bone=plr.Character:FindFirstChild(CFG.aimbotBone) or plr.Character:FindFirstChild("Head")
                if bone then
                    local pos,vis=cam:WorldToViewportPoint(bone.Position)
                    if vis then
                        local d=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                        if d<bestD then
                            if not CFG.aimbotVisCheck or hasLOS(bone.Position) then bestD=d; best=bone end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ============================================================
-- ESP — KOMPLETT OPTIMIERT v10.1
-- ============================================================
local espData={}
local espFr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=10},gui)
local skelFr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=11},gui)

local LINE_POOL_SIZE = 40
local SKEL_POOL_SIZE = 14

local function createPooledLine(parent)
    local f=Instance.new("Frame")
    f.BorderSizePixel=0; f.Visible=false; f.ZIndex=15
    f.AnchorPoint=Vector2.new(0.5, 0.5)
    f.Parent=parent; return f
end

local function updateLine(f, ax, ay, bx, by, col, thick)
    local dx,dy = bx-ax, by-ay
    local lenSq = dx*dx + dy*dy
    if lenSq < 1 then f.Visible=false; return end
    local len = math.sqrt(lenSq)
    local mx, my = (ax+bx)*0.5, (ay+by)*0.5
    f.Size     = UDim2.new(0, len, 0, thick or 1)
    f.Position = UDim2.new(0, mx,  0, my)
    f.Rotation = math.deg(math.atan2(dy, dx))
    f.BackgroundColor3 = col
    f.Visible  = true
end

local function hidePool(pool, from)
    for i=from,#pool do
        if pool[i].Visible then pool[i].Visible=false end
    end
end

local function drawCBoxPooled(d, x, y, w, h, col, thick)
    local t = thick or CFG.espLineThick
    local cl = math.clamp(math.min(w, h) * 0.20, 6, 30)
    local x2 = x + w
    local y2 = y + h
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f, x, y, x+cl, y, col, t) end
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f, x, y, x, y+cl, col, t) end
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f, x2-cl, y, x2, y, col, t) end
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f, x2, y, x2, y+cl, col, t) end
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f, x, y2, x+cl, y2, col, t) end
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f, x, y2-cl, x, y2, col, t) end
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f, x2-cl, y2, x2, y2, col, t) end
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f, x2, y2-cl, x2, y2, col, t) end
end

local function drawFBoxPooled(d, x, y, w, h, col, thick)
    local t = thick or CFG.espLineThick
    local x2=x+w; local y2=y+h
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f,x,y,x2,y,col,t) end
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f,x,y2,x2,y2,col,t) end
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f,x,y,x,y2,col,t) end
    d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]; if f then updateLine(f,x2,y,x2,y2,col,t) end
end

local BBOX_BONES={"Head","UpperTorso","LowerTorso","LeftFoot","RightFoot","LeftHand","RightHand"}
local BONES={"Head","UpperTorso","LowerTorso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"}
local SKEL_P={
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}

local function getECol() return Color3.fromHSV(CFG.espColorH,CFG.espColorS,CFG.espColorV) end

local function ensureESPData(plr, hrp)
    if not espData[plr] then espData[plr]={} end
    local d=espData[plr]

    if not d.bb or not d.bb.Parent then
        local bb=Instance.new("BillboardGui"); bb.AlwaysOnTop=true
        bb.Size=UDim2.new(0,165,0,52); bb.StudsOffset=Vector3.new(0,3.6,0); bb.LightInfluence=0
        pcall(function() bb.Parent=hrp end); d.bb=bb
        d.nl=mk("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,
            TextSize=13,Font=Enum.Font.GothamBold,TextStrokeTransparency=0,TextStrokeColor3=Color3.fromRGB(0,0,0)},bb)
        local hbg=mk("Frame",{Size=UDim2.new(1,0,0,5),Position=UDim2.new(0,0,0,22),BackgroundColor3=Color3.fromRGB(26,4,4),BorderSizePixel=0},bb); rnd(hbg,3)
        d.hpF=mk("Frame",{BackgroundColor3=T.green,BorderSizePixel=0},hbg); rnd(d.hpF,3)
        d.dl=mk("TextLabel",{Size=UDim2.new(1,0,0,13),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,TextSize=10,Font=Enum.Font.Gotham,TextStrokeTransparency=0,TextColor3=T.dim},bb)
        d.bbEnabled=false
    end

    if not d.boxFr or not d.boxFr.Parent then
        d.boxFr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=10},espFr)
        d.linePool={}
        for i=1,LINE_POOL_SIZE do d.linePool[i]=createPooledLine(d.boxFr) end
        d.lineUsed=0
    end

    if not d.skelFrP or not d.skelFrP.Parent then
        d.skelFrP=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=11},skelFr)
        d.skelPool={}
        for i=1,SKEL_POOL_SIZE do d.skelPool[i]=createPooledLine(d.skelFrP) end
        d.skelUsed=0
    end

    return d
end

local ESP_REFRESH_RATE = 8
local BB_REFRESH_RATE  = 12

-- ============================================================
-- HUD
-- ============================================================
local hud=mk("Frame",{
    Size=UDim2.new(0,290,0,100),
    Position=UDim2.new(0,10,1,-114),
    BackgroundColor3=Color3.fromRGB(4,4,6),
    BackgroundTransparency=.08,BorderSizePixel=0,Visible=false
},gui)
rnd(hud,12); mk("UIStroke",{Color=T.border,Thickness=1.2},hud); pad(hud,12,12,7,7)

local function hudLbl(y, col)
    return mk("TextLabel",{
        Text="",Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,y),
        BackgroundTransparency=1,TextColor3=col or T.txt,
        TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left
    },hud)
end
local hFPS   = hudLbl(0,  T.green)
local hCoord = hudLbl(16, T.txt)
local hSpeed = hudLbl(32, T.accent2)
local hGrav  = hudLbl(48, Color3.fromRGB(200,180,255))
local hFeats = hudLbl(64, T.orange)
local hBar   = mk("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,80),
    BackgroundColor3=T.border,BorderSizePixel=0},hud)
local hInfo  = hudLbl(84, T.dim)
rTC(function()
    hFPS.TextColor3=T.green; hSpeed.TextColor3=T.accent2; hFeats.TextColor3=T.orange
end)

local lastFPSTime=tick(); local frameCount=0; local currentFPS=0
RunService.RenderStepped:Connect(function()
    frameCount=frameCount+1
    local now=tick()
    if now-lastFPSTime>=0.5 then
        currentFPS=math.floor(frameCount/(now-lastFPSTime))
        frameCount=0; lastFPSTime=now
    end
end)

-- ============================================================
-- MASTER RENDER LOOP
-- ============================================================
local espFrameCount=0

RunService:BindToRenderStep("GF_Master", Enum.RenderPriority.Camera.Value, function(dt)
    espFrameCount = espFrameCount + 1

    -- ---- FLY ----
    if CFG.fly then
        local hrp=getHRP()
        if hrp and flyBV and flyBV.Parent then
            local d=Vector3.zero; local u=UserInputService
            if u:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end
            if u:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
            if u:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
            if u:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
            if u:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
            if u:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end
            flyBV.Velocity=d.Magnitude>0 and d.Unit*CFG.flySpeed or Vector3.zero
            if flyBG and flyBG.Parent then flyBG.CFrame=cam.CFrame end
        end
    end

    -- ---- SPINBOT ----
    -- spinSpeed = degrees per frame. More = faster, less = slower
    if CFG.spinBot then
        local h=getHRP()
        if h then pcall(function() h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(CFG.spinSpeed),0) end) end
    end

    -- ---- FREEZE TIME ----
    if CFG.freezeTime then
        pcall(function() Lighting.ClockTime=CFG.frozenTime end)
        local a=Lighting:FindFirstChildOfClass("Atmosphere")
        if a and next(frozenAtm) then for k,v in pairs(frozenAtm) do pcall(function() a[k]=v end) end end
    end

    -- ---- AIMBOT ----
    fovCircle.Visible=CFG.aimbot
    if CFG.aimbot then
        local r=CFG.aimbotFOV
        fovCircle.Size=UDim2.new(0,r*2,0,r*2)
        local rc=fovCircle:FindFirstChildOfClass("UICorner"); if rc then rc.CornerRadius=UDim.new(0,r) end
        local held=isKbHeld("aimbot")
        if held then
            if not aimbotWasHeld then
                updateLOSFilter()
                aimbotLockedTarget=getClosestTarget()
            end
            aimbotWasHeld=true
            if aimbotLockedTarget and aimbotLockedTarget.Parent then
                local canAim=true
                if CFG.aimbotVisCheck then canAim=hasLOS(aimbotLockedTarget.Position) end
                if canAim then
                    pcall(function()
                        local targetCF=CFrame.new(cam.CFrame.Position, aimbotLockedTarget.Position)
                        cam.CFrame=cam.CFrame:Lerp(targetCF, CFG.aimbotSmooth/100)
                    end)
                end
            else
                updateLOSFilter()
                aimbotLockedTarget=getClosestTarget()
            end
        else
            if aimbotWasHeld then aimbotLockedTarget=nil; aimbotWasHeld=false end
        end
    else
        aimbotLockedTarget=nil; aimbotWasHeld=false
    end

    -- ---- ESP ----
    if not CFG.esp then
        for _,d in pairs(espData) do
            if d.bb and d.bbEnabled then pcall(function() d.bb.Enabled=false end); d.bbEnabled=false end
            if d.hl then pcall(function() d.hl:Destroy() end); d.hl=nil end
            if d.linePool then hidePool(d.linePool, 1); d.lineUsed=0 end
            if d.skelPool then hidePool(d.skelPool, 1); d.skelUsed=0 end
        end
        return
    end

    local doBoxUpdate = (espFrameCount % ESP_REFRESH_RATE == 0)
    local doBBUpdate  = (espFrameCount % BB_REFRESH_RATE == 0)

    if not doBoxUpdate and not doBBUpdate then return end

    local myHRP=getHRP()
    local ecol=getECol()

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
            local hum=plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local dist=myHRP and math.floor((hrp.Position-myHRP.Position).Magnitude) or 999

                if dist>CFG.espMaxDist then
                    if espData[plr] then
                        local d=espData[plr]
                        if d.bb and d.bbEnabled then pcall(function() d.bb.Enabled=false end); d.bbEnabled=false end
                        if d.linePool then hidePool(d.linePool,1); d.lineUsed=0 end
                        if d.skelPool then hidePool(d.skelPool,1); d.skelUsed=0 end
                    end
                else
                    local d=ensureESPData(plr, hrp)

                    if doBBUpdate then
                        if not d.bbEnabled then
                            pcall(function() d.bb.Enabled=true end); d.bbEnabled=true
                        end
                        local hp=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                        if d.nl then pcall(function() d.nl.Visible=CFG.espNames; d.nl.Text=plr.Name; d.nl.TextColor3=ecol end) end
                        if d.hpF then pcall(function()
                            d.hpF.Parent.Visible=CFG.espHealth; d.hpF.Size=UDim2.new(hp,0,1,0)
                            d.hpF.BackgroundColor3=Color3.fromRGB(math.floor(255*(1-hp)),math.floor(210*hp),55)
                        end) end
                        if d.dl then pcall(function() d.dl.Visible=CFG.espDist; d.dl.Text=dist.."m" end) end
                    end

                    if doBoxUpdate then
                        d.lineUsed=0
                        d.skelUsed=0

                        local bonePos={}
                        local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
                        local anyVis=false

                        local boneList = (CFG.espSkeleton) and BONES or BBOX_BONES

                        for _,pn in ipairs(boneList) do
                            local pt=plr.Character:FindFirstChild(pn)
                            if pt then
                                local sp,vis=cam:WorldToViewportPoint(pt.Position)
                                if vis then
                                    anyVis=true
                                    bonePos[pn]=Vector2.new(sp.X,sp.Y)
                                    if sp.X<minX then minX=sp.X end
                                    if sp.Y<minY then minY=sp.Y end
                                    if sp.X>maxX then maxX=sp.X end
                                    if sp.Y>maxY then maxY=sp.Y end
                                end
                            end
                        end

                        local headPt  = plr.Character:FindFirstChild("Head")
                        local rootPt  = plr.Character:FindFirstChild("HumanoidRootPart")
                        local lFootPt = plr.Character:FindFirstChild("LeftFoot") or plr.Character:FindFirstChild("Left Leg")
                        local rFootPt = plr.Character:FindFirstChild("RightFoot") or plr.Character:FindFirstChild("Right Leg")
                        local lArmPt  = plr.Character:FindFirstChild("LeftUpperArm") or plr.Character:FindFirstChild("Left Arm")
                        local rArmPt  = plr.Character:FindFirstChild("RightUpperArm") or plr.Character:FindFirstChild("Right Arm")

                        local topY, botY, leftX, rightX = minY, maxY, minX, maxX

                        if headPt then
                            local headTop = headPt.Position + Vector3.new(0, headPt.Size.Y * 0.5 + 0.1, 0)
                            local sp,vis = cam:WorldToViewportPoint(headTop)
                            if vis then
                                if sp.Y < topY then topY = sp.Y end
                                if sp.X < leftX then leftX = sp.X end
                                if sp.X > rightX then rightX = sp.X end
                            end
                        end

                        for _,fp in ipairs({lFootPt, rFootPt}) do
                            if fp then
                                local footBot = fp.Position - Vector3.new(0, fp.Size.Y * 0.5, 0)
                                local sp,vis = cam:WorldToViewportPoint(footBot)
                                if vis then
                                    if sp.Y > botY then botY = sp.Y end
                                    if sp.X < leftX then leftX = sp.X end
                                    if sp.X > rightX then rightX = sp.X end
                                end
                            end
                        end

                        for _,ap in ipairs({lArmPt, rArmPt}) do
                            if ap then
                                local shoulderEdge = ap.Position
                                local sp,vis = cam:WorldToViewportPoint(shoulderEdge)
                                if vis then
                                    if sp.X < leftX then leftX = sp.X end
                                    if sp.X > rightX then rightX = sp.X end
                                end
                            end
                        end

                        if anyVis then
                            local PAD = 2
                            local px = leftX  - PAD
                            local py = topY   - PAD
                            local pw = (rightX - leftX) + PAD*2
                            local ph2= (botY   - topY)  + PAD*2

                            if pw < 10 then pw = 10 end
                            if ph2 < 10 then ph2 = 10 end

                            if CFG.espCorner then drawCBoxPooled(d,px,py,pw,ph2,ecol) end
                            if CFG.espBoxFull then drawFBoxPooled(d,px,py,pw,ph2,ecol) end

                            if CFG.espSkeleton then
                                for _,pair in ipairs(SKEL_P) do
                                    local a=bonePos[pair[1]]; local b2=bonePos[pair[2]]
                                    if a and b2 then
                                        d.skelUsed=d.skelUsed+1
                                        local sf=d.skelPool[d.skelUsed]
                                        if sf then updateLine(sf,a.X,a.Y,b2.X,b2.Y,ecol,CFG.espLineThick) end
                                    end
                                end
                            end

                            if CFG.espHeadDot then
                                local hp2=bonePos["Head"]
                                if hp2 then
                                    d.lineUsed=d.lineUsed+1
                                    local f=d.linePool[d.lineUsed]
                                    if f then
                                        f.Size=UDim2.new(0,8,0,8)
                                        f.Position=UDim2.new(0,hp2.X-4,0,hp2.Y-4)
                                        f.Rotation=0; f.BackgroundColor3=ecol; f.Visible=true
                                    end
                                end
                            end

                            if CFG.espTracer and myHRP then
                                local mp,mv=cam:WorldToViewportPoint(myHRP.Position)
                                local ep=bonePos["HumanoidRootPart"] or bonePos["UpperTorso"] or bonePos["LowerTorso"]
                                if mv and ep then
                                    d.lineUsed=d.lineUsed+1
                                    local f=d.linePool[d.lineUsed]
                                    if f then updateLine(f,mp.X,mp.Y,ep.X,ep.Y,ecol,CFG.espLineThick) end
                                end
                            end
                        end

                        hidePool(d.linePool, d.lineUsed+1)
                        hidePool(d.skelPool, d.skelUsed+1)
                    end

                    if CFG.espChams then
                        if not d.hl or not d.hl.Parent then
                            local hl=Instance.new("Highlight");hl.Adornee=plr.Character
                            hl.FillTransparency=.80;hl.OutlineTransparency=0
                            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                            pcall(function() hl.Parent=plr.Character end); d.hl=hl
                        end
                        pcall(function() d.hl.FillColor=ecol; d.hl.OutlineColor=ecol end)
                    else
                        if d.hl then pcall(function() d.hl:Destroy() end); d.hl=nil end
                    end
                end
            end
        end
    end

    local toRemove={}
    for plr,d in pairs(espData) do
        if not Players:FindFirstChild(plr.Name) then
            if d.bb then pcall(function() d.bb:Destroy() end) end
            if d.hl then pcall(function() d.hl:Destroy() end) end
            if d.boxFr then pcall(function() d.boxFr:Destroy() end) end
            if d.skelFrP then pcall(function() d.skelFrP:Destroy() end) end
            table.insert(toRemove,plr)
        end
    end
    for _,plr in ipairs(toRemove) do espData[plr]=nil end
end)

-- ============================================================
-- MASTER HEARTBEAT
-- ============================================================
local lastAfk=tick()
local kbToggleFeats={"fly","noclip","speed","highJump","spinBot","bunnyHop","crosshair","infinite_jump","headless","antiLag","freezeTime","antiAfk","esp","invisible","fullbright"}
local kbPrevDown={}
local hbFrame=0

RunService.Heartbeat:Connect(function(dt)
    hbFrame = hbFrame + 1

    if CFG.speed then
        local hum=getHum(); local hrp=getHRP()
        if hum and hrp then
            local t=CFG.speedMult
            pcall(function() hum.WalkSpeed=t end)
            if sethiddenproperty then pcall(function() sethiddenproperty(hum,"WalkSpeed",t) end) end
            if hbFrame % 30 == 0 then pcall(function() hrp:SetNetworkOwner(nil) end) end
        end
    end

    if CFG.highJump then
        local h=getHum()
        if h then
            if math.abs((h.JumpPower or 0)-CFG.jumpPower)>0.5 then
                pcall(function() h.UseJumpPower=true; h.JumpPower=CFG.jumpPower end)
                if sethiddenproperty then pcall(function() sethiddenproperty(h,"JumpPower",CFG.jumpPower) end) end
            end
        end
    end

    if CFG.autoJump then
        local h=getHum()
        if h and h.FloorMaterial~=Enum.Material.Air then pcall(function() h.Jump=true end) end
    end

    if CFG.infinite_jump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local h=getHum()
        if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end

    if CFG.antiAfk and tick()-lastAfk>360 then
        lastAfk=tick(); local h=getHum(); if h then pcall(function() h.Jump=true end) end
    end

    if hbFrame % 2 == 0 then
        for _,feat in ipairs(kbToggleFeats) do
            local down=isKbHeld(feat)
            if down and not kbPrevDown[feat] then
                CFG[feat]=not CFG[feat]
                if feat=="fly" then if CFG.fly then startFly() else stopFly() end end
                if feat=="noclip" then if CFG.noclip then startNoclip() else stopNoclip() end end
                if feat=="antiLag" then applyAntiLag(CFG.antiLag) end
                if feat=="fullbright" then applyFullbright(CFG.fullbright) end
                if feat=="crosshair" then xhF.Visible=CFG.crosshair end
                if feat=="invisible" then applyInvis(CFG.invisible) end
                if feat=="headless" then applyHeadless(CFG.headless) end
                if feat=="freezeTime" then applyFreezeTime(CFG.freezeTime) end
                if feat=="bunnyHop" then if CFG.bunnyHop then startBhop() else stopBhop() end end
                saveConfig()
            end
            kbPrevDown[feat]=down
        end
    end

    if hbFrame % 6 == 0 then
        local anyHud=CFG.showCoords or CFG.showFPS
        hud.Visible=anyHud
        if anyHud then
            local fpsColor = currentFPS>=55 and T.green or (currentFPS>=30 and T.orange or T.red)
            hFPS.Text="⚡ FPS: "..currentFPS.."   ["..tostring(math.floor(currentFPS/60*100)).."% of 60]"
            hFPS.TextColor3=fpsColor
            local hrpX=getHRP()
            if hrpX then
                local pos=hrpX.Position
                hCoord.Text=("📍 X:%.0f  Y:%.0f  Z:%.0f"):format(pos.X,pos.Y,pos.Z)
                local vel=hrpX.Velocity
                local spd=math.floor(math.sqrt(vel.X^2+vel.Z^2))
                hSpeed.Text="🏃 Speed: "..spd.." u/s  |  Y-Vel: "..math.floor(vel.Y)
            else
                hCoord.Text="📍 ---"; hSpeed.Text=""
            end
            hGrav.Text="🌐 Gravity: "..math.floor(workspace.Gravity).."  |  Time: "..string.format("%.1f",Lighting.ClockTime)
            local feats={}
            if CFG.fly then table.insert(feats,"FLY") end
            if CFG.speed then table.insert(feats,"SPD") end
            if CFG.noclip then table.insert(feats,"NCIP") end
            if CFG.aimbot then table.insert(feats,"AIM") end
            if CFG.esp then table.insert(feats,"ESP") end
            if CFG.invisible then table.insert(feats,"INVIS") end
            if CFG.antiLag then table.insert(feats,"FPS+") end
            hFeats.Text="🔧 "..(#feats>0 and table.concat(feats," · ") or "No features active")
            hInfo.Text="GLUHFIX v10 | "..lp.Name
        end
    end

    if activeTab=="Config" and hbFrame % 20 == 0 then
        for key,lbl in pairs(statusLabels) do
            pcall(function()
                local on=CFG[key]; lbl.Text=on and "ON" or "off"; lbl.TextColor3=on and T.green or T.dim
            end)
        end
    end
end)

-- ============================================================
-- CROSSHAIR
-- ============================================================
local xhF=mk("Frame",{Size=UDim2.new(0,90,0,90),AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=50},gui)
local function buildCH()
    xhF:ClearAllChildren()
    local col=CFG.crosshairColorH==0 and Color3.fromRGB(255,255,255) or Color3.fromHSV(CFG.crosshairColorH,1,1)
    local s=CFG.crosshairSize; local st=CFG.crosshairStyle
    xhF.Size=UDim2.new(0,s*2+16,0,s*2+16)
    local function ln(w,h,ox,oy,rot)
        local f=mk("Frame",{Size=UDim2.new(0,w,0,h),Position=UDim2.new(.5,-w/2+ox,.5,-h/2+oy),
            BackgroundColor3=col,BorderSizePixel=0,Rotation=rot or 0,ZIndex=51},xhF)
        rnd(f,1); mk("UIStroke",{Color=Color3.fromRGB(0,0,0),Thickness=1,Transparency=.4},f)
    end
    local function dot(sz) local f=mk("Frame",{Size=UDim2.new(0,sz,0,sz),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=52},xhF);rnd(f,sz/2) end
    local g=math.floor(s*.22)
    if st==1 then ln(s/2-g,2,-(s/4+g/2+1),0);ln(s/2-g,2,s/4+g/2+1,0);ln(2,s/2-g,0,-(s/4+g/2+1));ln(2,s/2-g,0,s/4+g/2+1)
    elseif st==2 then dot(7)
    elseif st==3 then local r=mk("Frame",{Size=UDim2.new(0,s,0,s),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=51},xhF);mk("UIStroke",{Color=Color3.fromRGB(0,0,0),Thickness=3.5,Transparency=.5},r);rnd(r,s);local r2=mk("Frame",{Size=UDim2.new(0,s,0,s),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=52},xhF);mk("UIStroke",{Color=col,Thickness=2},r2);rnd(r2,s)
    elseif st==4 then ln(s,2,0,0);ln(2,s/2,0,s/4)
    elseif st==5 then ln(s,2,0,0,45);ln(s,2,0,0,-45)
    elseif st==6 then ln(s/2-g,2,-(s/4+g/2+1),0);ln(s/2-g,2,s/4+g/2+1,0);ln(2,s/2-g,0,-(s/4+g/2+1));ln(2,s/2-g,0,s/4+g/2+1);dot(5)
    elseif st==7 then local h2=s/2; ln(s+4,2,0,-h2);ln(s+4,2,0,h2);ln(2,s,-h2+1,0);ln(2,s,h2-1,0)
    elseif st==8 then ln(s*.65,2,-s*.16,s*.2,45);ln(s*.65,2,s*.16,s*.2,-45) end
end
buildCH()

-- ============================================================
-- ANIMATIONS
-- ============================================================
local EMOTES = {
    {"Dance 1 — Shout",        507771019},
    {"Dance 2 — Robot",        507771955},
    {"Dance 3 — Gangnam",      507776043},
    {"Wave",                   507770239},
    {"Point",                  507770453},
    {"Cheer",                  507770677},
    {"Laugh",                  507770818},
    {"Victory",                507770894},
    {"Salute",                 3360692780},
    {"Tilt",                   3360686498},
    {"Crouch Idle",            2550741804},
    {"Sit (Ground)",           2550742915},
    {"Lean Back",              2550740560},
    {"Head Scratch",           3360692036},
    {"Air Guitar",             3360686288},
    {"Sword Slash",            522635514},
    {"Kick",                   522635514},
    {"Backflip",               747221813},
    {"Breakdance",             5916662781},
    {"IDK shrug",              3360686062},
    {"Fist Pump",              507769814},
    {"Superhero Land",         3360690660},
    {"Pushup",                 3360692396},
    {"Sit Chair",              2550742353},
    {"Bow",                    522635514},
}

local currentAnimTrack=nil
local function playAnim(id)
    local hum=getHum(); if not hum then return end
    if currentAnimTrack then pcall(function() currentAnimTrack:Stop() end) end
    local anim=Instance.new("Animation"); anim.AnimationId="rbxassetid://"..id
    pcall(function()
        currentAnimTrack=hum:LoadAnimation(anim)
        currentAnimTrack:Play()
    end)
end
local function stopAnim()
    if currentAnimTrack then pcall(function() currentAnimTrack:Stop() end); currentAnimTrack=nil end
end

-- ============================================================
-- SCANNER
-- ============================================================
local scannerResults={}
local function runScanner()
    local hrp=getHRP(); if not hrp then return end
    local origin=hrp.Position; local range=CFG.scannerRange
    scannerResults={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool") then
                local pos
                if obj:IsA("BasePart") then pos=obj.Position
                elseif obj:IsA("Model") then
                    local p=obj:FindFirstChildOfClass("BasePart"); if p then pos=p.Position end
                end
                if pos then
                    local d=math.floor((pos-origin).Magnitude)
                    if d<=range then table.insert(scannerResults,{name=obj.Name,class=obj.ClassName,dist=d,pos=pos}) end
                end
            end
        end)
    end
    table.sort(scannerResults,function(a,b) return a.dist<b.dist end)
    return scannerResults
end

-- ============================================================
-- TAB CONTENT
-- ============================================================

---- MOVE ----
sec("Move","Flying  [BYPASS]")
tog("Move","Fly  —  WASD + Space / Shift","fly","No PlatformStand. Bypasses AC.",function(on) if on then startFly() else stopFly() end end)
sld("Move","Fly Speed",10,600,CFG.flySpeed,5,"Flight speed",function(v) CFG.flySpeed=v end)
tog("Move","Noclip  —  through walls","noclip","Bypasses collision",function(on) if on then startNoclip() else stopNoclip() end end)
tog("Move","Speed Boost","speed","WalkSpeed direkt setzen — kein Multiplier",function(on) if not on then local h=getHum();if h then pcall(function() h.WalkSpeed=16 end) end end end)
sld("Move","WalkSpeed  (16=normal)",16,300,CFG.speedMult,1,"16=normal  50=schnell  150=sehr schnell  300=max",function(v) CFG.speedMult=v end)
sec("Move","Jumping")
tog("Move","High Jump","highJump","Bypasses jump height",function(on) if not on then local h=getHum();if h then pcall(function() h.JumpPower=50 end) end end end)
sld("Move","Jump Power",50,900,CFG.jumpPower,10,"50=normal  900=extreme",function(v) CFG.jumpPower=v end)
tog("Move","Infinite Jump","infinite_jump","Hold Space to keep jumping",nil)
tog("Move","Bunny Hop","bunnyHop","Auto-jump on landing",function(on) if on then startBhop() else stopBhop() end end)
tog("Move","Auto Jump","autoJump","Auto-jump while grounded",nil)
sec("Move","Misc")
tog("Move","Spinbot","spinBot","Spin character constantly",nil)
-- Spinbot Speed: höherer Wert = schneller drehen, niedrigerer Wert = langsamer
sld("Move","Spin Speed  (more=faster)",1,40,CFG.spinSpeed,1,"Degrees per frame — more=faster  less=slower",function(v) CFG.spinSpeed=v end)
tog("Move","Anti-AFK","antiAfk","Auto-jump every 6min",nil)
tog("Move","Anti-Lag  [100%]","antiLag","Kills ALL particles/effects/shadows",function(on) applyAntiLag(on) end)
note("Move","Removes: particles fire smoke bloom DoF atmosphere lights")
sec("Move","Teleport")
btn("Move","TP to Nearest Player","Teleport to closest enemy",function()
    local hrp=getHRP();if not hrp then return end; local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then local h2=p.Character:FindFirstChild("HumanoidRootPart");if h2 then local d=(h2.Position-hrp.Position).Magnitude;if d<bd then bd=d;best=h2 end end end end
    if best then pcall(function() hrp.CFrame=best.CFrame+Vector3.new(3,0,3) end) end
end)
btn("Move","TP to Player  —  choose","Pick a player to teleport to",function()
    playerPopup("Teleport to Player",function(p)
        local hrp=getHRP(); if not hrp then return end
        local h2=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if h2 then pcall(function() hrp.CFrame=h2.CFrame*CFrame.new(3,0,3) end) end
    end)
end)
btn("Move","TP to Spawn","Go to SpawnLocation",function()
    local hrp=getHRP();if not hrp then return end
    local sp=workspace:FindFirstChildOfClass("SpawnLocation")
    if sp then pcall(function() hrp.CFrame=sp.CFrame+Vector3.new(0,5,0) end) end
end)
btn("Move","Yeet  —  Launch Up","Catapult upward",function()
    local hrp=getHRP();if not hrp then return end
    local bv=Instance.new("BodyVelocity");bv.MaxForce=Vector3.new(1e9,1e9,1e9);bv.Velocity=Vector3.new(0,900,0);bv.Parent=hrp;Debris:AddItem(bv,.15)
end)
btn("Move","Rejoin","Rejoin current server",function()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,lp) end)
end)

---- COMBAT ----
sec("Combat","Aimbot  [100% BYPASS]")
local abModeDisp=mk("TextLabel",{
    Text="Aim Trigger:  [ "..(CFG.keybinds["aimbot"] and (CFG.keybinds["aimbot"].type=="mouse" and CFG.keybinds["aimbot"].value or (tostring(CFG.keybinds["aimbot"].value):match("%.(%a+)$") or "?")) or "RMB (default)").." ]",
    Size=UDim2.new(1,0,0,36),BackgroundColor3=T.accDark,TextColor3=T.accent,
    TextSize=12,Font=Enum.Font.GothamBold,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Center},tabScrolls["Combat"])
rnd(abModeDisp,10); mk("UIStroke",{Color=T.border,Thickness=1.2},abModeDisp)
rTC(function() abModeDisp.BackgroundColor3=T.accDark; abModeDisp.TextColor3=T.accent end)
note("Combat","Default: hold RMB to aim. Change in Keybinds tab.")
btn("Combat","Set Aim: RMB","Hold Right Mouse to aim",function() CFG.keybinds["aimbot"]={type="mouse",value="RMB"}; abModeDisp.Text="Aim Trigger:  [ RMB ]"; saveConfig() end)
btn("Combat","Set Aim: LMB","Hold Left Mouse to aim",function() CFG.keybinds["aimbot"]={type="mouse",value="LMB"}; abModeDisp.Text="Aim Trigger:  [ LMB ]"; saveConfig() end)
tog("Combat","Aimbot  (enable)","aimbot","Enable aimbot",nil)
tog("Combat","Visual Check  (no wall aim)","aimbotVisCheck","Only aim at visible targets",nil)
sld("Combat","FOV Radius",20,500,CFG.aimbotFOV,5,"Pixel radius",function(v) CFG.aimbotFOV=v end)
sld("Combat","Smooth  (1=snap  100=slow)",1,100,CFG.aimbotSmooth,1,"Aim lerp speed",function(v) CFG.aimbotSmooth=v end)
sec("Combat","Target Bone")
btn("Combat","Head","Aim at head",function() CFG.aimbotBone="Head"; notify("Aimbot","Bone: Head",2) end)
btn("Combat","UpperTorso","Aim at torso",function() CFG.aimbotBone="UpperTorso"; notify("Aimbot","Bone: Torso",2) end)
btn("Combat","HumanoidRootPart","Aim at root",function() CFG.aimbotBone="HumanoidRootPart"; notify("Aimbot","Bone: Root",2) end)
sec("Combat","Protection")
tog("Combat","Anti-Kick","antiKick","Block server-side kicks",function(on) applyAntiKick(on) end)
tog("Combat","Anti-Detect  [STEALTH]","antiDetect","Stealth flags",nil)

---- VISUAL ----
sec("Visual","Render")
tog("Visual","Fullbright","fullbright","Max brightness",function(on) applyFullbright(on) end)
tog("Visual","No Fog","noFog","Remove all fog",function(on) pcall(function() Lighting.FogEnd=on and 1e6 or CFG._origFogEnd end) end)
sec("Visual","Crosshair")
tog("Visual","Crosshair","crosshair","Show custom crosshair",function(on) xhF.Visible=on end)
for _,s in ipairs({{"+ Cross",1},{"● Dot",2},{"○ Circle",3},{"T Shape",4},{"X Diagonal",5},{"⊕ Cross+Dot",6},{"□ Box",7},{"∧ Chevron",8}}) do
    btn("Visual",s[1],nil,function() CFG.crosshairStyle=s[2]; buildCH(); saveConfig() end)
end
sld("Visual","Hue  (0=White)",0,100,math.floor(CFG.crosshairColorH*100),1,nil,function(v) CFG.crosshairColorH=v/100; buildCH() end)
sld("Visual","Size",8,70,CFG.crosshairSize,2,nil,function(v) CFG.crosshairSize=v; buildCH() end)

---- WORLD ----
sec("World","Time & Weather")
tog("World","Freeze Time","freezeTime","Lock sun + atmosphere",function(on) applyFreezeTime(on) end)
sld("World","Clock  (0-24)",0,24,CFG.frozenTime,.5,"Time of day",function(v) pcall(function() Lighting.ClockTime=v end); CFG.frozenTime=v end)
sld("World","Brightness",0,10,2,.1,nil,function(v) pcall(function() Lighting.Brightness=v end) end)
btn("World","Night",nil,function() pcall(function() Lighting.ClockTime=0; Lighting.Brightness=.04 end) end)
btn("World","Sunset",nil,function() pcall(function() Lighting.ClockTime=18.5; Lighting.Brightness=1 end) end)
btn("World","Noon",nil,function() pcall(function() Lighting.ClockTime=14; Lighting.Brightness=2.5 end) end)
sec("World","Physics")
sld("World","Gravity",0,1000,196,5,"Workspace gravity",function(v) pcall(function() workspace.Gravity=v end); CFG.gravity=v end)
btn("World","Moon  (16)",nil,function() pcall(function() workspace.Gravity=16 end) end)
btn("World","Normal  (196)",nil,function() pcall(function() workspace.Gravity=196.2 end) end)
btn("World","Heavy  (800)",nil,function() pcall(function() workspace.Gravity=800 end) end)
btn("World","Zero-G  (0)",nil,function() pcall(function() workspace.Gravity=0 end) end)
sec("World","Fog")
sld("World","Fog Start",0,5000,0,50,nil,function(v) pcall(function() Lighting.FogStart=v end) end)
sld("World","Fog End",100,10000,1000,100,nil,function(v) pcall(function() Lighting.FogEnd=v end) end)
btn("World","Random Ambient",nil,function()
    pcall(function() local c=Color3.fromHSV(math.random(),.8,.9); Lighting.Ambient=c; Lighting.OutdoorAmbient=c end)
end)

---- PLAYER ----
sec("Player","Appearance")
tog("Player","Invisible  [BYPASS]","invisible","LocalTransparencyModifier",function(on) applyInvis(on) end)
tog("Player","Headless","headless","Hide head",function(on) applyHeadless(on) end)
btn("Player","🌈  Rainbow  (10s)","Color all body parts rainbow",function()
    task.spawn(function()
        for t=0,200 do
            local c=getChar(); if not c then break end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                    pcall(function() p.Color=Color3.fromHSV((t*.04)%1,1,1) end)
                end
            end; task.wait(.05)
        end
    end)
end)
btn("Player","🖤  All Black","Color everything black",function()
    local c=getChar(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then pcall(function() p.Color=Color3.fromRGB(0,0,0) end) end
    end
end)
btn("Player","🤍  All White","Color everything white",function()
    local c=getChar(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then pcall(function() p.Color=Color3.fromRGB(255,255,255) end) end
    end
end)
btn("Player","✨  Neon Skin","Neon glowing body",function()
    local c=getChar(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
            pcall(function() p.Material=Enum.Material.Neon; p.Color=Color3.fromHSV(CFG.accentH,math.max(CFG.accentS,.7),1) end)
        end
    end
end)
btn("Player","🔍  Remove Accessories","Hide all hat/accessory items",function()
    local c=getChar(); if not c then return end
    for _,a in ipairs(c:GetChildren()) do
        if a:IsA("Accessory") then
            local h=a:FindFirstChildOfClass("Part") or a:FindFirstChildOfClass("MeshPart") or a:FindFirstChildOfClass("SpecialMesh")
            if h then pcall(function() h.Transparency=1 end) end
        end
    end
    notify("GLUHFIX","Accessories hidden",2)
end)
btn("Player","↩  Accessories Back","Show accessories again",function()
    local c=getChar(); if not c then return end
    for _,a in ipairs(c:GetChildren()) do
        if a:IsA("Accessory") then
            local h=a:FindFirstChildOfClass("Part") or a:FindFirstChildOfClass("MeshPart")
            if h then pcall(function() h.Transparency=0 end) end
        end
    end
    notify("GLUHFIX","Accessories visible",2)
end)
sec("Player","Actions")
btn("Player","🟦  Platform  (5s)","Neon platform below you",function()
    local hrp=getHRP();if not hrp then return end
    local p=Instance.new("Part"); p.Size=Vector3.new(12,1,12); p.Anchored=true
    p.Material=Enum.Material.Neon; p.BrickColor=BrickColor.new("Institutional white")
    pcall(function() p.CFrame=hrp.CFrame*CFrame.new(0,-3.5,0) end); p.Parent=workspace; Debris:AddItem(p,5)
    notify("GLUHFIX","Platform spawned — 5s",2)
end)
btn("Player","🔄  Respawn","Kill yourself to respawn",function() local h=getHum();if h then pcall(function() h.Health=0 end) end end)
btn("Player","🚀  Yeet Up","Launch yourself into the air",function()
    local hrp=getHRP();if not hrp then return end
    local bv=Instance.new("BodyVelocity");bv.MaxForce=Vector3.new(1e9,1e9,1e9);bv.Velocity=Vector3.new(0,900,0);bv.Parent=hrp;Debris:AddItem(bv,.15)
end)
btn("Player","💥  Superjump  (once)","One-time mega jump",function()
    local hrp=getHRP();if not hrp then return end
    local bv=Instance.new("BodyVelocity");bv.MaxForce=Vector3.new(1e9,1e9,1e9)
    bv.Velocity=Vector3.new(0,450,0);bv.Parent=hrp;Debris:AddItem(bv,.2)
end)
btn("Player","🌀  Hide Body  (Torso)","Make torso transparent",function()
    local c=getChar(); if not c then return end
    local parts={"UpperTorso","LowerTorso","Torso"}
    for _,n in ipairs(parts) do
        local p=c:FindFirstChild(n)
        if p then pcall(function() p.LocalTransparencyModifier=1 end) end
    end
    notify("GLUHFIX","Torso hidden",2)
end)

---- ANIMATIONS ----
sec("Anim","Emotes & Dances  (visible to others)")
note("Anim","Diese spielen via LoadAnimation — andere Spieler sehen sie")
for _,e in ipairs(EMOTES) do
    btn("Anim",e[1],"Play: "..e[1].." (ID: "..e[2]..")",function() playAnim(e[2]) end)
end
sec("Anim","Controls")
btn("Anim","⏹  Stop Animation","Stop current animation",function() stopAnim(); notify("Anim","Stopped",2) end)
btn("Anim","🔄  Reset Animations","Reload default walk/idle anims",function()
    stopAnim()
    local c=getChar(); if not c then return end
    local animate=c:FindFirstChild("Animate")
    if animate then animate.Disabled=true; task.wait(.1); animate.Disabled=false end
    notify("Anim","Anims reset",2)
end)
note("Anim","Custom anim ID:")
local custIdVal=3360686288
local custIdBox=mk("TextBox",{
    Size=UDim2.new(1,0,0,40),BackgroundColor3=T.row,
    TextColor3=T.txt,Text=tostring(custIdVal),PlaceholderText="Animation ID...",
    TextSize=13,Font=Enum.Font.GothamBold,BorderSizePixel=0,
    TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=false
},tabScrolls["Anim"])
rnd(custIdBox,10); mk("UIStroke",{Color=T.border,Thickness=1.2},custIdBox)
custIdBox.FocusLost:Connect(function()
    local v=tonumber(custIdBox.Text)
    if v then custIdVal=math.floor(v) else custIdBox.Text=tostring(custIdVal) end
end)
btn("Anim","▶  Play Custom Anim","Play custom ID",function() playAnim(custIdVal) end)

---- ESP ----
sec("ESP","ESP Settings")
note("ESP","ESP v10.1 — optimized for maximum FPS")
tog("ESP","Enable ESP","esp","See all players through walls",nil)
tog("ESP","Corner Box","espCorner","Corner brackets",nil)
tog("ESP","Full Box","espBoxFull","Full outline box",nil)
tog("ESP","Skeleton","espSkeleton","Bone structure",nil)
tog("ESP","Head Dot","espHeadDot","Dot on head",nil)
tog("ESP","Chams  (Highlight)","espChams","Glow through walls",nil)
tog("ESP","Health Bars","espHealth","HP bar",nil)
tog("ESP","Names","espNames","Player name",nil)
tog("ESP","Distance","espDist","Distance in meters",nil)
tog("ESP","Tracer","espTracer","Line to enemy",nil)
sld("ESP","Max Distance  (m)",50,2000,CFG.espMaxDist,50,"ESP render range",function(v) CFG.espMaxDist=v end)
sld("ESP","Line Thickness",1,6,CFG.espLineThick,1,"Box/line thickness",function(v) CFG.espLineThick=v end)
sec("ESP","Color")
sld("ESP","Hue  (0=White)",0,100,math.floor(CFG.espColorH*100),1,"Color hue",function(v) CFG.espColorH=v/100 end)
sld("ESP","Saturation %",0,100,math.floor(CFG.espColorS*100),1,"Saturation",function(v) CFG.espColorS=v/100 end)
sld("ESP","Brightness %",0,100,math.floor(CFG.espColorV*100),1,"Brightness",function(v) CFG.espColorV=v/100 end)
note("ESP","White=H0 S0 V100  |  Green=H36 S90 V100  |  Red=H0 S100 V100")

---- SCANNER ----
sec("Scanner","Nearby Object Scanner")
note("Scanner","Scans workspace for objects in range")
sld("Scanner","Scan Range  (studs)",10,2000,CFG.scannerRange,10,"Scan distance",function(v) CFG.scannerRange=v end)
tog("Scanner","Auto-scan  (every 30s)","scannerAuto","Automatically re-scan",nil)
sld("Scanner","Auto-scan Interval  (s)",5,120,CFG.scannerInterval,5,"Seconds between scans",function(v) CFG.scannerInterval=v end)
btn("Scanner","🔍  Scan Now","Scan workspace now",function()
    notify("GLUHFIX","Scanning...",1)
    for _,c in ipairs(tabScrolls["Scanner"]:GetChildren()) do if c.Name=="SR" then c:Destroy() end end
    local results=runScanner()
    local maxShow=math.min(#results,80)
    for i=1,maxShow do
        local r=results[i]
        local row=mk("Frame",{Name="SR",Size=UDim2.new(1,0,0,22),
            BackgroundColor3=i%2==0 and T.row or T.panel,BorderSizePixel=0},tabScrolls["Scanner"])
        rnd(row,5)
        mk("TextLabel",{Text="▸ "..r.name,Size=UDim2.new(.55,0,1,0),Position=UDim2.new(0,6,0,0),
            BackgroundTransparency=1,TextColor3=T.txt,TextSize=10,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left},row)
        mk("TextLabel",{Text=r.class,Size=UDim2.new(.25,0,1,0),Position=UDim2.new(.55,0,0,0),
            BackgroundTransparency=1,TextColor3=T.dim,TextSize=9,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left},row)
        mk("TextLabel",{Text=r.dist.."m",Size=UDim2.new(.2,0,1,0),Position=UDim2.new(.8,0,0,0),
            BackgroundTransparency=1,TextColor3=T.accent,TextSize=9,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Right},row)
    end
    notify("GLUHFIX","Scan done — "..(#results).." objects",3)
end)
btn("Scanner","🗑  Clear Results","Remove scan results",function()
    for _,c in ipairs(tabScrolls["Scanner"]:GetChildren()) do if c.Name=="SR" then c:Destroy() end end
end)

task.spawn(function()
    local sinceLastScan=0
    while true do
        task.wait(1)
        if CFG.scannerAuto then
            sinceLastScan=sinceLastScan+1
            if sinceLastScan>=CFG.scannerInterval then sinceLastScan=0; pcall(runScanner) end
        else sinceLastScan=0 end
    end
end)

---- MAP ----
sec("Map","Position Marker  [Cooler Pfeil]")
local lastPos=nil
local markerParts={}
local markerRunning=false

local function removeAllMarkers()
    markerRunning=false
    for _,p in ipairs(markerParts) do pcall(function() p:Destroy() end) end
    markerParts={}
    for _,v in ipairs(workspace:GetChildren()) do
        if v.Name=="GF_Marker" or v.Name=="GF_MarkerRing" or v.Name=="GF_MarkerBeam" then
            pcall(function() v:Destroy() end)
        end
    end
end

local function spawnCoolMarker(cf)
    removeAllMarkers()
    markerRunning=true
    local pos=cf.Position

    local pillar=Instance.new("Part"); pillar.Name="GF_Marker"
    pillar.Anchored=true; pillar.CanCollide=false; pillar.CastShadow=false
    pillar.Size=Vector3.new(0.3,30,0.3); pillar.Material=Enum.Material.Neon
    pillar.Color=Color3.fromHSV(CFG.accentH,math.max(CFG.accentS,.6),1)
    pillar.CFrame=CFrame.new(pos+Vector3.new(0,15,0)); pillar.Parent=workspace
    table.insert(markerParts,pillar)

    local ring=Instance.new("Part"); ring.Name="GF_MarkerRing"
    ring.Anchored=true; ring.CanCollide=false; ring.CastShadow=false
    ring.Size=Vector3.new(4,0.2,4); ring.Material=Enum.Material.Neon; ring.Shape=Enum.PartType.Cylinder
    ring.Color=Color3.fromHSV(CFG.accentH,math.max(CFG.accentS,.6),1)
    ring.CFrame=CFrame.new(pos+Vector3.new(0,0.1,0))*CFrame.Angles(0,0,math.pi/2); ring.Parent=workspace
    table.insert(markerParts,ring)

    local arrow=Instance.new("WedgePart"); arrow.Name="GF_Marker"
    arrow.Anchored=true; arrow.CanCollide=false; arrow.CastShadow=false
    arrow.Size=Vector3.new(1.2,1.8,1.2); arrow.Material=Enum.Material.Neon
    arrow.Color=Color3.fromRGB(255,255,255)
    arrow.CFrame=CFrame.new(pos+Vector3.new(0,32,0)); arrow.Parent=workspace
    table.insert(markerParts,arrow)

    task.spawn(function()
        local t=0
        while markerRunning and pillar and pillar.Parent do
            t=t+0.04
            local pulse=0.3+math.abs(math.sin(t))*0.25
            pcall(function() pillar.Size=Vector3.new(pulse,30,pulse) end)
            pcall(function() arrow.CFrame=CFrame.new(pos+Vector3.new(0,31+math.sin(t)*1.5,0))*CFrame.Angles(0,t*2,0) end)
            pcall(function() ring.CFrame=CFrame.new(pos+Vector3.new(0,0.1,0))*CFrame.Angles(0,t,math.pi/2) end)
            pcall(function()
                local hue=(t*.05)%1
                pillar.Color=Color3.fromHSV(hue,.9,1)
                ring.Color=Color3.fromHSV((hue+.5)%1,.9,1)
                arrow.Color=Color3.fromHSV(hue,.2,1)
            end)
            task.wait(0.033)
        end
    end)
end

btn("Map","📍  Save Position + Marker","Saves position and shows cool marker",function()
    local hrp=getHRP(); if hrp then
        lastPos=hrp.CFrame
        spawnCoolMarker(hrp.CFrame)
        notify("GLUHFIX","Position saved! Marker set ✓",3)
    end
end)
btn("Map","🔁  Return to Saved Position","Teleport back",function()
    local hrp=getHRP(); if hrp and lastPos then
        pcall(function() hrp.CFrame=lastPos end)
        notify("GLUHFIX","Teleported!",2)
    else notify("GLUHFIX","No position saved",2) end
end)
btn("Map","🗑  Remove Marker  — remove all","Delete marker completely",function()
    removeAllMarkers()
    notify("GLUHFIX","Marker removed ✓",2)
end)
sec("Map","Workspace Tools")
btn("Map","Highlight All Parts  (5s)","SelectionBox on all parts for 5s",function()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then pcall(function()
            local s=Instance.new("SelectionBox");s.Adornee=v;s.Color3=T.accent
            s.LineThickness=.04;s.SurfaceTransparency=.88;s.SurfaceColor3=T.accent
            s.Parent=gui;Debris:AddItem(s,5)
        end) end
    end
end)

---- SCRIPTE ----
sec("Scripte","Scripts")
note("Scripte","Press a button to execute the script")

btn("Scripte","🎯  Fling Script  —  execute","Loads and starts the Ultimate Fling GUI Script",function()
    notify("GLUHFIX","Fling Script loading...",3)
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/K1LAS1K/Ultimate-Fling-GUI/main/flingscript.lua"))()
        end)
    end)
end)

btn("Scripte","⚔️  Rivalen Script  —  execute","Loads and starts the Rivalen Script",function()
    notify("GLUHFIX","Rivalen Script loading...",3)
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/zWhb1mMS"))()
        end)
    end)
end)

---- KEYBINDS ----
sec("Keybinds","Universal Keybind System")
note("Keybinds","Click pill = rebind  ·  Right-click = remove")
note("Keybinds","Supports: any key, LMB, RMB")
local allKbFeats={
    {"fly","Fly"},{"noclip","Noclip"},{"speed","Speed Boost"},{"highJump","High Jump"},
    {"aimbot","Aimbot (hold)"},{"esp","Toggle ESP"},{"invisible","Invisible"},
    {"fullbright","Fullbright"},{"spinBot","Spinbot"},{"bunnyHop","Bunny Hop"},
    {"crosshair","Crosshair"},{"infinite_jump","Infinite Jump"},{"headless","Headless"},
    {"antiLag","Anti-Lag"},{"freezeTime","Freeze Time"},{"antiAfk","Anti-AFK"},
}
for _,pair in ipairs(allKbFeats) do kbWidget("Keybinds",pair[1],pair[2]) end

---- CONFIG ----
sec("Config","Config & Save")
note("Config","All settings save automatically.")
btn("Config","💾  Save Now","Save all settings",function() saveConfig(); notify("GLUHFIX","Config saved! ✓",3) end)
btn("Config","🔄  Reset Config","Clear all saved values",function()
    pcall(function()
        local attrs=lp:GetAttributes()
        for attr,_ in pairs(attrs) do
            if tostring(attr):sub(1,5)=="GF10_" then pcall(function() lp:SetAttribute(attr,nil) end) end
        end
    end)
    notify("GLUHFIX","Config reset! Restart script.",3)
end)
sec("Config","Active Features Overview")
local statusLabels={}
local sfFN={{"fly","Fly"},{"noclip","Noclip"},{"speed","Speed"},{"highJump","High Jump"},{"spinBot","Spinbot"},{"bunnyHop","BHop"},{"autoJump","Auto Jump"},{"infinite_jump","Inf Jump"},{"antiAfk","Anti-AFK"},{"antiLag","Anti-Lag"},{"aimbot","Aimbot"},{"aimbotVisCheck","Vis Check"},{"antiKick","Anti-Kick"},{"antiDetect","Anti-Detect"},{"invisible","Invisible"},{"headless","Headless"},{"esp","ESP"},{"fullbright","Fullbright"},{"noFog","No Fog"},{"crosshair","Crosshair"},{"freezeTime","Freeze Time"}}
local stF=mk("Frame",{Size=UDim2.new(1,0,0,#sfFN*24+14),BackgroundColor3=T.accDark,BorderSizePixel=0},tabScrolls["Config"])
rnd(stF,10); mk("UIListLayout",{Padding=UDim.new(0,2)},stF); pad(stF,10,10,6,6)
for _,pair in ipairs(sfFN) do
    local k,n=pair[1],pair[2]
    local row=mk("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1},stF)
    mk("TextLabel",{Text=n,Size=UDim2.new(.7,0,1,0),BackgroundTransparency=1,TextColor3=T.dim,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},row)
    local vl=mk("TextLabel",{Text="off",Size=UDim2.new(.3,0,1,0),Position=UDim2.new(.7,0,0,0),BackgroundTransparency=1,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right},row)
    statusLabels[k]=vl
end
btn("Config","📋  Print Config to Output","Prints all values to F9",function()
    print("=== GLUHFIX v10.0 Config ===")
    for k,v in pairs(CFG) do if type(v)=="boolean" or type(v)=="number" then print(("  %-26s = %s"):format(k,tostring(v))) end end
    notify("GLUHFIX","Printed to Output (F9)",3)
end)

---- SETTINGS ----
sec("Settings","Toggle Key")
local kbD=mk("TextLabel",{
    Text="Menu Toggle:  [ "..(tostring(CFG.toggleKey):match("%.(%a+)$") or "Insert").." ]",
    Size=UDim2.new(1,0,0,36),BackgroundColor3=T.accDark,TextColor3=T.accent,
    TextSize=13,Font=Enum.Font.GothamBold,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Center},tabScrolls["Settings"])
rnd(kbD,10); mk("UIStroke",{Color=T.border,Thickness=1.2},kbD)
rTC(function() kbD.BackgroundColor3=T.accDark; kbD.TextColor3=T.accent end)
btn("Settings","Bind Toggle Key","Press any key",function()
    kbD.Text="Press any key..."; kbD.TextColor3=T.orange
    local c; c=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            CFG.toggleKey=inp.KeyCode
            local kn=tostring(inp.KeyCode):match("%.(%a+)$") or "?"
            kbD.Text="Menu Toggle:  [ "..kn.." ]"; kbD.TextColor3=T.accent
            updateToggleDisp(); c:Disconnect(); saveConfig()
        end
    end)
end)
sec("Settings","Theme")
sld("Settings","Accent Hue %",0,100,math.floor(CFG.accentH*100),1,"Color hue",function(v) CFG.accentH=v/100;refreshT();pcall(function() winStroke.Color=T.accent end);saveConfig() end)
sld("Settings","Saturation %",0,100,math.floor(CFG.accentS*100),1,"Saturation",function(v) CFG.accentS=v/100;refreshT();saveConfig() end)
note("Settings","Quick presets:")
local function thB(l,h,s) btn("Settings",l,nil,function() CFG.accentH=h;CFG.accentS=s;refreshT();pcall(function() winStroke.Color=T.accent end);saveConfig() end) end
thB("⬜  White / Black (Default)",0.0,0.0)
thB("🔵  Blue — Hacker",0.60,0.95)
thB("🟣  Purple",0.72,0.88)
thB("🩵  Cyan",0.52,0.90)
thB("🟢  Green",0.36,0.90)
thB("🔴  Red",0.00,0.90)
thB("🟠  Orange",0.07,1.00)
thB("🩷  Pink",0.88,0.85)
sec("Settings","Layout")
btn("Settings","⊞  Switch to Sidebar Layout","Wide sidebar tab view",function()
    CFG.layoutMode="sidebar"; saveConfig(); notify("GLUHFIX","Sidebar layout — restart",3)
end)
btn("Settings","≡  Switch to Classic Layout","Top tab bar",function()
    CFG.layoutMode="classic"; saveConfig(); notify("GLUHFIX","Classic layout — restart",3)
end)
sec("Settings","⚡ FPS Booster")
note("Settings","FPS Booster starts automatically on script load")
btn("Settings","🚀  FPS Boost  —  apply again","Maximize FPS: kills particles, shadows, effects",function()
    applyMaxFPS(); notify("GLUHFIX","MAX FPS Booster applied! ✓",4)
end)
note("Settings","Disables: GlobalShadows, Bloom, Fog, Particles, Atmosphere, DoF")
sec("Settings","Info & Tools")
tog("Settings","Coordinates","showCoords","XYZ on screen",nil)
tog("Settings","FPS Counter","showFPS","FPS on screen",nil)
tog("Settings","Chat Spy","chatSpy","Log chat to output",nil)
btn("Settings","Re-apply All Features","Re-apply active features after respawn",function()
    if CFG.invisible then applyInvis(true) end
    if CFG.headless then applyHeadless(true) end
    if CFG.fullbright then applyFullbright(true) end
    if CFG.antiLag then applyAntiLag(true) end
    local h=getHum()
    if h then
        if CFG.speed then pcall(function() h.WalkSpeed=CFG.speedMult end) end
        if CFG.highJump then pcall(function() h.UseJumpPower=true; h.JumpPower=CFG.jumpPower end) end
    end; notify("GLUHFIX","Re-applied!",2)
end)

-- ============================================================
-- LAYOUT SWITCHER
-- ============================================================
local classicActive=false
layoutBtn.MouseButton1Click:Connect(function()
    classicActive=not classicActive
    if classicActive then
        tw(Sidebar,.2,{Size=UDim2.new(0,0,1,-50)})
        tw(ContentArea,.2,{Size=UDim2.new(1,0,1,-50),Position=UDim2.new(0,0,0,50)})
        layoutBtn.Text="≡"
    else
        tw(Sidebar,.2,{Size=UDim2.new(0,SIDEBAR_W,1,-50)})
        tw(ContentArea,.2,{Size=UDim2.new(1,-SIDEBAR_W,1,-50),Position=UDim2.new(0,SIDEBAR_W,0,50)})
        layoutBtn.Text="⊞"
    end
end)

-- ============================================================
-- CHAT SPY
-- ============================================================
for _,p in ipairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(msg) if CFG.chatSpy then print("[CHAT]["..p.Name.."]: "..msg) end end)
end
Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(msg) if CFG.chatSpy then print("[CHAT]["..p.Name.."]: "..msg) end end)
end)

-- ============================================================
-- RESPAWN HANDLER
-- ============================================================
lp.CharacterAdded:Connect(function(c)
    task.wait(.65)
    cacheNoclipParts()
    if CFG.invisible then applyInvis(true) end
    if CFG.headless then applyHeadless(true) end
    if CFG.fullbright then applyFullbright(true) end
    if CFG.antiLag then applyAntiLag(true) end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then
        if CFG.speed then pcall(function() h.WalkSpeed=CFG.speedMult end) end
        if CFG.highJump then pcall(function() h.UseJumpPower=true; h.JumpPower=CFG.jumpPower end) end
    end
    if CFG.fly then stopFly(); task.wait(.1); startFly() end
    if CFG.noclip then stopNoclip(); startNoclip() end
    if CFG.bunnyHop then stopBhop(); task.wait(.1); startBhop() end
    if CFG.freezeTime then applyFreezeTime(true) end
end)

-- ============================================================
-- MENU TOGGLE KEYBIND
-- ============================================================
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==CFG.toggleKey then showWin(not Win.Visible) end
end)

-- ============================================================
-- INIT
-- ============================================================
switchTab("Move")
Win.Visible=false
Win.Size=UDim2.new(0,WIN_W,0,WIN_H)

-- Sofort öffnen (kein Passwort mehr)
task.spawn(function()
    task.wait(0.1)
    showWin(true)
end)

print("⚡ GLUHFIX v10.0 loaded — Hello, "..lp.Name)
print("  Toggle: ["..tostring(CFG.toggleKey):match("%.(%a+)$").."]")
print("  ESP v10.1: Rate="..ESP_REFRESH_RATE.."f BB="..BB_REFRESH_RATE.."f | Corner Box FIXED | Pool=40/14")
