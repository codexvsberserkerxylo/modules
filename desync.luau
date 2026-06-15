local plrs = game:GetService("Players")
local rs = game:GetService("RunService")
local lp = plrs.LocalPlayer

local desync = {
    on = false,
    off = Vector3.new(0, 0, 0),
    con = nil,
    esp = nil,
    espcon = nil,
    ghostpos = Vector3.new(0, 0, 0)
}

function desync:chr()
    return lp.Character or lp.CharacterAdded:Wait()
end

function desync:mkesp()
    self:killesp()
    
    local c = self:chr()
    if not c then return end
    
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
    
    ghost.Parent = workspace
    self.esp = ghost
    
    self.espcon = rs.RenderStepped:Connect(function()
        if self.esp and self.esp.PrimaryPart then
            self.esp:SetPrimaryPartCFrame(CFrame.new(self.ghostpos))
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
end

function desync:start(offset)
    if self.on then return end
    
    self.off = offset or Vector3.new(0, 0, 15)
    self.on = true
    
    self:mkesp()
    
    self.con = rs.Heartbeat:Connect(function()
        local c = self:chr()
        if not c then return end
        
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        self.ghostpos = hrp.Position
        
        sethiddenproperty(hrp, "NetworkIsSleeping", false)
        hrp.CFrame = hrp.CFrame * CFrame.new(self.off)
        sethiddenproperty(hrp, "NetworkIsSleeping", true)
        
        hrp.CFrame = hrp.CFrame * CFrame.new(-self.off)
    end)
end

function desync:stop()
    if not self.on then return end
    
    if self.con then
        self.con:Disconnect()
        self.con = nil
    end
    
    self:killesp()
    self.on = false
end

function desync:toggle(offset)
    if self.on then
        self:stop()
    else
        self:start(offset)
    end
end

return desync
