AddEventHandler("Wardrobe:Shared:DependencyUpdate", RetrieveWardrobeComponents)
function RetrieveWardrobeComponents()
	Callbacks = exports["mythic-base"]:FetchComponent("Callbacks")
	Notification = exports["mythic-base"]:FetchComponent("Notification")
	Utils = exports["mythic-base"]:FetchComponent("Utils")
	ListMenu = exports["mythic-base"]:FetchComponent("ListMenu")
	Input = exports["mythic-base"]:FetchComponent("Input")
	Confirm = exports["mythic-base"]:FetchComponent("Confirm")
	Sounds = exports["mythic-base"]:FetchComponent("Sounds")
	Wardrobe = exports["mythic-base"]:FetchComponent("Wardrobe")
	Inventory = exports["mythic-base"]:FetchComponent("Inventory")
	Progress = exports["mythic-base"]:FetchComponent("Progress")
	Animations = exports["mythic-base"]:FetchComponent("Animations")
end

AddEventHandler("Core:Shared:Ready", function()
	exports["mythic-base"]:RequestDependencies("ListMenu", {
		"Callbacks",
		"Notification",
		"Utils",
		"ListMenu",
		"Input",
		"Confirm",
		"Sounds",
		"Wardrobe",
		"Inventory",
		"Progress",
		"Animations",
	}, function(error)
		if #error > 0 then
			return
		end
		RetrieveWardrobeComponents()
	end)
end)

AddEventHandler("Proxy:Shared:RegisterReady", function()
	exports["mythic-base"]:RegisterComponent("Wardrobe", WARDROBE)
end)

AddEventHandler("Wardrobe:Client:SaveNew", function(data)
	Input:Show("Outfit Name", "Outfit Name", {
		{
			id = "name",
			type = "text",
			options = {
				inputProps = {
					maxLength = 24,
				},
			},
		},
	}, "Wardrobe:Client:DoSave", data)
end)

AddEventHandler("Wardrobe:Client:SaveNewBag", function(data)
	Input:Show("Outfit Name", "Outfit Name", {
		{
			id = "name",
			type = "text",
			options = {
				inputProps = {
					maxLength = 24,
				},
			},
		},
	}, "Wardrobe:Client:DoSaveBag", data)
end)

AddEventHandler("Wardrobe:Client:SaveExisting", function(data)
	Callbacks:ServerCallback("Wardrobe:SaveExisting", data.index, function(state)
		if state then
			Notification:Success("Outfit Saved")
			Wardrobe:Show()
		else
			Notification:Error("Unable to Save Outfit")
		end
	end)
end)

AddEventHandler("Wardrobe:Client:SaveExistingBag", function(data)
	Callbacks:ServerCallback("Wardrobe:SaveExistingBag", data.index, function(state)
		if state then
			Notification:Success("Outfit Saved")
			Wardrobe:ShowBag()
		else
			Notification:Error("Unable to Save Outfit")
		end
	end)
end)

AddEventHandler("Wardrobe:Client:DoSave", function(values, data)
	Callbacks:ServerCallback("Wardrobe:Save", {
		index = data,
		name = values.name,
	}, function(state)
		if state then
			Notification:Success("Outfit Saved")
			Wardrobe:Show()
		else
			Notification:Error("Unable to Save Outfit")
		end
	end)
end)

AddEventHandler("Wardrobe:Client:DoSaveBag", function(values, data)
	Callbacks:ServerCallback("Wardrobe:SaveBag", {
		index = data,
		name = values.name,
	}, function(state)
		if state then
			Notification:Success("Outfit Saved in Bag")
			Wardrobe:ShowBag()
		else
			Notification:Error("Unable to Save Outfit")
		end
	end)
end)

AddEventHandler("Wardrobe:Client:Delete", function(data)
	Confirm:Show(string.format("Delete %s?", data.label), {
		yes = "Wardrobe:Client:Delete:Yes",
		no = "Wardrobe:Client:Delete:No",
	}, "", data.index)
end)

AddEventHandler("Wardrobe:Client:DeleteFromBag", function(data)
	Confirm:Show(string.format("Delete %s?", data.label), {
		yes = "Wardrobe:Client:DeleteFromBag:Yes",
		no = "Wardrobe:Client:DeleteFromBag:No",
	}, "", data.index)
end)

AddEventHandler("Wardrobe:Client:Delete:Yes", function(data)
	Callbacks:ServerCallback("Wardrobe:Delete", data, function(s)
		if s then
			Notification:Success("Outfit Deleted")
			Wardrobe:Show()
		end
	end)
end)

