function defaultApps()
	-- local defApps = {}
	-- for k, v in pairs(LAPTOP_APPS) do
	-- 	if not v.canUninstall then
	-- 		table.insert(defApps, v.name)
	-- 	end
	-- end
	-- return {
	-- 	installed = defApps,
	-- 	home = defApps,
	-- }

	return {
		installed = {
			"recyclebin",
			"settings",
			"files",
			"internet",
			"bizwiz",
			"teams",
			"lsunderground",
			"gangs",
			"terminal",
			"redline"
		},
		home = {
			"recyclebin",
			"settings",
			"files",
			"internet",
			"bizwiz",
			"teams",
			"lsunderground",
			"gangs",
			"terminal",
			"redline"
		},
	}
end

function hasValue(tbl, value)
	for k, v in ipairs(tbl) do
		if v == value or (type(v) == "table" and hasValue(v, value)) then
			return true
		end
	end
	return false
end

function table.copy(t)
	local u = {}
	for k, v in pairs(t) do
		u[k] = v
	end
	return setmetatable(u, getmetatable(t))
end

function defaultSettings()
	return {
		wallpaper = "wallpaper",
		texttone = "notification.ogg",
		colors = {
			accent = "#3e919c",
		},
		zoom = 75,
		volume = 100,
		notifications = true,
		appNotifications = {},
	}
end

local defaultPermissions = {
	redline = {
		create = false,
	},
	lsunderground = {
		admin = false,
	},
}

local usbItems = {
	redline = "racing_usb",
	lsunderground = "lsundg_usb",
	gangs = "gangs_usb",
}

AddEventHandler("onResourceStart", function(resource)
	if resource == GetCurrentResourceName() then
		TriggerClientEvent("Laptop:Client:SetApps", -1, LAPTOP_APPS)
	end
end)

AddEventHandler("Laptop:Shared:DependencyUpdate", RetrieveComponents)

function RetrieveComponents()
	Fetch = exports["lumen-base"]:FetchComponent("Fetch")
	Database = exports["lumen-base"]:FetchComponent("Database")
	Callbacks = exports["lumen-base"]:FetchComponent("Callbacks")
	Logger = exports["lumen-base"]:FetchComponent("Logger")
	Utils = exports["lumen-base"]:FetchComponent("Utils")
	Chat = exports["lumen-base"]:FetchComponent("Chat")
	Middleware = exports["lumen-base"]:FetchComponent("Middleware")
	Execute = exports["lumen-base"]:FetchComponent("Execute")
	Config = exports["lumen-base"]:FetchComponent("Config")
	MDT = exports["lumen-base"]:FetchComponent("MDT")
	Jobs = exports["lumen-base"]:FetchComponent("Jobs")
	Labor = exports["lumen-base"]:FetchComponent("Labor")
	Crypto = exports["lumen-base"]:FetchComponent("Crypto")
	VOIP = exports["lumen-base"]:FetchComponent("VOIP")
	Generator = exports["lumen-base"]:FetchComponent("Generator")
	Properties = exports["lumen-base"]:FetchComponent("Properties")
	Vehicles = exports["lumen-base"]:FetchComponent("Vehicles")
	Inventory = exports["lumen-base"]:FetchComponent("Inventory")
	Loot = exports["lumen-base"]:FetchComponent("Loot")
	Loans = exports["lumen-base"]:FetchComponent("Loans")
	Billing = exports["lumen-base"]:FetchComponent("Billing")
	Banking = exports["lumen-base"]:FetchComponent("Banking")
	Reputation = exports["lumen-base"]:FetchComponent("Reputation")
	Robbery = exports["lumen-base"]:FetchComponent("Robbery")
	Wallet = exports["lumen-base"]:FetchComponent("Wallet")
	Sequence = exports["lumen-base"]:FetchComponent("Sequence")
	Phone = exports["lumen-base"]:FetchComponent("Phone")
	Laptop = exports["lumen-base"]:FetchComponent("Laptop")
	Vendor = exports["lumen-base"]:FetchComponent("Vendor")
	RegisterChatCommands()
