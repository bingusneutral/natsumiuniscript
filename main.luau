local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RemoteEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CharacterSoundEvent")

local GUI_URL = "https://files.catbox.moe/1a59i7.rbxm"
local GUI_FILE = "UniformGui.rbxm"

local Defaults = {
    LeftSleeve = false,
    RightSleeve = false,
    LeftSleeveColor = Color3.fromRGB(255, 255, 255),
    RightSleeveColor = Color3.fromRGB(255, 255, 255),
    Towel = false,
    TowelColor = Color3.fromRGB(255, 255, 255),
    LeftGlove = true,
    RightGlove = true,
    Number = "1",
    Name = "",
}

local Customization = table.clone(Defaults)

local SavedCustomization = pcall(function()
    return HttpService:JSONDecode(
        readfile("NatsumiUniScriptConfig.txt")
    )
end)

if SavedCustomization then
    local Success, Data = pcall(function()
        return HttpService:JSONDecode(
            readfile("NatsumiUniScriptConfig.txt")
        )
    end)

    if Success and type(Data) == "table" then
        for Key, Value in pairs(Data) do
            if Key == "LeftSleeveColor"
                or Key == "RightSleeveColor"
                or Key == "TowelColor" then

                if type(Value) == "table"
                    and Value.R and Value.G and Value.B then

                    Customization[Key] = Color3.new(
                        Value.R,
                        Value.G,
                        Value.B
                    )
                end
            elseif Defaults[Key] ~= nil then
                Customization[Key] = Value
            end
        end
    end
end

local function LoadGui()
    local Success, Result = pcall(function()
        writefile(GUI_FILE, game:HttpGet(GUI_URL))

        local AssetFunction = getcustomasset or getsynasset
        assert(AssetFunction, "Your executor does not support getcustomasset or getsynasset")

        local Asset = AssetFunction(GUI_FILE)
        local Objects = game:GetObjects(Asset)

        assert(Objects and Objects[1], "Could not load the GUI asset")

        return Objects[1]
    end)

    if not Success then
        return nil
    end

    return Result
end

local UniformGui = LoadGui()

if not UniformGui then
    return
end

local ExistingGui = PlayerGui:FindFirstChild(UniformGui.Name)

if ExistingGui then
    ExistingGui:Destroy()
end

UniformGui.ResetOnSpawn = false
UniformGui.Parent = PlayerGui

local CustomizationGui = UniformGui:WaitForChild("Customization")
local Options = CustomizationGui:WaitForChild("Options")
local ColorPicker = CustomizationGui:WaitForChild("ColorPicker")
local Display = ColorPicker:WaitForChild("Display")

local SelectedChanger = nil
local SelectedColorButton = nil
local Visible = true

ColorPicker.Visible = false

local function ApplyCustomization(Name, Number, ChangeLeftGlove, ChangeRightGlove)
    local Character = Player.Character or Player.CharacterAdded:Wait()

    if not Character:WaitForChild("Uniform", 5) then
        return
    end

    if ChangeLeftGlove then
        RemoteEvent:FireServer("Game", "Customization", "Toggle", "LeftGlove")
    end

    if ChangeRightGlove then
        RemoteEvent:FireServer("Game", "Customization", "Toggle", "RightGlove")
    end

    RemoteEvent:FireServer("Game", "Customization", "Number", Number)
    RemoteEvent:FireServer("Game", "Customization", "Name", Name)
    
    task.spawn(function()
        local Config = table.clone(Customization)

        for _, Key in ipairs({
            "LeftSleeveColor",
            "RightSleeveColor",
            "TowelColor"
        }) do
            local Color = Config[Key]

            Config[Key] = {
                R = Color.R,
                G = Color.G,
                B = Color.B
            }
        end

        writefile(
            "NatsumiUniScriptConfig.txt",
            HttpService:JSONEncode(Config)
        )
    end)
end

