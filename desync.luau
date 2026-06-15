local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = plrs.LocalPlayer
local cam = workspace.CurrentCamera

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
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    
    self.esp = box
    
    self.espcon = rs.RenderStepped:Connect(function()
        if not self.on then 
            box.Visible = false
            return 
        end
        if not self.real or not self.real.Parent then 
            box.Visible = false
            return 
        end
        
        local pos = self.real.Position
        local screenpos, onscreen = cam:WorldToViewportPoint(pos)
        
        if onscreen then
            local sz = 50
            box.Size = Vector2.new(sz, sz * 1.5)
            box.Position = Vector2.new(screenpos.X - sz/2, screenpos.Y - sz * 0.75)
            box.Visible = true
        else
            box.Visible = false
        end
    end)
end

function desync:killesp()
    if self.espcon then
        self.espcon:Disconnect()
        self.espcon = nil
    end
    
    if self.esp then
        self.esp:Remove()
        self.esp = nil
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
    clone.Transparency = 0
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
