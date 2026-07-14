local DEFAULT_FUSE = Color3.fromRGB(100, 255, 100)
local DEFAULT_COIN = Color3.fromRGB(255, 215, 0)
local DEFAULT_FUSEBOX = Color3.fromRGB(0, 200, 255)
local DEFAULT_BREAKER = Color3.fromRGB(255, 165, 0)
local DEFAULT_FREDDY = Color3.fromRGB(255, 0, 0)

local COLOR_FILE = "thoc_colors.json"

local function LoadSavedColors()
    local colors = {
        FUSE = DEFAULT_FUSE,
        COIN = DEFAULT_COIN,
        FUSEBOX = DEFAULT_FUSEBOX,
        BREAKER = DEFAULT_BREAKER,
        FREDDY = DEFAULT_FREDDY
    }
    
    if isfile and isfile(COLOR_FILE) then
        local success, data = pcall(readfile, COLOR_FILE)
        if success and data then
            local parsed = game:GetService("HttpService"):JSONDecode(data)
            if parsed then
                if parsed.FUSE then colors.FUSE = Color3.fromRGB(parsed.FUSE[1]*255, parsed.FUSE[2]*255, parsed.FUSE[3]*255) end
                if parsed.COIN then colors.COIN = Color3.fromRGB(parsed.COIN[1]*255, parsed.COIN[2]*255, parsed.COIN[3]*255) end
                if parsed.FUSEBOX then colors.FUSEBOX = Color3.fromRGB(parsed.FUSEBOX[1]*255, parsed.FUSEBOX[2]*255, parsed.FUSEBOX[3]*255) end
                if parsed.BREAKER then colors.BREAKER = Color3.fromRGB(parsed.BREAKER[1]*255, parsed.BREAKER[2]*255, parsed.BREAKER[3]*255) end
                if parsed.FREDDY then colors.FREDDY = Color3.fromRGB(parsed.FREDDY[1]*255, parsed.FREDDY[2]*255, parsed.FREDDY[3]*255) end
            end
        end
    end
    return colors
end

local function SaveColors(colors)
    local data = game:GetService("HttpService"):JSONEncode({
        FUSE = {colors.FUSE.R, colors.FUSE.G, colors.FUSE.B},
        COIN = {colors.COIN.R, colors.COIN.G, colors.COIN.B},
        FUSEBOX = {colors.FUSEBOX.R, colors.FUSEBOX.G, colors.FUSEBOX.B},
        BREAKER = {colors.BREAKER.R, colors.BREAKER.G, colors.BREAKER.B},
        FREDDY = {colors.FREDDY.R, colors.FREDDY.G, colors.FREDDY.B}
    })
    if writefile then
        writefile(COLOR_FILE, data)
    end
end

local COLORS = LoadSavedColors()

local FUSE_COLOR = COLORS.FUSE
local COIN_COLOR = COLORS.COIN
local FUSEBOX_COLOR = COLORS.FUSEBOX
local BREAKER_COLOR = COLORS.BREAKER
local FREDDY_COLOR = COLORS.FREDDY

local FuseTargets = {}
local CoinTargets = {}
local FuseBoxTargets = nil
local BreakerTargets = {}
local FreddyTarget = nil

local FuseDrawings = {}
local CoinDrawings = {}
local FuseBoxDrawings = {}
local BreakerDrawings = {}
local FreddyDrawing = nil

local FuseTexts = {}
local CoinTexts = {}
local FuseBoxTexts = {}
local BreakerTexts = {}
local FreddyText = nil

local frameCounter = 0
local UPDATE_INTERVAL = 2

local function ScanChunked(container, targetTable, filterFunc)
    local function Scan(container)
        local count = 0
        for _, child in ipairs(container:GetChildren()) do
            if filterFunc(child) then
                table.insert(targetTable, child)
            end
            if child:IsA("Model") or child:IsA("Folder") then
                Scan(child)
            end
            count = count + 1
            if count % 100 == 0 then
                task.wait()
            end
        end
    end
    Scan(container)
end

