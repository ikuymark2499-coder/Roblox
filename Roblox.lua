--[[
    Darkdraft Script by [Your Name]
    Features:
    1. บินพร้อมปรับความเร็ว
    2. ล่องหน
    3. เดินทะลุ
    4. ESP มองเห็นผู้เล่น
]]

-- โหลด Library ที่จำเป็น
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ตัวแปรเก็บสถานะ
local Settings = {
    Fly = {
        Enabled = false,
        Speed = 50
    },
    Noclip = false,
    Invisible = false,
    ESP = false,
    UI = {
        Open = true,
        Minimized = false
    }
}

-- เก็บวัตถุ ESP
local ESPObjects = {}
local FlyConnection = nil
local NoclipConnection = nil

-- ====================== ฟังก์ชันหลัก ======================
function CreateDDIcon()
    -- สร้างไอคอน DD ที่มุมขวาบน
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DarkdraftGUI"
    ScreenGui.Parent = game.CoreGui
    
    -- Main Icon (DD Logo)
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
    
    -- เพิ่มเงาให้ไอคอน
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 100, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
    }
    UIGradient.Rotation = 90
    UIGradient.Parent = DDIcon
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = DDIcon
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 50, 50)
    UIStroke.Thickness = 2
    UIStroke.Parent = DDIcon
    
    return ScreenGui, DDIcon
end

function CreateMainUI()
    -- สร้าง UI หลัก
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
    MainFrame.BorderSizePixel = 3
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 400, 0, 350)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Visible = Settings.UI.Open
    
    -- เพิ่มเงา
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.5
    DropShadow.BackgroundTransparency = 1
    DropShadow.Position = UDim2.new(0, -15, 0, -15)
    DropShadow.Size = UDim2.new(1, 30, 1, 30)
    DropShadow.ZIndex = -1
    DropShadow.Parent = MainFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Text = "⚡ Darkdraft Script ⚡"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLabel.Parent = TitleBar
    
    -- ปุ่มปิด/ย่อ
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Parent = TitleBar
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Text = "_"
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 14
    MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Parent = TitleBar
    
    -- Side Menu (ซ้าย)
    local SideMenu = Instance.new("Frame")
    SideMenu.Name = "SideMenu"
    SideMenu.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SideMenu.Position = UDim2.new(0, 0, 0, 30)
    SideMenu.Size = UDim2.new(0.3, 0, 1, -30)
    SideMenu.Parent = MainFrame
    
    local MenuLabel = Instance.new("TextLabel")
    MenuLabel.Name = "MenuLabel"
    MenuLabel.Text = "📋 ฟังก์ชั่นทั้งหมด"
    MenuLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MenuLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MenuLabel.Size = UDim2.new(1, 0, 0, 30)
    MenuLabel.Font = Enum.Font.Gotham
    MenuLabel.TextSize = 14
    MenuLabel.Parent = SideMenu
    
    -- Content Area (ขวา)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ContentFrame.Position = UDim2.new(0.3, 0, 0, 30)
    ContentFrame.Size = UDim2.new(0.7, 0, 1, -30)
    ContentFrame.Parent = MainFrame
    
    return MainFrame, TitleBar, SideMenu, ContentFrame, CloseButton, MinimizeButton
end

function CreateMenuButtons(SideMenu)
    -- สร้างปุ่มเมนู
    local buttons = {
        {"Fly (บิน)", "🪽"},
        {"Noclip (ล่องหน/ทะลุ)", "👻"},
        {"ESP (มองผู้เล่น)", "👁️"},
        {"Speed (ความเร็ว)", "⚡"}
    }
    
    for i, buttonInfo in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = buttonInfo[1]:gsub("%s.+", "")
        button.Text = string.format("%s %s", buttonInfo[2], buttonInfo[1])
        button.Font = Enum.Font.Gotham
        button.TextSize = 13
        button.TextColor3 = Color3.fromRGB(220, 220, 220)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        button.Position = UDim2.new(0, 5, 0, 35 + (i-1)*35)
        button.Size = UDim2.new(1, -10, 0, 30)
        button.Parent = SideMenu
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = button
        
        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = Color3.fromRGB(60, 60, 60)
        UIStroke.Thickness = 1
        UIStroke.Parent = button
    end
