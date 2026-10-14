--[[
    GreatWall AutoPlace — Rayfield (extended)
    v2.3.0

    - Register-safe: consolidated state into tables (under 200 locals)
    - No goto/continue (Luau compatible)
    - Auto-upgrade uses Config.Upgrades + Remotes.Upgrade (RemoteFunction)
    - Auto-enter shrine zone when server replies "far"
    - Boost zone filter, 500x training targets, admin/mod detection
    - Admin panel local-gate bypass
    - Changelogs tab
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")
local LocalPlayer       = Players.LocalPlayer

local GreatWall = ReplicatedStorage:WaitForChild("GreatWall")
local Remotes   = GreatWall:WaitForChild("Remotes")

local SCRIPT_VERSION = "2.3.0"
local MAX_FIRES_PER_TICK = 12

-- wipe leftovers
do
    local old = workspace:FindFirstChild("AutoPlace_SectionViz"); if old then old:Destroy() end
    local old2 = workspace:FindFirstChild("AutoPlace_FireRing"); if old2 then old2:Destroy() end
    local cam = workspace.CurrentCamera
    if cam then
        local old3 = cam:FindFirstChild("AutoPlace_Highlights"); if old3 then old3:Destroy() end
    end
end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Build a Greatwall",
    LoadingTitle = "Automation",
    LoadingSubtitle = "by ChatGPT & Gouang  v" .. SCRIPT_VERSION,
    ConfigurationSaving = { Enabled = false },
    Icon = 0,
})

local CFG = {
    running = false, rate = 1500, adaptive = true, minRate = 15, regrowEvery = 1.5,
    moveMode = "teleport", placeMode = "nearest", targetMode = "cluster",
    placeInput = "hybrid", stepSpeed = 400, fireRadius = 40,
    noclip = true, cameraSeeThrough = true, useFlight = true,
    refillEnabled = true, refillInterval = 0.08, refillGroundY = 4,
    inflightTimeout = 2.0, pendingMaxAge = 5.0, suspendPoll = 0.5,
    clusterRadius = 30,

    trainStrength = false, trainSpeed = false, trainPauseBuild = true,
    trainReengageDist = 15, trainSpeedAnchorOffset = 3,

    autoTrainStrengthOn = false, autoTrainStrengthTarget = 500,
    autoTrainSpeedOn = false,    autoTrainSpeedTarget = 500,

    hsAuto = false, hsReturnBefore = 30, hsTeleportYOffset = 3, hsStayMin = 60,

    boostFilterOn = false, boostFilterMin = 1.5,

    autoUpgradeOn = false, autoUpgradeIds = {},
    autoUpgradeRespectWalls = true, autoUpgradeInterval = 0.6,
    autoUpgradeAutoShrine = true,

    tierFilterOn = false, tierFilterMin = 1,

    showPlaceHighlight = true, showFireRing = false,
    fireRingColor = Color3.fromRGB(143, 0, 255),
    placeHighlightColor = Color3.fromRGB(143, 0, 255),
    verbose = false, antiAfk = true,

    adminDetectOn = true, adminWarnSeconds = 2, adminLeaveMode = "rejoin",
    adminPanelKey = Enum.KeyCode.RightShift,
}

local function log(...)
    local parts = {}
    for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
    print("[AutoPlace] " .. table.concat(parts, " "))
end

-- ============================================================
-- Reflection
-- ============================================================

local function safeScripts()
    local ok, list = pcall(getscripts)
    if ok and type(list) == "table" then return list end
    local out = {}
    for _, d in LocalPlayer.PlayerScripts:GetDescendants() do
        if d:IsA("LocalScript") then out[#out + 1] = d end
    end
    return out
end
local function findClientScript()
    for _, s in ipairs(safeScripts()) do
        if s and s.Name and s.Name:lower():find("greatwall") then return s end
    end
end
local function safeClosure(scr)
    local ok, c = pcall(getscriptclosure, scr)
    return ok and type(c) == "function" and c or nil
end
local function safeProtos(fn)
    local ok, p = pcall(function() return debug.getprotos(fn) end)
    return ok and type(p) == "table" and p or {}
end
local function safeUpvalue(fn, i)
    local ok, name, val = pcall(function() return debug.getupvalue(fn, i) end)
    return ok and name or nil, val
end
local function findUpvalue(fn, match, depth)
    depth = depth or 0
    if depth > 8 or type(fn) ~= "function" then return nil end
    local i = 1
    while true do
        local name, val = safeUpvalue(fn, i)
        if not name then break end
        if match(name, val) then return val end
        i = i + 1
        if i > 200 then break end
    end
    for _, p in ipairs(safeProtos(fn)) do
        local f = findUpvalue(p, match, depth + 1)
        if f then return f end
    end
end
local function findPlaceIntoHeuristic(root)
    local found = nil
    local function walk(fn, depth)
        if found or depth > 8 or type(fn) ~= "function" then return end
        local hasPlace, hasU2 = false, false
        local i = 1
        while true do
            local name, val = safeUpvalue(fn, i)
            if not name then break end
            if typeof(val) == "Instance" and val:IsA("RemoteEvent") and val.Name == "Place" then hasPlace = true end
            if type(val) == "table" and val.seq ~= nil and val.spent ~= nil and val.sent ~= nil then hasU2 = true end
            i = i + 1
            if i > 200 then break end
        end
        if hasPlace and hasU2 then found = fn; return end
        for _, p in ipairs(safeProtos(fn)) do
            walk(p, depth + 1); if found then return end
        end
    end
    walk(root, 0)
    return found
end

local Config, Place, Fill = nil, nil, nil
local WallTiersModule, UpgradesTable, UpgradeRemote = nil, nil, nil
local clientPlaceInto, clientRoot = nil, nil

do
    local scr = findClientScript()
    clientRoot = scr and safeClosure(scr)
    if clientRoot then
        Config = findUpvalue(clientRoot, function(n, v) return n == "Config" and type(v) == "table" end)
        Place  = findUpvalue(clientRoot, function(n, v)
            return n == "Place" and typeof(v) == "Instance" and v:IsA("RemoteEvent")
        end)
        clientPlaceInto = findUpvalue(clientRoot, function(n, v)
            return n == "placeInto" and type(v) == "function"
        end)
        if not clientPlaceInto then clientPlaceInto = findPlaceIntoHeuristic(clientRoot) end
    end
    if not Config then
        local ok, mod = pcall(require, GreatWall:WaitForChild("Config"))
        if ok then Config = mod end
    end
    if not Place then Place = Remotes:WaitForChild("Place") end
    Fill = Remotes:WaitForChild("Fill", 5)

    do
        local ok, mod = pcall(require, GreatWall:WaitForChild("WallTiers", 5))
        if ok and type(mod) == "table" then WallTiersModule = mod end
    end

    if Config and type(Config.Upgrades) == "table" then
        UpgradesTable = Config.Upgrades
    end
    if not UpgradesTable then
        local ps = LocalPlayer:WaitForChild("PlayerScripts", 10)
        local menuScript = ps and ps:FindFirstChild("UpgradesMenu", 5)
        if menuScript and menuScript:IsA("LocalScript") then
            local closure = safeClosure(menuScript)
            if closure then
                local found = findUpvalue(closure, function(_, v)
                    return type(v) == "table" and type(v.List) == "table"
                        and #v.List > 0 and v.List[1].Id ~= nil
                end)
                if found then UpgradesTable = found end
            end
        end
    end
    do
        local ok, rem = pcall(function() return Remotes:WaitForChild("Upgrade", 30) end)
        if ok and rem then UpgradeRemote = rem end
    end
end

log("Ready. Config=" .. tostring(Config) .. " placeInto=" .. tostring(clientPlaceInto)
    .. " Upgrades=" .. tostring(UpgradesTable ~= nil)
    .. " UpgradeRemote=" .. tostring(UpgradeRemote ~= nil))

local function getLiveAttr(name)
    local ok, v = pcall(function() return LocalPlayer:GetAttribute(name) end)
    if ok then return v end
    return nil
end
local function allLiveAttrs()
    local keys = { "PlaceRange","PlaceCooldown","Capacity","Blocks","Skin",
                   "PracticeAt","TriedEmpty","AtPit","Filling",
                   "ShowVfx","ShowAnims","ShowBags" }
    local out = {}
    for _, k in ipairs(keys) do
        local v = getLiveAttr(k)
        if v ~= nil then out[#out + 1] = { key = k, value = v } end
    end
    table.sort(out, function(a, b) return a.key < b.key end)
    return out
end

local BLOCK     = (Config and Config.Block) or 4
local ORIGIN_X  = (Config and Config.Origin and Config.Origin.X) or 0
local ORIGIN_Y  = (Config and Config.Origin and Config.Origin.Y) or 0
local ORIGIN_Z  = (Config and Config.Origin and Config.Origin.Z) or -10
local LENGTH    = (Config and Config.Length) or 330
local SECTIONS  = (Config and Config.Sections) or 16
local THICKNESS = (Config and Config.Thickness) or 14
local STAGES    = Config and Config.Stages or nil

local function columnOf(x) return math.clamp(math.floor((x - ORIGIN_X) / BLOCK), 0, LENGTH - 1) end
local function layerOf(y) return math.floor((y - ORIGIN_Y) / BLOCK) end
local function columnWorldX(col) return ORIGIN_X + col * BLOCK end
local function defaultZ() return ORIGIN_Z - THICKNESS * BLOCK * 0.5 - 6 end
local function sectionOf(x)
    local col = columnOf(x)
    if STAGES then
        for i, v in ipairs(STAGES) do
            if v.x0 <= col and col <= v.x1 then return i end
        end
    end
    local per = math.max(1, math.ceil(LENGTH / SECTIONS))
    return math.clamp(math.floor(col / per) + 1, 1, SECTIONS)
end
local function cellOf(g)
    local col = math.floor((g.Position.X - ORIGIN_X) / BLOCK + 0.5)
    local lay = math.floor((g.Position.Y - ORIGIN_Y) / BLOCK + 0.5)
    local zb  = math.floor(g.Position.Z * 4 + 0.5)
    return col, lay, zb
end
local function keyOf(col, lay, zb) return col .. ":" .. lay .. ":" .. zb end

-- ============================================================
-- Consolidated state tables
-- ============================================================

local GL = {
    s = {}, l = {}, i = {},
    parts = {},
    fired = {},
    inflight = {},
    pending = {},
    dirty = true,
    seq = 1000000,
    lastPlaced = nil,
    lastSuspend = 0,
    cluster = nil,
}

local RATE = { pausedUntil = 0, current = CFG.rate, lastRegrow = os.clock(), bucket = 0 }

local analytics = {
    fires = 0, acks = 0, firesThisSec = 0, acksThisSec = 0,
    lastBucket = os.clock(), recent = {}, RECENT = 5,
    lastAckAt = 0, lastFireAt = 0,
}

local MOVE = { attach = nil, vel = nil, saved = {} }

local CAM = { ignore = {}, wallFolder = nil, wallConn = nil, ghostConn = nil }

local KEY = { held = false, vk = 0x45 }

local RT  = { leaving = false, antiAfkConn = nil }

local HL  = { SIZE = 6, HOLD = 0.5, pool = {}, idx = 1, folder = nil, ring = nil }

local SM  = { phase = "idle", target = nil, settleUntil = 0 }

local TIMERS = { dt = os.clock(), info = 0, afk = 0 }

local UPG = {
    lastAt = 0, reason = nil, triedAt = {},
    shrine = {
        lastVisit = 0,
        savedCFrame = nil,
        inZone = false,
        -- new:
        active = false,      -- currently on a shrine trip?
        enteredAt = 0,       -- when we entered
        maxStay = 2.0,       -- auto-leave after this many seconds
        cooldown = 4.0,      -- min seconds between shrine trips
    }
}

local AUTO = { settleTime = 0.12, lastAdapt = 0, PERIOD = 2.0, MIN = 0.06, MAX = 0.5, STEP = 0.03 }

-- ============================================================
-- Character movement helpers
-- ============================================================

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildOfClass("BasePart")
end

local function forceHumanoidWake()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Non-zero input for one frame → forces Humanoid out of the frozen state
    hum:Move(Vector3.new(0, 0, -0.01), false)
    task.wait(0.03)
    hum:Move(Vector3.zero, false)

    -- Reset any hard-stuck flags
    hum.PlatformStand = false
    hum:ChangeState(Enum.HumanoidStateType.Running)

    -- Also drop any residual velocity so we don't slide
    local root = getRoot()
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function setNoclip(on)
    local char = LocalPlayer.Character
    if not char then return end
    if on then
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                if MOVE.saved[d] == nil then MOVE.saved[d] = d.CanCollide end
                d.CanCollide = false
            end
        end
    else
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                local saved = MOVE.saved[d]
                d.CanCollide = (saved ~= nil) and saved or (d.Name == "HumanoidRootPart")
            end
        end
        MOVE.saved = {}
    end
end

local function enableFlight()
    local root = getRoot()
    if not root or MOVE.vel then return end
    pcall(function()
        MOVE.attach = Instance.new("Attachment", root)
        MOVE.vel = Instance.new("LinearVelocity")
        MOVE.vel.Attachment0 = MOVE.attach
        MOVE.vel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        MOVE.vel.VectorVelocity = Vector3.zero
        MOVE.vel.MaxForce = math.huge
        MOVE.vel.Parent = root
    end)
end

local function disableFlight()
    if MOVE.vel then MOVE.vel:Destroy(); MOVE.vel = nil end
    if MOVE.attach then MOVE.attach:Destroy(); MOVE.attach = nil end
end

local function dropToGround()
    local char = LocalPlayer.Character
    local root = getRoot()
    if not char or not root then return end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char }
    local hit = workspace:Raycast(root.Position, Vector3.new(0, -1000, 0), params)
    if hit then
        root.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0), root.CFrame.LookVector + hit.Position)
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
end