end

AddEventHandler("Core:Shared:Ready", function()
	exports["lumen-base"]:RequestDependencies("Laptop", {
		"Fetch",
		"Database",
		"Callbacks",
		"Logger",
		"Utils",
		"Chat",
		"Laptop",
		"Middleware",
		"Execute",
		"Config",
		"MDT",
		"Jobs",
		"Labor",
		"Crypto",
		"VOIP",
		"Generator",
		"Properties",
		"Vehicles",
		"Inventory",
		"Loot",
		"Loans",
		"Billing",
		"Banking",
		"Reputation",
		"Robbery",
		"Wallet",
		"Sequence",
		"Phone",
		"Vendor",
	}, function(error)
		if #error > 0 then
			return
		end
		-- Do something to handle if not all dependencies loaded
		RetrieveComponents()
		Startup()
		TriggerEvent("Laptop:Server:RegisterMiddleware")
		TriggerEvent("Laptop:Server:RegisterCallbacks")

		Inventory.Items:RegisterUse("laptop", "Laptop", function(source, itemData)
			TriggerClientEvent("Laptop:Client:Open", source)
		end)

		Reputation:Create("Chopping", "Vehicle Chopping", {
			{ label = "Rank 1", value = 1000 },
			{ label = "Rank 2", value = 2500 },
			{ label = "Rank 3", value = 5000 },
			{ label = "Rank 4", value = 10000 },
			{ label = "Rank 5", value = 25000 },
			{ label = "Rank 6", value = 50000 },
			{ label = "Rank 7", value = 100000 },
			{ label = "Rank 8", value = 250000 },
			{ label = "Rank 9", value = 500000 },
			{ label = "Rank 10", value = 1000000 },
		}, true)

		Reputation:Create("Boosting", "Boosting", {
			{ label = "D", value = 0 },
			{ label = "C", value = 6000 },
			{ label = "B", value = 15000 },
			{ label = "A", value = 50000 },
			{ label = "A+", value = 120000 }, -- Get Scratching
			{ label = "S+", value = 150000 },
		}, true)
	end)
end)

AddEventHandler("Laptop:Server:RegisterMiddleware", function()
	Middleware:Add("Characters:Spawning", function(source)
		Laptop:UpdateJobData(source)
		TriggerClientEvent("Laptop:Client:SetApps", source, LAPTOP_APPS)

		local char = Fetch:CharacterSource(source)
		local myPerms = char:GetData("LaptopPermissions") or {}
		local modified = false
		for app, perms in pairs(defaultPermissions) do
			if myPerms[app] == nil then
				myPerms[app] = perms
				modified = true
			else
				for perm, state in pairs(perms) do
					if myPerms[app][perm] == nil then
						myPerms[app][perm] = state
						modified = true
					end
				end
			end
		end

		if modified then
			char:SetData("LaptopPermissions", myPerms)
		end

		if not char:GetData("LaptopSettings") then
			char:SetData("LaptopSettings", defaultSettings())
		end

		if not char:GetData("LaptopApps") then
			char:SetData("LaptopApps", defaultApps())
		end
		local laptopApps = char:GetData("LaptopApps") or defaultApps()
		--To enable terminal app.
        --[[ if not TableContains(laptopApps.installed, "terminal") then
            table.insert(laptopApps.installed, "terminal")
            table.insert(laptopApps.home, "terminal")
            char:SetData("LaptopApps", laptopApps)
        end ]]
        if not TableContains(laptopApps.installed, "heists") then
            table.insert(laptopApps.installed, "heists")
            table.insert(laptopApps.home, "heists")
            char:SetData("LaptopApps", laptopApps)
        end
        if not TableContains(laptopApps.installed, "battlepass") then
            table.insert(laptopApps.installed, "battlepass")
            table.insert(laptopApps.home, "battlepass")
            char:SetData("LaptopApps", laptopApps)
        end
	end, 1)
	Middleware:Add("Laptop:UIReset", function(source)
		Laptop:UpdateJobData(source)
		TriggerClientEvent("Laptop:Client:SetApps", source, LAPTOP_APPS)
	end)
	Middleware:Add("Characters:Creating", function(source, cData)
		local t = Middleware:TriggerEventWithData("Laptop:CharacterCreated", source, cData)

		return {
			{
				LaptopApps = defaultApps(),
				LaptopSettings = defaultSettings(),
				LaptopPermissions = defaultPermissions,
			},
		}
	end)
end)