local function AddTowel(Character)
    local Torso = Character:WaitForChild("Torso")

    local Towel = Instance.new("Part")
    Towel.Name = "Towel"
    Towel.Parent = Character:WaitForChild("Uniform")
    Towel.Size = Vector3.new(0.2, 1, 1)
    Towel.CustomPhysicalProperties = PhysicalProperties.new(1.1, 0.5, 0.05, 5, 2.5)
    Towel.CanCollide = false

    local PositionOffset = Vector3.new(1.062, -1.361, 0.014)
    local RotationOffset = Vector3.new(-1.45, -147.363, -13.925)

    Towel.CFrame = Torso.CFrame
        * CFrame.new(PositionOffset)
        * CFrame.Angles(
            math.rad(RotationOffset.X),
            math.rad(RotationOffset.Y),
            math.rad(RotationOffset.Z)
        )

    local Mesh = Instance.new("SpecialMesh")
    Mesh.MeshId = "rbxassetid://6919149797"
    Mesh.TextureId = "rbxassetid://6923948446"
    Mesh.Offset = Vector3.new(0, 0, 0)
    Mesh.Scale = Vector3.new(0.45, 0.5, 0.55)
    Mesh.Parent = Towel

    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = Torso
    Weld.Part1 = Towel
    Weld.Parent = Towel

    return Towel
end

local function AddLeftSleeve(Character)
    local LeftArm = Character:WaitForChild("Left Arm")

    local LeftSleeve = Instance.new("Part")
    LeftSleeve.Name = "LeftSleeve"
    LeftSleeve.Parent = Character:WaitForChild("Uniform")
    LeftSleeve.Size = Vector3.new(1.02, 1.258, 1.02)
    LeftSleeve.CFrame = LeftArm.CFrame * CFrame.new(0, 0.078, 0)
    LeftSleeve.Material = Enum.Material.Sand
    LeftSleeve.CanCollide = false

    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = LeftArm
    Weld.Part1 = LeftSleeve
    Weld.Parent = LeftSleeve

    return LeftSleeve
end

local function AddRightSleeve(Character)
    local RightArm = Character:WaitForChild("Right Arm")

    local RightSleeve = Instance.new("Part")
    RightSleeve.Name = "RightSleeve"
    RightSleeve.Parent = Character:WaitForChild("Uniform")
    RightSleeve.Size = Vector3.new(1.02, 1.258, 1.02)
    RightSleeve.CFrame = RightArm.CFrame * CFrame.new(0, 0.078, 0)
    RightSleeve.Material = Enum.Material.Sand
    RightSleeve.CanCollide = false

    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = RightArm
    Weld.Part1 = RightSleeve
    Weld.Parent = RightSleeve

    return RightSleeve
end

local function UpdateCharacterColor(Character)
    if not Character then
        return
    end

    local Uniform = Character:FindFirstChild("Uniform")

    if not Uniform then
        return
    end

    local LeftSleeve = Uniform:FindFirstChild("LeftSleeve")
    local RightSleeve = Uniform:FindFirstChild("RightSleeve")
    local Towel = Uniform:FindFirstChild("Towel")

    if LeftSleeve then
        LeftSleeve.Color = Customization.LeftSleeveColor
    end

    if RightSleeve then
        RightSleeve.Color = Customization.RightSleeveColor
    end

    if Towel then
        local Mesh = Towel:FindFirstChildOfClass("SpecialMesh")

        if Mesh then
            local Color = Customization.TowelColor
            Mesh.VertexColor = Vector3.new(Color.R, Color.G, Color.B)
        end
    end
end

local function UpdateCharacter(Character)
    if not Character then
        return
    end

    local Uniform = Character:WaitForChild("Uniform", 15)

    if not Uniform then
        return
    end

    local LeftGlove = Uniform:WaitForChild("LeftGlove", 15)
    local RightGlove = Uniform:WaitForChild("RightGlove", 15)

    local ChangeLeftGlove = false
    local ChangeRightGlove = false

    if LeftGlove then
        local DesiredTransparency = Customization.LeftGlove and 0 or 1
        ChangeLeftGlove = LeftGlove.Transparency ~= DesiredTransparency
    end

    if RightGlove then
        local DesiredTransparency = Customization.RightGlove and 0 or 1
        ChangeRightGlove = RightGlove.Transparency ~= DesiredTransparency
    end

    ApplyCustomization(
        Customization.Name,
        Customization.Number,
        ChangeLeftGlove,
        ChangeRightGlove
    )

    local OldTowel = Uniform:FindFirstChild("Towel")
    local OldLeftSleeve = Uniform:FindFirstChild("LeftSleeve")
    local OldRightSleeve = Uniform:FindFirstChild("RightSleeve")

    if OldTowel then
        OldTowel:Destroy()
    end

    if OldLeftSleeve then
        OldLeftSleeve:Destroy()
    end

    if OldRightSleeve then
        OldRightSleeve:Destroy()
    end

    local NewLeftSleeve = AddLeftSleeve(Character)
    NewLeftSleeve.Transparency = Customization.LeftSleeve and 0 or 1
    NewLeftSleeve.Color = Customization.LeftSleeveColor

    local NewRightSleeve = AddRightSleeve(Character)
    NewRightSleeve.Transparency = Customization.RightSleeve and 0 or 1
    NewRightSleeve.Color = Customization.RightSleeveColor

    local NewTowel = AddTowel(Character)
    NewTowel.Transparency = Customization.Towel and 0 or 1

    local Mesh = NewTowel:FindFirstChildOfClass("SpecialMesh")

    if Mesh then
        local Color = Customization.TowelColor
        Mesh.VertexColor = Vector3.new(Color.R, Color.G, Color.B)
    end
    
    task.spawn(function()
        local Config = table.clone(Customization)

        for _, Key in ipairs({
            "LeftSleeveColor",
            "RightSleeveColor",
            "TowelColor"
        }) do
            local Color = Config[Key]

            Config[Key] = {
                R = Color.R,
                G = Color.G,
                B = Color.B
            }
        end

        writefile(
            "NatsumiUniScriptConfig.txt",
            HttpService:JSONEncode(Config)
        )
    end)
