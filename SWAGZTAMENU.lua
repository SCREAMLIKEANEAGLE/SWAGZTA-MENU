-- SWAGZTA MENU MADE BY SCREAMLIKEANEAGLE
-- TO CHANGE AIMBOT KEY GO TO LINE 107
-- IF SOME PEOPLE DOESN'T SHOW UP ON DA ESP, THEY R A BOT


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer


local MenuOpen = false


local Settings = {
    ESPEnabled = true,
    BoxEnabled = true,
    BoxSizeMultiplier = 1.0,
    NameEnabled = true,
    HealthEnabled = true,
    DistanceEnabled = true,
    TracerEnabled = true,
    HeadDotEnabled = true,
    HeadDotSize = 3,
    SkeletonEnabled = true,
    AimbotEnabled = true,
    AimbotSmoothness = 5,
    AimbotFOV = 90,
    AimbotFOVVisible = true,
    AimbotPredict = true,
    AimbotAimPart = "Head",
    AimbotVisibleCheck = true,
    AimbotTeamCheck = false,
    AimbotMaxDistance = 500,
    WallhackEnabled = false,
    ShootThruWalls = false
}


local Drawings = {}

function ClearDrawings()
    for _, obj in pairs(Drawings) do
        pcall(function() obj:Remove() end)
    end
    Drawings = {}
end

function GetPlayers()
    local list = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            table.insert(list, v)
        end
    end
    return list
end

function IsPlayerValid(player)
    if not player then return false end
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if Settings.AimbotTeamCheck and player.Team == LocalPlayer.Team then return false end
    return true
end

function GetClosestPlayer()
    local closest = nil
    local closestDist = Settings.AimbotFOV
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(GetPlayers()) do
        if not IsPlayerValid(player) then continue end
        
        local aimPart = player.Character:FindFirstChild(Settings.AimbotAimPart)
        if not aimPart then aimPart = player.Character:FindFirstChild("Head") end
        if not aimPart then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < closestDist then
            if Settings.AimbotVisibleCheck and not Settings.ShootThruWalls then
                local origin = Camera.CFrame.Position
                local dir = (aimPart.Position - origin).Unit * Settings.AimbotMaxDistance
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Blacklist
                params.FilterDescendantsInstances = {LocalPlayer.Character}
                local result = workspace:Raycast(origin, dir, params)
                if result and result.Instance:IsDescendantOf(player.Character) then
                    closest = player
                    closestDist = dist
                end
            else
                closest = player
                closestDist = dist
            end
        end
    end
    return closest
end

function DoAimbot()
    if not Settings.AimbotEnabled then return end
    if not UserInputService:IsKeyDown(Enum.KeyCode.Q) then return end
    if MenuOpen then return end
    
    local target = GetClosestPlayer()
    if not target then return end
    
    local aimPart = target.Character:FindFirstChild(Settings.AimbotAimPart)
    if not aimPart then aimPart = target.Character:FindFirstChild("Head") end
    if not aimPart then return end
    
    local targetPos = aimPart.Position
    if Settings.AimbotPredict and target.Character:FindFirstChild("HumanoidRootPart") then
        local vel = target.Character.HumanoidRootPart.Velocity
        targetPos = targetPos + vel * 0.2
    end
    
    local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1 / Settings.AimbotSmoothness)
end

function GetBox(player)
    local char = player.Character
    if not char then return nil end
    
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not head or not root then return nil end
    
    local headPos = Camera:WorldToViewportPoint(head.Position)
    local rootPos = Camera:WorldToViewportPoint(root.Position)
    
    if headPos.Z <= 0 and rootPos.Z <= 0 then return nil end
    
    local height = math.abs(headPos.Y - rootPos.Y) * 2.2 * Settings.BoxSizeMultiplier
    local width = height * 0.5
    local topX = headPos.X - width / 2
    local topY = headPos.Y - height * 0.2
    
    return {
        X = topX,
        Y = topY,
        W = width,
        H = height,
        OnScreen = (headPos.Z > 0 or rootPos.Z > 0)
    }
end

