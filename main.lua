--[[
    ОБУЧАЮЩИЙ ESP + SPEED
    Правый Shift — меню (освобождает курсор)
    Ползунок — скорость 1–20
    ESP — сущности, предметы, шкафы, двери, ловушки
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Настройки
local DEFAULT_SPEED = 16
local MIN_SPEED = 1
local MAX_SPEED = 20
local currentSpeed = DEFAULT_SPEED

local COLORS = {
    ENTITY = Color3.fromRGB(255, 60, 60),
    ITEM = Color3.fromRGB(60, 255, 180),
    HIDING = Color3.fromRGB(255, 255, 80),
    DOOR = Color3.fromRGB(80, 180, 255),
    TRAP = Color3.fromRGB(255, 100, 255),
}

local ENTITY_NAMES = {"Rush", "Ambush", "Screech", "Figure", "Seek", "Halt", "Eyes", "Jack", "Hide", "Timothy"}
local ITEM_NAMES = {"Key", "Battery", "Bandage", "Lockpick", "Vitamins", "Crucifix", "Coin", "Barrel", "Lighter"}
local HIDING_NAMES = {"Wardrobe", "Bed", "Closet", "Cabinet"}
local DOOR_NAMES = {"Door", "RoomDoor", "IronDoor", "Basement", "Hatch"}
local TRAP_NAMES = {"Vent", "Hole", "Trapdoor", "Window"}

-- ==================== МЕНЮ ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MenuGUI"
screenGui.Parent = PlayerGui
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 160)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -80)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "DOORS Educational Tool"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- Скорость текст
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 45)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: " .. DEFAULT_SPEED
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 14
speedLabel.Parent = mainFrame

-- Ползунок (фон)
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -40, 0, 18)
sliderBg.Position = UDim2.new(0, 20, 0, 80)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = mainFrame

-- Заполнение
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

-- Ручка
local sliderHandle = Instance.new("TextButton")
sliderHandle.Size = UDim2.new(0, 16, 1, 0)
sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderHandle.BorderSizePixel = 0
sliderHandle.Text = ""
sliderHandle.Parent = sliderBg

-- Кнопка закрыть
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 70, 0, 28)
closeBtn.Position = UDim2.new(1, -80, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Text = "Закрыть"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false
end)

-- Логика ползунка
local function updateSlider()
    local frac = (currentSpeed - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
    local w = sliderBg.AbsoluteSize.X - sliderHandle.AbsoluteSize.X
    local x = frac * w
    sliderHandle.Position = UDim2.new(0, x, 0, 0)
    sliderFill.Size = UDim2.new(0, x + 8, 1, 0)
    speedLabel.Text = "Скорость: " .. math.floor(currentSpeed * 10) / 10
end

local function applySpeed()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = currentSpeed end
    end
end

local function setSpeedFromMouse(input)
    local w = sliderBg.AbsoluteSize.X - sliderHandle.AbsoluteSize.X
    local mx = input.Position.X - sliderBg.AbsolutePosition.X - sliderHandle.AbsoluteSize.X / 2
    local frac = math.clamp(mx / w, 0, 1)
    currentSpeed = MIN_SPEED + frac * (MAX_SPEED - MIN_SPEED)
    updateSlider()
    applySpeed()
end

local dragConn = nil
sliderHandle.MouseButton1Down:Connect(function()
    dragConn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            setSpeedFromMouse(input)
        end
    end)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if dragConn then dragConn:Disconnect(); dragConn = nil end
    end
end)

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        setSpeedFromMouse(input)
        dragConn = UserInputService.InputChanged:Connect(function(input2)
            if input2.UserInputType == Enum.UserInputType.MouseMovement then
                setSpeedFromMouse(input2)
            end
        end)
    end
end)

-- Открытие по ПРАВОМУ Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
            updateSlider()
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = false
        end
    end
end)

updateSlider()

-- Пересоздание персонажа
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.2)
    applySpeed()
end)
if LocalPlayer.Character then applySpeed() end

-- ==================== ESP ====================
local espGui = Instance.new("ScreenGui")
espGui.Name = "ESPGUI"
espGui.Parent = PlayerGui
espGui.IgnoreGuiInset = true
espGui.ResetOnSpawn = false

local labels = {}

local function createLabel()
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 13
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.Parent = espGui
    return lbl
end

local function clearLabels()
    for _, lbl in ipairs(labels) do lbl:Destroy() end
    table.clear(labels)
end

local function isVisible(from, target)
    local dir = (target.Position - from).Unit * 500
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character or game}
    local result = workspace:Raycast(from, dir, params)
    return result and result.Instance == target
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then clearLabels(); return end
    local headPos = char.Head.Position
    local camera = workspace.CurrentCamera
    if not camera then return end

    clearLabels()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local color = nil
            if table.find(ENTITY_NAMES, obj.Name) then color = COLORS.ENTITY
            elseif table.find(ITEM_NAMES, obj.Name) then color = COLORS.ITEM
            elseif table.find(HIDING_NAMES, obj.Name) then color = COLORS.HIDING
            elseif table.find(DOOR_NAMES, obj.Name) then color = COLORS.DOOR
            elseif table.find(TRAP_NAMES, obj.Name) then color = COLORS.TRAP end

            if color and (obj.Position - headPos).Magnitude < 300 then
                if isVisible(headPos, obj) then
                    local pos, onScreen = camera:WorldToScreenPoint(obj.Position)
                    if onScreen then
                        local lbl = createLabel()
                        lbl.Position = UDim2.new(0, pos.X, 0, pos.Y)
                        lbl.TextColor3 = color
                        lbl.Text = obj.Name
                        table.insert(labels, lbl)
                    end
                end
            end
        end
    end
end)

print("Готово. Правый Shift — меню.")
