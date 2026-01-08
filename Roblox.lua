-- Darkdraft Script สำหรับ Delta Executor
-- เวอร์ชัน: Complete 3.0 (ทุกฟังก์ชัน + แท็บระบบ + ใช้งานได้จริง)
-- พัฒนาโดย [DarkDraft Stodio]
-- ตรวจสอบ Executor
local executor = identifyexecutor or getexecutorname
if executor then
    print("✅ Executor: " .. executor())
end

print("🎮 Darkdraft Script กำลังโหลด...")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Global Settings
getgenv().Darkdraft = {
    Fly = {Enabled = false, Speed = 50},
    Noclip = false,
    Invisible = false,
    ESP = false,
    WalkSpeed = 16,
    JumpPower = 50,
    FlyConnection = nil,
    NoclipConnection = nil,
    ESPObjects = {}
}

-- Keybinds
local Keybinds = {
    ToggleFly = Enum.KeyCode.F,
    ToggleNoclip = Enum.KeyCode.N,
    ToggleInvisible = Enum.KeyCode.I,
    ToggleESP = Enum.KeyCode.E,
    ToggleUI = Enum.KeyCode.RightShift
}

-- ====================== FLY SYSTEM ======================
function ToggleFly()
    getgenv().Darkdraft.Fly.Enabled = not getgenv().Darkdraft.Fly.Enabled
    
    if getgenv().Darkdraft.Fly.Enabled then
        StartFlying()
        print("🪽 Fly: เปิดใช้งานแล้ว")
    else
        StopFlying()
        print("🪽 Fly: ปิดใช้งานแล้ว")
    end
end

function StartFlying()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- ลบส่วนประกอบเก่า
    StopFlying()
    
    -- สร้าง BodyVelocity สำหรับการบิน
    local bv = Instance.new("BodyVelocity")
    bv.Name = "DarkdraftFly"
    bv.Parent = humanoidRootPart
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    bv.Velocity = Vector3.new(0, 0, 0)
    
    -- สร้าง BodyGyro สำหรับรักษาทิศทาง
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.Parent = humanoidRootPart
    bg.MaxTorque = Vector3.new(100000, 100000, 100000)
    bg.P = 10000
    bg.CFrame = humanoidRootPart.CFrame
    
    getgenv().Darkdraft.FlyConnection = RunService.Heartbeat:Connect(function()
        if not getgenv().Darkdraft.Fly.Enabled or not character or not humanoidRootPart then
            return
        end
        
        local camera = workspace.CurrentCamera
        local direction = Vector3.new(0, 0, 0)
        
        -- การควบคุมทิศทาง
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        -- ปรับความเร็ว
        if direction.Magnitude > 0 then
            direction = direction.Unit * getgenv().Darkdraft.Fly.Speed
        end
        
        bv.Velocity = direction
        bg.CFrame = camera.CFrame
    end)
end

function StopFlying()
    if getgenv().Darkdraft.FlyConnection then
        getgenv().Darkdraft.FlyConnection:Disconnect()
        getgenv().Darkdraft.FlyConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local bv = humanoidRootPart:FindFirstChild("DarkdraftFly")
            if bv then bv:Destroy() end
            
            local bg = humanoidRootPart:FindFirstChild("FlyGyro")
            if bg then bg:Destroy() end
        end
    end
end

-- ====================== NOCLIP SYSTEM (ทุกแมพ) ======================
function ToggleNoclip()
    getgenv().Darkdraft.Noclip = not getgenv().Darkdraft.Noclip
    
    if getgenv().Darkdraft.Noclip then
        StartNoclip()
        print("👻 Noclip: เปิดใช้งานแล้ว")
    else
        StopNoclip()
        print("👻 Noclip: ปิดใช้งานแล้ว")
    end
end

