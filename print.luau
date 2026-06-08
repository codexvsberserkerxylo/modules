-- not mine
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

getgenv().StatusManager = getgenv().StatusManager or {
    statuses = {},
    nextId = 1
}
local StatusManager = getgenv().StatusManager

function StatusManager:CreateStatus(text, color)
    local id = self.nextId
    self.nextId = self.nextId + 1

    local statusNumString = tostring(math.random(10000, 99999)) .. "_" .. tostring(id)

    local currentTime = os.date("*t")
    local timeString = string.format("%02d:%02d:%02d", currentTime.hour, currentTime.min, currentTime.sec)

    self.statuses[id] = {
        id = id,
        identifier = statusNumString,
        timeString = timeString, 
        text = text or "Status",
        color = color or Color3.fromRGB(255, 255, 255),
        enabled = true
    }

    print(statusNumString)

    return id
end

function StatusManager:SetText(id, text)
    if self.statuses[id] then
        self.statuses[id].text = text
    end
end

function StatusManager:SetColor(id, color)
    if self.statuses[id] then
        self.statuses[id].color = color
    end
end

function StatusManager:SetEnabled(id, enabled)
    if self.statuses[id] then
        self.statuses[id].enabled = enabled
    end
end

function StatusManager:RemoveStatus(id)
    self.statuses[id] = nil
end

task.wait(0.1)

RunService.Heartbeat:Connect(function()
    local devConsole = CoreGui:FindFirstChild("DevConsoleMaster")
    if not devConsole then return end

    local window = devConsole:FindFirstChild("DevConsoleWindow")
    if not window or not window.Visible then return end

    local clientLog = window:FindFirstChild("DevConsoleUI")
    if clientLog then
        clientLog = clientLog:FindFirstChild("MainView")
        if clientLog then
            clientLog = clientLog:FindFirstChild("ClientLog")
        end
    end

    if not clientLog then return end

    for _, child in pairs(clientLog:GetChildren()) do
        if child.ClassName == "Frame" and child.Name ~= "WindowingPadding" then
            local msgLabel = child:FindFirstChild("msg")
            if msgLabel then
                for id, status in pairs(StatusManager.statuses) do
                    if status.enabled then
                        local found = false
                        if string.find(msgLabel.Text, status.identifier) then
                            child.Name = "Status_" .. status.identifier
                            found = true
                        elseif child.Name == "Status_" .. status.identifier then
                            found = true
                        end
                        if found then
                            msgLabel.Text = status.timeString .. " -- " .. status.text
                            msgLabel.TextColor3 = status.color
                            break
                        end
                    end
                end
            end
        end
    end
end)

local myStatus = StatusManager:CreateStatus("Im gonna scare you ", Color3.fromRGB(255, 255, 0))
task.wait(0.9)
for i = 1, 10 do
    task.wait(0.3)
    StatusManager:SetText(myStatus, tostring(i))
end
StatusManager:SetText(myStatus, "Boo! You been spooked!")
StatusManager:SetEnabled(myStatus, true)
StatusManager:SetColor(myStatus, Color3.fromRGB(0, 255, 0))
