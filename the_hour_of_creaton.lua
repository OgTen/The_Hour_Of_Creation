local DEFAULT_COIN = Color3.fromRGB(255, 215, 0)
local DEFAULT_BREAKER = Color3.fromRGB(255, 165, 0)
local DEFAULT_FREDDY = Color3.fromRGB(255, 0, 0)
local DEFAULT_BONNIE = Color3.fromRGB(128, 0, 255)
local DEFAULT_KEY = Color3.fromRGB(255, 255, 0)
local DEFAULT_KEYLOCK = Color3.fromRGB(0, 255, 200)
local DEFAULT_CAR = Color3.fromRGB(0, 200, 255)
local DEFAULT_CARPART = Color3.fromRGB(100, 255, 100)
local DEFAULT_CHICA = Color3.fromRGB(255, 220, 0)
local COLOR_FILE = "thoc_colors.json"

local function LoadSavedColors()
    local colors = {
        COIN = DEFAULT_COIN,
        BREAKER = DEFAULT_BREAKER,
        FREDDY = DEFAULT_FREDDY,
        BONNIE = DEFAULT_BONNIE,
        KEY = DEFAULT_KEY,
        KEYLOCK = DEFAULT_KEYLOCK,
        CAR = DEFAULT_CAR,
        CARPART = DEFAULT_CARPART,
        CHICA = DEFAULT_CHICA
    }
    if isfile and isfile(COLOR_FILE) then
        local success, data = pcall(readfile, COLOR_FILE)
        if success and data then
            local parsed = game:GetService("HttpService"):JSONDecode(data)
            if parsed then
                if parsed.COIN then colors.COIN = Color3.fromRGB(parsed.COIN[1]*255, parsed.COIN[2]*255, parsed.COIN[3]*255) end
                if parsed.BREAKER then colors.BREAKER = Color3.fromRGB(parsed.BREAKER[1]*255, parsed.BREAKER[2]*255, parsed.BREAKER[3]*255) end
                if parsed.FREDDY then colors.FREDDY = Color3.fromRGB(parsed.FREDDY[1]*255, parsed.FREDDY[2]*255, parsed.FREDDY[3]*255) end
                if parsed.BONNIE then colors.BONNIE = Color3.fromRGB(parsed.BONNIE[1]*255, parsed.BONNIE[2]*255, parsed.BONNIE[3]*255) end
                if parsed.KEY then colors.KEY = Color3.fromRGB(parsed.KEY[1]*255, parsed.KEY[2]*255, parsed.KEY[3]*255) end
                if parsed.KEYLOCK then colors.KEYLOCK = Color3.fromRGB(parsed.KEYLOCK[1]*255, parsed.KEYLOCK[2]*255, parsed.KEYLOCK[3]*255) end
                if parsed.CAR then colors.CAR = Color3.fromRGB(parsed.CAR[1]*255, parsed.CAR[2]*255, parsed.CAR[3]*255) end
                if parsed.CARPART then colors.CARPART = Color3.fromRGB(parsed.CARPART[1]*255, parsed.CARPART[2]*255, parsed.CARPART[3]*255) end
                if parsed.CHICA then colors.CHICA = Color3.fromRGB(parsed.CHICA[1]*255, parsed.CHICA[2]*255, parsed.CHICA[3]*255) end
            end
        end
    end
    return colors
end

local function SaveColors(colors)
    local data = game:GetService("HttpService"):JSONEncode({
        COIN = {colors.COIN.R, colors.COIN.G, colors.COIN.B},
        BREAKER = {colors.BREAKER.R, colors.BREAKER.G, colors.BREAKER.B},
        FREDDY = {colors.FREDDY.R, colors.FREDDY.G, colors.FREDDY.B},
        BONNIE = {colors.BONNIE.R, colors.BONNIE.G, colors.BONNIE.B},
        KEY = {colors.KEY.R, colors.KEY.G, colors.KEY.B},
        KEYLOCK = {colors.KEYLOCK.R, colors.KEYLOCK.G, colors.KEYLOCK.B},
        CAR = {colors.CAR.R, colors.CAR.G, colors.CAR.B},
        CARPART = {colors.CARPART.R, colors.CARPART.G, colors.CARPART.B},
        CHICA = {colors.CHICA.R, colors.CHICA.G, colors.CHICA.B}
    })
    if writefile then
        writefile(COLOR_FILE, data)
    end
end
local COLORS = LoadSavedColors()
local COIN_COLOR = COLORS.COIN
local BREAKER_COLOR = COLORS.BREAKER
local FREDDY_COLOR = COLORS.FREDDY
local BONNIE_COLOR = COLORS.BONNIE
local KEY_COLOR = COLORS.KEY
local KEYLOCK_COLOR = COLORS.KEYLOCK
local CAR_COLOR = COLORS.CAR
local CARPART_COLOR = COLORS.CARPART
local CHICA_COLOR = COLORS.CHICA
local CoinTargets = {}
local BreakerTargets = {}
local FreddyTarget = nil
local BonnieTarget = nil
local ChicaTarget = nil
local CarTarget = nil
local CarPartTargets = {}
local KeyTargets = {}
local KeyLockTargets = {}
local CoinDrawings = {}
local BreakerDrawings = {}
local CarDrawing = nil
local CarText = nil
local CarPartDrawings = {}
local CarPartTexts = {}
local CoinTexts = {}
local BreakerTexts = {}
local FreddyDrawing = nil
local FreddyText = nil
local BonnieText = nil
local ChicaDrawing = nil
local ChicaText = nil
local KeyDrawings = {}
local KeyTexts = {}
local KeyLockDrawings = {}
local KeyLockTexts = {}
local frameCounter = 0
local UPDATE_INTERVAL = 2

