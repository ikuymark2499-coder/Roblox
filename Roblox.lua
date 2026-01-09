-- Darkdraft Script เวอร์ชันสมบูรณ์
-- สำหรับ Delta Executor

print("🎮 Darkdraft Script Complete กำลังโหลด...")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Settings
local Settings = {
    Fly = {Enabled = false, Speed = 50},
    Noclip = false,
    Invisible = false,
    ESP = false,
    WalkSpeed = 16,
    JumpPower = 50,
    ESPObjects = {}
}

local Connections = {
    Fly = nil,
    Noclip = nil
}

-- ====================== FLY SYSTEM ======================
function ToggleFly()
    Settings.Fly.Enabled = not Settings.Fly.Enabled
    
    if Settings.Fly.Enabled then
        StartFlying()
        print("🪽 Fly: เปิดใช้งานแล้ว")
    else
        StopFlying()
        print("🪽 Fly: ปิดใช้งานแล้ว")
    end
end

function StartFlying()
    local character = LocalPlayer.Character
    if not character then 
        warn("⚠️ ไม่พบ Character")
        return 
    end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then 
        warn("⚠️ ไม่พบ HumanoidRootPart")
        return 
    end
    
    -- ลบของเก่า
    if Connections.Fly then
        Connections.Fly:Disconnect()
    end
    
    local oldBV = humanoidRootPart:FindFirstChild("DarkdraftFly")
    if oldBV then oldBV:Destroy() end
    local oldGyro = humanoidRootPart:FindFirstChild("FlyGyro")
    if oldGyro then oldGyro:Destroy() end
    
    -- สร้าง BodyVelocity
    local bv = Instance.new("BodyVelocity")
    bv.Name = "DarkdraftFly"
    bv.Parent = humanoidRootPart
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    bv.Velocity = Vector3.new(0, 0, 0)
    
    -- สร้าง BodyGyro
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.Parent = humanoidRootPart
    bg.MaxTorque = Vector3.new(100000, 100000, 100000)
    bg.P = 10000
    bg.CFrame = humanoidRootPart.CFrame
    
    -- Connection สำหรับควบคุม
    Connections.Fly = RunService.Heartbeat:Connect(function()
        if not Settings.Fly.Enabled then return end
        
        local camera = workspace.CurrentCamera
        local move = Vector3.new(0, 0, 0)
        
        -- Controls
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            move = move + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            move = move - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            move = move + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            move = move - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            move = move + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            move = move - Vector3.new(0, 1, 0)
        end
        
        -- Apply speed
        if move.Magnitude > 0 then
            move = move.Unit * Settings.Fly.Speed
        end
        
        bv.Velocity = move
        bg.CFrame = camera.CFrame
    end)
end

function StopFlying()
    if Connections.Fly then
        Connections.Fly:Disconnect()
        Connections.Fly = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("DarkdraftFly")
            if bv then bv:Destroy() end
            local bg = hrp:FindFirstChild("FlyGyro")
            if bg then bg:Destroy() end
        end
    end
end

-- ====================== NOCLIP SYSTEM ======================
function ToggleNoclip()
    Settings.Noclip = not Settings.Noclip
    
    if Settings.Noclip then
        StartNoclip()
        print("👻 Noclip: เปิดใช้งานแล้ว")
    else
        StopNoclip()
        print("👻 Noclip: ปิดใช้งานแล้ว")
    end
end