local function groundYAt(x, z)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local hit = workspace:Raycast(Vector3.new(x, ORIGIN_Y + 500, z), Vector3.new(0, -1200, 0), params)
    return hit and hit.Position.Y or ORIGIN_Y
end

-- ============================================================
-- Camera see-through
-- ============================================================

local function camSetIgnore(part, ignore)
    if not part or not part:IsA("BasePart") then return end
    if ignore then
        if CAM.ignore[part] == nil then CAM.ignore[part] = part.CanQuery end
        part.CanQuery = false
    else
        local saved = CAM.ignore[part]
        if saved ~= nil then part.CanQuery = saved; CAM.ignore[part] = nil end
    end
end
local function camScanFolder(folder)
    if not folder then return end
    for _, d in ipairs(folder:GetDescendants()) do
        if d:IsA("BasePart") then camSetIgnore(d, true) end
    end
end
local function cameraSeeThroughEnable()
    for _, part in ipairs(CollectionService:GetTagged("WallGhost")) do camSetIgnore(part, true) end
    if not CAM.ghostConn then
        CAM.ghostConn = CollectionService:GetInstanceAddedSignal("WallGhost"):Connect(function(p)
            if CFG.cameraSeeThrough then camSetIgnore(p, true) end
        end)
    end
    CAM.wallFolder = workspace:FindFirstChild("GreatWall")
    if CAM.wallFolder then
        camScanFolder(CAM.wallFolder)
        if not CAM.wallConn then
            CAM.wallConn = CAM.wallFolder.DescendantAdded:Connect(function(d)
                if CFG.cameraSeeThrough and d:IsA("BasePart") then camSetIgnore(d, true) end
            end)
        end
    end
end
local function cameraSeeThroughDisable()
    for part, saved in pairs(CAM.ignore) do
        if part and part.Parent then part.CanQuery = saved end
    end
    CAM.ignore = {}
    if CAM.wallConn then CAM.wallConn:Disconnect(); CAM.wallConn = nil end
    if CAM.ghostConn then CAM.ghostConn:Disconnect(); CAM.ghostConn = nil end
    CAM.wallFolder = nil
end

local function phaseBlocksPlacement()
    if GreatWall:GetAttribute("Phase") == "Event" then return true, "event active" end
    if GreatWall:GetAttribute("JadeEventAt") ~= nil then return true, "jade event" end
    if LocalPlayer:GetAttribute("JadePreviewAt") ~= nil then return true, "jade preview" end
    return false, nil
end

-- ============================================================
-- E-key input
-- ============================================================

local function simulateM1Down()
    if type(keypress) ~= "function" then return false end
    return pcall(keypress, KEY.vk)
end
local function simulateM1Up()
    if type(keyrelease) == "function" then pcall(keyrelease, KEY.vk) end
end
local function setM1Held(on)
    if on and not KEY.held then
        if simulateM1Down() then KEY.held = true end
    elseif not on and KEY.held then
        simulateM1Up(); KEY.held = false
    end
end

-- ============================================================
-- Anti-AFK
-- ============================================================

local function vUserClick()
    if VirtualUser then
        local cam = workspace.CurrentCamera
        if cam then
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), cam.CFrame)
                task.wait(0.05)
                VirtualUser:Button2Up(Vector2.new(0, 0), cam.CFrame)
            end)
        end
        return
    end
    local VIM = game:GetService("VirtualInputManager")
    if VIM then
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 1, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0, 0, 1, false, game, 0)
        end)
    end
end
local function enableAntiAfk()
    if RT.antiAfkConn then return end
    RT.antiAfkConn = LocalPlayer.Idled:Connect(function()
        vUserClick()
        log("anti-afk: idled, sent input")
    end)
end
local function disableAntiAfk()
    if RT.antiAfkConn then RT.antiAfkConn:Disconnect(); RT.antiAfkConn = nil end
end

if CFG.antiAfk then enableAntiAfk() end

-- ============================================================
-- Highlight pool + fire ring
-- ============================================================

local function ensureHighlightPool()
    if #HL.pool > 0 and HL.pool[1] and HL.pool[1].Parent then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    if not HL.folder or not HL.folder.Parent then
        HL.folder = Instance.new("Folder")
        HL.folder.Name = "AutoPlace_Highlights"
        HL.folder.Parent = cam
    end
    HL.pool = {}
    for i = 1, HL.SIZE do
        local h = Instance.new("Highlight")
        h.Name = "AP_HL_" .. i
        h.FillColor = CFG.placeHighlightColor
        h.FillTransparency = 0.5
        h.OutlineColor = CFG.placeHighlightColor
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Adornee = nil
        h.Enabled = false
        h.Parent = HL.folder
        HL.pool[i] = h
    end
end
local function destroyHighlightPool()
    if HL.folder then HL.folder:Destroy(); HL.folder = nil end
    HL.pool = {}
end
local function showPlaceHighlight(ghost)
    if not CFG.showPlaceHighlight or not ghost or not ghost.Parent then return end
    ensureHighlightPool()
    if #HL.pool == 0 then return end
    local h = HL.pool[HL.idx]
    if not h or not h.Parent then
        ensureHighlightPool()
        h = HL.pool[HL.idx]
        if not h or not h.Parent then return end
    end
    HL.idx = (HL.idx % HL.SIZE) + 1
    h.Enabled = false
    h.FillColor = CFG.placeHighlightColor
    h.OutlineColor = CFG.placeHighlightColor
    h.Adornee = ghost
    h.Enabled = true
    task.delay(HL.HOLD, function()
        if h and h.Parent and h.Adornee == ghost then
            h.Enabled = false; h.Adornee = nil
        end
    end)
end

local function destroyFireRing()
    if HL.ring then HL.ring:Destroy(); HL.ring = nil end
end
local function updateFireRing()
    if not CFG.showFireRing or not CFG.running then destroyFireRing(); return end
    local root = getRoot()
    if not root then destroyFireRing(); return end
    if not HL.ring then
        HL.ring = Instance.new("Part")
        HL.ring.Name = "AutoPlace_FireRing"
        HL.ring.Shape = Enum.PartType.Cylinder
        HL.ring.Material = Enum.Material.Neon
        HL.ring.CanCollide = false
        HL.ring.CanQuery = false
        HL.ring.CanTouch = false
        HL.ring.CastShadow = false
        HL.ring.Anchored = true
        HL.ring.Parent = workspace
    end
    local r = CFG.fireRadius
    HL.ring.Size = Vector3.new(0.15, r * 2, r * 2)
    HL.ring.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, math.rad(90))
    HL.ring.Color = CFG.fireRingColor
    HL.ring.Transparency = 0.75
end

-- ============================================================
-- Training
-- ============================================================

local trainState = {
    lastSpeedAnchor = 0, lastStrengthFire = 0,
    strengthEngaged = false, currentArea = nil,
}

