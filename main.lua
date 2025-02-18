local ToggleKey = Enum.KeyCode.X
local TeleportInterval = 0.3

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local isRunning = false
local connection
local cooldown = false

local function collectBadges()
    local badges = {}
    local obby = workspace:FindFirstChild("obby")
    if obby then
        local badgeFolder = obby:FindFirstChild("Badge")
        if badgeFolder then
            for _, badge in ipairs(badgeFolder:GetChildren()) do
                if badge:IsA("Model") and badge.Name:match("Badge%d+") then
                    table.insert(badges, badge)
                end
            end
        end
    end
    table.sort(badges, function(a, b)
        return tonumber(a.Name:match("%d+")) < tonumber(b.Name:match("%d+"))
    end)
    return badges
end

local function safeTeleport(target)
    if not target or not target.PrimaryPart then return false end
    local character = Players.LocalPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoid and rootPart then
        if cooldown then return false end
        cooldown = true
        rootPart.CFrame = target.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
        task.delay(0.5, function()
            cooldown = false
        end)
        return true
    end
    return false
end

local function startCollection(badges)
    isRunning = true
    local currentIndex = 1
    while isRunning and #badges > 0 do
        local badge = badges[currentIndex]
        if badge and badge.Parent then
            local success = safeTeleport(badge)
            if success then
                print("[Success] Collected:", badge.Name)
                currentIndex = (currentIndex % #badges) + 1
            end
        else
            badges = collectBadges()
            currentIndex = 1
        end
        task.wait(TeleportInterval)
    end
end

local function toggleScript()
    isRunning = not isRunning
    if isRunning then
        print("[Status] Script activated")
        local badges = collectBadges()
        if #badges == 0 then
            warn("[Error] No badges found in workspace/obby/Badge")
            return
        end
        coroutine.wrap(startCollection)(badges)
    else
        print("[Status] Script deactivated")
    end
end

local function onInput(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == ToggleKey then
        toggleScript()
    end
end

local function initialize()
    if connection then
        connection:Disconnect()
    end
    connection = UserInputService.InputBegan:Connect(onInput)
    print(string.format(
        "[Info] Script initialized\nPress %s to toggle\nBadge count: %d",
        ToggleKey.Name,
        #collectBadges()
    ))
end

initialize()

game:GetService("RunService").Heartbeat:Connect(function()
    if not isRunning then
    end
end)
