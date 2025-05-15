local usernameBypass = "hackforfunmyg"
local requiredKey = "iqsm.-is-king"
local player = game.Players.LocalPlayer
if not player or not player:IsDescendantOf(game) then return end

local bypass = (player.Name == usernameBypass)
local clipboardSet = setclipboard or toclipboard or function() end
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

local device = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and "Mobile" or "PC"

local gui = Rayfield:CreateWindow({
    Name = "iqsm. ware",
    LoadingTitle = "Loading iqsm. ware",
    LoadingSubtitle = "by Maybecool",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "iqsmware",
        FileName = "config"
    },
    Discord = {
        Enabled = true,
        Invite = "7rxmvpCP",
        RememberJoins = true
    },
    KeySystem = false
})

local enteredKey = ""
local keyAccepted = false

local function notify(text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "iqsm. ware",
            Text = text,
            Duration = 5
        })
    end)
end

local keyWindow = Rayfield:CreateWindow({
    Name = "iqsm. ware | Key System",
    LoadingTitle = "Enter your key",
    LoadingSubtitle = "Join discord.gg/7rxmvpCP for key",
    ConfigurationSaving = { Enabled = false }
})

local keyTab = keyWindow:CreateTab("Key")

keyTab:CreateBox({
    Name = "Enter Key",
    PlaceholderText = "Paste your key here",
    RemoveTextAfterFocusLost = true,
    Callback = function(value)
        enteredKey = value
    end
})

keyTab:CreateButton({
    Name = "Check Key",
    Callback = function()
        if enteredKey == requiredKey or bypass then
            notify("Key valid! Loading script...")
            keyAccepted = true
            keyWindow:Close()
            gui:Show()
            loadMainUI()
        else
            notify("Invalid key! Join Discord for the key.")
        end
    end
})

keyTab:CreateButton({
    Name = "Get Discord Link",
    Callback = function()
        clipboardSet("https://discord.gg/7rxmvpCP")
        notify("Discord link copied to clipboard!")
    end
})

if bypass then
    notify("Bypass active! Loading script...")
    keyAccepted = true
    keyWindow:Close()
    gui:Show()
    loadMainUI()
else
    gui:Hide()
end

function loadMainUI()
    local tabAim = gui:CreateTab("Aimbot")
    local tabVis = gui:CreateTab("Visuals")
    local tabMisc = gui:CreateTab("Misc")

    local aimbotSettings = {
        Enabled = false,
        TargetPart = "Head",
        Smoothness = 4,
        FOV = 100
    }

    local espEnabled = false
    local espBoxes = {}

    local function getClosestPlayerToCursor()
        local mouse = player:GetMouse()
        local closestPlayer
        local shortestDistance = aimbotSettings.FOV
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local rootPart = plr.Character:FindFirstChild(aimbotSettings.TargetPart) or plr.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestPlayer = plr
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    local function aimAtTarget(target)
        if not target or not target.Character or not target.Character:FindFirstChild(aimbotSettings.TargetPart) then return end
        local camera = workspace.CurrentCamera
        local targetPos = target.Character[aimbotSettings.TargetPart].Position
        local cameraPos = camera.CFrame.Position
        local direction = (targetPos - cameraPos).Unit
        local desiredCFrame = CFrame.new(cameraPos, cameraPos + direction)
        local currentCFrame = camera.CFrame
        local smoothCFrame = currentCFrame:Lerp(desiredCFrame, 1 / aimbotSettings.Smoothness)
        camera.CFrame = smoothCFrame
    end

    RunService:BindToRenderStep("AimBot", Enum.RenderPriority.Camera.Value + 1, function()
        if aimbotSettings.Enabled then
            local target = getClosestPlayerToCursor()
            if target then
                aimAtTarget(target)
            end
        end
    end)

    tabAim:CreateToggle({
        Name = "Enable Aimbot",
        CurrentValue = false,
        Flag = "AimbotEnabled",
        Callback = function(val)
            aimbotSettings.Enabled = val
        end
    })

    tabAim:CreateDropdown({
        Name = "Target Part",
        Options = {"Head", "HumanoidRootPart", "Torso"},
        CurrentOption = "Head",
        Flag = "TargetPart",
        Callback = function(val)
            aimbotSettings.TargetPart = val
        end
    })

    tabAim:CreateSlider({
        Name = "Smoothness",
        Range = {1, 20},
        Increment = 1,
        Suffix = "",
        CurrentValue = aimbotSettings.Smoothness,
        Flag = "Smoothness",
        Callback = function(val)
            aimbotSettings.Smoothness = val
        end
    })

    tabAim:CreateSlider({
        Name = "FOV",
        Range = {50, 500},
        Increment = 1,
        Suffix = "px",
        CurrentValue = aimbotSettings.FOV,
        Flag = "FOV",
        Callback = function(val)
            aimbotSettings.FOV = val
        end
    })

    local function createESPBox(plr)
        if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = plr.Character.HumanoidRootPart
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Transparency = 0.5
        box.Size = plr.Character:GetExtentsSize()
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Parent = game.CoreGui
        espBoxes[plr] = box
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                box.Adornee = plr.Character.HumanoidRootPart
                box.Color3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            else
                box:Destroy()
                conn:Disconnect()
                espBoxes[plr] = nil
            end
        end)
    end

    tabVis:CreateToggle({
        Name = "Enable ESP",
        CurrentValue = false,
        Flag = "ESPEnabled",
        Callback = function(val)
            espEnabled = val
            if val then
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= player then
                        createESPBox(plr)
                    end
                end
                Players.PlayerAdded:Connect(function(p)
                    p.CharacterAdded:Connect(function()
                        if espEnabled and p ~= player then
                            createESPBox(p)
                        end
                    end)
                end)
            else
                for _, box in pairs(espBoxes) do
                    box:Destroy()
                end
                espBoxes = {}
            end
        end
    })

    tabMisc:CreateButton({
        Name = "Unload Script",
        Callback = function()
            notify("Unloading iqsm. ware...")
            for _, v in pairs(game.CoreGui:GetChildren()) do
                if v:IsA("ScreenGui") and v.Name:find("iqsm") then
                    v:Destroy()
                end
            end
            RunService:UnbindFromRenderStep("AimBot")
        end
    })

    local hidden = false
    UserInputService.InputBegan:Connect(function(input, gpe)
        if input.KeyCode == Enum.KeyCode.RightShift and not gpe then
            hidden = not hidden
            for _, v in pairs(game.CoreGui:GetChildren()) do
                if v:IsA("ScreenGui") and v.Name:find("iqsm") then
                    v.Enabled = not hidden
                end
            end
        end
    end)

    local watermarkGui = Instance.new("ScreenGui")
    watermarkGui.Name = "iqsmWatermark"
    watermarkGui.ResetOnSpawn = false
    watermarkGui.Parent = player:WaitForChild("PlayerGui")

    local watermark = Instance.new("TextLabel")
    watermark.Size = UDim2.new(0, 250, 0, 35)
    watermark.Position = UDim2.new(0, 10, 0, 10)
    watermark.BackgroundTransparency = 1
    watermark.Text = "Maybecool"
    watermark.Font = Enum.Font.LuckiestGuy
    watermark.TextSize = 36
    watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
    watermark.TextStrokeTransparency = 0.5
    watermark.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    watermark.Parent = watermarkGui

    notify("Device detected: "..device..". Press RightShift to toggle UI.")
end

if not bypass then
    keyWindow:Show()
else
    loadMainUI()
    gui:Show()
end
