-- client.lua
local currentTask = nil
local isTaskActive = false

-- Test task data structure
local testTask = {
    id = "test_task_1",
    name = "City Explorer",
    reward = "$5000 + 100 EXP",
    steps = {
        {
            id = "step1",
            description = "Go to Legion Square",
            coords = vector3(197.8297, -934.7239, 30.6873),
            completed = false
        },
        {
            id = "step2",
            description = "Collect 3 packages",
            isCollection = true,
            required = 3,
            progress = 0,
            completed = false
        },
        {
            id = "step3",
            description = "Visit LS Customs",
            coords = vector3(-359.59, -133.44, 38.24),
            completed = false
        },
        {
            id = "step4",
            description = "Find 2 hidden items",
            isCollection = true,
            required = 2,
            progress = 0,
            completed = false
        },
        {
            id = "step5",
            description = "Return to Mission Row PD",
            coords = vector3(432.0460, -981.9876, 30.7107),
            completed = false
        }
    }
}

-- NUI Callbacks
RegisterNUICallback('SQUID:GetPlayerData', function(data, cb)
    -- Simulated player data
    cb({
        level = 5,
        exp = 2500,
        nextLevelExp = 5000
    })
end)

RegisterNUICallback('SQUID:GetDailyTasks', function(data, cb)
    cb({testTask})
end)

RegisterNUICallback('SQUID:AcceptTask', function(data, cb)
    if data.taskId == testTask.id then
        isTaskActive = true
        currentTask = testTask
        cb({success = true})
        
        -- Notify player
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"SYSTEM", "Task accepted! Check your current task tab."}
        })
    end
end)

RegisterNUICallback('SQUID:GetTaskSteps', function(data, cb)
    if currentTask then
        cb(currentTask.steps)
    else
        cb({})
    end
end)

-- Command to simulate collecting items (Step 2)
RegisterCommand('getitem', function()
    if not isTaskActive then return end
    
    local step = currentTask.steps[2]
    if step.isCollection and step.progress < step.required then
        step.progress = step.progress + 1
        if step.progress >= step.required then
            step.completed = true
        end
        
        -- Send update to NUI
        SendNUIMessage({
            type = 'updateTask',
            stepId = 'step2',
            type = 'add',
            value = 1
        })
        
        -- Notify player
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"SYSTEM", string.format("Package collected! (%d/%d)", step.progress, step.required)}
        })
    end
end)

-- Command to simulate finding hidden items (Step 4)
RegisterCommand('finditem', function()
    if not isTaskActive then return end
    
    local step = currentTask.steps[4]
    if step.isCollection and step.progress < step.required then
        step.progress = step.progress + 1
        if step.progress >= step.required then
            step.completed = true
        end
        
        -- Send update to NUI
        SendNUIMessage({
            type = 'updateTask',
            stepId = 'step4',
            type = 'add',
            value = 1
        })
        
        -- Notify player
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"SYSTEM", string.format("Hidden item found! (%d/%d)", step.progress, step.required)}
        })
    end
end)

-- Thread to check location-based steps
Citizen.CreateThread(function()
    local checkSteps = {1, 3, 5} -- Steps that require location checking
    
    while true do
        Citizen.Wait(1000) -- Check every second
        
        if isTaskActive then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for _, stepIndex in ipairs(checkSteps) do
                local step = currentTask.steps[stepIndex]
                if step and not step.completed then
                    local distance = #(playerCoords - step.coords)
                    if distance < 5.0 then -- Within 5 meters
                        step.completed = true
                        
                        -- Send update to NUI
                        SendNUIMessage({
                            type = 'updateTask',
                            stepId = 'step' .. stepIndex,
                            type = 'done'
                        })
                        
                        -- Notify player
                        TriggerEvent('chat:addMessage', {
                            color = {255, 255, 0},
                            multiline = true,
                            args = {"SYSTEM", "Location reached! Step completed."}
                        })
                        
                        -- Check if all steps are completed
                        local allCompleted = true
                        for _, s in ipairs(currentTask.steps) do
                            if not s.completed then
                                allCompleted = false
                                break
                            end
                        end
                        
                        if allCompleted then
                            isTaskActive = false
                            TriggerEvent('chat:addMessage', {
                                color = {0, 255, 0},
                                multiline = true,
                                args = {"SYSTEM", "Congratulations! Task completed. Reward received: " .. currentTask.reward}
                            })
                        end
                    end
                end
            end
        end
    end
end)

-- Thread to show markers at target locations
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isTaskActive then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for i, step in ipairs(currentTask.steps) do
                if step.coords and not step.completed then
                    local distance = #(playerCoords - step.coords)
                    
                    -- Draw marker when within 100 meters
                    if distance < 100.0 then
                        DrawMarker(1, -- Marker type
                            step.coords.x, step.coords.y, step.coords.z - 1.0,
                            0.0, 0.0, 0.0, -- Direction
                            0.0, 0.0, 0.0, -- Rotation
                            1.5, 1.5, 1.5, -- Scale
                            255, 255, 0, 100, -- Color (yellow with alpha)
                            false, -- Bob up and down
                            false, -- Face camera
                            2, -- p19
                            false, -- Rotate
                            nil, -- Texture dictionary
                            nil, -- Texture name
                            false -- Draw on entities
                        )
                    end
                end
            end
        end
    end
end)

-- Helper function to show floating help text
function ShowHelpNotification(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Add chat suggestion for commands
Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/getitem', 'Collect a package for the current task')
    TriggerEvent('chat:addSuggestion', '/finditem', 'Find a hidden item for the current task')
end)