AddEventHandler("Wardrobe:Client:DeleteFromBag:Yes", function(data)
	Callbacks:ServerCallback("Wardrobe:DeleteFromBag", data, function(s)
		if s then
			Notification:Success("Outfit Deleted")
			Wardrobe:ShowBag()
		end
	end)
end)

AddEventHandler("Wardrobe:Client:Equip", function(data)
	Callbacks:ServerCallback("Wardrobe:Equip", data.index, function(state)
		if state then
			Sounds.Play:One("outfit_change.ogg", 0.3)
			Notification:Success("Outfit Equipped")
		else
			Notification:Error("Unable to Equip Outfit")
		end
	end)
end)

AddEventHandler("Wardrobe:Client:EquipFromBag", function(data)
	equipWardrobeBagProgress(data)
end)

RegisterNetEvent("Wardrobe:Client:ShowClothingBagMenu", function()
	Wardrobe:ShowBag()
end)

RegisterNetEvent("Wardrobe:Client:ShowBitch", function(eventRoutine)
	Wardrobe:Show()
end)

function equipWardrobeBagProgress(data)
    local playerPed = PlayerPedId()
    local bagProp = nil

    local function spawnBagProp()
        local model = GetHashKey("ch_prop_ch_duffelbag_01x")
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(10)
        end

        local coords = GetEntityCoords(playerPed)
		local forward = GetEntityForwardVector(playerPed)
		local x, y, z = table.unpack(coords + forward * 0.6)

        bagProp = CreateObject(model, x, y, z, true, true, false)
        PlaceObjectOnGroundProperly(bagProp)

        SetModelAsNoLongerNeeded(model)
    end

    local function removeBagProp()
        if DoesEntityExist(bagProp) then
            DeleteEntity(bagProp)
            bagProp = nil
        end
    end

    spawnBagProp()

    Progress:Progress({
        name = "wardrobe_bag",
        duration = 30000,
        label = "Equipping outfit",
        useWhileDead = false,
        canCancel = true,
        vehicle = false,
        animation = {
            animDict = "anim@heists@money_grab@duffel",
            anim = "loop",
            flags = 1,
        },
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableCombat = true,
        },
    }, function(cancelled)
        removeBagProp()

        if not cancelled then
			Animations.Emotes:Play('adjusttie', false, false, false)
			Citizen.Wait(2500)
            Callbacks:ServerCallback("Wardrobe:EquipFromBag", data.index, function(state)
                if state then
                    Sounds.Play:One("outfit_change.ogg", 0.3)
                    Notification:Success("Outfit Equipped from Bag")
                else
                    Notification:Error("Unable to Equip Outfit from Bag")
                end
            end)
        end
    end)
end

WARDROBE = {
	Show = function(self)
		Callbacks:ServerCallback("Wardrobe:GetAll", {}, function(data)
			local items = {}
			for k, v in pairs(data) do
				if v.label ~= nil then
					table.insert(items, {
						label = v.label,
						description = string.format("Outfit #%s", k),
						actions = {
							{
								icon = "floppy-disks",
								event = "Wardrobe:Client:SaveExisting",
							},
							{
								icon = "shirt",
								event = "Wardrobe:Client:Equip",
							},
							{
								icon = "trash",
								event = "Wardrobe:Client:Delete",
							},
						},
						data = {
							index = k,
							label = v.label,
						},
					})
				end
			end

			table.insert(items, {
				label = "Save New Outfit",
				event = "Wardrobe:Client:SaveNew",
			})

			ListMenu:Show({
				main = {
					label = "Wardrobe",
					items = items,
				},
			})
		end)
	end,
	ShowBag = function(self)
		Callbacks:ServerCallback("Wardrobe:GetBag", {}, function(data)
			local items = {}

			if data and data[1] and data[1].label then
				table.insert(items, {
					label = data[1].label,
					description = "Bagged Outfit",
					actions = {
						{
							icon = "floppy-disk",
							event = "Wardrobe:Client:SaveExistingBag",
						},
						{
							icon = "shirt",
							event = "Wardrobe:Client:EquipFromBag",
						},
						{
							icon = "trash",
							event = "Wardrobe:Client:DeleteFromBag",
						},
					},
					data = {
						index = 1,
						label = data[1].label,
					},
				})
			else
				table.insert(items, {
					label = "Save New Outfit",
					event = "Wardrobe:Client:SaveNewBag",
				})
			end

			ListMenu:Show({
				main = {
					label = "Wardrobe Bag",
					items = items,
				},
			})
		end)
	end,
	Close = function(self)
		SetNuiFocus(false, false)
		SendNUIMessage({
			type = "CLOSE_LIST_MENU",
		})
	end,
}
