--[[
  ⚡ GLUHFIX V11.1
  Toggle: [Left Control]
  Style: Ambani-inspired - 2-column panel, pink accent
]]

-- ============================================================
-- MOBILE BLOCK
-- ============================================================
do
    local UIS = game:GetService("UserInputService")
    local GS  = game:GetService("GuiService")
    if UIS.TouchEnabled or GS:IsTenFootInterface() then
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="GLUHFIX V11.1",Text="Not supported on Mobile/iOS.",Duration=6})
        return
    end
end

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
-- CONFIG
-- ============================================================
local CFG = {
    toggleKey=Enum.KeyCode.LeftControl,
    fly=false, flySpeed=80,
    noclip=false,
    speed=false, speedMult=24,
    highJump=false, jumpPower=180,
    infinite_jump=false,
    bunnyHop=false,
    autoJump=false,
    spinBot=false, spinSpeed=12,
    antiAfk=false,
    antiLag=false,
    removeAnims=false,
    freecam=false,
    aimbot=false, aimbotFOV=120, aimbotSmooth=18, aimbotBone="Head",
    aimbotVisCheck=true, aimbotActivationMode="hold",
    triggerbot=false, triggerbotDelay=80,
    showFovCircle=true,
    antiKick=false, antiDetect=false,
    invisible=false, headless=false,
    soloSession=false,
    esp=false, espHealth=true, espNames=true, espDist=true,
    espChams=false, espCorner=true, espSkeleton=false,
    espHeadDot=false, espBoxFull=false, espTracer=false,
    espClean=false, espMaxDist=600,
    espColorH=0, espColorS=0, espColorV=1, espLineThick=2,
    fullbright=false, noFog=false,
    crosshair=false, crosshairStyle=1, crosshairColorH=0, crosshairSize=22,
    freezeTime=false, frozenTime=14,
    showCoords=true, showFPS=true, chatSpy=false,
    scannerRange=200, scannerAuto=false, scannerInterval=30,
    menuBlur=false,
    accentH=0.92, accentS=0.85,
    gravity=196,
    keybinds={},
    radar=false, radarSize=200, radarZoom=60, radarShowNames=false,
    _origBright=Lighting.Brightness, _origFogEnd=Lighting.FogEnd,
    _origAmbient=Lighting.Ambient, _origOutdoor=Lighting.OutdoorAmbient,
}

-- ============================================================
-- SAVE / LOAD
-- ============================================================
local function saveConfig()
    pcall(function()
        local nums={"flySpeed","speedMult","jumpPower","spinSpeed","aimbotFOV","aimbotSmooth","espMaxDist","espColorH","espColorS","espColorV","espLineThick","crosshairStyle","crosshairColorH","crosshairSize","frozenTime","gravity","scannerRange","scannerInterval","triggerbotDelay","accentH","accentS","radarSize","radarZoom"}
        for _,k in ipairs(nums) do lp:SetAttribute("GF11_"..k,tostring(CFG[k])) end
        local bools={"fly","noclip","speed","highJump","spinBot","bunnyHop","autoJump","antiAfk","antiLag","infinite_jump","aimbot","aimbotVisCheck","antiKick","antiDetect","invisible","headless","freecam","removeAnims","soloSession","esp","espHealth","espNames","espDist","espChams","espCorner","espSkeleton","espHeadDot","espBoxFull","espTracer","espClean","fullbright","noFog","crosshair","freezeTime","showCoords","showFPS","chatSpy","scannerAuto","triggerbot","showFovCircle","menuBlur","radar","radarShowNames"}
        for _,k in ipairs(bools) do lp:SetAttribute("GF11_b_"..k,CFG[k] and "1" or "0") end
        lp:SetAttribute("GF11_toggleKey",tostring(CFG.toggleKey):match("%.(%a+)$") or "LeftControl")
        lp:SetAttribute("GF11_aimbotActivationMode",CFG.aimbotActivationMode)
    end)
end

local function loadConfig()
    pcall(function()
        local nums={"flySpeed","speedMult","jumpPower","spinSpeed","aimbotFOV","aimbotSmooth","espMaxDist","espColorH","espColorS","espColorV","espLineThick","crosshairStyle","crosshairColorH","crosshairSize","frozenTime","gravity","scannerRange","scannerInterval","triggerbotDelay","accentH","accentS","radarSize","radarZoom"}
        for _,k in ipairs(nums) do local v=lp:GetAttribute("GF11_"..k); if v then CFG[k]=tonumber(v) or CFG[k] end end
        local bools={"fly","noclip","speed","highJump","spinBot","bunnyHop","autoJump","antiAfk","antiLag","infinite_jump","aimbot","aimbotVisCheck","antiKick","antiDetect","invisible","headless","freecam","removeAnims","soloSession","esp","espHealth","espNames","espDist","espChams","espCorner","espSkeleton","espHeadDot","espBoxFull","espTracer","espClean","fullbright","noFog","crosshair","freezeTime","showCoords","showFPS","chatSpy","scannerAuto","triggerbot","showFovCircle","menuBlur","radar","radarShowNames"}
        for _,k in ipairs(bools) do local v=lp:GetAttribute("GF11_b_"..k); if v then CFG[k]=(v=="1") end end
        local tk=lp:GetAttribute("GF11_toggleKey")
        if tk then local ok,kc=pcall(function() return Enum.KeyCode[tk] end); if ok and kc then CFG.toggleKey=kc end end
        local am=lp:GetAttribute("GF11_aimbotActivationMode"); if am then CFG.aimbotActivationMode=am end
    end)
end
loadConfig()

-- ============================================================
-- THEME  (pink default)
-- ============================================================
local PINK   = Color3.fromHSV(CFG.accentH, CFG.accentS, 1)
local PINK2  = Color3.fromHSV(CFG.accentH, CFG.accentS*0.5, 0.9)
local PINKD  = Color3.fromHSV(CFG.accentH, CFG.accentS*0.9, 0.10)
local BG     = Color3.fromRGB(15,15,18)
local SIDE   = Color3.fromRGB(11,11,14)
local PANEL  = Color3.fromRGB(19,19,23)
local ROW    = Color3.fromRGB(22,22,27)
local ROWH   = Color3.fromRGB(30,30,36)
local BORDER = Color3.fromRGB(34,34,42)
local TXT    = Color3.fromRGB(225,225,232)
local DIM    = Color3.fromRGB(135,135,150)
local GREEN  = Color3.fromRGB(50,210,100)
local RED    = Color3.fromRGB(255,50,70)
local WHITE  = Color3.fromRGB(255,255,255)

local thCBs={}
local function rTC(fn) table.insert(thCBs,fn) end
local function refreshT()
    PINK=Color3.fromHSV(CFG.accentH,CFG.accentS,1)
    PINK2=Color3.fromHSV(CFG.accentH,CFG.accentS*0.6,1)
    PINKD=Color3.fromHSV(CFG.accentH,CFG.accentS*0.8,0.14)
    for _,cb in ipairs(thCBs) do pcall(cb) end
end

-- ============================================================
-- GUI ROOT
-- ============================================================
pcall(function() local cg=game:GetService("CoreGui"); local old=cg:FindFirstChild("GF11"); if old then old:Destroy() end end)
if lp.PlayerGui:FindFirstChild("GF11") then lp.PlayerGui.GF10:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="GF11"; gui.ResetOnSpawn=false; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset=true; gui.DisplayOrder=999990
pcall(function() gui.Parent=game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent=lp.PlayerGui end

local function mk(cls,props,parent)
    local o=Instance.new(cls)
    for k,v in pairs(props or {}) do pcall(function() o[k]=v end) end
    if parent then o.Parent=parent end; return o
end
local function rnd(o,r) mk("UICorner",{CornerRadius=UDim.new(0,r or 8)},o) end
local function tw(o,t,p,es,ed) TweenService:Create(o,TweenInfo.new(t,es or Enum.EasingStyle.Quart,ed or Enum.EasingDirection.Out),p):Play() end
local function pad(o,l,r,t,b)
    local p=mk("UIPadding",{},o)
    if l then p.PaddingLeft=UDim.new(0,l) end; if r then p.PaddingRight=UDim.new(0,r) end
    if t then p.PaddingTop=UDim.new(0,t) end;  if b then p.PaddingBottom=UDim.new(0,b) end
end
local function notify(ti,tx,d) pcall(function() StarterGui:SetCore("SendNotification",{Title=ti,Text=tx,Duration=d or 3}) end) end

-- ============================================================
-- WINDOW
-- ============================================================
local WIN_W,WIN_H = 860,580
local SIDEBAR_W   = 148
local _guiUnlocked = true
local freecamActive = false

local Win=mk("Frame",{Size=UDim2.new(0,WIN_W,0,WIN_H),AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,0,.5,0),BackgroundColor3=BG,BorderSizePixel=0,Visible=false},gui)
rnd(Win,14)
local winStroke=mk("UIStroke",{Color=Color3.fromRGB(45,45,55),Thickness=1},Win)

-- HEADER
local Hdr=mk("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=Color3.fromRGB(11,11,14),BorderSizePixel=0},Win)
rnd(Hdr,14)
mk("Frame",{Size=UDim2.new(1,0,.5,0),Position=UDim2.new(0,0,.5,0),BackgroundColor3=Color3.fromRGB(11,11,14),BorderSizePixel=0},Hdr)
local hLine=mk("Frame",{Size=UDim2.new(1,0,0,1.5),Position=UDim2.new(0,0,1,-1.5),BackgroundColor3=PINK,BorderSizePixel=0},Hdr)
rTC(function() hLine.BackgroundColor3=PINK end)

local logoF=mk("Frame",{Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,10,0,8),BackgroundColor3=PINK,BorderSizePixel=0},Hdr)
rnd(logoF,7); rTC(function() logoF.BackgroundColor3=PINK end)
mk("TextLabel",{Text="G",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=BG,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=2},logoF)
mk("TextLabel",{Text="GLUHFIX",Size=UDim2.new(0,120,0,22),Position=UDim2.new(0,44,0,4),BackgroundTransparency=1,TextColor3=WHITE,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},Hdr)
local verLbl=mk("TextLabel",{Text="V11.1",Size=UDim2.new(0,50,0,22),Position=UDim2.new(0,136,0,4),BackgroundTransparency=1,TextColor3=PINK,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},Hdr)
rTC(function() if verLbl then verLbl.TextColor3=PINK end end)

-- ONLINE pill
local sPill=mk("Frame",{Size=UDim2.new(0,62,0,16),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-82,.5,0),BackgroundColor3=Color3.fromRGB(18,5,28),BorderSizePixel=0},Hdr)
rnd(sPill,8); local sPillStroke=mk("UIStroke",{Color=PINK,Thickness=1.2},sPill)
local sPillTxt=mk("TextLabel",{Text="● ONLINE",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=PINK,TextSize=10,Font=Enum.Font.GothamBold},sPill)
task.spawn(function()
    local t2=0
    while sPill and sPill.Parent do
        t2=t2+0.04
        local p=(math.sin(t2)+1)/2
        local h=0.72+p*0.20
        local col=Color3.fromHSV(h,0.90,1)
        local bgCol=Color3.fromHSV(h,0.90,0.14)
        pcall(function()
            sPillTxt.TextColor3=col
            sPill.BackgroundColor3=bgCol
            sPillStroke.Color=col
            sPillStroke.Thickness=1.0+p*0.8
        end); task.wait(0.033)
    end
end)

-- ============================================================
-- MINIMIZE BUTTON  (larger, more visible stripe at top of window)
-- ============================================================
-- The clickable minimize button in the header - made bigger
local minBtn=mk("TextButton",{
    Text="─── MINIMIZE ───",
    Size=UDim2.new(0,140,0,28),
    AnchorPoint=Vector2.new(1,.5),
    Position=UDim2.new(1,-8,.5,0),
    BackgroundColor3=Color3.fromRGB(22,22,30),
    TextColor3=Color3.fromRGB(200,200,220),
    TextSize=11,
    Font=Enum.Font.GothamBold,
    BorderSizePixel=0,
    ZIndex=5,
},Hdr)
rnd(minBtn,6)
mk("UIStroke",{Color=Color3.fromRGB(50,50,65),Thickness=1},minBtn)
minBtn.MouseEnter:Connect(function()
    tw(minBtn,.08,{BackgroundColor3=Color3.fromRGB(35,35,48)})
    minBtn.TextColor3=WHITE
end)
minBtn.MouseLeave:Connect(function()
    tw(minBtn,.08,{BackgroundColor3=Color3.fromRGB(22,22,30)})
    minBtn.TextColor3=Color3.fromRGB(200,200,220)
end)

-- The floating "GF" bubble that appears when minimized - also bigger
local MiniBtn=mk("TextButton",{
    Text="GF",
    Size=UDim2.new(0,56,0,56),
    Position=UDim2.new(0,10,.5,-28),
    BackgroundColor3=PINK,
    TextColor3=BG,
    TextSize=16,
    Font=Enum.Font.GothamBold,
    BorderSizePixel=0,
    Visible=false,
    ZIndex=200,
},gui)
rnd(MiniBtn,28)
rTC(function() MiniBtn.BackgroundColor3=PINK; MiniBtn.TextColor3=BG end)
-- Pulsing stroke on the mini button so it's easy to spot
local miniStroke=mk("UIStroke",{Color=PINK,Thickness=2,Transparency=0.3},MiniBtn)
rTC(function() miniStroke.Color=PINK end)
task.spawn(function()
    local t=0
    while MiniBtn and MiniBtn.Parent do
        t=t+0.05
        local p=(math.sin(t)+1)/2
        pcall(function()
            miniStroke.Thickness=1.5+p*2.5
            miniStroke.Transparency=0.2+p*0.5
        end)
        task.wait(0.033)
    end
end)

local function showWin(v)
    if not _guiUnlocked then return end
    if v then
        pcall(function() UserInputService.MouseBehavior=Enum.MouseBehavior.Default end)
        Win.Visible=true; Win.Size=UDim2.new(0,WIN_W,0,0)
        tw(Win,.20,{Size=UDim2.new(0,WIN_W,0,WIN_H)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        MiniBtn.Visible=false
    else
        tw(Win,.16,{Size=UDim2.new(0,WIN_W,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        task.delay(.17,function() Win.Visible=false; MiniBtn.Visible=not freecamActive end)
    end
end
minBtn.MouseButton1Click:Connect(function() showWin(false) end)
MiniBtn.MouseButton1Click:Connect(function() showWin(true) end)

do -- drag
    local drag,ds,sp=false
    Hdr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;ds=i.Position;sp=Win.Position end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds; Win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
end

-- ============================================================
-- SIDEBAR
-- ============================================================
local Sidebar=mk("Frame",{Size=UDim2.new(0,SIDEBAR_W,1,-40),Position=UDim2.new(0,0,0,40),BackgroundColor3=Color3.fromRGB(11,11,14),BorderSizePixel=0},Win)
mk("UIStroke",{Color=Color3.fromRGB(28,28,34),Thickness=1},Sidebar)
mk("UIListLayout",{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder},Sidebar)
pad(Sidebar,4,4,8,6)

local ContentArea=mk("Frame",{Size=UDim2.new(1,-SIDEBAR_W,1,-40),Position=UDim2.new(0,SIDEBAR_W,0,40),BackgroundColor3=Color3.fromRGB(15,15,18),BorderSizePixel=0,ClipsDescendants=true},Win)

local tabFrames={}; local activeTab=""; local sideTabBtns={}
local togRefreshRegistry={}

local TABS={
    {id="Move",    icon="✈", label="Movement",  order=1},
    {id="Combat",  icon="⚔", label="Combat",    order=2},
    {id="Visual",  icon="👁", label="Visual",    order=3},
    {id="ESP",     icon="👾", label="ESP",       order=4},
    {id="World",   icon="🌍", label="World",     order=5},
    {id="Player",  icon="👤", label="Player",    order=6},
    {id="Scanner", icon="📡", label="Scanner",   order=7},
    {id="Map",     icon="🗺", label="Map",       order=8},
    {id="Scripts", icon="📜", label="Scripts",   order=9},
    {id="Keybinds",icon="⌨", label="Keybinds",  order=10},
    {id="Config",  icon="💾", label="Config",    order=11},
    {id="Settings",icon="⚙", label="Settings",  order=12},
}

local function makeTabFrame()
    local fr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,Visible=false},ContentArea)
    local lsf=mk("ScrollingFrame",{Size=UDim2.new(.48,0,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=Color3.fromRGB(55,55,65),CanvasSize=UDim2.new(0,0,0,0)},fr)
    local lll=mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},lsf)
    pad(lsf,8,6,8,8)
    lll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() lsf.CanvasSize=UDim2.new(0,0,0,lll.AbsoluteContentSize.Y+20) end)
    mk("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(.48,0,0,0),BackgroundColor3=Color3.fromRGB(26,26,32),BorderSizePixel=0},fr)
    local rsf=mk("ScrollingFrame",{Size=UDim2.new(.52,-2,1,0),Position=UDim2.new(.48,2,0,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=2,ScrollBarImageColor3=Color3.fromRGB(55,55,65),CanvasSize=UDim2.new(0,0,0,0)},fr)
    local rll=mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},rsf)
    pad(rsf,6,10,8,8)
    rll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() rsf.CanvasSize=UDim2.new(0,0,0,rll.AbsoluteContentSize.Y+20) end)
    return fr, lsf, rsf
end

local tabL={}
local tabR={}

