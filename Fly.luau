-- FlyScript.luau
-- LocalScript dentro de StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local SPEED = 10

local flying = false
local canFly = false
local bodyVelocity
local bodyGyro

local function toggleFly(active: boolean)
    local character = player.Character
    if not character or not character.PrimaryPart then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    local rootPart = character.PrimaryPart

    if active then
        -- 🔑 Darle control al cliente de las físicas
        pcall(function()
            rootPart:SetNetworkOwner(player)
        end)

        -- Desactivar caminar
        humanoid.WalkSpeed = 0
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

        -- BodyVelocity
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart

        -- BodyGyro
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
        bodyGyro.CFrame = rootPart.CFrame
        bodyGyro.P = 25000
        bodyGyro.Parent = rootPart

        flying = true
        print("✅ Vuelo activado")
    else
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
        humanoid.WalkSpeed = 16
        flying = false
        print("❌ Vuelo desactivado")
    end
end

local function setupInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.E then
            canFly = not canFly
            toggleFly(canFly)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not canFly or not flying then return end

        local character = player.Character
        if not character or not character.PrimaryPart or not bodyVelocity or not bodyGyro then return end

        local rootPart = character.PrimaryPart
        local cam = Workspace.CurrentCamera
        if not cam then return end

        local velocity = Vector3.new(0, 0, 0)
        local speed = SPEED

        local forward = cam.CFrame.LookVector
        local right = cam.CFrame.RightVector
        local up = Vector3.new(0, 1, 0)

        -- Corrección: W = adelante, S = atrás
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity = velocity + (forward * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity = velocity - (forward * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity = velocity - (right * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity = velocity + (right * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + (up * speed)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            velocity = velocity - (up * speed)
        end

        bodyVelocity.Velocity = velocity
        bodyGyro.CFrame = cam.CFrame
    end)
end

player.CharacterAdded:Connect(function()
    print("🔁 Personaje cargado. Usa E para volar.")
    setupInput()
end)

if player.Character then
    print("🔁 Personaje ya existe. Activando vuelo.")
    setupInput()
end