function DrawESP()
    if not Settings.ESPEnabled then return end
    if MenuOpen then return end
    
    for _, player in pairs(GetPlayers()) do
        if not IsPlayerValid(player) then continue end
        
        local box = GetBox(player)
        if not box or not box.OnScreen then continue end
        
        local char = player.Character
        local humanoid = char:FindFirstChild("Humanoid")
        local health = humanoid and (humanoid.Health / humanoid.MaxHealth) or 1
        
        local espColor = Color3.fromRGB(0, 255, 255)
        if Settings.ShootThruWalls then
            espColor = Color3.fromRGB(255, 0, 255)
        elseif Settings.WallhackEnabled then
            espColor = Color3.fromRGB(255, 100, 0)
        end
        
        
        if Settings.BoxEnabled then
            local square = Drawing.new("Square")
            square.Position = Vector2.new(box.X, box.Y)
            square.Size = Vector2.new(box.W, box.H)
            square.Color = espColor
            square.Thickness = 2
            square.Transparency = 0.5
            square.Filled = false
            square.Visible = true
            table.insert(Drawings, square)
        end
        
        
        if Settings.NameEnabled then
            local text = Drawing.new("Text")
            text.Text = player.Name
            text.Position = Vector2.new(box.X + box.W/2, box.Y - 12)
            text.Color = Color3.fromRGB(255, 255, 255)
            text.Size = 12
            text.Center = true
            text.Outline = true
            text.Visible = true
            table.insert(Drawings, text)
        end
        
        
        if Settings.HealthEnabled then
            local healthBar = Drawing.new("Line")
            local barHeight = box.H * health
            healthBar.From = Vector2.new(box.X - 4, box.Y + box.H)
            healthBar.To = Vector2.new(box.X - 4, box.Y + box.H - barHeight)
            healthBar.Color = Color3.fromRGB(0, 255 * health, 255 * (1 - health))
            healthBar.Thickness = 3
            healthBar.Visible = true
            table.insert(Drawings, healthBar)
            
            local healthText = Drawing.new("Text")
            healthText.Text = string.format("%.0f", health * 100)
            healthText.Position = Vector2.new(box.X - 10, box.Y + box.H/2)
            healthText.Color = Color3.fromRGB(255, 255, 255)
            healthText.Size = 9
            healthText.Center = true
            healthText.Visible = true
            table.insert(Drawings, healthText)
        end
        
        
        if Settings.DistanceEnabled then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                local distText = Drawing.new("Text")
                distText.Text = string.format("%.0fm", dist)
                distText.Position = Vector2.new(box.X + box.W/2, box.Y + box.H + 8)
                distText.Color = Color3.fromRGB(255, 255, 0)
                distText.Size = 10
                distText.Center = true
                distText.Visible = true
                table.insert(Drawings, distText)
            end
        end
        
        
        if Settings.TracerEnabled then
            local tracer = Drawing.new("Line")
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            local bottom = Vector2.new(box.X + box.W/2, box.Y + box.H)
            tracer.From = center
            tracer.To = bottom
            tracer.Color = Settings.ShootThruWalls and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(255, 0, 0)
            tracer.Thickness = 1
            tracer.Visible = true
            table.insert(Drawings, tracer)
        end
        
        
        if Settings.HeadDotEnabled then
            local head = char:FindFirstChild("Head")
            if head then
                local headPos = Camera:WorldToViewportPoint(head.Position)
                if headPos.Z > 0 then
                    local dot = Drawing.new("Circle")
                    dot.Position = Vector2.new(headPos.X, headPos.Y)
                    dot.Radius = Settings.HeadDotSize
                    dot.Color = Settings.ShootThruWalls and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(255, 0, 0)
                    dot.Filled = true
                    dot.Visible = true
                    table.insert(Drawings, dot)
                end
            end
        end
        
        
        if Settings.SkeletonEnabled then
            local bones = {
                {"Head", "UpperTorso"},
                {"UpperTorso", "HumanoidRootPart"},
                {"LeftUpperArm", "LeftLowerArm"},
                {"RightUpperArm", "RightLowerArm"},
                {"LeftUpperLeg", "LeftLowerLeg"},
                {"RightUpperLeg", "RightLowerLeg"}
            }
            for _, bone in pairs(bones) do
                local p1 = char:FindFirstChild(bone[1])
                local p2 = char:FindFirstChild(bone[2])
                if p1 and p2 then
                    local pos1 = Camera:WorldToViewportPoint(p1.Position)
                    local pos2 = Camera:WorldToViewportPoint(p2.Position)
                    if pos1.Z > 0 and pos2.Z > 0 then
                        local line = Drawing.new("Line")
                        line.From = Vector2.new(pos1.X, pos1.Y)
                        line.To = Vector2.new(pos2.X, pos2.Y)
                        line.Color = Color3.fromRGB(255, 255, 255)
                        line.Thickness = 1.5
                        line.Visible = true
                        table.insert(Drawings, line)
                    end
                end
            end
        end
    end