local function partOf(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    end
end
local function getWallAmount()
    local gui = LocalPlayer.PlayerGui
    local left = gui and gui:FindFirstChild("Left")
    local inner = left and left:FindFirstChild("Left")
    local label = inner and inner:FindFirstChild("WallAmount")
    if not label then return 0 end
    return tonumber(label.Text:match("%d+")) or 0
end
local function getTrainingRequirement(plot)
    local anchor = plot:FindFirstChild("LabelAnchor")
    if not anchor then return 0 end
    local bb = anchor:FindFirstChildWhichIsA("BillboardGui", true)
    if not bb then return 0 end
    local req = bb:FindFirstChild("Requirement", true)
    if not req then return 0 end
    return tonumber(req.Text:match("%d+")) or 0
end
local function getBestTrainingArea()
    local areaRoot = workspace:FindFirstChild("TrainingArea")
    if not areaRoot then return nil end
    local wall = getWallAmount()
    local best, bestReq = nil, -1
    for _, v in ipairs(areaRoot:GetDescendants()) do
        if v:IsA("Model")
            and v:FindFirstChild("Treadmill")
            and v:FindFirstChild("BenchPress")
            and v:FindFirstChild("LabelAnchor")
        then
            local req = getTrainingRequirement(v)
            if wall >= req and req > bestReq then
                best, bestReq = v, req
            end
        end
    end
    if not best then best = areaRoot:FindFirstChild("Plot_Free") end
    trainState.currentArea = best
    return best
end
local function getBenchPrompt(plot)
    local bench = plot and plot:FindFirstChild("BenchPress")
    if not bench then return nil, nil end
    return bench, bench:FindFirstChildWhichIsA("ProximityPrompt", true)
end
local function getTreadmill(plot) return plot and plot:FindFirstChild("Treadmill") end

local function firePrompt(prompt)
    if not prompt then return false end
    if type(fireproximityprompt) == "function" then
        local ok = pcall(fireproximityprompt, prompt)
        if ok then return true end
    end
    return pcall(function()
        if prompt.HoldDuration and prompt.HoldDuration > 0 then
            prompt:InputHoldBegin(); task.wait(prompt.HoldDuration + 0.05); prompt:InputHoldEnd()
        else
            prompt:InputHoldBegin(); task.wait(0.05); prompt:InputHoldEnd()
        end
    end)
end
local function teleportNear(obj, offset)
    local root = getRoot()
    local part = obj and partOf(obj)
    if not root or not part then return end
    local base = part.Position
    local off = offset or Vector3.new(0, 3, 4)
    root.CFrame = CFrame.new(base + off, base)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    forceHumanoidWake()
end
local function teleportOnto(obj, heightOffset)
    local root = getRoot()
    local part = obj and partOf(obj)
    if not root or not part then return end
    local top = part.Position + Vector3.new(0, (part.Size.Y / 2) + (heightOffset or 3), 0)
    root.CFrame = CFrame.new(top, top + root.CFrame.LookVector)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    forceHumanoidWake()
end

local function runTraining()
    if not (CFG.trainStrength or CFG.trainSpeed) then return false end
    local plot = trainState.currentArea
    if not plot or not plot.Parent then plot = getBestTrainingArea() end
    if not plot then return false end
    local now = os.clock()
    local did = false
    if CFG.trainSpeed then
        local tPart = partOf(getTreadmill(plot))
        if tPart and now - trainState.lastSpeedAnchor > 1.0 then
            trainState.lastSpeedAnchor = now
            disableFlight()
            teleportOnto(getTreadmill(plot), CFG.trainSpeedAnchorOffset)
            did = true
        end
    end
    if CFG.trainStrength then
        local bench, prompt = getBenchPrompt(plot)
        local benchPart = partOf(bench)
        if benchPart then
            local root = getRoot()
            if root then
                local dist = (root.Position - benchPart.Position).Magnitude
                if (not trainState.strengthEngaged) or dist > CFG.trainReengageDist then
                    if dist > 8 then
                        disableFlight()
                        teleportNear(bench, Vector3.new(0, 3, 4))
                        task.wait(0.15)
                    end
                    if prompt then
                        firePrompt(prompt)
                        trainState.strengthEngaged = true
                    end
                    did = true
                end
            end
        end
    end
    return did
end
local function resetTrainingEngagement() trainState.strengthEngaged = false end

local function trainTargetsMet()
    local str = tonumber(LocalPlayer:GetAttribute("Strength")) or 0
    local spd = tonumber(LocalPlayer:GetAttribute("Speed")) or 0
    local sMet = (not CFG.autoTrainStrengthOn) or str >= CFG.autoTrainStrengthTarget
    local pMet = (not CFG.autoTrainSpeedOn)    or spd >= CFG.autoTrainSpeedTarget
    return sMet, pMet, str, spd
end

-- ============================================================
-- Boost zone (Hot Springs)
-- ============================================================

local hsState = {
    isOpen = false, secondsLeft = 0, multiplier = 1,
    wallEnd = 0, gymEnd = 0,
    wallActive = false, gymActive = false, wallMult = 1, gymMult = 1,
    hasZone = false, zoneCFrame = nil,
    inSprings = false, savedCFrame = nil, enteredAt = 0, reason = nil,
}

local function refreshHotSprings()
    local now = workspace:GetServerTimeNow()
    local wallEnd = GreatWall:GetAttribute("WallBoostEnd") or 0
    local gymEnd  = GreatWall:GetAttribute("GymBoostEnd")  or 0
    local wallActive = wallEnd > now
    local gymActive  = gymEnd  > now
    local wallMult = wallActive and (GreatWall:GetAttribute("WallBoostMult") or 2) or 1
    local gymMult  = gymActive  and (GreatWall:GetAttribute("GymBoostMult")  or 2) or 1
    hsState.wallEnd, hsState.gymEnd = wallEnd, gymEnd
    hsState.wallActive, hsState.gymActive = wallActive, gymActive
    hsState.wallMult, hsState.gymMult = wallMult, gymMult
    local maxEnd = math.max(wallEnd, gymEnd)
    hsState.secondsLeft = math.max(0, maxEnd - now)
    hsState.isOpen = maxEnd > now
    hsState.multiplier = hsState.isOpen and math.max(wallMult, gymMult) or 1
    local zone = workspace:FindFirstChild("HotSprings")
    zone = zone and zone:FindFirstChild("RelaxZone")
    if zone and zone:IsA("BasePart") then
        hsState.hasZone = true; hsState.zoneCFrame = zone.CFrame
    else
        hsState.hasZone = false
    end
end
local function formatClock(sec)
    sec = math.max(0, math.floor(sec or 0))
    return ("%d:%02d"):format(sec // 60, sec % 60)
end
local function teleportToHotSprings(reason)
    if not hsState.hasZone then return false end
    local root = getRoot()
    if not root then return false end
    hsState.savedCFrame = root.CFrame
    local target = hsState.zoneCFrame.Position + Vector3.new(0, CFG.hsTeleportYOffset, 0)
    root.CFrame = CFrame.new(target, target + root.CFrame.LookVector)
    hsState.inSprings = true
    hsState.enteredAt = os.clock()
    hsState.reason = reason or "manual"
    return true
end
local function teleportBackFromHotSprings()
    local root = getRoot()
    if not root then hsState.inSprings = false; hsState.reason = nil; return end
    if hsState.savedCFrame then root.CFrame = hsState.savedCFrame else dropToGround() end
    hsState.inSprings = false
    hsState.reason = nil
end

-- ============================================================
-- Wall tiers
-- ============================================================

local function getTiers()
    if not WallTiersModule or not WallTiersModule.List then return {} end
    return WallTiersModule.List
end
local function currentTier() return Config and (tonumber(Config.Tier) or 1) or 1 end
local function tierName(i)
    local t = getTiers()[i]
    return t and (t.Name or t.Short or ("Wall " .. i)) or ("Wall " .. i)
end
local function tierGymMult(i)
    local t = getTiers()[i]; return t and t.Reward and t.Reward.Gym or 1
end
local function tierCoins(i)
    local t = getTiers()[i]; return t and t.Reward and t.Reward.Coins or 0
end
local function tierPassesFilter()
    if not CFG.tierFilterOn then return true end
    return currentTier() >= CFG.tierFilterMin
end

-- ============================================================
-- Section markers
-- ============================================================

local SectionViz = {
    enabled = false, folder = nil, markers = {}, maxDistance = 800, yBase = nil,
    lastUpdate = 0, INTERVAL = 0.4, nearOnly = true, nearRadius = 3,
    hideComplete = false, scaleByDist = true, baseX = 160, baseY = 70,
}

local function targetLayers()
    if Config and type(Config.WallHeight) == "number" then return Config.WallHeight end
    local ti = Config and Config.TierInfo
    if ti and type(ti.WallHeight) == "number" then return ti.WallHeight end
    return 20
end
local function destroySectionViz()
    if SectionViz.folder then SectionViz.folder:Destroy(); SectionViz.folder = nil end
    SectionViz.markers = {}
end
local function buildSectionViz()
    destroySectionViz()
    if not STAGES then return end
    local folder = Instance.new("Folder")
    folder.Name = "AutoPlace_SectionViz"
    folder.Parent = workspace
    SectionViz.folder = folder
    local bw, bh = SectionViz.baseX, SectionViz.baseY
    for i, v in ipairs(STAGES) do
        local part = Instance.new("Part")
        part.Anchored = true; part.CanCollide = false
        part.CanQuery = false; part.CanTouch = false
        part.CastShadow = false; part.Transparency = 1
        part.Size = Vector3.new(0.5, 0.5, 0.5)
        part.Parent = folder
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.fromOffset(bw, bh)
        bb.AlwaysOnTop = true; bb.LightInfluence = 0
        bb.MaxDistance = SectionViz.maxDistance
        bb.Adornee = part; bb.Parent = part
        local bg = Instance.new("Frame")
        bg.Size = UDim2.fromScale(1, 1)
        bg.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
        bg.BackgroundTransparency = 0.1; bg.BorderSizePixel = 0
        bg.Parent = bb
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", bg)
        stroke.Color = Color3.fromRGB(60, 65, 82); stroke.Thickness = 1.5
        local nl = Instance.new("TextLabel")
        nl.BackgroundTransparency = 1
        nl.Position = UDim2.new(0, 0, 0, 3); nl.Size = UDim2.new(1, 0, 0, 15)
        nl.Font = Enum.Font.GothamBold; nl.TextSize = 11
        nl.TextColor3 = Color3.fromRGB(255, 226, 120)
        nl.Text = ("[%d] %s"):format(i, v.name or "Section")
        nl.Parent = bg
        local sl = Instance.new("TextLabel")
        sl.BackgroundTransparency = 1
        sl.Position = UDim2.new(0, 0, 0, 19); sl.Size = UDim2.new(1, 0, 0, 13)
        sl.Font = Enum.Font.GothamBold; sl.TextSize = 10
        sl.TextColor3 = Color3.fromRGB(180, 190, 210)
        sl.Text = "PENDING"; sl.Parent = bg
        local barBg = Instance.new("Frame")
        barBg.Position = UDim2.new(0, 8, 0, 34)
        barBg.Size = UDim2.new(1, -16, 0, 9)
        barBg.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
        barBg.BorderSizePixel = 0; barBg.Parent = bg
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 3)
        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.fromScale(0, 1)
        barFill.BackgroundColor3 = Color3.fromRGB(80, 160, 240)
        barFill.BorderSizePixel = 0; barFill.Parent = barBg
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 3)
        local pl = Instance.new("TextLabel")
        pl.BackgroundTransparency = 1
        pl.Position = UDim2.new(0, 0, 0, 46); pl.Size = UDim2.new(1, 0, 0, 15)
        pl.Font = Enum.Font.Code; pl.TextSize = 10
        pl.TextColor3 = Color3.fromRGB(200, 210, 230)
        pl.Text = "L0 / 20  (0%)"; pl.Parent = bg
        SectionViz.markers[i] = { part=part, bb=bb, stroke=stroke, name=nl, status=sl, barFill=barFill, pct=pl }
    end
end
local function updateSectionViz()
    if not SectionViz.enabled or not SectionViz.folder then return end
    local now = os.clock()
    if now - SectionViz.lastUpdate < SectionViz.INTERVAL then return end
    SectionViz.lastUpdate = now
    local cam = workspace.CurrentCamera
    local camPos = cam and cam.CFrame.Position
    local currentStage = GreatWall:GetAttribute("Stage") or 1
    local wallHeight = targetLayers()
    local wallBaseY = SectionViz.yBase or (ORIGIN_Y + 3)
    local zFace = defaultZ()
    local root = getRoot()
    local playerSec = root and sectionOf(root.Position.X) or 0
    for i, m in pairs(SectionViz.markers) do
        if not m.part or not m.part.Parent then
            SectionViz.markers[i] = nil
        else
            local v = STAGES and STAGES[i]
            if v then
                local c0, c1 = tonumber(v.x0) or 0, tonumber(v.x1) or 0
                local cx = columnWorldX((c0 + c1) / 2)
                local worldPos = Vector3.new(cx, wallBaseY, zFace)
                m.part.CFrame = CFrame.new(worldPos)
                local current = tonumber(GreatWall:GetAttribute("S" .. i .. "Layer")) or 0
                local target = wallHeight
                local statusText, statusColor, barColor, isComplete
                if target > 0 and current >= target then
                    statusText, statusColor = "COMPLETE", Color3.fromRGB(80, 220, 120)
                    barColor = Color3.fromRGB(80, 220, 120); isComplete = true
                elseif current > 0 then
                    statusText, statusColor = "BUILDING", Color3.fromRGB(240, 200, 80)
                    barColor = Color3.fromRGB(240, 200, 80)
                elseif i < currentStage then
                    statusText, statusColor = "COMPLETE", Color3.fromRGB(80, 220, 120)
                    barColor = Color3.fromRGB(80, 220, 120); current = target; isComplete = true
                elseif i == currentStage then
                    statusText, statusColor = "BUILDING", Color3.fromRGB(240, 200, 80)
                    barColor = Color3.fromRGB(240, 200, 80)
                else
                    statusText, statusColor = "PENDING", Color3.fromRGB(140, 150, 170)
                    barColor = Color3.fromRGB(80, 160, 240)
                end
                local show = true
                if SectionViz.nearOnly and playerSec > 0 and math.abs(i - playerSec) > SectionViz.nearRadius then show = false end
                if show and SectionViz.hideComplete and isComplete then show = false end
                if show and camPos and SectionViz.maxDistance > 0 then
                    local dx, dy, dz = camPos.X - cx, camPos.Y - wallBaseY, camPos.Z - zFace
                    if dx*dx + dy*dy + dz*dz > SectionViz.maxDistance * SectionViz.maxDistance then show = false end
                end
                if m.bb.Enabled ~= show then m.bb.Enabled = show end
                if show then
                    local scale = 1
                    if SectionViz.scaleByDist and camPos then
                        local d = (camPos - worldPos).Magnitude
                        scale = math.clamp(1 - (d - 80) / 700, 0.45, 1)
                    end
                    local sx, sy = SectionViz.baseX * scale, SectionViz.baseY * scale
                    if math.abs(m.bb.AbsoluteSize.X - sx) > 4 then
                        m.bb.Size = UDim2.fromOffset(sx, sy)
                    end
                end
                local pct = target > 0 and math.clamp(current / target, 0, 1) or 0
                m.name.Text = ("[%d] %s"):format(i, v.name or "Section")
                m.status.Text = statusText
                m.status.TextColor3 = statusColor
                m.barFill.Size = UDim2.fromScale(pct, 1)
                m.barFill.BackgroundColor3 = barColor
                m.pct.Text = ("L%d / %d  (%d%%)"):format(current, target, math.floor(pct * 100 + 0.5))
                if i == currentStage then
                    m.stroke.Color = Color3.fromRGB(255, 226, 120); m.stroke.Thickness = 2.5
                else
                    m.stroke.Color = Color3.fromRGB(60, 65, 82); m.stroke.Thickness = 1.5
                end
            end
        end
    end
end

-- ============================================================
-- Ghost list
-- ============================================================

