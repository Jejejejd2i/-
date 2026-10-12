local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local open = make("TextButton", {
    Size = UDim2.fromOffset(55, 55),
    Position = UDim2.new(0, 20, 0.5, -27),
    Text = "👟",
    TextSize = 28,
    BackgroundColor3 = Color3.fromRGB(35, 35, 45),
    TextColor3 = Color3.new(1, 1, 1)
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, open)

local frame = make("Frame", {
    Size = UDim2.fromOffset(270, 300),
    Position = UDim2.new(0.5, -135, 0.5, -150),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    Visible = false
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 14)}, frame)

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
    Text = "PLAYER MENU",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 20
}, frame)

local speedInput = make("TextBox", {
    Size = UDim2.new(1, -24, 0, 38),
    Position = UDim2.fromOffset(12, 45),
    PlaceholderText = "Скорость шага (1–2500)",
    Text = "",
    TextSize = 16,
    BackgroundColor3 = Color3.fromRGB(50, 50, 65),
    TextColor3 = Color3.new(1, 1, 1)
}, frame)

local function addButton(text, y)
    local b = make("TextButton", {
        Size = UDim2.new(1, -24, 0, 38),
        Position = UDim2.fromOffset(12, y),
        Text = text .. ": OFF",
        TextSize = 16,
        BackgroundColor3 = Color3.fromRGB(50, 50, 65),
        TextColor3 = Color3.new(1, 1, 1)
    }, frame)
    make("UICorner", {CornerRadius = UDim.new(0, 8)}, b)
    return b
end

local apply = addButton("Применить скорость", 90)
local jumpButton = addButton("Infinity Jump", 136)
local ghostButton = addButton("Ghost Mode", 182)
local guardButton = addButton("Anti-Guard (NPC)", 228)

make("UICorner", {CornerRadius = UDim.new(0, 8)}, speedInput)

open.Activated:Connect(function()
    frame.Visible = not frame.Visible
end)

local function getHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

apply.Text = "Применить скорость"
apply.Activated:Connect(function()
    local n = tonumber(speedInput.Text)
    local h = getHumanoid()
    if n and n >= 1 and n <= 2500 and n % 1 == 0 and h then
        h.WalkSpeed = n
        apply.Text = "Скорость: " .. n
    else
        apply.Text = "Введите число 1–2500"
    end
end)

local infinityJump = false
local ghost = false
local antiGuard = false

jumpButton.Activated:Connect(function()
    infinityJump = not infinityJump
    jumpButton.Text = "Infinity Jump: " .. (infinityJump and "ON" or "OFF")
end)

UIS.JumpRequest:Connect(function()
    if infinityJump then
        local h = getHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local originalCollisions = {}

local function setGhost(enabled)
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if enabled then
                if originalCollisions[part] == nil then
                    originalCollisions[part] = part.CanCollide
                end
                part.CanCollide = false
            elseif originalCollisions[part] ~= nil then
                part.CanCollide = originalCollisions[part]
                originalCollisions[part] = nil
            end
        end
    end
end

ghostButton.Activated:Connect(function()
    ghost = not ghost
    ghostButton.Text = "Ghost Mode: " .. (ghost and "ON" or "OFF")
    setGhost(ghost)
end)

guardButton.Activated:Connect(function()
    antiGuard = not antiGuard
    guardButton.Text = "Anti-Guard (NPC): " .. (antiGuard and "ON" or "OFF")
    player:SetAttribute("AntiGuard", antiGuard)
end)

RunService.Stepped:Connect(function()
    if ghost then setGhost(true) end
end)

player.CharacterAdded:Connect(function()
    table.clear(originalCollisions)
    task.wait(1)
    if ghost then setGhost(true) end
end)