end


local WallhackActive = false
local TransparentParts = {}

function ApplyWallhack()
    if Settings.WallhackEnabled then
        if not WallhackActive then
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Transparency < 0.9 then
                    local shouldSkip = false
                    local name = obj.Name:lower()
                    
                    
                    if obj:IsDescendantOf(LocalPlayer.Character) then
                        shouldSkip = true
                    end
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and obj:IsDescendantOf(player.Character) then
                            shouldSkip = true
                            break
                        end
                    end
                    
                    if not shouldSkip then
                        if not TransparentParts[obj] then
                            TransparentParts[obj] = obj.Transparency
                        end
                        obj.Transparency = 0.6
                        obj.CastShadow = false
                    end
                end
            end
            WallhackActive = true
        end
    else
        if WallhackActive then
            for obj, originalTrans in pairs(TransparentParts) do
                pcall(function()
                    obj.Transparency = originalTrans
                    obj.CastShadow = true
                end)
            end
            TransparentParts = {}
            WallhackActive = false
        end
    end
end


local ShootThruActive = false
local OriginalCanQuery = {}

function ApplyShootThruWalls()
    if Settings.ShootThruWalls then
        if not ShootThruActive then
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local shouldSkip = false
                    local name = obj.Name:lower()
                    
                    
                    if name:find("baseplate") or name:find("ground") or name:find("terrain") then
                        shouldSkip = true
                    end
                    
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Character and obj:IsDescendantOf(player.Character) then
                            shouldSkip = true
                            break
                        end
                    end
                    
                    if not shouldSkip then
                        if not OriginalCanQuery[obj] then
                            OriginalCanQuery[obj] = obj.CanQuery
                        end
                        
                        obj.CanQuery = false
                    end
                end
            end
            ShootThruActive = true
        end
    else
        if ShootThruActive then
            for obj, original in pairs(OriginalCanQuery) do
                pcall(function() obj.CanQuery = original end)
            end
            OriginalCanQuery = {}
            ShootThruActive = false
        end
    end
end


local FOVCircle = nil
function UpdateFOVCircle()
    if Settings.AimbotFOVVisible and not MenuOpen then
        if not FOVCircle then
            FOVCircle = Drawing.new("Circle")
            FOVCircle.Thickness = 1
            FOVCircle.NumSides = 64
            FOVCircle.Filled = false
            FOVCircle.Transparency = 0.4
            FOVCircle.Color = Settings.ShootThruWalls and Color3.fromRGB(255, 0, 255) or Color3.fromRGB(255, 255, 255)
        end
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Settings.AimbotFOV
        FOVCircle.Visible = true
    else
        if FOVCircle then
            FOVCircle.Visible = false
        end
    end
end


local ScreenGui = nil
local MainFrame = nil