local function ScanFuses()
    task.spawn(function()
        local function filter(child)
            return child:IsA("Model") and child.Name == "Fuse"
        end
        ScanChunked(workspace, FuseTargets, filter)
        
        for i = 1, #FuseTargets do
            if not FuseDrawings[i] then
                local square = Drawing.new("Square")
                square.Size = Vector2.new(34, 34)
                square.Color = FUSE_COLOR
                square.Transparency = 1
                square.Filled = false
                square.Thickness = 2
                square.ZIndex = 999
                square.Visible = false
                FuseDrawings[i] = square
                
                local text = Drawing.new("Text")
                text.Font = Drawing.Fonts.UI
                text.Size = 12
                text.Color = FUSE_COLOR
                text.Outline = false
                text.Center = true
                text.ZIndex = 999
                text.Visible = false
                FuseTexts[i] = text
            end
        end
        notify("Fuses found: " .. #FuseTargets, "The Hour Of Creation", 3)
    end)
end

local function ScanCoins()
    task.spawn(function()
        local function filter(child)
            return child:IsA("Model") and string.lower(child.Name):find("smallcoins")
        end
        ScanChunked(workspace, CoinTargets, filter)
        
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

local function ScanFuseBox()
    task.spawn(function()
        local gameFolder = workspace:FindFirstChild("Game")
        if gameFolder then
            local mapFolder = gameFolder:FindFirstChild("Map")
            if mapFolder then
                local objectivesFolder = mapFolder:FindFirstChild("Objectives")
                if objectivesFolder then
                    local fusesFolder = objectivesFolder:FindFirstChild("Fuses")
                    if fusesFolder then
                        FuseBoxTargets = fusesFolder:FindFirstChild("FuseBox")
                    end
                end
            end
        end
        
        if FuseBoxTargets then
            if not FuseBoxDrawings[1] then
                FuseBoxDrawings[1] = Drawing.new("Square")
                FuseBoxDrawings[1].Size = Vector2.new(50, 50)
                FuseBoxDrawings[1].Color = FUSEBOX_COLOR
                FuseBoxDrawings[1].Transparency = 1
                FuseBoxDrawings[1].Filled = false
                FuseBoxDrawings[1].Thickness = 3
                FuseBoxDrawings[1].ZIndex = 999
                FuseBoxDrawings[1].Visible = false
                
                FuseBoxTexts[1] = Drawing.new("Text")
                FuseBoxTexts[1].Font = Drawing.Fonts.UI
                FuseBoxTexts[1].Size = 12
                FuseBoxTexts[1].Color = FUSEBOX_COLOR
                FuseBoxTexts[1].Outline = false
                FuseBoxTexts[1].Center = true
                FuseBoxTexts[1].ZIndex = 999
                FuseBoxTexts[1].Visible = false
            end
            notify("FuseBox found!", "The Hour Of Creation", 3)
        else
            notify("FuseBox not found!", "The Hour Of Creation", 3)
        end
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

UI.SetValue("fuse_enabled", false)
UI.SetValue("coin_enabled", false)
UI.SetValue("fusebox_enabled", false)
UI.SetValue("freddy_enabled", false)
UI.SetValue("breaker_enabled", false)
UI.SetValue("show_labels", true)
UI.SetValue("show_distance", true)

UI.SetValue("fuse_box", true)
UI.SetValue("coin_box", true)
UI.SetValue("fusebox_box", true)
UI.SetValue("breaker_box", true)
UI.SetValue("freddy_box", true)

UI.AddTab("The Hour Of Creation", function(tab)
    local itemsSection = tab:Section("Items", "Left")
    
    itemsSection:Toggle("fuse_enabled", "Track Fuses", false, function(state)
        if state and #FuseTargets == 0 then ScanFuses() end
    end)
    itemsSection:ColorPicker("fuse_color", FUSE_COLOR.R, FUSE_COLOR.G, FUSE_COLOR.B, 1, function(color, alpha)
        FUSE_COLOR = color
        COLORS.FUSE = color
        SaveColors(COLORS)
        for _, draw in ipairs(FuseDrawings) do
            if draw then draw.Color = color end
        end
        for _, text in ipairs(FuseTexts) do
            if text then text.Color = color end
        end
    end)
    
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
    
    itemsSection:Toggle("fusebox_enabled", "Track FuseBox", false, function(state)
        if state and not FuseBoxTargets then ScanFuseBox() end
    end)
    itemsSection:ColorPicker("fusebox_color", FUSEBOX_COLOR.R, FUSEBOX_COLOR.G, FUSEBOX_COLOR.B, 1, function(color, alpha)
        FUSEBOX_COLOR = color
        COLORS.FUSEBOX = color
        SaveColors(COLORS)
        if FuseBoxDrawings[1] then FuseBoxDrawings[1].Color = color end
        if FuseBoxTexts[1] then FuseBoxTexts[1].Color = color end
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
    
    local freddySection = tab:Section("Freddy", "Right")
    freddySection:Toggle("freddy_enabled", "Track Freddy", false, function(state)
        if state and not FreddyTarget then ScanFreddy() end
    end)
    freddySection:ColorPicker("freddy_color", FREDDY_COLOR.R, FREDDY_COLOR.G, FREDDY_COLOR.B, 1, function(color, alpha)
        FREDDY_COLOR = color
        COLORS.FREDDY = color
        SaveColors(COLORS)
        if FreddyDrawing then FreddyDrawing.Color = color end
        if FreddyText then FreddyText.Color = color end
    end)
    
    local settingsSection = tab:Section("Settings", "Right")
    settingsSection:Text("ESP Settings")
    settingsSection:Toggle("show_labels", "Show Labels", true)
    settingsSection:Toggle("show_distance", "Show Distance", true)
    settingsSection:Spacing()
    settingsSection:Toggle("fuse_box", "Fuse Box", true)
    settingsSection:Toggle("coin_box", "Coin Box", true)
    settingsSection:Toggle("fusebox_box", "FuseBox Box", true)
    settingsSection:Toggle("breaker_box", "Breaker Box", true)
    settingsSection:Toggle("freddy_box", "Freddy Box", true)
    
    local infoSection = tab:Section("Info", "Right")
    infoSection:Text("Tracks Fuses, Coins, FuseBox, Breakers, and Freddy.")
    infoSection:Text("Only Enable 'Track Freddy' Once He's Spawned.")
    infoSection:Spacing()
    infoSection:Tip("by og_ten")
end)

notify("The Hour Of Creation loaded.", "The Hour Of Creation", 3)

local RunService = game:GetService("RunService")

local function UpdateTargets()
    for i = #FuseTargets, 1, -1 do
        local fuse = FuseTargets[i]
        if not fuse or not fuse.Parent then
            if FuseDrawings[i] then
                FuseDrawings[i]:Remove()
                FuseDrawings[i] = nil
            end
            if FuseTexts[i] then
                FuseTexts[i]:Remove()
                FuseTexts[i] = nil
            end
            table.remove(FuseTargets, i)
            table.remove(FuseDrawings, i)
            table.remove(FuseTexts, i)
        end
    end
    
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
    
    if FuseBoxTargets and not FuseBoxTargets.Parent then
        if FuseBoxDrawings[1] then
            FuseBoxDrawings[1]:Remove()
            FuseBoxDrawings[1] = nil
        end
        if FuseBoxTexts[1] then
            FuseBoxTexts[1]:Remove()
            FuseBoxTexts[1] = nil
        end
        FuseBoxTargets = nil
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
    
    if UI.GetValue("fuse_enabled") then
        local showBox = UI.GetValue("fuse_box")
        for i, fuse in ipairs(FuseTargets) do
            local square = FuseDrawings[i]
            local text = FuseTexts[i]
            if square and fuse and fuse.Parent then
                local pos = fuse.PrimaryPart and fuse.PrimaryPart.Position or fuse.Position
                if pos then
                    local s, on = WorldToScreen(pos)
                    if on then
                        if showBox then
                            square.Position = s - Vector2.new(17, 17)
                            square.Visible = true
                        else
                            square.Visible = false
                        end
                        
                        if text then
                            local dist = (pos - camPos).Magnitude
                            if showLabels and showDistance then
                                text.Text = string.format("Fuse %.0f", dist)
                            elseif showLabels then
                                text.Text = "Fuse"
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
        for _, square in ipairs(FuseDrawings) do
            if square then square.Visible = false end
        end
        for _, text in ipairs(FuseTexts) do
            if text then text.Visible = false end
        end
    end
    
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
    
    if UI.GetValue("fusebox_enabled") and FuseBoxTargets and FuseBoxTargets.Parent then
        local box = FuseBoxDrawings[1]
        local text = FuseBoxTexts[1]
        if box then
            local pos = FuseBoxTargets.PrimaryPart and FuseBoxTargets.PrimaryPart.Position or FuseBoxTargets.Position
            if pos then
                local s, on = WorldToScreen(pos)
                if on then
                    if UI.GetValue("fusebox_box") then
                        box.Position = s - Vector2.new(25, 25)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                    
                    if text then
                        local dist = (pos - camPos).Magnitude
                        if showLabels and showDistance then
                            text.Text = string.format("FuseBox %.0f", dist)
                        elseif showLabels then
                            text.Text = "FuseBox"
                        elseif showDistance then
                            text.Text = string.format("%.0f", dist)
                        else
                            text.Text = ""
                        end
                        text.Position = s - Vector2.new(0, 32)
                        text.Visible = true
                    end
                else
                    box.Visible = false
                    if text then text.Visible = false end
                end
            end
        end
    elseif FuseBoxDrawings[1] then
        FuseBoxDrawings[1].Visible = false
        if FuseBoxTexts[1] then FuseBoxTexts[1].Visible = false end
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
end)

while true do wait(60) end
