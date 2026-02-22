--[[
  ⚡  G L U H F I X  v 9 . 0  —  FINAL
  Toggle: [Left Ctrl]
  Made by GLUHFIX
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local Debris           = game:GetService("Debris")
local StarterGui       = game:GetService("StarterGui")
local TeleportService  = game:GetService("TeleportService")
local ContextActionService = game:GetService("ContextActionService")
local AnimationTrackService = nil
pcall(function() AnimationTrackService = game:GetService("AnimationService") end)

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera

local function getChar() return lp.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ============================================================
-- CONFIG
-- ============================================================
local CFG = {
    toggleKey      = Enum.KeyCode.LeftControl,
    aimbotKey      = Enum.KeyCode.CapsLock,
    aimbotMouseBtn = nil,  -- nil = no mouse button, or Enum.UserInputType.MouseButton1/2
    triggerbotKey  = Enum.KeyCode.Unknown, -- triggerbot hold key
    triggerbotMouse= Enum.UserInputType.MouseButton1, -- default LMB
    accentH=0.0, accentS=0.0,

    fly=false,      flySpeed=80,
    noclip=false,
    speed=false,    speedMult=2,
    highJump=false, jumpPower=180,
    spinBot=false,  spinSpeed=12,
    bunnyHop=false,
    autoJump=false,
    antiAfk=false,  antiLag=false,
    infinite_jump=false,

    aimbot=false,   aimbotFOV=120,  aimbotSmooth=18,
    aimbotTeamCheck=false, aimbotBone="Head",
    aimbotVisCheck=true,
    triggerbot=false, triggerbotDelay=0.05,

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

    _origBright = Lighting.Brightness,
    _origFogEnd = Lighting.FogEnd,
    _origAmbient= Lighting.Ambient,
    _origOutdoor= Lighting.OutdoorAmbient,
}

-- ============================================================
-- SAVE / LOAD
-- ============================================================
local function saveConfig()
    pcall(function()
        for _,k in ipairs({"accentH","accentS","flySpeed","speedMult","jumpPower","spinSpeed",
            "aimbotFOV","aimbotSmooth","espMaxDist","espColorH","espColorS","espColorV",
            "espLineThick","crosshairStyle","crosshairColorH","crosshairSize","frozenTime",
            "gravity","triggerbotDelay"}) do
            lp:SetAttribute("GF9_"..k, tostring(CFG[k]))
        end
        for _,k in ipairs({"fly","noclip","speed","highJump","spinBot","bunnyHop","autoJump",
            "antiAfk","antiLag","infinite_jump","aimbot","aimbotTeamCheck","aimbotVisCheck",
            "triggerbot","antiKick","antiDetect","invisible","headless",
            "esp","espHealth","espNames","espDist","espChams","espCorner","espSkeleton",
            "espHeadDot","espBoxFull","espTracer","fullbright","noFog","crosshair","freezeTime",
            "showCoords","showFPS","chatSpy"}) do
            lp:SetAttribute("GF9_b_"..k, CFG[k] and "1" or "0")
        end
    end)
end
local function loadConfig()
    pcall(function()
        for _,k in ipairs({"accentH","accentS","flySpeed","speedMult","jumpPower","spinSpeed",
            "aimbotFOV","aimbotSmooth","espMaxDist","espColorH","espColorS","espColorV",
            "espLineThick","crosshairStyle","crosshairColorH","crosshairSize","frozenTime",
            "gravity","triggerbotDelay"}) do
            local v=lp:GetAttribute("GF9_"..k); if v then CFG[k]=tonumber(v) or CFG[k] end
        end
        for _,k in ipairs({"fly","noclip","speed","highJump","spinBot","bunnyHop","autoJump",
            "antiAfk","antiLag","infinite_jump","aimbot","aimbotTeamCheck","aimbotVisCheck",
            "triggerbot","antiKick","antiDetect","invisible","headless",
            "esp","espHealth","espNames","espDist","espChams","espCorner","espSkeleton",
            "espHeadDot","espBoxFull","espTracer","fullbright","noFog","crosshair","freezeTime",
            "showCoords","showFPS","chatSpy"}) do
            local v=lp:GetAttribute("GF9_b_"..k); if v then CFG[k]=(v=="1") end
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
    T.accDark = mono and Color3.fromRGB(32,32,32)    or Color3.fromHSV(h,s*.8,.16)
    T.accGlow = mono and Color3.fromRGB(20,20,20)    or Color3.fromHSV(h,s*.85,.12)
    T.bg      = Color3.fromRGB(8,8,8)
    T.panel   = Color3.fromRGB(13,13,13)
    T.row     = Color3.fromRGB(18,18,18)
    T.rowHov  = Color3.fromRGB(28,28,28)
    T.border  = mono and Color3.fromRGB(48,48,48) or Color3.fromHSV(h,s*.3,.32)
    T.txt     = Color3.fromRGB(220,220,220)
    T.dim     = Color3.fromRGB(85,85,85)
    T.green   = Color3.fromRGB(60,220,100)
    T.red     = Color3.fromRGB(255,55,75)
    T.white   = Color3.fromRGB(255,255,255)
    T.purple  = Color3.fromRGB(168,85,247)
    for _,cb in ipairs(thCBs) do pcall(cb) end
end
refreshT()

-- ============================================================
-- GUI ROOT
-- ============================================================
if lp.PlayerGui:FindFirstChild("GF9") then lp.PlayerGui.GF9:Destroy() end
local gui=Instance.new("ScreenGui")
gui.Name="GF9"; gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset=true; gui.Parent=lp.PlayerGui

-- HELPERS
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
local function addGlow(parent,col,sz,tp)
    local g=mk("Frame",{Size=UDim2.new(1,sz,1,sz),Position=UDim2.new(0,-sz/2,0,-sz/2),
        BackgroundColor3=col,BackgroundTransparency=tp or .86,BorderSizePixel=0,ZIndex=0},parent)
    rnd(g,20+sz/2); rTC(function() g.BackgroundColor3=T.accent end); return g
end

-- ============================================================
-- "Made by GLUHFIX" — always visible watermark (purple, bottom right)
-- ============================================================
local watermark = mk("TextLabel",{
    Text="made by GLUHFIX",
    Size=UDim2.new(0,160,0,22),
    AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,-10,1,-10),
    BackgroundTransparency=1,
    TextColor3=Color3.fromRGB(168,85,247),
    TextSize=12, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Right,
    ZIndex=900
},gui)
-- subtle glow effect on watermark
local wmStroke=mk("UIStroke",{Color=Color3.fromRGB(168,85,247),Thickness=0,Transparency=.6},watermark)

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local Win=mk("Frame",{
    Size=UDim2.new(0,710,0,650),AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,0,.5,0),BackgroundColor3=T.bg,
    BorderSizePixel=0,ClipsDescendants=false,Visible=false
},gui)
rnd(Win,16)
local winStroke=mk("UIStroke",{Color=T.accent,Thickness=2},Win)
rTC(function() winStroke.Color=T.accent end)
for _,sz in ipairs({40,75,115}) do addGlow(Win,T.accent,sz,.91+sz/1100) end

-- ============================================================
-- HEADER
-- ============================================================
local Hdr=mk("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=T.panel,BorderSizePixel=0},Win)
rnd(Hdr,16)
mk("UIGradient",{Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(20,20,20)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(8,8,8))
}),Rotation=90},Hdr)

local hLine=mk("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),
    BackgroundColor3=T.accent,BorderSizePixel=0},Hdr)
rTC(function() hLine.BackgroundColor3=T.accent end)

mk("TextLabel",{
    Text="Hello, "..lp.Name,
    Size=UDim2.new(0,380,0,32),Position=UDim2.new(0,16,0,8),
    BackgroundTransparency=1,TextColor3=T.white,
    TextSize=22,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left
},Hdr)
mk("TextLabel",{
    Text="⚡ GLUHFIX v9.0  •  [Left Ctrl] toggle",
    Size=UDim2.new(0,340,0,16),Position=UDim2.new(0,16,0,38),
    BackgroundTransparency=1,TextColor3=T.dim,
    TextSize=11,Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left
},Hdr)

local aPill=mk("Frame",{Size=UDim2.new(0,76,0,24),AnchorPoint=Vector2.new(1,.5),
    Position=UDim2.new(1,-50,.5,0),BackgroundColor3=Color3.fromRGB(8,32,16),BorderSizePixel=0},Hdr)
rnd(aPill,12); mk("UIStroke",{Color=T.green,Thickness=1,Transparency=.4},aPill)
mk("TextLabel",{Text="● ACTIVE",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    TextColor3=T.green,TextSize=10,Font=Enum.Font.GothamBold},aPill)

-- RED X close button (not a rectangle — just the X)
local closeBtn=mk("TextButton",{
    Text="✕",Size=UDim2.new(0,30,0,30),AnchorPoint=Vector2.new(1,.5),
    Position=UDim2.new(1,-11,.5,0),
    BackgroundTransparency=1,  -- transparent background = just the X visible
    TextColor3=T.red,TextSize=18,Font=Enum.Font.GothamBold,BorderSizePixel=0
},Hdr)
closeBtn.MouseEnter:Connect(function()
    tw(closeBtn,.1,{TextColor3=Color3.fromRGB(255,100,120)})
    closeBtn.TextSize=22
end)
closeBtn.MouseLeave:Connect(function()
    tw(closeBtn,.1,{TextColor3=T.red})
    closeBtn.TextSize=18
end)

-- Mini button (⚡ lightning bolt, always on screen when menu closed)
local MiniBtn=mk("TextButton",{Text="⚡",Size=UDim2.new(0,44,0,44),
    Position=UDim2.new(0,10,.5,-22),BackgroundColor3=T.accent,
    TextColor3=T.bg,TextSize=20,Font=Enum.Font.GothamBold,BorderSizePixel=0,Visible=false},gui)
rnd(MiniBtn,22); rTC(function() MiniBtn.BackgroundColor3=T.accent; MiniBtn.TextColor3=T.bg end)

local function showWin(v)
    if v then
        Win.Visible=true; Win.BackgroundTransparency=1
        tw(Win,.22,{BackgroundTransparency=0}); MiniBtn.Visible=false
    else
        tw(Win,.18,{BackgroundTransparency=1})
        task.delay(.19,function() Win.Visible=false end); MiniBtn.Visible=true
    end
end
closeBtn.MouseButton1Click:Connect(function() showWin(false) end)
MiniBtn.MouseButton1Click:Connect(function() showWin(true) end)

-- Drag
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

-- Tooltip
local Tip=mk("Frame",{Size=UDim2.new(0,260,0,36),BackgroundColor3=Color3.fromRGB(10,10,10),
    BorderSizePixel=0,Visible=false,ZIndex=700},gui)
