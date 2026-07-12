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
                local circle = Drawing.new("Circle")
                circle.Radius = 8
                circle.Color = Color3.fromRGB(100, 255, 100)
                circle.Transparency = 0.15
                circle.Filled = true
                circle.ZIndex = 999
                circle.Visible = false
                FuseDrawings[i] = circle
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
                local dot = Drawing.new("Circle")
                dot.Radius = 6
                dot.Color = Color3.fromRGB(255, 215, 0)
                dot.Transparency = 0.2
                dot.Filled = true
                dot.ZIndex = 999
                dot.Visible = false
                CoinDrawings[i] = dot
            end
        end
        notify("SmallCoins found: " .. #CoinTargets, "The Hour Of Creation", 3)
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
                FuseBoxDrawings[1].Color = Color3.fromRGB(0, 200, 255)
                FuseBoxDrawings[1].Transparency = 0.2
                FuseBoxDrawings[1].Filled = false
                FuseBoxDrawings[1].Thickness = 3
                FuseBoxDrawings[1].ZIndex = 999
                FuseBoxDrawings[1].Visible = false
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
                box.Color = Color3.fromRGB(255, 165, 0)
                box.Transparency = 0.15
                box.Filled = false
                box.Thickness = 2
                box.ZIndex = 999
                box.Visible = false
                BreakerDrawings[i] = box
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
                FreddyDrawing.Color = Color3.fromRGB(255, 0, 0)
                FreddyDrawing.Transparency = 0.2
                FreddyDrawing.Filled = false
                FreddyDrawing.Thickness = 3
                FreddyDrawing.ZIndex = 999
                FreddyDrawing.Visible = true
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

UI.AddTab("The Hour Of Creation", function(tab)
    local itemsSection = tab:Section("Items", "Left")
    itemsSection:Toggle("fuse_enabled", "Track Fuses", false, function(state)
        if state and #FuseTargets == 0 then ScanFuses() end
    end)
    itemsSection:Toggle("coin_enabled", "Track SmallCoins", false, function(state)
        if state and #CoinTargets == 0 then ScanCoins() end
    end)
    itemsSection:Toggle("fusebox_enabled", "Track FuseBox", false, function(state)
        if state and not FuseBoxTargets then ScanFuseBox() end
    end)
    itemsSection:Toggle("breaker_enabled", "Track Breakers", false, function(state)
        if state and #BreakerTargets == 0 then ScanBreakers() end
    end)
    
    local freddySection = tab:Section("Freddy", "Right")
    freddySection:Toggle("freddy_enabled", "Track Freddy", false, function(state)
        if state and not FreddyTarget then ScanFreddy() end
    end)
    freddySection:Tip("Only enable once Freddy has spawned in.")
    
    local infoSection = tab:Section("Info", "Right")
    infoSection:Text("The Hour Of Creation")
    infoSection:Spacing()
    infoSection:Text("Tracks Fuses, SmallCoins, FuseBox, Breakers, and Freddy.")
    infoSection:Spacing()
    infoSection:Text("Fuses: Lime Green Circles")
    infoSection:Text("SmallCoins: Gold Circles")
    infoSection:Text("FuseBox: Cyan Square")
    infoSection:Text("Breakers: Orange Squares")
    infoSection:Text("Freddy: Red Square")
    infoSection:Spacing()
    infoSection:Text("by og_ten")
end)

notify("The Hour Of Creation loaded.", "The Hour Of Creation", 3)

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function UpdateTargets()
    for i = #FuseTargets, 1, -1 do
        local fuse = FuseTargets[i]
        if not fuse or not fuse.Parent then
            if FuseDrawings[i] then
                FuseDrawings[i]:Remove()
                FuseDrawings[i] = nil
            end
            table.remove(FuseTargets, i)
            table.remove(FuseDrawings, i)
        end
    end
    
    for i = #CoinTargets, 1, -1 do
        local coin = CoinTargets[i]
        if not coin or not coin.Parent then
            if CoinDrawings[i] then
                CoinDrawings[i]:Remove()
                CoinDrawings[i] = nil
            end
            table.remove(CoinTargets, i)
            table.remove(CoinDrawings, i)
        end
    end
    
    if FuseBoxTargets and not FuseBoxTargets.Parent then
        if FuseBoxDrawings[1] then
            FuseBoxDrawings[1]:Remove()
            FuseBoxDrawings[1] = nil
        end
        FuseBoxTargets = nil
        notify("FuseBox was picked up/removed.", "The Hour Of Creation", 2)
    end
    
    for i = #BreakerTargets, 1, -1 do
        local breaker = BreakerTargets[i]
        if not breaker or not breaker.Parent then
            if BreakerDrawings[i] then
                BreakerDrawings[i]:Remove()
                BreakerDrawings[i] = nil
            end
            table.remove(BreakerTargets, i)
            table.remove(BreakerDrawings, i)
        end
    end
    
    if FreddyTarget and not FreddyTarget.Parent then
        if FreddyDrawing then
            FreddyDrawing:Remove()
            FreddyDrawing = nil
        end
        FreddyTarget = nil
        notify("Freddy despawned. Toggle off and on to re-acquire.", "The Hour Of Creation", 3)
        UI.SetValue("freddy_enabled", false)
    end
end

RunService.RenderStepped:Connect(function()
    UpdateTargets()
    
    if UI.GetValue("fuse_enabled") then
        for i, fuse in ipairs(FuseTargets) do
            local circle = FuseDrawings[i]
            if circle and fuse and fuse.Parent then
                local pos = fuse.PrimaryPart and fuse.PrimaryPart.Position or fuse.Position
                if pos then
                    local s, on = WorldToScreen(pos)
                    if on then
                        circle.Position = s
                        circle.Visible = true
                    else
                        circle.Visible = false
                    end
                end
            end
        end
    else
        for _, circle in ipairs(FuseDrawings) do
            if circle then circle.Visible = false end
        end
    end
    
    if UI.GetValue("coin_enabled") then
        for i, coin in ipairs(CoinTargets) do
            local dot = CoinDrawings[i]
            if dot and coin and coin.Parent then
                local pos = coin.PrimaryPart and coin.PrimaryPart.Position or coin.Position
                if pos then
                    local s, on = WorldToScreen(pos)
                    if on then
                        dot.Position = s
                        dot.Visible = true
                    else
                        dot.Visible = false
                    end
                end
            end
        end
    else
        for _, dot in ipairs(CoinDrawings) do
            if dot then dot.Visible = false end
        end
    end
    
    if UI.GetValue("fusebox_enabled") and FuseBoxTargets and FuseBoxTargets.Parent then
        local box = FuseBoxDrawings[1]
        if box then
            local pos = FuseBoxTargets.PrimaryPart and FuseBoxTargets.PrimaryPart.Position or FuseBoxTargets.Position
            if pos then
                local s, on = WorldToScreen(pos)
                if on then
                    box.Position = s - Vector2.new(25, 25)
                    box.Visible = true
                else
                    box.Visible = false
                end
            end
        end
    elseif FuseBoxDrawings[1] then
        FuseBoxDrawings[1].Visible = false
    end
    
    if UI.GetValue("breaker_enabled") then
        for i, breaker in ipairs(BreakerTargets) do
            local box = BreakerDrawings[i]
            if box and breaker and breaker.Parent then
                local pos = breaker.PrimaryPart and breaker.PrimaryPart.Position or breaker.Position
                if pos then
                    local s, on = WorldToScreen(pos)
                    if on then
                        box.Position = s - Vector2.new(20, 20)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                end
            end
        end
    else
        for _, box in ipairs(BreakerDrawings) do
            if box then box.Visible = false end
        end
    end
    
    if UI.GetValue("freddy_enabled") and FreddyTarget and FreddyTarget.Parent and FreddyDrawing then
        local pos = FreddyTarget.PrimaryPart and FreddyTarget.PrimaryPart.Position or FreddyTarget.Position
        if pos then
            local s, on = WorldToScreen(pos)
            if on then
                FreddyDrawing.Position = s - Vector2.new(30, 45)
                FreddyDrawing.Visible = true
            else
                FreddyDrawing.Visible = false
            end
        end
    elseif FreddyDrawing then
        FreddyDrawing.Visible = false
    end
end)

while true do wait(60) end