for _,t in ipairs(TABS) do
    local fr,lsf,rsf=makeTabFrame()
    tabFrames[t.id]=fr; tabL[t.id]=lsf; tabR[t.id]=rsf

    local b=mk("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=t.order},Sidebar)
    local bar=mk("Frame",{Size=UDim2.new(0,2,0,0),AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),BackgroundColor3=PINK,BorderSizePixel=0},b)
    rTC(function() bar.BackgroundColor3=PINK end)
    local lbl=mk("TextLabel",{Text=t.label,Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(225,225,235),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},b)
    local hit=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=3},b)
    hit.MouseEnter:Connect(function() if activeTab~=t.id then lbl.TextColor3=Color3.fromRGB(240,240,248) end end)
    hit.MouseLeave:Connect(function() if activeTab~=t.id then lbl.TextColor3=Color3.fromRGB(225,225,235) end end)
    hit.MouseButton1Click:Connect(function()
        if activeTab==t.id then return end; activeTab=t.id
        for n,btn2 in pairs(sideTabBtns) do
            local on=(n==t.id)
            local barX=btn2:FindFirstChildOfClass("Frame")
            for _,child in ipairs(btn2:GetDescendants()) do
                if child:IsA("TextLabel") then child.TextColor3=on and PINK or Color3.fromRGB(225,225,235) end
            end
            if barX then barX.Size=on and UDim2.new(0,2,0,18) or UDim2.new(0,2,0,0) end
            tw(btn2,.1,{BackgroundColor3=on and Color3.fromRGB(22,22,28) or Color3.fromRGB(0,0,0),BackgroundTransparency=on and 0 or 1})
        end
        for n,f in pairs(tabFrames) do f.Visible=(n==t.id) end
    end)
    sideTabBtns[t.id]=b
end

local function switchTab(id)
    if activeTab==id then return end; activeTab=id
    for n,btn2 in pairs(sideTabBtns) do
        local on=(n==id)
        local barX=btn2:FindFirstChildOfClass("Frame")
        if barX then barX.Size=on and UDim2.new(0,2,0,18) or UDim2.new(0,2,0,0) end
        tw(btn2,.1,{BackgroundColor3=on and Color3.fromRGB(22,22,28) or Color3.fromRGB(0,0,0),BackgroundTransparency=on and 0 or 1})
        for _,child in ipairs(btn2:GetDescendants()) do
            if child:IsA("TextLabel") then child.TextColor3=on and PINK or Color3.fromRGB(225,225,235) end
        end
    end
    for n,f in pairs(tabFrames) do f.Visible=(n==id) end
end

-- ============================================================
-- WIDGET BUILDERS
-- ============================================================
local function sec(sf, title)
    local f=mk("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,BorderSizePixel=0},sf)
    local l=mk("TextLabel",{Text=title:upper(),Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(135,135,150),TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},f)
    mk("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=BORDER,BorderSizePixel=0},f)
end

local function tog(sf, label, key, tipTxt, cb)
    local row=mk("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},sf)
    rnd(row,6)
    local hb=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=3},row)
    hb.MouseEnter:Connect(function() tw(row,.08,{BackgroundColor3=Color3.fromRGB(26,26,32)}) end)
    hb.MouseLeave:Connect(function() tw(row,.08,{BackgroundColor3=Color3.fromRGB(20,20,24)}) end)
    local lbl=mk("TextLabel",{Text=label,Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(230,230,238),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},row)
    local swBg=mk("Frame",{Size=UDim2.new(0,40,0,20),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),BackgroundColor3=Color3.fromRGB(35,35,42),BorderSizePixel=0,ZIndex=2},row)
    rnd(swBg,10)
    local knob=mk("Frame",{Size=UDim2.new(0,14,0,14),AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,3,.5,0),BackgroundColor3=Color3.fromRGB(90,90,100),BorderSizePixel=0,ZIndex=3},swBg)
    rnd(knob,7)
    local function refresh()
        local on=CFG[key]
        tw(knob,.14,{Position=on and UDim2.new(1,-17,.5,0) or UDim2.new(0,3,.5,0),BackgroundColor3=on and PINK or Color3.fromRGB(90,90,100)})
        tw(swBg,.14,{BackgroundColor3=on and Color3.fromHSV(CFG.accentH,CFG.accentS*0.9,0.18) or Color3.fromRGB(35,35,42)})
        lbl.TextColor3=on and Color3.fromRGB(245,245,250) or Color3.fromRGB(225,225,232)
    end
    rTC(function() refresh() end)
    hb.MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]; refresh()
        if cb then pcall(function() cb(CFG[key]) end) end; saveConfig()
    end)
    refresh()
    if not togRefreshRegistry[key] then togRefreshRegistry[key]={} end
    table.insert(togRefreshRegistry[key],refresh)
    return row, refresh
end

local function sld(sf, label, minV, maxV, defV, step, cb)
    step=step or 1
    local row=mk("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},sf)
    rnd(row,6)
    local lbl=mk("TextLabel",{
        Text=label,
        Size=UDim2.new(1,-52,0,16),
        Position=UDim2.new(0,10,0,6),
        BackgroundTransparency=1,
        TextColor3=Color3.fromRGB(230,230,238),
        TextSize=12,
        Font=Enum.Font.GothamSemibold,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
    },row)
    local valLbl=mk("TextLabel",{
        Text=tostring(defV),
        Size=UDim2.new(0,42,0,16),
        Position=UDim2.new(1,-48,0,6),
        BackgroundTransparency=1,
        TextColor3=PINK,
        TextSize=12,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,
    },row)
    rTC(function() valLbl.TextColor3=PINK end)
    local track=mk("Frame",{Size=UDim2.new(1,-20,0,4),Position=UDim2.new(0,10,0,30),BackgroundColor3=Color3.fromRGB(38,38,46),BorderSizePixel=0},row)
    rnd(track,2)
    local fill=mk("Frame",{Size=UDim2.new((defV-minV)/(maxV-minV),0,1,0),BackgroundColor3=PINK,BorderSizePixel=0},track)
    rnd(fill,2); rTC(function() fill.BackgroundColor3=PINK end)
    local knob=mk("Frame",{Size=UDim2.new(0,12,0,12),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new((defV-minV)/(maxV-minV),0,.5,0),BackgroundColor3=WHITE,BorderSizePixel=0},track)
    rnd(knob,6)
    local dragging=false
    local function update(px)
        local rel=math.clamp((px-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val=math.clamp(math.floor((minV+rel*(maxV-minV))/step+.5)*step,minV,maxV)
        local fr=(val-minV)/(maxV-minV)
        fill.Size=UDim2.new(fr,0,1,0); knob.Position=UDim2.new(fr,0,.5,0)
        valLbl.Text=tostring(val)
        if cb then pcall(function() cb(val) end) end; saveConfig()
    end
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; update(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
end

local function btn(sf, label, cb)
    local b=mk("TextButton",{Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(20,20,24),TextColor3=Color3.fromRGB(220,220,230),TextSize=12,Text=label,Font=Enum.Font.GothamSemibold,BorderSizePixel=0},sf)
    rnd(b,6)
    b.MouseEnter:Connect(function() tw(b,.08,{BackgroundColor3=Color3.fromRGB(28,28,35)}); b.TextColor3=Color3.fromRGB(248,248,252) end)
    b.MouseLeave:Connect(function() tw(b,.08,{BackgroundColor3=Color3.fromRGB(20,20,24)}); b.TextColor3=Color3.fromRGB(220,220,230) end)
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
end

local function note(sf, txt)
    mk("TextLabel",{Text=txt,Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,TextColor3=Color3.fromRGB(95,95,108),TextSize=11,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.new(0,6,0,0),TextWrapped=true},sf)
end

local function kbWidget(sf, featKey, label)
    local row=mk("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},sf)
    rnd(row,6)
    mk("TextLabel",{Text=label,Size=UDim2.new(.6,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(225,225,235),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},row)
    local kb=CFG.keybinds[featKey]
    local function kbDisp() if not kb then return "NONE" end; if kb.type=="key" then return tostring(kb.value):match("%.(%a+)$") or "?" end; return kb.value end
    local pill=mk("Frame",{Size=UDim2.new(0,68,0,22),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),BackgroundColor3=Color3.fromRGB(28,28,36),BorderSizePixel=0,ZIndex=3},row)
    rnd(pill,5)
    local pillTxt=mk("TextLabel",{Text=kbDisp(),Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(210,210,222),TextSize=12,Font=Enum.Font.GothamSemibold,ZIndex=4},pill)
    local listening=false
    local hitBtn=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},pill)
    hitBtn.MouseButton1Click:Connect(function()
        if listening then return end; listening=true; pillTxt.Text="..."; pillTxt.TextColor3=Color3.fromRGB(255,140,0)
        local kconn; kconn=UserInputService.InputBegan:Connect(function(inp,gpe)
            if gpe then return end
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                if inp.KeyCode==Enum.KeyCode.G then pillTxt.Text="BLOCKED"; pillTxt.TextColor3=RED; task.delay(1.2,function() pillTxt.Text=kbDisp(); pillTxt.TextColor3=PINK end); listening=false; kconn:Disconnect(); return end
                CFG.keybinds[featKey]={type="key",value=inp.KeyCode}; kb=CFG.keybinds[featKey]
                pillTxt.Text=kbDisp(); pillTxt.TextColor3=PINK; listening=false; kconn:Disconnect(); saveConfig()
            elseif inp.UserInputType==Enum.UserInputType.MouseButton1 then
                CFG.keybinds[featKey]={type="mouse",value="LMB"}; kb=CFG.keybinds[featKey]
                pillTxt.Text="LMB"; pillTxt.TextColor3=PINK; listening=false; kconn:Disconnect(); saveConfig()
            elseif inp.UserInputType==Enum.UserInputType.MouseButton2 then
                CFG.keybinds[featKey]={type="mouse",value="RMB"}; kb=CFG.keybinds[featKey]
                pillTxt.Text="RMB"; pillTxt.TextColor3=PINK; listening=false; kconn:Disconnect(); saveConfig()
            end
        end)
    end)
    hitBtn.MouseButton2Click:Connect(function() CFG.keybinds[featKey]=nil; kb=nil; pillTxt.Text="NONE"; pillTxt.TextColor3=DIM; saveConfig() end)
end

-- ============================================================
-- FEATURE LOGIC
-- ============================================================
local bypass={}
function bypass.set(obj,prop,val)
    if not obj then return end
    pcall(function() if sethiddenproperty then sethiddenproperty(obj,prop,val) else obj[prop]=val end end)
    pcall(function() obj[prop]=val end)
end

local flyBV,flyBG
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

local ncConn; local ncCachedParts={}
local function startNoclip()
    if ncConn then ncConn:Disconnect() end
    ncCachedParts={}; local c=getChar(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then table.insert(ncCachedParts,p) end end
    ncConn=RunService.Stepped:Connect(function()
        if not CFG.noclip then return end
        for _,p in ipairs(ncCachedParts) do pcall(function() p.CanCollide=false end) end
    end)
end
local function stopNoclip()
    if ncConn then ncConn:Disconnect(); ncConn=nil end
    for _,p in ipairs(ncCachedParts) do pcall(function() p.CanCollide=true end) end; ncCachedParts={}
end

local bhopConn
local function startBhop()
    if bhopConn then bhopConn:Disconnect() end
    local h=getHum(); if not h then return end
    bhopConn=h.StateChanged:Connect(function(_,new)
        if not CFG.bunnyHop then return end
        if new==Enum.HumanoidStateType.Landed then task.wait(); local h2=getHum(); if h2 then pcall(function() h2:ChangeState(Enum.HumanoidStateType.Jumping) end) end end
    end)
end
local function stopBhop() if bhopConn then bhopConn:Disconnect(); bhopConn=nil end end

local function applyFullbright(on)
    pcall(function()
        if on then Lighting.Brightness=10; Lighting.ClockTime=14; Lighting.FogEnd=1e6; Lighting.GlobalShadows=false; Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        else Lighting.Brightness=CFG._origBright; Lighting.FogEnd=CFG._origFogEnd; Lighting.GlobalShadows=true; Lighting.Ambient=CFG._origAmbient; Lighting.OutdoorAmbient=CFG._origOutdoor end
    end)
end

local invisOrigData={}
local function applyInvis(on)
    local c=getChar(); if not c then return end
    if on then
        invisOrigData={}
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function()
                invisOrigData[p]={transparency=p.Transparency}
                local mesh=p:FindFirstChildOfClass("SpecialMesh"); if mesh then invisOrigData[p].meshScale=mesh.Scale; pcall(function() mesh.Scale=Vector3.new(0,0,0) end) end
                p.Transparency=1; pcall(function() p.LocalTransparencyModifier=1 end)
            end)
            elseif p:IsA("Decal") then pcall(function() invisOrigData[p]={transparency=p.Transparency}; p.Transparency=1 end) end
        end
    else
        for obj,data in pairs(invisOrigData) do pcall(function()
            if not obj or not obj.Parent then return end
            if obj:IsA("BasePart") then obj.Transparency=data.transparency or 0; pcall(function() obj.LocalTransparencyModifier=0 end)
                if data.meshScale then local mesh=obj:FindFirstChildOfClass("SpecialMesh"); if mesh then pcall(function() mesh.Scale=data.meshScale end) end end
            elseif obj:IsA("Decal") then obj.Transparency=data.transparency or 0 end
        end) end; invisOrigData={}
    end
end

local hlessBkp={}
local function applyHeadless(on)
    local c=getChar(); if not c then return end; local head=c:FindFirstChild("Head"); if not head then return end
    if on then
        pcall(function() head.Transparency=1 end)
        for _,d in ipairs(head:GetDescendants()) do
            if d:IsA("Decal") then hlessBkp[d]=d.Transparency; pcall(function() d.Transparency=1 end)
            elseif d:IsA("SpecialMesh") then hlessBkp[d]=d.Scale; pcall(function() d.Scale=Vector3.new(0,0,0) end) end
        end
    else
        pcall(function() head.Transparency=0 end)
        for obj,val in pairs(hlessBkp) do pcall(function()
            if obj:IsA("Decal") then obj.Transparency=val elseif obj:IsA("SpecialMesh") then obj.Scale=val end
        end) end; hlessBkp={}
    end
end

local soloSessionData={}
local function hideSoloPlayer(plr)
    if not plr.Character then return end; local data={}
    for _,p in ipairs(plr.Character:GetDescendants()) do pcall(function()
        if p:IsA("BasePart") then data[p]=p.LocalTransparencyModifier; p.LocalTransparencyModifier=1
            if sethiddenproperty then sethiddenproperty(p,"LocalTransparencyModifier",1) end
        elseif p:IsA("Decal") or p:IsA("Texture") then data[p]=p.Transparency; p.Transparency=1
        elseif p:IsA("BillboardGui") then data[p]=p.Enabled; p.Enabled=false end
    end) end
    soloSessionData[plr]=data
end
local function showSoloPlayer(plr)
    local data=soloSessionData[plr]; if not data or not plr.Character then soloSessionData[plr]=nil; return end
    for obj,val in pairs(data) do pcall(function()
        if not obj or not obj.Parent then return end
        if obj:IsA("BasePart") then obj.LocalTransparencyModifier=val; if sethiddenproperty then sethiddenproperty(obj,"LocalTransparencyModifier",val) end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=val
        elseif obj:IsA("BillboardGui") then obj.Enabled=val end
    end) end; soloSessionData[plr]=nil
end
local function applySoloSession(on)
    if on then for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp then hideSoloPlayer(plr) end end
    else for plr,_ in pairs(soloSessionData) do showSoloPlayer(plr) end; soloSessionData={} end
end

local removeAnimsConn
local function applyRemoveAnims(on)
    if removeAnimsConn then removeAnimsConn:Disconnect(); removeAnimsConn=nil end
    local c=getChar(); if not c then return end
    if on then
        local h=getHum(); if h then pcall(function() local a=h:FindFirstChildOfClass("Animator"); if a then for _,t in ipairs(a:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end end end) end
        local animS=c:FindFirstChild("Animate"); if animS then pcall(function() animS.Disabled=true end) end
        removeAnimsConn=RunService.Heartbeat:Connect(function()
            if not CFG.removeAnims then return end
            local h2=getHum(); if not h2 then return end
            pcall(function() local a=h2:FindFirstChildOfClass("Animator"); if a then for _,t in ipairs(a:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end end end)
        end)
    else local animS=c:FindFirstChild("Animate"); if animS then pcall(function() animS.Disabled=false end) end end
end

local freecamPos=Vector3.new(0,10,0); local freecamYaw=0; local freecamPitch=0
local freecamSpeed=40; local freecamSens=0.003
local freecamMouseConn; local freecamStepConn
local function freecamBuildCF() return CFrame.new(freecamPos)*CFrame.Angles(0,freecamYaw,0)*CFrame.Angles(freecamPitch,0,0) end
local function startFreecam()
    freecamActive=true
    local ok,cf=pcall(function() return cam.CFrame end)
    if ok and cf then freecamPos=cf.Position; local lv=cf.LookVector; freecamYaw=math.atan2(-lv.X,-lv.Z); freecamPitch=math.asin(math.clamp(lv.Y,-1,1)) end
    local hrp=getHRP(); if hrp then pcall(function() local old=hrp:FindFirstChild("_GF_FC"); if old then old:Destroy() end; local bv=Instance.new("BodyVelocity"); bv.Name="_GF_FC"; bv.MaxForce=Vector3.new(1e9,1e9,1e9); bv.Velocity=Vector3.zero; bv.Parent=hrp end) end
    pcall(function() local h=getHum(); if h then h.AutoRotate=false end end)
    if freecamMouseConn then freecamMouseConn:Disconnect() end
    freecamMouseConn=UserInputService.InputChanged:Connect(function(inp)
        if not freecamActive or Win.Visible then return end
        if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
        freecamYaw=freecamYaw-inp.Delta.X*freecamSens
        freecamPitch=math.clamp(freecamPitch-inp.Delta.Y*freecamSens,math.rad(-89),math.rad(89))
    end)
    if freecamStepConn then freecamStepConn:Disconnect() end
    freecamStepConn=RunService:BindToRenderStep("GF_Freecam",Enum.RenderPriority.Camera.Value+1,function(dt2)
        if not freecamActive then return end
        pcall(function() cam.CameraType=Enum.CameraType.Scriptable end)
        if Win.Visible then pcall(function() cam.CFrame=freecamBuildCF() end); return end
        pcall(function() UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter end)
        local cf2=freecamBuildCF(); local move=Vector3.zero; local u=UserInputService
        if u:IsKeyDown(Enum.KeyCode.W) then move=move+cf2.LookVector end
        if u:IsKeyDown(Enum.KeyCode.S) then move=move-cf2.LookVector end
        if u:IsKeyDown(Enum.KeyCode.A) then move=move-cf2.RightVector end
        if u:IsKeyDown(Enum.KeyCode.D) then move=move+cf2.RightVector end
        if u:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
        if u:IsKeyDown(Enum.KeyCode.LeftShift) then move=move-Vector3.new(0,1,0) end
        if move.Magnitude>0 then freecamPos=freecamPos+move.Unit*freecamSpeed*dt2 end
        pcall(function() cam.CFrame=freecamBuildCF() end)
        local hrp2=getHRP(); if hrp2 then local anc=hrp2:FindFirstChild("_GF_FC"); if anc and anc:IsA("BodyVelocity") then anc.Velocity=Vector3.zero end end
    end)
end
local function stopFreecam()
    freecamActive=false
    if freecamStepConn then pcall(function() RunService:UnbindFromRenderStep("GF_Freecam") end); freecamStepConn=nil end
    if freecamMouseConn then freecamMouseConn:Disconnect(); freecamMouseConn=nil end
    pcall(function() UserInputService.MouseBehavior=Enum.MouseBehavior.Default end)
    pcall(function() cam.CameraType=Enum.CameraType.Custom; local c=getChar(); if c then local h=c:FindFirstChildOfClass("Humanoid"); if h then cam.CameraSubject=h; h.AutoRotate=true end end end)
    local hrp=getHRP(); if hrp then local anc=hrp:FindFirstChild("_GF_FC"); if anc then anc:Destroy() end end
end

-- AIMBOT
local fovCircle=mk("Frame",{Size=UDim2.new(0,240,0,240),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=50},gui)
rnd(fovCircle,120); local fovStroke=mk("UIStroke",{Color=PINK,Thickness=1.5,Transparency=.4},fovCircle)
rTC(function() fovStroke.Color=PINK end)

-- ============================================================
-- ESP DATA STRUCTURES
-- ============================================================
local espData={}
local espFr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=10},gui)
local skelFr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=11},gui)
local LINE_POOL_SIZE=40; local SKEL_POOL_SIZE=14

local function createPooledLine(parent)
    local f=Instance.new("Frame"); f.BorderSizePixel=0; f.Visible=false; f.ZIndex=15
    f.AnchorPoint=Vector2.new(0.5,0.5); f.Parent=parent; return f
end
local function updateLine(f,ax,ay,bx,by,col,thick)
    local dx,dy=bx-ax,by-ay; local lenSq=dx*dx+dy*dy
    if lenSq<1 then f.Visible=false; return end
    local len=math.sqrt(lenSq); local mx,my=(ax+bx)*.5,(ay+by)*.5
    f.Size=UDim2.new(0,len,0,thick or 1); f.Position=UDim2.new(0,mx,0,my)
    f.Rotation=math.deg(math.atan2(dy,dx)); f.BackgroundColor3=col; f.Visible=true
end
local function hidePool(pool,from) for i=from,#pool do if pool[i] and pool[i].Visible then pool[i].Visible=false end end end
local function drawCBoxPooled(d,x,y,w,h,col,thick)
    local t=thick or CFG.espLineThick; local cl=math.clamp(math.min(w,h)*.20,6,30)
    local x2=x+w; local y2=y+h; local pf
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x,y,x+cl,y,col,t) end
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x,y,x,y+cl,col,t) end
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x2-cl,y,x2,y,col,t) end
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x2,y,x2,y+cl,col,t) end
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x,y2,x+cl,y2,col,t) end
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x,y2-cl,x,y2,col,t) end
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x2-cl,y2,x2,y2,col,t) end
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x2,y2-cl,x2,y2,col,t) end
end
local function drawFBoxPooled(d,x,y,w,h,col,thick)
    local t=thick or CFG.espLineThick; local x2=x+w; local y2=y+h; local pf
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x,y,x2,y,col,t) end
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x,y2,x2,y2,col,t) end
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x,y,x,y2,col,t) end
    d.lineUsed=d.lineUsed+1; pf=d.linePool[d.lineUsed]; if pf then updateLine(pf,x2,y,x2,y2,col,t) end
