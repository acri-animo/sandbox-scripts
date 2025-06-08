local _ammuPeds = {}

function ammuNeedsReset()
    for k, v in ipairs(_ammuDoors) do
        if not Doors:IsLocked(v.door) then
            return true
        end
    end

    for k, v in ipairs(_ammuHack) do
        if
           GlobalState[string.format("Ammunation:Vault:Wall:%s", v.data.wallId)] ~= nil
           and GlobalState[string.format("Ammunation:Vault:Wall:%s", v.data.wallId)] > GetCloudTimeAsInt()
        then
            return true
        end
    end
end


AddEventHandler("Robbery:Client:Setup", function()
    Polyzone.Create:Box(
        "ammunation_one",
        vector3(818.36, -2172.69, 29.29),
        50.6,
        24.2,
        {
            heading = 0,
            -- debugPoly = true,
            minZ = 25.09,
            maxZ = 39.69,
        }
    )


    Targeting.Zones:AddBox("ammunation_secure", "shield-keyhole", vector3(810.0, -2158.0, 29.6), 1.4, 0.6, {
        heading = 37,
        --debugPoly = true,
        minZ = 29.4,
        maxZ = 31.0,
    }, {
        {
            icon = "phone",
            text = "Secure Bank",
            event = "Robbery:Client:Ammunation:StartSecuring",
            jobPerms = {
                {
                    job = "police",
                    reqDuty = true,
                },
            },
            data = {},
            isEnabled = ammuNeedsReset,
        },
    }, 3.0, true)

    Targeting.Zones:AddBox("ammunation_electric", "bolt", vector3(853.49, -2211.33, 30.63), 1.2, 0.8, {
        heading = 354,
        --debugPoly = true,
        minZ = 29.63,
        maxZ = 32.03,
    }, {
        {
            icon = "terminal",
            text = "Hack Power Interface",
            item = "adv_electronics_kit",
            event = "Robbery:Client:Ammunation:ElectricBox:Hack",
            data = {
                boxId = 1,
                ptFxPoint = vector3(853.69, -2211.33, 30.63),
            },
            isEnabled = function(data, entity)
                return not GlobalState["Ammunation:Secured"]
                    and (
                        not GlobalState[string.format("Ammunation:Power:%s", data.boxId)]
                        or GetCloudTimeAsInt()
                            > GlobalState[string.format("Ammunation:Power:%s", data.boxId)]
                    )
            end,
        },
    }, 3.0, true)

    Targeting.Zones:AddBox("ammunation_pc_hack", "laptop", vector3(811.0, -2181.0, 27.68), 1.2, 0.8, {
        heading = 354,
        --debugPoly = true,
        minZ = 26.68,
        maxZ = 29.08,
    }, {
        {
            icon = "laptop",
            text = "Hack Security System",
            item = "adv_electronics_kit",
            event = "Robbery:Client:Ammunation:HackPC",
            data = {
                pc = 1,
            },
            isEnabled = function(data, entity)
                return not GlobalState["Ammunation:Secured"]
                    and (
                        not GlobalState[string.format("Ammunation:PC:%s", data.pc)]
                        or GetCloudTimeAsInt()
                            > GlobalState[string.format("Ammunation:PC:%s", data.pc)]
                    )
                    and LocalPlayer.state.inAmmunation
            end,
        },
    }, 3.0, true)

    for k, v in ipairs(_ammuDrillPoints) do
        Targeting.Zones:AddBox(
            string.format("ammunation_drill_%s", v.data.wallId),
            "bore-hole",
            v.coords,
            v.length,
            v.width,
            v.options,
            {
                {
                    icon = "bore-hole",
                    text = "Drill Vault",
                    item = "drill",
                    event = "Robbery:Client:Ammunation:Drill",
                    data = {
                        id = v.data.wallId,
                    },
                    isEnabled = function(data, entity)
                        return not GlobalState["Ammunation:Secured"]
                            and (
                                not GlobalState[string.format("Ammunation:Vault:Wall:%s", data.id)]
                                or GetCloudTimeAsInt()
                                    > GlobalState[string.format("Ammunation:Vault:Wall:%s", data.id)]
                            )
                            and LocalPlayer.state.inAmmunation
                    end,
                },
            },
            3.0,
            true
        )
    end

    for k, v in ipairs(_ammuMainLoot) do
        Targeting.Zones:AddBox(
            string.format("ammunation_main_loot_%s", v.data.lootId),
            "box-taped",
            v.coords,
            v.length,
            v.width,
            v.options,
            {
                {
                    icon = "person-rifle",
                    text = "Loot Shelf",
                    event = "Robbery:Client:Ammunation:LootMain",
                    data = {
                        id = v.data.lootId,
                    },
                    isEnabled = function(data, entity)
                        return not GlobalState["Ammunation:Secured"]
                            and (
                                not GlobalState[string.format("Ammunation:Loot:%s", data.id)]
                                or GetCloudTimeAsInt()
                                    > GlobalState[string.format("Ammunation:Loot:%s", data.id)]
                            )
                            and LocalPlayer.state.inAmmunation
                    end,
                },
            },
            3.0,
            true
        )
    end

    Callbacks:RegisterClientCallback("Robbery:Client:Ammunation:LootProg", function(data, cb)
        Progress:Progress({
            name = "ammunation_loot",
            duration = 30000,
            label = "Looting Ammunation",
            useWhileDead = false,
            canCancel = false,
            ignoreModifier = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                anim = "search",
            },
        }, function(status)
            if status then
                return
            end
            cb(true)
        end)
    end)