end

local function UpdateCheckButton(Button, Value)
    Button.ImageTransparency = Value and 0 or 1
end

local function UpdateColorButton(Button, Color)
    Button.BackgroundColor3 = Color
end


local function UpdateColorDisplay()
    if not SelectedChanger then return end

    local Color = Customization[SelectedChanger .. "Color"]
    local Hex = "#" .. Color:ToHex()

    Display.BackgroundColor3 = Color
    Display.Text = ""

    local Option = Options:FindFirstChild(SelectedChanger)
    local ColorButton = Option and Option:FindFirstChild("ColorBtn")

    if ColorButton then
        ColorButton.BackgroundColor3 = Color
        ColorButton.ImageColor3 = Color
    end
end



local function SetSliderValue(Channel, Value)
    Value = math.clamp(Value, 0, 1)

    local SliderFrame = ColorPicker:FindFirstChild("slider" .. Channel)
    if not SliderFrame then return end

    local Slider = SliderFrame:FindFirstChild("Slider")
    local Fill = SliderFrame:FindFirstChild("Fill")
    local Percentage = SliderFrame:FindFirstChild("%")

    if Slider then
        Slider.Position = UDim2.new(0, -9, (1 - Value) * 0.9, 0)
    end

    if Fill then
        Fill.Size = UDim2.new(
            Fill.Size.X.Scale,
            Fill.Size.X.Offset,
            Value,
            Fill.Size.Y.Offset
        )
        
        Fill.Position = UDim2.new(
            Fill.Position.X.Scale,
            Fill.Position.X.Offset,
            (1 - Value),
            0
        )
    end

    if Percentage then
        Percentage.Value = Value * 100
    end
end


local function SetSelectedColor(Color)
    if not SelectedChanger then
        return
    end

    Customization[SelectedChanger .. "Color"] = Color

    SetSliderValue("R", Color.R)
    SetSliderValue("G", Color.G)
    SetSliderValue("B", Color.B)

    UpdateColorDisplay()

    if SelectedColorButton then
        UpdateColorButton(SelectedColorButton, Color)
    end

    UpdateCharacterColor(Player.Character)
end

local function OpenColorPicker(ChangerName, ColorButton)
    if SelectedChanger == ChangerName and ColorPicker.Visible then
        ColorPicker.Visible = false
        SelectedChanger = nil
        SelectedColorButton = nil
        return
    end

    SelectedChanger = ChangerName
    SelectedColorButton = ColorButton

    local Color = Customization[ChangerName .. "Color"]

    ColorPicker.Visible = true

    SetSliderValue("R", Color.R)
    SetSliderValue("G", Color.G)
    SetSliderValue("B", Color.B)

    UpdateColorDisplay()
end


local function UpdateSlider(Channel, SliderFrame, InputPosition)
    if not SelectedChanger then return end

    local Height = SliderFrame.AbsoluteSize.Y
    if Height <= 0 then return end

    local Value = math.clamp(
        (InputPosition.Y - SliderFrame.AbsolutePosition.Y) / Height,
        0,
        1
    )

    Value = 1 - Value

    local CurrentColor = Customization[SelectedChanger .. "Color"]

    local R = CurrentColor.R
    local G = CurrentColor.G
    local B = CurrentColor.B

    if Channel == "R" then
        R = Value
    elseif Channel == "G" then
        G = Value
    elseif Channel == "B" then
        B = Value
    end

    SetSelectedColor(Color3.new(R, G, B))
