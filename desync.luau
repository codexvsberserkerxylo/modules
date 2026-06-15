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
    
    local hl = Instance.new("Highlight")
    hl.Name = "dsyesp"
    hl.Adornee = self.real
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.FillTransparency = 0.7
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    pcall(function()
        hl.Parent = game:GetService("CoreGui")
    end)
    
    if not hl.Parent then
        hl.Parent = lp:WaitForChild("PlayerGui")
    end
    
    self.esp = hl
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
    
    local ghost = Instance.new("Part")
    ghost.Name = "dsyghost"
    ghost.Size = hrp.Size
    ghost.Transparency = 1
    ghost.CanCollide = false
    ghost.Anchored = true
    ghost.CFrame = hrp.CFrame * CFrame.new(self.off)
    ghost.Parent = workspace
    
    self.real = ghost
    self.fake = hrp
    
    self:mkesp()
    
    self.hb = rs.Heartbeat:Connect(function()
        if not self.on then return end
        if not self.fake or not self.fake.Parent then 
            self:stop()
            return 
        end
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
    
    if self.real then
        self.real:Destroy()
        self.real = nil
    end
    
    self.fake = nil
end

function desync:tp(cf)
    if not self.on then return end
    if not self.fake or not self.fake.Parent then return end
    
    self.fake.CFrame = cf
end

function desync:setoff(o)
    self.off = o or Vector3.new(0, 0, 50)
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
