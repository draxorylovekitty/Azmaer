    local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
    local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
    local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
    
    local Window = Library:CreateWindow{
        Title = `Aimbot 4.0`,
        SubTitle = "by Actual Master Oogway",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Resize = true, -- Resize this ^ Size according to a 1920x1080 screen, good for mobile users but may look weird on some devices
        MinSize = Vector2.new(470, 380),
        Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl -- Used when theres no MinimizeKeybind
    }

    -- Fluent Renewed provides ALL 1544 Lucide 0.469.0 https://lucide.dev/icons/ Icons and ALL 9072 Phosphor 2.1.0 https://phosphoricons.com/ Icons for the tabs, icons are optional
    local Tabs = {
        Main = Window:CreateTab{
            Title = "Aimbot 4.0",
            Icon = "phosphor-users-bold"
        },

        Legit = Window:CreateTab{
            Title = "Legit",
            Icon = "phosphor-users-bold"
        },

        ESP = Window:CreateTab{
            Title = "ESP",
            Icon = "eye"
        },

        Settings = Window:CreateTab{
            Title = "Settings",
            Icon = "settings"
        }
    }

    local Options = Library.Options

    Library:Notify{
        Title = "Aimbot 4.0",
        Content = "",
        SubContent = "", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    }

    -- Aimbot 4.0: สามารถเลือกแกน X/Y ได้ + FOV, Smooth, Keybind + เลือกชิ้นส่วน + FOV Simple + ESP Head + Team Check + Toggle ESP
    -- เพิ่มความละเอียดของระบบ aimbot โดยไม่เพิ่ม UI
    -- เพิ่ม Legit: ปรับขนาด hitbox หัวและปรับขนาดได้

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    local UserInputService = game:GetService("UserInputService")
    local Drawing = Drawing or getgenv().Drawing -- For compatibility

    -- ตัวเลือกชิ้นส่วนที่นิยมใน Roblox humanoid
    local AIM_PARTS = {
        ["หัว (Head)"] = "Head",
        ["ลำตัว (Torso)"] = "HumanoidRootPart",
        ["บนตัว (UpperTorso)"] = "UpperTorso",
        ["ล่างตัว (LowerTorso)"] = "LowerTorso"
    }

    -- Team Check Toggle
    local TeamCheckToggle = Tabs.Main:CreateToggle("AimbotTeamCheck", {
        Title = "🛡️ Team Check",
        Default = true
    })
    TeamCheckToggle:OnChanged(function(Value)
        print("Team Check:", Value)
    end)
    Options.AimbotTeamCheck = TeamCheckToggle

    -- ESP Toggle
    local ESPToggle = Tabs.Main:CreateToggle("AimbotESP", {
        Title = "🧠 แสดง ESP",
        Default = true
    })
    ESPToggle:OnChanged(function(Value)
        print("ESP:", Value)
    end)
    Options.AimbotESP = ESPToggle

    -- Dropdown สำหรับเลือกชิ้นส่วน
    local AimbotPartDropdown = Tabs.Main:CreateDropdown("AimbotPart", {
        Title = "🎯 เลือกชิ้นส่วน",
        Values = {},
        Multi = false,
        Default = "HumanoidRootPart",
        Callback = function(Value)
            print("Aimbot Part Changed:", Value)
        end
    })

    do
        local partNames = {}
        for display, part in pairs(AIM_PARTS) do
            table.insert(partNames, display)
        end
        table.sort(partNames)
        AimbotPartDropdown:SetValues(partNames)
        if AIM_PARTS["ลำตัว (Torso)"] then
            AimbotPartDropdown:SetValue("ลำตัว (Torso)")
        else
            AimbotPartDropdown:SetValue(partNames[1])
        end
    end

    local AimbotToggle = Tabs.Main:CreateToggle("AimbotEnabled", {
        Title = "🔫 เปิดใช้งาน Aimbot",
        Default = false
    })

    AimbotToggle:OnChanged(function()
        print("Aimbot Enabled:", Options.AimbotEnabled.Value)
    end)

    Options.AimbotEnabled:SetValue(false)

    local ShowFOVToggle = Tabs.Main:CreateToggle("ShowFOV", {
        Title = "👁️ แสดง FOV",
        Default = true
    })

    ShowFOVToggle:OnChanged(function(Value)
        print("Show FOV:", Value)
    end)

    Options.ShowFOV:SetValue(true)

    local FOVSlider = Tabs.Main:CreateSlider("AimbotFOV", {
        Title = "🔵 FOV",
        Description = "ปรับขนาด FOV (องศา)",
        Default = 120,
        Min = 10,
        Max = 360,
        Rounding = 0,
        Callback = function(Value)
            print("FOV เปลี่ยนเป็น:", Value)
        end
    })

    FOVSlider:OnChanged(function(Value)
        print("FOV Changed:", Value)
    end)

    FOVSlider:SetValue(120)

    local SmoothSlider = Tabs.Main:CreateSlider("AimbotSmooth", {
        Title = "🔄 Smooth",
        Description = "ปรับความลื่นของการเล็ง (0 = ทันที, มาก = ลื่น)",
        Default = 2,
        Min = 0,
        Max = 20,
        Rounding = 1,
        Callback = function(Value)
            print("Smooth เปลี่ยนเป็น:", Value)
        end
    })

    SmoothSlider:OnChanged(function(Value)
        print("Smooth Changed:", Value)
    end)

    SmoothSlider:SetValue(2)

    local XSlider = Tabs.Main:CreateSlider("AimbotX", {
        Title = "🎯 X Offset",
        Description = "ปรับตำแหน่ง X ที่จะเล็ง (เช่น หัว/ตัว/ขา)",
        Default = 0,
        Min = -10,
        Max = 10,
        Rounding = 1,
        Callback = function(Value)
            print("X Offset เปลี่ยนเป็น:", Value)
        end
    })

    XSlider:OnChanged(function(Value)
        print("X Offset Changed:", Value)
    end)

    XSlider:SetValue(0)

    local YSlider = Tabs.Main:CreateSlider("AimbotY", {
        Title = "🎯 Y Offset",
        Description = "ปรับตำแหน่ง Y ที่จะเล็ง (เช่น หัว/ตัว/ขา)",
        Default = 0,
        Min = -10,
        Max = 10,
        Rounding = 1,
        Callback = function(Value)
            print("Y Offset เปลี่ยนเป็น:", Value)
        end
    })

    YSlider:OnChanged(function(Value)
        print("Y Offset Changed:", Value)
    end)

    YSlider:SetValue(0)

    local Keybind = Tabs.Main:CreateKeybind("AimbotKeybind", {
        Title = "KeyBind",
        Mode = "Hold",
        Default = "LeftControl",
        Callback = function(Value)
            print("Keybind clicked!", Value)
        end,
        ChangedCallback = function(New)
            print("Keybind changed!", New)
        end
    })

    Keybind:OnClick(function()
        print("Keybind clicked:", Keybind:GetState())
    end)

    Keybind:OnChanged(function()
        print("Keybind changed:", Keybind.Value)
    end)

    Keybind:SetValue("MB2", "Hold")

    -- LEGIT: ปรับขนาด hitbox หัว
    local LegitTab = Tabs.Legit

    local LegitHeadSizeSlider = LegitTab:CreateSlider("LegitHeadSize", {
        Title = "ขนาดหัว (Legit Head Size)",
        Description = "ปรับขนาด hitbox หัว (Legit)",
        Default = 2,
        Min = 1,
        Max = 10,
        Rounding = 2,
        Callback = function(Value)
            print("Legit Head Size เปลี่ยนเป็น:", Value)
        end
    })

    LegitHeadSizeSlider:OnChanged(function(Value)
        print("Legit Head Size Changed:", Value)
    end)

    LegitHeadSizeSlider:SetValue(2)

    local LegitEnabledToggle = LegitTab:CreateToggle("LegitHeadSizeEnabled", {
        Title = "เปิดใช้งาน Legit Head Size",
        Default = false
    })

    LegitEnabledToggle:OnChanged(function(Value)
        print("Legit Head Size Enabled:", Value)
    end)

    Options.LegitHeadSize = LegitHeadSizeSlider
    Options.LegitHeadSizeEnabled = LegitEnabledToggle

    -- ฟังก์ชัน Team Check
    local function IsEnemy(player)
        if not Options.AimbotTeamCheck or not Options.AimbotTeamCheck.Value then
            return true
        end
        if not LocalPlayer.Team or not player.Team then
            return true
        end
        return player.Team ~= LocalPlayer.Team
    end

    -- LEGIT: ปรับขนาด hitbox หัว (เฉพาะฝั่งศัตรู)
    local OriginalHeadSizes = {}

    local function SetLegitHeadSize()
        if not Options.LegitHeadSizeEnabled or not Options.LegitHeadSizeEnabled.Value then
            -- Restore all heads
            for player, origSize in pairs(OriginalHeadSizes) do
                if player and player.Character and player.Character:FindFirstChild("Head") then
                    local head = player.Character.Head
                    if head.Size ~= origSize then
                        pcall(function()
                            head.Size = origSize
                        end)
                    end
                end
            end
            return
        end

        local size = Vector3.new(Options.LegitHeadSize.Value, Options.LegitHeadSize.Value, Options.LegitHeadSize.Value)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if IsEnemy(player) then
                    local head = player.Character.Head
                    if not OriginalHeadSizes[player] then
                        OriginalHeadSizes[player] = head.Size
                    end
                    if head.Size ~= size then
                        pcall(function()
                            head.Size = size
                        end)
                    end
                end
            end
        end
    end

    -- เก็บข้อมูลเป้าหมายละเอียดมากขึ้น
    local function GetClosestTarget()
        local closestData = nil
        local shortestDistance = math.huge
        local fov = Options.AimbotFOV and Options.AimbotFOV.Value or 120
        local mousePos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                if IsEnemy(player) then
                    local selectedDisplay = AimbotPartDropdown.Value or "ลำตัว (Torso)"
                    local selectedPartName = AIM_PARTS[selectedDisplay] or "HumanoidRootPart"
                    local targetPart = player.Character:FindFirstChild(selectedPartName)
                    if targetPart then
                        local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if dist < shortestDistance and dist <= fov then
                                shortestDistance = dist
                                closestData = {
                                    Player = player,
                                    Character = player.Character,
                                    Part = targetPart,
                                    ScreenPosition = Vector2.new(pos.X, pos.Y),
                                    WorldPosition = targetPart.Position,
                                    Distance = dist,
                                    Health = player.Character:FindFirstChildOfClass("Humanoid").Health
                                }
                            end
                        end
                    end
                end
            end
        end
        return closestData
    end

    -- ฟังก์ชันคำนวณตำแหน่งเป้าหมายโดยใช้ X/Y Offset และชิ้นส่วนที่เลือก
    local function GetAimbotTargetPosition(targetCharacter, targetPart)
        local selectedDisplay = AimbotPartDropdown.Value or "ลำตัว (Torso)"
        local selectedPartName = AIM_PARTS[selectedDisplay] or "HumanoidRootPart"
        local part = targetPart or targetCharacter:FindFirstChild(selectedPartName)
        if not part then
            part = targetCharacter:FindFirstChild("HumanoidRootPart") or targetCharacter:FindFirstChild("Head")
            if not part then return nil end
        end
        local xOffset = Options.AimbotX.Value
        local yOffset = Options.AimbotY.Value
        local pos = part.Position + Vector3.new(xOffset, yOffset, 0)
        return pos
    end


    -- ESP System
    local HeadESPToggle = Tabs.ESP:CreateToggle("HeadESP", {
        Title = "ESP (Highlight ทุกคน)",
        Default = true
    })

    HeadESPToggle:OnChanged(function()
        print("Toggle changed:", Options.HeadESP.Value)
    end)

    Options.HeadESP = HeadESPToggle

    local HeadESPColor = Tabs.ESP:CreateColorpicker("HeadESPColor", {
        Title = "ศัตรู ESP Color",
        Default = Color3.fromRGB(255, 0, 0)
    })
    Options.HeadESPColor = HeadESPColor

    local TeamESPColor = Tabs.ESP:CreateColorpicker("TeamESPColor", {
        Title = "ทีม ESP Color",
        Default = Color3.fromRGB(0, 255, 0)
    })
    Options.TeamESPColor = TeamESPColor

    -- ESP Objects Storage
    local ESPObjects = {
        Highlights = {},
        Boxes = {},
        Names = {},
        HealthBars = {},
        Distances = {}
    }

    -- Function to clean up ESP objects
    local function CleanupESPObjects()
        for player, highlight in pairs(ESPObjects.Highlights) do
            if highlight and highlight.Parent then
                pcall(function() highlight:Destroy() end)
            end
        end
        ESPObjects.Highlights = {}
        
        for player, box in pairs(ESPObjects.Boxes) do
            if box then
                for _, part in pairs(box) do
                    if part and part.Remove then
                        pcall(function() part:Remove() end)
                    end
                end
            end
        end
        ESPObjects.Boxes = {}
        
        for player, text in pairs(ESPObjects.Names) do
            if text and text.Remove then
                pcall(function() text:Remove() end)
            end
        end
        ESPObjects.Names = {}
        
        for player, healthBar in pairs(ESPObjects.HealthBars) do
            if healthBar then
                for _, part in pairs(healthBar) do
                    if part and part.Remove then
                        pcall(function() part:Remove() end)
                    end
                end
            end
        end
        ESPObjects.HealthBars = {}
        
        for player, text in pairs(ESPObjects.Distances) do
            if text and text.Remove then
                pcall(function() text:Remove() end)
            end
        end
        ESPObjects.Distances = {}
    end

    -- ฟังก์ชันตรวจสอบทีม
    local function IsSameTeam(player)
        if not LocalPlayer.Team or not player.Team then return false end
        return player.Team == LocalPlayer.Team
    end

    -- ฟังก์ชันเลือกสีตามทีม
    local function GetPlayerESPColor(player)
        if IsSameTeam(player) then
            return Options.TeamESPColor.Value
        else
            return Options.HeadESPColor.Value
        end
    end

    -- Enhanced ESP System
    local function UpdateHeadESP()
        if not Options.HeadESP or not Options.HeadESP.Value then
            CleanupESPObjects()
            return
        end

        local existingPlayers = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                local isAlive = character and character:FindFirstChildOfClass("Humanoid") and character:FindFirstChildOfClass("Humanoid").Health > 0
                
                if character then
                    existingPlayers[player] = true
                    
                    local espColor = GetPlayerESPColor(player)
                    local transparency = isAlive and 0.5 or 0.8
                    local outlineTransparency = isAlive and 0.7 or 0.9
                    
                    -- Head Highlight ESP
                    if not ESPObjects.Highlights[player] or not ESPObjects.Highlights[player].Parent then
                        if ESPObjects.Highlights[player] then
                            pcall(function() ESPObjects.Highlights[player]:Destroy() end)
                        end
                        
                        pcall(function()
                            local highlight = Instance.new("Highlight")
                            highlight.Adornee = character
                            highlight.FillColor = espColor
                            highlight.FillTransparency = transparency
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.OutlineTransparency = outlineTransparency
                            
                            local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                            if playerGui then
                                highlight.Parent = playerGui
                            else
                                highlight.Parent = game:GetService("CoreGui")
                            end
                            
                            ESPObjects.Highlights[player] = highlight
                        end)
                    else
                        pcall(function()
                            ESPObjects.Highlights[player].Adornee = character
                            ESPObjects.Highlights[player].FillColor = espColor
                            ESPObjects.Highlights[player].FillTransparency = transparency
                            ESPObjects.Highlights[player].OutlineTransparency = outlineTransparency
                        end)
                    end
                    
                    -- Box ESP
                    if not ESPObjects.Boxes[player] then
                        local boxParts = {}
                        
                        for i = 1, 4 do
                            local line = Drawing.new("Line")
                            line.Visible = isAlive
                            line.Color = espColor
                            line.Thickness = 1.5
                            line.Transparency = isAlive and 1 or 0.5
                            table.insert(boxParts, line)
                        end
                        
                        ESPObjects.Boxes[player] = boxParts
                    end
                    
                    -- Update box positions
                    if ESPObjects.Boxes[player] then
                        local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
                        if rootPart then
                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            local size = Vector3.new(4, humanoid and humanoid.HipHeight * 2 or 5, 2)
                            local cf = rootPart.CFrame
                            
                            local corners = {
                                cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
                                cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
                                cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
                                cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2)
                            }
                            
                            local screenCorners = {}
                            local onScreen = true
                            
                            for _, corner in ipairs(corners) do
                                local screenPos, visible = Camera:WorldToViewportPoint(corner.Position)
                                if not visible then onScreen = false break end
                                table.insert(screenCorners, Vector2.new(screenPos.X, screenPos.Y))
                            end
                            
                            if onScreen then
                                for i = 1, 4 do
                                    local line = ESPObjects.Boxes[player][i]
                                    line.From = screenCorners[i]
                                    line.To = screenCorners[i < 4 and i + 1 or 1]
                                    line.Color = espColor
                                    line.Visible = isAlive
                                    line.Transparency = isAlive and 1 or 0.5
                                end
                            else
                                for _, line in ipairs(ESPObjects.Boxes[player]) do
                                    line.Visible = false
                                end
                            end
                        end
                    end
                    
                    -- แสดงชื่อผู้เล่น
                    if not ESPObjects.Names[player] then
                        local nameText = Drawing.new("Text")
                        nameText.Visible = true
                        nameText.Color = espColor
                        nameText.Size = 18
                        nameText.Center = true
                        nameText.Outline = true
                        nameText.OutlineColor = Color3.new(0, 0, 0)
                        nameText.Font = 2
                        ESPObjects.Names[player] = nameText
                    end
                    
                    -- อัปเดตชื่อ
                    if ESPObjects.Names[player] then
                        local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
                        if rootPart then
                            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
                            if onScreen then
                                ESPObjects.Names[player].Position = Vector2.new(pos.X, pos.Y)
                                local statusText = isAlive and "" or " [ตาย]"
                                ESPObjects.Names[player].Text = player.Name .. statusText
                                ESPObjects.Names[player].Color = espColor
                                ESPObjects.Names[player].Transparency = isAlive and 1 or 0.7
                                ESPObjects.Names[player].Visible = true
                            else
                                ESPObjects.Names[player].Visible = false
                            end
                        end
                    end
                    
                    -- แสดงระยะห่าง
                    if not ESPObjects.Distances[player] then
                        local distText = Drawing.new("Text")
                        distText.Visible = true
                        distText.Color = espColor
                        distText.Size = 16
                        distText.Center = true
                        distText.Outline = true
                        distText.OutlineColor = Color3.new(0, 0, 0)
                        distText.Font = 2
                        ESPObjects.Distances[player] = distText
                    end
                    
                    -- อัปเดตระยะห่าง
                    if ESPObjects.Distances[player] then
                        local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
                        if rootPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, -2, 0))
                            if onScreen then
                                local distance = math.floor((rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                                ESPObjects.Distances[player].Position = Vector2.new(pos.X, pos.Y)
                                ESPObjects.Distances[player].Text = distance .. "m"
                                ESPObjects.Distances[player].Color = espColor
                                ESPObjects.Distances[player].Transparency = isAlive and 1 or 0.7
                                ESPObjects.Distances[player].Visible = true
                            else
                                ESPObjects.Distances[player].Visible = false
                            end
                        end
                    end
                end
            end
        end
        
        -- Clean up ESP objects for players that no longer exist
        for player in pairs(ESPObjects.Highlights) do
            if not existingPlayers[player] then
                if ESPObjects.Highlights[player] and ESPObjects.Highlights[player].Parent then
                    pcall(function() ESPObjects.Highlights[player]:Destroy() end)
                end
                ESPObjects.Highlights[player] = nil
                
                if ESPObjects.Boxes[player] then
                    for _, line in ipairs(ESPObjects.Boxes[player]) do
                        if line and line.Remove then
                            pcall(function() line:Remove() end)
                        end
                    end
                    ESPObjects.Boxes[player] = nil
                end
                
                if ESPObjects.Names[player] and ESPObjects.Names[player].Remove then
                    pcall(function() ESPObjects.Names[player]:Remove() end)
                    ESPObjects.Names[player] = nil
                end
                
                if ESPObjects.Distances[player] and ESPObjects.Distances[player].Remove then
                    pcall(function() ESPObjects.Distances[player]:Remove() end)
                    ESPObjects.Distances[player] = nil
                end
            end
        end
    end

    -- FOV Circle Drawing
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(0, 170, 255)
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.7
    FOVCircle.Visible = false

    local function UpdateFOVCircle()
        if not Options.ShowFOV.Value then
            FOVCircle.Visible = false
            return
        end
        local fov = Options.AimbotFOV and Options.AimbotFOV.Value or 120
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        local radius = (fov / 90) * 150
        FOVCircle.Radius = radius
        FOVCircle.Visible = true
    end

    -- ระบบ Aimbot หลัก
    local aiming = false
    local aimConnection

    local function StartAimbot()
        if aimConnection then aimConnection:Disconnect() end
        aimConnection = RunService.RenderStepped:Connect(function()
            -- LEGIT: ปรับขนาด hitbox หัวทุกเฟรม
            SetLegitHeadSize()
            UpdateHeadESP()
            UpdateFOVCircle()
            if not Options.AimbotEnabled.Value then return end
            if not Keybind:GetState() then return end
            local targetData = GetClosestTarget()
            if targetData and targetData.Character then
                local aimPos = GetAimbotTargetPosition(targetData.Character, targetData.Part)
                if aimPos then
                    local camCF = Camera.CFrame
                    local direction = (aimPos - Camera.CFrame.Position).Unit
                    local smooth = Options.AimbotSmooth and Options.AimbotSmooth.Value or 2
                    -- เพิ่มความละเอียด: ใช้การคำนวณมุมกล้องแบบละเอียด
                    if smooth > 0 then
                        -- คำนวณมุม pitch/yaw ปัจจุบันและเป้าหมาย
                        local function getAngles(vec)
                            local dx, dy, dz = vec.X, vec.Y, vec.Z
                            local yaw = math.atan2(dx, dz)
                            local hyp = math.sqrt(dx*dx + dz*dz)
                            local pitch = math.atan2(dy, hyp)
                            return pitch, yaw
                        end
                        local camDir = camCF.LookVector
                        local targetDir = direction
                        local camPitch, camYaw = getAngles(camDir)
                        local targetPitch, targetYaw = getAngles(targetDir)
                        -- Interpolate
                        local lerp = function(a, b, t)
                            return a + (b - a) * t
                        end
                        local t = 1 / math.max(smooth, 1)
                        local newPitch = lerp(camPitch, targetPitch, t)
                        local newYaw = lerp(camYaw, targetYaw, t)
                        local dist = (aimPos - camCF.Position).Magnitude
                        local newLook = Vector3.new(
                            math.sin(newYaw) * math.cos(newPitch),
                            math.sin(newPitch),
                            math.cos(newYaw) * math.cos(newPitch)
                        )
                        Camera.CFrame = CFrame.new(camCF.Position, camCF.Position + newLook * dist)
                    else
                        Camera.CFrame = CFrame.new(camCF.Position, camCF.Position + direction)
                    end
                end
            end
        end)
    end

    local function StopAimbot()
        if aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end
        CleanupESPObjects()
        FOVCircle.Visible = false
        -- LEGIT: คืนขนาดหัว
        SetLegitHeadSize()
    end

    AimbotToggle:OnChanged(function(enabled)
        if enabled then
            StartAimbot()
        else
            StopAimbot()
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not (aimConnection and Options.AimbotEnabled.Value) then
            -- LEGIT: ปรับขนาด hitbox หัวทุกเฟรม (กรณี legit เปิดแต่ aimbot ปิด)
            SetLegitHeadSize()
            UpdateFOVCircle()
            UpdateHeadESP()
        end
    end)


    -- ESP Dot System (with Toggle & TeamCheck)

    local ESPSettings = {
        Enabled = true,
        DotSize = 10,
        TeamColors = {
            Enemy = Color3.fromRGB(255, 80, 80),
            Friend = Color3.fromRGB(80, 200, 255),
            Neutral = Color3.fromRGB(200, 200, 200)
        }
    }

    -- ESP Dot Toggle
    local ESPDotToggle = Tabs.ESP:AddToggle("ESPDotEnabled", {
        Title = "🔵 Enable ESP Dot",
        Description = "Show colored dot above players' heads",
        Default = true
    })

    -- TeamCheck Toggle
    local ESPDotTeamCheckToggle = Tabs.ESP:AddToggle("ESPDotTeamCheck", {
        Title = "TeamCheck (Show only enemies)",
        Description = "Show ESP dot only for enemy players",
        Default = false
    })

    -- Colorpickers for team colors
    local ESPDotEnemyColor = Tabs.ESP:CreateColorpicker("ESPDotEnemyColor", {
        Title = "Enemy Dot Color",
        Default = ESPSettings.TeamColors.Enemy
    })
    local ESPDotFriendColor = Tabs.ESP:CreateColorpicker("ESPDotFriendColor", {
        Title = "Friend Dot Color",
        Default = ESPSettings.TeamColors.Friend
    })
    local ESPDotNeutralColor = Tabs.ESP:CreateColorpicker("ESPDotNeutralColor", {
        Title = "Neutral Dot Color",
        Default = ESPSettings.TeamColors.Neutral
    })

    -- Update ESPSettings colors on colorpicker change
    ESPDotEnemyColor:OnChanged(function(color)
        ESPSettings.TeamColors.Enemy = color
    end)
    ESPDotFriendColor:OnChanged(function(color)
        ESPSettings.TeamColors.Friend = color
    end)
    ESPDotNeutralColor:OnChanged(function(color)
        ESPSettings.TeamColors.Neutral = color
    end)

    -- Table to keep track of created ESP dots (indexed by player.UserId for reliability)
    local ESPDots = {}

    -- Helper to get team type
    local function GetTeamType(player)
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer.Team or not player.Team then
            return "Neutral"
        end
        if player.Team == localPlayer.Team then
            return "Friend"
        else
            return "Enemy"
        end
    end

    -- Create or update ESP dot for a character
    local function CreateOrUpdateESPDot(player)
        if not player or not player.Character then return end
        local char = player.Character
        local root = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Use player.UserId as key for reliability
        local key = player.UserId

        -- Remove old dot if exists and parent changed
        if ESPDots[key] and ESPDots[key].Parent ~= root then
            ESPDots[key]:Destroy()
            ESPDots[key] = nil
        end

        -- Get team type and color
        local teamType = GetTeamType(player)
        local color = ESPSettings.TeamColors[teamType] or ESPSettings.TeamColors.Neutral

        -- Create new dot if not exists
        if not ESPDots[key] then
            local adorn = Instance.new("BillboardGui")
            adorn.Name = "ESP_Dot"
            adorn.Size = UDim2.new(0, ESPSettings.DotSize, 0, ESPSettings.DotSize)
            adorn.AlwaysOnTop = true
            adorn.Adornee = root
            adorn.Parent = root

            -- Center the dot above the head
            adorn.StudsOffset = Vector3.new(0, 1.5, 0)

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 0
            frame.BorderSizePixel = 0
            frame.BackgroundColor3 = color
            frame.Parent = adorn

            ESPDots[key] = adorn
        else
            -- Update color if needed
            local frame = ESPDots[key]:FindFirstChildOfClass("Frame")
            if frame then
                frame.BackgroundColor3 = color
            end
        end
    end

    -- Cleanup ESP dots for players that are no longer valid
    local function CleanupESPDots(validUserIds)
        for userId, dot in pairs(ESPDots) do
            if not validUserIds[userId] then
                if dot then
                    dot:Destroy()
                end
                ESPDots[userId] = nil
            end
        end
    end

    -- Update ESP dots for all players, with teamcheck
    local function UpdateESPDots()
        if not ESPDotToggle.Value then
            -- Clean up all dots if ESP is disabled
            for userId, dot in pairs(ESPDots) do
                if dot then
                    dot:Destroy()
                end
                ESPDots[userId] = nil
            end
            return
        end

        local validUserIds = {}
        local localPlayer = game.Players.LocalPlayer

        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character.Parent then
                local teamType = GetTeamType(player)
                -- TeamCheck: show only enemies if enabled
                if not ESPDotTeamCheckToggle.Value or teamType == "Enemy" then
                    CreateOrUpdateESPDot(player)
                    validUserIds[player.UserId] = true
                end
            end
        end

        CleanupESPDots(validUserIds)
    end

    -- Update ESP dots every frame
    game:GetService("RunService").RenderStepped:Connect(function()
        UpdateESPDots()
    end)


    -- Addons:
    SaveManager:SetLibrary(Library)
    InterfaceManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes{}
    InterfaceManager:SetFolder("FluentScriptHub")
    SaveManager:SetFolder("FluentScriptHub/specific-game")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)
    Window:SelectTab(1)
    Library:Notify{
        Title = "Fluent",
        Content = "The script has been loaded.",
        Duration = 8
    }
    SaveManager:LoadAutoloadConfig()