rnd(Tip,8); mk("UIStroke",{Color=T.border,Thickness=1},Tip)
local TipL=mk("TextLabel",{Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,7,0,0),
    BackgroundTransparency=1,TextColor3=Color3.fromRGB(210,210,210),TextSize=11,Font=Enum.Font.Gotham,
    ZIndex=701,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},Tip)
-- dark BG for readability
mk("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(15,15,15),Color3.fromRGB(5,5,5)),Rotation=45},Tip)
local function tip(o,txt)
    o.MouseEnter:Connect(function() TipL.Text=txt; Tip.Visible=true end)
    o.MouseMoved:Connect(function(x,y)
        local vp=cam.ViewportSize
        local tx=math.min(x+16, vp.X-265)
        local ty=math.min(y+12, vp.Y-44)
        Tip.Position=UDim2.new(0,tx,0,ty)
    end)
    o.MouseLeave:Connect(function() Tip.Visible=false end)
end

-- ============================================================
-- TABS
-- ============================================================
local TABS={
    {id="Move",    icon="✈", col=Color3.fromHSV(.60,.90,1)},
    {id="Combat",  icon="⚔", col=Color3.fromHSV(.00,.90,1)},
    {id="Visual",  icon="👁", col=Color3.fromHSV(.13,.90,1)},
    {id="World",   icon="🌍", col=Color3.fromHSV(.34,.88,1)},
    {id="Player",  icon="👤", col=Color3.fromHSV(.72,.88,1)},
    {id="ESP",     icon="🟩", col=Color3.fromHSV(.40,.90,1)},
    {id="Emotes",  icon="💃", col=Color3.fromHSV(.85,.85,1)},
    {id="Map",     icon="🗺", col=Color3.fromHSV(.10,.82,1)},
    {id="Config",  icon="💾", col=Color3.fromRGB(180,180,180)},
    {id="Settings",icon="⚙", col=Color3.fromRGB(180,180,180)},
}

local TabBar=mk("Frame",{Size=UDim2.new(1,-16,0,44),Position=UDim2.new(0,8,0,66),
    BackgroundColor3=T.panel,BorderSizePixel=0,ClipsDescendants=true},Win)
rnd(TabBar,11); mk("UIStroke",{Color=T.border,Thickness=1},TabBar)
mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,2),
    VerticalAlignment=Enum.VerticalAlignment.Center},TabBar)
pad(TabBar,3,3,5,5)

local TabInd=mk("Frame",{Size=UDim2.new(0,60,0,3),Position=UDim2.new(0,3,1,-3),
    BackgroundColor3=T.accent,BorderSizePixel=0},TabBar)
rnd(TabInd,2); rTC(function() TabInd.BackgroundColor3=T.accent end)

local Content=mk("Frame",{Size=UDim2.new(1,-16,1,-124),Position=UDim2.new(0,8,0,118),
    BackgroundColor3=T.panel,BorderSizePixel=0,ClipsDescendants=true},Win)
rnd(Content,11); mk("UIStroke",{Color=T.border,Thickness=1},Content)

local tabBtns,tabScrolls,activeTab={},{},""

local function makeScroll(p)
    local sf=mk("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.accent,
        CanvasSize=UDim2.new(0,0,0,0),Visible=false},p)
    rTC(function() sf.ScrollBarImageColor3=T.accent end)
    local ll=mk("UIListLayout",{Padding=UDim.new(0,5)},sf)
    pad(sf,10,10,8,10)
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+20)
    end)
    return sf
end

local function switchTab(id)
    if activeTab==id then return end; activeTab=id
    for n,b in pairs(tabBtns) do
        local info; for _,t in ipairs(TABS) do if t.id==n then info=t;break end end
        local on=(n==id)
        if on then
            tw(b,.15,{BackgroundColor3=info and info.col or T.accent,BackgroundTransparency=0})
            b.TextColor3=Color3.fromRGB(0,0,0)
            local s=b:FindFirstChildOfClass("UIStroke")
            if s then s.Color=info and info.col or T.accent; s.Thickness=1.5 end
        else
            tw(b,.15,{BackgroundColor3=T.accGlow,BackgroundTransparency=0})
            b.TextColor3=T.dim
            local s=b:FindFirstChildOfClass("UIStroke"); if s then s.Color=T.border; s.Thickness=1 end
        end
    end
    for n,sf in pairs(tabScrolls) do
        if n==id then sf.Visible=true; sf.Position=UDim2.new(0,0,.03,0); tw(sf,.14,{Position=UDim2.new(0,0,0,0)})
        else sf.Visible=false end
    end
    local b=tabBtns[id]; if b then
        local bx=b.AbsolutePosition.X-TabBar.AbsolutePosition.X
        local tc=T.accent; for _,t in ipairs(TABS) do if t.id==id then tc=t.col;break end end
        tw(TabInd,.17,{Size=UDim2.new(0,b.AbsoluteSize.X-4,0,3),Position=UDim2.new(0,bx+2,1,-3),BackgroundColor3=tc})
    end
end

for _,t in ipairs(TABS) do
    local b=mk("TextButton",{Text=t.icon.." "..t.id,Size=UDim2.new(0,60,0,34),
        BackgroundColor3=T.accGlow,TextColor3=T.dim,TextSize=8,
        Font=Enum.Font.GothamBold,BorderSizePixel=0},TabBar)
    rnd(b,8); mk("UIStroke",{Color=T.border,Thickness=1},b)
    tabBtns[t.id]=b; tabScrolls[t.id]=makeScroll(Content)
    b.MouseButton1Click:Connect(function() switchTab(t.id) end)
    b.MouseEnter:Connect(function()
        if activeTab~=t.id then tw(b,.1,{BackgroundColor3=t.col,BackgroundTransparency=.55}); b.TextColor3=t.col end
    end)
    b.MouseLeave:Connect(function()
        if activeTab~=t.id then tw(b,.1,{BackgroundColor3=T.accGlow,BackgroundTransparency=0}); b.TextColor3=T.dim end
    end)
end

