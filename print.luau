-- base is from rscripts i forgot by who tho
local gui = game:GetService("CoreGui")
local rs = game:GetService("RunService")

getgenv().printModule = getgenv().printModule or {
    statuses = {},
    nid = 1
}

local printModule = getgenv().printModule

function printModule:CreateStatus(text, color)
    local id = self.nid
    self.nid = self.nid + 1

    local numstring = tostring(math.random(10000, 99999)) .. "_" .. tostring(id)

    local ctime = os.date("*t")
    local time = string.format("%02d:%02d:%02d", ctime.hour, ctime.min, ctime.sec)

    self.statuses[id] = {
        id = id,
        identifier = numstring,
        timeString = time, 
        text = text or "Status",
        color = color or Color3.fromRGB(255, 255, 255),
        enabled = true
    }

    print(numstring)

    return id
end

function printModule:SetText(id, text)
    if self.statuses[id] then
        self.statuses[id].text = text
    end
end

function printModule:SetColor(id, color)
    if self.statuses[id] then
        self.statuses[id].color = color
    end
end

function printModule:SetEnabled(id, enabled)
    if self.statuses[id] then
        self.statuses[id].enabled = enabled
    end
end

function printModule:RemoveStatus(id)
    self.statuses[id] = nil
end

task.wait(0.1)

rs.Heartbeat:Connect(function()
    local dev = gui:FindFirstChild("DevConsoleMaster")
    if not dev then return end

    local window = dev:FindFirstChild("DevConsoleWindow")
    if not window or not window.Visible then return end

    local log = window:FindFirstChild("DevConsoleUI")
    if log then
        log = log:FindFirstChild("MainView")
        if log then
            log = log:FindFirstChild("ClientLog")
        end
    end

    if not log then print("critical error: log not found")return end

    for _, child in pairs(log:GetChildren()) do
        if child.ClassName == "Frame" and child.Name ~= "WindowingPadding" then
            local msg = child:FindFirstChild("msg")
            if msg then
                for id, status in pairs(printModule.statuses) do
                    if status.enabled then
                        local found = false
                        if string.find(msg.Text, status.identifier) then
                            child.Name = "Status_" .. status.identifier
                            found = true
                        elseif child.Name == "Status_" .. status.identifier then
                            found = true
                        end
                        if found then
                            msg.Text = status.timeString .. " -- " .. status.text
                            msg.TextColor3 = status.color
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- example: 
--[[
local status = printModule:CreateStatus("im gonna say hi in 10 seconds ", Color3.fromRGB(255, 255, 0))
task.wait(0.9)
for i = 1, 10 do
    task.wait(0.3)
    printModule:SetText(status, tostring(i))
end
printModule:SetText(status, "hi")
printModule:SetEnabled(status, true)
printModule:SetColor(status, Color3.fromRGB(0, 255, 0))
]]
