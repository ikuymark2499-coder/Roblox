-- Darkdraft Script สำหรับ Delta Executor
-- URL: https://raw.githubusercontent.com/ikuymark2499-coder/Roblox/refs/heads/main/Roblox.lua
-- ปรับปรุงโดย [DarkDraft Studio]

-- ตรวจสอบว่าใช้ Delta หรือไม่
if not (identifyexecutor or getexecutorname) then
    game:GetService("Players").LocalPlayer:Kick("⚠️ กรุณาใช้ Delta Executor หรือ Executor ที่รองรับ!")
    return
end

print("✅ Darkdraft Script สำหรับ Delta กำลังโหลด...")

-- บริการต่างๆ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ตั้งค่าต่างๆ
local Settings = {
    Fly = {
        Enabled = false,
        Speed = 50
    },
    Noclip = false,
    Invisible = false,
    ESP = false,
    ESPObjects = {}
}

-- คีย์ลัด
local Keybinds = {
    ToggleFly = Enum.KeyCode.F,
    ToggleNoclip = Enum.KeyCode.N,
    ToggleInvisible = Enum.KeyCode.I,
    ToggleESP = Enum.KeyCode.E,
    ToggleUI = Enum.KeyCode.RightShift
}

-- ====================== ฟังก์ชัน Fly ======================
local FlyConnection = nil

function ToggleFly()
    Settings.Fly.Enabled = not Settings.Fly.Enabled
    
    if Settings.Fly.Enabled then
        StartFlying()
        print("🪽 Fly: เปิดใช้งานแล้ว")
    else
        StopFlying()
        print("🪽 Fly: ปิดใช้งานแล้ว")
    end
    UpdateUI()
end

function StartFlying()
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- ลบของเก่า
    local old = hrp:FindFirstChild("DarkdraftFly")
    if old then old:Destroy() end
    
    -- สร้างใหม่
    local bv = Instance.new("BodyVelocity")
    bv.Name = "DarkdraftFly"
    bv.Parent = hrp
    bv.MaxForce = Vector3.new(100000, 100000, 100000)
    bv.Velocity = Vector3.new(0,0,0)
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Fly.Enabled then return end
        
        local camera = workspace.CurrentCamera
        local move = Vector3.new(0,0,0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
        
        if move.Magnitude > 0 then
            move = move.Unit * Settings.Fly.Speed
        end
        bv.Velocity = move
    end)
end

function StopFlying()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    local character = LocalPlayer.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("DarkdraftFly")
            if bv then bv:Destroy() end
        end
    end
end

-- ====================== ฟังก์ชัน Noclip ======================
local NoclipConnection = nil

function ToggleNoclip()
    Settings.Noclip = not Settings.Noclip
    
    if Settings.Noclip then
        StartNoclip()
        print("👻 Noclip: เปิดใช้งานแล้ว")
    else
        StopNoclip()
        print("👻 Noclip: ปิดใช้งานแล้ว")
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

-- ====================== ฟังก์ชัน Invisible ======================
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
    UpdateUI()
end

-- ====================== ฟังก์ชัน ESP ======================
function ToggleESP()
    Settings.ESP = not Settings.ESP
    
    if Settings.ESP then
        CreateESP()
        print("👁️ ESP: เปิดใช้งานแล้ว")
    else
        ClearESP()
        print("👁️ ESP: ปิดใช้งานแล้ว")
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

-- ====================== สร้าง UI สำหรับ Delta ======================
local ScreenGui = nil
local MainFrame = nil