end


local function ConnectSlider(Channel)
    local SliderFrame = ColorPicker:FindFirstChild("slider" .. Channel)

    if not SliderFrame then
        return
    end

    local Slider = SliderFrame:FindFirstChild("Slider")

    if not Slider then
        return
    end

    Slider.Active = true

    local Dragging = false

    Slider.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
            and Input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        if not SelectedChanger then
            return
        end

        Dragging = true
        UpdateSlider(Channel, SliderFrame, Input.Position)
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if not Dragging then
            return
        end

        if Input.UserInputType ~= Enum.UserInputType.MouseMovement
            and Input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        UpdateSlider(Channel, SliderFrame, Input.Position)
    end)

    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
end

local function ValidateNumber(Text)
    if tonumber(Text) == nil then
        return false
    end

    if #Text > 2 then
        return false
    end

    if tonumber(Text) < 0 or tonumber(Text) > 99 then
        return false
    end

    if Text == "00" then
        return false
    end

    if #Text == 2 and Text:sub(1, 1) == "0" then
        return false
    end

    return true
end

local function ConnectOption(Option)
    if not Option:IsA("Frame") then
        return
    end

    local CheckButton = Option:FindFirstChild("CheckBtn")
    local ColorButton = Option:FindFirstChild("ColorBtn")
    local TextBox = Option:FindFirstChild("TextBox")

    if CheckButton then
        local OptionName = Option.Name

        local ValueName = OptionName

        if OptionName == "LeftGlove" then
            ValueName = "LeftGlove"
        end

        UpdateCheckButton(CheckButton, Customization[ValueName])

        CheckButton.Activated:Connect(function()
            if OptionName == "LeftGlove" then
                Customization.LeftGlove = not Customization.LeftGlove
                Customization.RightGlove = Customization.LeftGlove

                UpdateCheckButton(CheckButton, Customization.LeftGlove)
            else
                Customization[OptionName] = not Customization[OptionName]

                UpdateCheckButton(
                    CheckButton,
                    Customization[OptionName]
                )
            end

            if Player.Character then
                UpdateCharacter(Player.Character)
            end
        end)
    end

    if ColorButton then
        local OptionName = Option.Name

        UpdateColorButton(
            ColorButton,
            Customization[OptionName .. "Color"]
        )

        ColorButton.Activated:Connect(function()
            OpenColorPicker(OptionName, ColorButton)
        end)
    end

    if TextBox then
        if Option.Name == "Name" then
            TextBox.Text = Customization.Name
        elseif Option.Name == "Number" then
            TextBox.Text = Customization.Number
        end

        TextBox.FocusLost:Connect(function()
            local Text = TextBox.Text

            if Option.Name == "Number" then
                if not ValidateNumber(Text) then
                    TextBox.Text = Customization.Number
                    return
                end

                Customization.Number = Text
            elseif Option.Name == "Name" then
                Customization.Name = Text
            end

            if Player.Character then
                ApplyCustomization(
                    Customization.Name,
                    Customization.Number,
                    false,
                    false
                )
            end
        end)
    end
end

for _, Option in ipairs(Options:GetChildren()) do
    ConnectOption(Option)
end

ConnectSlider("R")
ConnectSlider("G")
ConnectSlider("B")

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then
        return
    end

    if Input.KeyCode == Enum.KeyCode.LeftControl then
        Visible = not Visible
        Options.Visible = Visible

        if not Visible then
            ColorPicker.Visible = false
        end
    elseif Input.KeyCode == Enum.KeyCode.Escape then
        ColorPicker.Visible = false
        SelectedChanger = nil
        SelectedColorButton = nil
    end
end)

Options.Visible = true

if Player.Character then
    task.spawn(UpdateCharacter, Player.Character)
    
    local Uniform = Player.Character:WaitForChild("Uniform")
    
    for _, Part in Uniform:GetChildren() do
        task.spawn(function()
            Part:GetPropertyChangedSignal("Transparency"):Connect(function()
                UpdateCharacter(Player.Character)
            end)
        end) 
    end
end

Player.CharacterAdded:Connect(function(Character)
    UpdateCharacter(Character)
    
    local Uniform = Player.Character:WaitForChild("Uniform")
    
    for _, Part in Uniform:GetChildren() do
        task.spawn(function()
            Part:GetPropertyChangedSignal("Transparency"):Connect(function()
                UpdateCharacter(Character)
            end)
        end) 
    end
end)
