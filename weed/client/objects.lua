_activePlants, _nearbyPlants, _spawnedPlants = {}, {}, {}

RegisterNetEvent('Weed:Client:Objects:Init', function(plants)
    if plants and type(plants) == 'table' then
        for k,v in pairs(plants) do
            _activePlants[k] = v
        end

        _spawnedPlants = {}
        _nearbyPlants = {}

        while not LocalPlayer.state.loggedIn do
            Citizen.Wait(100)
        end

        Citizen.CreateThread(function()
            while LocalPlayer.state.loggedIn do
                Citizen.Wait(3000)

                if _activePlants then
                    local pedCoords = GetEntityCoords(LocalPlayer.state.ped)
                    for k,v in pairs(_activePlants) do
                        if #(pedCoords - vector3(v.plant.location.x, v.plant.location.y, v.plant.location.z)) <= 500.0 then
                            if not _nearbyPlants[k] then
                                _nearbyPlants[k] = true
                            end
                        elseif _nearbyPlants[k] then
                            _nearbyPlants[k] = nil

                            if _spawnedPlants[k] and DoesEntityExist(_spawnedPlants[k]) then
                                DeleteEntity(_spawnedPlants[k])
                                _spawnedPlants[k] = nil
                                Citizen.Wait(5)
                            end
                        end
                    end
                end
            end
        end)

        Citizen.CreateThread(function()
            while LocalPlayer.state.loggedIn do
                Citizen.Wait(350)
                if _activePlants and _nearbyPlants then
                    local pedCoords = GetEntityCoords(LocalPlayer.state.ped)
                    for k,v in pairs(_nearbyPlants) do
                        local weed = _activePlants[k]
                        if weed and #(pedCoords - vector3(weed.plant.location.x, weed.plant.location.y, weed.plant.location.z)) <= 50.0 then
                            if not _spawnedPlants[k] then
                                _spawnedPlants[k] = CreateWeedPlant(k, weed)
                                Citizen.Wait(5)
                            end
                        elseif _spawnedPlants[k] and DoesEntityExist(_spawnedPlants[k]) then
                            DeleteEntity(_spawnedPlants[k])
                            _spawnedPlants[k] = nil
                            Citizen.Wait(5)
                        end
                    end
                else
                    Citizen.Wait(1500)
                end
            end
        end)
    else
        Logger:Error('Weed', 'Failed to Load Weed Objects')
    end
end)

RegisterNetEvent('Weed:Client:Objects:Update', function(plantId, data, isUpdate)
    _activePlants[plantId] = data

    if isUpdate and _spawnedPlants[plantId] then
        DeleteEntity(_spawnedPlants[plantId])
        _spawnedPlants[plantId] = nil
    end
end)

RegisterNetEvent('Weed:Client:Objects:UpdateMany', function(data)
    for k, v in ipairs(data) do
        _activePlants[v.id] = v.plant
    
        if v.update and _spawnedPlants[v.id] then
            DeleteEntity(_spawnedPlants[v.id])
            _spawnedPlants[v.id] = nil
        end
    end
end)

RegisterNetEvent('Weed:Client:Objects:Delete', function(plantId)
    _activePlants[plantId] = nil

    if _spawnedPlants[plantId] then
        DeleteEntity(_spawnedPlants[plantId])
        _spawnedPlants[plantId] = nil
    end

    if _nearbyPlants[plantId] then
        _nearbyPlants[plantId] = nil
    end
end)

function CreateWeedPlant(id, data)
    local weedPlant = data.plant
    local strain = weedPlant.strain
    local stage = getStageByPct(weedPlant.growth)

    if not Plants[strain] then
        print("Error: Strain '" .. strain .. "' not found in Plants table")
        return nil
    end

    if not Plants[strain][stage] then
        print("Error: Stage " .. stage .. " not found for strain '" .. strain .. "'")
        return nil
    end

    local model = Plants[strain][stage].model
    -- print("Model: " .. model)

    local obj = CreateObject(model, weedPlant.location.x + 0.0, weedPlant.location.y + 0.0, weedPlant.location.z + Plants[strain][stage].offset, false, true)
    FreezeEntityPosition(obj, true)
    SetEntityCoords(obj, weedPlant.location.x + 0.0, weedPlant.location.y + 0.0, weedPlant.location.z + Plants[strain][stage].offset)

    return obj
end

function GetWeedPlant(entity)
    for k, v in pairs(_spawnedPlants) do
        if v == entity then
            return k
        end
    end
end

RegisterNetEvent('Characters:Client:Logout')
AddEventHandler('Characters:Client:Logout', function()
    if _spawnedPlants then
        for k, v in pairs(_spawnedPlants) do
            DeleteEntity(v)
        end
    end

    _activePlants = nil
    _spawnedPlants = nil
    _nearbyPlants = nil

    collectgarbage()

    _activePlants = {}
    _spawnedPlants = {}
    _nearbyPlants = {}
end)