function StartNoclip()
    -- ลบ Connection เก่า
    if getgenv().Darkdraft.NoclipConnection then
        getgenv().Darkdraft.NoclipConnection:Disconnect()
    end
    
    getgenv().Darkdraft.NoclipConnection = RunService.Stepped:Connect(function()
        if not getgenv().Darkdraft.Noclip then return end
        
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
    if getgenv().Darkdraft.NoclipConnection then
        getgenv().Darkdraft.NoclipConnection:Disconnect()
        getgenv().Darkdraft.NoclipConnection = nil
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
    getgenv().Darkdraft.Invisible = not getgenv().Darkdraft.Invisible
    
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if getgenv().Darkdraft.Invisible then
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
    
    print(getgenv().Darkdraft.Invisible and "🎭 Invisible: เปิดใช้งานแล้ว" or "🎭 Invisible: ปิดใช้งานแล้ว")
end

-- ====================== ESP SYSTEM ======================
function ToggleESP()
    getgenv().Darkdraft.ESP = not getgenv().Darkdraft.ESP
    
    if getgenv().Darkdraft.ESP then
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
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    -- สร้าง Highlight
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "DarkdraftESP_" .. player.Name
                    highlight.Parent = character
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    highlight.FillTransparency = 0.5
                    
                    -- สร้าง Billboard สำหรับชื่อ
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "DarkdraftName_" .. player.Name
                    billboard.Parent = humanoidRootPart
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
                    
                    getgenv().Darkdraft.ESPObjects[player.Name] = {highlight, billboard}
                end
            end
        end
    end
end

function ClearESP()
    for _, objects in pairs(getgenv().Darkdraft.ESPObjects) do
        for _, obj in ipairs(objects) do
            if obj then
                obj:Destroy()
            end
        end
    end
    getgenv().Darkdraft.ESPObjects = {}
end

-- ====================== PLAYER MODIFIERS ======================
function SetWalkSpeed(speed)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
            getgenv().Darkdraft.WalkSpeed = speed
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
            getgenv().Darkdraft.JumpPower = power
            print("🦘 JumpPower: " .. power)
        end
    end
end

function ResetCharacter()
    local character = LocalPlayer.Character
    if character then
        character:BreakJoints()
        print("🔄 รีเซ็ตตัวละครแล้ว")
    end
end

-- ====================== UI SYSTEM ======================
local ScreenGui = nil
local MainFrame = nil
local TabButtons = {}
local TabFrames = {}
local ActiveTab = 1

function CreateDarkdraftUI()
    -- ลบ UI เก่าถ้ามี
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    -- สร้าง ScreenGui หลัก
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DarkdraftUIV2"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- ไอคอน DD ที่มุมขวาบน
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
    
    -- เฟรมหลัก
    MainFrame = Instance.new("Frame")
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
    
    -- หัวเรื่อง
    local Title = Instance.new("TextLabel")
    Title.Text = "⚡ Darkdraft Complete ⚡"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Parent = MainFrame
    
    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabBar.Size = UDim2.new(1, 0, 0, 30)
    TabBar.Position = UDim2.new(0, 0, 0, 30)
    TabBar.Parent = MainFrame
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 10, 0, 70)
    TabContainer.Size = UDim2.new(1, -20, 1, -80)
    TabContainer.Parent = MainFrame
    
    -- สร้าง Tabs
    local tabNames = {"⚡ หลัก", "👻 ฟังก์ชัน", "🎮 ผู้เล่น", "⚙️ ตั้งค่า"}
    local tabColors = {
        Color3.fromRGB(255, 100, 100),
        Color3.fromRGB(100, 200, 255),
        Color3.fromRGB(100, 255, 100),
        Color3.fromRGB(255, 200, 100)
    }
    
    -- สร้าง Tab Frames
    for i = 1, 4 do
        local tabFrame = Instance.new("Frame")
        tabFrame.Name = "Tab" .. i
        tabFrame.BackgroundTransparency = 1
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.Visible = (i == 1)
        tabFrame.Parent = TabContainer
        TabFrames[i] = tabFrame
    end
    
    -- สร้าง Tab Buttons
    for i = 1, 4 do
        local tabButton = Instance.new("TextButton")
        tabButton.Text = tabNames[i]
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextSize = 12
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundColor3 = (i == 1) and tabColors[i] or Color3.fromRGB(60, 60, 60)
        tabButton.Size = UDim2.new(0.25, -2, 1, 0)
        tabButton.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
        tabButton.Parent = TabBar
        
        tabButton.MouseButton1Click:Connect(function()
            SwitchTab(i)
        end)
        
        TabButtons[i] = tabButton
    end
    
    -- ====================== TAB 1 (หลัก) ======================
    -- Fly Toggle
    local flyToggle = CreateToggleButton(TabFrames[1], "🪽 Fly (บิน)", getgenv().Darkdraft.Fly.Enabled, ToggleFly, 10)
    
    -- Speed Slider
    local speedSlider = CreateSlider(TabFrames[1], "ความเร็วบิน", 20, 200, getgenv().Darkdraft.Fly.Speed, 60, function(value)
        getgenv().Darkdraft.Fly.Speed = value
    end)
    
    -- Noclip Toggle
    local noclipToggle = CreateToggleButton(TabFrames[1], "👻 Noclip (ทะลุ)", getgenv().Darkdraft.Noclip, ToggleNoclip, 110)
    
    -- Invisible Toggle
    local invisibleToggle = CreateToggleButton(TabFrames[1], "🎭 Invisible (ล่องหน)", getgenv().Darkdraft.Invisible, ToggleInvisible, 160)
    
    -- ESP Toggle
    local espToggle = CreateToggleButton(TabFrames[1], "👁️ ESP (มองผู้เล่น)", getgenv().Darkdraft.ESP, ToggleESP, 210)
    
    -- ====================== TAB 2 (ฟังก์ชัน) ======================
    CreateButton(TabFrames[2], "รีเซ็ตตัวละคร", 20, function()
        ResetCharacter()
    end)
    
    -- WalkSpeed Slider
    CreateSlider(TabFrames[2], "ความเร็วเดิน", 16, 100, getgenv().Darkdraft.WalkSpeed, 70, function(value)
        SetWalkSpeed(value)
    end)
    
    -- JumpPower Slider
    CreateSlider(TabFrames[2], "พลังกระโดด", 50, 200, getgenv().Darkdraft.JumpPower, 130, function(value)
        SetJumpPower(value)
    end)
    
    CreateButton(TabFrames[2], "ลบ ESP ทั้งหมด", 190, function()
        ClearESP()
    end)
    
    -- ====================== TAB 3 (ผู้เล่น) ======================
    CreateButton(TabFrames[3], "ESP ผู้เล่นทั้งหมด", 20, function()
        ToggleESP()
    end)
    
    -- ====================== TAB 4 (ตั้งค่า) ======================
    CreateButton(TabFrames[4], "รีเซ็ตการตั้งค่า", 20, function()
        getgenv().Darkdraft.Fly.Speed = 50
        getgenv().Darkdraft.WalkSpeed = 16
        getgenv().Darkdraft.JumpPower = 50
        SetWalkSpeed(16)
        SetJumpPower(50)
    end)
    
    CreateButton(TabFrames[4], "รีสตาร์ทสคริปต์", 80, function()
        ScreenGui:Destroy()
        wait(1)
        CreateDarkdraftUI()
    end)
    
    CreateButton(TabFrames[4], "ปิด UI", 140, function()
        MainFrame.Visible = false
    end)
    
    -- ปุ่มปิด
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.TextColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Parent = Title
    
    closeButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    
    -- ระบบลากหน้าต่าง
    SetupDragging(Title, MainFrame)
    
    -- อีเวนต์ไอคอน DD
    DDIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    print("✅ UI โหลดสำเร็จ!")
