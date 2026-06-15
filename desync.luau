local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = plrs.LocalPlayer

local desync = {
    on = false,
    off = Vector3.new(0, 0, 0),
    fk = nil,
    rl = nil,
    hb = nil
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
        
        local mv = hum.MoveDirection
        if mv.Magnitude > 0 then
            local spd = hum.WalkSpeed
            local dt = mv * spd * 0.016
            self.fk.CFrame = self.fk.CFrame + dt
        end
        
        for _, d in pairs(wp) do
            if d.p and d.p.Parent then
                local rel = self.fk.CFrame * d.o
                d.p.CFrame = rel
            end
        end
        
        self.rl.CFrame = self.fk.CFrame * CFrame.new(self.off)
    end)
end

function desync:stop()
    if not self.on then return end
    
    self.on = false
    
    if self.hb then
        self.hb:Disconnect()
        self.hb = nil
    end
    
    if self.rl and self.rl.Parent then
        self.rl.Anchored = false
        self.rl.Transparency = 0
        if self.fk then
            self.rl.CFrame = self.fk.CFrame
        end
    end
    
    if self.fk and self.fk.Parent then
        self.fk:Destroy()
        self.fk = nil
    end
end

function desync:setoff(o)
    self.off = o
end

return desync
