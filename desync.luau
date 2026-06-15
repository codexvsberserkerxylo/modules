local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = plrs.LocalPlayer

local desync = {
    on = false,
    off = Vector3.new(0, 0, 0),
    real = nil,
    fake = nil,
    hb = nil,
    esp = nil,
    espcon = nil
}

function desync:chr()
    return lp.Character or lp.CharacterAdded:Wait()
end

function desync:mkesp()
    self:killesp()
    if not self.real or not self.real.Parent then return end
    
    local c = self:chr()
    local ghost = c:Clone()
    ghost.Name = "dsyghost"
    
    for _, obj in pairs(ghost:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            obj:Destroy()
        end
        if obj:IsA("BasePart") then
            obj.CanCollide = false
            obj.Anchored = true
            obj.Transparency = 0.6
        end
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 0.6
        end
    end
    
    local ghosthrp = ghost:FindFirstChild("HumanoidRootPart") or ghost:FindFirstChild("RealRoot")
    if ghosthrp then
        ghosthrp.Transparency = 1
    end
    
    local ghosthum = ghost:FindFirstChildOfClass("Humanoid")
    if ghosthum then
        ghosthum:Destroy()
    end
    
    ghost.Parent = workspace
    
    self.esp = ghost
    
    self.espcon = rs.RenderStepped:Connect(function()
        if not self.on then return end
        if not self.real or not self.real.Parent then return end
        if not self.esp or not self.esp.Parent then return end
        
        local ghostroot = self.esp:FindFirstChild("HumanoidRootPart") or self.esp:FindFirstChild("RealRoot")
        if ghostroot then
            local offset = self.real.CFrame:ToObjectSpace(self.fake.CFrame)
            for _, part in pairs(self.esp:GetDescendants()) do
                if part:IsA("BasePart") then
                    local originalpart = self:chr():FindFirstChild(part.Name, true)
                    if originalpart and originalpart:IsA("BasePart") then
                        local relcf = self.fake.CFrame:ToObjectSpace(originalpart.CFrame)
                        part.CFrame = self.real.CFrame * relcf
                    end
                end
            end
        end
    end)
end

function desync:killesp()
    if self.espcon then
        self.espcon:Disconnect()
        self.espcon = nil
    end
    
    if self.esp then
        self.esp:Destroy()
        self.esp = nil
    end
    
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name == "dsyghost" then
            v:Destroy()
        end
    end
end

function desync:go(o)
    if self.on then return end
    
    if typeof(o) == "CFrame" then
        self.off = o.Position
    elseif typeof(o) == "Vector3" then
        self.off = o
    else
        self.off = Vector3.new(0, 0, 50)
    end
    
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
    
    workspace.CurrentCamera.CameraSubject = c:FindFirstChildOfClass("Humanoid")
    
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
        
        workspace.CurrentCamera.CameraSubject = c:FindFirstChildOfClass("Humanoid")
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
    
    if typeof(cf) == "Vector3" then
        cf = CFrame.new(cf)
    end
    
    self.fake.CFrame = cf
end

function desync:setoff(o)
    if typeof(o) == "CFrame" then
        self.off = o.Position
    elseif typeof(o) == "Vector3" then
        self.off = o
    end
end

function desync:toggle(o)
    if self.on then
        self:stop()
    else
        self:go(o)
    end
end

lp.CharacterAdded:Connect(function()
    if desync.on then
        desync:stop()
    end
end)

return desync
