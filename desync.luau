local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = plrs.LocalPlayer

local desync = {
    on = false,
    off = Vector3.new(0, 0, 0),
    fk = nil,
    rl = nil,
    hb = nil,
    camcon = nil,
    esp = nil,
    espcon = nil,
    wp = {},
    oldsubject = nil
}

function desync:chr()
    return lp.Character or lp.CharacterAdded:Wait()
end

function desync:mkfake()
    local c = self:chr()
    local h = c:WaitForChild("HumanoidRootPart")
    
    local f = Instance.new("Part")
    f.Name = "fkroot"
    f.Size = h.Size
    f.Transparency = 1
    f.CanCollide = false
    f.Anchored = false
    f.Massless = true
    f.CFrame = h.CFrame
    f.Parent = c
    
    self.rl = h
    self.fk = f
    
    return f
end

function desync:mkesp()
    self:killesp()
    
    if not self.rl or not self.rl.Parent then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "dsyesp"
    box.Size = Vector3.new(4, 6, 2)
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = self.rl
    
    local ok, gui = pcall(function()
        return game:GetService("CoreGui")
    end)
    
    if ok and gui then
        box.Parent = gui
    else
        box.Parent = lp:WaitForChild("PlayerGui")
    end
    
    self.esp = box
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
    
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "dsyesp" then
            v:Destroy()
        end
    end
    
    pcall(function()
        for _, v in pairs(lp.PlayerGui:GetChildren()) do
            if v.Name == "dsyesp" then
                v:Destroy()
            end
        end
    end)
end

function desync:go(o)
    if self.on then return end
    
    self.off = o or Vector3.new(0, 0, 50)
    self.on = true
    
    local c = self:chr()
    local hum = c:WaitForChild("Humanoid")
    local cam = workspace.CurrentCamera
    
    self:mkfake()
    
    local startcf = self.rl.CFrame
    
    self.oldsubject = cam.CameraSubject
    
    self.rl.Anchored = true
    self.rl.CFrame = startcf * CFrame.new(self.off)
    self.rl.Transparency = 1
    
    self.wp = {}
    for _, p in pairs(c:GetDescendants()) do
        if p:IsA("BasePart") and p ~= self.rl and p ~= self.fk then
            local ofs = startcf:ToObjectSpace(p.CFrame)
            table.insert(self.wp, {p = p, o = ofs})
        end
    end
    
    self.fk.CFrame = startcf
    
    self:mkesp()
    
    self.camcon = rs.RenderStepped:Connect(function()
        if not self.on then return end
        if not self.fk or not self.fk.Parent then return end
        
        local cf = self.fk.CFrame
        local offset = cam.CFrame.Position - (self.oldsubject and self.oldsubject:IsA("BasePart") and self.oldsubject.Position or cf.Position)
        
        cam.CameraSubject = nil
        cam.CFrame = CFrame.new(cf.Position) * CFrame.new(0, 2, 10) * CFrame.Angles(0, 0, 0)
    end)
    
    self.hb = rs.Heartbeat:Connect(function(dt)
        if not self.on then return end
        if not self.fk or not self.fk.Parent then return end
        if not hum or not hum.Parent then return end
        
        local mv = hum.MoveDirection
        if mv.Magnitude > 0 then
            local spd = hum.WalkSpeed
            local delta = mv * spd * dt
            self.fk.CFrame = self.fk.CFrame + delta
        end
        
        local fc = self.fk.CFrame
        
        for _, w in pairs(self.wp) do
            if w.p and w.p.Parent then
                w.p.CFrame = fc * w.o
            end
        end
        
        self.rl.CFrame = fc * CFrame.new(self.off)
    end)
end

function desync:stop()
    if not self.on then return end
    
    self.on = false
    
    if self.hb then
        self.hb:Disconnect()
        self.hb = nil
    end
    
    if self.camcon then
        self.camcon:Disconnect()
        self.camcon = nil
    end
    
    self:killesp()
    
    local cam = workspace.CurrentCamera
    local c = self:chr()
    local hum = c:FindFirstChildOfClass("Humanoid")
    
    if hum then
        cam.CameraSubject = hum
    end
    
    if self.rl and self.rl.Parent and self.fk and self.fk.Parent then
        local targetcf = self.fk.CFrame
        
        self.rl.CFrame = targetcf
        self.rl.Velocity = Vector3.new(0, 0, 0)
        self.rl.Anchored = false
        self.rl.Transparency = 0
        
        for _, w in pairs(self.wp) do
            if w.p and w.p.Parent then
                w.p.CFrame = targetcf * w.o
            end
        end
        
        self.fk:Destroy()
        self.fk = nil
    end
    
    self.rl = nil
    self.wp = {}
end

function desync:tp(cf)
    if not self.on then return end
    if not self.rl or not self.rl.Parent then return end
    if not self.fk or not self.fk.Parent then return end
    
    self.rl.Anchored = false
    self.rl.CFrame = cf * CFrame.new(self.off)
    task.wait(0.1)
    self.rl.Anchored = true
    
    self.fk.CFrame = cf
    
    for _, w in pairs(self.wp) do
        if w.p and w.p.Parent then
            w.p.CFrame = cf * w.o
        end
    end
end

function desync:setoff(o)
    self.off = o
    if self.on and self.rl and self.rl.Parent and self.fk and self.fk.Parent then
        self.rl.CFrame = self.fk.CFrame * CFrame.new(self.off)
    end
end

return desync