function CreateMenu()
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SWAGZTAMenu"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Enabled = false
    ScreenGui.ResetOnSpawn = false
    
    MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
    MainFrame.BorderSizePixel = 2
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -320)
    MainFrame.Size = UDim2.new(0, 700, 0, 640)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    Title.BackgroundTransparency = 0.3
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "SWAGZTA MENU [PRESS K TO OPEN OR CLOSE SETTINGS]"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = MainFrame
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
        MenuOpen = false
    end)
    
    
    local options = {
        {"ESP ENABLED", "ESPEnabled", true},
        {"BOX ESP", "BoxEnabled", true},
        {"NAME ESP", "NameEnabled", true},
        {"HEALTH ESP", "HealthEnabled", true},
        {"DISTANCE ESP", "DistanceEnabled", true},
        {"TRACER ESP", "TracerEnabled", true},
        {"HEAD DOT ESP", "HeadDotEnabled", true},
        {"SKELETON ESP", "SkeletonEnabled", true},
        {"AIMBOT ENABLED", "AimbotEnabled", true},
        {"FOV CIRKLE", "AimbotFOVVisible", true},
        {"VISIBLE CHECK", "AimbotVisibleCheck", true},
        {"TEAM CHECK", "AimbotTeamCheck", false},
        {"AIMBOT MOVEMENT PREDICT", "AimbotPredict", true},
        {"SEE THRU WALLZ", "WallhackEnabled", false},
        {"SHOOT THRU WALLS (NOT WORKING)", "ShootThruWalls", false}
    }
    
    local yOffset = 50
    for i, opt in ipairs(options) do
        local label = Instance.new("TextLabel")
        label.Parent = MainFrame
        label.Position = UDim2.new(0, 20, 0, yOffset + (i-1) * 35)
        label.Size = UDim2.new(0, 220, 0, 30)
        label.Text = opt[1]
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local btn = Instance.new("TextButton")
        btn.Parent = MainFrame
        btn.Position = UDim2.new(0, 250, 0, yOffset + (i-1) * 35)
        btn.Size = UDim2.new(0, 60, 0, 30)
        btn.BackgroundColor3 = opt[3] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        btn.Text = opt[3] and "ON" or "OFF"
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        
        local settingName = opt[2]
        btn.MouseButton1Click:Connect(function()
            Settings[settingName] = not Settings[settingName]
            btn.BackgroundColor3 = Settings[settingName] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            btn.Text = Settings[settingName] and "ON" or "OFF"
        end)
    end
    
    
    local sliderStartY = 50 + #options * 35 + 20
    
    
    local boxSizeLabel = Instance.new("TextLabel")
    boxSizeLabel.Parent = MainFrame
    boxSizeLabel.Position = UDim2.new(0, 20, 0, sliderStartY)
    boxSizeLabel.Size = UDim2.new(0, 250, 0, 20)
    boxSizeLabel.Text = "ESP Box Size: " .. string.format("%.1f", Settings.BoxSizeMultiplier)
    boxSizeLabel.TextColor3 = Color3.fromRGB(255,255,255)
    boxSizeLabel.BackgroundTransparency = 1
    boxSizeLabel.Font = Enum.Font.Gotham
    boxSizeLabel.TextSize = 14
    boxSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local boxSizeBar = Instance.new("Frame")
    boxSizeBar.Parent = MainFrame
    boxSizeBar.Position = UDim2.new(0, 20, 0, sliderStartY + 25)
    boxSizeBar.Size = UDim2.new(0, 250, 0, 6)
    boxSizeBar.BackgroundColor3 = Color3.fromRGB(80,80,90)
    
    local boxSizeFill = Instance.new("Frame")
    boxSizeFill.Parent = boxSizeBar
    local boxPercent = (Settings.BoxSizeMultiplier - 0.5) / (2.0 - 0.5)
    boxSizeFill.Size = UDim2.new(boxPercent, 0, 1, 0)
    boxSizeFill.BackgroundColor3 = Color3.fromRGB(0,200,255)
    
    local draggingBox = false
    boxSizeBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingBox = true
        end
    end)
    boxSizeBar.InputEnded:Connect(function() draggingBox = false end)
    
    
    local headDotLabel = Instance.new("TextLabel")
    headDotLabel.Parent = MainFrame
    headDotLabel.Position = UDim2.new(0, 350, 0, sliderStartY)
    headDotLabel.Size = UDim2.new(0, 250, 0, 20)
    headDotLabel.Text = "Head Dot Size: " .. tostring(Settings.HeadDotSize)
    headDotLabel.TextColor3 = Color3.fromRGB(255,255,255)
    headDotLabel.BackgroundTransparency = 1
    headDotLabel.Font = Enum.Font.Gotham
    headDotLabel.TextSize = 14
    headDotLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local headDotBar = Instance.new("Frame")
    headDotBar.Parent = MainFrame
    headDotBar.Position = UDim2.new(0, 350, 0, sliderStartY + 25)
    headDotBar.Size = UDim2.new(0, 250, 0, 6)
    headDotBar.BackgroundColor3 = Color3.fromRGB(80,80,90)
    
    local headDotFill = Instance.new("Frame")
    headDotFill.Parent = headDotBar
    local headPercent = (Settings.HeadDotSize - 1) / (10 - 1)
    headDotFill.Size = UDim2.new(headPercent, 0, 1, 0)
    headDotFill.BackgroundColor3 = Color3.fromRGB(0,200,255)
    
    local draggingHead = false
    headDotBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHead = true
        end
    end)
    headDotBar.InputEnded:Connect(function() draggingHead = false end)
    
    
    local smoothLabel = Instance.new("TextLabel")
    smoothLabel.Parent = MainFrame
    smoothLabel.Position = UDim2.new(0, 20, 0, sliderStartY + 60)
    smoothLabel.Size = UDim2.new(0, 250, 0, 20)
    smoothLabel.Text = "AIMBOT SMOOTHNESS: " .. tostring(Settings.AimbotSmoothness)
    smoothLabel.TextColor3 = Color3.fromRGB(255,255,255)
    smoothLabel.BackgroundTransparency = 1
    smoothLabel.Font = Enum.Font.Gotham
    smoothLabel.TextSize = 14
    smoothLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local smoothBar = Instance.new("Frame")
    smoothBar.Parent = MainFrame
    smoothBar.Position = UDim2.new(0, 20, 0, sliderStartY + 85)
    smoothBar.Size = UDim2.new(0, 250, 0, 6)
    smoothBar.BackgroundColor3 = Color3.fromRGB(80,80,90)
    
    local smoothFill = Instance.new("Frame")
    smoothFill.Parent = smoothBar
    local smoothPercent = (Settings.AimbotSmoothness - 1) / (20 - 1)
    smoothFill.Size = UDim2.new(smoothPercent, 0, 1, 0)
    smoothFill.BackgroundColor3 = Color3.fromRGB(0,200,255)
    
    local draggingSmooth = false
    smoothBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSmooth = true
        end
    end)
    smoothBar.InputEnded:Connect(function() draggingSmooth = false end)
    
    
    local fovLabel = Instance.new("TextLabel")
    fovLabel.Parent = MainFrame
    fovLabel.Position = UDim2.new(0, 350, 0, sliderStartY + 60)
    fovLabel.Size = UDim2.new(0, 250, 0, 20)
    fovLabel.Text = "AIMBOT CIRCLE FOV: " .. tostring(Settings.AimbotFOV)
    fovLabel.TextColor3 = Color3.fromRGB(255,255,255)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Font = Enum.Font.Gotham
    fovLabel.TextSize = 14
    fovLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local fovBar = Instance.new("Frame")
    fovBar.Parent = MainFrame
    fovBar.Position = UDim2.new(0, 350, 0, sliderStartY + 85)
    fovBar.Size = UDim2.new(0, 250, 0, 6)
    fovBar.BackgroundColor3 = Color3.fromRGB(80,80,90)
    
    local fovFill = Instance.new("Frame")
    fovFill.Parent = fovBar
    local fovPercent = (Settings.AimbotFOV - 30) / (180 - 30)
    fovFill.Size = UDim2.new(fovPercent, 0, 1, 0)
    fovFill.BackgroundColor3 = Color3.fromRGB(0,200,255)
    
    local draggingFOV = false
    fovBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingFOV = true
        end
    end)
    fovBar.InputEnded:Connect(function() draggingFOV = false end)
    
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Parent = MainFrame
    distLabel.Position = UDim2.new(0, 20, 0, sliderStartY + 120)
    distLabel.Size = UDim2.new(0, 250, 0, 20)
    distLabel.Text = "MAX AIMBOT DISTANCE: " .. tostring(Settings.AimbotMaxDistance)
    distLabel.TextColor3 = Color3.fromRGB(255,255,255)
    distLabel.BackgroundTransparency = 1
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 14
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local distBar = Instance.new("Frame")
    distBar.Parent = MainFrame
    distBar.Position = UDim2.new(0, 20, 0, sliderStartY + 145)
    distBar.Size = UDim2.new(0, 250, 0, 6)
    distBar.BackgroundColor3 = Color3.fromRGB(80,80,90)
    
    local distFill = Instance.new("Frame")
    distFill.Parent = distBar
    local distPercent = (Settings.AimbotMaxDistance - 100) / (1000 - 100)
    distFill.Size = UDim2.new(distPercent, 0, 1, 0)
    distFill.BackgroundColor3 = Color3.fromRGB(0,200,255)
    
    local draggingDist = false
    distBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingDist = true
        end
    end)
    distBar.InputEnded:Connect(function() draggingDist = false end)
    
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if not MainFrame or not MainFrame.Visible then return end
        
        if draggingBox then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = boxSizeBar.AbsolutePosition
            local percentRaw = (mousePos.X - absPos.X) / boxSizeBar.AbsoluteSize.X
            local percentVal = math.clamp(percentRaw, 0, 1)
            local val = 0.5 + percentVal * (2.0 - 0.5)
            Settings.BoxSizeMultiplier = val
            boxSizeFill.Size = UDim2.new(percentVal, 0, 1, 0)
            boxSizeLabel.Text = "ESP BOX SIZE: " .. string.format("%.1f", val)
        end
        
        if draggingHead then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = headDotBar.AbsolutePosition
            local percentRaw = (mousePos.X - absPos.X) / headDotBar.AbsoluteSize.X
            local percentVal = math.clamp(percentRaw, 0, 1)
            local val = math.floor(1 + percentVal * (10 - 1))
            Settings.HeadDotSize = val
            headDotFill.Size = UDim2.new(percentVal, 0, 1, 0)
            headDotLabel.Text = "HEAD DOT SIZE: " .. tostring(val)
        end
        
        if draggingSmooth then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = smoothBar.AbsolutePosition
            local percentRaw = (mousePos.X - absPos.X) / smoothBar.AbsoluteSize.X
            local percentVal = math.clamp(percentRaw, 0, 1)
            local val = math.floor(1 + percentVal * (20 - 1))
            Settings.AimbotSmoothness = val
            smoothFill.Size = UDim2.new(percentVal, 0, 1, 0)
            smoothLabel.Text = "AIMBOT SMOOTHNESS: " .. tostring(val)
        end
        
        if draggingFOV then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = fovBar.AbsolutePosition
            local percentRaw = (mousePos.X - absPos.X) / fovBar.AbsoluteSize.X
            local percentVal = math.clamp(percentRaw, 0, 1)
            local val = math.floor(30 + percentVal * (180 - 30))
            Settings.AimbotFOV = val
            fovFill.Size = UDim2.new(percentVal, 0, 1, 0)
            fovLabel.Text = "AIMBOT CIRCLE FOV: " .. tostring(val)
        end
        
        if draggingDist then
            local mousePos = UserInputService:GetMouseLocation()
            local absPos = distBar.AbsolutePosition
            local percentRaw = (mousePos.X - absPos.X) / distBar.AbsoluteSize.X
            local percentVal = math.clamp(percentRaw, 0, 1)
            local val = math.floor(100 + percentVal * (1000 - 100))
            Settings.AimbotMaxDistance = val
            distFill.Size = UDim2.new(percentVal, 0, 1, 0)
            distLabel.Text = "AIMBOT MAX DISTANCE: " .. tostring(val)
        end
    end)
    
    local Note = Instance.new("TextLabel")
    Note.Parent = MainFrame
    Note.Position = UDim2.new(0, 20, 0, 590)
    Note.Size = UDim2.new(0, 660, 0, 40)
    Note.Text = "HOLD Q FOR AIMBOT | K TO OPEN OR CLOSE SETTINGZ MENU"
    Note.TextColor3 = Color3.fromRGB(200, 200, 200)
    Note.BackgroundTransparency = 1
    Note.Font = Enum.Font.Gotham
    Note.TextSize = 12
end


CreateMenu()


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.K and not gameProcessed then
        MenuOpen = not MenuOpen
        if ScreenGui then
            ScreenGui.Enabled = MenuOpen
        end
        if not MenuOpen then
            ClearDrawings()
        end
    end
end)


RunService.RenderStepped:Connect(function()
    ClearDrawings()
    
    
    ApplyWallhack()
    ApplyShootThruWalls()
    
    if not MenuOpen then
        DoAimbot()
        DrawESP()
        UpdateFOVCircle()
    end
end)


spawn(function()
    while wait(30) do
        if not Settings.ShootThruWalls then
            for obj, _ in pairs(OriginalCanQuery) do
                if not obj.Parent then
                    OriginalCanQuery[obj] = nil
                end
            end
        end
        if not Settings.WallhackEnabled then
            for obj, _ in pairs(TransparentParts) do
                if not obj.Parent then
                    TransparentParts[obj] = nil
                end
            end
        end
    end
end)

print("SWAG")