local function GetItemsFolder()
    local gameFolder = workspace:FindFirstChild("Game")
    if gameFolder then
        return gameFolder:FindFirstChild("Items")
    end
    return nil
end

local function ScanCoins()
    task.spawn(function()
        local itemsFolder = GetItemsFolder()
        if itemsFolder then
            for _, child in ipairs(itemsFolder:GetChildren()) do
                if child:IsA("Model") and string.lower(child.Name):find("smallcoins") then
                    table.insert(CoinTargets, child)
                end
            end
        end
        for i = 1, #CoinTargets do
            if not CoinDrawings[i] then
                local square = Drawing.new("Square")
                square.Size = Vector2.new(30, 30)
                square.Color = COIN_COLOR
                square.Transparency = 1
                square.Filled = false
                square.Thickness = 2
                square.ZIndex = 999
                square.Visible = false
                CoinDrawings[i] = square
                local text = Drawing.new("Text")
                text.Font = Drawing.Fonts.UI
                text.Size = 12
                text.Color = COIN_COLOR
                text.Outline = false
                text.Center = true
                text.ZIndex = 999
                text.Visible = false
                CoinTexts[i] = text
            end
        end
        notify("Coins found: " .. #CoinTargets, "The Hour Of Creation", 3)
    end)
end

local function ScanBreakers()
    task.spawn(function()
        BreakerTargets = {}
        local gameFolder = workspace:FindFirstChild("Game")
        local mapFolder = gameFolder and gameFolder:FindFirstChild("Map")
        local objectivesFolder = mapFolder and mapFolder:FindFirstChild("Objectives")
        local breakersFolder = objectivesFolder and objectivesFolder:FindFirstChild("Breakers")
        if breakersFolder then
            for _, child in ipairs(breakersFolder:GetChildren()) do
                if child.Name == "Breaker" and child.ClassName == "Model" then
                    table.insert(BreakerTargets, child)
                end
            end
        end
        for i = 1, #BreakerTargets do
            if not BreakerDrawings[i] then
                local box = Drawing.new("Square")
                box.Size = Vector2.new(40, 40)
                box.Color = BREAKER_COLOR
                box.Transparency = 1
                box.Filled = false
                box.Thickness = 2
                box.ZIndex = 999
                box.Visible = false
                BreakerDrawings[i] = box
                local text = Drawing.new("Text")
                text.Font = Drawing.Fonts.UI
                text.Size = 12
                text.Color = BREAKER_COLOR
                text.Outline = false
                text.Center = true
                text.ZIndex = 999
                text.Visible = false
                BreakerTexts[i] = text
            end
        end
        notify("Breakers found: " .. #BreakerTargets, "The Hour Of Creation", 3)
    end)
end

local function ScanCar()
    task.spawn(function()
        CarTarget = nil
        local gameFolder = workspace:FindFirstChild("Game")
        local mapFolder = gameFolder and gameFolder:FindFirstChild("Map")
        local objectivesFolder = mapFolder and mapFolder:FindFirstChild("Objectives")
        local carFolder = objectivesFolder and objectivesFolder:FindFirstChild("Car")
        local car = carFolder and carFolder:FindFirstChild("Car")
        if car and car.ClassName == "Model" then
            CarTarget = car
        end
        if CarTarget then
            if not CarDrawing then
                CarDrawing = Drawing.new("Square")
                CarDrawing.Size = Vector2.new(60, 60)
                CarDrawing.Color = CAR_COLOR
                CarDrawing.Transparency = 1
                CarDrawing.Filled = false
                CarDrawing.Thickness = 2
                CarDrawing.ZIndex = 999
                CarDrawing.Visible = false
                CarText = Drawing.new("Text")
                CarText.Font = Drawing.Fonts.UI
                CarText.Size = 12
                CarText.Color = CAR_COLOR
                CarText.Outline = false
                CarText.Center = true
                CarText.ZIndex = 999
                CarText.Visible = false
            end
            notify("Car found and tracking!", "The Hour Of Creation", 3)
        else
            notify("Car not found.", "The Hour Of Creation", 3)
        end
    end)
end

local function ScanCarParts()
    task.spawn(function()
        CarPartTargets = {}
        local itemsFolder = GetItemsFolder()
        local wanted = {
            Light = true,
            Radiator = true,
            Tire = true,
            Engine = true
        }
        if itemsFolder then
            for _, child in ipairs(itemsFolder:GetChildren()) do
                if wanted[child.Name] then
                    if child.ClassName == "MeshPart" then
                        table.insert(CarPartTargets, child)
                    elseif child.ClassName == "Model" then
                        for _, part in ipairs(child:GetChildren()) do
                            if part.ClassName == "MeshPart" then
                                table.insert(CarPartTargets, part)
                            end
                        end
                    end
                end
            end
        end
        for i = 1, #CarPartTargets do
            if not CarPartDrawings[i] then
                local box = Drawing.new("Square")
                box.Size = Vector2.new(30, 30)
                box.Color = CARPART_COLOR
                box.Transparency = 1
                box.Filled = false
                box.Thickness = 2
                box.ZIndex = 999
                box.Visible = false
                CarPartDrawings[i] = box
            end
            if not CarPartTexts[i] then
                local text = Drawing.new("Text")
                text.Font = Drawing.Fonts.UI
                text.Size = 12
                text.Color = CARPART_COLOR
                text.Outline = false
                text.Center = true
                text.ZIndex = 999
                text.Visible = false
                CarPartTexts[i] = text
            end
        end
        notify("Car parts found: " .. #CarPartTargets, "The Hour Of Creation", 3)
    end)
end

local function ScanChica()
    task.spawn(function()
        local gameFolder = workspace:FindFirstChild("Game")
        local entitiesFolder = gameFolder and gameFolder:FindFirstChild("Entities")
        ChicaTarget = entitiesFolder and entitiesFolder:FindFirstChild("Chica") or nil
        if ChicaTarget then
            if not ChicaDrawing then
                ChicaDrawing = Drawing.new("Square")
                ChicaDrawing.Size = Vector2.new(60, 90)
                ChicaDrawing.Color = CHICA_COLOR
                ChicaDrawing.Transparency = 1
                ChicaDrawing.Filled = false
                ChicaDrawing.Thickness = 3
                ChicaDrawing.ZIndex = 999
                ChicaDrawing.Visible = false
                ChicaText = Drawing.new("Text")
                ChicaText.Font = Drawing.Fonts.UI
                ChicaText.Size = 12
                ChicaText.Color = CHICA_COLOR
                ChicaText.Outline = false
                ChicaText.Center = true
                ChicaText.ZIndex = 999
                ChicaText.Visible = false
            end
            notify("Chica found and tracking!", "The Hour Of Creation", 3)
        else
            notify("Enable when Chica has spawned in.", "The Hour Of Creation", 4)
            UI.SetValue("chica_enabled", false)
        end
    end)
end

local function ScanFreddy()
    task.spawn(function()
        local found = nil
        local function SearchChunked(container)
            local count = 0
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Model") and child.Name and string.find(string.lower(child.Name), "freddy") then
                    found = child
                    return true
                end
                if child:IsA("Model") or child:IsA("Folder") then
                    if SearchChunked(child) then
                        return true
                    end
                end
                count = count + 1
                if count % 50 == 0 then
                    task.wait()
                end
            end
            return false
        end
        SearchChunked(workspace)
        FreddyTarget = found
        if FreddyTarget then
            if not FreddyDrawing then
                FreddyDrawing = Drawing.new("Square")
                FreddyDrawing.Size = Vector2.new(60, 90)
                FreddyDrawing.Color = FREDDY_COLOR
                FreddyDrawing.Transparency = 1
                FreddyDrawing.Filled = false
                FreddyDrawing.Thickness = 3
                FreddyDrawing.ZIndex = 999
                FreddyDrawing.Visible = true
                FreddyText = Drawing.new("Text")
                FreddyText.Font = Drawing.Fonts.UI
                FreddyText.Size = 12
                FreddyText.Color = FREDDY_COLOR
                FreddyText.Outline = false
                FreddyText.Center = true
                FreddyText.ZIndex = 999
                FreddyText.Visible = true
            end
            notify("Freddy found and tracking!", "The Hour Of Creation", 3)
        else
            notify("Enable when Freddy has spawned in.", "The Hour Of Creation", 4)
            UI.SetValue("freddy_enabled", false)
        end
    end)
end

local function ScanBonnie()
    task.spawn(function()
        local found = nil
        local function SearchChunked(container)
            local count = 0
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Model") and child.Name and string.find(string.lower(child.Name), "bonnie") then
                    found = child
                    return true
                end
                if child:IsA("Model") or child:IsA("Folder") then
                    if SearchChunked(child) then
                        return true
                    end
                end
                count = count + 1
                if count % 50 == 0 then
                    task.wait()
                end
            end
            return false
        end
        SearchChunked(workspace)
        BonnieTarget = found
        if BonnieTarget then
            if not BonnieDrawing then
                BonnieDrawing = Drawing.new("Square")
                BonnieDrawing.Size = Vector2.new(60, 90)
                BonnieDrawing.Color = BONNIE_COLOR
                BonnieDrawing.Transparency = 1
                BonnieDrawing.Filled = false
                BonnieDrawing.Thickness = 3
                BonnieDrawing.ZIndex = 999
                BonnieDrawing.Visible = true
                BonnieText = Drawing.new("Text")
                BonnieText.Font = Drawing.Fonts.UI
                BonnieText.Size = 12
                BonnieText.Color = BONNIE_COLOR
                BonnieText.Outline = false
                BonnieText.Center = true
                BonnieText.ZIndex = 999
                BonnieText.Visible = true
            end
            notify("Bonnie found and tracking!", "The Hour Of Creation", 3)
        else
            notify("Enable when Bonnie has spawned in.", "The Hour Of Creation", 4)
            UI.SetValue("bonnie_enabled", false)
        end
    end)
end

local function ScanKeys()
    task.spawn(function()
        local itemsFolder = GetItemsFolder()
        if itemsFolder then
            for _, child in ipairs(itemsFolder:GetChildren()) do
                if child:IsA("Model") and child.Name == "Key" then
                    table.insert(KeyTargets, child)
                end
            end
        end
        for i = 1, #KeyTargets do
            if not KeyDrawings[i] then
                local square = Drawing.new("Square")
                square.Size = Vector2.new(30, 30)
                square.Color = KEY_COLOR
                square.Transparency = 1
                square.Filled = false
                square.Thickness = 2
                square.ZIndex = 999
                square.Visible = false
                KeyDrawings[i] = square
                local text = Drawing.new("Text")
                text.Font = Drawing.Fonts.UI
                text.Size = 12
                text.Color = KEY_COLOR
                text.Outline = false
                text.Center = true
                text.ZIndex = 999
                text.Visible = false
                KeyTexts[i] = text
            end
        end
        notify("Keys found: " .. #KeyTargets, "The Hour Of Creation", 3)
    end)
end

local function ScanKeyLocks()
    task.spawn(function()
        local gameFolder = workspace:FindFirstChild("Game")
        if gameFolder then
            local mapFolder = gameFolder:FindFirstChild("Map")
            if mapFolder then
                local objectivesFolder = mapFolder:FindFirstChild("Objectives")
                if objectivesFolder then
                    local keysFolder = objectivesFolder:FindFirstChild("Keys")
                    if keysFolder then
                        local locksModel = keysFolder:FindFirstChild("Locks")
                        if locksModel and locksModel:IsA("Model") then
                            table.insert(KeyLockTargets, locksModel)
                        end
                    end
                end
            end
        end
        for i = 1, #KeyLockTargets do
            if not KeyLockDrawings[i] then
                local square = Drawing.new("Square")
                square.Size = Vector2.new(50, 70)
                square.Color = KEYLOCK_COLOR
                square.Transparency = 1
                square.Filled = false
                square.Thickness = 3
                square.ZIndex = 999
                square.Visible = false
                KeyLockDrawings[i] = square
                local text = Drawing.new("Text")
                text.Font = Drawing.Fonts.UI
                text.Size = 12
                text.Color = KEYLOCK_COLOR
                text.Outline = false
                text.Center = true
                text.ZIndex = 999
                text.Visible = false
                KeyLockTexts[i] = text
            end
        end
        notify("Key Locks found: " .. #KeyLockTargets, "The Hour Of Creation", 3)
    end)
end
UI.SetValue("coin_enabled", false)
UI.SetValue("freddy_enabled", false)
UI.SetValue("bonnie_enabled", false)
UI.SetValue("breaker_enabled", false)
UI.SetValue("key_enabled", false)
UI.SetValue("keylock_enabled", false)
UI.SetValue("car_enabled", false)
UI.SetValue("carparts_enabled", false)
UI.SetValue("chica_enabled", false)
UI.SetValue("show_labels", true)
UI.SetValue("show_distance", true)
UI.SetValue("coin_box", true)
UI.SetValue("breaker_box", true)
UI.SetValue("freddy_box", true)
UI.SetValue("bonnie_box", true)
UI.SetValue("key_box", true)
UI.SetValue("keylock_box", true)
UI.SetValue("car_box", true)
UI.SetValue("carparts_box", true)
UI.SetValue("chica_box", true)

UI.AddTab("The Hour Of Creation", function(tab)
    local itemsSection = tab:Section("Items", "Left")
    itemsSection:Toggle("coin_enabled", "Track Coins", false, function(state)
        if state and #CoinTargets == 0 then ScanCoins() end
    end)
    itemsSection:ColorPicker("coin_color", COIN_COLOR.R, COIN_COLOR.G, COIN_COLOR.B, 1, function(color, alpha)
        COIN_COLOR = color
        COLORS.COIN = color
        SaveColors(COLORS)
        for _, draw in ipairs(CoinDrawings or {}) do
            if draw then draw.Color = color end
        end
        for _, text in ipairs(CoinTexts or {}) do
            if text then text.Color = color end
        end
    end)
    itemsSection:Toggle("breaker_enabled", "Track Breakers", false, function(state)
        if state and #BreakerTargets == 0 then ScanBreakers() end
    end)
    itemsSection:ColorPicker("breaker_color", BREAKER_COLOR.R, BREAKER_COLOR.G, BREAKER_COLOR.B, 1, function(color, alpha)
        BREAKER_COLOR = color
        COLORS.BREAKER = color
        SaveColors(COLORS)
        for _, draw in ipairs(BreakerDrawings or {}) do
            if draw then draw.Color = color end
        end
        for _, text in ipairs(BreakerTexts or {}) do
            if text then text.Color = color end
        end
    end)
    itemsSection:Toggle("car_enabled", "Track Car", false, function(state)
        if state and not CarTarget then ScanCar() end
    end)
    itemsSection:ColorPicker("car_color", CAR_COLOR.R, CAR_COLOR.G, CAR_COLOR.B, 1, function(color, alpha)
        CAR_COLOR = color
        COLORS.CAR = color
        SaveColors(COLORS)
        if CarDrawing then CarDrawing.Color = color end
        if CarText then CarText.Color = color end
    end)
    itemsSection:Toggle("carparts_enabled", "Track Car Parts", false, function(state)
        if state and #CarPartTargets == 0 then ScanCarParts() end
    end)
    itemsSection:ColorPicker("carparts_color", CARPART_COLOR.R, CARPART_COLOR.G, CARPART_COLOR.B, 1, function(color, alpha)
        CARPART_COLOR = color
        COLORS.CARPART = color
        SaveColors(COLORS)
        for _, box in ipairs(CarPartDrawings or {}) do
            if box then box.Color = color end
        end
        for _, text in ipairs(CarPartTexts or {}) do
            if text then text.Color = color end
        end
    end)
    itemsSection:Toggle("key_enabled", "Track Keys", false, function(state)
        if state and #KeyTargets == 0 then ScanKeys() end
    end)
    itemsSection:ColorPicker("key_color", KEY_COLOR.R, KEY_COLOR.G, KEY_COLOR.B, 1, function(color, alpha)
        KEY_COLOR = color
        COLORS.KEY = color
        SaveColors(COLORS)
        for _, draw in ipairs(KeyDrawings or {}) do
            if draw then draw.Color = color end
        end
        for _, text in ipairs(KeyTexts or {}) do
            if text then text.Color = color end
        end
    end)
    itemsSection:Toggle("keylock_enabled", "Track Key Lock", false, function(state)
        if state and #KeyLockTargets == 0 then ScanKeyLocks() end
    end)
    itemsSection:ColorPicker("keylock_color", KEYLOCK_COLOR.R, KEYLOCK_COLOR.G, KEYLOCK_COLOR.B, 1, function(color, alpha)
        KEYLOCK_COLOR = color
        COLORS.KEYLOCK = color
        SaveColors(COLORS)
        for _, draw in ipairs(KeyLockDrawings or {}) do
            if draw then draw.Color = color end
        end
        for _, text in ipairs(KeyLockTexts or {}) do
            if text then text.Color = color end
        end
    end)
    local entitySection = tab:Section("Entities", "Right")
    entitySection:Toggle("freddy_enabled", "Track Freddy", false, function(state)
        if state and not FreddyTarget then ScanFreddy() end
    end)
    entitySection:ColorPicker("freddy_color", FREDDY_COLOR.R, FREDDY_COLOR.G, FREDDY_COLOR.B, 1, function(color, alpha)
        FREDDY_COLOR = color
        COLORS.FREDDY = color
        SaveColors(COLORS)
        if FreddyDrawing then FreddyDrawing.Color = color end
        if FreddyText then FreddyText.Color = color end
    end)
    entitySection:Toggle("bonnie_enabled", "Track Bonnie", false, function(state)
        if state and not BonnieTarget then ScanBonnie() end
    end)
    entitySection:ColorPicker("bonnie_color", BONNIE_COLOR.R, BONNIE_COLOR.G, BONNIE_COLOR.B, 1, function(color, alpha)
        BONNIE_COLOR = color
        COLORS.BONNIE = color
        SaveColors(COLORS)
        if BonnieDrawing then BonnieDrawing.Color = color end
        if BonnieText then BonnieText.Color = color end
    end)
    entitySection:Toggle("chica_enabled", "Track Chica", false, function(state)
        if state and not ChicaTarget then ScanChica() end
    end)
    entitySection:ColorPicker("chica_color", CHICA_COLOR.R, CHICA_COLOR.G, CHICA_COLOR.B, 1, function(color, alpha)
        CHICA_COLOR = color
        COLORS.CHICA = color
        SaveColors(COLORS)
        if ChicaDrawing then ChicaDrawing.Color = color end
        if ChicaText then ChicaText.Color = color end
    end)
    local settingsSection = tab:Section("Settings", "Right")
    settingsSection:Text("ESP Settings")
    settingsSection:Toggle("show_labels", "Show Labels", true)
    settingsSection:Toggle("show_distance", "Show Distance", true)
    settingsSection:Spacing()
    settingsSection:Toggle("coin_box", "Coin Box", true)
    settingsSection:Toggle("breaker_box", "Breaker Box", true)
    settingsSection:Toggle("car_box", "Car Box", true)
    settingsSection:Toggle("carparts_box", "Car Parts Box", true)
    settingsSection:Toggle("key_box", "Key Box", true)
    settingsSection:Toggle("keylock_box", "Key Lock Box", true)
    settingsSection:Toggle("freddy_box", "Freddy Box", true)
    settingsSection:Toggle("bonnie_box", "Bonnie Box", true)
    settingsSection:Toggle("chica_box", "Chica Box", true)
    local infoSection = tab:Section("Info", "Right")
    infoSection:Text("Tracks Coins, Breakers, Car, Car Parts, Keys, Key Lock,")
    infoSection:Text("Freddy, Bonnie, and Chica.")
    infoSection:Text("Only Enable Entity Tracking After They've Spawned.")
    infoSection:Spacing()
    infoSection:Tip("by og_ten")
end)

notify("The Hour Of Creation loaded.", "The Hour Of Creation", 3)

local function GetModelPosition(model, preferredChild)
    if not model or not model.Parent then
        return nil
    end
    if preferredChild then
        local child = model:FindFirstChild(preferredChild)
        if child and child:IsA("BasePart") then
            return child.Position
        end
    end
    if model:IsA("BasePart") then
        return model.Position
    end
    if model:IsA("Model") then
        local part = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart", true)
            or model:FindFirstChildWhichIsA("BasePart", true)
        if part and part:IsA("BasePart") then
            return part.Position
        end
        local ok, pivot = pcall(function()
            return model:GetPivot()
        end)
        if ok and pivot then
            return pivot.Position
        end
    end
    return nil
end

local function GetLocksPosition(locks)
    if not locks or not locks.Parent then
        return nil
    end
    local positions = {}
    for i = 1, 8 do
        local lockPart = locks:FindFirstChild("Lock" .. i)
        if lockPart and lockPart:IsA("BasePart") then
            table.insert(positions, lockPart.Position)
        end
    end
    if #positions > 0 then
        local total = Vector3.new(0, 0, 0)
        for _, position in ipairs(positions) do
            total = total + position
        end
        return total / #positions
    end
    return GetModelPosition(locks)
end
local RunService = game:GetService("RunService")

local function UpdateTargets()
    for i = #CoinTargets, 1, -1 do
        local coin = CoinTargets[i]
        if not coin or not coin.Parent then
            if CoinDrawings[i] then
                CoinDrawings[i]:Remove()
                CoinDrawings[i] = nil
            end
            if CoinTexts[i] then
                CoinTexts[i]:Remove()
                CoinTexts[i] = nil
            end
            table.remove(CoinTargets, i)
            table.remove(CoinDrawings, i)
            table.remove(CoinTexts, i)
        end
    end
    for i = #BreakerTargets, 1, -1 do
        local breaker = BreakerTargets[i]
        if not breaker or not breaker.Parent then
            if BreakerDrawings[i] then
                BreakerDrawings[i]:Remove()
                BreakerDrawings[i] = nil
            end
            if BreakerTexts[i] then
                BreakerTexts[i]:Remove()
                BreakerTexts[i] = nil
            end
            table.remove(BreakerTargets, i)
            table.remove(BreakerDrawings, i)
            table.remove(BreakerTexts, i)
        end
    end
    for i = #KeyTargets, 1, -1 do
        local key = KeyTargets[i]
        if not key or not key.Parent then
            if KeyDrawings[i] then
                KeyDrawings[i]:Remove()
                KeyDrawings[i] = nil
            end
            if KeyTexts[i] then
                KeyTexts[i]:Remove()
                KeyTexts[i] = nil
            end
            table.remove(KeyTargets, i)
            table.remove(KeyDrawings, i)
            table.remove(KeyTexts, i)
        end
    end
    for i = #KeyLockTargets, 1, -1 do
        local lock = KeyLockTargets[i]
        if not lock or not lock.Parent then
            if KeyLockDrawings[i] then
                KeyLockDrawings[i]:Remove()
                KeyLockDrawings[i] = nil
            end
            if KeyLockTexts[i] then
                KeyLockTexts[i]:Remove()
                KeyLockTexts[i] = nil
            end
            table.remove(KeyLockTargets, i)
            table.remove(KeyLockDrawings, i)
            table.remove(KeyLockTexts, i)
        end
    end
    if FreddyTarget and not FreddyTarget.Parent then
        if FreddyDrawing then
            FreddyDrawing:Remove()
            FreddyDrawing = nil
        end
        if FreddyText then
            FreddyText:Remove()
            FreddyText = nil
        end
        FreddyTarget = nil
        notify("Freddy despawned. Toggle off and on to re-acquire.", "The Hour Of Creation", 3)
        UI.SetValue("freddy_enabled", false)
    end
    if BonnieTarget and not BonnieTarget.Parent then
        if BonnieDrawing then
            BonnieDrawing:Remove()
            BonnieDrawing = nil
        end
        if BonnieText then
            BonnieText:Remove()
            BonnieText = nil
        end
        BonnieTarget = nil
        notify("Bonnie despawned. Toggle off and on to re-acquire.", "The Hour Of Creation", 3)
        UI.SetValue("bonnie_enabled", false)
    end
end

RunService.RenderStepped:Connect(function()
    frameCounter = frameCounter + 1
    if frameCounter % UPDATE_INTERVAL ~= 0 then
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local camPos = camera.Position
    local showLabels = UI.GetValue("show_labels")
    local showDistance = UI.GetValue("show_distance")
    UpdateTargets()
    if UI.GetValue("coin_enabled") then
        local showBox = UI.GetValue("coin_box")
        for i, coin in ipairs(CoinTargets) do
            local square = CoinDrawings[i]
            local text = CoinTexts[i]
            if square and coin and coin.Parent then
                local pos = GetModelPosition(coin, "MainCoin")
                if pos then
                    local s, on = WorldToScreen(pos)
                    if on then
                        if showBox then
                            square.Position = s - Vector2.new(15, 15)
                            square.Visible = true
                        else
                            square.Visible = false
                        end
                        if text then
                            local dist = (pos - camPos).Magnitude
                            if showLabels and showDistance then
                                text.Text = string.format("Coin %.0f", dist)
                            elseif showLabels then
                                text.Text = "Coin"
                            elseif showDistance then
                                text.Text = string.format("%.0f", dist)
                            else
                                text.Text = ""
                            end
                            text.Position = s - Vector2.new(0, 22)
                            text.Visible = true
                        end
                    else
                        square.Visible = false
                        if text then text.Visible = false end
                    end
                end
            end
        end
    else
        for _, square in ipairs(CoinDrawings or {}) do
            if square then square.Visible = false end
        end
        for _, text in ipairs(CoinTexts or {}) do
            if text then text.Visible = false end
        end
    end
    if UI.GetValue("carparts_enabled") then
        local showCarPartBox = UI.GetValue("carparts_box")
        for i, part in ipairs(CarPartTargets) do
            local box = CarPartDrawings[i]
            local text = CarPartTexts[i]
            if part and part.Parent then
                local pos = part.Position
                if pos then
                    local screen, on = WorldToScreen(pos)
                    if on then
                        if box then
                            if showCarPartBox then
                                box.Position = screen - Vector2.new(15, 15)
                                box.Visible = true
                            else
                                box.Visible = false
                            end
                        end
                        if text then
                            local dist = (pos - camPos).Magnitude
                            if showLabels and showDistance then
                                text.Text = string.format("%s %.0f", part.Name, dist)
                            elseif showLabels then
                                text.Text = part.Name
                            elseif showDistance then
                                text.Text = string.format("%.0f", dist)
                            else
                                text.Text = ""
                            end
                            text.Position = screen - Vector2.new(0, 22)
                            text.Visible = true
                        end
                    else
                        if box then box.Visible = false end
                        if text then text.Visible = false end
                    end
                else
                    if box then box.Visible = false end
                    if text then text.Visible = false end
                end
            else
                if box then box.Visible = false end
                if text then text.Visible = false end
            end
        end
    else
        for _, box in ipairs(CarPartDrawings or {}) do
            if box then box.Visible = false end
        end
        for _, text in ipairs(CarPartTexts or {}) do
            if text then text.Visible = false end
        end
    end
    if UI.GetValue("car_enabled") and CarTarget and CarTarget.Parent and CarDrawing then
        local carPart = CarTarget:FindFirstChild("Body")
        local pos = nil
        if carPart and carPart.ClassName == "MeshPart" then
            pos = carPart.Position
        end
        if pos then
            local screen, on = WorldToScreen(pos)
            if on then
                if UI.GetValue("car_box") then
                    CarDrawing.Position = screen - Vector2.new(30, 30)
                    CarDrawing.Visible = true
                else
                    CarDrawing.Visible = false
                end
                if CarText then
                    local dist = (pos - camPos).Magnitude
                    if showLabels and showDistance then
                        CarText.Text = string.format("Car %.0f", dist)
                    elseif showLabels then
                        CarText.Text = "Car"
                    elseif showDistance then
                        CarText.Text = string.format("%.0f", dist)
                    else
                        CarText.Text = ""
                    end
                    CarText.Position = screen - Vector2.new(0, 37)
                    CarText.Visible = true
                end
            else
                CarDrawing.Visible = false
                if CarText then CarText.Visible = false end
            end
        end
    elseif CarDrawing then
        CarDrawing.Visible = false
        if CarText then CarText.Visible = false end
    end
    if UI.GetValue("breaker_enabled") then
        local showBox = UI.GetValue("breaker_box")
        for i, breaker in ipairs(BreakerTargets) do
            local box = BreakerDrawings[i]
            local text = BreakerTexts[i]
            if box and breaker and breaker.Parent then
                local breakerPart = breaker:FindFirstChild("Panel")
                    or breaker:FindFirstChild("Lever")
                local pos = nil
                if breakerPart and breakerPart.ClassName == "MeshPart" then
                    pos = breakerPart.Position
                end
                if pos then
                    local s, on = WorldToScreen(pos)
                    local validScreenPoint = s
                        and typeof(s) == "Vector2"
                        and s.X == s.X and s.Y == s.Y
                        and s.X > -100 and s.Y > -100
                        and s.X < camera.ViewportSize.X + 100
                        and s.Y < camera.ViewportSize.Y + 100
                    if on and validScreenPoint then
                        if showBox then
                            box.Position = s - Vector2.new(20, 20)
                            box.Visible = true
                        else
                            box.Visible = false
                        end
                        if text then
                            local dist = (pos - camPos).Magnitude
                            if showLabels and showDistance then
                                text.Text = string.format("Breaker %.0f", dist)
                            elseif showLabels then
                                text.Text = "Breaker"
                            elseif showDistance then
                                text.Text = string.format("%.0f", dist)
                            else
                                text.Text = ""
                            end
                            text.Position = s - Vector2.new(0, 27)
                            text.Visible = true
                        end
                    else
                        box.Visible = false
                        if text then text.Visible = false end
                    end
                end
            end
        end
    else
        for _, box in ipairs(BreakerDrawings or {}) do
            if box then box.Visible = false end
        end
        for _, text in ipairs(BreakerTexts or {}) do
            if text then text.Visible = false end
        end
    end
    if UI.GetValue("freddy_enabled") and FreddyTarget and FreddyTarget.Parent and FreddyDrawing then
        local freddyPart = FreddyTarget:FindFirstChild("HumanoidRootPart", true)
            or FreddyTarget:FindFirstChild("Head", true)
            or FreddyTarget:FindFirstChildWhichIsA("BasePart", true)
        local pos = freddyPart and freddyPart.Position or nil
        if pos then
            local s, on = WorldToScreen(pos)
            local validScreenPoint = s
                and typeof(s) == "Vector2"
                and s.X == s.X and s.Y == s.Y
                and s.X > -100 and s.Y > -100
                and s.X < camera.ViewportSize.X + 100
                and s.Y < camera.ViewportSize.Y + 100
            if on and validScreenPoint then
                if UI.GetValue("freddy_box") then
                    FreddyDrawing.Position = s - Vector2.new(30, 45)
                    FreddyDrawing.Visible = true
                else
                    FreddyDrawing.Visible = false
                end
                if FreddyText then
                    local dist = (pos - camPos).Magnitude
                    if showLabels and showDistance then
                        FreddyText.Text = string.format("Freddy %.0f", dist)
                    elseif showLabels then
                        FreddyText.Text = "Freddy"
                    elseif showDistance then
                        FreddyText.Text = string.format("%.0f", dist)
                    else
                        FreddyText.Text = ""
                    end
                    FreddyText.Position = s - Vector2.new(0, 52)
                    FreddyText.Visible = true
                end
            else
                FreddyDrawing.Visible = false
                if FreddyText then FreddyText.Visible = false end
            end
        end
    elseif FreddyDrawing then
        FreddyDrawing.Visible = false
        if FreddyText then FreddyText.Visible = false end
    end
    if UI.GetValue("bonnie_enabled") and BonnieTarget and BonnieTarget.Parent and BonnieDrawing then
        local bonniePart = BonnieTarget:FindFirstChild("HumanoidRootPart")
        local pos = bonniePart and bonniePart.Position or nil
        if pos then
            local s, on = WorldToScreen(pos)
            local validScreenPoint = s
                and typeof(s) == "Vector2"
                and s.X == s.X and s.Y == s.Y
                and s.X > -100 and s.Y > -100
                and s.X < camera.ViewportSize.X + 100
                and s.Y < camera.ViewportSize.Y + 100
            if on and validScreenPoint then
                if UI.GetValue("bonnie_box") then
                    BonnieDrawing.Position = s - Vector2.new(30, 45)
                    BonnieDrawing.Visible = true
                else
                    BonnieDrawing.Visible = false
                end
                if BonnieText then
                    local dist = (pos - camPos).Magnitude
                    if showLabels and showDistance then
                        BonnieText.Text = string.format("Bonnie %.0f", dist)
                    elseif showLabels then
                        BonnieText.Text = "Bonnie"
                    elseif showDistance then
                        BonnieText.Text = string.format("%.0f", dist)
                    else
                        BonnieText.Text = ""
                    end
                    BonnieText.Position = s - Vector2.new(0, 52)
                    BonnieText.Visible = true
                end
            else
                BonnieDrawing.Visible = false
                if BonnieText then BonnieText.Visible = false end
            end
        end
    elseif BonnieDrawing then
        BonnieDrawing.Visible = false
        if BonnieText then BonnieText.Visible = false end
    end
    if UI.GetValue("chica_enabled") and ChicaTarget and ChicaTarget.Parent and ChicaDrawing then
        local chicaPart = ChicaTarget:FindFirstChild("HumanoidRootPart")
        local pos = chicaPart and chicaPart.Position or nil
        if pos then
            local screen, on = WorldToScreen(pos)
            local validScreenPoint = screen
                and typeof(screen) == "Vector2"
                and screen.X == screen.X and screen.Y == screen.Y
                and screen.X > -100 and screen.Y > -100
                and screen.X < camera.ViewportSize.X + 100
                and screen.Y < camera.ViewportSize.Y + 100
            if on and validScreenPoint then
                if UI.GetValue("chica_box") then
                    ChicaDrawing.Position = screen - Vector2.new(30, 45)
                    ChicaDrawing.Visible = true
                else
                    ChicaDrawing.Visible = false
                end
                if ChicaText then
                    local dist = (pos - camPos).Magnitude
                    if showLabels and showDistance then
                        ChicaText.Text = string.format("Chica %.0f", dist)
                    elseif showLabels then
                        ChicaText.Text = "Chica"
                    elseif showDistance then
                        ChicaText.Text = string.format("%.0f", dist)
                    else
                        ChicaText.Text = ""
                    end
                    ChicaText.Position = screen - Vector2.new(0, 52)
                    ChicaText.Visible = true
                end
            else
                ChicaDrawing.Visible = false
                if ChicaText then ChicaText.Visible = false end
            end
        end
    elseif ChicaDrawing then
        ChicaDrawing.Visible = false
        if ChicaText then ChicaText.Visible = false end
    end
    if UI.GetValue("key_enabled") then
        local showBox = UI.GetValue("key_box")
        for i, key in ipairs(KeyTargets) do
            local square = KeyDrawings[i]
            local text = KeyTexts[i]
            if square and key and key.Parent then
                local pos = GetModelPosition(key, "Key")
                if pos then
                        local s, on = WorldToScreen(pos)
                        if on then
                            if showBox then
                                square.Position = s - Vector2.new(15, 15)
                                square.Visible = true
                            else
                                square.Visible = false
                            end
                            if text then
                                local dist = (pos - camPos).Magnitude
                                if showLabels and showDistance then
                                    text.Text = string.format("Key %.0f", dist)
                                elseif showLabels then
                                    text.Text = "Key"
                                elseif showDistance then
                                    text.Text = string.format("%.0f", dist)
                                else
                                    text.Text = ""
                                end
                                text.Position = s - Vector2.new(0, 22)
                                text.Visible = true
                            end
                        else
                            square.Visible = false
                            if text then text.Visible = false end
                        end
                    end
            end
        end
    else
        for _, square in ipairs(KeyDrawings or {}) do
            if square then square.Visible = false end
        end
        for _, text in ipairs(KeyTexts or {}) do
            if text then text.Visible = false end
        end
    end
    if UI.GetValue("keylock_enabled") then
        local showBox = UI.GetValue("keylock_box")
        for i, lock in ipairs(KeyLockTargets) do
            local square = KeyLockDrawings[i]
            local text = KeyLockTexts[i]
            if square and lock and lock.Parent then
                local pos = GetLocksPosition(lock)
                if pos then
                    local s, on = WorldToScreen(pos)
                    if on then
                        if showBox then
                            square.Position = s - Vector2.new(25, 35)
                            square.Visible = true
                        else
                            square.Visible = false
                        end
                        if text then
                            local dist = (pos - camPos).Magnitude
                            if showLabels and showDistance then
                                text.Text = string.format("Key Lock %.0f", dist)
                            elseif showLabels then
                                text.Text = "Key Lock"
                            elseif showDistance then
                                text.Text = string.format("%.0f", dist)
                            else
                                text.Text = ""
                            end
                            text.Position = s - Vector2.new(0, 42)
                            text.Visible = true
                        end
                    else
                        square.Visible = false
                        if text then text.Visible = false end
                    end
                end
            end
        end
    else
        for _, square in ipairs(KeyLockDrawings or {}) do
            if square then square.Visible = false end
        end
        for _, text in ipairs(KeyLockTexts or {}) do
            if text then text.Visible = false end
        end
    end
end)
while true do wait(60) end