local function collectGhosts()
    local out = {}
    local now = os.clock()
    for _, part in ipairs(CollectionService:GetTagged("WallGhost")) do
        if part:IsA("BasePart") and part.Parent and not GL.fired[part] then
            local t = GL.inflight[part]
            if not (t and (now - t) < CFG.inflightTimeout) then
                if t then GL.inflight[part] = nil end
                local s, l, i = part:GetAttribute("S"), part:GetAttribute("L"), part:GetAttribute("I")
                if s and l and i then
                    out[#out + 1] = { part = part, s = s, l = l, i = i, pos = part.Position }
                end
            end
        end
    end
    return out
end

local function rebuildList()
    GL.s, GL.l, GL.i, GL.parts = {}, {}, {}, {}
    local entries = collectGhosts()
    local root = getRoot()
    if root and #entries > 1 then
        local pp = root.Position
        for _, e in ipairs(entries) do
            local dx, dy, dz = pp.X - e.pos.X, pp.Y - e.pos.Y, pp.Z - e.pos.Z
            e.d2 = dx*dx + dy*dy + dz*dz
        end
        table.sort(entries, function(a, b) return a.d2 < b.d2 end)
    end
    for _, e in ipairs(entries) do
        GL.s[#GL.s + 1] = e.s
        GL.l[#GL.l + 1] = e.l
        GL.i[#GL.i + 1] = e.i
        GL.parts[#GL.parts + 1] = e.part
    end
    GL.dirty = false
end

CollectionService:GetInstanceAddedSignal("WallGhost"):Connect(function(p)
    if p then
        GL.fired[p] = nil; GL.inflight[p] = nil
        if CFG.cameraSeeThrough then camSetIgnore(p, true) end
    end
    GL.dirty = true
    if GL.cluster and p and p:IsA("BasePart") and p.Parent then
        local dx = p.Position.X - GL.cluster.anchorPos.X
        local dy = p.Position.Y - GL.cluster.anchorPos.Y
        local dz = p.Position.Z - GL.cluster.anchorPos.Z
        if dx*dx + dy*dy + dz*dz <= CFG.clusterRadius * CFG.clusterRadius then
            GL.dirty = true
        end
    end
end)
CollectionService:GetInstanceRemovedSignal("WallGhost"):Connect(function(p)
    if p then GL.fired[p] = nil; GL.inflight[p] = nil end
    GL.dirty = true
end)

local function pickNearest(ref, filter)
    if not ref then return nil end
    local best, bestD = nil, math.huge
    for i = 1, #GL.parts do
        local g = GL.parts[i]
        if g and g.Parent and (not filter or filter(g)) then
            local d = (g.Position - ref).Magnitude
            if d < bestD then bestD = d; best = g end
        end
    end
    return best
end
local function anyPasses(filter)
    if not filter then return true end
    for i = 1, #GL.parts do
        local g = GL.parts[i]
        if g and g.Parent and filter(g) then return true end
    end
    return false
end
local function modeFilterAndRef(playerPos)
    if CFG.placeMode == "nearest" or not GL.lastPlaced then return playerPos, nil end
    local ref = GL.lastPlaced
    if CFG.placeMode == "section" then
        local s = sectionOf(ref.X)
        return ref, function(g) return sectionOf(g.Position.X) == s end
    elseif CFG.placeMode == "column" then
        local c = columnOf(ref.X)
        return ref, function(g) return columnOf(g.Position.X) == c end
    end
    return playerPos, nil
end
local function clusterGhosts(anchorPos)
    local CR = CFG.clusterRadius
    local cr2 = CR * CR
    local out = {}
    for i = 1, #GL.parts do
        local g = GL.parts[i]
        if g and g.Parent then
            local dx = g.Position.X - anchorPos.X
            local dy = g.Position.Y - anchorPos.Y
            local dz = g.Position.Z - anchorPos.Z
            if dx*dx + dy*dy + dz*dz <= cr2 then out[#out + 1] = g end
        end
    end
    return out
end
local function clusterInflightCount(anchorPos)
    local CR = CFG.clusterRadius
    local cr2 = CR * CR
    local now = os.clock()
    local n = 0
    for g, t in pairs(GL.inflight) do
        if g and g.Parent and (now - t) < CFG.inflightTimeout then
            local dx = g.Position.X - anchorPos.X
            local dy = g.Position.Y - anchorPos.Y
            local dz = g.Position.Z - anchorPos.Z
            if dx*dx + dy*dy + dz*dz <= cr2 then n = n + 1 end
        end
    end
    return n
end
local function bfsOrder(ghosts, anchorPos)
    if #ghosts == 0 then return {} end
    local map = {}
    for _, g in ipairs(ghosts) do
        local c, l, z = cellOf(g)
        map[keyOf(c, l, z)] = g
    end
    local startKey, bestD = nil, math.huge
    for _, g in ipairs(ghosts) do
        local d = (g.Position - anchorPos).Magnitude
        if d < bestD then
            bestD = d
            local c, l, z = cellOf(g)
            startKey = keyOf(c, l, z)
        end
    end
    if not startKey then return ghosts end
    local order = {}
    local seen = { [startKey] = true }
    local queue = { startKey }
    local head = 1
    while head <= #queue do
        local key = queue[head]; head = head + 1
        local g = map[key]
        if g then order[#order + 1] = g end
        local c, l, z = key:match("^(%-?%d+):(%-?%d+):(%-?%d+)$")
        if c then
            c, l, z = tonumber(c), tonumber(l), tonumber(z)
            local nbrs = { keyOf(c+1, l, z), keyOf(c-1, l, z), keyOf(c, l+1, z), keyOf(c, l-1, z) }
            for _, nk in ipairs(nbrs) do
                if not seen[nk] and map[nk] then
                    seen[nk] = true
                    queue[#queue + 1] = nk
                end
            end
        end
    end
    for _, g in ipairs(ghosts) do
        local c, l, z = cellOf(g)
        local k = keyOf(c, l, z)
        if not seen[k] then seen[k] = true; order[#order + 1] = g end
    end
    return order
end
local function rebuildClusterOrder()
    if not GL.cluster then return end
    local ghosts = clusterGhosts(GL.cluster.anchorPos)
    GL.cluster.order = bfsOrder(ghosts, GL.cluster.anchorPos)
    local idx = 1
    while idx <= #GL.cluster.order
        and (GL.fired[GL.cluster.order[idx]] or GL.inflight[GL.cluster.order[idx]])
    do
        idx = idx + 1
    end
    GL.cluster.orderIdx = math.min(idx, #GL.cluster.order + 1)
end

-- ============================================================
-- Server feedback
-- ============================================================

local Fx = Remotes:WaitForChild("Fx", 5)
if Fx then
    Fx.OnClientEvent:Connect(function(kind, a)
        if kind == "SlowDown" then
            RATE.pausedUntil = os.clock() + 1.0
            if CFG.adaptive then
                RATE.current = math.max(CFG.minRate, math.floor(RATE.current * 0.6))
            end
        elseif kind == "PlaceAck" then
            local rec = GL.pending[a]
            if rec then
                analytics.acks = analytics.acks + 1
                analytics.acksThisSec = analytics.acksThisSec + 1
                analytics.lastAckAt = os.clock()
                if rec.ghost then
                    GL.inflight[rec.ghost] = nil
                    GL.fired[rec.ghost] = true
                end
                if rec.pos then GL.lastPlaced = rec.pos end
                GL.pending[a] = nil
            end
        end
    end)
end

-- ============================================================
-- Refill
-- ============================================================

local refilling = false
local function readCarry()
    local gui = LocalPlayer.PlayerGui
    local left = gui and gui:FindFirstChild("Left")
    local label
    if left then
        local inner = left:FindFirstChild("Left") or left:FindFirstChild("Inner")
        if inner then label = inner:FindFirstChild("CarryAmount") end
    end
    if not label then return 0, 0 end
    local a, b = label.Text:match("(%d+)/(%d+)")
    return tonumber(a) or 0, tonumber(b) or 0
end
local function groundUnder(pos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local hit = workspace:Raycast(pos, Vector3.new(0, -500, 0), params)
    return hit and hit.Position or pos - Vector3.new(0, 10, 0)
end
local function refillBlocks()
    if refilling then return end
    local root = getRoot()
    if not root or not Fill then return end
    local quarry = workspace:FindFirstChild("Quarry")
    local anchor = quarry and quarry:FindFirstChild("TitleAnchor")
    if not anchor then return end
    refilling = true
    local saved = root.CFrame
    local hadFlight = MOVE.vel ~= nil
    if hadFlight then disableFlight() end
    local dest = groundUnder(anchor.Position) + Vector3.new(0, CFG.refillGroundY, 0)
    root.CFrame = CFrame.new(dest, dest + root.CFrame.LookVector)
    forceHumanoidWake()
    task.wait(0.35)
    Fill:FireServer(1, true)
    task.wait(0.1)
    local start = os.clock()
    repeat
        task.wait(CFG.refillInterval)
        Fill:FireServer(1, false)
        local cur, max = readCarry()
        if cur >= max and max > 0 then break end
        if os.clock() - start > 20 then break end
    until false
    root.CFrame = saved
    forceHumanoidWake()
    if hadFlight then enableFlight() end
    refilling = false
end

-- ============================================================
-- Token bucket
-- ============================================================

local function primeBucket() RATE.bucket = math.min(RATE.current * 0.05, 6) end
local function refillTokens(dt) RATE.bucket = math.min(RATE.current * 0.5, RATE.bucket + RATE.current * dt) end
local function spendToken()
    if RATE.bucket >= 1 then RATE.bucket = RATE.bucket - 1; return true end
    return false
end

-- ============================================================
-- Fire routines
-- ============================================================

local function fireInRange()
    local root = getRoot()
    if not root then return 0, false end
    if CFG.placeInput == "key" then
        return (#GL.parts > 0) and 1 or 0, #GL.parts > 0
    end
    local effR2 = CFG.fireRadius * CFG.fireRadius
    local origin = root.Position
    local fired = 0
    local hasInRange = false
    local useInternal = (CFG.placeInput == "internal" and clientPlaceInto ~= nil)
    local useRemote   = (CFG.placeInput == "remote" or CFG.placeInput == "hybrid")
    local cap = (CFG.placeInput == "hybrid") and 4 or MAX_FIRES_PER_TICK

    local i = 1
    while i <= #GL.parts do
        if fired >= cap then break end
        local g = GL.parts[i]
        if not g or not g.Parent then
            table.remove(GL.parts, i); table.remove(GL.s, i); table.remove(GL.l, i); table.remove(GL.i, i)
        else
            local dx = g.Position.X - origin.X
            local dy = g.Position.Y - origin.Y
            local dz = g.Position.Z - origin.Z
            local d2 = dx*dx + dy*dy + dz*dz
            if d2 > effR2 then i = i + 1
            else
                hasInRange = true
                if not spendToken() then i = i + 1
                else
                    local success = false
                    if useInternal then
                        success = pcall(clientPlaceInto, g)
                    elseif useRemote then
                        GL.seq = GL.seq + 1
                        Place:FireServer(GL.s[i], GL.l[i], GL.i[i], GL.seq)
                        GL.inflight[g] = os.clock()
                        GL.pending[GL.seq] = { ghost = g, pos = g.Position, dist = math.sqrt(d2), at = os.clock() }
                        success = true
                    end
                    if success then
                        fired = fired + 1
                        analytics.fires = analytics.fires + 1
                        analytics.firesThisSec = analytics.firesThisSec + 1
                        analytics.lastFireAt = os.clock()
                        showPlaceHighlight(g)
                        table.remove(GL.parts, i); table.remove(GL.s, i); table.remove(GL.l, i); table.remove(GL.i, i)
                    else
                        i = i + 1
                    end
                end
            end
        end
    end
    return fired, hasInRange
end

local function fireClusterOrdered()
    if not GL.cluster then return 0, false, nil end
    if CFG.placeInput == "key" then
        return (#GL.parts > 0) and 1 or 0, false, nil
    end
    local order = GL.cluster.order
    local idx = GL.cluster.orderIdx
    local root = getRoot()
    if not root then return 0, false, nil end
    local origin = root.Position
    local r2 = CFG.fireRadius * CFG.fireRadius
    local fired = 0
    local nextOutOfRange = nil
    local useInternal = (CFG.placeInput == "internal" and clientPlaceInto ~= nil)
    local useRemote   = (CFG.placeInput == "remote" or CFG.placeInput == "hybrid")
    local cap = (CFG.placeInput == "hybrid") and 4 or MAX_FIRES_PER_TICK

    while idx <= #order and fired < cap do
        local g = order[idx]
        if not g or not g.Parent then idx = idx + 1
        elseif GL.fired[g] or GL.inflight[g] then idx = idx + 1
        else
            local dx = g.Position.X - origin.X
            local dy = g.Position.Y - origin.Y
            local dz = g.Position.Z - origin.Z
            local d2 = dx*dx + dy*dy + dz*dz
            if d2 > r2 then nextOutOfRange = g; break end
            if not spendToken() then nextOutOfRange = g; break end
            local success = false
            if useInternal then
                success = pcall(clientPlaceInto, g)
            elseif useRemote then
                GL.seq = GL.seq + 1
                Place:FireServer(g:GetAttribute("S"), g:GetAttribute("L"), g:GetAttribute("I"), GL.seq)
                GL.inflight[g] = os.clock()
                GL.pending[GL.seq] = { ghost = g, pos = g.Position, dist = math.sqrt(d2), at = os.clock() }
                success = true
            end
            if success then
                fired = fired + 1
                analytics.fires = analytics.fires + 1
                analytics.firesThisSec = analytics.firesThisSec + 1
                analytics.lastFireAt = os.clock()
                showPlaceHighlight(g)
            end
            idx = idx + 1
        end
    end
    GL.cluster.orderIdx = idx
    return fired, nextOutOfRange ~= nil, nextOutOfRange
end

-- ============================================================
-- Auto Upgrade
-- ============================================================

local function upgradeWanted(id)
    if #CFG.autoUpgradeIds == 0 then return true end
    for _, v in ipairs(CFG.autoUpgradeIds) do
        if v == id then return true end
    end
    return false
end
local function getUpgradeList()
    if not UpgradesTable then return {} end
    if type(UpgradesTable.List) == "table" then return UpgradesTable.List end
    return {}
end
local function nextPriceFor(up, level)
    local raw = (up.Costs and up.Costs[level + 1]) or nil
    if not raw then return nil end
    local price = raw
    if Config and type(Config.SalePrice) == "function" then
        local ok, p = pcall(Config.SalePrice, raw)
        if ok and type(p) == "number" then price = p end
    end
    local free = false
    if LocalPlayer:GetAttribute("FreeUpgrade") == true then
        if Config and type(Config.FreeUpgradeTarget) == "function" then
            local ok, match = pcall(Config.FreeUpgradeTarget, function(id)
                return LocalPlayer:GetAttribute("Up_" .. id) or 0
            end)
            if ok and match == up.Id then free = true end
        end
    end
    if not free
        and Config and Config.Tutorial
        and Config.Tutorial.FreeUpgrade == up.Id
        and level == 0
        and LocalPlayer:GetAttribute("TutorialDone") == false
    then
        free = true
    end
    if free then price = 0 end
    return price, raw, free
end

local function getShrineZone()
    local shrine = workspace:FindFirstChild("UpgradeShrine")
    return shrine and shrine:FindFirstChild("Zone")
end
local function inShrineZone()
    local zone = getShrineZone()
    local root = getRoot()
    if not zone or not root then return false end
    local dx = root.Position.X - zone.Position.X
    local dz = root.Position.Z - zone.Position.Z
    local radius = zone:GetAttribute("Radius") or 3
    if Vector3.new(dx, 0, dz).Magnitude > radius then return false end
    return math.abs(root.Position.Y - zone.Position.Y) < 8
end
local function tickShrineAutoEnter()
    local now = os.clock()
    local S = UPG.shrine

    -- If disabled mid-trip, return
    if not CFG.autoUpgradeOn or not CFG.autoUpgradeAutoShrine then
        if S.active and S.savedCFrame then
            local root = getRoot()
            if root then
                root.CFrame = S.savedCFrame
                forceHumanoidWake()
            end
            S.active = false
            S.savedCFrame = nil
            if CFG.running and CFG.useFlight then enableFlight() end
        end
        return
    end

    local root = getRoot()
    if not root then return end

    -- ---- Currently on a shrine trip ----
    if S.active then
        local bought   = (UPG.reason == "ok")
        local timedOut = (now - S.enteredAt) >= S.maxStay
        if not getShrineZone() then bought = false; timedOut = true end

        if bought or timedOut then
            if S.savedCFrame then root.CFrame = S.savedCFrame end
            forceHumanoidWake()
            -- Re-enable flight only if the builder is still running
            if CFG.running and CFG.useFlight then enableFlight() end
            S.active = false
            S.savedCFrame = nil
            S.lastVisit = now
        end
        return
    end

    -- ---- Not on a trip: decide whether to start one ----
    if UPG.reason ~= "far" then return end
    if now - S.lastVisit < S.cooldown then return end

    -- Don't rip the builder away mid-placement
    if CFG.running and not S.inZone and SM.phase ~= "idle" then return end

    local zone = getShrineZone()
    if not zone then return end

    -- Save position, kill flight, teleport, wake humanoid
    S.savedCFrame = root.CFrame
    S.enteredAt = now
    S.active = true
    S.inZone = true

    if CFG.useFlight then disableFlight() end  -- <-- KEY: stop holding us still

    local target = zone.Position + Vector3.new(0, 3, 0)
    root.CFrame = CFrame.new(target, target + root.CFrame.LookVector)

    task.wait()                -- let one heartbeat pass
    root.CFrame = CFrame.new(target, target + root.CFrame.LookVector)  -- reinforce
    forceHumanoidWake()
end

local function ensureUpgradeRemote()
    if UpgradeRemote then return true end
    local r = Remotes:FindFirstChild("Upgrade")
    if r then UpgradeRemote = r; return true end
    return false
end

local function ensureUpgradesTable()
    if UpgradesTable then return true end
    if Config and type(Config.Upgrades) == "table" then
        UpgradesTable = Config.Upgrades; return true
    end
    return false
end

local function tryAutoUpgrade(force)
    if not force and not CFG.autoUpgradeOn then return "disabled" end
    if not UpgradeRemote then return "no-remote" end
    if not UpgradesTable then return "no-list" end

    local list = getUpgradeList()
    if #list == 0 then return "no-list" end

    local now = os.clock()
    if not force and now - UPG.lastAt < CFG.autoUpgradeInterval then return "rate" end

    local coins = tonumber(LocalPlayer:GetAttribute("Coins")) or 0
    local walls = tonumber(LocalPlayer:GetAttribute("Walls")) or 0

    local function attempt(up)
        local level = tonumber(LocalPlayer:GetAttribute("Up_" .. up.Id)) or 0
        if up.Max and level >= up.Max then return false end
        if CFG.autoUpgradeRespectWalls and up.RequiresWalls and walls < up.RequiresWalls then
            return false
        end
        local price, _, isFree = nextPriceFor(up, level)
        if not price then return false end
        if not (isFree or coins >= price) then return false end

        local last = UPG.triedAt[up.Id] or 0
        if not force and now - last < 1.5 then return false end

        UPG.triedAt[up.Id] = now
        UPG.lastAt = now

        local ok, res = pcall(function() return UpgradeRemote:InvokeServer("Buy", up.Id) end)
        if not ok then
            UPG.reason = "invoke-error"
            log(("auto-upgrade invoke error: %s — %s"):format(up.Id, tostring(res)))
            return true
        end
        if type(res) == "table" and res.ok then
            UPG.reason = "ok"
            log(("auto-upgrade: %s -> L%d (%s%s)"):format(
                up.Id, level + 1,
                isFree and "free" or tostring(math.floor(price)),
                isFree and "" or " coins"))
            return true
        end
        local reason = (type(res) == "table" and res.reason) or "unknown"
        UPG.reason = reason
        if reason == "coins" then
            log(("auto-upgrade: %s needs %d more coins"):format(up.Id, math.floor((res.need or 0))))
        elseif reason == "locked" then
            log(("auto-upgrade: %s locked (needs %d walls)"):format(up.Id, res.need or 0))
        elseif reason ~= "far" and reason ~= "loading" then
            log(("auto-upgrade: %s rejected (%s)"):format(up.Id, tostring(reason)))
        end
        return true
    end

    for _, up in ipairs(list) do
        if up and up.Id and upgradeWanted(up.Id) then
            if attempt(up) then
                return UPG.reason or "ok"
            end
        end
    end
    return "nothing-affordable"
end

-- ============================================================
-- Admin / Mod detection
-- ============================================================

local function playerIsAdminOrMod(p)
    if not p then return false end
    if p:GetAttribute("IsAdmin") == true then return true end
    if p:GetAttribute("IsMod")   == true then return true end
    if Config and Config.Admins and Config.Admins[p.UserId] then return true end
    return false
end

local function leaveServer(reason)
    if RT.leaving then return end
    RT.leaving = true
    log("admin/mod detected -> leaving: " .. tostring(reason))
    pcall(function()
        Rayfield:Notify({
            Title = "Admin / Mod detected",
            Content = tostring(reason) .. " — leaving server",
            Duration = CFG.adminWarnSeconds,
        })
    end)
    task.wait(CFG.adminWarnSeconds)
    if CFG.adminLeaveMode == "kick-self" then
        pcall(function() LocalPlayer:Kick("admin/mod detected") end)
    end
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end

local function watchForAdmin(p)
    if p == LocalPlayer then return end
    task.spawn(function()
        for _ = 1, 8 do
            if playerIsAdminOrMod(p) then
                if CFG.adminDetectOn then
                    local tag = (p:GetAttribute("IsAdmin") == true and "IsAdmin")
                        or (p:GetAttribute("IsMod") == true and "IsMod")
                        or "Admins list"
                    leaveServer(p.Name .. " (" .. p.UserId .. ") [" .. tag .. "]")
                end
                return
            end
            task.wait(0.5)
        end
    end)
    p:GetAttributeChangedSignal("IsAdmin"):Connect(function()
        if CFG.adminDetectOn and p:GetAttribute("IsAdmin") == true then
            leaveServer(p.Name .. " (IsAdmin)")
        end
    end)
    p:GetAttributeChangedSignal("IsMod"):Connect(function()
        if CFG.adminDetectOn and p:GetAttribute("IsMod") == true then
            leaveServer(p.Name .. " (IsMod)")
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do watchForAdmin(p) end
Players.PlayerAdded:Connect(watchForAdmin)

-- ============================================================
-- Admin panel opener (bypass local gate)
-- ============================================================

local function getAdminPanel()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    return pg and pg:FindFirstChild("AdminPanel")
end
local function openAdminPanel()
    local wasAdmin = LocalPlayer:GetAttribute("IsAdmin")
    if wasAdmin ~= true then
        LocalPlayer:SetAttribute("IsAdmin", true)
        task.wait(0.05)
    end
    local panel = getAdminPanel()
    local t0 = os.clock()
    while os.clock() - t0 < 2 and not panel do
        task.wait(0.1)
        panel = getAdminPanel()
    end
    if wasAdmin ~= true then
        LocalPlayer:SetAttribute("IsAdmin", wasAdmin)
    end
    if panel then panel.Enabled = true; return true end
    return false, "panel not found"
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == CFG.adminPanelKey then
        local ok, reason = openAdminPanel()
        if not ok and CFG.verbose then log("admin panel: " .. tostring(reason)) end
    end
end)

-- ============================================================
-- State machine
-- ============================================================

local function applyMovementState()
    if CFG.running then
        if CFG.noclip then setNoclip(true) end
        if CFG.useFlight then enableFlight() else disableFlight() end
        cameraSeeThroughEnable()
        primeBucket()
        if CFG.placeInput == "key" or CFG.placeInput == "hybrid" then setM1Held(true) end
    else
        setM1Held(false)
        disableFlight()
        dropToGround()
        setNoclip(false)
        cameraSeeThroughDisable()
        destroyHighlightPool()
        destroyFireRing()
        GL.cluster = nil
        resetTrainingEngagement()
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    MOVE.saved = {}
    MOVE.attach, MOVE.vel = nil, nil
    task.wait(0.5)
    resetTrainingEngagement()
    if CFG.running then applyMovementState() end
end)

if CFG.cameraSeeThrough then cameraSeeThroughEnable() end

local function adaptTuning(now)
    if now - AUTO.lastAdapt < AUTO.PERIOD then return end
    AUTO.lastAdapt = now
    local f, a = 0, 0
    for _, s in ipairs(analytics.recent) do f = f + s.fires; a = a + s.acks end
    local ratio = f > 0 and (a / f) or nil
    if ratio and ratio < 0.85 then
        AUTO.settleTime = math.min(AUTO.MAX, AUTO.settleTime + AUTO.STEP)
    elseif (not ratio or ratio > 0.97) then
        AUTO.settleTime = math.max(AUTO.MIN, AUTO.settleTime - AUTO.STEP)
    end
end
local function regrowRate(now)
    if analytics.lastFireAt > 0 and now - analytics.lastFireAt > 2.0 then
        if RATE.current < CFG.rate then RATE.current = CFG.rate end
    end
    if now - RATE.lastRegrow > CFG.regrowEvery then
        RATE.lastRegrow = now
        if RATE.current < CFG.rate then
            RATE.current = math.min(CFG.rate, RATE.current + math.max(10, math.floor(CFG.rate * 0.25)))
        end
    end
end
local function tickAnalytics()
    local now = os.clock()
    if now - analytics.lastBucket >= 1 then
        table.insert(analytics.recent, { fires = analytics.firesThisSec, acks = analytics.acksThisSec })
        while #analytics.recent > analytics.RECENT do table.remove(analytics.recent, 1) end
        analytics.firesThisSec = 0
        analytics.acksThisSec = 0
        analytics.lastBucket = now
    end
    for k, v in pairs(GL.pending) do
        if now - v.at > CFG.pendingMaxAge then
            if v.ghost then GL.inflight[v.ghost] = nil end
            GL.pending[k] = nil
        end
    end
end

local function hotSpringsTick(now)
    refreshHotSprings()
    if hsState.inSprings then
        if hsState.reason == "manual" then
            if not hsState.isOpen and CFG.hsAuto then teleportBackFromHotSprings() end
            return true
        end
        local stayTime = now - hsState.enteredAt
        local canReturn = stayTime >= CFG.hsStayMin
        local expiring  = hsState.secondsLeft <= CFG.hsReturnBefore
        local closed    = not hsState.isOpen
        local belowFilter = CFG.boostFilterOn
            and hsState.multiplier < CFG.boostFilterMin
        if closed or belowFilter or (expiring and canReturn) then
            teleportBackFromHotSprings()
        end
        return true
    end
    if CFG.hsAuto and hsState.isOpen then
        local passes = true
        if CFG.boostFilterOn then
            passes = hsState.multiplier >= CFG.boostFilterMin
        end
        if passes then teleportToHotSprings("auto"); return true end
    end
    return false
end

-- ============================================================
-- Rayfield UI
-- ============================================================

local function safeCreateTab(name, icon)
    if not Window then return nil end
    if type(Window.CreateTab) == "function" then
        local ok, t = pcall(Window.CreateTab, Window, name, icon)
        if ok and t then return t end
        local ok2, t2 = pcall(Window.CreateTab, Window, name)
        if ok2 and t2 then return t2 end
    end
    if type(Window.Tab) == "function" then
        local ok, t = pcall(Window.Tab, Window, name)
        if ok and t then return t end
    end
    return nil
end

local TABS = {
    Building  = safeCreateTab("Building", 4483362458),
    Training  = safeCreateTab("Training", 4483362458),
    Stats     = safeCreateTab("Stats", 4483362458),
    Walls     = safeCreateTab("Walls", 4483362458),
    Visuals   = safeCreateTab("Visuals", 4483362458),
    Safety    = safeCreateTab("Safety", 4483362458),
    Changelog = safeCreateTab("Changelogs / Update", 4483362458),
}

local FALLBACKS = {
    CreateParagraph = { "CreateParagraph", "CreateLabel", "Paragraph", "Label" },
    CreateDropdown  = { "CreateDropdown", "Dropdown" },
    CreateSlider    = { "CreateSlider", "Slider" },
    CreateToggle    = { "CreateToggle", "Toggle" },
    CreateButton    = { "CreateButton", "Button" },
    CreateSection   = { "CreateSection", "Section" },
    CreateColorPicker = { "CreateColorPicker", "ColorPicker" },
}
local function UI(tab, method, cfg)
    if not tab then return nil end
    local names = FALLBACKS[method] or { method }
    for _, m in ipairs(names) do
        local fn = tab[m]
        if type(fn) == "function" then
            local ok, res = pcall(fn, tab, cfg)
            if ok then return res end
        end
    end
    return nil
end
local function makeParagraph(tab, title, content)
    local p = UI(tab, "CreateParagraph", { Title = title, Content = content })
    if p and type(p.Set) == "function" then return p end
    return nil
end

local PARA = {}

-- ---- Building tab ----
UI(TABS.Building, "CreateSection", "Main Control")
UI(TABS.Building, "CreateToggle", {
    Name = "Start auto-building", Tooltip = "Turn the bot on or off.",
    CurrentValue = false, Flag = "Enabled",
    Callback = function(v)
        CFG.running = v
        applyMovementState()
        log("building " .. (v and "started" or "stopped"))
    end,
})
UI(TABS.Building, "CreateSection", "Character")
UI(TABS.Building, "CreateToggle", {
    Name = "Walk through walls", CurrentValue = CFG.noclip, Flag = "Noclip",
    Callback = function(v) CFG.noclip = v; if CFG.running then setNoclip(v) end end,
})
UI(TABS.Building, "CreateToggle", {
    Name = "Camera sees through blocks", CurrentValue = CFG.cameraSeeThrough, Flag = "CamSeeThrough",
    Callback = function(v)
        CFG.cameraSeeThrough = v
        if v then cameraSeeThroughEnable() else cameraSeeThroughDisable() end
    end,
})
UI(TABS.Building, "CreateToggle", {
    Name = "Hover in the air", CurrentValue = CFG.useFlight, Flag = "UseFlight",
    Callback = function(v)
        CFG.useFlight = v
        if CFG.running then if v then enableFlight() else disableFlight() end end
    end,
})
UI(TABS.Building, "CreateToggle", {
    Name = "Anti-AFK", CurrentValue = CFG.antiAfk, Flag = "AntiAfk",
    Callback = function(v) CFG.antiAfk = v; if v then enableAntiAfk() else disableAntiAfk() end end,
})

UI(TABS.Building, "CreateSection", "Fill Strategy")
UI(TABS.Building, "CreateDropdown", {
    Name = "Ordering",
    Options = { "Closest first", "Whole section", "One column" },
    CurrentOption = { "Closest first" }, Flag = "PlaceMode",
    Callback = function(opt)
        if type(opt) ~= "table" or not opt[1] then return end
        local map = { ["Closest first"] = "nearest", ["Whole section"] = "section", ["One column"] = "column" }
        CFG.placeMode = map[opt[1]] or "nearest"
        GL.lastPlaced = nil; GL.dirty = true
    end,
})
UI(TABS.Building, "CreateDropdown", {
    Name = "Group size",
    Options = { "Single ghost", "Cluster of ghosts" },
    CurrentOption = { "Cluster of ghosts" }, Flag = "TargetMode",
    Callback = function(opt)
        if type(opt) ~= "table" or not opt[1] then return end
        CFG.targetMode = (opt[1] == "Single ghost") and "single" or "cluster"
        GL.cluster = nil
    end,
})
UI(TABS.Building, "CreateDropdown", {
    Name = "Travel method",
    Options = { "Instant teleport", "Fast walk", "Stay still" },
    CurrentOption = { "Instant teleport" }, Flag = "MoveMode",
    Callback = function(opt)
        if type(opt) ~= "table" or not opt[1] then return end
        local map = { ["Instant teleport"] = "teleport", ["Fast walk"] = "step", ["Stay still"] = "off" }
        CFG.moveMode = map[opt[1]] or "teleport"
    end,
})

UI(TABS.Building, "CreateSection", "Placement Method")
UI(TABS.Building, "CreateDropdown", {
    Name = "How to place blocks",
    Options = { "Direct (remote)", "Game controls (E key)", "Game function", "Hybrid (remote + E key)" },
    CurrentOption = { "Hybrid (remote + E key)" }, Flag = "PlaceInput",
    Callback = function(opt)
        if type(opt) ~= "table" or not opt[1] then return end
        local map = {
            ["Direct (remote)"] = "remote", ["Game controls (E key)"] = "key",
            ["Game function"] = "internal", ["Hybrid (remote + E key)"] = "hybrid",
        }
        local newMode = map[opt[1]] or "hybrid"
        if newMode == CFG.placeInput then return end
        if (CFG.placeInput == "key" or CFG.placeInput == "hybrid") and KEY.held then setM1Held(false) end
        CFG.placeInput = newMode
        log("method -> " .. newMode)
        if CFG.running and (newMode == "key" or newMode == "hybrid") then setM1Held(true) end
    end,
})

UI(TABS.Building, "CreateSection", "Speed & Range")
UI(TABS.Building, "CreateSlider", {
    Name = "Blocks per second", Range = { 20, 2000 }, Increment = 20,
    CurrentValue = CFG.rate, Flag = "Rate",
    Callback = function(v) CFG.rate = v; RATE.current = v; primeBucket() end,
})
UI(TABS.Building, "CreateSlider", {
    Name = "Reach", Range = { 5, 150 }, Increment = 5, Suffix = " studs",
    CurrentValue = CFG.fireRadius, Flag = "FireRadius",
    Callback = function(v) CFG.fireRadius = v end,
})
UI(TABS.Building, "CreateSlider", {
    Name = "Cluster size", Range = { 5, 100 }, Increment = 5, Suffix = " studs",
    CurrentValue = CFG.clusterRadius, Flag = "ClusterRadius",
    Callback = function(v) CFG.clusterRadius = v end,
})
UI(TABS.Building, "CreateSlider", {
    Name = "Walk speed", Range = { 50, 2000 }, Increment = 50, Suffix = " studs/s",
    CurrentValue = CFG.stepSpeed, Flag = "StepSpeed",
    Callback = function(v) CFG.stepSpeed = v end,
})

UI(TABS.Building, "CreateSection", "Refill")
UI(TABS.Building, "CreateToggle", {
    Name = "Auto-refill from quarry", CurrentValue = CFG.refillEnabled, Flag = "RefillEnabled",
    Callback = function(v) CFG.refillEnabled = v end,
})

UI(TABS.Building, "CreateSection", "Auto Upgrade")
UI(TABS.Building, "CreateToggle", {
    Name = "Auto-buy upgrades when affordable",
    Tooltip = "Buys the next level of any upgrade your coins can cover (uses the game's own Upgrade remote).",
    CurrentValue = CFG.autoUpgradeOn, Flag = "AutoUpgrade",
    Callback = function(v) CFG.autoUpgradeOn = v end,
})
UI(TABS.Building, "CreateToggle", {
    Name = "Auto-enter shrine zone",
    CurrentValue = CFG.autoUpgradeAutoShrine, Flag = "AutoUpgradeShrine",
    Callback = function(v) CFG.autoUpgradeAutoShrine = v end,
})
UI(TABS.Building, "CreateToggle", {
    Name = "Respect wall requirements",
    CurrentValue = CFG.autoUpgradeRespectWalls, Flag = "AutoUpgradeWalls",
    Callback = function(v) CFG.autoUpgradeRespectWalls = v end,
})
UI(TABS.Building, "CreateSlider", {
    Name = "Upgrade check interval", Range = { 0.2, 3 }, Increment = 0.1, Suffix = "s",
    CurrentValue = CFG.autoUpgradeInterval, Flag = "AutoUpgradeRate",
    Callback = function(v) CFG.autoUpgradeInterval = v end,
})
UI(TABS.Building, "CreateParagraph", {
    Title = "Auto-upgrade reasons",
    Content = "ok = bought | coins = not enough | locked = needs more walls | far = not in shrine zone | loading = server still loading your save.",
})
UI(TABS.Building, "CreateButton", {
    Name = "Upgrade everything affordable now",
    Callback = function()
        -- Guard: remote / list not loaded yet
        ensureUpgradeRemote()
        ensureUpgradesTable()
        if not UpgradeRemote then
            pcall(function()
                Rayfield:Notify({ Title = "Auto Upgrade",
                    Content = "Upgrade remote not loaded yet — try again in a few seconds.",
                    Duration = 5 })
            end)
            return
        end
        if not UpgradesTable or #getUpgradeList() == 0 then
            pcall(function()
                Rayfield:Notify({ Title = "Auto Upgrade",
                    Content = "Upgrades list not loaded yet — try again in a few seconds.",
                    Duration = 5 })
            end)
            return
        end

        -- Walk into the shrine zone so the server accepts the buy
        local root = getRoot()
        if root and not inShrineZone() then
            local zone = getShrineZone()
            if zone then
                local target = zone.Position + Vector3.new(0, 3, 0)
                root.CFrame = CFrame.new(target, target + root.CFrame.LookVector)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                task.wait(0.2)
            end
        end

        UPG.lastAt = 0
        local result = tryAutoUpgrade(true)

        -- Pretty feedback
        local msg
        if type(result) == "table" then
            msg = "Result: " .. tostring(result.reason or "?")
        elseif result == "ok" then
            msg = "Bought the next affordable upgrade."
        elseif result == "nothing-affordable" then
            msg = "No upgrade is affordable right now."
        elseif result == "no-remote" then
            msg = "Upgrade remote not available."
        elseif result == "no-list" then
            msg = "Upgrades list empty."
        elseif result == "coins" then
            msg = "Not enough coins."
        elseif result == "locked" then
            msg = "Upgrade locked (needs more walls)."
        elseif result == "far" then
            msg = "Out of shrine zone — move closer and retry."
        elseif result == "loading" then
            msg = "Server still loading your save."
        else
            msg = "Result: " .. tostring(result)
        end
        pcall(function()
            Rayfield:Notify({
                Title = "Auto Upgrade",
                Content = msg,
                Duration = 5,
            })
        end)
        log("manual upgrade: " .. tostring(result))
    end,
})

-- ---- Training tab ----
UI(TABS.Training, "CreateSection", "Auto Training")
UI(TABS.Training, "CreateParagraph", {
    Title = "About",
    Content = "Speed: stand on the treadmill. Strength: stand at the bench and fire its prompt once.",
})
UI(TABS.Training, "CreateToggle", {
    Name = "Train strength", CurrentValue = CFG.trainStrength, Flag = "TrainStrength",
    Callback = function(v) CFG.trainStrength = v; trainState.strengthEngaged = false end,
})
UI(TABS.Training, "CreateToggle", {
    Name = "Train speed", CurrentValue = CFG.trainSpeed, Flag = "TrainSpeed",
    Callback = function(v) CFG.trainSpeed = v; trainState.lastSpeedAnchor = 0 end,
})
UI(TABS.Training, "CreateToggle", {
    Name = "Pause building while training", CurrentValue = CFG.trainPauseBuild, Flag = "TrainPause",
    Callback = function(v) CFG.trainPauseBuild = v end,
})
UI(TABS.Training, "CreateSlider", {
    Name = "Re-fire when this far away", Range = { 5, 40 }, Increment = 1, Suffix = " studs",
    CurrentValue = CFG.trainReengageDist, Flag = "TrainReengage",
    Callback = function(v) CFG.trainReengageDist = v end,
})

UI(TABS.Training, "CreateSection", "Training Targets (client attributes)")
UI(TABS.Training, "CreateToggle", {
    Name = "Stop strength at target",
    CurrentValue = CFG.autoTrainStrengthOn, Flag = "AutoStrOn",
    Callback = function(v) CFG.autoTrainStrengthOn = v end,
})
UI(TABS.Training, "CreateSlider", {
    Name = "Strength target", Range = { 100, 5000 }, Increment = 50,
    CurrentValue = CFG.autoTrainStrengthTarget, Flag = "AutoStrTarget",
    Callback = function(v) CFG.autoTrainStrengthTarget = v end,
})
UI(TABS.Training, "CreateToggle", {
    Name = "Stop speed at target",
    CurrentValue = CFG.autoTrainSpeedOn, Flag = "AutoSpdOn",
    Callback = function(v) CFG.autoTrainSpeedOn = v end,
})
UI(TABS.Training, "CreateSlider", {
    Name = "Speed target", Range = { 100, 5000 }, Increment = 50,
    CurrentValue = CFG.autoTrainSpeedTarget, Flag = "AutoSpdTarget",
    Callback = function(v) CFG.autoTrainSpeedTarget = v end,
})

UI(TABS.Training, "CreateSection", "Training Area")
PARA.trainingInfo = makeParagraph(TABS.Training, "Current area", "Reading...")
UI(TABS.Training, "CreateButton", {
    Name = "Refresh best area now",
    Callback = function()
        local area = getBestTrainingArea()
        local txt
        if area then
            txt = ("Using: %s\nRequirement: %d   Blocks built: %d"):format(
                area.Name, getTrainingRequirement(area), getWallAmount())
        else
            txt = "(no training area found)"
        end
        if PARA.trainingInfo then
            pcall(function() PARA.trainingInfo:Set({ Title = "Current area", Content = txt }) end)
        end
    end,
})

UI(TABS.Training, "CreateSection", "Boost Zone")
PARA.hsInfo = makeParagraph(TABS.Training, "Current boost", "Reading...")
UI(TABS.Training, "CreateButton", {
    Name = "Go to boost zone",
    Callback = function()
        refreshHotSprings()
        if not hsState.hasZone then log("boost zone not found"); return end
        teleportToHotSprings("manual")
    end,
})
UI(TABS.Training, "CreateButton", {
    Name = "Come back", Callback = teleportBackFromHotSprings,
})
UI(TABS.Training, "CreateToggle", {
    Name = "Auto-travel to boost zone", CurrentValue = CFG.hsAuto, Flag = "HsAuto",
    Callback = function(v)
        CFG.hsAuto = v
        if not v and hsState.inSprings and hsState.reason == "auto" then teleportBackFromHotSprings() end
    end,
})

UI(TABS.Training, "CreateSection", "Boost Zone Filter")
UI(TABS.Training, "CreateToggle", {
    Name = "Only travel above threshold", CurrentValue = CFG.boostFilterOn, Flag = "BoostFilter",
    Callback = function(v) CFG.boostFilterOn = v end,
})

do
    local seen, opts = {}, {}
    local tiers = (WallTiersModule and WallTiersModule.List) or {}
    for _, t in ipairs(tiers) do
        local g = t.Reward and t.Reward.Gym
        if type(g) == "number" and not seen[g] then
            seen[g] = true
            opts[#opts + 1] = g
        end
    end
    table.sort(opts)
    -- Fallback if WallTiersModule didn't load
    if #opts == 0 then
        opts = { 1.25, 1.5, 1.75, 2, 2.5, 3, 4, 5 }
    end

    local labels = {}
    for i, v in ipairs(opts) do
        -- WallTiers.mult is the game's own formatter (strips trailing zeros)
        local pretty = WallTiersModule and WallTiersModule.mult
            and WallTiersModule.mult(v) or tostring(v)
        labels[i] = pretty .. "x"
    end

    -- Match current CFG value to a label
    local current = tostring(CFG.boostFilterMin) .. "x"
    local currentMatch = labels[1]
    for _, l in ipairs(labels) do
        if l == current then currentMatch = l; break end
    end

    UI(TABS.Training, "CreateDropdown", {
        Name = "Minimum wall-tier multiplier",
        Tooltip = "Only travel to the boost zone when the completion boost is at least this strong.",
        Options = labels,
        CurrentOption = { currentMatch }, Flag = "BoostFilterMin",
        Callback = function(opt)
            if type(opt) ~= "table" or not opt[1] then return end
            local n = tonumber(tostring(opt[1]):match("^([%d%.]+)"))
            if n then CFG.boostFilterMin = n end
        end,
    })
end

-- ---- Stats tab ----
UI(TABS.Stats, "CreateSection", "Live Progress")
PARA.progress = makeParagraph(TABS.Stats, "Status", "Starting...")
UI(TABS.Stats, "CreateSection", "Server Values")
PARA.live = makeParagraph(TABS.Stats, "Current values", "Reading...")

-- ---- Walls tab ----
UI(TABS.Walls, "CreateSection", "Current Wall")
PARA.tier = makeParagraph(TABS.Walls, "Wall info", "Reading...")
UI(TABS.Walls, "CreateSection", "Your Position")
PARA.position = makeParagraph(TABS.Walls, "Position", "Reading...")
UI(TABS.Walls, "CreateSection", "Wall Selection Filter")
local wallNames = {}
do
    local list = getTiers()
    for i, t in ipairs(list) do
        wallNames[i] = ("%d. %s"):format(i, t.Name or t.Short or ("Wall " .. i))
    end
    if #wallNames == 0 then wallNames[1] = "1. Default" end
end
UI(TABS.Walls, "CreateToggle", {
    Name = "Filter by wall type", CurrentValue = CFG.tierFilterOn, Flag = "TierFilter",
    Callback = function(v) CFG.tierFilterOn = v end,
})
UI(TABS.Walls, "CreateDropdown", {
    Name = "Minimum wall type",
    Options = wallNames,
    CurrentOption = { wallNames[CFG.tierFilterMin] or wallNames[1] }, Flag = "TierMin",
    Callback = function(opt)
        if type(opt) ~= "table" then return end
        local n = tonumber(tostring(opt[1]):match("^(%d+)"))
        if n then CFG.tierFilterMin = n end
    end,
})
UI(TABS.Walls, "CreateSection", "Section Markers")
UI(TABS.Walls, "CreateToggle", {
    Name = "Show section markers", CurrentValue = false, Flag = "SectionViz",
    Callback = function(v)
        SectionViz.enabled = v
        if v then buildSectionViz() else destroySectionViz() end
    end,
})
UI(TABS.Walls, "CreateToggle", {
    Name = "Only show nearby sections", CurrentValue = true, Flag = "VizNearOnly",
    Callback = function(v) SectionViz.nearOnly = v end,
})
UI(TABS.Walls, "CreateSlider", {
    Name = "Nearby range", Range = { 1, 8 }, Increment = 1,
    CurrentValue = 3, Flag = "VizNearRad",
    Callback = function(v) SectionViz.nearRadius = v end,
})
UI(TABS.Walls, "CreateToggle", {
    Name = "Hide finished sections", CurrentValue = false, Flag = "VizHideDone",
    Callback = function(v) SectionViz.hideComplete = v end,
})
UI(TABS.Walls, "CreateToggle", {
    Name = "Shrink far markers", CurrentValue = true, Flag = "VizScale",
    Callback = function(v) SectionViz.scaleByDist = v end,
})
UI(TABS.Walls, "CreateButton", {
    Name = "Hide all markers",
    Callback = function() SectionViz.enabled = false; destroySectionViz() end,
})

-- ---- Visuals tab ----
UI(TABS.Visuals, "CreateSection", "Place Highlights")
UI(TABS.Visuals, "CreateToggle", {
    Name = "Show highlights", CurrentValue = CFG.showPlaceHighlight, Flag = "PlaceHl",
    Callback = function(v) CFG.showPlaceHighlight = v; if not v then destroyHighlightPool() end end,
})
UI(TABS.Visuals, "CreateColorPicker", {
    Name = "Highlight color", Color = CFG.placeHighlightColor, Flag = "PlaceHlColor",
    Callback = function(c) CFG.placeHighlightColor = c end,
})
UI(TABS.Visuals, "CreateSection", "Fire Radius")
UI(TABS.Visuals, "CreateToggle", {
    Name = "Show fire radius ring", CurrentValue = CFG.showFireRing, Flag = "FireRing",
    Callback = function(v) CFG.showFireRing = v; if not v then destroyFireRing() end end,
})
UI(TABS.Visuals, "CreateColorPicker", {
    Name = "Ring color", Color = CFG.fireRingColor, Flag = "FireRingColor",
    Callback = function(c) CFG.fireRingColor = c end,
})

-- ---- Safety tab ----
UI(TABS.Safety, "CreateSection", "Admin / Mod Detection")
UI(TABS.Safety, "CreateParagraph", {
    Title = "How it works",
    Content = "Watches every player's IsAdmin AND IsMod attributes plus the Config.Admins list. If any true -> leave server.",
})
UI(TABS.Safety, "CreateToggle", {
    Name = "Leave if an admin or mod joins", CurrentValue = CFG.adminDetectOn, Flag = "AdminDetect",
    Callback = function(v) CFG.adminDetectOn = v end,
})
UI(TABS.Safety, "CreateDropdown", {
    Name = "Leave action",
    Options = { "Rejoin server", "Local kick (fallback)" },
    CurrentOption = { "Rejoin server" }, Flag = "AdminLeaveMode",
    Callback = function(opt)
        if type(opt) ~= "table" then return end
        CFG.adminLeaveMode = (opt[1] == "Local kick (fallback)") and "kick-self" or "rejoin"
    end,
})
UI(TABS.Safety, "CreateSlider", {
    Name = "Warning delay before leaving", Range = { 0, 10 }, Increment = 0.5, Suffix = "s",
    CurrentValue = CFG.adminWarnSeconds, Flag = "AdminWarn",
    Callback = function(v) CFG.adminWarnSeconds = v end,
})
PARA.adminList = makeParagraph(TABS.Safety, "Players with admin / mod now", "Scanning...")
UI(TABS.Safety, "CreateSection", "Admin Panel")
UI(TABS.Safety, "CreateParagraph", {
    Title = "Panel access",
    Content = "Opens the admin panel UI on your screen regardless of admin status. Server-side actions are still validated — only the interface is unlocked locally.\nHotkey: RightShift",
})
UI(TABS.Safety, "CreateButton", {
    Name = "Force-open admin panel",
    Callback = function()
        local ok, reason = openAdminPanel()
        if not ok then log("admin panel: " .. tostring(reason)) end
    end,
})

-- ---- Changelogs / Update tab ----
UI(TABS.Changelog, "CreateSection", "Script Info")
UI(TABS.Changelog, "CreateParagraph", {
    Title = "Version",
    Content = "v" .. SCRIPT_VERSION .. " — Build a Greatwall AutoPlace\nBy ChatGPT & Gouang",
})
UI(TABS.Changelog, "CreateSection", "What's New in v2.3.0")
UI(TABS.Changelog, "CreateParagraph", {
    Title = "v2.3.0 — Register-safe rebuild",
    Content = table.concat({
        "• Fix: removed goto/continue (Luau compatible)",
        "• Fix: consolidated locals into tables — stays under Luau's 200-register limit",
        "• Fix: auto-upgrade reads Config.Upgrades (not a nonexistent module)",
        "• Fix: Upgrade remote is Remotes.Upgrade, called with :InvokeServer",
        "• New: proper response handling (ok / coins / locked / far / loading)",
        "• New: auto-enter Upgrade Shrine zone when server replies 'far'",
        "• New: admin panel local-gate bypass",
    }, "\n"),
})
UI(TABS.Changelog, "CreateSection", "v2.2.0")
UI(TABS.Changelog, "CreateParagraph", {
    Title = "v2.2.0 — Upgrade system fix",
    Content = table.concat({
        "• Auto-upgrade reads Config.Upgrades",
        "• Upgrade remote :InvokeServer with proper response parsing",
        "• Auto shrine entry on 'far' reason",
        "• Per-upgrade rate limit",
    }, "\n"),
})
UI(TABS.Changelog, "CreateSection", "v2.1.0")
UI(TABS.Changelog, "CreateParagraph", {
    Title = "v2.1.0 — Changelogs Tab",
    Content = table.concat({
        "• New: Changelogs / Update tab",
        "• New: Boost zone filter (minimum multiplier)",
        "• New: 500x training targets from client attributes",
        "• New: Admin AND Mod detection",
        "• New: Safety tab with live admin/mod list",
        "• Removed: Walls tab Quick Jump",
    }, "\n"),
})
UI(TABS.Changelog, "CreateSection", "v2.0.0 / v1.0.0")
UI(TABS.Changelog, "CreateParagraph", {
    Title = "Earlier",
    Content = table.concat({
        "v2.0.0 — BFS cluster, camera see-through, adaptive rate, auto-refill,",
        "section markers, highlight pool, fire ring, auto hot springs,",
        "wall tier filter, anti-AFK.",
        "",
        "v1.0.0 — Initial: 4 placement methods, 4 targeting modes,",
        "3 travel modes, noclip, flight, bench+treadmill training, Rayfield UI.",
    }, "\n"),
})
UI(TABS.Changelog, "CreateButton", {
    Name = "Copy version string",
    Callback = function()
        log("script version: " .. SCRIPT_VERSION)
        pcall(function() setclipboard("AutoPlace v" .. SCRIPT_VERSION) end)
    end,
})

-- ============================================================
-- Main loop
-- ============================================================

local function tick()
    local now = os.clock()
    local dt = now - TIMERS.dt
    TIMERS.dt = now

    tickAnalytics()
    updateSectionViz()
    updateFireRing()
    adaptTuning(now)
    regrowRate(now)

    tryAutoUpgrade()
    tickShrineAutoEnter()

    if UPG.shrine.active and UPG.reason == "far" then
        UPG.reason = nil
        UPG.lastAt = 0
        tryAutoUpgrade()
    end

    if CFG.antiAfk and (now - TIMERS.afk) > 60 then
        TIMERS.afk = now
        vUserClick()
    end

    local trainingBusy = false
    local sMet, pMet = trainTargetsMet()
    local wantStrength = CFG.trainStrength and not sMet
    local wantSpeed    = CFG.trainSpeed    and not pMet
    if wantStrength or wantSpeed then
        local keepStr, keepSpd = CFG.trainStrength, CFG.trainSpeed
        CFG.trainStrength = wantStrength
        CFG.trainSpeed    = wantSpeed
        trainingBusy = runTraining()
        CFG.trainStrength = keepStr
        CFG.trainSpeed    = keepSpd
    end

    local pausedBySprings = hotSpringsTick(now)

    if now - TIMERS.info > 1.0 then
        TIMERS.info = now

        if PARA.trainingInfo and type(PARA.trainingInfo.Set) == "function" then
            local area = trainState.currentArea or getBestTrainingArea()
            local txt
            if not area then
                txt = "(no training area found)"
            else
                local sM, pM, str, spd = trainTargetsMet()
                txt = ("Using: %s\nRequirement: %d   Blocks built: %d\nStrength %d%s   Speed %d%s"):format(
                    area.Name, getTrainingRequirement(area), getWallAmount(),
                    math.floor(str), sM and " ✓" or "",
                    math.floor(spd), pM and " ✓" or "")
            end
            pcall(function() PARA.trainingInfo:Set({ Title = "Current area", Content = txt }) end)
        end

        if PARA.hsInfo and type(PARA.hsInfo.Set) == "function" then
            local status
            if hsState.isOpen then
                status = ("Open — %sx boost, ends in %s"):format(
                    tostring(hsState.multiplier), formatClock(hsState.secondsLeft))
                if CFG.boostFilterOn then
                    local ok = hsState.multiplier >= CFG.boostFilterMin
                    status = status .. ("\nFilter: %s (need %sx)"):format(
                        ok and "passing" or "below",
                        tostring(CFG.boostFilterMin))
                end
            else
                status = "Closed — finish the wall to open it"
            end
            pcall(function() PARA.hsInfo:Set({ Title = "Current boost", Content = status }) end)
        end

        if PARA.tier and type(PARA.tier.Set) == "function" then
            local i = currentTier()
            pcall(function()
                PARA.tier:Set({ Title = "Wall info", Content =
                    ("Now building: %s\nGym boost: %.2fx   Coin reward: %d"):format(
                        tierName(i), tierGymMult(i), tierCoins(i)) })
            end)
        end

        if PARA.live and type(PARA.live.Set) == "function" then
            local list = allLiveAttrs()
            local lines = {}
            for _, item in ipairs(list) do
                local pretty = item.key
                    :gsub("PlaceRange", "Reach")
                    :gsub("PlaceCooldown", "Cooldown")
                    :gsub("Capacity", "Bag capacity")
                    :gsub("Blocks", "Blocks carried")
                lines[#lines + 1] = ("%s: %s"):format(pretty, tostring(item.value))
            end
            if #lines == 0 then lines[1] = "(no values yet)" end
            pcall(function() PARA.live:Set({ Title = "Current values", Content = table.concat(lines, "\n") }) end)
        end

        if PARA.progress and type(PARA.progress.Set) == "function" then
            local root = getRoot()
            local txt
            if not root then
                txt = "(character not loaded)"
            else
                local sec = sectionOf(root.Position.X)
                local layer = layerOf(root.Position.Y)
                local sName = (STAGES and STAGES[sec] and STAGES[sec].name) or "?"
                local statusLine
                if trainingBusy then statusLine = "Training at best area"
                elseif phaseBlocksPlacement() then statusLine = "Paused — event in progress"
                elseif refilling then statusLine = "Refilling at quarry"
                elseif CFG.running then statusLine = ("Building — %d blocks/sec"):format(RATE.current)
                else statusLine = "Idle"
                end
                local clusterLine = ""
                if GL.cluster then
                    clusterLine = ("\nCluster progress: %d of %d"):format(
                        math.min(GL.cluster.orderIdx - 1, #GL.cluster.order),
                        #GL.cluster.order)
                end
                local upgradeLine = ""
                if CFG.autoUpgradeOn then
                    upgradeLine = ("\nAuto-upgrade: on (%s)"):format(tostring(UPG.reason or "idle"))
                end
                txt = ("%s\nSection: %s (layer %d)%s%s\nBlocks placed: %d"):format(
                    statusLine, sName, layer, clusterLine, upgradeLine, analytics.fires)
            end
            pcall(function() PARA.progress:Set({ Title = "Status", Content = txt }) end)
        end

        if PARA.position and type(PARA.position.Set) == "function" then
            local root = getRoot()
            local txt
            if not root then
                txt = "(character not loaded)"
            else
                local col = columnOf(root.Position.X)
                local sec = sectionOf(root.Position.X)
                local layer = layerOf(root.Position.Y)
                local sName = (STAGES and STAGES[sec] and STAGES[sec].name) or "?"
                txt = ("Section: %d — %s\nColumn: %d   Layer: %d"):format(sec, sName, col, layer)
            end
            pcall(function() PARA.position:Set({ Title = "Position", Content = txt }) end)
        end

        if PARA.adminList and type(PARA.adminList.Set) == "function" then
            local lines = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local isA = p:GetAttribute("IsAdmin") == true
                    local isM = p:GetAttribute("IsMod") == true
                    local listed = Config and Config.Admins and Config.Admins[p.UserId]
                    if isA or isM or listed then
                        local tag = isA and "IsAdmin" or (isM and "IsMod" or "Admins list")
                        lines[#lines + 1] = ("%s (%d) — %s"):format(p.Name, p.UserId, tag)
                    end
                end
            end
            if #lines == 0 then lines[1] = "(none detected)" end
            pcall(function() PARA.adminList:Set({ Title = "Players with admin / mod now", Content = table.concat(lines, "\n") }) end)
        end
    end

    if trainingBusy and CFG.trainPauseBuild then return end

    if not CFG.running then SM.phase = "idle"; SM.target = nil; return end
    if pausedBySprings then return end
    if not tierPassesFilter() then return end

    local blocked = phaseBlocksPlacement()
    if blocked then
        if now - GL.lastSuspend > 2 then GL.lastSuspend = now end
        return
    end

    refillTokens(dt)
    if refilling then return end
    if now < RATE.pausedUntil then return end

    if GL.dirty then rebuildList() end

    local blocks = LocalPlayer:GetAttribute("Blocks") or 0
    if CFG.refillEnabled and blocks <= 0 then task.spawn(refillBlocks); return end
    if blocks <= 0 then return end

    local root = getRoot()
    if not root then return end

    if SM.phase == "idle" then
        if CFG.targetMode == "cluster" then
            if not GL.cluster then
                local ref, filter = modeFilterAndRef(root.Position)
                if filter and not anyPasses(filter) then GL.lastPlaced = nil; ref, filter = root.Position, nil end
                local anchor = pickNearest(ref, filter) or pickNearest(root.Position, nil)
                if anchor then
                    GL.cluster = { anchorPos = anchor.Position, order = {}, orderIdx = 1 }
                    rebuildClusterOrder()
                end
            end
            if not GL.cluster then
                GL.dirty = true
            else
                if GL.cluster.orderIdx > #GL.cluster.order then
                    local unfired = clusterGhosts(GL.cluster.anchorPos)
                    if #unfired == 0 then
                        local expand = CFG.clusterRadius * 3
                        local nearest, bestD = nil, expand
                        for i = 1, #GL.parts do
                            local g = GL.parts[i]
                            if g and g.Parent and not GL.fired[g] and not GL.inflight[g] then
                                local d = (g.Position - GL.cluster.anchorPos).Magnitude
                                if d < bestD then bestD = d; nearest = g end
                            end
                        end
                        if nearest then
                            GL.cluster.anchorPos = nearest.Position
                            unfired = clusterGhosts(GL.cluster.anchorPos)
                        end
                    end
                    if #unfired > 0 then rebuildClusterOrder() end
                end
                if GL.cluster.orderIdx > #GL.cluster.order then
                    local ifCount = clusterInflightCount(GL.cluster.anchorPos)
                    if ifCount == 0 then
                        GL.cluster = nil; GL.dirty = true
                    else
                        GL.dirty = true
                    end
                else
                    local g = GL.cluster.order[GL.cluster.orderIdx]
                    if not g or not g.Parent or GL.fired[g] or GL.inflight[g] then
                        GL.cluster.orderIdx = GL.cluster.orderIdx + 1
                    else
                        local sign = (root.Position.Z >= g.Position.Z) and 1 or -1
                        local target = Vector3.new(
                            g.Position.X, g.Position.Y + BLOCK,
                            g.Position.Z + sign * (BLOCK * 0.5 + 2.5))
                        SM.target = target
                        local dist = (root.Position - target).Magnitude
                        if dist > 2 then
                            if CFG.moveMode == "teleport" then
                                root.CFrame = CFrame.new(target, target + root.CFrame.LookVector)
                            elseif CFG.moveMode == "step" then
                                local delta = target - root.Position
                                local stepDist = math.min(CFG.stepSpeed * dt, delta.Magnitude)
                                root.CFrame = root.CFrame + delta.Unit * stepDist
                            end
                        end
                        SM.phase = "settling"
                        SM.settleUntil = now + AUTO.settleTime
                    end
                end
            end
        else
            local ref, filter = modeFilterAndRef(root.Position)
            if filter and not anyPasses(filter) then GL.lastPlaced = nil; ref, filter = root.Position, nil end
            local g = pickNearest(ref, filter) or pickNearest(root.Position, nil)
            if not g then
                GL.dirty = true
                if now - GL.lastSuspend > CFG.suspendPoll then GL.lastSuspend = now; GL.dirty = true end
            else
                local sign = (root.Position.Z >= g.Position.Z) and 1 or -1
                local target = Vector3.new(
                    g.Position.X, g.Position.Y + BLOCK,
                    g.Position.Z + sign * (BLOCK * 0.5 + 2.5))
                SM.target = target
                local dist = (root.Position - target).Magnitude
                if dist > 2 then
                    if CFG.moveMode == "teleport" then
                        root.CFrame = CFrame.new(target, target + root.CFrame.LookVector)
                    elseif CFG.moveMode == "step" then
                        local delta = target - root.Position
                        local stepDist = math.min(CFG.stepSpeed * dt, delta.Magnitude)
                        root.CFrame = root.CFrame + delta.Unit * stepDist
                    end
                end
                SM.phase = "settling"
                SM.settleUntil = now + AUTO.settleTime
            end
        end

    elseif SM.phase == "settling" then
        if now >= SM.settleUntil then SM.phase = "firing" end

    elseif SM.phase == "firing" then
        if CFG.targetMode == "cluster" and GL.cluster then
            local fired, blockedRange = fireClusterOrdered()
            if GL.cluster.orderIdx > #GL.cluster.order then
                local ifCount = clusterInflightCount(GL.cluster.anchorPos)
                if ifCount == 0 then
                    GL.cluster = nil
                    SM.phase = "idle"
                    SM.target = nil
                    GL.dirty = true
                else
                    SM.phase = "idle"
                end
            elseif blockedRange then
                SM.phase = "idle"
            elseif fired == 0 then
                SM.phase = "idle"
            end
        else
            local fired, hasInRange = fireInRange()
            if fired == 0 and not hasInRange then
                SM.phase = "idle"
                SM.target = nil
            end
        end
    end
end

RunService.Heartbeat:Connect(tick)

pcall(function()
    Rayfield:Notify({
        Title = "AutoPlace v" .. SCRIPT_VERSION,
        Content = "Building, Training, Safety, Changelogs tabs ready.",
        Duration = 6,
    })
end)

log("loaded v" .. SCRIPT_VERSION)
