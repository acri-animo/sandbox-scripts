Citizen.CreateThread(function()
	while GetIsLoadingScreenActive() do
		Citizen.Wait(0)
	end
	SendNUIMessage({
		type = "APP_SHOW",
	})
end)

local loadTo = 0
function loadModel(model)
	RequestModel(model)
	loadTo = 0
	while not HasModelLoaded(model) and loadTo < 500 do
		loadTo += 1
		Citizen.Wait(100)
	end
end

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(10)
	end
end

local previews = {
	vector4(707.324, -966.991, 29.413, 176.367),
	vector4(705.442, -965.971, 29.395, 283.243),
	vector4(708.767, -966.609, 29.395, 95.992),
	vector4(708.813, -963.524, 29.395, 177.803),
	vector4(705.708, -963.826, 29.395, 49.689),
}
local peds = {}

local typeAnim = {
	dict = "mp_prison_break",
	anim = "hack_loop",
}

local sitAnim = {
	dict = "anim@heists@fleeca_bank@ig_7_jetski_owner",
	anim = "owner_idle",
}

local leanAnim = {
	dict = "amb@world_human_leaning@female@wall@back@holding_elbow@idle_a",
	anim = "idle_a",
}

RegisterNUICallback("GetData", function(data, cb)
	cb("ok")

	while LocalPlayer.state.ID == nil do
		Citizen.Wait(1)
	end

	for k, v in ipairs(peds) do
		DeleteEntity(v)
	end

	Callbacks:ServerCallback("Characters:GetServerData", {}, function(serverData)
		SendNUIMessage({
			type = "LOADING_SHOW",
			data = { message = "Getting Character Data" },
		})

		FadeOutWithTimeout(500)

		Callbacks:ServerCallback("Characters:GetCharacters", {}, function(characters, characterLimit)
			local ped = PlayerPedId()
			SetEntityCoords(ped, 709.441, -963.162, 32.158, 0.0, 0.0, 0.0, false)
			FreezeEntityPosition(ped, true)
			SetEntityVisible(ped, false)
			SetPlayerVisibleLocally(ped, false)

			local interior = GetInteriorFromEntity(ped)
			if interior ~= 0 then
				local roomHash = GetRoomKeyFromEntity(ped)
				ForceRoomForEntity(ped, interior, roomHash)
			end

			Citizen.Wait(250)

			local cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 709.441, -963.162, 32.158, -21.286, -0.0, 145.935, 55.0, false, 0)

			SetCamActiveWithInterp(cam2, cam, 1000, true, true)
			RenderScriptCams(true, false, 1, true, true)

			TriggerScreenblurFadeOut(500)
			cam = cam2

			for k, v in ipairs(characters) do
				if previews[k] then
					if v.Preview then
						loadModel(GetHashKey(v.Preview.model))
						local ped = CreatePed(
							5,
							GetHashKey(v.Preview.model),
							previews[k][1],
							previews[k][2],
							previews[k][3],
							previews[k][4],
							false,
							true
						)

						local t = 0
						while not DoesEntityExist(ped) and t < 2500 do
							t += 1
							Citizen.Wait(1)
						end

						if DoesEntityExist(ped) then
							SetEntityCoords(ped, previews[k][1], previews[k][2], previews[k][3], 0.0, 0.0, 0.0, false)
							FreezeEntityPosition(ped, true)
							Ped:Preview(ped, tonumber(v.Gender), v.Preview, false, v.GangChain)

							if k == 1 then
								loadAnimDict(typeAnim.dict)
								TaskPlayAnim(ped, typeAnim.dict, typeAnim.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
							elseif k == 2 then
								loadAnimDict(sitAnim.dict)
								TaskPlayAnim(ped, sitAnim.dict, sitAnim.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
							elseif k == 3 then
								loadAnimDict(leanAnim.dict)
								TaskPlayAnim(ped, leanAnim.dict, leanAnim.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
							end
	
							table.insert(peds, ped)
						end
					else
						loadModel(tonumber(v.Gender) == 0 and `mp_m_freemode_01` or `mp_f_freemode_01`)
						local ped = CreatePed(
							5,
							tonumber(v.Gender) == 0 and `mp_m_freemode_01` or `mp_f_freemode_01`,
							previews[k][1],
							previews[k][2],
							previews[k][3],
							previews[k][4],
							false,
							true
						)

						local t = 0
						while not DoesEntityExist(ped) and t < 2500 do
							t += 1
							Citizen.Wait(1)
						end

						if DoesEntityExist(ped) then
							SetEntityCoords(ped, previews[k][1], previews[k][2], previews[k][3], 0.0, 0.0, 0.0, false)
							FreezeEntityPosition(ped, true)

							if k == 1 then
								loadAnimDict(typeAnim.dict)
								TaskPlayAnim(ped, typeAnim.dict, typeAnim.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
							elseif k == 2 then
								loadAnimDict(sitAnim.dict)
								TaskPlayAnim(ped, sitAnim.dict, sitAnim.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
							elseif k == 3 then
								loadAnimDict(leanAnim.dict)
								TaskPlayAnim(ped, leanAnim.dict, leanAnim.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
							end
	
							table.insert(peds, ped)
						end
					end
				end
			end

			SendNUIMessage({
				type = "SET_DATA",
				data = {
					changelog = serverData.changelog,
					motd = serverData.motd,
					characters = characters,
					characterLimit = characterLimit,
				},
			})
			SendNUIMessage({ type = "LOADING_HIDE" })
			SendNUIMessage({
				type = "SET_STATE",
				data = { state = "STATE_CHARACTERS" },
			})

			FadeInWithTimeout(500)
		end)
	end)
end)

RegisterNUICallback("CreateCharacter", function(data, cb)
	cb("ok")
	Callbacks:ServerCallback("Characters:CreateCharacter", data, function(character)
		if character ~= nil then
			SendNUIMessage({
				type = "CREATE_CHARACTER",
				data = { character = character },
			})
		end

		SendNUIMessage({
			type = "SET_STATE",
			data = { state = "STATE_CHARACTERS" },
		})
		SendNUIMessage({ type = "LOADING_HIDE" })
	end)
end)

RegisterNUICallback("DeleteCharacter", function(data, cb)
	cb("ok")
	Callbacks:ServerCallback("Characters:DeleteCharacter", data.id, function(status)
		if status then
			SendNUIMessage({
				type = "DELETE_CHARACTER",
				data = { id = data.id },
			})
		end
		SendNUIMessage({ type = "LOADING_HIDE" })
	end)
end)

RegisterNUICallback("SelectCharacter", function(data, cb)
	cb("ok")
	Callbacks:ServerCallback("Characters:GetSpawnPoints", data.id, function(spawns)
		if spawns then
			SendNUIMessage({
				type = "SET_SPAWNS",
				data = { spawns = spawns },
			})
			SendNUIMessage({
				type = "SET_STATE",
				data = { state = "STATE_SPAWN" },
			})
		end

		SendNUIMessage({ type = "LOADING_HIDE" })
	end)
end)

RegisterNUICallback("PlayCharacter", function(data, cb)
	cb("ok")

	FadeOutWithTimeout(500)

	Callbacks:ServerCallback("Characters:GetCharacterData", data.character.ID, function(cData)
		cData.spawn = data.spawn
		TriggerEvent("Characters:Client:SetData", -1, cData, function()
			exports["lumen-base"]:FetchComponent("Spawn"):SpawnToWorld(cData, function()
				LocalPlayer.state.canUsePhone = true
				if data.spawn.event ~= nil then
					Callbacks:ServerCallback(data.spawn.event, data.spawn, function()
						LocalPlayer.state.Char = cData.ID
						LocalPlayer.state:set('SID', cData.SID, true)
						TriggerServerEvent("Characters:Server:Spawning")
						FadeInWithTimeout(500)
					end)
				else
					LocalPlayer.state:set('SID', cData.SID, true)
					TriggerServerEvent("Characters:Server:Spawning")

					FadeInWithTimeout(500)
				end
			end)
		end)

		for k, v in ipairs(peds) do
			DeleteEntity(v)
		end
	end)
end)

RegisterNetEvent("Characters:Client:Spawned", function()
	TriggerEvent("Characters:Client:Spawn")
	TriggerServerEvent("Characters:Server:Spawn")
	SetNuiFocus(false)
	SendNUIMessage({ type = "APP_HIDE" })
	SendNUIMessage({ type = "LOADING_HIDE" })
	LocalPlayer.state.loggedIn = true
end)