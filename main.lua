-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Load Kavo UI Library (free, reliable)
local Library = loadstring(game:HttpGet("loadstring(game:HttpGet('https://sirius.menu/rayfield')
-- Create the main GUI window
local Window = Library.CreateLib("Blade Ball Elite GUI","Serpent")
local MainTab = Window:NewTab("Main")
local ControlSection = MainTab:NewSection("GUI Controls")
local ThemeSection = MainTab:NewSection("Theme Customization")
local CheatsSection = MainTab:NewSection("Blade Ball Cheats")

-- Variables for GUI control
local isMinimized = false
local originalSize = UDim2.new(0, 550, 0, 400)
local isDragging = false
local dragStartPos = nil
local startPos = nil
local transparency = 1

-- Variables for cheats
local autoParryEnabled = false
local aimbotEnabled = false
local espEnabled = false
local aimbotTarget ="Ball" -- Can switch to"Player" via dropdown
local espFolder = Instance.new("Folder", game.CoreGui)

-- Minimize Button
ControlSection:NewButton("Minimize/Restore","Toggle GUI size", function()
    if isMinimized then
        Window.MainFrame:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
        isMinimized = false
    else
        originalSize = Window.MainFrame.Size
        Window.MainFrame:TweenSize(UDim2.new(0, originalSize.X.Offset, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3, true)
        isMinimized = true
    end
end)

-- Close Button
ControlSection:NewButton("Close GUI","Exit the GUI", function()
    Library:ToggleUI()
    espEnabled = false -- Disable ESP to clear highlights
    espFolder:ClearAllChildren()
end)

-- Resize Slider
ControlSection:NewSlider("Window Width","Adjust GUI width", 700, 300, function(value)
    if not isMinimized then
        local newSize = UDim2.new(0, value, 0, value* 0.73)
        Window.MainFrame:TweenSize(newSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        originalSize = newSize
    end
end)

-- Transparency Slider
ControlSection:NewSlider("GUI Transparency","Adjust GUI transparency", 1, 0, function(value)
    transparency = value
    Window.MainFrame.BackgroundTransparency = 1 - value
    for_, element in pairs(Window.MainFrame:GetDescendants()) do
        if element:IsA("GuiObject") and element ~= Window.MainFrame then
            element.BackgroundTransparency = 1 - value
            if element:IsA("TextLabel") or element:IsA("TextButton") then
                element.TextTransparency = 1 - value
            end
        end
    end
end)

-- Draggable GUI Logic
local frame = Window.MainFrame
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not isMinimized then
        isDragging = true
        dragStartPos = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
        local delta = input.Position - dragStartPos
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Theme Customization
ThemeSection:NewDropdown("Theme","Change GUI theme", {"Serpent","Synapse","Dark","Light"}, function(theme)
    Library:ChangeTheme(theme)
end)

ThemeSection:NewColorPicker("Accent Color","Customize accent color", Color3.fromRGB(255, 50, 50), function(color)
    Library:SetAccentColor(color)
end)

-- Auto-Parry Toggle
CheatsSection:NewToggle("Auto-Parry","Automatically parry the ball", function(state)
    autoParryEnabled = state
    Library:Notify({
        Title ="Auto-Parry",
        Content = state and"Auto-Parry enabled!" or"Auto-Parry disabled.",
        Duration = 3
    })
end)

-- Aimbot Toggle
CheatsSection:NewToggle("Aimbot","Lock onto ball or player", function(state)
    aimbotEnabled = state
    Library:Notify({
        Title ="Aimbot",
        Content = state and"Aimbot enabled!" or"Aimbot disabled.",
        Duration = 3
    })
end)

-- Aimbot Target Selector
CheatsSection:NewDropdown("Aimbot Target","Choose aimbot target", {"Ball","Player"}, function(value)
    aimbotTarget = value
    Library:Notify({
        Title ="Aimbot",
        Content ="Aimbot target set to:" .. value,
        Duration = 3
    })
end)

-- ESP Toggle
CheatsSection:NewToggle("ESP","Highlight players and ball", function(state)
    espEnabled = state
    if not state then
        espFolder:ClearAllChildren()
    end
    Library:Notify({
        Title ="ESP",
        Content = state and"ESP enabled!" or"ESP disabled.",
        Duration = 3
    })
end)

-- Auto-Parry Logic
RunService.Heartbeat:Connect(function()
    if autoParryEnabled then
        local ball = workspace:FindFirstChild("Ball")
        if ball and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (ball.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            local isTargeting = ball:GetAttribute("Target") == LocalPlayer.Name
            if isTargeting and distance < 15 then -- Parry when ball is close and targeting
                local parryButton = LocalPlayer.PlayerGui:FindFirstChild("MobileParry") and LocalPlayer.PlayerGui.MobileParry.Parry
                if parryButton then
                    virtualInputManager:SendMouseButtonEvent(parryButton.AbsolutePosition.X + 10, parryButton.AbsolutePosition.Y + 10, 0, true, game, 0)
                    wait(0.1)
                    virtualInputManager:SendMouseButtonEvent(parryButton.AbsolutePosition.X + 10, parryButton.AbsolutePosition.Y + 10, 0, false, game, 0)
                end
            end
        end
    end
end)

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target
        if aimbotTarget =="Ball" then
            target = workspace:FindFirstChild("Ball")
        elseif aimbotTarget =="Player" then
            local closestPlayer = nil
            local closestDistance = math.huge
            for_, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
            target = closestPlayer and closestPlayer.Character and closestPlayer.Character.HumanoidRootPart
        end
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- ESP Logic
RunService.RenderStepped:Connect(function()
    if espEnabled then
        espFolder:ClearAllChildren()
        -- Ball ESP
        local ball = workspace:FindFirstChild("Ball")
        if ball then
            local highlight = Instance.new("Highlight", espFolder)
            highlight.Adornee = ball
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
        end
        -- Player ESP
        for_, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = Instance.new("Highlight", espFolder)
                highlight.Adornee = player.Character
                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                -- Distance Label
                local billboard = Instance.new("BillboardGui", espFolder)
                billboard.Adornee = player.Character.HumanoidRootPart
                billboard.Size = UDim2.new(0, 100, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                local text = Instance.new("TextLabel", billboard)
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.Text = player.Name .. " (" .. math.floor((player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. " studs)"
            end
        end
    end
end)

-- GUI Opening Animation
Window.MainFrame.Position = UDim2.new(0.5, -275, 1, 0)
Window.MainFrame:TweenPosition(UDim2.new(0.5, -275, 0.5, -200), Enum.EasingDirection.Out, Enum.EasingStyle.Bounce, 0.5, true)

-- Keep GUI on top
RunService:BindToRenderStep("KeepOnTop", 100, function()
    Window.MainFrame.ZIndex = 1000
end)

-- Welcome Notification
Library:Notify({
    Title ="Blade Ball Elite GUI",
    Content ="Loaded successfully! Dominate Blade Ball with Auto-Parry, Aimbot, and ESP!",
    Duration = 5
})