end

local BBOX_R15={"Head","UpperTorso","LowerTorso","LeftFoot","RightFoot","LeftHand","RightHand"}
local BONES_R15={"Head","UpperTorso","LowerTorso","HumanoidRootPart","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"}
local BBOX_R6={"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
local BONES_R6={"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
local SKEL_R15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local SKEL_R6={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}

local function isR6(char) return char:FindFirstChild("Torso")~=nil end
local function getBBoxBones(char) return isR6(char) and BBOX_R6 or BBOX_R15 end
local function getAllBones(char) return isR6(char) and BONES_R6 or BONES_R15 end
local function getSkelPairs(char) return isR6(char) and SKEL_R6 or SKEL_R15 end
local function getHRPBypass(char) return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChildWhichIsA("BasePart") end
local function getECol() return Color3.fromHSV(CFG.espColorH,CFG.espColorS,CFG.espColorV) end
local function safeParentBB(bb,hrp) local ok=pcall(function() bb.Parent=hrp end); if not ok then pcall(function() local cg=game:GetService("CoreGui"); bb.Adornee=hrp; bb.Parent=cg end) end end

local function ensureESPData(plr,hrp)
    if not espData[plr] then espData[plr]={} end
    local d=espData[plr]
    if not d.bb or not d.bb.Parent then
        local bb=Instance.new("BillboardGui"); bb.AlwaysOnTop=true; bb.Size=UDim2.new(0,165,0,52)
        bb.StudsOffset=Vector3.new(0,3.6,0); bb.LightInfluence=0; bb.ResetOnSpawn=false; safeParentBB(bb,hrp); d.bb=bb
        d.nl=mk("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,TextSize=12,Font=Enum.Font.GothamBold,TextStrokeTransparency=0,TextStrokeColor3=Color3.fromRGB(0,0,0)},bb)
        local hbg=mk("Frame",{Size=UDim2.new(1,0,0,5),Position=UDim2.new(0,0,0,22),BackgroundColor3=Color3.fromRGB(26,4,4),BorderSizePixel=0},bb); rnd(hbg,3)
        d.hpF=mk("Frame",{BackgroundColor3=GREEN,BorderSizePixel=0},hbg); rnd(d.hpF,3)
        d.dl=mk("TextLabel",{Size=UDim2.new(1,0,0,13),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,TextSize=12,Font=Enum.Font.GothamSemibold,TextStrokeTransparency=0,TextColor3=DIM},bb)
        d.bbEnabled=false
    end
    if not d.boxFr or not d.boxFr.Parent then
        d.boxFr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=10},espFr)
        d.linePool={}; for i=1,LINE_POOL_SIZE do d.linePool[i]=createPooledLine(d.boxFr) end; d.lineUsed=0
    end
    if not d.skelFrP or not d.skelFrP.Parent then
        d.skelFrP=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=11},skelFr)
        d.skelPool={}; for i=1,SKEL_POOL_SIZE do d.skelPool[i]=createPooledLine(d.skelFrP) end; d.skelUsed=0
    end
    return d
end

-- Clean ESP
local cleanEspData={}
local function ensureCleanESP(plr)
    if not cleanEspData[plr] then
        cleanEspData[plr]={lines={},bb=nil,nl=nil,hpF=nil,dl=nil,hlInstance=nil}
        for i=1,50 do local ln=mk("Frame",{BackgroundTransparency=0,BorderSizePixel=0,ZIndex=21,Visible=false},gui); cleanEspData[plr].lines[i]=ln end
    end
    return cleanEspData[plr]
end
local function ensureCleanBB(plr,hrp)
    local d=cleanEspData[plr]; if not d then return end
    if not d.bb or not d.bb.Parent then
        local bb=Instance.new("BillboardGui"); bb.AlwaysOnTop=true; bb.Size=UDim2.new(0,165,0,52)
        bb.StudsOffset=Vector3.new(0,3.6,0); bb.LightInfluence=0; bb.ResetOnSpawn=false; safeParentBB(bb,hrp); d.bb=bb
        d.nl=mk("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,TextSize=12,Font=Enum.Font.GothamBold,TextStrokeTransparency=0,TextStrokeColor3=Color3.fromRGB(0,0,0)},bb)
        local hbg=mk("Frame",{Size=UDim2.new(1,0,0,5),Position=UDim2.new(0,0,0,22),BackgroundColor3=Color3.fromRGB(26,4,4),BorderSizePixel=0},bb); rnd(hbg,3)
        d.hpF=mk("Frame",{BackgroundColor3=GREEN,BorderSizePixel=0},hbg); rnd(d.hpF,3)
        d.dl=mk("TextLabel",{Size=UDim2.new(1,0,0,13),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,TextSize=12,Font=Enum.Font.GothamSemibold,TextStrokeTransparency=0,TextColor3=DIM},bb)
        d.bbEnabled=false
    end
end
local function hideCleanESP(plr)
    local d=cleanEspData[plr]; if not d then return end
    for _,ln in ipairs(d.lines) do ln.Visible=false end
    if d.bb and d.bbEnabled then pcall(function() d.bb.Enabled=false end); d.bbEnabled=false end
    if d.hlInstance then pcall(function() d.hlInstance:Destroy() end); d.hlInstance=nil end
end
local function drawCleanESP(plr,col,thick,dist,hum)
    local d=cleanEspData[plr]; if not d then return end
    if not plr.Character then hideCleanESP(plr); return end
    local char=plr.Character
    local allParts={"Head","UpperTorso","LowerTorso","Torso","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot","Left Arm","Right Arm","Left Leg","Right Leg","HumanoidRootPart"}
    local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
    local anyVis=false; local bonePos2D={}
    for _,pn in ipairs(allParts) do
        local pt=char:FindFirstChild(pn)
        if pt and pt:IsA("BasePart") then
            local sz=pt.Size; local cf2=pt.CFrame
            local corners={cf2*CFrame.new(sz.X/2,sz.Y/2,sz.Z/2),cf2*CFrame.new(-sz.X/2,sz.Y/2,sz.Z/2),cf2*CFrame.new(sz.X/2,-sz.Y/2,sz.Z/2),cf2*CFrame.new(-sz.X/2,-sz.Y/2,sz.Z/2),cf2*CFrame.new(sz.X/2,sz.Y/2,-sz.Z/2),cf2*CFrame.new(-sz.X/2,sz.Y/2,-sz.Z/2),cf2*CFrame.new(sz.X/2,-sz.Y/2,-sz.Z/2),cf2*CFrame.new(-sz.X/2,-sz.Y/2,-sz.Z/2)}
            for _,corner in ipairs(corners) do
                local ok2,sp,vis=pcall(function() return cam:WorldToViewportPoint(corner.Position) end)
                if ok2 and vis and sp.Z>0 then anyVis=true; if sp.X<minX then minX=sp.X end; if sp.Y<minY then minY=sp.Y end; if sp.X>maxX then maxX=sp.X end; if sp.Y>maxY then maxY=sp.Y end end
            end
            local ok2,sp2,vis2=pcall(function() return cam:WorldToViewportPoint(pt.Position) end)
            if ok2 and vis2 and sp2.Z>0 then bonePos2D[pn]=Vector2.new(sp2.X,sp2.Y) end
        end
    end
    if not anyVis then hideCleanESP(plr); return end
    local lns=d.lines; local lineIdx=0
    local function nextLine()
        lineIdx=lineIdx+1; local ln=lns[lineIdx]
        if not ln then ln=mk("Frame",{BackgroundTransparency=0,BorderSizePixel=0,ZIndex=21,Visible=false},gui); lns[lineIdx]=ln end
        return ln
    end
    local function drawLine2D(ax,ay,bx,by,c2,t2)
        local ln=nextLine(); local dx,dy=bx-ax,by-ay; local len=math.sqrt(dx*dx+dy*dy)
        if len<1 then ln.Visible=false; return end
        ln.Size=UDim2.new(0,len,0,t2); ln.Position=UDim2.new(0,(ax+bx)*.5,0,(ay+by)*.5)
        ln.AnchorPoint=Vector2.new(0.5,0.5); ln.Rotation=math.deg(math.atan2(dy,dx)); ln.BackgroundColor3=c2; ln.Visible=true
    end
    local t=thick or CFG.espLineThick; local PAD=2
    local x=minX-PAD; local y=minY-PAD; local w=math.max((maxX-minX)+PAD*2,8); local h2=math.max((maxY-minY)+PAD*2,8)
    local x2=x+w; local y2=y+h2; local cl=math.clamp(math.min(w,h2)*.22,5,28)
    if CFG.espCorner then
        drawLine2D(x,y,x+cl,y,col,t); drawLine2D(x,y,x,y+cl,col,t)
        drawLine2D(x2-cl,y,x2,y,col,t); drawLine2D(x2,y,x2,y+cl,col,t)
        drawLine2D(x,y2,x+cl,y2,col,t); drawLine2D(x,y2-cl,x,y2,col,t)
        drawLine2D(x2-cl,y2,x2,y2,col,t); drawLine2D(x2,y2-cl,x2,y2,col,t)
    end
    if CFG.espBoxFull then
        drawLine2D(x,y,x2,y,col,t); drawLine2D(x,y2,x2,y2,col,t)
        drawLine2D(x,y,x,y2,col,t); drawLine2D(x2,y,x2,y2,col,t)
    end
    if CFG.espSkeleton then
        local skelPairs=getSkelPairs(char)
        for _,pair in ipairs(skelPairs) do
            local a=bonePos2D[pair[1]]; local b=bonePos2D[pair[2]]
            if a and b then drawLine2D(a.X,a.Y,b.X,b.Y,col,t) end
        end
    end
    if CFG.espTracer then
        local vp=cam.ViewportSize; local tracerX=vp.X/2; local tracerY=vp.Y
        local ep=bonePos2D["HumanoidRootPart"] or bonePos2D["Torso"] or bonePos2D["UpperTorso"]
        if ep then drawLine2D(tracerX,tracerY,ep.X,ep.Y,col,t) end
    end
    for i=lineIdx+1,#lns do if lns[i] then lns[i].Visible=false end end
    local hrp2=getHRPBypass(char)
    if hrp2 then
        ensureCleanBB(plr,hrp2)
        if not d.bbEnabled then pcall(function() d.bb.Enabled=true end); d.bbEnabled=true end
        if hum then
            local hp=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
            if d.nl then pcall(function() d.nl.Visible=CFG.espNames; d.nl.Text=plr.Name; d.nl.TextColor3=col end) end
            if d.hpF then pcall(function() d.hpF.Parent.Visible=CFG.espHealth; d.hpF.Size=UDim2.new(hp,0,1,0); d.hpF.BackgroundColor3=Color3.fromRGB(math.floor(255*(1-hp)),math.floor(210*hp),55) end) end
            if d.dl then pcall(function() d.dl.Visible=CFG.espDist; d.dl.Text=dist.."m" end) end
        end
    end
    if CFG.espChams then
        if not d.hlInstance or not d.hlInstance.Parent then
            local hl=Instance.new("Highlight"); hl.Adornee=char; hl.FillTransparency=.80; hl.OutlineTransparency=0
            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            local hlOk=pcall(function() hl.Parent=char end)
            if not hlOk then pcall(function() hl.Parent=game:GetService("CoreGui") end) end
            d.hlInstance=hl
        end
        pcall(function() d.hlInstance.FillColor=col; d.hlInstance.OutlineColor=col end)
    else
        if d.hlInstance then pcall(function() d.hlInstance:Destroy() end); d.hlInstance=nil end
    end
end
local function cleanupCleanESP()
    for plr,d in pairs(cleanEspData) do
        if not Players:FindFirstChild(plr.Name) then
            for _,ln in ipairs(d.lines) do pcall(function() ln:Destroy() end) end
            if d.bb then pcall(function() d.bb:Destroy() end) end
            if d.hlInstance then pcall(function() d.hlInstance:Destroy() end) end
            cleanEspData[plr]=nil
        end
    end
end

local espFrameCount=0
task.spawn(function()
    while true do task.wait(300)
        for plr,d in pairs(espData) do
            if d.bb then pcall(function() d.bb:Destroy() end) end
            if d.hl then pcall(function() d.hl:Destroy() end) end
            if d.boxFr then pcall(function() d.boxFr:Destroy() end) end
            if d.skelFrP then pcall(function() d.skelFrP:Destroy() end) end
        end
        espData={}; cleanupCleanESP()
        pcall(function() collectgarbage("collect") end)
    end
end)
local losCastParams=RaycastParams.new(); losCastParams.FilterType=Enum.RaycastFilterType.Exclude
local function updateLOSFilter() local ex={}; local myChar=getChar(); if myChar then table.insert(ex,myChar) end; for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then table.insert(ex,p.Character) end end; pcall(function() losCastParams.FilterDescendantsInstances=ex end) end
local function hasLOS(tp) local hrp=getHRP(); if not hrp then return false end; local dir=(tp-hrp.Position); if dir.Magnitude<0.1 then return true end; local ok,res=pcall(function() return workspace:Raycast(hrp.Position,dir,losCastParams) end); if not ok or not res then return true end; local h=res.Instance; if h and h:IsA("BasePart") then if h.Transparency>=.5 or not h.CanCollide then return true end end; return false end
local aimbotLockedTarget=nil; local aimbotWasHeld=false; local aimbotToggleActive=false; local aimbotTogglePrevDown=false
local function getTargetBone(char) if not char then return nil end; return char:FindFirstChild(CFG.aimbotBone) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") end
local function getClosestTarget() local center=cam.ViewportSize/2; local best,bestDist=nil,CFG.aimbotFOV; updateLOSFilter(); for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp and plr.Character then local hum=plr.Character:FindFirstChildOfClass("Humanoid"); if hum and hum.Health>0 then local bone=getTargetBone(plr.Character); if bone then local ok,pos,vis=pcall(function() return cam:WorldToViewportPoint(bone.Position) end); if ok and vis then local dist=(Vector2.new(pos.X,pos.Y)-center).Magnitude; if dist<bestDist then local can=true; if CFG.aimbotVisCheck then can=hasLOS(bone.Position) end; if can then bestDist=dist; best=bone end end end end end end end; return best end
local function applyAimbotCamera(targetPos) pcall(function() local alpha=math.clamp(CFG.aimbotSmooth/100,0.01,1.0); local camPos=cam.CFrame.Position; local targetCF=CFrame.new(camPos,targetPos); local lerpedCF=cam.CFrame:Lerp(targetCF,alpha); pcall(function() cam.CFrame=CFrame.new(camPos,camPos+lerpedCF.LookVector) end) end) end
local function aimbotStartLock() pcall(function() local hum=getHum(); if hum then hum.AutoRotate=false end end) end
local function aimbotStopLock() pcall(function() local hum=getHum(); if hum then hum.AutoRotate=true end end); aimbotLockedTarget=nil end

local mouseHeld={LMB=false,RMB=false}
UserInputService.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then mouseHeld.LMB=true end; if inp.UserInputType==Enum.UserInputType.MouseButton2 then mouseHeld.RMB=true end end)
UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then mouseHeld.LMB=false end; if inp.UserInputType==Enum.UserInputType.MouseButton2 then mouseHeld.RMB=false end end)
local function isKbHeld(featKey) local kb=CFG.keybinds[featKey]; if not kb then if featKey=="aimbot" then return mouseHeld.RMB end; return false end; if kb.type=="key" then return UserInputService:IsKeyDown(kb.value) elseif kb.type=="mouse" then return mouseHeld[kb.value] or false end; return false end

