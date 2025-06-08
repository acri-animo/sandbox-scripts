Materials = {
	[581794674] = { groundType = "normal" },
	[-2041329971] = { groundType = "normal" },
	[-309121453] = { groundType = "normal" },
	[-913351839] = { groundType = "normal" },
	[-1885547121] = { groundType = "normal" },
	[-1915425863] = { groundType = "normal" },
	[-1833527165] = { groundType = "normal" },
	[2128369009] = { groundType = "normal" },
	[-124769592] = { groundType = "normal" },
	[-840216541] = { groundType = "normal" },
	[-461750719] = { groundType = "grass" },
	[930824497] = { groundType = "grass" },
	[1333033863] = { groundType = "grocks" },
	[223086562] = { groundType = "wet" },
	[1109728704] = { groundType = "wet" },
	[-1286696947] = { groundType = "mgrass" },
	[-1942898710] = { groundType = "grocks" },
	[509508168] = { groundType = "sand" },
	[-2073312001] = { groundType = "unk1" },
	[627123000] = { groundType = "unk1" },
	[-1595148316] = { groundType = "unk2" },
	[435688960] = { groundType = "unk3" },
}

Plants = {
	reggie = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_natur_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_natur_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_natur_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_natur_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	greencrack = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_green_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_green_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_green_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_green_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	bluedream = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_blue_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_blue_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_blue_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_blue_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	bluekush = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_cyan_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_cyan_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_cyan_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_cyan_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	granddaddy = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_maroon_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_maroon_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_maroon_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_maroon_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	bluehaze = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_navy_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_navy_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_navy_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_navy_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	purpdream = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_purple_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_purple_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_purple_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_purple_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	cherrypie = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_red_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_red_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_red_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_red_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	gelatopurp = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_romance_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_romance_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_romance_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_romance_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	gscookies = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_sea_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_sea_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_sea_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_sea_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	sourdiesel = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_sunny_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_sunny_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_sunny_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_sunny_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
	gorillaglue = {
		{
			model = GetHashKey("bzzz_plant_weed_pot_yellow_a"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_yellow_b"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_yellow_c"),
			offset = 0.0,
			harvestable = false,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
		{
			model = GetHashKey("bzzz_plant_weed_pot_yellow_d"),
			offset = 0.0,
			harvestable = true,
			targeting = {
				{
					icon = "magnifying-glass",
					text = "Check",
					event = "Weed:Client:Check",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "sack",
					text = "Harvest",
					event = "Weed:Client:Harvest",
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
				{
					icon = "hand-scissors",
					text = "Destroy Plant",
					event = "Weed:Client:PDDestroy",
					jobPerms = {
						{
							job = "police",
							reqDuty = true,
						}
					},
					data = {},
					isEnabled = function(data, entity)
						return GetWeedPlant(entity.entity)
					end,
				},
			},
		},
	},
}
