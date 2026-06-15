local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = plrs.LocalPlayer

local desync = {
    on = false,
    off = Vector3.new(0, 0, 0),
    real = nil,
    fake = nil,
    hb = nil,
    esp = nil
}

function desync:chr()
    return lp.Character or lp.CharacterAdded:Wait()
end

function desync:mkesp()
    self:killesp()
    if not self.real or not self.real.Parent then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "dsyesp"
    box.Size = Vector3.new(4, 6, 2)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = self.real
    
    pcall(function()
        box.Parent = game:GetService("CoreGui")
    end)
    
    if not box.Parent then
        box.Parent = lp:WaitForChild("PlayerGui")
    end
    
    self.esp = box
end

function desync:killesp()
    if self.esp then
        self.esp:Destroy()
        self.esp = nil
    end
    
    pcall(function()
        for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
            if v.Name == "dsyesp" then v:Destroy() end
        end
    end)
    
    pcall(function()
        for _, v in pairs(lp.PlayerGui:GetChildren()) do
            if v.Name == "dsyesp" then v:Destroy() end
        end
    end)
end

function desync:go(o)
    if self.on then return end
    
    self.off = o or Vector3.new(0, 0, 50)
    self.on = true
    
    local c = self:chr()
    local hrp = c:WaitForChild("HumanoidRootPart")
    
    local startcf = hrp.CFrame
    
    local clone = hrp:Clone()
    clone.Name = "HumanoidRootPart"
    clone.Transparency = 1
    clone.CanCollide = true
    clone.Anchored = false
    
    hrp.Name = "RealRoot"
    hrp.Transparency = 1
    hrp.CanCollide = false
    hrp.Anchored = true
    hrp.CFrame = startcf * CFrame.new(self.off)
    
    self.real = hrp
    self.fake = clone
    
    for _, obj in pairs(c:GetDescendants()) do
        if obj:IsA("Motor6D") or obj:IsA("Weld") or obj:IsA("WeldConstraint") then
            if obj.Part0 == hrp then
                obj.Part0 = clone
            end
            if obj.Part1 == hrp then
                obj.Part1 = clone
            end
        end
        
        if obj:IsA("Attachment") and obj.Parent == hrp then
            obj.Parent = clone
        end
    end
    
    clone.CFrame = startcf
    clone.Parent = c
    
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.RootPart = clone
    end
    
    workspace.CurrentCamera.CameraSubject = hum
    
    self:mkesp()
    
    self.hb = rs.Heartbeat:Connect(function()
        if not self.on then return end
        if not self.fake or not self.fake.Parent then return end
        if not self.real or not self.real.Parent then return end
        
        self.real.CFrame = self.fake.CFrame * CFrame.new(self.off)
    end)
end

function desync:stop()
    if not self.on then return end
    self.on = false
    
    if self.hb then
        self.hb:Disconnect()
        self.hb = nil
    end
    
    self:killesp()
    
    local c = self:chr()
    if self.real and self.real.Parent then
        local restoreCF = self.fake and self.fake.CFrame or self.real.CFrame
        
        self.real.Name = "HumanoidRootPart"
        self.real.Transparency = 0
        self.real.CanCollide = true
        self.real.Anchored = false
        self.real.CFrame = restoreCF
        
        for _, obj in pairs(c:GetDescendants()) do
            if obj:IsA("Motor6D") or obj:IsA("Weld") or obj:IsA("WeldConstraint") then
                if obj.Part0 == self.fake then
                    obj.Part0 = self.real
                end
                if obj.Part1 == self.fake then
                    obj.Part1 = self.real
                end
            end
            
            if obj:IsA("Attachment") and self.fake and obj.Parent == self.fake then
                obj.Parent = self.real
            end
        end
        
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.RootPart = self.real
        end
        
        workspace.CurrentCamera.CameraSubject = hum
    end
    
    if self.fake then
        self.fake:Destroy()
        self.fake = nil
    end
    
    self.real = nil
end

function desync:tp(cf)
    if not self.on then return end
    if not self.fake or not self.fake.Parent then return end
    
    self.fake.CFrame = cf
end

function desync:setoff(o)
    self.off = o or Vector3.new(0, 0, 50)
end

return desync
