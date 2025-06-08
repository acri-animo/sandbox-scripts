_bigPharmDoors = {
	{
		coords = vector3(-3163.127, 1093.620, 20.927),
		heading = 153.938,
		door = "bigpharm_1",
		requiredDoors = {
			"bigpharm_entryright",
		},
	},
	{
		coords = vector3(-3165.355, 1093.158, 20.927),
		heading = 65.436,
		door = "bigpharm_2",
		requiredDoors = {
			"bigpharm_entryright",
			"bigpharm_1",
		},
	},
	{
		coords = vector3(-3168.878, 1092.855, 20.927),
		heading = 66.431,
		door = "bigpharm_3",
		requiredDoors = {
			--"bigpharm_entryright",
			--"bigpharm_1",
			--"bigpharm_2",
			--"bigpharm_lootboi",
		},
	},
}

_bigPharmEntryDoor = {
	{
		coords = vector3(-3158.3344726562, 1096.78405, 20.874956),
		heading = 246.18673706055,
		door = "bigpharm_entryright",
		requiredDoors = {},
	},
}

_bigPharmLootDoor = {
	{
		coords = vector3(-3165.3720703125, 1099.84667, 20.926722),
		heading = 336.58117675781,
		door = "bigpharm_lootboi",
		requiredDoors = {
			"bigpharm_entryright",
			"bigpharm_1",
			"bigpharm_2",
		},
	},
}


_bigPharmHacks = {
	{
		coords = vector3(-3164.820, 1098.506, 20.927),
		heading = 337.742,
		requiredDoors = {
			"bigpharm_1",
			"bigpharm_2",
		},
		doorId = 1,
		doorConfig = {
			object = `v_ilev_cd_entrydoor`,
			step = 0.8,
			originalHeading = 56.732730865479,
		},
		config = {
			countdown = 3,
			timer = { 1700, 2400 },
			limit = 20000,
			difficulty = 2,
			chances = 6,
			isShuffled = false,
			anim = false,
		},
	},
}

_bigPharmDesks = {
	{
		coords = vector3(-3163.47, 1096.41, 20.93),
		length = 0.8,
		width = 0.8,
		options = {
			heading = 337,
			--debugPoly = true,
			minZ = 17.88,
			maxZ = 21.88,
		},
		data = {
			deskId = 1,
		},
	},
}

_bigPharmElectric = {
	{
		isThermite = false,
		coords = vector3(-3167.49, 1097.28, 20.79),
		length = 0.8,
		width = 1.2,
		options = {
			heading = 336,
			--debugPoly = true,
			minZ = 17.69,
			maxZ = 21.69,
		},
		data = {
			boxId = 1,
			ptFxPoint = vector3(-3167.49, 1097.28, 20.79),
		},
	},
	{
		isThermite = true,
		coords = vector3(-3162.72, 1093.6, 20.93),
		length = 0.6,
		width = 1.3,
		options = {
			heading = 336,
			--debugPoly = true,
			minZ = 18.23,
			maxZ = 22.23,
		},
		data = {
			boxId = 2,
			thermitePoint = {
				coords = vector3(-3160.216, 1089.388, 20.855),
				heading = 66.564,
			},
			ptFxPoint = vector3(-3162.72, 1093.6, 20.93),
		},
	},
}

_bigPharmShelves = {
	{
		coords = vector3(-3157.34, 1100.08, 20.93),
		length = 0.25,
		width = 1.4,
		options = {
			heading = 67,
			--debugPoly = true,
			minZ = 17.78,
			maxZ = 21.78,
		},
	},
	{
		coords = vector3(-3158.29, 1100.48, 20.93),
		length = 0.25,
		width = 1.4,
		options = {
			heading = 66,
			--debugPoly = true,
			minZ = 17.73,
			maxZ = 21.73,
		},
	},
	{
		coords = vector3(-3159.52, 1101.04, 20.93),
		length = 0.25,
		width = 1.4,
		options = {
			heading = 66,
			--debugPoly = true,
			minZ = 17.73,
			maxZ = 21.73,
		},
	},
	{
		coords = vector3(-3160.51, 1101.44, 20.93),
		length = 0.25,
		width = 1.4,
		options = {
			heading = 66,
			--debugPoly = true,
			minZ = 17.83,
			maxZ = 21.83,
		},
	},
}


_bigPharmLoot = {
	{ 
		coords = vector3(-3163.36, 1102.76, 20.93), 
		length = 1.0, 
		width = 1.0, 
		options = { 
			heading = 337, 
			--debugPoly = true, 
			minZ = 17.63, 
			maxZ = 21.63 
		}
	},
	{ 
		coords = vector3(-3162.27, 1101.13, 20.93), 
		length = 1.4, 
		width = 0.5, 
		options = { 
			heading = 336, 
			--debugPoly = true, 
			minZ = 18.03, 
			maxZ = 22.03 
		}
	},
}