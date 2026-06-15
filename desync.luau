local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = plrs.LocalPlayer

local desync = {
    on = false,
    off = Vector3.new(0, 0, 0),
    con = nil,
    esp = nil,
    espcon = nil,
    ghostpos = CFrame.new()
}

function desync:chr()
    return lp.Character or lp.CharacterAdded:Wait()
end

function desync:mkesp()
    self:killesp()
    
    local c = self:chr()
    if not c then return end
    
    local hrp = c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local ok, ghost = pcall(function()
        return c:Clone()
    end)
    
    if not ok or not ghost then return end
    
    ghost.Name = "dsyghost"
    
    for _, obj in pairs(ghost:GetDescendants()) do
        pcall(function()
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
        end)
    end
    
    local ghosthum = ghost:FindFirstChildOfClass("Humanoid")
    if ghosthum then
        ghosthum:Destroy()
    end
    
    ghost.Parent = workspace
    self.esp = ghost
    self.ghostpos = hrp.CFrame
    
    self.espcon = rs.RenderStepped:Connect(function()
        if not self.esp or not self.esp.Parent then return end
        
        for _, part in pairs(self.esp:GetDescendants()) do
            if part:IsA("BasePart") then
                local orig = self:chr() and self:chr():FindFirstChild(part.Name, true)
                if orig and orig:IsA("BasePart") then
                    local relcf = self.ghostpos:ToObjectSpace(orig.CFrame)
                    part.CFrame = self.ghostpos * relcf
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

function desync:start(offset)
    if self.on then return end
    
    self.off = offset or Vector3.new(0, 0, 15)
    self.on = true
    
    local c = self:chr()
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if hrp then
        self.ghostpos = hrp.CFrame * CFrame.new(self.off)
    end
    
    self:mkesp()
    
    self.con = rs.Heartbeat:Connect(function()
        local chr = self:chr()
        if not chr then return end
        
        local hrp = chr:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        self.ghostpos = hrp.CFrame * CFrame.new(self.off)
        
        sethiddenproperty(hrp, "NetworkIsSleeping", false)
        local realcf = hrp.CFrame
        hrp.CFrame = realcf * CFrame.new(self.off)
        rs.RenderStepped:Wait()
        hrp.CFrame = realcf
    end)
end

function desync:stop()
    if not self.on then return end
    
    self.on = false
    
    if self.con then
        self.con:Disconnect()
        self.con = nil
    end
    
    self:killesp()
end

function desync:updateoffset(newoff)
    self.off = newoff
end

function desync:teleportghost(cf)
    self.ghostpos = cf
end

return desync
