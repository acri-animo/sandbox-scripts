local parcelInProgress = false
local _currentZone = nil
local _blip = nil
local parcels = {}
local model = `prop_cardbordbox_05a`

AddEventHandler("PettyCrime:Client:Setup", function()
    PedInteraction:Add("ParcelTheftPed", `a_m_o_tramp_01`, vector3(1117.711, -656.085, 55.813), 194.783, 25.0, {
        {
            icon = "hands",
            text = "Parcel Theft",
            event = "Parcel:Client:InitializeZone",
            data = {},
        },
        {
            icon = "gift",
            text = "Turn In Parcels",
            event = "Parcel:Client:TurnInParcels",
            data = {},
            isEnabled = function(data, entity)
                if not parcelInProgress then
                    return false
                end
                return true
            end,
        },
    }, 'user-hoodie', 'WORLD_HUMAN_SMOKING')
end)

function createParcels(locations)
    for k, v in ipairs(locations) do
        local parcel = CreateObject(model, v.x, v.y, v.z, true, true, false)
        SetEntityHeading(parcel, v.h)
        FreezeEntityPosition(parcel, true)

        parcels[k] = parcel

    end

    Targeting:AddObject(model, "box", {
            {
                icon = "hand",
                text = "Collect parcel",
                event = "Parcel:Client:CollectParcel",
                data = {},
                isEnabled = function(data, entity)
                    if not parcelInProgress or not entity.entity then
                        return false
                    end
                    return true
                end,
            }
        })
end

function clearParcels()
    for k, v in ipairs(parcels) do
        if DoesEntityExist(v) then
            DeleteObject(v)
        end
    end

    Targeting:RemoveObject(model)

    _currentZone = nil

    parcels = {}
end

AddEventHandler("Parcel:Client:InitializeZone", function()
    if parcelInProgress then
        Notification:Error("You already started the task.")
        return
    end

    Callbacks:ServerCallback("Parcel:Server:GetZone", {}, function(zone)
        if not zone or not zone.coords then
            Notification:Error("Invalid zone data.")
            return
        end

        _currentZone = zone
        parcelInProgress = true

        Notification:Success("I know a good spot for parcels, check your map")
        _blip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, (zone.radius / 2) + 0.0)
        SetBlipColour(_blip, 3)
        SetBlipAlpha(_blip, 90)

        createParcels(zone.locations)
    end)
end)

AddEventHandler("Parcel:Client:CollectParcel", function(entity, data)
    if not entity or not entity.entity then
        Notification:Error("Invalid parcel.")
        return
    end

    local parcel = entity.entity
    
    Progress:Progress({
        name = "parcel_theft",
        duration = math.random(5000, 10000),
        label = "Collecting parcel",
        useWhileDead = false,
        canCancel = true,
        vehicle = false,
        animation = {
            anim = "medic",
        },
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableCombat = true,
        },
    }, function(cancelled)
        if not cancelled then
            local coords = GetEntityCoords(LocalPlayer.state.ped)
            Callbacks:ServerCallback("Parcel:Server:CollectParcel", { coords = coords }, function(success)
                if success then
                    Notification:Success("Parcel collected successfully.")
                    DeleteObject(parcel)
                else
                    Notification:Error("Failed to collect parcel.")
                end
            end)
        end
    end)
end)

AddEventHandler("Parcel:Client:TurnInParcels", function()
    Callbacks:ServerCallback("Parcel:Server:TurnInParcels", {}, function(success)
        if success then
            Notification:Success("Parcels turned in successfully.")
            clearParcels()
            parcelInProgress = false
            RemoveBlip(_blip)
            _blip = nil
        else
            Notification:Error("You need at least 1 parcel.")
        end
    end)
end)