function CreateDeltaUI()
    -- ลบ UI เก่าถ้ามี
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    -- สร้าง ScreenGui
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DarkdraftDeltaUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- ไอคอน DD (มุมขวาบน)
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
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = DDIcon
    
    -- เมนูหลัก
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
    MainFrame.BorderSizePixel = 3
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 300, 0, 300)
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 8)
    UICorner2.Parent = MainFrame
    
    -- หัวเรื่อง
    local Title = Instance.new("TextLabel")
    Title.Text = "⚡ Darkdraft Delta ⚡"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Parent = MainFrame
    
    -- Container สำหรับปุ่ม
    local Container = Instance.new("Frame")
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Parent = MainFrame
    
    -- สร้างปุ่ม Toggle
    local function CreateToggleButton(text, state, callback, yPosition)
        local Frame = Instance.new("Frame")
        Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Frame.Size = UDim2.new(1, 0, 0, 40)
        Frame.Position = UDim2.new(0, 0, 0, yPosition)
        Frame.Parent = Container
        
        local Label = Instance.new("TextLabel")
        Label.Text = text
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextColor3 = Color3.fromRGB(220, 220, 220)
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Parent = Frame
        
        local Button = Instance.new("TextButton")
        Button.Text = state and "ON" or "OFF"
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 12
        Button.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Button.Position = UDim2.new(0.75, 0, 0.15, 0)
        Button.Size = UDim2.new(0.2, 0, 0.7, 0)
        Button.Parent = Frame
        
        Button.MouseButton1Click:Connect(callback)
        
        return Button
    end
    
    -- สร้าง Slider สำหรับความเร็ว
    local SpeedFrame = Instance.new("Frame")
    SpeedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SpeedFrame.Size = UDim2.new(1, 0, 0, 60)
    SpeedFrame.Position = UDim2.new(0, 0, 0, 200)
    SpeedFrame.Parent = Container
    
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Text = "ความเร็วบิน: " .. Settings.Fly.Speed
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 14
    SpeedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Size = UDim2.new(1, 0, 0, 30)
    SpeedLabel.Parent = SpeedFrame
    
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SpeedSlider.Position = UDim2.new(0.1, 0, 0.5, 0)
    SpeedSlider.Size = UDim2.new(0.8, 0, 0, 20)
    SpeedSlider.Parent = SpeedFrame
    
    local SpeedFill = Instance.new("Frame")
    SpeedFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    SpeedFill.Size = UDim2.new((Settings.Fly.Speed - 20) / 180, 0, 1, 0)
    SpeedFill.Parent = SpeedSlider
    
    -- สร้างปุ่มทั้งหมด
    local FlyButton = CreateToggleButton("🪽 Fly (บิน)", Settings.Fly.Enabled, ToggleFly, 0)
    local NoclipButton = CreateToggleButton("👻 Noclip (ทะลุ)", Settings.Noclip, ToggleNoclip, 50)
    local InvisButton = CreateToggleButton("🎭 Invisible (ล่องหน)", Settings.Invisible, ToggleInvisible, 100)
    local ESPButton = CreateToggleButton("👁️ ESP (มองผู้เล่น)", Settings.ESP, ToggleESP, 150)
    
    -- อีเวนต์สำหรับไอคอน DD
    DDIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)
    
    -- ฟังก์ชันอัพเดท UI
    function UpdateUI()
        if FlyButton then
            FlyButton.Text = Settings.Fly.Enabled and "ON" or "OFF"
            FlyButton.TextColor3 = Settings.Fly.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        end
        if NoclipButton then
            NoclipButton.Text = Settings.Noclip and "ON" or "OFF"
            NoclipButton.TextColor3 = Settings.Noclip and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        end
        if InvisButton then
            InvisButton.Text = Settings.Invisible and "ON" or "OFF"
            InvisButton.TextColor3 = Settings.Invisible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        end
        if ESPButton then
            ESPButton.Text = Settings.ESP and "ON" or "OFF"
            ESPButton.TextColor3 = Settings.ESP and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        end
        if SpeedLabel then
            SpeedLabel.Text = "ความเร็วบิน: " .. Settings.Fly.Speed
        end
        if SpeedFill then
            SpeedFill.Size = UDim2.new((Settings.Fly.Speed - 20) / 180, 0, 1, 0)
        end
    end
    
    -- ระบบลากหน้าต่าง
    local dragging = false
    local dragInput, dragStart, startPos
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
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
    
    return {
        FlyButton = FlyButton,
        NoclipButton = NoclipButton,
        InvisButton = InvisButton,
        ESPButton = ESPButton,
        SpeedLabel = SpeedLabel,
        SpeedFill = SpeedFill,
        SpeedSlider = SpeedSlider
    }
end

-- ====================== คีย์ลัด ======================
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Keybinds.ToggleFly then
        ToggleFly()
    elseif input.KeyCode == Keybinds.ToggleNoclip then
        ToggleNoclip()
    elseif input.KeyCode == Keybinds.ToggleInvisible then
        ToggleInvisible()
    elseif input.KeyCode == Keybinds.ToggleESP then
        ToggleESP()
    elseif input.KeyCode == Keybinds.ToggleUI then
        if MainFrame then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)

-- ====================== เริ่มต้นทำงาน ======================
CreateDeltaUI()

-- Auto reconnect เมื่อรีสปอน
LocalPlayer.CharacterAdded:Connect(function()
    wait(1) -- รอให้ตัวละครโหลดเสร็จ
    
    if Settings.Fly.Enabled then
        ToggleFly()
        ToggleFly() -- เปิดใหม่อีกครั้ง
    end
    if Settings.ESP then
        ToggleESP()
        ToggleESP() -- เปิดใหม่อีกครั้ง
    end
end)

print("=========================================")
print("🎮 Darkdraft Script สำหรับ Delta พร้อมใช้งาน!")
print("=========================================")
print("⚡ คีย์ลัด:")
print("  F - เปิด/ปิด Fly (บิน)")
print("  N - เปิด/ปิด Noclip (ทะลุ)")
print("  I - เปิด/ปิด Invisible (ล่องหน)")
print("  E - เปิด/ปิด ESP (มองผู้เล่น)")
print("  RightShift - เปิด/ปิด UI")
print("=========================================")
print("📌 คลิกไอคอน DD ที่มุมขวาบนเพื่อเปิดเมนู")
print("🎯 สนุกกับการใช้งาน!")