RegisterNetEvent("Laptop:Server:UIReset", function()
	Middleware:TriggerEvent("Laptop:UIReset", source)
end)

AddEventHandler("Laptop:Server:RegisterCallbacks", function()
	Callbacks:RegisterServerCallback("Laptop:Permissions", function(src, data, cb)
		local char = Fetch:CharacterSource(src)

		if char ~= nil then
			local perms = char:GetData("LaptopPermissions")

			for k, v in pairs(data) do
				for k2, v2 in ipairs(v) do
					if not perms[k][v2] then
						cb(false)
						return
					end
				end
			end
			cb(true)
		else
			cb(false)
		end
	end)

	Callbacks:RegisterServerCallback("Laptop:RaceCreatorPerm", function(src, data, cb)
		local char = Fetch:CharacterSource(src)
	
		if char ~= nil then
			local laptopPerms = char:GetData("LaptopPermissions")
			print(json.encode(laptopPerms))
			local redlineCreate = laptopPerms.redline.create
			print(redlineCreate)

			if redlineCreate then
				cb({ success = true})
			else
				cb(false)
			end
		end
	end)

	Callbacks:RegisterServerCallback("Laptop:Server:InstallApp", function(src, data, cb)
		local char = Fetch:CharacterSource(src)
		local sid = char:GetData("SID")
		if not char or not data or not data.app then
			cb(false)
			return
		end
	
		local laptopApps = char:GetData("LaptopApps") or { installed = {}, home = {} }
		local app = data.app
	
		if TableContains(laptopApps.installed, app) or TableContains(laptopApps.home, app) then
			cb(false)
			return
		end
	
		table.insert(laptopApps.installed, app)
		table.insert(laptopApps.home, app)
	
		char:SetData("LaptopApps", laptopApps)

		Inventory.Items:Remove(sid, 1, usbItems[app], 1)
		cb(true)
	end)

	Callbacks:RegisterServerCallback("Laptop:UpdateProfile", function(src, data, cb)
		local char = Fetch:CharacterSource(src)
		if char ~= nil then
			local sid = char:GetData("SID")
			local profiles = char:GetData("Profiles") or {}
			if profiles[data.app] ~= nil then
				MySQL.insert("INSERT INTO app_profile_history (sid, app, name, picture, meta) VALUES(?, ?, ?, ?, ?)", {
					char:GetData("SID"),
					data.app,
					profiles[data.app].name,
					profiles[data.app].picture,
					json.encode(profiles[data.app].meta),
				})
			end

			local count = MySQL.scalar.await("SELECT COUNT(*) FROM character_app_profiles WHERE app = ? AND name = ? AND sid != ?", {
				data.app,
				data.name,
				sid
			})

			if count == 0 then
				MySQL.prepare.await(
					"INSERT INTO character_app_profiles (sid, app, name, picture, meta) VALUES(?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name), picture = VALUES(picture), meta = VALUES(meta)",
					{
						char:GetData("SID"),
						data.app,
						data.name,
						data.picture,
						json.encode(data.meta or {}),
					}
				)
	
				profiles[data.app] = {
					sid = char:GetData("SID"),
					app = data.app,
					name = data.name,
					picture = data.picture,
					meta = data.meta or {},
				}
				char:SetData("Profiles", profiles)

				--TriggerEvent("Phone:Server:UpdateProfile", src, data)
				cb(true)
			else
				Execute:Client(src, "Notification", "Error", "Alias already in use")
				cb(false)
			end
		else
			cb(false)
		end
	end)
end)


function TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end