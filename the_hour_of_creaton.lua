local DEFAULT_COIN = Color3.fromRGB(255, 215, 0)
local DEFAULT_BREAKER = Color3.fromRGB(255, 165, 0)
local DEFAULT_FREDDY = Color3.fromRGB(255, 0, 0)
local DEFAULT_BONNIE = Color3.fromRGB(128, 0, 255)
local DEFAULT_KEY = Color3.fromRGB(255, 255, 0)
local DEFAULT_KEYLOCK = Color3.fromRGB(0, 255, 200)

local COLOR_FILE = "thoc_colors.json"

local function LoadSavedColors()
    local colors = {
        COIN = DEFAULT_COIN,
        BREAKER = DEFAULT_BREAKER,
        FREDDY = DEFAULT_FREDDY,
        BONNIE = DEFAULT_BONNIE,
        KEY = DEFAULT_KEY,
        KEYLOCK = DEFAULT_KEYLOCK
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
        KEYLOCK = {colors.KEYLOCK.R, colors.KEYLOCK.G, colors.KEYLOCK.B}
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

local CoinTargets = {}
local BreakerTargets = {}
local FreddyTarget = nil
local BonnieTarget = nil
local KeyTargets = {}
local KeyLockTargets = {}

local CoinDrawings = {}
local BreakerDrawings = {}
local FreddyDrawing = nil
local BonnieDrawing = nil
local KeyDrawings = {}
local KeyLockDrawings = {}

local CoinTexts = {}
local BreakerTexts = {}
local FreddyText = nil
local BonnieText = nil
local KeyTexts = {}
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
        local gameFolder = workspace:FindFirstChild("Game")
        if gameFolder then
            local mapFolder = gameFolder:FindFirstChild("Map")
            if mapFolder then
                local objectivesFolder = mapFolder:FindFirstChild("Objectives")
                if objectivesFolder then
                    local breakersFolder = objectivesFolder:FindFirstChild("Breakers")
                    if breakersFolder then
                        for _, child in ipairs(breakersFolder:GetChildren()) do
                            if child:IsA("Model") and child.Name == "Breaker" then
                                table.insert(BreakerTargets, child)
                            end
                        end
                    end
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
UI.SetValue("show_labels", true)
UI.SetValue("show_distance", true)

UI.SetValue("coin_box", true)
UI.SetValue("breaker_box", true)
UI.SetValue("freddy_box", true)
UI.SetValue("bonnie_box", true)
UI.SetValue("key_box", true)
UI.SetValue("keylock_box", true)

UI.AddTab("The Hour Of Creation", function(tab)
    local itemsSection = tab:Section("Items", "Left")
    
    itemsSection:Toggle("coin_enabled", "Track Coins", false, function(state)
        if state and #CoinTargets == 0 then ScanCoins() end
    end)
    itemsSection:ColorPicker("coin_color", COIN_COLOR.R, COIN_COLOR.G, COIN_COLOR.B, 1, function(color, alpha)
        COIN_COLOR = color
        COLORS.COIN = color
        SaveColors(COLORS)
        for _, draw in ipairs(CoinDrawings) do
            if draw then draw.Color = color end
        end
        for _, text in ipairs(CoinTexts) do
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
        for _, draw in ipairs(BreakerDrawings) do
            if draw then draw.Color = color end
        end
        for _, text in ipairs(BreakerTexts) do
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
        for _, draw in ipairs(KeyDrawings) do
            if draw then draw.Color = color end
        end
        for _, text in ipairs(KeyTexts) do
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
        for _, draw in ipairs(KeyLockDrawings) do
            if draw then draw.Color = color end
        end
        for _, text in ipairs(KeyLockTexts) do
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
    
    local settingsSection = tab:Section("Settings", "Right")
    settingsSection:Text("ESP Settings")
    settingsSection:Toggle("show_labels", "Show Labels", true)
    settingsSection:Toggle("show_distance", "Show Distance", true)
    settingsSection:Spacing()
    settingsSection:Toggle("coin_box", "Coin Box", true)
    settingsSection:Toggle("breaker_box", "Breaker Box", true)
    settingsSection:Toggle("key_box", "Key Box", true)
    settingsSection:Toggle("keylock_box", "Key Lock Box", true)
    settingsSection:Toggle("freddy_box", "Freddy Box", true)
    settingsSection:Toggle("bonnie_box", "Bonnie Box", true)
    
    local infoSection = tab:Section("Info", "Right")
    infoSection:Text("Tracks Coins, Breakers, Keys, Key Lock,")
    infoSection:Text("Freddy, and Bonnie.")
    infoSection:Text("Only Enable Entity Tracking After They've Spawned.")
    infoSection:Spacing()
    infoSection:Tip("by og_ten")
end)

notify("The Hour Of Creation loaded.", "The Hour Of Creation", 3)

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
                local pos = coin.PrimaryPart and coin.PrimaryPart.Position or coin.Position
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
        for _, square in ipairs(CoinDrawings) do
            if square then square.Visible = false end
        end
        for _, text in ipairs(CoinTexts) do
            if text then text.Visible = false end
        end
    end
    
    if UI.GetValue("breaker_enabled") then
        local showBox = UI.GetValue("breaker_box")
        for i, breaker in ipairs(BreakerTargets) do
            local box = BreakerDrawings[i]
            local text = BreakerTexts[i]
            if box and breaker and breaker.Parent then
                local pos = breaker.PrimaryPart and breaker.PrimaryPart.Position or breaker.Position
                if pos then
                    local s, on = WorldToScreen(pos)
                    if on then
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
        for _, box in ipairs(BreakerDrawings) do
            if box then box.Visible = false end
        end
        for _, text in ipairs(BreakerTexts) do
            if text then text.Visible = false end
        end
    end
    
    if UI.GetValue("freddy_enabled") and FreddyTarget and FreddyTarget.Parent and FreddyDrawing then
        local pos = FreddyTarget.PrimaryPart and FreddyTarget.PrimaryPart.Position or FreddyTarget.Position
        if pos then
            local s, on = WorldToScreen(pos)
            if on then
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
        local pos = BonnieTarget.PrimaryPart and BonnieTarget.PrimaryPart.Position or BonnieTarget.Position
        if pos then
            local s, on = WorldToScreen(pos)
            if on then
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
    
    if UI.GetValue("key_enabled") then
        local showBox = UI.GetValue("key_box")
        for i, key in ipairs(KeyTargets) do
            local square = KeyDrawings[i]
            local text = KeyTexts[i]
            if square and key and key.Parent then
                local meshPart = key:FindFirstChild("Key")
                if meshPart then
                    local pos = meshPart.Position
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
        end
    else
        for _, square in ipairs(KeyDrawings) do
            if square then square.Visible = false end
        end
        for _, text in ipairs(KeyTexts) do
            if text then text.Visible = false end
        end
    end
    
    if UI.GetValue("keylock_enabled") then
        local showBox = UI.GetValue("keylock_box")
        for i, lock in ipairs(KeyLockTargets) do
            local square = KeyLockDrawings[i]
            local text = KeyLockTexts[i]
            if square and lock and lock.Parent then
                local pos = nil
                for j = 1, 8 do
                    local meshPart = lock:FindFirstChild("Lock" .. j)
                    if meshPart then
                        pos = meshPart.Position
                        break
                    end
                end
                
                if not pos then
                    pos = lock.Position
                end
                
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
        for _, square in ipairs(KeyLockDrawings) do
            if square then square.Visible = false end
        end
        for _, text in ipairs(KeyLockTexts) do
            if text then text.Visible = false end
        end
    end
end)

while true do wait(60) end
