AddEventHandler("Drugs:Client:Startup", function()
    Targeting.Zones:AddBox("wash_moneyrolls", "money-bill", vector3(1131.5, -3198.51, -39.67), 2.0, 2.4, {
		heading = 0,
		--debugPoly = true,
		minZ = -42.67,
		maxZ = -38.67,
	}, {
		{
			icon = "money-bill",
			text = "Dry Wet Money Rolls",
			event = "drymoneyroll:menu",
			item = "moneywash_card",
			count = 1,
		},
	}, 3.0, true)

	Targeting.Zones:AddBox("wash_moneyband", "money-bill", vector3(1128.51, -3198.46, -39.67), 2.0, 2.4, {
		heading = 0,
		--debugPoly=true,
		minZ = -42.67,
		maxZ = -38.67,
	}, {
		{
			icon = "money-bill",
			text = "Dry Wet Money Bands",
			event = "drymoneyband:menu",
			item = "moneywash_card",
			count = 1,
		},
	}, 3.0, true)

	Targeting.Zones:AddBox("dry_moneyroll", "money-bill", vector3(1123.04, -3193.22, -40.4), 2.0, 2.4, {
		heading = 0,
		--debugPoly=true,
		minZ = -43.2,
		maxZ = -39.2,
	}, {
		{
			icon = "money-bill",
			text = "Wash Money Rolls",
			event = "moneyroll:menu",
			item = "moneywash_card",
			count = 1,
		},
	}, 3.0, true)

	Targeting.Zones:AddBox("dry_moneyband", "money-bill", vector3(1126.23, -3193.0, -40.4), 2.0, 2.4, {
		heading = 0,
		--debugPoly=true,
		minZ = -43.2,
		maxZ = -39.2,
	}, {
		{
			icon = "money-bill",
			text = "Wash Money Bands",
			event = "moneyband:menu",
			item = "moneywash_card",
			count = 1,
		},
	}, 3.0, true)
end)