function StartNoclip()
    if Connections.Noclip then
        Connections.Noclip:Disconnect()
    end
    
    Connections.Noclip = RunService.Stepped:Connect(function()
        if not Settings.Noclip then return end
        
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function StopNoclip()
    if Connections.Noclip then
        Connections.Noclip:Disconnect()
        Connections.Noclip = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ====================== INVISIBLE SYSTEM ======================
function ToggleInvisible()
    Settings.Invisible = not Settings.Invisible
    
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if Settings.Invisible then
                    part.Transparency = 0.8
                    if part:FindFirstChildWhichIsA("Decal") then
                        part:FindFirstChildWhichIsA("Decal").Transparency = 0.8
                    end
                else
                    part.Transparency = 0
                    if part:FindFirstChildWhichIsA("Decal") then
                        part:FindFirstChildWhichIsA("Decal").Transparency = 0
                    end
                end
            end
        end
    end
    
    print(Settings.Invisible and "🎭 Invisible: เปิดใช้งานแล้ว" or "🎭 Invisible: ปิดใช้งานแล้ว")
end

-- ====================== ESP SYSTEM ======================
function ToggleESP()
    Settings.ESP = not Settings.ESP
    
    if Settings.ESP then
        CreateESP()
        print("👁️ ESP: เปิดใช้งานแล้ว")
    else
        ClearESP()
        print("👁️ ESP: ปิดใช้งานแล้ว")
    end
end

function CreateESP()
    ClearESP()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Highlight
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESP_" .. player.Name
                    highlight.Parent = character
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    highlight.FillTransparency = 0.5
                    
                    -- Name Tag
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "Name_" .. player.Name
                    billboard.Parent = hrp
                    billboard.Size = UDim2.new(0, 200, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Parent = billboard
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.Text = player.Name
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.TextSize = 14
                    
                    Settings.ESPObjects[player.Name] = {highlight, billboard}
                end
            end
        end
    end
end

function ClearESP()
    for _, objects in pairs(Settings.ESPObjects) do
        for _, obj in ipairs(objects) do
            if obj then
                obj:Destroy()
            end
        end
    end
    Settings.ESPObjects = {}
end

-- ====================== PLAYER MODIFIERS ======================
function SetWalkSpeed(speed)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
            Settings.WalkSpeed = speed
            print("🚶 WalkSpeed: " .. speed)
        end
    end
end

function SetJumpPower(power)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = power
            Settings.JumpPower = power
            print("🦘 JumpPower: " .. power)
        end
    end
end

-- ====================== UI SYSTEM ======================
function CreateMainUI()
    -- สร้าง ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DarkdraftMainUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- DD Icon
    local DDIcon = Instance.new("TextButton")
    DDIcon.Name = "DDIcon"
    DDIcon.Text = "DD"
    DDIcon.Font = Enum.Font.GothamBlack
    DDIcon.TextSize = 18
    DDIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    DDIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DDIcon.BorderColor3 = Color3.fromRGB(255, 50, 50)
    DDIcon.BorderSizePixel = 2
    DDIcon.Position = UDim2.new(1, -60, 0, 20)
    DDIcon.Size = UDim2.new(0, 50, 0, 50)
    DDIcon.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = DDIcon
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
    MainFrame.BorderSizePixel = 3
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 350, 0, 350)
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 8)
    mainCorner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "⚡ Darkdraft Complete ⚡"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Parent = MainFrame
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Parent = Title
    
    -- Container
    local Container = Instance.new("Frame")
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Parent = MainFrame
    
    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabBar.Size = UDim2.new(1, 0, 0, 30)
    TabBar.Position = UDim2.new(0, 0, 0, -30)
    TabBar.Parent = Container
    
    -- Create Tabs
    local tabs = {
        {"⚡ หลัก", Color3.fromRGB(255, 100, 100)},
        {"🛠️ เครื่องมือ", Color3.fromRGB(100, 200, 255)},
        {"🎮 ผู้เล่น", Color3.fromRGB(100, 255, 100)},
        {"⚙️ ตั้งค่า", Color3.fromRGB(255, 200, 100)}
    }
    
    local TabFrames = {}
    local TabButtons = {}
    
    -- Create Tab Frames
    for i = 1, 4 do
        local tabFrame = Instance.new("Frame")
        tabFrame.Name = "Tab" .. i
        tabFrame.BackgroundTransparency = 1
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.Visible = (i == 1)
        tabFrame.Parent = Container
        TabFrames[i] = tabFrame
    end
    
    -- Create Tab Buttons
    for i, tabInfo in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Text = tabInfo[1]
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextSize = 12
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundColor3 = (i == 1) and tabInfo[2] or Color3.fromRGB(60, 60, 60)
        tabButton.Size = UDim2.new(0.25, -2, 1, 0)
        tabButton.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
        tabButton.Parent = TabBar
        
        tabButton.MouseButton1Click:Connect(function()
            for _, frame in pairs(TabFrames) do
                frame.Visible = false
            end
            TabFrames[i].Visible = true
            
            for idx, btn in pairs(TabButtons) do
                btn.BackgroundColor3 = (idx == i) and tabs[idx][2] or Color3.fromRGB(60, 60, 60)
            end
        end)
        
        TabButtons[i] = tabButton
    end
    
    -- ===== TAB 1 CONTENT =====
    local function CreateToggle(parent, text, state, callback, yPos)
        local frame = Instance.new("Frame")
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.Position = UDim2.new(0, 0, 0, yPos)
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Parent = frame
        
        local button = Instance.new("TextButton")
        button.Text = state and "ON" or "OFF"
        button.Font = Enum.Font.GothamBold
        button.TextSize = 12
        button.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.Position = UDim2.new(0.75, 0, 0.15, 0)
        button.Size = UDim2.new(0.2, 0, 0.7, 0)
        button.Parent = frame
        
        button.MouseButton1Click:Connect(function()
            callback()
            button.Text = state and "ON" or "OFF"
            button.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        end)
        
        return button
    end
    
    -- Fly Toggle
    local flyBtn = CreateToggle(TabFrames[1], "🪽 Fly (บิน)", Settings.Fly.Enabled, ToggleFly, 10)
    
    -- Speed Slider
    local speedFrame = Instance.new("Frame")
    speedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    speedFrame.Size = UDim2.new(1, 0, 0, 60)
    speedFrame.Position = UDim2.new(0, 0, 0, 60)
    speedFrame.Parent = TabFrames[1]
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Text = "ความเร็วบิน: " .. Settings.Fly.Speed
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 13
    speedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Size = UDim2.new(1, 0, 0, 30)
    speedLabel.Parent = speedFrame
    
    -- Noclip Toggle
    local noclipBtn = CreateToggle(TabFrames[1], "👻 Noclip (ทะลุ)", Settings.Noclip, ToggleNoclip, 130)
    
    -- Invisible Toggle
    local invisibleBtn = CreateToggle(TabFrames[1], "🎭 Invisible (ล่องหน)", Settings.Invisible, ToggleInvisible, 180)
    
    -- ESP Toggle
    local espBtn = CreateToggle(TabFrames[1], "👁️ ESP (มองผู้เล่น)", Settings.ESP, ToggleESP, 230)
    
    -- ===== TAB 2 CONTENT =====
    local function CreateButton(parent, text, yPos, callback)
        local button = Instance.new("TextButton")
        button.Text = text
        button.Font = Enum.Font.Gotham
        button.TextSize = 13
        button.TextColor3 = Color3.fromRGB(220, 220, 220)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.Position = UDim2.new(0.1, 0, 0, yPos)
        button.Size = UDim2.new(0.8, 0, 0, 35)
        button.Parent = parent
        
        button.MouseButton1Click:Connect(callback)
        return button
    end
    
    CreateButton(TabFrames[2], "รีเซ็ตตัวละคร", 30, function()
        LocalPlayer.Character:BreakJoints()
    end)
    
    CreateButton(TabFrames[2], "WalkSpeed x2", 80, function()
        SetWalkSpeed(32)
    end)
    
    CreateButton(TabFrames[2], "JumpPower x2", 130, function()
        SetJumpPower(100)
    end)
    
    CreateButton(TabFrames[2], "รีเซ็ตค่าเดิน/กระโดด", 180, function()
        SetWalkSpeed(16)
        SetJumpPower(50)
    end)
    
    -- ===== TAB 3 CONTENT =====
    CreateButton(TabFrames[3], "ESP ผู้เล่นทั้งหมด", 30, function()
        ToggleESP()
    end)
    
    CreateButton(TabFrames[3], "ลบ ESP ทั้งหมด", 80, function()
        ClearESP()
    end)
    
    -- ===== TAB 4 CONTENT =====
    CreateButton(TabFrames[4], "รีเซ็ตการตั้งค่า", 30, function()
        Settings.Fly.Speed = 50
        Settings.WalkSpeed = 16
        Settings.JumpPower = 50
        SetWalkSpeed(16)
        SetJumpPower(50)
    end)
    
    CreateButton(TabFrames[4], "รีสตาร์ทสคริปต์", 80, function()
        ScreenGui:Destroy()
        wait(1)
        CreateMainUI()
    end)
    
    -- UI Events
    DDIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    
    -- Drag System
    local dragging = false
    local dragStart, startPos
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    print("✅ UI โหลดสำเร็จ!")
end

-- ====================== KEYBINDS ======================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        ToggleFly()
    elseif input.KeyCode == Enum.KeyCode.N then
        ToggleNoclip()
    elseif input.KeyCode == Enum.KeyCode.I then
        ToggleInvisible()
    elseif input.KeyCode == Enum.KeyCode.E then
        ToggleESP()
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        local ui = game.CoreGui:FindFirstChild("DarkdraftMainUI")
        if ui then
            local frame = ui:FindFirstChild("MainFrame")
            if frame then
                frame.Visible = not frame.Visible
            end
        end
    end
end)

-- ====================== INITIALIZATION ======================
CreateMainUI()

-- Auto Reconnect
LocalPlayer.CharacterAdded:Connect(function()
    wait(2)
    if Settings.Fly.Enabled then
        ToggleFly()
        wait(0.1)
        ToggleFly()
    end
    if Settings.ESP then
        ToggleESP()
        wait(0.1)
        ToggleESP()
    end
end)

print("=========================================")
print("🎮 Darkdraft Script Complete โหลดสำเร็จ!")
print("=================================
