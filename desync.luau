local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = plrs.LocalPlayer

local desync = {
    on = false,
    off = Vector3.new(0, 0, 0),
    fk = nil,
    rl = nil,
    hb = nil,
    esp = nil,
    espcon = nil
}

function desync:chr()
    return lp.Character or lp.CharacterAdded:Wait()
end

function desync:mkfake()
    local c = self:chr()
    local h = c:WaitForChild("HumanoidRootPart")
    
    local f = h:Clone()
    f.Name = "fkroot"
    f.Transparency = 1
    f.CanCollide = false
    f.Anchored = true
    f.Parent = c
    
    self.rl = h
    self.fk = f
    
    return f
end

function desync:mkesp()
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "dsyesp"
    box.Size = Vector3.new(4, 6, 2)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.6
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = self.rl
    box.Parent = game:GetService("CoreGui")
    
    self.esp = box
    
    self.espcon = rs.RenderStepped:Connect(function()
        if not self.on then return end
        if not self.rl or not self.rl.Parent then return end
        if not self.esp or not self.esp.Parent then return end
        
        self.esp.CFrame = self.rl.CFrame
    end)
end

function desync:killesp()
    if self.espcon then
        self.espcon:Disconnect()
        self.espcon = nil
    end
    
    if self.esp and self.esp.Parent then
        self.esp:Destroy()
        self.esp = nil
    end
end

function desync:go(o)
    if self.on then return end
    
    self.off = o or Vector3.new(0, 0, 50)
    self.on = true
    
    local c = self:chr()
    local hum = c:WaitForChild("Humanoid")
    
    self:mkfake()
    
    local ocf = self.rl.CFrame
    
    self.rl.Anchored = true
    self.rl.CFrame = ocf * CFrame.new(self.off)
    self.rl.Transparency = 1
    
    self:mkesp()
    
    local wp = {}
    for _, p in pairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p ~= self.rl and p ~= self.fk then
            local ofs = self.rl.CFrame:ToObjectSpace(p.CFrame)
            table.insert(wp, {p = p, o = ofs})
        end
    end
    
    self.fk.CFrame = ocf
    
    self.hb = rs.Heartbeat:Connect(function()
        if not self.on then return end
        if not self.fk or not self.fk.Parent then return end
        
        local fc = self.fk.CFrame
        
        for _, w in pairs(wp) do
            if w.p and w.p.Parent then
                w.p.CFrame = fc * w.o
            end
        end
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
    
    if self.rl and self.rl.Parent then
        local targetcf = self.fk and self.fk.CFrame or self.rl.CFrame
        
        self.rl.Velocity = Vector3.new(0, 0, 0)
        self.rl.RotVelocity = Vector3.new(0, 0, 0)
        self.rl.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        self.rl.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        self.rl.CFrame = targetcf
        self.rl.Transparency = 0
        self.rl.Anchored = false
        
        task.defer(function()
            if self.rl and self.rl.Parent then
                self.rl.Velocity = Vector3.new(0, 0, 0)
                self.rl.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end
    
    if self.fk and self.fk.Parent then
        self.fk:Destroy()
        self.fk = nil
    end
    
    self.rl = nil
end

function desync:toggle(o)
    if self.on then
        self:stop()
    else
        self:go(o)
    end
end

return desync