end

function CreateFlyUI(ContentFrame)
    -- สร้าง UI สำหรับบิน
    local FlyFrame = Instance.new("Frame")
    FlyFrame.Name = "FlyFrame"
    FlyFrame.BackgroundTransparency = 1
    FlyFrame.Size = UDim2.new(1, 0, 1, 0)
    FlyFrame.Visible = false
    FlyFrame.Parent = ContentFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = "🪽 Fly Settings (ตั้งค่าบิน)"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255, 200, 100)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Parent = FlyFrame
    
    -- Toggle Fly
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "ToggleFrame"
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleFrame.Position = UDim2.new(0, 10, 0, 50)
    ToggleFrame.Size = UDim2.new(1, -20, 0, 50)
    ToggleFrame.Parent = FlyFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "ToggleLabel"
    ToggleLabel.Text = "Fly Enabled:"
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 14
    ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Text = Settings.Fly.Enabled and "ON" or "OFF"
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 14
    ToggleButton.TextColor3 = Settings.Fly.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleButton.Position = UDim2.new(0.7, 0, 0.2, 0)
    ToggleButton.Size = UDim2.new(0.25, 0, 0.6, 0)
    ToggleButton.Parent = ToggleFrame
    
    -- Speed Slider
    local SpeedFrame = Instance.new("Frame")
    SpeedFrame.Name = "SpeedFrame"
    SpeedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SpeedFrame.Position = UDim2.new(0, 10, 0, 110)
    SpeedFrame.Size = UDim2.new(1, -20, 0, 80)
    SpeedFrame.Parent = FlyFrame
    
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Name = "SpeedLabel"
    SpeedLabel.Text = "Fly Speed: " .. Settings.Fly.Speed
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 14
    SpeedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Size = UDim2.new(1, 0, 0, 30)
    SpeedLabel.Parent = SpeedFrame
    
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpeedSlider.Position = UDim2.new(0, 10, 0, 40)
    SpeedSlider.Size = UDim2.new(1, -20, 0, 20)
    SpeedSlider.Parent = SpeedFrame
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    SliderFill.Size = UDim2.new((Settings.Fly.Speed - 20) / 180, 0, 1, 0)
    SliderFill.Parent = SpeedSlider
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Name = "SliderButton"
    SliderButton.Text = ""
    SliderButton.BackgroundTransparency = 1
    SliderButton.Size = UDim2.new(1, 0, 1, 0)
    SliderButton.Parent = SpeedSlider
    
    return FlyFrame, ToggleButton, SpeedLabel, SliderFill, SliderButton
end

function CreateNoclipUI(ContentFrame)
    -- UI สำหรับ Noclip
    local NoclipFrame = Instance.new("Frame")
    NoclipFrame.Name = "NoclipFrame"
    NoclipFrame.BackgroundTransparency = 1
    NoclipFrame.Size = UDim2.new(1, 0, 1, 0)
    NoclipFrame.Visible = false
    NoclipFrame.Parent = ContentFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = "👻 Noclip Settings (เดินทะลุ)"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(100, 200, 255)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Parent = NoclipFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Text = Settings.Noclip and "Noclip: ON" or "Noclip: OFF"
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 16
    ToggleButton.TextColor3 = Settings.Noclip and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleButton.Position = UDim2.new(0.2, 0, 0.3, 0)
    ToggleButton.Size = UDim2.new(0.6, 0, 0, 40)
    ToggleButton.Parent = NoclipFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = ToggleButton
    
    return NoclipFrame, ToggleButton
end