-- TRIGGERBOT
local tbLastFire=0
local function applyAntiLag(on)
    if on then
        pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
        pcall(function() Lighting.GlobalShadows=false end)
        for _,v in ipairs(workspace:GetDescendants()) do pcall(function() if v:IsA("ParticleEmitter") then v.Rate=0 elseif v:IsA("Fire") then v.Enabled=false elseif v:IsA("Smoke") then v.Enabled=false elseif v:IsA("Trail") then v.Enabled=false end end) end
    else pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic end); pcall(function() Lighting.GlobalShadows=true end) end
end

-- HUD
local hud=mk("Frame",{Size=UDim2.new(0,290,0,100),Position=UDim2.new(0,10,1,-110),BackgroundColor3=Color3.fromRGB(4,4,6),BackgroundTransparency=.1,BorderSizePixel=0,Visible=true},gui)
rnd(hud,10); mk("UIStroke",{Color=Color3.fromRGB(28,28,34),Thickness=1},hud); pad(hud,10,10,6,6)
local function hudLbl(y,col) return mk("TextLabel",{Text="",Size=UDim2.new(1,0,0,13),Position=UDim2.new(0,0,0,y),BackgroundTransparency=1,TextColor3=col or TXT,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},hud) end
local hFPS=hudLbl(0,GREEN); local hCoord=hudLbl(14,TXT); local hSpeed=hudLbl(28,PINK2); local hGrav=hudLbl(42,Color3.fromRGB(200,180,255)); local hFeats=hudLbl(56,Color3.fromRGB(255,140,0))
mk("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,72),BackgroundColor3=BORDER,BorderSizePixel=0},hud)
local hInfo=hudLbl(76,DIM)
rTC(function() hFPS.TextColor3=GREEN; hSpeed.TextColor3=PINK2 end)

local lastFPSTime=tick(); local frameCount=0; local currentFPS=0
RunService.RenderStepped:Connect(function() frameCount=frameCount+1; local now=tick(); if now-lastFPSTime>=0.5 then currentFPS=math.floor(frameCount/(now-lastFPSTime)); frameCount=0; lastFPSTime=now end end)

-- ============================================================
-- RADAR  (FIXED: correct orientation so "in front" = top of radar)
-- ============================================================
local radarF=mk("Frame",{
    Size=UDim2.new(0,CFG.radarSize,0,CFG.radarSize),
    AnchorPoint=Vector2.new(1,0),
    Position=UDim2.new(1,-14,0,14),
    BackgroundColor3=Color3.fromRGB(8,8,11),
    BackgroundTransparency=0.25,
    BorderSizePixel=0,
    Visible=false,
    ZIndex=60,
},gui)
rnd(radarF,CFG.radarSize/2)
local radarStroke=mk("UIStroke",{Color=PINK,Thickness=1.2,Transparency=0.5},radarF)
rTC(function() radarStroke.Color=PINK end)
local rCH=mk("Frame",{Size=UDim2.new(1,0,0,1),AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,0,.5,0),BackgroundColor3=Color3.fromRGB(40,40,50),BorderSizePixel=0,ZIndex=61},radarF)
local rCV=mk("Frame",{Size=UDim2.new(0,1,1,0),AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,0),BackgroundColor3=Color3.fromRGB(40,40,50),BorderSizePixel=0,ZIndex=61},radarF)
local rTitle=mk("TextLabel",{Text="RADAR",Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,4),BackgroundTransparency=1,TextColor3=PINK,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=63},radarF)
rTC(function() rTitle.TextColor3=PINK end)
local selfDot=mk("Frame",{Size=UDim2.new(0,6,0,6),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundColor3=Color3.fromRGB(100,200,255),BorderSizePixel=0,ZIndex=64},radarF)
rnd(selfDot,3)
local radarDots={}
for i=1,24 do
    local d=mk("Frame",{Size=UDim2.new(0,6,0,6),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundColor3=PINK,BorderSizePixel=0,Visible=false,ZIndex=64},radarF)
    rnd(d,3); rTC(function() d.BackgroundColor3=PINK end)
    local nl=mk("TextLabel",{Text="",Size=UDim2.new(0,60,0,10),AnchorPoint=Vector2.new(0,1),Position=UDim2.new(1,2,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(230,230,240),TextSize=7,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,Visible=false,ZIndex=65},d)
    radarDots[i]={dot=d,lbl=nl}
end

local radarFrame=0
RunService.Heartbeat:Connect(function()
    if not CFG.radar then radarF.Visible=false; return end
    radarF.Visible=true
    radarF.Size=UDim2.new(0,CFG.radarSize,0,CFG.radarSize)
    rnd(radarF,CFG.radarSize/2)
    radarFrame=radarFrame+1
    if radarFrame%4~=0 then return end

    local myHRP=getHRP(); if not myHRP then return end

    -- FIX: Build the radar orientation from the camera's horizontal look direction.
    -- We project everything into a top-down plane aligned with the camera's yaw,
    -- so players in front show at the top and players to the right show on the right.
    local camCF=cam.CFrame
    -- Camera forward projected flat onto XZ plane (ignore Y tilt)
    local camFwd=Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
    local camFwdLen=camFwd.Magnitude
    if camFwdLen < 0.001 then camFwd=Vector3.new(0,0,-1) else camFwd=camFwd/camFwdLen end
    -- Camera right on XZ plane
    local camRight=Vector3.new(camFwd.Z, 0, -camFwd.X)  -- rotate 90 degrees CW

    local myPos=myHRP.Position
    local dotI=0

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local hrp2=plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp2 then
                -- Vector from me to the other player, flat on XZ
                local delta=hrp2.Position - myPos
                local flatDelta=Vector3.new(delta.X, 0, delta.Z)

                -- Project onto camera-relative axes
                -- Forward component  (positive = in front of camera)
                local fwdComp  = flatDelta:Dot(camFwd)
                -- Right component    (positive = to the right of camera)
                local rightComp = flatDelta:Dot(camRight)

                -- Normalize to radar radius (zoom = stud range)
                local zoom = CFG.radarZoom
                local px =  rightComp / zoom   -- X on radar: right = right
                local pz = -fwdComp   / zoom   -- Y on radar: forward = UP (negative screen Y)

                -- Clamp to circle edge if outside range
                local mag=math.sqrt(px*px+pz*pz)
                if mag>1 then px=px/mag*0.92; pz=pz/mag*0.92 end

                dotI=dotI+1
                if dotI>24 then break end
                local entry=radarDots[dotI]
                pcall(function()
                    entry.dot.Visible=true
                    -- radarF UDim2: 0.5 = centre; px/pz range -1..1 mapped to 0..1
                    entry.dot.Position=UDim2.new(0.5+px*0.5, 0, 0.5+pz*0.5, 0)
                    entry.lbl.Visible=CFG.radarShowNames
                    entry.lbl.Text=plr.Name
                end)
            end
        end
    end
    for i=dotI+1,24 do
        pcall(function() radarDots[i].dot.Visible=false end)
    end
end)

local freecamOverlay=mk("TextLabel",{Text="WASD=fly  Space/Shift=up/down  Mouse=look  [G]=stop FreeCam",Size=UDim2.new(0,500,0,32),AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-16),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=.5,BorderSizePixel=0,TextColor3=WHITE,TextSize=12,Font=Enum.Font.GothamBold,Visible=false,ZIndex=300},gui)
rnd(freecamOverlay,8)

-- CROSSHAIR
local xhF=mk("Frame",{Size=UDim2.new(0,90,0,90),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=50},gui)
local function buildCH()
    xhF:ClearAllChildren()
    local col=CFG.crosshairColorH==0 and WHITE or Color3.fromHSV(CFG.crosshairColorH,1,1)
    local s=CFG.crosshairSize; local st=CFG.crosshairStyle; xhF.Size=UDim2.new(0,s*2+16,0,s*2+16)
    local function ln(w,h,ox,oy,rot) local f=mk("Frame",{Size=UDim2.new(0,w,0,h),Position=UDim2.new(.5,-w/2+ox,.5,-h/2+oy),BackgroundColor3=col,BorderSizePixel=0,Rotation=rot or 0,ZIndex=51},xhF); rnd(f,1) end
    local function dot(sz) local f=mk("Frame",{Size=UDim2.new(0,sz,0,sz),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=52},xhF); rnd(f,sz/2) end
    local g=math.floor(s*.22)
    if st==1 then ln(s/2-g,2,-(s/4+g/2+1),0);ln(s/2-g,2,s/4+g/2+1,0);ln(2,s/2-g,0,-(s/4+g/2+1));ln(2,s/2-g,0,s/4+g/2+1)
    elseif st==2 then dot(7)
    elseif st==3 then local r=mk("Frame",{Size=UDim2.new(0,s,0,s),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=51},xhF);mk("UIStroke",{Color=col,Thickness=2},r);rnd(r,s)
    elseif st==4 then ln(s,2,0,0);ln(2,s/2,0,s/4)
    elseif st==5 then ln(s,2,0,0,45);ln(s,2,0,0,-45)
    elseif st==6 then ln(s/2-g,2,-(s/4+g/2+1),0);ln(s/2-g,2,s/4+g/2+1,0);ln(2,s/2-g,0,-(s/4+g/2+1));ln(2,s/2-g,0,s/4+g/2+1);dot(5)
    elseif st==7 then local h2=s/2;ln(s+4,2,0,-h2);ln(s+4,2,0,h2);ln(2,s,-h2+1,0);ln(2,s,h2-1,0)
    elseif st==8 then ln(s*.65,2,-s*.16,s*.2,45);ln(s*.65,2,s*.16,s*.2,-45) end
end
buildCH()

-- ============================================================
-- TELEPORT TO PLAYER POPUP
-- ============================================================
local tpPopup=mk("Frame",{
    Size=UDim2.new(0,220,0,320),
    AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,0,.5,0),
    BackgroundColor3=Color3.fromRGB(10,10,13),
    BorderSizePixel=0,
    Visible=false,
    ZIndex=500,
},gui)
rnd(tpPopup,12)
mk("UIStroke",{Color=Color3.fromRGB(40,40,52),Thickness=1.2},tpPopup)

local tpHeader=mk("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(14,14,18),BorderSizePixel=0,ZIndex=501},tpPopup)
rnd(tpHeader,12)
mk("Frame",{Size=UDim2.new(1,0,.5,0),Position=UDim2.new(0,0,.5,0),BackgroundColor3=Color3.fromRGB(14,14,18),BorderSizePixel=0,ZIndex=501},tpHeader)
mk("TextLabel",{Text="Teleport to Player",Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,TextColor3=WHITE,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=502},tpHeader)
local tpCloseBtn=mk("TextButton",{Text="CLOSE",Size=UDim2.new(0,46,0,22),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),BackgroundColor3=RED,TextColor3=WHITE,TextSize=11,Font=Enum.Font.GothamBold,BorderSizePixel=0,ZIndex=502},tpHeader)
rnd(tpCloseBtn,6)
tpCloseBtn.MouseButton1Click:Connect(function() tpPopup.Visible=false end)

local tpScroll=mk("ScrollingFrame",{Size=UDim2.new(1,0,1,-40),Position=UDim2.new(0,0,0,38),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(60,60,75),CanvasSize=UDim2.new(0,0,0,0),ZIndex=501},tpPopup)
local tpList=mk("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},tpScroll)
pad(tpScroll,8,8,6,6)
tpList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tpScroll.CanvasSize=UDim2.new(0,0,0,tpList.AbsoluteContentSize.Y+12) end)

