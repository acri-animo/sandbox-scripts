function RegisterItems()
    local strains = {
        "reggie", "greencrack", "bluedream", "bluekush", "granddaddy",
        "bluehaze", "purpdream", "cherrypie", "gelatopurp", "gscookies",
        "sourdiesel", "gorillaglue"
    }

    for _, strain in ipairs(strains) do
        -- Male seed
        Inventory.Items:RegisterUse("weedseed_" .. strain .. "_male", "Weed", function(source, item)
            if GlobalState[string.format("%s:House", source)] == nil then
                local char = Fetch:CharacterSource(source)
                local veh = GetVehiclePedIsIn(GetPlayerPed(source))
                if veh == 0 then
                    Callbacks:ClientCallback(source, "Weed:PlantingAnim", { strain = strain }, function(data)
                        if data.error == nil then
                            Inventory.Items:RemoveList(char:GetData("SID"), 1, { { name = "weedseed_" .. strain .. "_male", count = 1 } })
                            local plant = Weed.Planting:Create(
                                true,
                                { x = data.coords.x, y = data.coords.y, z = data.coords.z },
                                data.material,
                                strain -- Pass strain to Create
                            )

                            _plants[plant._id] = {
                                plant = plant,
                                strain = strain -- Store strain
                            }

                            Weed.Planting:Set(plant._id, false)
                        else
                            if data.error == 2 then
                                Execute:Client(source, "Notification", "Error", "Need Better Soil")
                            elseif data.error == 3 then
                                Execute:Client(source, "Notification", "Error", "Too Close")
                            end
                        end
                    end)
                else
                    Execute:Client(source, "Notification", "Error", "Can't Plant While In A Vehicle")
                end
            else
                Execute:Client(source, "Notification", "Error", "Plant Needs Natural Light")
            end
        end)

        -- Female seed
        Inventory.Items:RegisterUse("weedseed_" .. strain .. "_female", "Weed", function(source, item)
            if GlobalState[string.format("%s:House", source)] == nil then
                local char = Fetch:CharacterSource(source)
                local veh = GetVehiclePedIsIn(GetPlayerPed(source))
                if veh == 0 then
                    Callbacks:ClientCallback(source, "Weed:PlantingAnim", { strain = strain }, function(data)
                        if data.error == nil then
                            Inventory.Items:RemoveList(char:GetData("SID"), 1, { { name = "weedseed_" .. strain .. "_female", count = 1 } })
                            local plant = Weed.Planting:Create(
                                false,
                                { x = data.coords.x, y = data.coords.y, z = data.coords.z },
                                data.material,
                                strain -- Pass strain to Create
                            )

                            _plants[plant._id] = {
                                plant = plant,
                                strain = strain -- Store strain
                            }

                            Weed.Planting:Set(plant._id, false)
                        else
                            if data.error == 2 then
                                Execute:Client(source, "Notification", "Error", "Need Better Soil")
                            elseif data.error == 3 then
                                Execute:Client(source, "Notification", "Error", "Too Close")
                            end
                        end
                    end)
                else
                    Execute:Client(source, "Notification", "Error", "Can't Plant While In A Vehicle")
                end
            else
                Execute:Client(source, "Notification", "Error", "Plant Needs Natural Light")
            end
        end)
    end

    Inventory.Items:RegisterUse("rolling_paper", "Weed", function(source, item)
        local char = Fetch:CharacterSource(source)
        if Inventory.Items:Has(char:GetData("SID"), 1, "weed_bud", 1) then
            Callbacks:ClientCallback(source, "Weed:RollingAnim", {}, function(success)
                if success then
                    Inventory.Items:RemoveList(
                        char:GetData("SID"),
                        1,
                        { { name = "rolling_paper", count = 1 }, { name = "weed_bud", count = 1 } }
                    )
                    Inventory:AddItem(char:GetData("SID"), "weed_joint", 2, {}, 1)
                end
            end)
        else
            Execute:Client(source, "Notification", "Error", "You need bud you fucking idiot")
        end
    end)

    Inventory.Items:RegisterUse("weed_joint", "Weed", function(source, item)
        local char = Fetch:CharacterSource(source)
        Callbacks:ClientCallback(source, "Weed:SmokingAnim", {}, function(success, count)
            Inventory.Items:RemoveList(char:GetData("SID"), 1, { { name = "weed_joint", count = 1 } })

            local stressTicks = {}
            for i = 0, count do
                table.insert(stressTicks, "3")
            end
            Player(source).state.stressTicks = stressTicks
        end)
    end)

    Inventory.Items:RegisterUse("weed_brick", "Weed", function(source, item)
        local char = Fetch:CharacterSource(source)
        if Inventory.Items:Has(char:GetData("SID"), 1, "weed_brick", 1) then
            Callbacks:ClientCallback(source, "Weed:MakingBrick", {
                label = "Unpacking Brick",
                time = 10,
            }, function(success)
                if success then
                    Inventory.Items:RemoveList(char:GetData("SID"), 1, { { name = "weed_brick", count = 1 } })
                    Inventory:AddItem(char:GetData("SID"), "weed_bud", 200, {}, 1)
                end
            end)
        else
            Execute:Client(source, "Notification", "Error", "You need 200 bud you fucking idiot")
        end
    end)

    Inventory.Items:RegisterUse("weed_baggy", "Weed", function(source, item)
        local char = Fetch:CharacterSource(source)
        if Inventory.Items:Has(char:GetData("SID"), 1, "weed_baggy", 1) then
            Callbacks:ClientCallback(source, "Weed:MakingBrick", {
                label = "Removing Bud",
                time = 3,
            }, function(success)
                if success then
                    Inventory.Items:RemoveList(char:GetData("SID"), 1, { { name = "weed_baggy", count = 1 } })
                    Inventory:AddItem(char:GetData("SID"), "weed_bud", 2, {}, 1)
                end
            end)
        else
            Execute:Client(source, "Notification", "Error", "You need 200 bud")
        end
    end)
end