function CreateInvisibleUI(ContentFrame)
    -- UI สำหรับล่องหน
    local InvisibleFrame = Instance.new("Frame")
    InvisibleFrame.Name = "InvisibleFrame"
    InvisibleFrame.BackgroundTransparency = 1
    InvisibleFrame.Size = UDim2.new(1, 0, 1, 0)
    InvisibleFrame.Visible = false
    InvisibleFrame.Parent = ContentFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = "🎭 Invisible Mode (ล่องหน)"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(200, 100, 255)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Parent = InvisibleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Text = Settings.Invisible and "Invisible: ON" or "Invisible: OFF"
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 16
    ToggleButton.TextColor3 = Settings.Invisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleButton.Position = UDim2.new(0.2, 0, 0.3, 0)
    ToggleButton.Size = UDim2.new(0.6, 0, 0, 40)
    ToggleButton.Parent = InvisibleFrame
    
    local WarningLabel = Instance.new("TextLabel")
    WarningLabel.Name = "WarningLabel"
    WarningLabel.Text = "⚠️ หมายเหตุ: อาจมองเห็นได้จากบางมุม"
    WarningLabel.Font = Enum.Font.Gotham
    WarningLabel.TextSize = 12
    WarningLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    WarningLabel.BackgroundTransparency = 1
    WarningLabel.Position = UDim2.new(0, 0, 0.6, 0)
    WarningLabel.Size = UDim2.new(1, 0, 0, 20)
    WarningLabel.Parent = InvisibleFrame
    
    return InvisibleFrame, ToggleButton
end

function CreateESPUI(ContentFrame)
    -- UI สำหรับ ESP
    local ESPFrame = Instance.new("Frame")
    ESPFrame.Name = "ESPFrame"
    ESPFrame.BackgroundTransparency = 1
    ESPFrame.Size = UDim2.new(1, 0, 1, 0)
    ESPFrame.Visible = false
    ESPFrame.Parent = ContentFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = "👁️ ESP Settings (มองเห็นผู้เล่น)"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(100, 255, 100)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Parent = ESPFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Text = Settings.ESP and "ESP: ON" or "ESP: OFF"
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.TextSize = 16
    ToggleButton.TextColor3 = Settings.ESP and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleButton.Position = UDim2.new(0.2, 0, 0.3, 0)
    ToggleButton.Size = UDim2.new(0.6, 0, 0, 40)
    ToggleButton.Parent = ESPFrame
    
    return ESPFrame, ToggleButton
end

-- ====================== ฟังก์ชันการทำงาน ======================
function ToggleFly()
    Settings.Fly.Enabled = not Settings.Fly.Enabled
    
    if Settings.Fly.Enabled then
        StartFlying()
    else
        StopFlying()
    end
    
    UpdateUI()
end

function StartFlying()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- ลบ BodyVelocity เก่าถ้ามี
    local oldBV = humanoidRootPart:FindFirstChild("FlyBV")
    if oldBV then
        oldBV:Destroy()
    end
    
    -- สร้าง BodyVelocity ใหม่
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyBV"
    bv.Parent = humanoidRootPart
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Fly.Enabled or not character or not humanoidRootPart then
            StopFlying()
            return
        end
        
        local camera = workspace.CurrentCamera
        local forward = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector
        local up = Vector3.new(0, 1, 0)
        
        local direction = Vector3.new()
        
        -- อ่านการกดปุ่ม
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + up
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - up
        end
        
        -- ปรับความเร็ว
        if direction.Magnitude > 0 then
            direction = direction.Unit * Settings.Fly.Speed
        end
        
        bv.Velocity = direction
    end)
end

function StopFlying()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local bv = humanoidRootPart:FindFirstChild("FlyBV")
            if bv then
                bv:Destroy()
            end
        end
    end
end

function ToggleNoclip()
    Settings.Noclip = not Settings.Noclip
    
    if Settings.Noclip then
        StartNoclip()
    else
        StopNoclip()
    end
    
    UpdateUI()
end

function StartNoclip()
    NoclipConnection = RunService.Stepped:Connect(function()
        if not Settings.Noclip then
            StopNoclip()
            return
        end
        
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
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
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

function ToggleInvisible()
    Settings.Invisible = not Settings.Invisible
    
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if Settings.Invisible then
                    part.Transparency = 0.8
                    part.Material = Enum.Material.Glass
                else
                    part.Transparency = 0
                    part.Material = Enum.Material.Plastic
                end
            end
        end
    end
    
    UpdateUI()
end

function ToggleESP()
    Settings.ESP = not Settings.ESP
    
    if Settings.ESP then
        CreateESP()
    else
        ClearESP()
    end
    
    UpdateUI()
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
                    highlight.Name = "ESP_Highlight_" .. player.Name
                    highlight.Parent = character
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    highlight.FillTransparency = 0.5
         