-- ============================================================
-- WIDGET BUILDERS
-- ============================================================
local function sec(tab,title)
    local f=mk("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=T.accDark,BorderSizePixel=0},tabScrolls[tab])
    rnd(f,8)
    mk("UIGradient",{Color=ColorSequence.new(Color3.fromRGB(32,32,32),Color3.fromRGB(12,12,12)),Rotation=90},f)
    local l=mk("TextLabel",{Text="  ▸  "..title:upper(),Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,TextColor3=T.accent2,TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},f)
    rTC(function() l.TextColor3=T.accent2 end)
end

local function tog(tab,label,key,tipTxt,cb)
    local row=mk("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=T.row,BorderSizePixel=0},tabScrolls[tab])
    rnd(row,11)
    local rowStroke=mk("UIStroke",{Color=Color3.fromRGB(26,26,26),Thickness=1},row)
    local hb=mk("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=3},row)
    hb.MouseEnter:Connect(function() tw(row,.1,{BackgroundColor3=T.rowHov}); rowStroke.Color=T.border end)
    hb.MouseLeave:Connect(function() tw(row,.1,{BackgroundColor3=T.row}); rowStroke.Color=Color3.fromRGB(26,26,26) end)
    local lbl=mk("TextLabel",{Text=label,Size=UDim2.new(1,-92,1,0),Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,TextColor3=T.txt,TextSize=13,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=2},row)
    local swBg=mk("Frame",{Size=UDim2.new(0,54,0,28),AnchorPoint=Vector2.new(1,.5),
        Position=UDim2.new(1,-14,.5,0),BackgroundColor3=Color3.fromRGB(22,22,22),BorderSizePixel=0,ZIndex=2},row)
    rnd(swBg,14)
    local knob=mk("Frame",{Size=UDim2.new(0,22,0,22),AnchorPoint=Vector2.new(0,.5),
        Position=UDim2.new(0,3,.5,0),BackgroundColor3=Color3.fromRGB(65,65,65),BorderSizePixel=0,ZIndex=3},swBg)
    rnd(knob,11)
    local function refresh()
        local on=CFG[key]
        tw(knob,.18,{Position=on and UDim2.new(1,-25,.5,0) or UDim2.new(0,3,.5,0),
            BackgroundColor3=on and T.accent or Color3.fromRGB(65,65,65)})
        tw(swBg,.18,{BackgroundColor3=on and T.accDark or Color3.fromRGB(22,22,22)})
        local s=swBg:FindFirstChildOfClass("UIStroke")
        if on then if not s then mk("UIStroke",{Color=T.accent,Thickness=1.5},swBg) end
        else if s then s:Destroy() end end
        lbl.TextColor3=on and T.accent or T.txt
    end
    rTC(function()
        knob.BackgroundColor3=CFG[key] and T.accent or Color3.fromRGB(65,65,65)
        swBg.BackgroundColor3=CFG[key] and T.accDark or Color3.fromRGB(22,22,22)
        lbl.TextColor3=CFG[key] and T.accent or T.txt
    end)
    hb.MouseButton1Click:Connect(function()
        CFG[key]=not CFG[key]; refresh()
        tw(row,.05,{Size=UDim2.new(1,-4,0,44)}); task.delay(.06,function() tw(row,.09,{Size=UDim2.new(1,0,0,48)}) end)
        if cb then pcall(function() cb(CFG[key]) end) end; saveConfig()
    end)
    if tipTxt then tip(row,tipTxt) end; refresh()
    return row,refresh
end

local function sld(tab,label,minV,maxV,defV,step,tipTxt,cb)
    step=step or 1
    local row=mk("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=T.row,BorderSizePixel=0},tabScrolls[tab])
    rnd(row,11); mk("UIStroke",{Color=Color3.fromRGB(26,26,26),Thickness=1},row)
    local lbl=mk("TextLabel",{Text=label.."   "..defV,Size=UDim2.new(1,-14,0,26),
        Position=UDim2.new(0,14,0,4),BackgroundTransparency=1,TextColor3=T.txt,
        TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},row)
    local track=mk("Frame",{Size=UDim2.new(1,-28,0,6),Position=UDim2.new(0,14,0,40),
        BackgroundColor3=Color3.fromRGB(22,22,22),BorderSizePixel=0},row)
    rnd(track,3)
    local fill=mk("Frame",{Size=UDim2.new((defV-minV)/(maxV-minV),0,1,0),
        BackgroundColor3=T.accent,BorderSizePixel=0},track)
    rnd(fill,3); rTC(function() fill.BackgroundColor3=T.accent end)
    local knob=mk("Frame",{Size=UDim2.new(0,16,0,16),AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new((defV-minV)/(maxV-minV),0,.5,0),BackgroundColor3=T.white,BorderSizePixel=0},track)
    rnd(knob,8)
    local dragging=false
    local function update(px)
        local rel=math.clamp((px-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val=math.clamp(math.floor((minV+rel*(maxV-minV))/step+.5)*step,minV,maxV)
        local fr=(val-minV)/(maxV-minV)
        fill.Size=UDim2.new(fr,0,1,0); knob.Position=UDim2.new(fr,0,.5,0)
        lbl.Text=label.."   "..val
        if cb then pcall(function() cb(val) end) end; saveConfig()
    end
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; tw(knob,.1,{Size=UDim2.new(0,20,0,20)}) end end)
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; update(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false; tw(knob,.1,{Size=UDim2.new(0,16,0,16)}) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
    if tipTxt then tip(row,tipTxt) end; return lbl
end

local function btn(tab,label,tipTxt,cb)
    local b=mk("TextButton",{Size=UDim2.new(1,0,0,42),BackgroundColor3=T.row,
        TextColor3=T.txt,TextSize=13,Text=label,Font=Enum.Font.GothamBold,BorderSizePixel=0},tabScrolls[tab])
    rnd(b,11); local bs=mk("UIStroke",{Color=T.border,Thickness=1.2},b)
    rTC(function() b.BackgroundColor3=T.row; bs.Color=T.border end)
    b.MouseEnter:Connect(function() tw(b,.1,{BackgroundColor3=T.rowHov}); bs.Color=T.accent; bs.Thickness=1.8; b.TextColor3=T.white end)
    b.MouseLeave:Connect(function() tw(b,.1,{BackgroundColor3=T.row}); bs.Color=T.border; bs.Thickness=1.2; b.TextColor3=T.txt end)
    b.MouseButton1Click:Connect(function()
        tw(b,.05,{Size=UDim2.new(1,-6,0,38)}); task.delay(.06,function() tw(b,.08,{Size=UDim2.new(1,0,0,42)}) end)
        if cb then pcall(cb) end
    end)
    if tipTxt then tip(b,tipTxt) end; return b
end

local function note(tab,txt)
    mk("TextLabel",{Text="  ↳  "..txt,Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,
        TextColor3=T.dim,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},tabScrolls[tab])
end

local function playerPopup(title,onPick)
    local plrs=Players:GetPlayers()
    local ph=60+math.max(0,#plrs-1)*40
    local pop=mk("Frame",{Size=UDim2.new(0,270,0,ph),AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new(.5,0,.6,0),BackgroundColor3=T.panel,BorderSizePixel=0,ZIndex=100,BackgroundTransparency=1},gui)
    rnd(pop,14); mk("UIStroke",{Color=T.accent,Thickness=2,ZIndex=101},pop)
    tw(pop,.22,{BackgroundTransparency=0,Position=UDim2.new(.5,0,.5,0)},Enum.EasingStyle.Back)
    mk("TextLabel",{Text=title,Size=UDim2.new(1,0,0,46),BackgroundTransparency=1,
        TextColor3=T.white,TextSize=15,Font=Enum.Font.GothamBold,ZIndex=101},pop)
    local cl=mk("TextButton",{Text="✕",Size=UDim2.new(0,28,0,28),AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-8,0,8),BackgroundTransparency=1,
        TextColor3=T.red,TextSize=16,Font=Enum.Font.GothamBold,BorderSizePixel=0,ZIndex=102},pop)
    cl.MouseButton1Click:Connect(function()
        tw(pop,.14,{BackgroundTransparency=1}); task.delay(.15,function() pop:Destroy() end)
    end)
    mk("UIListLayout",{Padding=UDim.new(0,3)},pop); pad(pop,8,8,46,8)
    for _,p in ipairs(plrs) do
        if p~=lp then
            local pb=mk("TextButton",{Size=UDim2.new(1,0,0,36),BackgroundColor3=T.accGlow,
                TextColor3=T.txt,Text="  "..p.Name,TextSize=13,Font=Enum.Font.GothamBold,
                BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102},pop)
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
-- FEATURE LOGIC
-- ============================================================

-- FLY
local flyBV,flyBG
local function startFly()
    local hrp=getHRP(); if not hrp then return end
    local hum=getHum()
    if hum and not CFG.antiDetect then pcall(function() hum.PlatformStand=true end) end
    if flyBV then pcall(function() flyBV:Destroy() end) end
    if flyBG then pcall(function() flyBG:Destroy() end) end
    flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e9,1e9,1e9); flyBV.Velocity=Vector3.zero; flyBV.Parent=hrp
    flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1e9,1e9,1e9); flyBG.P=9000; flyBG.D=200; flyBG.Parent=hrp
    pcall(function() RunService:UnbindFromRenderStep("GF_Fly") end)
    RunService:BindToRenderStep("GF_Fly",Enum.RenderPriority.Camera.Value+1,function()
        if not CFG.fly then return end
        local h=getHRP(); if not h then return end
        local d=Vector3.zero; local u=UserInputService
        if u:IsKeyDown(Enum.KeyCode.W) then d=d+cam.CFrame.LookVector end
        if u:IsKeyDown(Enum.KeyCode.S) then d=d-cam.CFrame.LookVector end
        if u:IsKeyDown(Enum.KeyCode.A) then d=d-cam.CFrame.RightVector end
        if u:IsKeyDown(Enum.KeyCode.D) then d=d+cam.CFrame.RightVector end
        if u:IsKeyDown(Enum.KeyCode.Space)     then d=d+Vector3.new(0,1,0) end
        if u:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end
        if flyBV and flyBV.Parent then flyBV.Velocity=d.Magnitude>0 and d.Unit*CFG.flySpeed or Vector3.zero end
        if flyBG and flyBG.Parent then flyBG.CFrame=cam.CFrame end
    end)
end
local function stopFly()
    pcall(function() RunService:UnbindFromRenderStep("GF_Fly") end)
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV=nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG=nil end
    pcall(function() local h=getHum(); if h then h.PlatformStand=false end end)
end

-- NOCLIP
local ncConn
local function startNoclip()
    if ncConn then ncConn:Disconnect() end
    ncConn=RunService.Stepped:Connect(function()
        if not CFG.noclip then return end
        local c=getChar(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then pcall(function() p.CanCollide=false end) end
        end
    end)
end
local function stopNoclip()
    if ncConn then ncConn:Disconnect(); ncConn=nil end
    local c=getChar(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then pcall(function() p.CanCollide=true end) end
    end
end

-- HIGH JUMP
local function applyHighJump(on)
    local h=getHum(); if not h then return end
    pcall(function() h.UseJumpPower=true; h.JumpPower=on and CFG.jumpPower or 50 end)
end
RunService.Heartbeat:Connect(function()
    if not CFG.highJump then return end
    local h=getHum(); if not h then return end
    pcall(function()
        h.UseJumpPower=true
        if math.abs(h.JumpPower-CFG.jumpPower)>0.5 then h.JumpPower=CFG.jumpPower end
    end)
end)

-- SPINBOT
pcall(function() RunService:UnbindFromRenderStep("GF_Spin") end)
RunService:BindToRenderStep("GF_Spin",Enum.RenderPriority.Character.Value,function()
    if not CFG.spinBot then return end
    local h=getHRP(); if h then pcall(function() h.CFrame=h.CFrame*CFrame.Angles(0,math.rad(CFG.spinSpeed),0) end) end
end)

-- BHOP
local bhopConn
local function startBhop()
    if bhopConn then bhopConn:Disconnect() end
    local h=getHum(); if not h then return end
    bhopConn=h.StateChanged:Connect(function(_,new)
        if not CFG.bunnyHop then return end
        if new==Enum.HumanoidStateType.Landed then
            task.wait()
            local h2=getHum()
            if h2 then pcall(function() h2:ChangeState(Enum.HumanoidStateType.Jumping) end) end
        end
    end)
end
local function stopBhop() if bhopConn then bhopConn:Disconnect(); bhopConn=nil end end

-- AUTO JUMP / ANTI AFK / INF JUMP
local lastAfk=tick()
RunService.Heartbeat:Connect(function()
    if CFG.autoJump then
        local h=getHum()
        if h and h.FloorMaterial~=Enum.Material.Air then pcall(function() h.Jump=true end) end
    end
    if CFG.antiAfk and tick()-lastAfk>360 then
        lastAfk=tick(); local h=getHum(); if h then pcall(function() h.Jump=true end) end
    end
    if CFG.infinite_jump then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local h=getHum()
            if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
        end
    end
end)

-- ANTI LAG  (optimized — no workspace iteration every frame)
local function applyAntiLag(on)
    pcall(function() settings().Rendering.QualityLevel=on and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end)
    pcall(function() Lighting.GlobalShadows=not on end)
    if on then
        -- one-time pass to disable particles — no repeated iteration
        task.spawn(function()
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") then
                    pcall(function() v.Enabled=false end)
                end
            end
        end)
    end
end

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
        for _,acc in ipairs(c:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle=acc:FindFirstChild("Handle"); if not handle then continue end
                local att=handle:FindFirstChildOfClass("Attachment")
                if att and (att.Name:find("Hat") or att.Name:find("Hair") or att.Name:find("Face")) then
                    hlessBkp[handle]=handle.Transparency; pcall(function() handle.Transparency=1 end)
                    for _,dec in ipairs(handle:GetDescendants()) do
                        if dec:IsA("Decal") then hlessBkp[dec]=dec.Transparency; pcall(function() dec.Transparency=1 end) end
                    end
                end
            end
        end
    else
        pcall(function() head.Transparency=0 end)
        for obj,val in pairs(hlessBkp) do
            pcall(function()
                if obj:IsA("Decal") then obj.Transparency=val
                elseif obj:IsA("SpecialMesh") then obj.Scale=val
                elseif obj:IsA("BasePart") then obj.Transparency=val end
            end)
        end; hlessBkp={}
    end
end

-- INVISIBLE
local function applyInvis(on)
    local c=getChar(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
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
        pcall(function() RunService:UnbindFromRenderStep("GF_FreezeT") end)
        RunService:BindToRenderStep("GF_FreezeT",1,function()
            if not CFG.freezeTime then return end
            pcall(function() Lighting.ClockTime=CFG.frozenTime end)
            local a=Lighting:FindFirstChildOfClass("Atmosphere")
            if a and next(frozenAtm) then for k,v in pairs(frozenAtm) do pcall(function() a[k]=v end) end end
        end)
    else
        pcall(function() RunService:UnbindFromRenderStep("GF_FreezeT") end); frozenAtm={}
    end
end

-- ============================================================
-- AIMBOT  — hold key/mouse to aim, smooth = higher → slower
-- ============================================================
local fovCircle=mk("Frame",{Size=UDim2.new(0,240,0,240),AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,BorderSizePixel=0,Visible=false,ZIndex=50},gui)
rnd(fovCircle,120)
local fovStroke=mk("UIStroke",{Color=T.accent,Thickness=1.5,Transparency=.35},fovCircle)
rTC(function() fovStroke.Color=T.accent end)

local aimbotKeyHeld=false
local aimbotMouseHeld=false

-- Line of sight check
local function hasLineOfSight(targetPos)
    local hrp=getHRP(); if not hrp then return false end
    local origin=hrp.Position
    local direction=(targetPos-origin)
    local rayParams=RaycastParams.new()
    rayParams.FilterType=Enum.RaycastFilterType.Exclude
    local exclude={getChar()}
    for _,p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(exclude,p.Character) end end
    rayParams.FilterDescendantsInstances=exclude
    local result=workspace:Raycast(origin,direction,rayParams)
    if not result then return true end
    local hit=result.Instance
    if hit and hit:IsA("BasePart") then
        if hit.Transparency>=0.7 then return true end
        if hit.Material==Enum.Material.Glass or hit.Material==Enum.Material.ForceField then return true end
    end
    return false
end

local function getAimbotTarget()
    local center=cam.ViewportSize/2; local best,bestDist=nil,CFG.aimbotFOV
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            if CFG.aimbotTeamCheck and plr.Team==lp.Team then continue end
            local hum=plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health>0 then
                local bone=plr.Character:FindFirstChild(CFG.aimbotBone) or plr.Character:FindFirstChild("Head")
                if bone then
                    local pos,vis=cam:WorldToViewportPoint(bone.Position)
                    if vis then
                        local d=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                        if d<bestDist then
                            if CFG.aimbotVisCheck then
                                if hasLineOfSight(bone.Position) then bestDist=d; best=bone end
                            else bestDist=d; best=bone end
                        end
                    end
                end
            end
        end
    end
    return best
end

pcall(function() RunService:UnbindFromRenderStep("GF_Aimbot") end)
RunService:BindToRenderStep("GF_Aimbot",Enum.RenderPriority.Camera.Value,function()
    fovCircle.Visible=CFG.aimbot
    if not CFG.aimbot then return end
    local r=CFG.aimbotFOV
    fovCircle.Size=UDim2.new(0,r*2,0,r*2)
    local rc=fovCircle:FindFirstChildOfClass("UICorner"); if rc then rc.CornerRadius=UDim.new(0,r) end
    local held = aimbotKeyHeld or aimbotMouseHeld
    if not held then return end
    local target=getAimbotTarget(); if not target then return end
    -- Smooth: higher value = SLOWER (divide: low smooth = fast lerp, high smooth = slow lerp)
    local lerpFactor = math.clamp(1 / CFG.aimbotSmooth, 0.01, 1.0)
    pcall(function() cam.CFrame=cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position,target.Position),lerpFactor) end)
end)

-- ============================================================
-- TRIGGERBOT  — fires when crosshair over enemy, only if key/LMB held
-- ============================================================
local triggerbotActive = false
local triggerbotMouseHeld = false
local triggerbotKeyHeld = false
local lastTriggerShot = 0

RunService.Heartbeat:Connect(function()
    if not CFG.triggerbot then return end
    local held = triggerbotMouseHeld or triggerbotKeyHeld
    if not held then return end
    local now = tick()
    if now - lastTriggerShot < CFG.triggerbotDelay then return end
    -- Check if cursor is over an enemy
    local center = cam.ViewportSize / 2
    local unitRay = cam:ScreenPointToRay(center.X, center.Y)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local excl = {getChar()}
    rayParams.FilterDescendantsInstances = excl
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, rayParams)
    if result and result.Instance then
        local hit = result.Instance
        -- Check if hit part belongs to an enemy player
        local hitChar = hit:FindFirstAncestorOfClass("Model")
        if hitChar then
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character == hitChar then
                    if CFG.aimbotTeamCheck and plr.Team == lp.Team then break end
                    local hum = hitChar:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        -- Simulate click
                        lastTriggerShot = now
                        local vms = Instance.new("VirtualInputManager") pcall(function()
                            -- fallback: fire tool
                            local c=getChar()
                            if c then
                                local tool=c:FindFirstChildOfClass("Tool")
                                if tool then
                                    local remote=tool:FindFirstChild("RemoteEvent") or tool:FindFirstChildOfClass("RemoteEvent")
                                    if remote then pcall(function() remote:FireServer() end) end
                                end
                            end
                        end)
                        break
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- ESP  — optimized: billboard reused, boxes drawn each frame only
-- ============================================================
local espData={}
-- Use ONE persistent drawing layer — clear only drawing frames, not billboard data
local espFr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=10},gui)
local skelFr=mk("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=11},gui)

local function getECol() return Color3.fromHSV(CFG.espColorH,CFG.espColorS,CFG.espColorV) end
local function cleanESP()
    for _,d in pairs(espData) do
        if d.bb then pcall(function() d.bb:Destroy() end) end
        if d.hl then pcall(function() d.hl:Destroy() end) end
    end; espData={}
end

local BONES={"Head","UpperTorso","LowerTorso","HumanoidRootPart",
    "LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm",
    "LeftHand","RightHand","LeftUpperLeg","RightUpperLeg",
    "LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"}
local SKEL_P={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}

local function drawCBox(p,x,y,w,h,col)
    local t=CFG.espLineThick; local cl=math.max(5,math.min(w,h)*.22)
    local function ln(lx,ly,lw,lh)
        mk("Frame",{Size=UDim2.new(0,lw,0,lh),Position=UDim2.new(0,lx,0,ly),BackgroundColor3=col,BorderSizePixel=0,ZIndex=15},p)
    end
    ln(x,y,cl,t); ln(x,y,t,cl); ln(x+w-cl,y,cl,t); ln(x+w-t,y,t,cl)
    ln(x,y+h-t,cl,t); ln(x,y+h-cl,t,cl); ln(x+w-cl,y+h-t,cl,t); ln(x+w-t,y+h-cl,t,cl)
end
local function drawFBox(p,x,y,w,h,col)
    local t=CFG.espLineThick
    local function ln(lx,ly,lw,lh) mk("Frame",{Size=UDim2.new(0,lw,0,lh),Position=UDim2.new(0,lx,0,ly),BackgroundColor3=col,BorderSizePixel=0,ZIndex=15},p) end
    ln(x,y,w,t); ln(x,y+h-t,w,t); ln(x,y,t,h); ln(x+w-t,y,t,h)
end
local function drawLine(p,a,b,col,thick)
    local dx,dy=b.X-a.X,b.Y-a.Y; local len=math.sqrt(dx*dx+dy*dy); if len<2 then return end
    mk("Frame",{Size=UDim2.new(0,len,0,thick or 1),Position=UDim2.new(0,a.X,0,a.Y),
        AnchorPoint=Vector2.new(0,.5),Rotation=math.deg(math.atan2(dy,dx)),
        BackgroundColor3=col,BorderSizePixel=0,ZIndex=13},p)
end

-- Throttle ESP drawing to every other frame to reduce lag
local espFrameSkip = 0
pcall(function() RunService:UnbindFromRenderStep("GF_ESP") end)
RunService:BindToRenderStep("GF_ESP",Enum.RenderPriority.Camera.Value-1,function()
    espFrameSkip = espFrameSkip + 1
    if espFrameSkip % 2 ~= 0 then return end -- skip every other frame = 2x less work
    espFr:ClearAllChildren(); skelFr:ClearAllChildren()
    if not CFG.esp then cleanESP(); return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp and plr.Character then
            local hrp=plr.Character:FindFirstChild("HumanoidRootPart")
            local hum=plr.Character:FindFirstChildOfClass("Humanoid")
            if not(hrp and hum) then continue end
            local myHRP=getHRP()
            local dist=myHRP and math.floor((hrp.Position-myHRP.Position).Magnitude) or 999
            if dist>CFG.espMaxDist then
                if espData[plr] and espData[plr].bb then pcall(function() espData[plr].bb.Enabled=false end) end; continue
            end
            local ecol=getECol()
            local hp=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
            if not espData[plr] then espData[plr]={} end
            local d=espData[plr]
            if not d.bb or not d.bb.Parent then
                local bb=Instance.new("BillboardGui"); bb.AlwaysOnTop=true
                bb.Size=UDim2.new(0,165,0,55); bb.StudsOffset=Vector3.new(0,3.6,0); bb.LightInfluence=0
                pcall(function() bb.Parent=hrp end); d.bb=bb
                d.nl=mk("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,
                    TextSize=13,Font=Enum.Font.GothamBold,TextStrokeTransparency=0,TextStrokeColor3=Color3.fromRGB(0,0,0)},bb)
                local hbg=mk("Frame",{Size=UDim2.new(1,0,0,5),Position=UDim2.new(0,0,0,22),BackgroundColor3=Color3.fromRGB(26,4,4),BorderSizePixel=0},bb); rnd(hbg,3)
                d.hpF=mk("Frame",{BackgroundColor3=T.green,BorderSizePixel=0},hbg); rnd(d.hpF,3)
                d.dl=mk("TextLabel",{Size=UDim2.new(1,0,0,13),Position=UDim2.new(0,0,0,30),BackgroundTransparency=1,TextSize=10,Font=Enum.Font.Gotham,TextStrokeTransparency=0,TextColor3=T.dim},bb)
            end
            pcall(function() d.bb.Enabled=true end)
            if d.nl then pcall(function() d.nl.Visible=CFG.espNames; d.nl.Text=plr.Name; d.nl.TextColor3=ecol end) end
            if d.hpF then pcall(function()
                d.hpF.Parent.Visible=CFG.espHealth; d.hpF.Size=UDim2.new(hp,0,1,0)
                d.hpF.BackgroundColor3=Color3.fromRGB(math.floor(255*(1-hp)),math.floor(210*hp),55)
            end) end
            if d.dl then pcall(function() d.dl.Visible=CFG.espDist; d.dl.Text=dist.."m" end) end

            local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
            local bonePos={}; local anyVis=false
            for _,pn in ipairs(BONES) do
                local pt=plr.Character:FindFirstChild(pn)
                if pt then
                    local sz=pt.Size/2
                    local corners={
                        Vector3.new(sz.X,sz.Y,sz.Z),Vector3.new(-sz.X,sz.Y,sz.Z),
                        Vector3.new(sz.X,-sz.Y,sz.Z),Vector3.new(-sz.X,-sz.Y,sz.Z),
                        Vector3.new(sz.X,sz.Y,-sz.Z),Vector3.new(-sz.X,sz.Y,-sz.Z),
                        Vector3.new(sz.X,-sz.Y,-sz.Z),Vector3.new(-sz.X,-sz.Y,-sz.Z),
                    }
                    for _,off in ipairs(corners) do
                        local sp,vis=cam:WorldToViewportPoint(pt.CFrame*off)
                        if vis then
                            anyVis=true
                            if sp.X<minX then minX=sp.X end; if sp.Y<minY then minY=sp.Y end
                            if sp.X>maxX then maxX=sp.X end; if sp.Y>maxY then maxY=sp.Y end
                        end
                    end
                    local csp,cvis=cam:WorldToViewportPoint(pt.Position)
                    if cvis then bonePos[pn]=Vector2.new(csp.X,csp.Y) end
                end
            end
            if anyVis then
                local px,py=minX-4,minY-4; local pw,ph2=(maxX-minX)+8,(maxY-minY)+8
                if CFG.espCorner  then drawCBox(espFr,px,py,pw,ph2,ecol) end
                if CFG.espBoxFull then drawFBox(espFr,px,py,pw,ph2,ecol) end
                if CFG.espSkeleton then
                    for _,pair in ipairs(SKEL_P) do
                        local a=bonePos[pair[1]]; local b2=bonePos[pair[2]]
                        if a and b2 then drawLine(skelFr,a,b2,ecol,CFG.espLineThick) end
                    end
                end
                if CFG.espHeadDot then
                    local hp2=bonePos["Head"]
                    if hp2 then
                        local dot=mk("Frame",{Size=UDim2.new(0,8,0,8),AnchorPoint=Vector2.new(.5,.5),
                            Position=UDim2.new(0,hp2.X,0,hp2.Y),BackgroundColor3=ecol,BorderSizePixel=0,ZIndex=16},espFr); rnd(dot,4)
                    end
                end
                if CFG.espTracer then
                    local m=getHRP()
                    if m then
                        local mp,mv=cam:WorldToViewportPoint(m.Position)
                        local ep=bonePos["HumanoidRootPart"] or bonePos["UpperTorso"]
                        if mv and ep then drawLine(espFr,Vector2.new(mp.X,mp.Y),ep,ecol,CFG.espLineThick) end
                    end
                end
            end
            if CFG.espChams then
                if not d.hl or not d.hl.Parent then
                    local hl=Instance.new("Highlight"); hl.Adornee=plr.Character
                    hl.FillTransparency=.80; hl.OutlineTransparency=0
                    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    pcall(function() hl.Parent=plr.Character end); d.hl=hl
                end
                pcall(function() d.hl.FillColor=ecol; d.hl.OutlineColor=ecol end)
            else
                if d.hl then pcall(function() d.hl:Destroy() end); d.hl=nil end
            end
        end
    end
    for plr,d in pairs(espData) do
        if not Players:FindFirstChild(plr.Name) then
            if d.bb then pcall(function() d.bb:Destroy() end) end
            if d.hl then pcall(function() d.hl:Destroy() end) end
            espData[plr]=nil
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
    local function dot(sz)
        local f=mk("Frame",{Size=UDim2.new(0,sz,0,sz),AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.new(.5,0,.5,0),BackgroundColor3=col,BorderSizePixel=0,ZIndex=52},xhF); rnd(f,sz/2)
    end
    local g=math.floor(s*.22)
    if st==1 then ln(s/2-g,2,-(s/4+g/2+1),0);ln(s/2-g,2,s/4+g/2+1,0);ln(2,s/2-g,0,-(s/4+g/2+1));ln(2,s/2-g,0,s/4+g/2+1)
    elseif st==2 then dot(7)
    elseif st==3 then
        local r=mk("Frame",{Size=UDim2.new(0,s,0,s),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=51},xhF)
        mk("UIStroke",{Color=Color3.fromRGB(0,0,0),Thickness=3.5,Transparency=.5},r); rnd(r,s)
        local r2=mk("Frame",{Size=UDim2.new(0,s,0,s),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.5,0),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=52},xhF)
        mk("UIStroke",{Color=col,Thickness=2},r2); rnd(r2,s)
    elseif st==4 then ln(s,2,0,0);ln(2,s/2,0,s/4)
    elseif st==5 then ln(s,2,0,0,45);ln(s,2,0,0,-45)
    elseif st==6 then ln(s/2-g,2,-(s/4+g/2+1),0);ln(s/2-g,2,s/4+g/2+1,0);ln(2,s/2-g,0,-(s/4+g/2+1));ln(2,s/2-g,0,s/4+g/2+1);dot(5)
    elseif st==7 then local h2=s/2; ln(s+4,2,0,-h2);ln(s+4,2,0,h2);ln(2,s,-h2+1,0);ln(2,s,h2-1,0)
    elseif st==8 then ln(s*.65,2,-s*.16,s*.2,45);ln(s*.65,2,s*.16,s*.2,-45) end
end
buildCH()

-- ============================================================
-- HUD
-- ============================================================
local hud=mk("Frame",{Size=UDim2.new(0,260,0,54),Position=UDim2.new(0,10,1,-64),
    BackgroundColor3=T.panel,BackgroundTransparency=.15,BorderSizePixel=0,Visible=false},gui)
rnd(hud,10); mk("UIStroke",{Color=T.border,Thickness=1},hud); pad(hud,12,12,5,5)
local hc=mk("TextLabel",{Text="",Size=UDim2.new(1,0,.5,0),BackgroundTransparency=1,
    TextColor3=T.txt,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},hud)
local hf=mk("TextLabel",{Text="",Size=UDim2.new(1,0,.5,0),Position=UDim2.new(0,0,.5,0),
    BackgroundTransparency=1,TextColor3=T.accent2,TextSize=12,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left},hud)
rTC(function() hf.TextColor3=T.accent2 end)
RunService.RenderStepped:Connect(function(dt)
    hud.Visible=CFG.showCoords or CFG.showFPS
    if CFG.showCoords then
        local h=getHRP()
        if h then local p=h.Position; hc.Text=("X:%.0f  Y:%.0f  Z:%.0f"):format(p.X,p.Y,p.Z) end
    else hc.Text="" end
    if CFG.showFPS then hf.Text="FPS:  "..math.floor(1/math.max(dt,.001)) else hf.Text="" end
end)

-- ============================================================
-- POSITION MARKER
-- ============================================================
local lastPos=nil; local markerPart=nil
local function spawnMarker(cf)
    if markerPart then for _,p in ipairs(markerPart) do pcall(function() p:Destroy() end) end; markerPart=nil end
    local p=Instance.new("Part"); p.Name="GF_Marker"; p.Anchored=true; p.CanCollide=false
    p.Size=Vector3.new(0.5,3,0.5); p.Material=Enum.Material.Neon
    p.BrickColor=BrickColor.new("Institutional white"); p.Parent=workspace
    local wedge=Instance.new("WedgePart"); wedge.Name="GF_MarkerHead"; wedge.Anchored=true; wedge.CanCollide=false
    wedge.Size=Vector3.new(0.5,1,0.5); wedge.Material=Enum.Material.Neon
    wedge.BrickColor=BrickColor.new("Institutional white"); wedge.Parent=workspace
    task.spawn(function()
        local angle=0
        while p and p.Parent and wedge and wedge.Parent do
            angle=angle+2
            local base=CFrame.new(cf.Position)
            p.CFrame=base*CFrame.Angles(0,math.rad(angle),0)*CFrame.new(0,5,0)
            wedge.CFrame=base*CFrame.Angles(0,math.rad(angle),0)*CFrame.new(0,8.5,0)
            task.wait()
        end
    end)
    markerPart={p,wedge}
end
local function removeMarker()
    if markerPart then for _,p in ipairs(markerPart) do pcall(function() p:Destroy() end) end; markerPart=nil end
end

-- ============================================================
-- TAB CONTENT
-- ============================================================

---- MOVE ----
sec("Move","Flying")
tog("Move","Fly  —  WASD + Space / Shift","fly","Fly freely. Space=up, Shift=down.",function(on) if on then startFly() else stopFly() end end)
sld("Move","Fly Speed",10,600,CFG.flySpeed,5,"Flight speed (studs/s)",function(v) CFG.flySpeed=v end)
tog("Move","Noclip  —  through walls","noclip","Phase through all parts",function(on) if on then startNoclip() else stopNoclip() end end)
tog("Move","Speed Boost","speed","Increase walk speed",function(on) local h=getHum();if h then pcall(function() h.WalkSpeed=on and 16*CFG.speedMult or 16 end) end end)
sld("Move","Speed Multiplier",1,25,CFG.speedMult,.5,"WalkSpeed factor",function(v) CFG.speedMult=v; if CFG.speed then local h=getHum();if h then pcall(function() h.WalkSpeed=16*v end) end end end)
sec("Move","Jumping")
tog("Move","High Jump","highJump","Jump much higher",function(on) applyHighJump(on) end)
sld("Move","Jump Power",50,600,CFG.jumpPower,10,"50=Normal  300=High  600=Max",function(v) CFG.jumpPower=v; if CFG.highJump then local h=getHum();if h then pcall(function() h.UseJumpPower=true;h.JumpPower=v end) end end end)
note("Move","50=Normal  150=2x  300=High  600=Extreme")
tog("Move","Infinite Jump","infinite_jump","Hold Space to keep jumping",nil)
tog("Move","Bunny Hop","bunnyHop","Auto-jump on landing",function(on) if on then startBhop() else stopBhop() end end)
tog("Move","Auto Jump","autoJump","Constantly jump while on ground",nil)
sec("Move","Misc")
tog("Move","Spinbot","spinBot","Spin character constantly",nil)
sld("Move","Spin Speed",1,40,CFG.spinSpeed,1,"Degrees per frame",function(v) CFG.spinSpeed=v end)
tog("Move","Anti-AFK","antiAfk","Jumps every 6 min to avoid kick",nil)
tog("Move","Anti-Lag","antiLag","Lower graphics to boost FPS",function(on) applyAntiLag(on) end)
sec("Move","Teleport")
btn("Move","TP to Nearest Player","Teleport next to closest player",function()
    local hrp=getHRP();if not hrp then return end; local best,bd=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local h2=p.Character:FindFirstChild("HumanoidRootPart")
            if h2 then local d=(h2.Position-hrp.Position).Magnitude;if d<bd then bd=d;best=h2 end end
        end
    end
    if best then pcall(function() hrp.CFrame=best.CFrame+Vector3.new(3,0,3) end) end
end)
btn("Move","TP to Player  —  pick","Choose which player to teleport to",function()
    playerPopup("Teleport to player",function(p)
        local hrp=getHRP(); if not hrp then return end
        local h2=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if h2 then pcall(function() hrp.CFrame=h2.CFrame*CFrame.new(3,0,3) end) end
    end)
end)
btn("Move","TP to Spawn","Teleport to SpawnLocation",function()
    local hrp=getHRP();if not hrp then return end
    local sp=workspace:FindFirstChildOfClass("SpawnLocation")
    if sp then pcall(function() hrp.CFrame=sp.CFrame+Vector3.new(0,5,0) end) end
end)
btn("Move","Yeet  —  launch up","Catapult yourself upward",function()
    local hrp=getHRP();if not hrp then return end
    local bv=Instance.new("BodyVelocity");bv.MaxForce=Vector3.new(1e9,1e9,1e9);bv.Velocity=Vector3.new(0,900,0);bv.Parent=hrp;Debris:AddItem(bv,.15)
end)
btn("Move","Rejoin","Rejoin the same server",function()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,lp) end)
end)

---- COMBAT ----
sec("Combat","Aimbot Key Binding")
do
    local aKeyDisp=mk("TextLabel",{
        Text="Aim Key:  [ "..tostring(CFG.aimbotKey):match("%.(%a+)$").." ]",
        Size=UDim2.new(1,0,0,38),BackgroundColor3=T.accDark,TextColor3=T.accent,
        TextSize=14,Font=Enum.Font.GothamBold,BorderSizePixel=0,
        TextXAlignment=Enum.TextXAlignment.Center},tabScrolls["Combat"])
    rnd(aKeyDisp,11); mk("UIStroke",{Color=T.border,Thickness=1.2},aKeyDisp)
    rTC(function() aKeyDisp.BackgroundColor3=T.accDark; aKeyDisp.TextColor3=T.accent end)
    btn("Combat","Bind Aimbot Key  (keyboard or mouse)","Press any key OR mouse button to bind",function()
        aKeyDisp.Text="Press key or click mouse button..."; aKeyDisp.TextColor3=T.txt
        local conn; conn=UserInputService.InputBegan:Connect(function(inp)
            local name = ""
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                CFG.aimbotKey=inp.KeyCode; CFG.aimbotMouseBtn=nil
                name=tostring(inp.KeyCode):match("%.(%a+)$") or "?"
            elseif inp.UserInputType==Enum.UserInputType.MouseButton1 then
                CFG.aimbotMouseBtn=Enum.UserInputType.MouseButton1; CFG.aimbotKey=Enum.KeyCode.Unknown
                name="Mouse1 (LMB)"
            elseif inp.UserInputType==Enum.UserInputType.MouseButton2 then
                CFG.aimbotMouseBtn=Enum.UserInputType.MouseButton2; CFG.aimbotKey=Enum.KeyCode.Unknown
                name="Mouse2 (RMB)"
            elseif inp.UserInputType==Enum.UserInputType.MouseButton3 then
                CFG.aimbotMouseBtn=Enum.UserInputType.MouseButton3; CFG.aimbotKey=Enum.KeyCode.Unknown
                name="Mouse3 (MMB)"
            else return end
            aKeyDisp.Text="Aim Key:  [ "..name.." ]"; aKeyDisp.TextColor3=T.accent
            conn:Disconnect(); saveConfig()
        end)
    end)
    note("Combat","Hold the bound key/button to aim — release to stop")
    note("Combat","Smooth: LOW = fast snap  |  HIGH = slow smooth")
end
sec("Combat","Aimbot Settings")
tog("Combat","Aimbot  (enable)","aimbot","Enable aimbot — hold Aim Key to aim",nil)
tog("Combat","Team Check","aimbotTeamCheck","Skip teammates",nil)
tog("Combat","Visual Check  (no wall target)","aimbotVisCheck","Only aim at targets not behind walls/glass",nil)
sld("Combat","FOV Radius",20,500,CFG.aimbotFOV,5,"Aim search radius in pixels",function(v)
    CFG.aimbotFOV=v
    fovCircle.Size=UDim2.new(0,v*2,0,v*2)
    local rc=fovCircle:FindFirstChildOfClass("UICorner"); if rc then rc.CornerRadius=UDim.new(0,v) end
end)
sld("Combat","Smooth  (1=snap  100=slow)",1,100,CFG.aimbotSmooth,1,"1=instant snap  100=very slow smooth",function(v) CFG.aimbotSmooth=v end)
sec("Combat","Aim Bone")
btn("Combat","Head","Aim at head",function() CFG.aimbotBone="Head"; notify("Aimbot","Target: Head",2) end)
btn("Combat","UpperTorso","Aim at torso",function() CFG.aimbotBone="UpperTorso"; notify("Aimbot","Target: Torso",2) end)
btn("Combat","HumanoidRootPart","Aim at body center",function() CFG.aimbotBone="HumanoidRootPart"; notify("Aimbot","Target: Root",2) end)
sec("Combat","Triggerbot")
do
    local tbKeyDisp=mk("TextLabel",{
        Text="Triggerbot Key:  [ LMB (Mouse1) ]",
        Size=UDim2.new(1,0,0,38),BackgroundColor3=T.accDark,TextColor3=T.accent,
        TextSize=13,Font=Enum.Font.GothamBold,BorderSizePixel=0,
        TextXAlignment=Enum.TextXAlignment.Center},tabScrolls["Combat"])
    rnd(tbKeyDisp,11); mk("UIStroke",{Color=T.border,Thickness=1.2},tbKeyDisp)
    rTC(function() tbKeyDisp.BackgroundColor3=T.accDark; tbKeyDisp.TextColor3=T.accent end)
    btn("Combat","Bind Triggerbot Key","Press key or click mouse button to bind triggerbot",function()
        tbKeyDisp.Text="Press key or click mouse..."; tbKeyDisp.TextColor3=T.txt
        local conn; conn=UserInputService.InputBegan:Connect(function(inp)
            local name=""
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                CFG.triggerbotKey=inp.KeyCode; CFG.triggerbotMouse=nil
                name=tostring(inp.KeyCode):match("%.(%a+)$") or "?"
            elseif inp.UserInputType==Enum.UserInputType.MouseButton1 then
                CFG.triggerbotMouse=Enum.UserInputType.MouseButton1; CFG.triggerbotKey=Enum.KeyCode.Unknown
                name="LMB (Mouse1)"
            elseif inp.UserInputType==Enum.UserInputType.MouseButton2 then
                CFG.triggerbotMouse=Enum.UserInputType.MouseButton2; CFG.triggerbotKey=Enum.KeyCode.Unknown
                name="RMB (Mouse2)"
            else return end
            tbKeyDisp.Text="Triggerbot Key:  [ "..name.." ]"; tbKeyDisp.TextColor3=T.accent
            conn:Disconnect()
        end)
    end)
end
tog("Combat","Triggerbot  (enable)","triggerbot","Auto-fire when crosshair is on enemy — hold trigger key",nil)
note("Combat","Only fires if enemy is visible within crosshair")
sld("Combat","Triggerbot Delay (s)",0,1,CFG.triggerbotDelay,.01,"Delay between shots in seconds",function(v) CFG.triggerbotDelay=v end)
sec("Combat","Protection")
tog("Combat","Anti-Kick","antiKick","Block server-side kicks",function(on) applyAntiKick(on) end)
tog("Combat","Anti-Detect","antiDetect","No PlatformStand — harder to detect",nil)

---- VISUAL ----
sec("Visual","Render")
tog("Visual","Fullbright","fullbright","Make everything fully bright",function(on) applyFullbright(on) end)
tog("Visual","No Fog","noFog","Remove all fog",function(on) pcall(function() Lighting.FogEnd=on and 1e6 or CFG._origFogEnd end) end)
sec("Visual","Crosshair")
tog("Visual","Crosshair","crosshair","Show custom crosshair",function(on) xhF.Visible=on end)
note("Visual","8 styles — click to apply:")
for _,s in ipairs({
    {"+ Cross (Gap)",1},{"● Dot",2},{"○ Circle",3},{"T T-Shape",4},
    {"X Diagonal",5},{"⊕ Cross+Dot",6},{"□ Box",7},{"∧ Chevron",8}
}) do
    btn("Visual",s[1],s[1],function() CFG.crosshairStyle=s[2]; buildCH() end)
end
sld("Visual","Color Hue  (0=White)",0,100,math.floor(CFG.crosshairColorH*100),1,"Color hue",function(v) CFG.crosshairColorH=v/100; buildCH() end)
sld("Visual","Size",8,70,CFG.crosshairSize,2,"Crosshair size",function(v) CFG.crosshairSize=v; buildCH() end)

---- WORLD ----
sec("World","Time & Weather")
tog("World","Freeze Time","freezeTime","Lock sun position + atmosphere",function(on) applyFreezeTime(on) end)
sld("World","Clock  (0-24)",0,24,CFG.frozenTime,.5,"Time of day",function(v) pcall(function() Lighting.ClockTime=v end); CFG.frozenTime=v end)
sld("World","Brightness",0,10,2,.1,"Ambient brightness",function(v) pcall(function() Lighting.Brightness=v end) end)
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
tog("Player","Invisible","invisible","Make your character transparent",function(on) applyInvis(on) end)
tog("Player","Headless","headless","Hide your head",function(on) applyHeadless(on) end)
btn("Player","Rainbow  (10s)","Cycle through rainbow colors",function()
    task.spawn(function()
        for t=0,200 do
            local c=getChar(); if not c then break end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                    pcall(function() p.BrickColor=BrickColor.new(Color3.fromHSV((t*.04)%1,1,1)) end)
                end
            end; task.wait(.05)
        end
    end)
end)
sec("Player","Actions")
btn("Player","Platform  (5s)","Spawn a 10x10 platform for 5 seconds",function()
    local hrp=getHRP();if not hrp then return end
    local p=Instance.new("Part"); p.Size=Vector3.new(10,1,10); p.Anchored=true
    p.Material=Enum.Material.Neon; p.BrickColor=BrickColor.new("Institutional white")
    pcall(function() p.CFrame=hrp.CFrame*CFrame.new(0,-3.5,0) end); p.Parent=workspace; Debris:AddItem(p,5)
    notify("GLUHFIX","Platform spawned — 5s",3)
end)
btn("Player","Reset  (Respawn)","Kill yourself to respawn",function() local h=getHum();if h then pcall(function() h.Health=0 end) end end)
btn("Player","Yeet  —  launch up","Launch yourself into the air",function()
    local hrp=getHRP();if not hrp then return end
    local bv=Instance.new("BodyVelocity");bv.MaxForce=Vector3.new(1e9,1e9,1e9);bv.Velocity=Vector3.new(0,900,0);bv.Parent=hrp;Debris:AddItem(bv,.15)
end)

---- ESP ----
sec("ESP","ESP Settings")
tog("ESP","Enable ESP","esp","See all players through walls",nil)
tog("ESP","Corner Box","espCorner","Show corner brackets around player",nil)
tog("ESP","Full Box","espBoxFull","Full outline box around player",nil)
tog("ESP","Skeleton","espSkeleton","Show bone structure lines",nil)
tog("ESP","Head Dot","espHeadDot","Show dot on player head",nil)
tog("ESP","Chams","espChams","Glow highlight through walls",nil)
tog("ESP","Health Bars","espHealth","Show HP bar",nil)
tog("ESP","Names","espNames","Show player names",nil)
tog("ESP","Distance","espDist","Show distance in meters",nil)
tog("ESP","Tracer","espTracer","Line from you to enemy",nil)
sld("ESP","Max Distance  (m)",50,2000,CFG.espMaxDist,50,"ESP render range",function(v) CFG.espMaxDist=v end)
sld("ESP","Line Thickness",1,6,CFG.espLineThick,1,"Box/line thickness",function(v) CFG.espLineThick=v end)
sec("ESP","Color")
sld("ESP","Hue  (0=White)",0,100,math.floor(CFG.espColorH*100),1,"Color hue",function(v) CFG.espColorH=v/100 end)
sld("ESP","Saturation %",0,100,math.floor(CFG.espColorS*100),1,"Color saturation",function(v) CFG.espColorS=v/100 end)
sld("ESP","Brightness %",0,100,math.floor(CFG.espColorV*100),1,"Color brightness",function(v) CFG.espColorV=v/100 end)
note("ESP","Green=H36 S90 V100  |  White=H0 S0 V100  |  Red=H0 S100 V100")

---- EMOTES ----
sec("Emotes","Default Roblox Emotes")
note("Emotes","Click any emote to play it — works in most games")
local EMOTES = {
    -- Default free emotes
    {"Wave",         "Wave"},
    {"Point",        "Point"},
    {"Cheer",        "Cheer"},
    {"Laugh",        "Laugh"},
    {"Dance",        "Dance"},
    {"Dance2",       "Dance 2"},
    {"Dance3",       "Dance 3"},
    -- R15 emotes
    {"Salute",       "Salute"},
    {"Tilt",         "Tilt"},
    {"Shrug",        "Shrug"},
    {"Stadium",      "Stadium"},
    {"Tentacle",     "Tentacle"},
    {"Woah",         "Woah"},
    {"Hype",         "Hype"},
    {"Charging",     "Charging"},
    {"Life",         "Life"},
    {"Agree",        "Agree"},
    {"Disagree",     "Disagree"},
    {"CommunityTalk","Community Talk"},
    {"FireUp",       "Fire Up"},
    {"Flex",         "Flex"},
    {"Pose1",        "Pose 1"},
    {"Pose2",        "Pose 2"},
    {"Goofy",        "Goofy Run"},
    {"BubbleMagic",  "Bubble Magic"},
    {"Bow",          "Bow"},
    {"Hello",        "Hello"},
    {"DuckWalk",     "Duck Walk"},
    {"Superhero",    "Superhero"},
    {"Ninja",        "Ninja"},
    {"Sit",          "Sit"},
    {"Sleep",        "Sleep"},
    {"Win",          "Winner"},
    {"Lose",         "Loser"},
    {"Swim",         "Swim"},
    {"Swim2",        "Swim 2"},
    {"Climb",        "Climb"},
    {"Jump",         "Jump"},
    {"Fall",         "Fall"},
    {"Idle1",        "Idle"},
    {"Run",          "Run"},
    {"Walk",         "Walk"},
    {"Kick",         "Kick"},
    {"Punch",        "Punch"},
    {"Block",        "Block"},
    {"Carry",        "Carry"},
}

local function playEmote(emoteName)
    local c=getChar(); if not c then return end
    local hum=getHum(); if not hum then return end
    -- Method 1: Use Animate script
    local animate=c:FindFirstChild("Animate")
    if animate then
        local emoteEvent=animate:FindFirstChild("PlayEmote")
        if emoteEvent then
            pcall(function() emoteEvent:Fire(emoteName) end)
            return
        end
    end
    -- Method 2: Use HumanoidRootPart remote
    pcall(function()
        local args = {emoteName}
        game:GetService("ReplicatedStorage"):WaitForChild("EmoteEvent",1):FireServer(unpack(args))
    end)
    -- Method 3: Direct animation (fallback)
    pcall(function()
        hum:GetPropertyChangedSignal("Jump"):Connect(function() end)
        local args2={[1]=emoteName}
        game:GetService("ReplicatedStorage"):FindFirstChild("EmoteEvent") and
        game:GetService("ReplicatedStorage").EmoteEvent:FireServer(table.unpack(args2))
    end)
    notify("Emote",emoteName,1.5)
end

-- Stop emote button first
btn("Emotes","⏹  Stop Current Emote","Stop the currently playing emote",function()
    local c=getChar(); if not c then return end
    local hum=getHum(); if not hum then return end
    pcall(function()
        for _,track in ipairs(hum:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end)
    notify("Emote","Stopped",1)
end)

sec("Emotes","All Available Emotes")
for _,e in ipairs(EMOTES) do
    btn("Emotes",e[2],"Play emote: "..e[2],function() playEmote(e[1]) end)
end

---- MAP ----
sec("Map","Position Marker")
btn("Map","Save Position  +  Spawn Arrow","Save your position and spawn a spinning marker",function()
    local hrp=getHRP()
    if hrp then lastPos=hrp.CFrame; spawnMarker(hrp.CFrame); notify("GLUHFIX","Position saved! Arrow spawned.",2) end
end)
btn("Map","Return to Saved Position","Teleport back to your saved position",function()
    local hrp=getHRP()
    if hrp and lastPos then pcall(function() hrp.CFrame=lastPos end)
    else notify("GLUHFIX","No position saved!",2) end
end)
btn("Map","Remove Marker","Remove the spawned arrow marker",function()
    removeMarker(); notify("GLUHFIX","Marker removed.",2)
end)

sec("Map","Workspace File Explorer")
note("Map","Click 'Scan' to explore all folders and objects in the map")
btn("Map","Scan Entire Workspace","List all objects, folders and scripts in workspace",function()
    -- Clear previous results
    for _,c in ipairs(tabScrolls["Map"]:GetChildren()) do if c.Name=="ER" then c:Destroy() end end
    local ct=0
    local function traverse(obj,depth)
        if ct>1000 then return end; ct=ct+1
        local row=mk("Frame",{Name="ER",Size=UDim2.new(1,0,0,22),
            BackgroundColor3=depth%2==0 and T.row or T.panel,BorderSizePixel=0},tabScrolls["Map"])
        rnd(row,5)
        -- indent + icon based on class
        local icon="▸"
        if obj:IsA("Folder") then icon="📁"
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then icon="📜"
        elseif obj:IsA("Model") then icon="🧩"
        elseif obj:IsA("BasePart") then icon="⬜"
        elseif obj:IsA("Light") then icon="💡" end
        mk("TextLabel",{
            Text=("  "):rep(math.min(depth,5))..icon.." "..obj.Name,
            Size=UDim2.new(.62,0,1,0),BackgroundTransparency=1,
            TextColor3=T.txt,TextSize=10,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left},row)
        mk("TextLabel",{
            Text=obj.ClassName,Size=UDim2.new(.38,0,1,0),
            Position=UDim2.new(.62,0,0,0),BackgroundTransparency=1,
            TextColor3=T.dim,TextSize=9,Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Right},row)
        if depth<4 then
            for _,ch in ipairs(obj:GetChildren()) do traverse(ch,depth+1) end
        end
    end
    traverse(workspace,0)
    notify("GLUHFIX","Scan complete: "..ct.." objects",3)
end)
btn("Map","Scan game.ReplicatedStorage","List contents of ReplicatedStorage",function()
    for _,c in ipairs(tabScrolls["Map"]:GetChildren()) do if c.Name=="ER" then c:Destroy() end end
    local ct=0
    local function traverse(obj,depth)
        if ct>500 then return end; ct=ct+1
        local row=mk("Frame",{Name="ER",Size=UDim2.new(1,0,0,22),
            BackgroundColor3=depth%2==0 and T.row or T.panel,BorderSizePixel=0},tabScrolls["Map"])
        rnd(row,5)
        mk("TextLabel",{Text=("  "):rep(math.min(depth,5)).."▸ "..obj.Name,Size=UDim2.new(.62,0,1,0),BackgroundTransparency=1,TextColor3=T.txt,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},row)
        mk("TextLabel",{Text=obj.ClassName,Size=UDim2.new(.38,0,1,0),Position=UDim2.new(.62,0,0,0),BackgroundTransparency=1,TextColor3=T.dim,TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right},row)
        if depth<3 then for _,ch in ipairs(obj:GetChildren()) do traverse(ch,depth+1) end end
    end
    pcall(function() traverse(game:GetService("ReplicatedStorage"),0) end)
    notify("GLUHFIX","ReplicatedStorage: "..ct.." objects",3)
end)
btn("Map","Highlight All Parts  (5s)","Draw selection boxes on all parts for 5s",function()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            pcall(function()
                local s=Instance.new("SelectionBox");s.Adornee=v;s.Color3=T.accent
                s.LineThickness=.04;s.SurfaceTransparency=.88;s.SurfaceColor3=T.accent
                s.Parent=gui;Debris:AddItem(s,5)
            end)
        end
    end
end)

-- ============================================================
-- CONFIG TAB
-- ============================================================
sec("Config","Saved Settings")
note("Config","All toggles & sliders save automatically on change.")
note("Config","They reload automatically on next script start.")
btn("Config","Save Now","Save all settings immediately",function()
    saveConfig(); notify("GLUHFIX","Config saved! ✓",3)
end)
btn("Config","Reset Config","Delete all saved values",function()
    pcall(function()
        for attr,_ in pairs(lp:GetAttributes()) do
            if tostring(attr):sub(1,4)=="GF9_" then lp:SetAttribute(attr,nil) end
        end
    end)
    notify("GLUHFIX","Config reset! Restart script.",3)
end)

sec("Config","Active Features — Live Status")
local statusLabels={}
local featureNames={
    {"fly","Fly"},{"noclip","Noclip"},{"speed","Speed Boost"},{"highJump","High Jump"},
    {"spinBot","Spinbot"},{"bunnyHop","Bunny Hop"},{"autoJump","Auto Jump"},
    {"infinite_jump","Infinite Jump"},{"antiAfk","Anti-AFK"},{"antiLag","Anti-Lag"},
    {"aimbot","Aimbot"},{"aimbotVisCheck","Visual Check"},{"aimbotTeamCheck","Team Check"},
    {"triggerbot","Triggerbot"},{"antiKick","Anti-Kick"},{"antiDetect","Anti-Detect"},
    {"invisible","Invisible"},{"headless","Headless"},
    {"esp","ESP"},{"fullbright","Fullbright"},{"noFog","No Fog"},
    {"crosshair","Crosshair"},{"freezeTime","Freeze Time"},
    {"showCoords","Coords"},{"showFPS","FPS Counter"},{"chatSpy","Chat Spy"},
}
local statusFrame=mk("Frame",{Size=UDim2.new(1,0,0,#featureNames*26+16),BackgroundColor3=T.accDark,BorderSizePixel=0},tabScrolls["Config"])
rnd(statusFrame,11)
mk("UIListLayout",{Padding=UDim.new(0,2)},statusFrame); pad(statusFrame,10,10,8,8)
for _,pair in ipairs(featureNames) do
    local key,name=pair[1],pair[2]
    local row=mk("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},statusFrame)
    mk("TextLabel",{Text=name,Size=UDim2.new(.7,0,1,0),BackgroundTransparency=1,
        TextColor3=T.dim,TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},row)
    local valLabel=mk("TextLabel",{Text="off",Size=UDim2.new(.3,0,1,0),Position=UDim2.new(.7,0,0,0),
        BackgroundTransparency=1,TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right},row)
    statusLabels[key]=valLabel
end
RunService.Heartbeat:Connect(function()
    if activeTab~="Config" then return end
    for key,lbl in pairs(statusLabels) do
        pcall(function()
            local on=CFG[key]; lbl.Text=on and "ON" or "off"; lbl.TextColor3=on and T.green or T.dim
        end)
    end
end)

sec("Config","Export")
btn("Config","Print Config to Output (F9)","Print all values to Roblox output",function()
    print("=== GLUHFIX v9.0 Config ===")
    for k,v in pairs(CFG) do
        local t=type(v)
        if t=="boolean" or t=="number" then print(("  %-28s = %s"):format(k,tostring(v))) end
    end
    notify("GLUHFIX","Config printed to Output (F9)",3)
end)

---- SETTINGS ----
sec("Settings","Keybinds")
local kbDisp=mk("TextLabel",{
    Text="Toggle Key:  [ LeftControl ]",
    Size=UDim2.new(1,0,0,38),BackgroundColor3=T.accDark,TextColor3=T.accent,
    TextSize=14,Font=Enum.Font.GothamBold,BorderSizePixel=0,
    TextXAlignment=Enum.TextXAlignment.Center},tabScrolls["Settings"])
rnd(kbDisp,11); mk("UIStroke",{Color=T.border,Thickness=1.2},kbDisp)
rTC(function() kbDisp.BackgroundColor3=T.accDark; kbDisp.TextColor3=T.accent end)
btn("Settings","Bind Toggle Key","Press any key to set as menu toggle",function()
    kbDisp.Text="Press any key..."; kbDisp.TextColor3=T.txt
    local conn; conn=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            CFG.toggleKey=inp.KeyCode
            local kn=tostring(inp.KeyCode):match("%.(%a+)$") or "?"
            kbDisp.Text="Toggle Key:  [ "..kn.." ]"; kbDisp.TextColor3=T.accent
            conn:Disconnect(); saveConfig()
        end
    end)
end)
sec("Settings","Theme")
note("Settings","Default: Black/White. Adjust Hue + Saturation for color.")
sld("Settings","Accent Hue %",0,100,math.floor(CFG.accentH*100),1,"Color hue",function(v) CFG.accentH=v/100;refreshT();pcall(function() winStroke.Color=T.accent end);saveConfig() end)
sld("Settings","Saturation %",0,100,math.floor(CFG.accentS*100),1,"Saturation (0 = Black/White)",function(v) CFG.accentS=v/100;refreshT();saveConfig() end)
note("Settings","Quick color presets:")
local function thB(l,h,s) btn("Settings",l,nil,function() CFG.accentH=h;CFG.accentS=s;refreshT();pcall(function() winStroke.Color=T.accent end);saveConfig() end) end
thB("⬜  White / Black (Default)",0.0,0.0)
thB("🔵  Blue — Hacker",0.60,0.95)
thB("🟣  Purple",0.72,0.88)
thB("🩵  Cyan",0.52,0.90)
thB("🟢  Green",0.36,0.90)
thB("🔴  Red",0.00,0.90)
thB("🟠  Orange",0.07,1.00)
thB("🩷  Pink",0.88,0.85)
sec("Settings","Info & Tools")
tog("Settings","Coordinates","showCoords","Show XYZ position on screen",nil)
tog("Settings","FPS Counter","showFPS","Show FPS on screen",nil)
tog("Settings","Chat Spy","chatSpy","Log all chat messages to output",nil)
btn("Settings","Print Players + IDs","Print all player names and user IDs to output",function()
    for _,p in ipairs(Players:GetPlayers()) do
        print(("[GF9] %s  ID:%d  Team:%s"):format(p.Name,p.UserId,tostring(p.Team)))
    end; notify("GLUHFIX","IDs printed — open F9",2)
end)
btn("Settings","Re-apply All Features","Re-apply all active features after respawn",function()
    if CFG.invisible then applyInvis(true) end
    if CFG.headless  then applyHeadless(true) end
    if CFG.fullbright then applyFullbright(true) end
    local h=getHum()
    if h then
        if CFG.speed then pcall(function() h.WalkSpeed=16*CFG.speedMult end) end
        if CFG.highJump then pcall(function() h.UseJumpPower=true; h.JumpPower=CFG.jumpPower end) end
    end; notify("GLUHFIX","Re-applied!",2)
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
    if CFG.invisible  then applyInvis(true) end
    if CFG.headless   then applyHeadless(true) end
    if CFG.fullbright then applyFullbright(true) end
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then
        if CFG.speed    then pcall(function() h.WalkSpeed=16*CFG.speedMult end) end
        if CFG.highJump then pcall(function() h.UseJumpPower=true; h.JumpPower=CFG.jumpPower end) end
    end
    if CFG.fly      then stopFly();    task.wait(.1); startFly()    end
    if CFG.noclip   then stopNoclip(); startNoclip()                end
    if CFG.bunnyHop then stopBhop();   task.wait(.1); startBhop()   end
    if CFG.freezeTime then applyFreezeTime(true) end
end)

-- ============================================================
-- KEYBINDS  —  keyboard + mouse support
-- ============================================================
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe and inp.KeyCode~=CFG.toggleKey then return end
    -- Toggle menu
    if inp.KeyCode==CFG.toggleKey then showWin(not Win.Visible) end
    -- Aimbot key (keyboard)
    if inp.KeyCode==CFG.aimbotKey and CFG.aimbotKey~=Enum.KeyCode.Unknown then
        aimbotKeyHeld=true
    end
    -- Aimbot mouse button
    if CFG.aimbotMouseBtn and inp.UserInputType==CFG.aimbotMouseBtn then
        aimbotMouseHeld=true
    end
    -- Triggerbot key
    if CFG.triggerbotKey~=Enum.KeyCode.Unknown and inp.KeyCode==CFG.triggerbotKey then
        triggerbotKeyHeld=true
    end
    -- Triggerbot mouse
    if CFG.triggerbotMouse and inp.UserInputType==CFG.triggerbotMouse then
        triggerbotMouseHeld=true
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.KeyCode==CFG.aimbotKey then aimbotKeyHeld=false end
    if CFG.aimbotMouseBtn and inp.UserInputType==CFG.aimbotMouseBtn then aimbotMouseHeld=false end
    if CFG.triggerbotKey~=Enum.KeyCode.Unknown and inp.KeyCode==CFG.triggerbotKey then triggerbotKeyHeld=false end
    if CFG.triggerbotMouse and inp.UserInputType==CFG.triggerbotMouse then triggerbotMouseHeld=false end
end)

-- ============================================================
-- WELCOME ANIMATION — cinematic intro, auto-closes, guaranteed destroy
-- ============================================================
task.spawn(function()
    local WA = mk("Frame",{
        Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(0,0,0),
        BackgroundTransparency=0, BorderSizePixel=0, ZIndex=500
    }, gui)
    -- failsafe: max 10s
    task.delay(10, function() pcall(function() WA:Destroy() end) end)

    -- Cinematic bars
    local barTop = mk("Frame",{Size=UDim2.new(1,0,0,90),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(0,0,0),BorderSizePixel=0,ZIndex=502},WA)
    local barBot = mk("Frame",{Size=UDim2.new(1,0,0,90),Position=UDim2.new(0,0,1,-90),BackgroundColor3=Color3.fromRGB(0,0,0),BorderSizePixel=0,ZIndex=502},WA)
    task.wait(.05)

    -- Scan line
    local scan = mk("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,0,90),BackgroundColor3=Color3.fromRGB(200,200,200),BackgroundTransparency=.3,BorderSizePixel=0,ZIndex=504},WA)
    tw(scan,.5,{Position=UDim2.new(0,0,1,-92),BackgroundTransparency=.9},Enum.EasingStyle.Linear)
    task.wait(.38)

    -- "Hello," fades + rises
    local hello=mk("TextLabel",{Text="Hello,",Size=UDim2.new(1,0,0,44),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.4,20),BackgroundTransparency=1,TextColor3=Color3.fromRGB(140,140,140),TextSize=30,Font=Enum.Font.GothamBold,TextTransparency=1,ZIndex=506},WA)
    tw(hello,.3,{TextTransparency=0,Position=UDim2.new(.5,0,.4,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
    task.wait(.26)

    -- Name typewriter
    local nameL=mk("TextLabel",{Text="",Size=UDim2.new(1,0,0,80),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.535,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(255,255,255),TextSize=62,Font=Enum.Font.GothamBold,TextTransparency=0,ZIndex=506},WA)
    for i=1,#lp.Name do
        if not WA.Parent then return end
        nameL.Text=lp.Name:sub(1,i)
        nameL.TextColor3=(i%2==0) and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)
        task.wait(.055)
    end
    nameL.TextColor3=Color3.fromRGB(255,255,255)
    task.wait(.08)

    -- Accent line
    local acLine=mk("Frame",{Size=UDim2.new(0,0,0,2),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.626,0),BackgroundColor3=Color3.fromRGB(220,220,220),BorderSizePixel=0,ZIndex=506},WA)
    tw(acLine,.5,{Size=UDim2.new(.26,0,0,2)},Enum.EasingStyle.Expo,Enum.EasingDirection.Out)
    local tag=mk("TextLabel",{Text="G L U H F I X   v 9 . 0",Size=UDim2.new(1,0,0,18),AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(.5,0,.69,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(70,70,70),TextSize=11,Font=Enum.Font.Gotham,TextTransparency=1,ZIndex=506,TextXAlignment=Enum.TextXAlignment.Center},WA)
    task.wait(.18)
    tw(tag,.35,{TextTransparency=0},Enum.EasingStyle.Quart)

    -- Hold ~3 seconds
    task.wait(1.4)

    -- Outro: text flies up
    tw(hello,.25,{TextTransparency=1,Position=UDim2.new(.5,0,.37,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
    tw(nameL,.25,{TextTransparency=1,Position=UDim2.new(.5,0,.50,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
    tw(acLine,.2,{BackgroundTransparency=1})
    tw(tag,.2,{TextTransparency=1})
    task.wait(.15)
    -- Bars slam out
    tw(barTop,.3,{Position=UDim2.new(0,0,0,-90)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
    tw(barBot,.3,{Position=UDim2.new(0,0,1,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
    task.wait(.22)
    -- DESTROY — no transparency tween on root frame
    pcall(function() WA:Destroy() end)
    -- Open menu
    Win.Visible=true; Win.BackgroundTransparency=0
    hLine.Size=UDim2.new(1,0,0,2)
    switchTab("Move")
end)

print("⚡ GLUHFIX v9.0 loaded — Hello, "..lp.Name.." | Toggle: [Left Ctrl]")