end

-- Helper Functions สำหรับ UI
function CreateToggleButton(parent, text, initialState, callback, yPosition)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.Position = UDim2.new(0, 0, 0, yPosition)
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
    button.Text = initialState and "ON" or "OFF"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextColor3 = initialState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Position = UDim2.new(0.75, 0, 0.15, 0)
    button.Size = UDim2.new(0.2, 0, 0.7, 0)
    button.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        callback()
        button.Text = (text:find("Fly") and getgenv().Darkdraft.Fly.Enabled) or
                     (text:find("Noclip") and getgenv().Darkdraft.Noclip) or
                     (text:find("Invisible") and getgenv().Darkdraft.Invisible) or
                     (text:find("ESP") and getgenv().Darkdraft.ESP) and "ON" or "OFF"
        button.TextColor3 = (button.Text == "ON") and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    end)
    
    return button
end

function CreateSlider(parent, text, min, max, defaultValue, yPosition, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.Position = UDim2.new(0, 0, 0, yPosition)
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Text = text .. ": " .. defaultValue
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Parent = frame
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderFrame.Position = UDim2.new(0.1, 0, 0.5, 0)
    sliderFrame.Size = UDim2.new(0.8, 0, 0, 20)
    sliderFrame.Parent = frame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    sliderFill.Parent = sliderFrame
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Text = ""
    sliderButton.BackgroundTransparency = 1
    sliderButton.Size = UDim2.new(1, 0, 1, 0)
    sliderButton.Parent = sliderFrame
    
    sliderButton.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local mouse = UserInputService:GetMouseLocation()
            local sliderPos = sliderFrame.AbsolutePosition
            local sliderSize = sliderFrame.AbsoluteSize
        