end)

AddEventHandler("Polyzone:Enter", function(id, testedPoint, insideZones, data)
    if id == "ammunation_one" or id == "ammunation_two" then
        LocalPlayer.state:set("inAmmunation", true, true)
    end
end)

AddEventHandler("Polyzone:Exit", function(id, testedPoint, insideZones, data)
    if id == "ammunation_one" or id == "ammunation_two" then
        LocalPlayer.state:set("inAmmunation", false, true)
    end
end)

AddEventHandler("Robbery:Client:Ammunation:StartSecuring", function()
    Progress:Progress({
        name = "secure_ammunation",
        duration = 30000,
        label = "Securing Ammunation",
        useWhileDead = false,
        canCancel = false,
        ignoreModifier = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            anim = "cop3",
        },
    }, function(status)
        if not status then
            Callbacks:ServerCallback("Robbery:Ammunation:SecureAmmu", {})
        end
    end)
end)

RegisterNetEvent("Robbery:Client:Ammunation:SpawnPeds", function()
    for k, ped in pairs(_ammuPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
        _ammuPeds[k] = nil
    end

    if not _ammuPedSpawns or #_ammuPedSpawns == 0 then
        print("[Ammunation] Error: _ammuPedSpawns is empty or undefined")
        return
    end

    local pedModel = GetHashKey("s_m_y_ammucity_01")
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(100)
    end

    local pedGroup = GetHashKey("AMMUNATION_ENEMIES")
    AddRelationshipGroup("AMMUNATION_ENEMIES")
    SetRelationshipBetweenGroups(5, pedGroup, GetHashKey("PLAYER")) -- Hate players
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), pedGroup) -- Players hate peds

    for k, v in ipairs(_ammuPedSpawns) do
        if not v.coords or type(v.coords) ~= "vector4" then
            print("[Ammunation] Error: Invalid coords for ped " .. k)
            goto continue
        end

        local ped = CreatePed(
            4,
            pedModel,
            v.coords.x, v.coords.y, v.coords.z,
            v.coords.w,
            true,
            true
        )

        if DoesEntityExist(ped) then
            _ammuPeds[k] = ped

            SetPedRelationshipGroupHash(ped, pedGroup)
            SetPedCombatAttributes(ped, 46, true)
            SetPedCombatAttributes(ped, 5, true)
            SetPedFleeAttributes(ped, 0, false)
            SetPedCombatRange(ped, 1)
            SetPedCombatMovement(ped, 2)
            SetPedAccuracy(ped, 60)
            SetPedAsEnemy(ped, true)

            GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 100, false, true)
            SetPedInfiniteAmmo(ped, true, GetHashKey("WEAPON_PISTOL"))

            SetEntityAsMissionEntity(ped, true, true)
            SetPedKeepTask(ped, true)

            Citizen.CreateThread(function()
                while DoesEntityExist(ped) and not IsEntityDead(ped) do
                    local playerPed = GetPlayerPed(-1)
                    if DoesEntityExist(playerPed) and HasEntityClearLosToEntity(ped, playerPed, 17) then
                        TaskCombatPed(ped, playerPed, 0, 16)
                    else
                        TaskWanderInArea(ped, v.coords.x, v.coords.y, v.coords.z, 5.0, 0, 0)
                    end
                    Wait(1000)
                end
            end)
        end

        ::continue::
    end

    SetModelAsNoLongerNeeded(pedModel)
end)

AddEventHandler("Robbery:Client:Ammunation:Drill", function(entity, data)
    Callbacks:ServerCallback("Robbery:Ammunation:Drill", data.id, function() end)
end)

AddEventHandler("Robbery:Client:Ammunation:ElectricBox:Hack", function(entity, data)
    Callbacks:ServerCallback("Robbery:Ammunation:ElectricBox:Hack", data, function() end)
end)

AddEventHandler("Robbery:Client:Ammunation:HackPC", function(entity, data)
    Callbacks:ServerCallback("Robbery:Ammunation:PcHack", data.pc, function() end)
end)

AddEventHandler("Robbery:Client:Ammunation:LootMain", function(entity, data)
    Callbacks:ServerCallback("Robbery:Ammunation:LootMain", data.id, function() end)
end)