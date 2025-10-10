repeat wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

local ConfigFile = "x2zu_stellar_config.txt"

local function SaveConfig(config)
    local HttpService = game:GetService("HttpService")
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(config)
    end)
    if success then
        writefile(ConfigFile, encoded)
        return true
    end
    return false
end

local function LoadConfig()
    local HttpService = game:GetService("HttpService")
    if isfile(ConfigFile) then
        local content = readfile(ConfigFile)
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success then
            return decoded
        end
    end
    return {}
end

local ConfigState = LoadConfig()

local Window = Library:Window({
    Title = "Balihai [Premium]",
    Desc = "",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "Balihai"
    }
})

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(0, 140, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 5
SidebarLine.Name = "SidebarLine"
SidebarLine.Parent = game:GetService("CoreGui")

local Tab = Window:Tab({Title = "Main", Icon = "star"})

Tab:Section({Title = "Auto Farm Dungeon"})

local ToggleReturn, ToggleGoAgain, ToggleNextDifficulty, Toggle

local function SetConfig(key, value)
    ConfigState[key] = value
    if key == "AutoReturnLobby" and ToggleReturn and ToggleReturn.Set then
        ToggleReturn.Set(value)
    elseif key == "AutoPlayAgain" and ToggleGoAgain and ToggleGoAgain.Set then
        ToggleGoAgain.Set(value)
    elseif key == "AutoNextDifficulty" and ToggleNextDifficulty and ToggleNextDifficulty.Set then
        ToggleNextDifficulty.Set(value)
    elseif key == "EnableAutoDungeon" and Toggle and Toggle.Set then
        Toggle.Set(value)
    end
end

ToggleReturn = Tab:Toggle({
    Title = "Auto Return To lobby",
    Desc = "Automatically return to lobby after dungeon",
    Value = (ConfigState.AutoReturnLobby == nil and false) or ConfigState.AutoReturnLobby,
    Callback = function(Value)
        ConfigState.AutoReturnLobby = Value
        if Value then
            ToggleReturn.Connection = game:GetService("RunService").RenderStepped:Connect(function()
                local args = {"Return"}
                game:GetService("ReplicatedStorage"):WaitForChild("Systems"):WaitForChild("Dungeons"):WaitForChild("SetExitChoice"):FireServer(unpack(args))
            end)
        else
            if ToggleReturn.Connection then
                ToggleReturn.Connection:Disconnect()
                ToggleReturn.Connection = nil
            end
        end
    end
})

function ToggleReturn.Set(v)
    if ToggleReturn.Value ~= v then
        ToggleReturn:SetState(v)
    end
end

ToggleGoAgain = Tab:Toggle({
    Title = "Auto Play Again",
    Desc = "Automatically play again after dungeon",
    Value = (ConfigState.AutoPlayAgain == nil and false) or ConfigState.AutoPlayAgain,
    Callback = function(Value)
        ConfigState.AutoPlayAgain = Value
        if Value then
            ToggleGoAgain.Connection = game:GetService("RunService").RenderStepped:Connect(function()
                local args = {"GoAgain"}
                game:GetService("ReplicatedStorage"):WaitForChild("Systems"):WaitForChild("Dungeons"):WaitForChild("SetExitChoice"):FireServer(unpack(args))
            end)
        else
            if ToggleGoAgain.Connection then
                ToggleGoAgain.Connection:Disconnect()
                ToggleGoAgain.Connection = nil
            end
        end
    end
})

function ToggleGoAgain.Set(v)
    if ToggleGoAgain.Value ~= v then
        ToggleGoAgain:SetState(v)
    end
end

ToggleNextDifficulty = Tab:Toggle({
    Title = "Auto Next Difficulty",
    Desc = "Automatically proceed to next difficulty",
    Value = (ConfigState.AutoNextDifficulty == nil and true) or ConfigState.AutoNextDifficulty,
    Callback = function(Value)
        ConfigState.AutoNextDifficulty = Value
        if Value then
            ToggleNextDifficulty.Connection = game:GetService("RunService").RenderStepped:Connect(function()
                local args = {"NextDifficulty"}
                game:GetService("ReplicatedStorage"):WaitForChild("Systems"):WaitForChild("Dungeons"):WaitForChild("SetExitChoice"):FireServer(unpack(args))
            end)
        else
            if ToggleNextDifficulty.Connection then
                ToggleNextDifficulty.Connection:Disconnect()
                ToggleNextDifficulty.Connection = nil
            end
        end
    end
})

function ToggleNextDifficulty.Set(v)
    if ToggleNextDifficulty.Value ~= v then
        ToggleNextDifficulty:SetState(v)
    end
end

if not ConfigState.AutoDungeonSpeed then
    ConfigState.AutoDungeonSpeed = "Normal"
end

-- ตั้งค่าความเร็วใหม่ (fix 0.17)
getgenv()._autoDungeonSpeedValue = 0.17

Toggle = Tab:Toggle({
    Title = "Enable Auto Dungeon",
    Desc = "Automatically farm dungeons (player killaura)",
    Value = (ConfigState.EnableAutoDungeon == nil and true) or ConfigState.EnableAutoDungeon,
    Callback = function(Value)
        ConfigState.EnableAutoDungeon = Value
        getgenv().AutoDungeon = Value

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Combat = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat")
        local PlayerAttack = Combat:WaitForChild("PlayerAttack")
        local Dungeons = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Dungeons")
        local TriggerStartDungeon = Dungeons:WaitForChild("TriggerStartDungeon")
        local Mobs = workspace:WaitForChild("Mobs")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local TweenService = game:GetService("TweenService")

        local function isMyPet(model)
            if not model or not model:IsA("Model") then return false end
            local owner = model:GetAttribute("Owner")
            if owner and tostring(owner) == tostring(LocalPlayer.Name) then
                return true
            end
            return false
        end

        local function getHRP()
            local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            return Char:FindFirstChild("HumanoidRootPart")
        end

        local function isMobAlive(mob)
            if not mob or not mob.Parent then
                return false
            end
            local hp = mob:GetAttribute("HP")
            return hp == nil or hp > 0
        end

        local function bypass_teleport(targetCFrame, tweenTime)
            tweenTime = tweenTime or 0.5
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then
                local tweeninfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(
                    LocalPlayer.Character.HumanoidRootPart,
                    tweeninfo,
                    {CFrame = targetCFrame}
                )
                tween:Play()
                return tween
            end
            return nil
        end

        if Value then
            pcall(function()
                TriggerStartDungeon:FireServer()
            end)

            if not getgenv()._dungeonFarmThread or not getgenv()._dungeonFarmThreadAlive then
                getgenv()._dungeonFarmThreadAlive = true
                getgenv()._dungeonFarmThread = coroutine.create(function()
                    local currentTarget = nil
                    local currentTween = nil
                    local isAtPosition = false
                    local antiGravity = nil

                    local function enableAntiGravity(HRP)
                        if HRP and HRP.Parent then
                            local bodyVelocity = HRP:FindFirstChild("AntiGravity")
                            if not bodyVelocity then
                                bodyVelocity = Instance.new("BodyVelocity")
                                bodyVelocity.Name = "AntiGravity"
                                bodyVelocity.Parent = HRP
                            end
                            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
                            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                            return bodyVelocity
                        end
                        return nil
                    end

                    local function disableAntiGravity(HRP)
                        if HRP then
                            local bodyVelocity = HRP:FindFirstChild("AntiGravity")
                            if bodyVelocity then
                                bodyVelocity:Destroy()
                            end
                        end
                    end

                    local function onMobAdded(mob)
                        if mob:IsA("Model") then
                            mob:WaitForChild("HumanoidRootPart", 5)
                        end
                    end

                    local mobAddedConnection = Mobs.ChildAdded:Connect(onMobAdded)
                    local mobRemovedConnection = Mobs.ChildRemoved:Connect(function(mob)
                        if currentTarget == mob then
                            currentTarget = nil
                            isAtPosition = false
                            if currentTween then
                                currentTween:Cancel()
                                currentTween = nil
                            end
                        end
                    end)

                    local HRP = getHRP()
                    antiGravity = enableAntiGravity(HRP)

                    while getgenv()._dungeonFarmThreadAlive do
                        local waitSpeed = getgenv()._autoDungeonSpeedValue or 0.17
                        local success = pcall(function()
                            local mobs = {}
                            for _, mob in ipairs(Mobs:GetChildren()) do
                                if mob:IsA("Model") and not isMyPet(mob) and mob:FindFirstChild("HumanoidRootPart") and isMobAlive(mob) then
                                    table.insert(mobs, mob)
                                end
                            end

                            if #mobs == 0 then
                                currentTarget = nil
                                isAtPosition = false
                                if currentTween then
                                    currentTween:Cancel()
                                    currentTween = nil
                                end
                                return
                            end

                            if currentTarget and (not currentTarget.Parent or not isMobAlive(currentTarget) or isMyPet(currentTarget)) then
                                currentTarget = nil
                                isAtPosition = false
                                if currentTween then
                                    currentTween:Cancel()
                                    currentTween = nil
                                end
                            end

                            if not currentTarget then
                                local HRP = getHRP()
                                local closestMob = nil
                                local closestDistance = math.huge

                                if HRP then
                                    for _, mob in ipairs(mobs) do
                                        local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                                        if mobHRP then
                                            local distance = (HRP.Position - mobHRP.Position).Magnitude
                                            if distance < closestDistance then
                                                closestDistance = distance
                                                closestMob = mob
                                            end
                                        end
                                    end
                                end

                                currentTarget = closestMob
                                isAtPosition = false
                            end

                            local HRP = getHRP()
                            if HRP and currentTarget and currentTarget.Parent and not isMyPet(currentTarget) then
                                if not HRP:FindFirstChild("AntiGravity") then
                                    antiGravity = enableAntiGravity(HRP)
                                end

                                local mobHRP = currentTarget:FindFirstChild("HumanoidRootPart")
                                if mobHRP then
                                    local targetPos = mobHRP.Position + Vector3.new(0,30,0)
                                    local distance = (HRP.Position - targetPos).Magnitude

                                    if distance > 5 then
                                        isAtPosition = false

                                        if currentTween then
                                            currentTween:Cancel()
                                        end

                                        local speed = 100
                                        local tweenTime = math.clamp(distance / speed, 0.2, 1)
                                        local targetCFrame = CFrame.new(targetPos, mobHRP.Position)
                                        currentTween = bypass_teleport(targetCFrame, tweenTime)

                                        if currentTween then
                                            currentTween.Completed:Connect(function()
                                                isAtPosition = true
                                            end)
                                        end
                                    else
                                        isAtPosition = true
                                        if currentTween then
                                            currentTween:Cancel()
                                            currentTween = nil
                                        end

                                        local targetCFrame = CFrame.new(targetPos, mobHRP.Position)
                                        HRP.CFrame = targetCFrame
                                        HRP.Velocity = Vector3.new(0, 0, 0)
                                        HRP.RotVelocity = Vector3.new(0, 0, 0)
                                    end
                                end
                            end

                            pcall(function()
                                local aliveMobs = {}
                                for _, mob in ipairs(mobs) do
                                    if mob and mob.Parent and mob:FindFirstChild("HumanoidRootPart") then
                                        local hp = mob:GetAttribute("HP")
                                        if hp == nil or hp > 0 then
                                            table.insert(aliveMobs, mob)
                                        end
                                    end
                                end

                                if #aliveMobs > 0 then
                                    PlayerAttack:FireServer(aliveMobs)
                                end
                            end)
                        end)

                        if not success then
                            task.wait(waitSpeed)
                        end
                        task.wait(waitSpeed)
                    end

                    local HRP = getHRP()
                    disableAntiGravity(HRP)

                    if mobAddedConnection then
                        mobAddedConnection:Disconnect()
                    end
                    if mobRemovedConnection then
                        mobRemovedConnection:Disconnect()
                    end
                    if currentTween then
                        currentTween:Cancel()
                    end
                end)
                coroutine.resume(getgenv()._dungeonFarmThread)
            end
        else
            getgenv()._dungeonFarmThreadAlive = false
            task.wait(getgenv()._autoDungeonSpeedValue or 0.17)
            local HRP = getHRP()
            if HRP then
                local bodyVelocity = HRP:FindFirstChild("AntiGravity")
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
            end
        end
    end
})

function Toggle.Set(v)
    if Toggle.Value ~= v then
        Toggle:SetState(v)
    end
end

PetAuraToggle = Tab:Toggle({
    Title = "Enable Pet Killaura",
    Desc = "",
    Value = (ConfigState.EnablePetKillaura == nil and true) or ConfigState.EnablePetKillaura,
    Callback = function(Value)
        ConfigState.EnablePetKillaura = Value
        getgenv().EnablePetKillaura = Value

        -- ป้องกัน Thread ซ้อน/loop ทับ
        if getgenv()._petKillauraThread and coroutine.status(getgenv()._petKillauraThread) ~= "dead" then
            getgenv()._petKillauraThreadAlive = false
            task.wait(0.05)
        end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Combat = ReplicatedStorage:WaitForChild("Systems"):WaitForChild("Combat")
        local PetDamage = Combat:WaitForChild("PetDamage")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Mobs = workspace:WaitForChild("Mobs")

        local function isMyPet(model)
            if not model or not model:IsA("Model") then return false end
            local owner = model:GetAttribute("Owner")
            return owner and tostring(owner) == tostring(LocalPlayer.Name)
        end

        if Value then
            if not getgenv()._petKillauraThread or coroutine.status(getgenv()._petKillauraThread) == "dead" then
                getgenv()._petKillauraThreadAlive = true
                getgenv()._petKillauraThread = coroutine.create(function()
                    while getgenv()._petKillauraThreadAlive do
                        local success = pcall(function()
                            local myPet, petName = nil, nil

                            for _, mob in ipairs(Mobs:GetChildren()) do
                                if mob:IsA("Model") and isMyPet(mob) then
                                    myPet = mob
                                    petName = mob.Name
                                    break
                                end
                            end

                            if myPet and petName then
                                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                                local petData = ReplicatedStorage:WaitForChild("Mobs"):FindFirstChild(petName)
                                if petData then
                                    local attacksFolder = petData:FindFirstChild("Attacks")
                                    if attacksFolder then
                                        local skillName = nil
                                        local skillEffect = nil

                                        for _, skill in ipairs(attacksFolder:GetChildren()) do
                                            if skill:IsA("Folder") then
                                                skillName = skill.Name
                                                for _, effect in ipairs(skill:GetChildren()) do
                                                    skillEffect = effect
                                                    break
                                                end
                                                if skillEffect then break end
                                            end
                                        end

                                        if skillName and skillEffect then
                                            local targets = {}
                                            for _, mob in ipairs(Mobs:GetChildren()) do
                                                if mob:IsA("Model") and mob ~= myPet and not isMyPet(mob) then
                                                    table.insert(targets, mob)
                                                end
                                            end

                                            if #targets > 0 then
                                                -- จำกัดการยิงเพื่อลด ping/lag
                                                local args = {
                                                    myPet,
                                                    skillName,
                                                    skillEffect,
                                                    targets
                                                }
                                                PetDamage:FireServer(unpack(args))
                                                -- ปรับเลข loop หรือคอมเมนต์ทิ้งเพื่อเพิ่มหรือลดความเร็ว
                                                -- for i = 1, 2 do
                                                --     PetDamage:FireServer(unpack(args))
                                                -- end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                        task.wait(0.01) -- หน่วง loop ลด ping (เดิม 0.01)
                    end
                end)
                coroutine.resume(getgenv()._petKillauraThread)
            end
        else
            getgenv()._petKillauraThreadAlive = false
            task.wait(0.05)
        end
    end
})

function PetAuraToggle.Set(v)
    if PetAuraToggle.Value ~= v then
        PetAuraToggle:SetState(v)
    end
end



local Config = Window:Tab({Title = "Save Config", Icon = "star"})
Config:Section({Title = "Save Config"})

Config:Button({
    Title = "Save Config",
    Desc = "",
    Callback = function()
        if SaveConfig(ConfigState) then
            Window:Notify({
                Title = "Config",
                Desc = "บันทึก config สำเร็จ!",
                Time = 2
            })
        else
            Window:Notify({
                Title = "Config",
                Desc = "บันทึก config ไม่สำเร็จ",
                Time = 2
            })
        end
    end
})

task.defer(function()
    if ConfigState.AutoReturnLobby ~= nil and ToggleReturn.Set then 
        ToggleReturn.Set(ConfigState.AutoReturnLobby) 
    end
    if ConfigState.AutoPlayAgain ~= nil and ToggleGoAgain.Set then 
        ToggleGoAgain.Set(ConfigState.AutoPlayAgain) 
    end
    if ConfigState.AutoNextDifficulty ~= nil and ToggleNextDifficulty.Set then 
        ToggleNextDifficulty.Set(ConfigState.AutoNextDifficulty) 
    end
    if ConfigState.EnableAutoDungeon ~= nil and Toggle.Set then 
        Toggle.Set(ConfigState.EnableAutoDungeon) 
    end
end)

Window:Notify({
    Title = "x2zu",
    Desc = "All components loaded successfully! Credits leak: @x2zu",
    Time = 4
})