local function refreshTpList()
    for _,c in ipairs(tpScroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
    local plrs=Players:GetPlayers()
    for _,plr in ipairs(plrs) do
        if plr~=lp then
            local row=mk("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(18,18,22),BorderSizePixel=0,ZIndex=502},tpScroll)
            rnd(row,8)
            local iconF=mk("Frame",{Size=UDim2.new(0,22,0,22),AnchorPoint=Vector2.new(0,.5),Position=UDim2.new(0,8,.5,0),BackgroundColor3=PINK,BorderSizePixel=0,ZIndex=503},row)
            rnd(iconF,11)
            mk("TextLabel",{Text="👤",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=WHITE,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=504},iconF)
            mk("TextLabel",{Text=plr.Name,Size=UDim2.new(1,-42,1,0),Position=UDim2.new(0,36,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(225,225,235),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=503},row)
            local hitBtn=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=504},row)
            hitBtn.MouseEnter:Connect(function() tw(row,.08,{BackgroundColor3=Color3.fromRGB(26,26,32)}) end)
            hitBtn.MouseLeave:Connect(function() tw(row,.08,{BackgroundColor3=Color3.fromRGB(18,18,22)}) end)
            local capturedPlr=plr
            hitBtn.MouseButton1Click:Connect(function()
                local hrp=getHRP()
                if hrp and capturedPlr.Character then
                    local targetHRP=capturedPlr.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        pcall(function() hrp.CFrame=targetHRP.CFrame+Vector3.new(3,0,3) end)
                        notify("GLUHFIX","Teleported to "..capturedPlr.Name,2)
                        tpPopup.Visible=false
                    else
                        notify("GLUHFIX",capturedPlr.Name.." has no character",2)
                    end
                end
            end)
        end
    end
end

local function openTpPopup()
    refreshTpList()
    tpPopup.Visible=true
    tpPopup.Size=UDim2.new(0,220,0,0)
    tw(tpPopup,.18,{Size=UDim2.new(0,220,0,320)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
end

-- ============================================================
-- BUILD TABS
-- ============================================================

-- MOVEMENT
do
    local L,R=tabL["Move"],tabR["Move"]
    sec(L,"Flying")
    tog(L,"Fly  -  WASD + Space/Shift","fly",nil,function(on) if on then startFly() else stopFly() end end)
    sld(L,"Fly Speed",10,600,CFG.flySpeed,5,function(v) CFG.flySpeed=v end)
    tog(L,"Noclip - through walls","noclip",nil,function(on) if on then startNoclip() else stopNoclip() end end)
    tog(L,"Speed Boost","speed",nil,function(on) if not on then local h=getHum();if h then pcall(function() h.WalkSpeed=16 end) end end end)
    sld(L,"WalkSpeed (16=normal)",16,300,CFG.speedMult,1,function(v) CFG.speedMult=v end)
    sec(L,"Jumping")
    tog(L,"High Jump","highJump",nil,function(on) if not on then local h=getHum();if h then pcall(function() h.JumpPower=50 end) end end end)
    sld(L,"Jump Power",50,900,CFG.jumpPower,10,function(v) CFG.jumpPower=v end)
    tog(L,"Infinite Jump","infinite_jump",nil,nil)
    tog(L,"Bunny Hop","bunnyHop",nil,function(on) if on then startBhop() else stopBhop() end end)

    sec(R,"FreeCam")
    tog(R,"FreeCam - fly the camera","freecam",nil,function(on)
        if on then startFreecam(); freecamOverlay.Visible=true; task.delay(.05,function() showWin(false) end)
        else stopFreecam(); freecamOverlay.Visible=false; showWin(true) end
    end)
    sld(R,"FreeCam Speed",5,300,freecamSpeed,5,function(v) freecamSpeed=v end)
    sld(R,"Camera Smoothness",1,20,math.floor(freecamSens*1000),1,function(v) freecamSens=v/1000 end)
    note(R,"Low = smoother camera  High = snappy  |  [G] = Exit")
    sec(R,"Misc")
    tog(R,"Spinbot","spinBot",nil,nil)
    sld(R,"Spin Speed",1,40,CFG.spinSpeed,1,function(v) CFG.spinSpeed=v end)
    tog(R,"Anti-AFK","antiAfk",nil,nil)
    tog(R,"Anti-Lag","antiLag",nil,function(on) applyAntiLag(on) end)
    tog(R,"Remove Animations","removeAnims",nil,function(on) applyRemoveAnims(on) end)
    sec(R,"Teleport")
    local tpBtn=mk("TextButton",{
        Size=UDim2.new(1,0,0,32),
        BackgroundColor3=Color3.fromRGB(20,20,24),
        TextColor3=Color3.fromRGB(220,220,230),
        TextSize=12,
        Text="👤  Teleport to Player...",
        Font=Enum.Font.GothamSemibold,
        BorderSizePixel=0,
    },R)
    rnd(tpBtn,6)
    mk("UIStroke",{Color=PINK,Thickness=1,Transparency=0.6},tpBtn)
    tpBtn.MouseEnter:Connect(function() tw(tpBtn,.08,{BackgroundColor3=Color3.fromRGB(28,28,35)}); tpBtn.TextColor3=WHITE end)
    tpBtn.MouseLeave:Connect(function() tw(tpBtn,.08,{BackgroundColor3=Color3.fromRGB(20,20,24)}); tpBtn.TextColor3=Color3.fromRGB(220,220,230) end)
    tpBtn.MouseButton1Click:Connect(function() openTpPopup() end)
    rTC(function() for _,s in ipairs(tpBtn:GetChildren()) do if s:IsA("UIStroke") then s.Color=PINK end end end)

    btn(R,"TP to Nearest Player",function()
        local hrp=getHRP();if not hrp then return end; local best,bd=nil,math.huge
        for _,p in ipairs(Players:GetPlayers()) do if p~=lp and p.Character then local h2=p.Character:FindFirstChild("HumanoidRootPart");if h2 then local d=(h2.Position-hrp.Position).Magnitude;if d<bd then bd=d;best=h2 end end end end
        if best then pcall(function() hrp.CFrame=best.CFrame+Vector3.new(3,0,3) end) end
    end)
    btn(R,"TP to Spawn",function()
        local hrp=getHRP();if not hrp then return end; local sp=workspace:FindFirstChildOfClass("SpawnLocation"); if sp then pcall(function() hrp.CFrame=sp.CFrame+Vector3.new(0,5,0) end) end
    end)
    btn(R,"Yeet - Launch Up",function()
        local hrp=getHRP();if not hrp then return end; local bv=Instance.new("BodyVelocity");bv.MaxForce=Vector3.new(1e9,1e9,1e9);bv.Velocity=Vector3.new(0,900,0);bv.Parent=hrp;Debris:AddItem(bv,.15)
    end)
    btn(R,"Rejoin",function() pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,lp) end) end)
end

-- COMBAT
do
    local L,R=tabL["Combat"],tabR["Combat"]
    sec(L,"Aimbot")
    local modeDisp=mk("TextLabel",{Text="Mode: HOLD  |  Trigger: RMB",Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(22,22,28),TextColor3=Color3.fromRGB(190,190,205),TextSize=12,Font=Enum.Font.GothamSemibold,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Center},L)
    rnd(modeDisp,6)
    local function refreshMode()
        local kb=CFG.keybinds["aimbot"]; local trig="RMB"
        if kb then if kb.type=="key" then trig=tostring(kb.value):match("%.(%a+)$") or "?" else trig=kb.value end end
        modeDisp.Text="Mode: "..CFG.aimbotActivationMode:upper().."  |  Trigger: "..trig
    end
    local modeRow=mk("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},L); rnd(modeRow,6)
    local holdBtn=mk("TextButton",{Text="HOLD",Size=UDim2.new(.48,-4,0,22),Position=UDim2.new(0,4,.5,0),AnchorPoint=Vector2.new(0,.5),BackgroundColor3=CFG.aimbotActivationMode=="hold" and PINK or Color3.fromRGB(32,32,40),TextColor3=CFG.aimbotActivationMode=="hold" and BG or Color3.fromRGB(135,135,150),TextSize=12,Font=Enum.Font.GothamBold,BorderSizePixel=0},modeRow); rnd(holdBtn,5)
    local togBtn=mk("TextButton",{Text="TOGGLE",Size=UDim2.new(.48,-4,0,22),Position=UDim2.new(1,-4,.5,0),AnchorPoint=Vector2.new(1,.5),BackgroundColor3=CFG.aimbotActivationMode=="toggle" and PINK or Color3.fromRGB(32,32,40),TextColor3=CFG.aimbotActivationMode=="toggle" and BG or Color3.fromRGB(135,135,150),TextSize=12,Font=Enum.Font.GothamBold,BorderSizePixel=0},modeRow); rnd(togBtn,5)
    local function setMode(m) CFG.aimbotActivationMode=m; saveConfig(); holdBtn.BackgroundColor3=m=="hold" and PINK or Color3.fromRGB(32,32,40); holdBtn.TextColor3=m=="hold" and BG or Color3.fromRGB(135,135,150); togBtn.BackgroundColor3=m=="toggle" and PINK or Color3.fromRGB(32,32,40); togBtn.TextColor3=m=="toggle" and BG or Color3.fromRGB(135,135,150); refreshMode() end
    holdBtn.MouseButton1Click:Connect(function() setMode("hold") end); togBtn.MouseButton1Click:Connect(function() setMode("toggle") end)
    do
        local kbRow=mk("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},L); rnd(kbRow,6)
        mk("TextLabel",{Text="Trigger Key",Size=UDim2.new(.5,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(230,230,238),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},kbRow)
        local function kbName() local kb=CFG.keybinds["aimbot"]; if not kb then return "RMB" end; if kb.type=="key" then return tostring(kb.value):match("%.(%a+)$") or "?" end; return kb.value end
        local pill=mk("Frame",{Size=UDim2.new(0,68,0,22),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-8,.5,0),BackgroundColor3=Color3.fromRGB(28,28,36),BorderSizePixel=0,ZIndex=3},kbRow); rnd(pill,5)
        local pillTxt=mk("TextLabel",{Text=kbName(),Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(210,210,222),TextSize=12,Font=Enum.Font.GothamSemibold,ZIndex=4},pill)
        local listening=false
        local hitBtn=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},pill)
        hitBtn.MouseButton1Click:Connect(function()
            if listening then return end; listening=true
            pillTxt.Text="..."; pillTxt.TextColor3=Color3.fromRGB(255,160,60)
            local kc; kc=UserInputService.InputBegan:Connect(function(inp,gpe)
                if gpe then return end
                if inp.UserInputType==Enum.UserInputType.Keyboard then
                    if inp.KeyCode==Enum.KeyCode.G then
                        pillTxt.Text="BLOCKED"; pillTxt.TextColor3=RED
                        task.delay(1.2,function() pillTxt.Text=kbName(); pillTxt.TextColor3=Color3.fromRGB(210,210,222) end)
                        listening=false; kc:Disconnect(); return
                    end
                    CFG.keybinds["aimbot"]={type="key",value=inp.KeyCode}
                    pillTxt.Text=kbName(); pillTxt.TextColor3=Color3.fromRGB(210,210,222)
                    listening=false; kc:Disconnect(); refreshMode(); saveConfig()
                elseif inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    CFG.keybinds["aimbot"]={type="mouse",value="LMB"}
                    pillTxt.Text="LMB"; pillTxt.TextColor3=Color3.fromRGB(210,210,222)
                    listening=false; kc:Disconnect(); refreshMode(); saveConfig()
                elseif inp.UserInputType==Enum.UserInputType.MouseButton2 then
                    CFG.keybinds["aimbot"]={type="mouse",value="RMB"}
                    pillTxt.Text="RMB"; pillTxt.TextColor3=Color3.fromRGB(210,210,222)
                    listening=false; kc:Disconnect(); refreshMode(); saveConfig()
                end
            end)
        end)
        hitBtn.MouseButton2Click:Connect(function()
            CFG.keybinds["aimbot"]={type="mouse",value="RMB"}
            pillTxt.Text="RMB"; pillTxt.TextColor3=Color3.fromRGB(210,210,222)
            refreshMode(); saveConfig()
        end)
        note(L,"Click = rebind key/mouse  |  RMB = reset")
    end
    tog(L,"Aimbot (enable)","aimbot",nil,nil)
    tog(L,"Visual Check (no wall aim)","aimbotVisCheck",nil,nil)
    sld(L,"FOV Radius",20,500,CFG.aimbotFOV,5,function(v) CFG.aimbotFOV=v end)
    sld(L,"Smooth (1=slow  100=snap)",1,100,CFG.aimbotSmooth,1,function(v) CFG.aimbotSmooth=v end)

    sec(R,"Target Bone")
    local bones={"Head","UpperTorso","HumanoidRootPart"}
    for _,b in ipairs(bones) do
        btn(R,b,function() CFG.aimbotBone=b; notify("Aimbot","Bone: "..b,2) end)
    end
    sec(R,"FOV Circle")
    local fovRow=mk("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(20,20,24),BorderSizePixel=0},R); rnd(fovRow,6)
    mk("TextLabel",{Text="FOV Circle",Size=UDim2.new(.5,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(180,180,192),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left},fovRow)
    local fovOnBtn=mk("TextButton",{Text="SHOW",Size=UDim2.new(0,50,0,20),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-62,.5,0),BackgroundColor3=CFG.showFovCircle and PINK or Color3.fromRGB(32,32,40),TextColor3=CFG.showFovCircle and BG or Color3.fromRGB(135,135,150),TextSize=12,Font=Enum.Font.GothamBold,BorderSizePixel=0},fovRow); rnd(fovOnBtn,5)
    local fovOffBtn=mk("TextButton",{Text="HIDE",Size=UDim2.new(0,50,0,20),AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-6,.5,0),BackgroundColor3=not CFG.showFovCircle and PINK or Color3.fromRGB(32,32,40),TextColor3=not CFG.showFovCircle and BG or Color3.fromRGB(135,135,150),TextSize=12,Font=Enum.Font.GothamBold,BorderSizePixel=0},fovRow); rnd(fovOffBtn,5)
    local function setFovShow(v) CFG.showFovCircle=v; saveConfig(); fovOnBtn.BackgroundColor3=v and PINK or Color3.fromRGB(32,32,40); fovOnBtn.TextColor3=v and BG or Color3.fromRGB(135,135,150); fovOffBtn.BackgroundColor3=not v and PINK or Color3.fromRGB(32,32,40); fovOffBtn.TextColor3=not v and BG or Color3.fromRGB(135,135,150) end
    fovOnBtn.MouseButton1Click:Connect(function() setFovShow(true) end); fovOffBtn.MouseButton1Click:Connect(function() setFovShow(false) end)

    sec(R,"Triggerbot  ⚠")
    local warnLbl=mk("TextLabel",{Text="⚠  maybe detected - auto-fires LMB on enemy",Size=UDim2.new(1,0,0,24),BackgroundColor3=Color3.fromRGB(24,18,4),TextColor3=Color3.fromRGB(200,155,60),TextSize=12,Font=Enum.Font.GothamSemibold,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Center,TextWrapped=true},R)
    rnd(warnLbl,5)
    tog(R,"Triggerbot  ⚠ maybe detected","triggerbot",nil,nil)
    sld(R,"Fire Delay (ms)",10,500,CFG.triggerbotDelay,5,function(v) CFG.triggerbotDelay=v end)
    sec(R,"Protection")
    tog(R,"Anti-Kick","antiKick",nil,nil)
    tog(R,"Anti-Detect","antiDetect",nil,nil)
end

-- VISUAL
do
    local L,R=tabL["Visual"],tabR["Visual"]
    sec(L,"Render")
    tog(L,"Fullbright","fullbright",nil,function(on) applyFullbright(on) end)
    tog(L,"No Fog","noFog",nil,function(on) pcall(function() Lighting.FogEnd=on and 1e6 or CFG._origFogEnd end) end)
    sec(L,"Radar")
    tog(L,"Radar (top-right)","radar",nil,function(on) radarF.Visible=on end)
    sld(L,"Radar Size",80,400,CFG.radarSize,10,function(v) CFG.radarSize=v; radarF.Size=UDim2.new(0,v,0,v); rnd(radarF,v/2) end)
    sld(L,"Radar Zoom (Studs)",10,500,CFG.radarZoom,5,function(v) CFG.radarZoom=v end)
    tog(L,"Show Names","radarShowNames",nil,nil)
    sec(L,"Crosshair")
    tog(L,"Crosshair","crosshair",nil,function(on) xhF.Visible=on end)
    local styles={{"+ Cross",1},{"● Dot",2},{"○ Circle",3},{"T Shape",4},{"X Diagonal",5},{"⊕ Cross+Dot",6},{"□ Box",7},{"∧ Chevron",8}}
    for _,s in ipairs(styles) do btn(L,s[1],function() CFG.crosshairStyle=s[2]; buildCH(); saveConfig() end) end
    sec(R,"Crosshair Settings")
    sld(R,"Hue (0=White)",0,100,math.floor(CFG.crosshairColorH*100),1,function(v) CFG.crosshairColorH=v/100; buildCH(); saveConfig() end)
    sld(R,"Size",8,70,CFG.crosshairSize,2,function(v) CFG.crosshairSize=v; buildCH() end)
end

-- WORLD
do
    local L,R=tabL["World"],tabR["World"]
    sec(L,"Solo Session")
    tog(L,"Solo Session - hide all players","soloSession",nil,function(on) applySoloSession(on) end)
    note(L,"Hides other players locally + nametags")
    sec(L,"Time & Weather")
    tog(L,"Freeze Time","freezeTime",nil,nil)
    sld(L,"Time of Day (0-24)",0,24,CFG.frozenTime,.5,function(v) pcall(function() Lighting.ClockTime=v end); CFG.frozenTime=v end)
    sld(L,"Brightness",0,10,2,.1,function(v) pcall(function() Lighting.Brightness=v end) end)
    btn(L,"🌙  Night",function() pcall(function() Lighting.ClockTime=0; Lighting.Brightness=.04 end) end)
    btn(L,"🌅  Sunset",function() pcall(function() Lighting.ClockTime=18.5; Lighting.Brightness=1 end) end)
    btn(L,"☀️  Noon",function() pcall(function() Lighting.ClockTime=14; Lighting.Brightness=2.5 end) end)
    sec(R,"Physics")
    sld(R,"Gravity",0,1000,196,5,function(v) pcall(function() workspace.Gravity=v end) end)
    btn(R,"🌙  Moon (16)",function() pcall(function() workspace.Gravity=16 end) end)
    btn(R,"🌍  Normal (196)",function() pcall(function() workspace.Gravity=196.2 end) end)
    btn(R,"⬛  Heavy (800)",function() pcall(function() workspace.Gravity=800 end) end)
    btn(R,"🌌  Zero Gravity",function() pcall(function() workspace.Gravity=0 end) end)
    sec(R,"Fog")
    sld(R,"Fog Start",0,5000,0,50,function(v) pcall(function() Lighting.FogStart=v end) end)
    sld(R,"Fog End",100,10000,1000,100,function(v) pcall(function() Lighting.FogEnd=v end) end)
    sld(R,"Fog Density (Atmosphere)",0,100,0,5,function(v)
        pcall(function()
            local atm=Lighting:FindFirstChildOfClass("Atmosphere")
            if not atm then atm=Instance.new("Atmosphere",Lighting) end
            atm.Density=v/100; atm.Haze=v/50
        end)
    end)
    sec(R,"Shadows & Effects")
    btn(R,"💡  No Shadows",function() pcall(function() Lighting.GlobalShadows=false end) end)
    btn(R,"💡  Shadows ON",function() pcall(function() Lighting.GlobalShadows=true end) end)
    btn(R,"✨  Remove Bloom",function()
        for _,e in ipairs(Lighting:GetChildren()) do
            pcall(function() if e:IsA("BloomEffect") or e:IsA("SunRaysEffect") or e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") then e.Enabled=false end end)
        end
        notify("GLUHFIX","All effects disabled",3)
    end)
    btn(R,"✨  Restore Effects",function()
        for _,e in ipairs(Lighting:GetChildren()) do
            pcall(function() if e:IsA("BloomEffect") or e:IsA("SunRaysEffect") or e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect") then e.Enabled=true end end)
        end
        notify("GLUHFIX","Effects restored",3)
    end)
end

-- PLAYER
do
    local L,R=tabL["Player"],tabR["Player"]
    sec(L,"Appearance")
    tog(L,"Invisible (local only)","invisible",nil,function(on) applyInvis(on) end)
    tog(L,"Headless","headless",nil,function(on) applyHeadless(on) end)
    sec(L,"Colors")
    btn(L,"🌈  Rainbow (10s)",function()
        task.spawn(function() for t=0,200 do local c=getChar(); if not c then break end; for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then pcall(function() p.Color=Color3.fromHSV((t*.04)%1,1,1) end) end end; task.wait(.05) end end)
    end)
    btn(L,"🖤  All Black",function() local c=getChar(); if not c then return end; for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then pcall(function() p.Color=Color3.fromRGB(0,0,0) end) end end end)
    btn(L,"🤍  All White",function() local c=getChar(); if not c then return end; for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then pcall(function() p.Color=Color3.fromRGB(255,255,255) end) end end end)
    btn(L,"✨  Neon Skin",function() local c=getChar(); if not c then return end; for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then pcall(function() p.Material=Enum.Material.Neon; p.Color=PINK end) end end end)
    sec(R,"Actions")
    btn(R,"Hide Accessories",function() local c=getChar();if not c then return end; for _,a in ipairs(c:GetChildren()) do if a:IsA("Accessory") then local h=a:FindFirstChildOfClass("Part") or a:FindFirstChildOfClass("MeshPart"); if h then pcall(function() h.Transparency=1 end) end end end end)
    btn(R,"Show Accessories",function() local c=getChar();if not c then return end; for _,a in ipairs(c:GetChildren()) do if a:IsA("Accessory") then local h=a:FindFirstChildOfClass("Part") or a:FindFirstChildOfClass("MeshPart"); if h then pcall(function() h.Transparency=0 end) end end end end)
    btn(R,"🔄  Respawn",function() local h=getHum();if h then pcall(function() h.Health=0 end) end end)
    btn(R,"🚀  Yeet Up",function() local hrp=getHRP();if not hrp then return end; local bv=Instance.new("BodyVelocity");bv.MaxForce=Vector3.new(1e9,1e9,1e9);bv.Velocity=Vector3.new(0,900,0);bv.Parent=hrp;Debris:AddItem(bv,.15) end)
    btn(R,"💥  Superjump",function() local hrp=getHRP();if not hrp then return end; local bv=Instance.new("BodyVelocity");bv.MaxForce=Vector3.new(1e9,1e9,1e9);bv.Velocity=Vector3.new(0,450,0);bv.Parent=hrp;Debris:AddItem(bv,.2) end)
    btn(R,"🟦  Spawn Platform (5s)",function() local hrp=getHRP();if not hrp then return end; local p=Instance.new("Part");p.Size=Vector3.new(12,1,12);p.Anchored=true;p.Material=Enum.Material.Neon;p.BrickColor=BrickColor.new("Institutional white");pcall(function() p.CFrame=hrp.CFrame*CFrame.new(0,-3.5,0) end);p.Parent=workspace;Debris:AddItem(p,5) end)
end

-- ESP
do
    local L,R=tabL["ESP"],tabR["ESP"]
    sec(L,"ESP Settings")
    note(L,"ESP - see all players through walls")
    tog(L,"Enable ESP","esp",nil,nil)
    tog(L,"Clean ESP  (body-fit, every frame)","espClean",nil,function(on)
        if not on then for plr,_ in pairs(cleanEspData) do hideCleanESP(plr) end end
    end)
    note(L,"Clean ESP: per-frame body-fit box - includes all elements")
    tog(L,"Corner Box","espCorner",nil,nil)
    tog(L,"Full Box","espBoxFull",nil,nil)
    tog(L,"Skeleton","espSkeleton",nil,nil)
    tog(L,"Head Dot","espHeadDot",nil,nil)
    tog(L,"Chams (Highlight)","espChams",nil,nil)
    tog(L,"Health Bars","espHealth",nil,nil)
    tog(L,"Names","espNames",nil,nil)
    tog(L,"Distance","espDist",nil,nil)
    tog(L,"Tracer (line to enemy)","espTracer",nil,nil)
    sld(L,"Max Distance (m)",50,2000,CFG.espMaxDist,50,function(v) CFG.espMaxDist=v end)
    sld(L,"Line Thickness",1,6,CFG.espLineThick,1,function(v) CFG.espLineThick=v end)
    sec(R,"Color")
    sld(R,"Hue (0=White)",0,100,math.floor(CFG.espColorH*100),1,function(v) CFG.espColorH=v/100 end)
    sld(R,"Saturation %",0,100,math.floor(CFG.espColorS*100),1,function(v) CFG.espColorS=v/100 end)
    sld(R,"Brightness %",0,100,math.floor(CFG.espColorV*100),1,function(v) CFG.espColorV=v/100 end)
    note(R,"White=H0 S0 V100  |  Green=H36 S90 V100  |  Red=H0 S100 V100")
end

-- SCANNER
do
    local L,R=tabL["Scanner"],tabR["Scanner"]
    sec(L,"Object Scanner")
    sld(L,"Scan Range (studs)",10,2000,CFG.scannerRange,10,function(v) CFG.scannerRange=v end)
    tog(L,"Auto-scan (every 30s)","scannerAuto",nil,nil)
    sld(L,"Auto-scan Interval (s)",5,120,CFG.scannerInterval,5,function(v) CFG.scannerInterval=v end)
    btn(L,"🔍  Scan Now",function()
        notify("GLUHFIX","Scanning...",1)
        local hrp=getHRP(); if not hrp then return end; local origin=hrp.Position; local results={}
        for _,obj in ipairs(workspace:GetDescendants()) do pcall(function()
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local pos; if obj:IsA("BasePart") then pos=obj.Position elseif obj:IsA("Model") then local p=obj:FindFirstChildOfClass("BasePart"); if p then pos=p.Position end end
                if pos then local d=math.floor((pos-origin).Magnitude); if d<=CFG.scannerRange then table.insert(results,{name=obj.Name,class=obj.ClassName,dist=d}) end end
            end
        end) end
        table.sort(results,function(a,b) return a.dist<b.dist end)
        for _,c in ipairs(tabR["Scanner"]:GetChildren()) do if c.Name=="SR" then c:Destroy() end end
        for i=1,math.min(#results,60) do
            local r=results[i]
            local row=mk("Frame",{Name="SR",Size=UDim2.new(1,0,0,20),BackgroundColor3=i%2==0 and Color3.fromRGB(20,20,24) or Color3.fromRGB(17,17,20),BorderSizePixel=0},tabR["Scanner"]); rnd(row,4)
            mk("TextLabel",{Text=r.name,Size=UDim2.new(.55,0,1,0),Position=UDim2.new(0,5,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(185,185,198),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left},row)
            mk("TextLabel",{Text=r.class,Size=UDim2.new(.25,0,1,0),Position=UDim2.new(.55,0,0,0),BackgroundTransparency=1,TextColor3=DIM,TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left},row)
            mk("TextLabel",{Text=r.dist.."m",Size=UDim2.new(.2,0,1,0),Position=UDim2.new(.8,0,0,0),BackgroundTransparency=1,TextColor3=PINK,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right},row)
        end
        notify("GLUHFIX","Found "..(#results).." objects",3)
    end)
    btn(L,"🗑  Clear Results",function() for _,c in ipairs(tabR["Scanner"]:GetChildren()) do if c.Name=="SR" then c:Destroy() end end end)
    note(R,"Scan results appear here")
end

-- MAP
do
    local L,R=tabL["Map"],tabR["Map"]
    local lastPos=nil; local markerParts={}; local markerRunning=false
    local function removeAllMarkers() markerRunning=false; for _,p in ipairs(markerParts) do pcall(function() p:Destroy() end) end; markerParts={} end
    local function spawnMarker(cf)
        removeAllMarkers(); markerRunning=true; local pos=cf.Position
        local beam=Instance.new("Part"); beam.Name="GF_Marker"; beam.Anchored=true; beam.CanCollide=false; beam.Size=Vector3.new(.16,200,.16); beam.Material=Enum.Material.Neon; beam.Color=WHITE; beam.CFrame=CFrame.new(pos+Vector3.new(0,100,0)); beam.Parent=workspace; table.insert(markerParts,beam)
        local disc=Instance.new("Part"); disc.Name="GF_Marker"; disc.Anchored=true; disc.CanCollide=false; disc.Size=Vector3.new(8,.06,8); disc.Material=Enum.Material.Neon; disc.Shape=Enum.PartType.Cylinder; disc.Color=PINK; disc.CFrame=CFrame.new(pos+Vector3.new(0,.03,0))*CFrame.Angles(0,0,math.pi/2); disc.Parent=workspace; table.insert(markerParts,disc)
        task.spawn(function() local t=0; local h=0; while markerRunning and beam and beam.Parent do t=t+.033; h=(h+.001)%1; local col=Color3.fromHSV(h,.6,1); pcall(function() beam.Color=col; disc.Color=col end); task.wait(.033) end end)
    end
    sec(L,"Position Marker")
    btn(L,"📍  Save Position + Marker",function() local hrp=getHRP(); if hrp then lastPos=hrp.CFrame; spawnMarker(hrp.CFrame); notify("GLUHFIX","Position saved! ✓",3) end end)
    btn(L,"🔁  TP to Saved Position",function() local hrp=getHRP(); if hrp and lastPos then pcall(function() hrp.CFrame=lastPos end); notify("GLUHFIX","Teleported!",2) else notify("GLUHFIX","No position saved",2) end end)
    btn(L,"🗑  Remove Marker",function() removeAllMarkers(); lastPos=nil; notify("GLUHFIX","Marker removed ✓",2) end)
    sec(L,"Workspace Tools")
    btn(L,"🟦  Spawn Platform (5s)",function() local hrp=getHRP();if not hrp then return end; local p=Instance.new("Part");p.Size=Vector3.new(12,1,12);p.Anchored=true;p.Material=Enum.Material.Neon;p.BrickColor=BrickColor.new("Institutional white");pcall(function() p.CFrame=hrp.CFrame*CFrame.new(0,-3.5,0) end);p.Parent=workspace;Debris:AddItem(p,5) end)
    btn(L,"Highlight All Parts (5s)",function()
        local boxes={}; for _,v in ipairs(workspace:GetDescendants()) do pcall(function() if v:IsA("BasePart") and v.Transparency<1 then local s=Instance.new("SelectionBox");s.Adornee=v;s.Color3=PINK;s.LineThickness=.05;s.SurfaceTransparency=.85;s.SurfaceColor3=PINK;s.Parent=workspace;table.insert(boxes,s) end end) end
        task.delay(5,function() for _,s in ipairs(boxes) do pcall(function() s:Destroy() end) end end); notify("GLUHFIX","Highlighted parts (5s)",3)
    end)
end

-- SCRIPTS
do
    local L,R=tabL["Scripts"],tabR["Scripts"]
    local function scriptBtn(sf, label, url)
        local b=mk("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=Color3.fromRGB(12,12,16),BorderSizePixel=0},sf); rnd(b,8)
        mk("UIStroke",{Color=Color3.fromRGB(36,36,48),Thickness=1.1},b)
        local lbl=mk("TextLabel",{Text=label,Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,TextColor3=TXT,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},b)
        local hit=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=3},b)
        hit.MouseEnter:Connect(function() tw(b,.1,{BackgroundColor3=ROWH}); lbl.TextColor3=WHITE end)
        hit.MouseLeave:Connect(function() tw(b,.1,{BackgroundColor3=Color3.fromRGB(12,12,16)}); lbl.TextColor3=TXT end)
        hit.MouseButton1Click:Connect(function()
            showWin(false); notify("GLUHFIX","Loading: "..label,3)
            task.spawn(function() pcall(function() loadstring(game:HttpGet(url,true))() end) end)
        end)
    end
    sec(L,"Game Scripts")
    scriptBtn(L,"Hypershoot - Zephyr V2","https://raw.githubusercontent.com/TheRealAvrwm/Zephyr-V2/refs/heads/main/Hypershot.lua")
    scriptBtn(L,"Rival Script","https://pastebin.com/raw/zWhb1mMS")
    scriptBtn(L,"Blade Ball [LEGIT]","https://raw.githubusercontent.com/ImNotRox1/Trevous-Hub/refs/heads/main/blade-ball.lua")
    scriptBtn(L,"Escape Tsunami","https://api.luarmor.net/files/v4/loaders/c4aac7911638bbcff33cba2ec603ee7e.lua")
    scriptBtn(L,"Blox Fruits","https://raw.githubusercontent.com/giahuy2511-coder/MonsterHub/refs/heads/main/MonsterHubEN")
    scriptBtn(L,"99 Nights","https://raw.githubusercontent.com/Rx1m/CpsHub/refs/heads/main/Hub")
    scriptBtn(L,"Survive Lava for Brainrots","https://raw.rawscriptserver.com/427425254160")
    sec(R,"Other Scripts")
    scriptBtn(R,"Fling Script","https://raw.githubusercontent.com/K1LAS1K/Ultimate-Fling-GUI/main/flingscript.lua")
    scriptBtn(R,"Fly GUI V3","https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt")
    scriptBtn(R,"Invisible Script","https://pastebin.com/raw/3Rnd9rHf")
    scriptBtn(R,"Emote Script","https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua")
    note(R,"Menu auto-minimizes when script executes")
end

-- KEYBINDS
do
    local L,R=tabL["Keybinds"],tabR["Keybinds"]
    note(L,"Click pill = rebind  ·  Right-click = remove")
    note(L,"⚠ G key is reserved for FreeCam exit")
    local featsL={{"fly","Fly"},{"noclip","Noclip"},{"speed","Speed Boost"},{"highJump","High Jump"},{"spinBot","Spinbot"},{"bunnyHop","Bunny Hop"},{"autoJump","Auto Jump"},{"infinite_jump","Infinite Jump"},{"freecam","FreeCam"},{"antiAfk","Anti-AFK"},{"removeAnims","Remove Anims"},{"soloSession","Solo Session"},{"aimbot","Aimbot Trigger"},{"triggerbot","Triggerbot"}}
    local featsR={{"esp","Toggle ESP"},{"espClean","Clean ESP"},{"espCorner","Corner Box"},{"espBoxFull","Full Box"},{"espSkeleton","Skeleton"},{"espTracer","Tracer"},{"espNames","ESP Names"},{"espHealth","ESP Health"},{"espDist","ESP Distance"},{"espChams","Chams"},{"espHeadDot","Head Dot"},{"invisible","Invisible"},{"headless","Headless"},{"fullbright","Fullbright"},{"noFog","No Fog"},{"crosshair","Crosshair"},{"freezeTime","Freeze Time"},{"antiLag","Anti-Lag"},{"antiKick","Anti-Kick"},{"antiDetect","Anti-Detect"}}
    for _,pair in ipairs(featsL) do kbWidget(L,pair[1],pair[2]) end
    for _,pair in ipairs(featsR) do kbWidget(R,pair[1],pair[2]) end
end

-- CONFIG
do
    local L,R=tabL["Config"],tabR["Config"]
    sec(L,"Quick Actions")
    note(L,"Settings save automatically on every change.")
    btn(L,"💾  Save Now",function() saveConfig(); notify("GLUHFIX","Config saved! ✓",3) end)
    btn(L,"🗑  Reset Config",function()
        pcall(function() local attrs=lp:GetAttributes(); for attr,_ in pairs(attrs) do if tostring(attr):sub(1,5)=="GF11_" then pcall(function() lp:SetAttribute(attr,nil) end) end end end)
        notify("GLUHFIX","Config reset - restart script",3)
    end)
    sec(L,"Active Features")
    local statusLabels={}
    local sfFN={{"fly","Fly"},{"noclip","Noclip"},{"speed","Speed"},{"highJump","High Jump"},{"spinBot","Spinbot"},{"bunnyHop","BHop"},{"infinite_jump","Inf Jump"},{"antiAfk","Anti-AFK"},{"antiLag","Anti-Lag"},{"removeAnims","No Anims"},{"soloSession","Solo Session"},{"aimbot","Aimbot"},{"triggerbot","Triggerbot"},{"invisible","Invisible"},{"headless","Headless"},{"freecam","FreeCam"},{"esp","ESP"},{"espClean","Clean ESP"},{"fullbright","Fullbright"},{"noFog","No Fog"},{"crosshair","Crosshair"},{"freezeTime","Freeze Time"}}
    for i,pair in ipairs(sfFN) do
        local k,n=pair[1],pair[2]
        local row=mk("Frame",{Size=UDim2.new(1,0,0,24),BackgroundColor3=i%2==0 and Color3.fromRGB(20,20,25) or Color3.fromRGB(17,17,21),BorderSizePixel=0},L); rnd(row,5)
        mk("TextLabel",{Text="  "..n,Size=UDim2.new(.65,0,1,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(175,175,188),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left},row)
        local vl=mk("TextLabel",{Text="OFF",Size=UDim2.new(.35,0,1,0),Position=UDim2.new(.65,0,0,0),BackgroundTransparency=1,TextColor3=DIM,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right},row)
        statusLabels[k]=vl
    end
    task.spawn(function() while true do task.wait(1)
        for k,lbl in pairs(statusLabels) do pcall(function() local on=CFG[k]; lbl.Text=on and "ON" or "OFF"; lbl.TextColor3=on and GREEN or DIM end) end
    end end)
    sec(R,"Info")
    local info=mk("Frame",{Size=UDim2.new(1,0,0,100),BackgroundColor3=Color3.fromRGB(18,18,22),BorderSizePixel=0},R); rnd(info,6)
    local itl=mk("TextLabel",{Text="GLUHFIX V11.1",Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,12,0,6),BackgroundTransparency=1,TextColor3=PINK,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},info)
    rTC(function() itl.TextColor3=PINK end)
    mk("TextLabel",{Text="Made by GLUHFIX  |  USE AT YOUR OWN RISK",Size=UDim2.new(1,-24,0,16),Position=UDim2.new(0,12,0,32),BackgroundTransparency=1,TextColor3=DIM,TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left},info)
    mk("TextLabel",{Text="Aimbot: HOLD or TOGGLE mode - switch in Combat tab",Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,48),BackgroundTransparency=1,TextColor3=Color3.fromRGB(65,65,78),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left},info)
    mk("TextLabel",{Text="G key: only EXITS freecam - cannot be bound",Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,62),BackgroundTransparency=1,TextColor3=Color3.fromRGB(65,65,78),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left},info)
    mk("TextLabel",{Text="Scripts tab: menu minimizes when script executes",Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,76),BackgroundTransparency=1,TextColor3=Color3.fromRGB(65,65,78),TextSize=12,Font=Enum.Font.GothamSemibold,TextXAlignment=Enum.TextXAlignment.Left},info)
end

-- SETTINGS
do
    local L,R=tabL["Settings"],tabR["Settings"]
    sec(L,"Menu Toggle Key")
    local kbDisp=mk("TextLabel",{Text="Menu Toggle:  [ Ctrl ]",Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(22,22,28),TextColor3=Color3.fromRGB(190,190,205),TextSize=12,Font=Enum.Font.GothamSemibold,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Center},L)
    rnd(kbDisp,6)
    btn(L,"Bind Toggle Key",function()
        kbDisp.Text="Press any key..."; kbDisp.TextColor3=Color3.fromRGB(255,140,0)
        local c; c=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                if inp.KeyCode==Enum.KeyCode.G then kbDisp.Text="BLOCKED - G is reserved"; task.delay(1.5,function() kbDisp.Text="Menu Toggle:  [ Ctrl ]"; kbDisp.TextColor3=PINK end); c:Disconnect(); return end
                CFG.toggleKey=inp.KeyCode; local kn=tostring(inp.KeyCode):match("%.(%a+)$") or "?"
                if inp.KeyCode==Enum.KeyCode.LeftControl or inp.KeyCode==Enum.KeyCode.RightControl then kn="Ctrl" end
                kbDisp.Text="Menu Toggle:  [ "..kn.." ]"; kbDisp.TextColor3=PINK; c:Disconnect(); saveConfig()
            end
        end)
    end)
    sec(L,"Theme")
    note(L,"Adjust sliders → press Apply to commit colour")
    local previewH=CFG.accentH
    local previewS=CFG.accentS
    local prevBar=mk("Frame",{Size=UDim2.new(1,0,0,6),BackgroundColor3=PINK,BorderSizePixel=0},L)
    rnd(prevBar,3); rTC(function() prevBar.BackgroundColor3=PINK end)
    sld(L,"Hue (drag = preview)",0,100,math.floor(CFG.accentH*100),1,function(v)
        previewH=v/100
        pcall(function() prevBar.BackgroundColor3=Color3.fromHSV(previewH,previewS,1) end)
    end)
    sld(L,"Saturation (drag = preview)",0,100,math.floor(CFG.accentS*100),1,function(v)
        previewS=v/100
        pcall(function() prevBar.BackgroundColor3=Color3.fromHSV(previewH,previewS,1) end)
    end)
    btn(L,"✅  Apply Colour Now",function()
        CFG.accentH=previewH; CFG.accentS=previewS
        refreshT()
        pcall(function() winStroke.Color=PINK end)
        saveConfig()
        notify("GLUHFIX","Theme applied! ✓",2)
    end)
    local function thB(lbl2,h,s)
        btn(L,lbl2,function()
            previewH=h; previewS=s
            CFG.accentH=h; CFG.accentS=s
            refreshT()
            pcall(function() winStroke.Color=PINK end)
            pcall(function() prevBar.BackgroundColor3=PINK end)
            saveConfig()
        end)
    end
    thB("🩷  Pink (Default)",0.92,0.85)
    thB("⬜  White / Mono",0.0,0.0)
    thB("🔵  Blue",0.60,0.95)
    thB("🟣  Purple",0.72,0.88)
    thB("🟢  Green",0.36,0.90)
    thB("🔴  Red",0.00,0.90)

    sec(R,"FPS Booster")
    note(R,"NOT automatic - click to apply manually")
    btn(R,"🚀  Apply FPS Boost Now",function()
        pcall(function() if setfpscap then setfpscap(0) end end)
        pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
        pcall(function() Lighting.GlobalShadows=false end)
        for _,v in ipairs(Lighting:GetChildren()) do pcall(function() if v:IsA("BloomEffect") then v.Enabled=false elseif v:IsA("BlurEffect") then v.Enabled=false elseif v:IsA("SunRaysEffect") then v.Enabled=false elseif v:IsA("Atmosphere") then v.Density=0; v.Haze=0 end end) end
        task.spawn(function() local desc=workspace:GetDescendants(); for i,v in ipairs(desc) do pcall(function() if v:IsA("ParticleEmitter") then v.Rate=0; v.Enabled=false elseif v:IsA("Fire") then v.Enabled=false elseif v:IsA("Smoke") then v.Enabled=false elseif v:IsA("Trail") then v.Enabled=false elseif v:IsA("BasePart") and v.CastShadow then v.CastShadow=false end end); if i%200==0 then task.wait() end end end)
        notify("GLUHFIX","FPS Boost applied! ✓",4)
    end)
    sec(R,"HUD & Display")
    tog(R,"Coordinates","showCoords",nil,nil)
    tog(R,"FPS Counter","showFPS",nil,nil)
    tog(R,"Chat Spy","chatSpy",nil,nil)
    sec(R,"Re-apply & Unload")
    btn(R,"Re-apply All Active Features",function()
        if CFG.invisible then applyInvis(true) end; if CFG.headless then applyHeadless(true) end
        if CFG.fullbright then applyFullbright(true) end; if CFG.antiLag then applyAntiLag(true) end
        if CFG.removeAnims then applyRemoveAnims(true) end; if CFG.soloSession then applySoloSession(true) end
        local h=getHum(); if h then if CFG.speed then pcall(function() h.WalkSpeed=CFG.speedMult end) end; if CFG.highJump then pcall(function() h.UseJumpPower=true; h.JumpPower=CFG.jumpPower end) end end
        notify("GLUHFIX","Re-applied! ✓",2)
    end)
    btn(R,"🗑  Unload Script",function()
        pcall(function()
            CFG.fly=false; stopFly(); CFG.noclip=false; stopNoclip(); CFG.bunnyHop=false; stopBhop()
            CFG.freecam=false; stopFreecam(); CFG.removeAnims=false; applyRemoveAnims(false)
            CFG.soloSession=false; applySoloSession(false)
            CFG.invisible=false; applyInvis(false); CFG.headless=false; applyHeadless(false)
            CFG.fullbright=false; applyFullbright(false)
            CFG.esp=false; CFG.espClean=false
            for _,d in pairs(espData) do
                if d.bb then pcall(function() d.bb:Destroy() end) end
                if d.hl then pcall(function() d.hl:Destroy() end) end
                if d.boxFr then pcall(function() d.boxFr:Destroy() end) end
                if d.skelFrP then pcall(function() d.skelFrP:Destroy() end) end
            end; espData={}
            for plr,d in pairs(cleanEspData) do
                for _,ln in ipairs(d.lines) do pcall(function() ln:Destroy() end) end
                if d.bb then pcall(function() d.bb:Destroy() end) end
                if d.hlInstance then pcall(function() d.hlInstance:Destroy() end) end
            end; cleanEspData={}
            local h=getHum(); if h then pcall(function() h.WalkSpeed=16; h.JumpPower=50; h.AutoRotate=true end) end
            pcall(function() RunService:UnbindFromRenderStep("GF_Master") end)
            pcall(function() RunService:UnbindFromRenderStep("GF_Freecam") end)
            pcall(function() gui:Destroy() end)
        end)
    end)
end

-- ============================================================
-- MASTER RENDER LOOP
-- ============================================================
RunService:BindToRenderStep("GF_Master",Enum.RenderPriority.Camera.Value,function(dt)

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

    if CFG.spinBot then local h=getHRP(); if h then pcall(function() h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(CFG.spinSpeed),0) end) end end

    if CFG.freezeTime then pcall(function() Lighting.ClockTime=CFG.frozenTime end) end

    if CFG.aimbot then
        fovCircle.Visible=true; fovStroke.Transparency=CFG.showFovCircle and 0.4 or 0.82
        local r=CFG.aimbotFOV; fovCircle.Size=UDim2.new(0,r*2,0,r*2)
        local rc=fovCircle:FindFirstChildOfClass("UICorner"); if rc then rc.CornerRadius=UDim.new(0,r) end
        if CFG.aimbotActivationMode=="hold" then
            local held=isKbHeld("aimbot")
            if held then
                if not aimbotWasHeld then aimbotWasHeld=true; aimbotStartLock() end
                if not aimbotLockedTarget or not aimbotLockedTarget.Parent then aimbotLockedTarget=getClosestTarget() end
                if aimbotLockedTarget and aimbotLockedTarget.Parent then
                    local canAim=true; if CFG.aimbotVisCheck then canAim=hasLOS(aimbotLockedTarget.Position) end
                    if not canAim then aimbotLockedTarget=getClosestTarget() end
                    if aimbotLockedTarget and aimbotLockedTarget.Parent then applyAimbotCamera(aimbotLockedTarget.Position) end
                end
            else if aimbotWasHeld then aimbotWasHeld=false; aimbotStopLock() end end
        else
            local down=isKbHeld("aimbot")
            if down and not aimbotTogglePrevDown then
                aimbotToggleActive=not aimbotToggleActive
                if aimbotToggleActive then aimbotStartLock(); aimbotLockedTarget=nil else aimbotStopLock() end
            end
            aimbotTogglePrevDown=down
            if aimbotToggleActive then
                if not aimbotLockedTarget or not aimbotLockedTarget.Parent then aimbotLockedTarget=getClosestTarget() end
                if aimbotLockedTarget and aimbotLockedTarget.Parent then applyAimbotCamera(aimbotLockedTarget.Position) end
            end
        end
    else fovCircle.Visible=false; if aimbotWasHeld or aimbotToggleActive then aimbotStopLock() end; aimbotWasHeld=false; aimbotToggleActive=false; aimbotTogglePrevDown=false end

    if CFG.triggerbot then
        local now=tick(); local myChar=lp.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHRP and not mouseHeld.LMB then
            pcall(function()
                local vp=cam.ViewportSize; local ray=cam:ViewportPointToRay(vp.X/2,vp.Y/2)
                local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances={myChar}
                local res=workspace:Raycast(ray.Origin,ray.Direction*1200,rp)
                if res and res.Instance then
                    local model=res.Instance:FindFirstAncestorOfClass("Model")
                    if model then
                        local hum=model:FindFirstChildOfClass("Humanoid"); local plr=Players:GetPlayerFromCharacter(model)
                        if hum and hum.Health>0 and plr and plr~=lp then
                            local delay=math.max(1,CFG.triggerbotDelay)/1000
                            if now-tbLastFire>=delay then
                                tbLastFire=now
                                task.spawn(function() pcall(function() mouse1press() end); task.wait(.055); pcall(function() mouse1release() end) end)
                            end
                        end
                    end
                end
            end)
        end
    end

    -- ESP
    espFrameCount=espFrameCount+1
    local ESP_REFRESH_RATE=8; local BB_REFRESH_RATE=12
    local doBoxUpdate=(espFrameCount%ESP_REFRESH_RATE==0)
    local doBBUpdate=(espFrameCount%BB_REFRESH_RATE==0)

    if CFG.esp and CFG.espClean then
        local ecol=getECol(); local myHRP2=getHRP()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=lp and plr.Character then
                if not (CFG.soloSession and soloSessionData[plr]) then
                    local hrp2=getHRPBypass(plr.Character); local humX=plr.Character:FindFirstChildOfClass("Humanoid")
                    if hrp2 then
                        local dist=myHRP2 and math.floor((hrp2.Position-myHRP2.Position).Magnitude) or 999
                        ensureCleanESP(plr)
                        if dist<=CFG.espMaxDist then drawCleanESP(plr,ecol,CFG.espLineThick,dist,humX) else hideCleanESP(plr) end
                    end
                else hideCleanESP(plr) end
            end
        end
        for plr,_ in pairs(cleanEspData) do if not Players:FindFirstChild(plr.Name) then hideCleanESP(plr) end end
        for _,d in pairs(espData) do
            if d.bb and d.bbEnabled then pcall(function() d.bb.Enabled=false end); d.bbEnabled=false end
            if d.hl then pcall(function() d.hl:Destroy() end); d.hl=nil end
            if d.linePool then hidePool(d.linePool,1); d.lineUsed=0 end
            if d.skelPool then hidePool(d.skelPool,1); d.skelUsed=0 end
        end
        return
    end

    for plr,_ in pairs(cleanEspData) do hideCleanESP(plr) end
    if not CFG.esp then
        for _,d in pairs(espData) do
            if d.bb and d.bbEnabled then pcall(function() d.bb.Enabled=false end); d.bbEnabled=false end
            if d.hl then pcall(function() d.hl:Destroy() end); d.hl=nil end
            if d.linePool then hidePool(d.linePool,1); d.lineUsed=0 end
            if d.skelPool then hidePool(d.skelPool,1); d.skelUsed=0 end
        end
        return
    end

    if not doBoxUpdate and not doBBUpdate then return end
    local myHRP=getHRP(); local ecol=getECol()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            if CFG.soloSession and soloSessionData[plr] then
                local d=espData[plr]
                if d then
                    if d.bb and d.bbEnabled then pcall(function() d.bb.Enabled=false end); d.bbEnabled=false end
                    if d.linePool then hidePool(d.linePool,1); d.lineUsed=0 end
                    if d.skelPool then hidePool(d.skelPool,1); d.skelUsed=0 end
                end
            else
                local hrp=getHRPBypass(plr.Character); local hum=plr.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    local dist=myHRP and math.floor((hrp.Position-myHRP.Position).Magnitude) or 999
                    if dist>CFG.espMaxDist then
                        local d=espData[plr]
                        if d then
                            if d.bb and d.bbEnabled then pcall(function() d.bb.Enabled=false end); d.bbEnabled=false end
                            if d.linePool then hidePool(d.linePool,1); d.lineUsed=0 end
                            if d.skelPool then hidePool(d.skelPool,1); d.skelUsed=0 end
                        end
                    else
                        local d=ensureESPData(plr,hrp)
                        if doBBUpdate then
                            if not d.bbEnabled then pcall(function() d.bb.Enabled=true end); d.bbEnabled=true end
                            local hp=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                            if d.nl then pcall(function() d.nl.Visible=CFG.espNames; d.nl.Text=plr.Name; d.nl.TextColor3=ecol end) end
                            if d.hpF then pcall(function() d.hpF.Parent.Visible=CFG.espHealth; d.hpF.Size=UDim2.new(hp,0,1,0); d.hpF.BackgroundColor3=Color3.fromRGB(math.floor(255*(1-hp)),math.floor(210*hp),55) end) end
                            if d.dl then pcall(function() d.dl.Visible=CFG.espDist; d.dl.Text=dist.."m" end) end
                        end
                        if doBoxUpdate then
                            d.lineUsed=0; d.skelUsed=0
                            local bonePos={}; local minX2,minY2,maxX2,maxY2=math.huge,math.huge,-math.huge,-math.huge; local anyVis2=false
                            local boneList=CFG.espSkeleton and getAllBones(plr.Character) or getBBoxBones(plr.Character)
                            for _,pn in ipairs(boneList) do
                                local pt=plr.Character:FindFirstChild(pn)
                                if pt then
                                    local ok2,sp,vis=pcall(function() return cam:WorldToViewportPoint(pt.Position) end)
                                    if ok2 and vis then anyVis2=true; bonePos[pn]=Vector2.new(sp.X,sp.Y)
                                        if sp.X<minX2 then minX2=sp.X end; if sp.Y<minY2 then minY2=sp.Y end
                                        if sp.X>maxX2 then maxX2=sp.X end; if sp.Y>maxY2 then maxY2=sp.Y end
                                    end
                                end
                            end
                            local headPt=plr.Character:FindFirstChild("Head")
                            local lFootPt=plr.Character:FindFirstChild("LeftFoot") or plr.Character:FindFirstChild("Left Leg")
                            local rFootPt=plr.Character:FindFirstChild("RightFoot") or plr.Character:FindFirstChild("Right Leg")
                            local lArmPt=plr.Character:FindFirstChild("LeftUpperArm") or plr.Character:FindFirstChild("Left Arm")
                            local rArmPt=plr.Character:FindFirstChild("RightUpperArm") or plr.Character:FindFirstChild("Right Arm")
                            local topY2,botY2,leftX2,rightX2=minY2,maxY2,minX2,maxX2
                            if headPt then
                                local headTop=headPt.Position+Vector3.new(0,headPt.Size.Y*.5+.1,0)
                                local ok2,sp,vis=pcall(function() return cam:WorldToViewportPoint(headTop) end)
                                if ok2 and vis then if sp.Y<topY2 then topY2=sp.Y end; if sp.X<leftX2 then leftX2=sp.X end; if sp.X>rightX2 then rightX2=sp.X end end
                            end
                            for _,fp in ipairs({lFootPt,rFootPt}) do
                                if fp then
                                    local footBot=fp.Position-Vector3.new(0,fp.Size.Y*.5,0)
                                    local ok2,sp,vis=pcall(function() return cam:WorldToViewportPoint(footBot) end)
                                    if ok2 and vis then if sp.Y>botY2 then botY2=sp.Y end; if sp.X<leftX2 then leftX2=sp.X end; if sp.X>rightX2 then rightX2=sp.X end end
                                end
                            end
                            for _,ap in ipairs({lArmPt,rArmPt}) do
                                if ap then
                                    local ok2,sp,vis=pcall(function() return cam:WorldToViewportPoint(ap.Position) end)
                                    if ok2 and vis then if sp.X<leftX2 then leftX2=sp.X end; if sp.X>rightX2 then rightX2=sp.X end end
                                end
                            end
                            if anyVis2 then
                                local PAD2=2; local px=leftX2-PAD2; local py=topY2-PAD2
                                local pw=(rightX2-leftX2)+PAD2*2; local ph2=(botY2-topY2)+PAD2*2
                                if pw<10 then pw=10 end; if ph2<10 then ph2=10 end
                                if CFG.espCorner then drawCBoxPooled(d,px,py,pw,ph2,ecol) end
                                if CFG.espBoxFull then drawFBoxPooled(d,px,py,pw,ph2,ecol) end
                                if CFG.espSkeleton then
                                    local skelPairs=getSkelPairs(plr.Character)
                                    for _,pair in ipairs(skelPairs) do
                                        local a=bonePos[pair[1]]; local b2=bonePos[pair[2]]
                                        if a and b2 then
                                            d.skelUsed=d.skelUsed+1; local sf=d.skelPool[d.skelUsed]
                                            if sf then updateLine(sf,a.X,a.Y,b2.X,b2.Y,ecol,CFG.espLineThick) end
                                        end
                                    end
                                end
                                if CFG.espHeadDot then
                                    local hp2=bonePos["Head"]
                                    if hp2 then
                                        d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]
                                        if f then f.Size=UDim2.new(0,8,0,8); f.Position=UDim2.new(0,hp2.X-4,0,hp2.Y-4); f.Rotation=0; f.BackgroundColor3=ecol; f.Visible=true end
                                    end
                                end
                                if CFG.espTracer then
                                    local sc=cam.ViewportSize
                                    local ep=bonePos["HumanoidRootPart"] or bonePos["Torso"] or bonePos["UpperTorso"]
                                    if ep then
                                        d.lineUsed=d.lineUsed+1; local f=d.linePool[d.lineUsed]
                                        if f then updateLine(f,sc.X/2,sc.Y,ep.X,ep.Y,ecol,CFG.espLineThick) end
                                    end
                                end
                            end
                            hidePool(d.linePool,d.lineUsed+1); hidePool(d.skelPool,d.skelUsed+1)
                        end
                        if CFG.espChams then
                            if not d.hl or not d.hl.Parent then
                                local hl=Instance.new("Highlight"); hl.Adornee=plr.Character; hl.FillTransparency=.80; hl.OutlineTransparency=0
                                hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                                local hlOk=pcall(function() hl.Parent=plr.Character end)
                                if not hlOk then pcall(function() hl.Parent=game:GetService("CoreGui") end) end
                                d.hl=hl
                            end
                            pcall(function() d.hl.FillColor=ecol; d.hl.OutlineColor=ecol end)
                        else
                            if d.hl then pcall(function() d.hl:Destroy() end); d.hl=nil end
                        end
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
-- HEARTBEAT
-- ============================================================
local lastAfkTime=tick()
local afkVU=pcall(function()
    game:GetService("VirtualUser")
end) and game:GetService("VirtualUser") or nil

local hbFrame=0
local kbToggleFeats={"fly","noclip","speed","highJump","spinBot","bunnyHop","autoJump","antiAfk","antiLag","infinite_jump","antiKick","antiDetect","invisible","headless","freecam","removeAnims","soloSession","fullbright","noFog","crosshair","freezeTime","showCoords","showFPS","chatSpy","scannerAuto","triggerbot","esp","espClean","espCorner","espBoxFull","espSkeleton","espHeadDot","espChams","espHealth","espNames","espDist","espTracer"}
local kbPrevDown={}

task.spawn(function()
    lp.Idled:Connect(function()
        if CFG.antiAfk then
            pcall(function()
                local vu=game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                task.wait(.1)
                vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
        end
    end)
end)

RunService.Heartbeat:Connect(function(dt)
    hbFrame=hbFrame+1

    if CFG.speed then local hum=getHum(); if hum then pcall(function() hum.WalkSpeed=CFG.speedMult end) end end
    if CFG.highJump then local h=getHum(); if h then pcall(function() h.UseJumpPower=true; h.JumpPower=CFG.jumpPower end) end end
    if CFG.autoJump then local h=getHum(); if h and h.FloorMaterial~=Enum.Material.Air then pcall(function() h.Jump=true end) end end
    if CFG.infinite_jump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then local h=getHum(); if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end end

    if CFG.antiAfk then
        local now=tick()
        if now-lastAfkTime>=15 then
            lastAfkTime=now
            task.spawn(function()
                pcall(function()
                    local vu=game:GetService("VirtualUser")
                    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                    task.wait(.08)
                    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                end)
                local hrp=getHRP()
                if hrp then
                    pcall(function()
                        local bv=Instance.new("BodyVelocity")
                        bv.MaxForce=Vector3.new(1e4,0,1e4)
                        bv.Velocity=hrp.CFrame.LookVector*1.5
                        bv.Parent=hrp
                        task.wait(.12)
                        if bv and bv.Parent then bv:Destroy() end
                    end)
                end
            end)
        end
    else
        lastAfkTime=tick()
    end

    if hbFrame%2==0 then
        for _,feat in ipairs(kbToggleFeats) do
            local kb=CFG.keybinds[feat]; local down=false
            if kb then if kb.type=="key" then down=UserInputService:IsKeyDown(kb.value) elseif kb.type=="mouse" then down=mouseHeld[kb.value] or false end end
            if down and not kbPrevDown[feat] then
                CFG[feat]=not CFG[feat]
                if feat=="fly" then if CFG.fly then startFly() else stopFly() end end
                if feat=="noclip" then if CFG.noclip then startNoclip() else stopNoclip() end end
                if feat=="antiLag" then applyAntiLag(CFG.antiLag) end
                if feat=="fullbright" then applyFullbright(CFG.fullbright) end
                if feat=="crosshair" then xhF.Visible=CFG.crosshair end
                if feat=="invisible" then applyInvis(CFG.invisible) end
                if feat=="headless" then applyHeadless(CFG.headless) end
                if feat=="freezeTime" and CFG.freezeTime then CFG.frozenTime=Lighting.ClockTime end
                if feat=="bunnyHop" then if CFG.bunnyHop then startBhop() else stopBhop() end end
                if feat=="removeAnims" then applyRemoveAnims(CFG.removeAnims) end
                if feat=="soloSession" then applySoloSession(CFG.soloSession) end
                if feat=="freecam" then
                    if CFG.freecam then startFreecam(); freecamOverlay.Visible=true; task.delay(.05,function() showWin(false) end)
                    else stopFreecam(); freecamOverlay.Visible=false; showWin(true) end
                end
                if togRefreshRegistry[feat] then for _,rfn in ipairs(togRefreshRegistry[feat]) do pcall(rfn) end end
                saveConfig()
            end
            kbPrevDown[feat]=down
        end
    end

    if hbFrame%6==0 then
        local anyHud=CFG.showCoords or CFG.showFPS; hud.Visible=anyHud
        if anyHud then
            local fpsColor=currentFPS>=55 and GREEN or (currentFPS>=30 and Color3.fromRGB(255,140,0) or RED)
            hFPS.Text=CFG.showFPS and ("FPS: "..currentFPS) or ""
            hFPS.TextColor3=fpsColor
            if CFG.showCoords then
                local hrpX=getHRP(); if hrpX then local pos=hrpX.Position; hCoord.Text=("X:%.0f  Y:%.0f  Z:%.0f"):format(pos.X,pos.Y,pos.Z); local vel=hrpX.Velocity; hSpeed.Text="Speed: "..math.floor(math.sqrt(vel.X^2+vel.Z^2)).."  Y:"..math.floor(vel.Y) else hCoord.Text="---"; hSpeed.Text="" end
                hGrav.Text="Gravity: "..math.floor(workspace.Gravity).."  Time: "..string.format("%.1f",Lighting.ClockTime)
            else hCoord.Text=""; hSpeed.Text=""; hGrav.Text="" end
            local feats={}
            if CFG.fly then table.insert(feats,"FLY") end; if CFG.speed then table.insert(feats,"SPD") end
            if CFG.noclip then table.insert(feats,"NCIP") end; if CFG.aimbot then table.insert(feats,"AIM") end
            if CFG.esp then table.insert(feats,"ESP") end
            if CFG.invisible then table.insert(feats,"INVIS") end
            if CFG.freecam then table.insert(feats,"CAM") end; if CFG.soloSession then table.insert(feats,"SOLO") end
            hFeats.Text="Active: "..(#feats>0 and table.concat(feats," · ") or "none")
            hInfo.Text="GLUHFIX V11.1 | "..lp.Name
        end
    end
end)

-- ============================================================
-- CHAT SPY / RESPAWN / PLAYERS
-- ============================================================
for _,p in ipairs(Players:GetPlayers()) do p.Chatted:Connect(function(msg) if CFG.chatSpy then print("[CHAT]["..p.Name.."]: "..msg) end end) end
Players.PlayerAdded:Connect(function(p) p.Chatted:Connect(function(msg) if CFG.chatSpy then print("[CHAT]["..p.Name.."]: "..msg) end end) end)

local function reAttachESP(plr)
    task.wait(.35)
    if not plr.Character then return end
    local newHRP=plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso") or plr.Character:FindFirstChild("UpperTorso")
    if not newHRP then return end
    local d=espData[plr]
    if d then
        if d.bb then pcall(function() d.bb:Destroy() end); d.bb=nil end
    end
    local cd=cleanEspData[plr]
    if cd then
        if cd.bb then pcall(function() cd.bb:Destroy() end); cd.bb=nil end
        cd.bbEnabled=false
    end
end

local function hookPlayerESP(plr)
    plr.CharacterAdded:Connect(function()
        reAttachESP(plr)
        if CFG.soloSession then task.wait(.5); if CFG.soloSession then hideSoloPlayer(plr) end end
    end)
end

for _,plr in ipairs(Players:GetPlayers()) do
    if plr~=lp then hookPlayerESP(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    hookPlayerESP(plr)
end)
Players.PlayerRemoving:Connect(function(plr)
    local d=espData[plr]
    if d then
        pcall(function() if d.bb then d.bb:Destroy() end end)
        pcall(function() if d.hl then d.hl:Destroy() end end)
        pcall(function() if d.boxFr then d.boxFr:Destroy() end end)
        pcall(function() if d.skelFrP then d.skelFrP:Destroy() end end)
        espData[plr]=nil
    end
    local cd=cleanEspData[plr]
    if cd then
        for _,ln in ipairs(cd.lines) do pcall(function() ln:Destroy() end) end
        pcall(function() if cd.bb then cd.bb:Destroy() end end)
        pcall(function() if cd.hlInstance then cd.hlInstance:Destroy() end end)
        cleanEspData[plr]=nil
    end
end)

lp.CharacterAdded:Connect(function(c)
    task.wait(.65); invisOrigData={}
    if CFG.invisible then applyInvis(true) end; if CFG.headless then applyHeadless(true) end
    if CFG.fullbright then applyFullbright(true) end; if CFG.antiLag then applyAntiLag(true) end
    if CFG.removeAnims then task.wait(.5); applyRemoveAnims(true) end
    if CFG.soloSession then task.wait(.3); applySoloSession(true) end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then if CFG.speed then pcall(function() h.WalkSpeed=CFG.speedMult end) end; if CFG.highJump then pcall(function() h.UseJumpPower=true; h.JumpPower=CFG.jumpPower end) end end
    if CFG.fly then stopFly(); task.wait(.1); startFly() end
    if CFG.noclip then startNoclip() end; if CFG.bunnyHop then startBhop() end
    if CFG.freecam then stopFreecam(); task.wait(.1); startFreecam() end
    aimbotToggleActive=false; aimbotWasHeld=false
    lastAfkTime=tick()
end)

-- ============================================================
-- TOGGLE KEY + G KEY
-- ============================================================
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==CFG.toggleKey then if not freecamActive then showWin(not Win.Visible) end; return end
    if inp.KeyCode==Enum.KeyCode.G then
        if freecamActive then
            CFG.freecam=false; stopFreecam(); freecamOverlay.Visible=false; showWin(true)
            if togRefreshRegistry["freecam"] then for _,rfn in ipairs(togRefreshRegistry["freecam"]) do pcall(rfn) end end
            saveConfig()
        end; return
    end
end)

-- ============================================================
-- INIT
-- ============================================================
switchTab("Move")
Win.Visible=false; Win.Size=UDim2.new(0,WIN_W,0,WIN_H)

-- ============================================================
-- STARTUP ANIMATION
-- ============================================================
_guiUnlocked=false

local function runIntro()
    local I={}

    I.ov=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(4,4,6),BackgroundTransparency=0,BorderSizePixel=0,ZIndex=900},gui)

    I.pts={}
    for _,pos in ipairs({{.15,.2},{.85,.2},{.1,.75},{.9,.75},{.3,.1},{.7,.9},{.5,.15},{.5,.85}}) do
        local p=mk("Frame",{Size=UDim2.new(0,3,0,3),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(pos[1],0,pos[2],0),BackgroundColor3=PINK,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=901},I.ov)
        rnd(p,2); table.insert(I.pts,p)
    end

    I.glow=mk("Frame",{Size=UDim2.new(0,0,0,0),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundColor3=PINK,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=901},I.ov)
    rnd(I.glow,600)

    I.top=mk("Frame",{Size=UDim2.new(0,0,0,1.5),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,0,0),BackgroundColor3=PINK,BackgroundTransparency=0,BorderSizePixel=0,ZIndex=902},I.ov)
    I.bot=mk("Frame",{Size=UDim2.new(0,0,0,1.5),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,1,0),BackgroundColor3=PINK,BackgroundTransparency=0,BorderSizePixel=0,ZIndex=902},I.ov)

    I.logo=mk("TextLabel",{Text="GLUHFIX",AnchorPoint=Vector2.new(.5,.5),Size=UDim2.new(0,600,0,80),Position=UDim2.new(.5,0,.5,-18),BackgroundTransparency=1,TextColor3=WHITE,TextTransparency=1,TextSize=68,Font=Enum.Font.GothamBold,ZIndex=904},I.ov)
    I.stroke=mk("UIStroke",{Color=PINK,Thickness=0,Transparency=0.2},I.logo)

    I.ver=mk("TextLabel",{Text="V11.1",AnchorPoint=Vector2.new(.5,.5),Size=UDim2.new(0,200,0,24),Position=UDim2.new(.5,0,.5,24),BackgroundTransparency=1,TextColor3=PINK,TextTransparency=1,TextSize=15,Font=Enum.Font.GothamBold,ZIndex=904},I.ov)
    I.tag=mk("TextLabel",{Text="BUILT DIFFERENT",AnchorPoint=Vector2.new(.5,.5),Size=UDim2.new(0,400,0,18),Position=UDim2.new(.5,0,.5,44),BackgroundTransparency=1,TextColor3=Color3.fromRGB(80,80,100),TextTransparency=1,TextSize=11,Font=Enum.Font.GothamBold,ZIndex=904,TextXAlignment=Enum.TextXAlignment.Center},I.ov)
    I.nam=mk("TextLabel",{Text="Welcome, "..lp.Name,AnchorPoint=Vector2.new(.5,.5),Size=UDim2.new(0,500,0,22),Position=UDim2.new(.5,0,.5,68),BackgroundTransparency=1,TextColor3=Color3.fromRGB(160,140,200),TextTransparency=1,TextSize=13,Font=Enum.Font.GothamSemibold,ZIndex=904},I.ov)

    I.barbg=mk("Frame",{Size=UDim2.new(0,280,0,2),AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,1,-28),BackgroundColor3=Color3.fromRGB(22,22,28),BorderSizePixel=0,ZIndex=903},I.ov)
    rnd(I.barbg,1)
    I.bar=mk("Frame",{Size=UDim2.new(0,0,1,0),BackgroundColor3=PINK,BorderSizePixel=0,ZIndex=904},I.barbg)
    rnd(I.bar,1)
    I.bartxt=mk("TextLabel",{Text="INITIALIZING",Size=UDim2.new(1,0,0,14),AnchorPoint=Vector2.new(.5,1),Position=UDim2.new(.5,0,0,-5),BackgroundTransparency=1,TextColor3=Color3.fromRGB(70,70,88),TextSize=10,Font=Enum.Font.GothamBold,TextTransparency=1,ZIndex=903},I.barbg)

    I.run=true
    task.spawn(function()
        local ht=0
        while I.run do
            ht=ht+0.012
            local ph=0.72+((math.sin(ht)+1)/2)*0.22
            local pc=Color3.fromHSV(ph,0.9,1)
            pcall(function()
                I.top.BackgroundColor3=pc; I.bot.BackgroundColor3=pc
                I.glow.BackgroundColor3=pc; I.bar.BackgroundColor3=pc
                I.ver.TextColor3=pc; I.stroke.Color=pc
            end)
            task.wait(0.033)
        end
    end)

    task.spawn(function()
        tw(I.top,.30,{Size=UDim2.new(1,0,0,1.5)},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
        tw(I.bot,.30,{Size=UDim2.new(1,0,0,1.5)},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
        task.wait(.10)
        tw(I.glow,.50,{Size=UDim2.new(0,700,0,700),BackgroundTransparency=.93},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
        for _,p in ipairs(I.pts) do
            tw(p,.40,{BackgroundTransparency=.55},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
            task.wait(.03)
        end
        tw(I.logo,.35,{TextTransparency=0},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        tw(I.stroke,.35,{Thickness=2},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        task.wait(.20)
        tw(I.ver,.22,{TextTransparency=0},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        tw(I.tag,.22,{TextTransparency=0},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        task.wait(.15)
        tw(I.nam,.28,{TextTransparency=0},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
        tw(I.bartxt,.15,{TextTransparency=0})
        task.wait(.10)
        tw(I.bar,.60,{Size=UDim2.new(1,0,1,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.InOut)
        task.wait(.65)
        I.run=false
        tw(I.logo,.22,{TextTransparency=1,Position=UDim2.new(.5,0,.5,-36)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        tw(I.stroke,.22,{Thickness=0})
        tw(I.ver,.22,{TextTransparency=1,Position=UDim2.new(.5,0,.5,18)})
        tw(I.tag,.22,{TextTransparency=1})
        tw(I.nam,.22,{TextTransparency=1})
        tw(I.top,.22,{Size=UDim2.new(0,0,0,1.5)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        tw(I.bot,.22,{Size=UDim2.new(0,0,0,1.5)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        for _,p in ipairs(I.pts) do tw(p,.18,{BackgroundTransparency=1}) end
        tw(I.bar,.18,{BackgroundTransparency=1})
        tw(I.bartxt,.18,{TextTransparency=1})
        tw(I.glow,.22,{BackgroundTransparency=1})
        task.wait(.12)
        tw(I.ov,.32,{BackgroundTransparency=1},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        task.wait(.35)
        pcall(function() I.ov:Destroy() end)
        _guiUnlocked=true
        showWin(true)
    end)
end
runIntro()

print("GLUHFIX V11.1 loaded - Hello, "..lp.Name)
print("  Toggle: [Ctrl]  |  [G] = exit FreeCam only")