RegisterNetEvent('moneyroll:menu', function()
    ListMenu:Show({
        main = {
            label = "Wash Money Rolls",
            items = {
                {
                    label = "Wash 5 Money Rolls",
                    description = "Wash your Money Rolls. You need 5 rolls.",
                    data = {
                        amount = 5,
                        type = "wash",
                        progress = "Washing moneyrolls",
                        anim = "kneel",
                        duration = math.random(12, 15) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Wash 10 Money Rolls",
                    description = "Wash your Money Rolls. You need 10 rolls.",
                    data = {
                        amount = 10,
                        type = "wash",
                        progress = "Washing moneyrolls",
                        anim = "kneel",
                        duration = math.random(25, 29) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Wash 25 Money Rolls",
                    description = "Wash your Money Rolls. You need 25 rolls.",
                    data = {
                        amount = 25,
                        type = "wash",
                        progress = "Washing moneyrolls",
                        anim = "kneel",
                        duration = math.random(65, 70) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Wash 100 Money Rolls",
                    description = "Wash your Money Rolls. You need 100 rolls.",
                    data = {
                        amount = 100,
                        type = "wash",
                        progress = "Washing moneyrolls",
                        anim = "kneel",
                        duration = math.random(120, 125) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                }
            }
        }
    })
end)

RegisterNetEvent('drymoneyroll:menu', function()
    ListMenu:Show({
        main = {
            label = "Dry Wet Money Rolls",
            items = {
                {
                    label = "Dry 5 Money Rolls",
                    description = "Dry your Wet Money Rolls. You need 5 Wet Rolls.",
                    data = {
                        amount = 5,
                        type = "dry",
                        progress = "Drying wetcash",
                        anim = "mechanic",
                        duration = math.random(12, 15) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Dry 10 Money Rolls",
                    description = "Dry your Wet Money Rolls. You need 10 Wet Rolls.",
                    data = {
                        amount = 10,
                        type = "dry",
                        progress = "Drying wetcash",
                        anim = "mechanic",
                        duration = math.random(25, 29) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Dry 25 Money Rolls",
                    description = "Dry your Wet Money Rolls. You need 25 Wet Rolls.",
                    data = {
                        amount = 25,
                        type = "dry",
                        progress = "Drying wetcash",
                        anim = "mechanic",
                        duration = math.random(65, 70) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Dry 100 Money Rolls",
                    description = "Dry your Wet Money Rolls. You need 100 Wet Rolls.",
                    data = {
                        amount = 100,
                        type = "dry",
                        progress = "Drying wetcash",
                        anim = "mechanic",
                        duration = math.random(120, 125) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                }
            }
        }
    })
end)

RegisterNetEvent('moneyband:menu', function()
    ListMenu:Show({
        main = {
            label = "Wash Money Bands",
            items = {
                {
                    label = "Wash 5 Money Bands",
                    description = "Wash your Money Bands. You need 5 Bands.",
                    data = {
                        amount = 5,
                        type = "wash_band",
                        progress = "Washing bands",
                        anim = "kneel",
                        duration = math.random(12, 15) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Wash 10 Money Bands",
                    description = "Wash your Money Bands. You need 10 Bands.",
                    data = {
                        amount = 10,
                        type = "wash_band",
                        progress = "Washing bands",
                        anim = "kneel",
                        duration = math.random(25, 29) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Wash 25 Money Bands",
                    description = "Wash your Money Bands. You need 25 Bands.",
                    data = {
                        amount = 25,
                        type = "wash_band",
                        progress = "Washing bands",
                        anim = "kneel",
                        duration = math.random(65, 70) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Wash 100 Money Bands",
                    description = "Wash your Money Bands. You need 100 Bands.",
                    data = {
                        amount = 100,
                        type = "wash_band",
                        progress = "Washing bands",
                        anim = "kneel",
                        duration = math.random(120, 125) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                }
            }
        }
    })
end)

RegisterNetEvent('drymoneyband:menu', function()
    ListMenu:Show({
        main = {
            label = "Dry Wet Money Bands",
            items = {
                {
                    label = "Dry 5 Money Bands",
                    description = "Dry your Wet Money Bands. You need 5 Wet Bands.",
                    data = {
                        amount = 5,
                        type = "dry_band",
                        progress = "Drying bands",
                        anim = "mechanic",
                        duration = math.random(12, 15) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Dry 10 Money Bands",
                    description = "Dry your Wet Money Bands. You need 10 Wet Bands.",
                    data = {
                        amount = 10,
                        type = "dry_band",
                        progress = "Drying bands",
                        anim = "mechanic",
                        duration = math.random(25, 29) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Dry 25 Money Bands",
                    description = "Dry your Wet Money Bands. You need 25 Wet Bands.",
                    data = {
                        amount = 25,
                        type = "dry_band",
                        progress = "Drying bands",
                        anim = "mechanic",
                        duration = math.random(65, 70) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                },
                {
                    label = "Dry 100 Money Bands",
                    description = "Dry your Wet Money Bands. You need 100 Wet Bands.",
                    data = {
                        amount = 100,
                        type = "dry_band",
                        progress = "Drying bands",
                        anim = "mechanic",
                        duration = math.random(120, 125) * 1000,
                    },
                    event = "lumen:client:checkandwash"
                }
            }
        }
    })
end)


RegisterNetEvent('lumen:client:checkandwash')
AddEventHandler('lumen:client:checkandwash', function(data)
    local hasItem = false

    if data.type == "wash" then
        hasItem = Inventory.Check.Player:HasItem("moneyroll", data.amount)
    elseif data.type == "dry" then
        hasItem = Inventory.Check.Player:HasItem("wetcash", data.amount)
    elseif data.type == "wash_band" then
        hasItem = Inventory.Check.Player:HasItem("moneyband", data.amount)
    elseif data.type == "dry_band" then
        hasItem = Inventory.Check.Player:HasItem("wetcash2", data.amount)
    end

    if hasItem then
        Progress:Progress({
            name = "money-wash",
            duration = data.duration,
            label = data.progress,
            useWhileDead = false,
            canCancel = true,
            vehicle = false,
            animation = {
                anim = data.anim,
            },
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableCombat = true,
            },
        }, function(cancelled)
            if not cancelled then
                TriggerServerEvent("lumen:server:giveMwItem", data)
            end
        end)
    else
        Notification:Error("You need at least " .. data.amount .. " to continue.")
    end
end)