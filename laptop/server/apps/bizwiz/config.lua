_businessNotices = {}

_bizWizTypes = {
	default = {
		{
			id = "Dashboard",
			icon = { "fas", "house" },
			label = "Dashboard",
		},
		{
			id = "Search/Document",
			icon = { "fas", "file-lines" },
			label = "Documents",
			permission = "TABLET_VIEW_DOCUMENT",
		},
		{
			id = "View/Document",
			hidden = true,
		},
		{
			id = "View/Receipt",
			hidden = true,
		},

		{
			id = "Create/Document",
			hidden = true,
		},
		{
			id = "Create/Notice",
			hidden = true,
		},
		{
			id = "Create/Receipt",
			icon = { "fas", "money-check-dollar" },
			label = "Create Receipt",
		},
		{
			id = "Search/Receipt",
			icon = { "fas", "money-check-dollar" },
			label = "Receipts",
		},
		{
			id = "Search/ReceiptCount",
			icon = { "fas", "money-check-dollar" },
			label = "Receipts Count",
			permission = "TABLET_MANAGE_RECEIPT",
		},
		{
			id = "Tweet",
			icon = { "fas", "face-awesome" },
			label = "Business Spammer",
			permission = "TABLET_TWEET",
		},
		{
			id = "TweetSettings",
			icon = { "fas", "face-awesome" },
			label = "Spammer Profile",
			permission = "JOB_MANAGEMENT",
		},
		{
			id = "FleetManagement",
			icon = { "fas", "cars" },
			label = "Fleet Management",
			permission = "FLEET_MANAGEMENT",
		},
		{
			id = "Create/Pos",
			icon = {"fas", "shop"},
			label = "POS Management",
			permission = "TABLET_CREATE_POS",
		},
	},
	mechanic = {
		{
			id = "Dashboard",
			icon = { "fas", "house" },
			label = "Dashboard",
		},
		{
			id = "Search/Document",
			icon = { "fas", "file-lines" },
			label = "Documents",
			permission = "TABLET_VIEW_DOCUMENT",
		},
		{
			id = "View/Document",
			hidden = true,
		},
		{
			id = "View/Receipt",
			hidden = true,
		},

		{
			id = "Create/Document",
			hidden = true,
		},
		{
			id = "Create/Notice",
			hidden = true,
		},
		{
			id = "Create/Receipt",
			hidden = true,
		},
		{
			id = "Search/Receipt",
			icon = { "fas", "money-check-dollar" },
			label = "Receipts",
		},
		{
			id = "Search/ReceiptCount",
			icon = { "fas", "money-check-dollar" },
			label = "Receipts Count",
			permission = "TABLET_MANAGE_RECEIPT",
		},
		{
			id = "Tweet",
			icon = { "fas", "face-awesome" },
			label = "Business Spammer",
			permission = "TABLET_TWEET",
		},
		{
			id = "TweetSettings",
			icon = { "fas", "face-awesome" },
			label = "Spammer Profile",
			permission = "JOB_MANAGEMENT",
		},
		{
			id = "FleetManagement",
			icon = { "fas", "cars" },
			label = "Fleet Management",
			permission = "FLEET_MANAGEMENT",
		},
		{
			id = "Create/Pos",
			icon = {"fas", "shop"},
			label = "POS Management",
			permission = "TABLET_CREATE_POS",
		},
	},
	dealerships = {
		{
			id = "Dashboard",
			icon = { "fas", "house" },
			label = "Dashboard",
		},
		{
			id = "Search/Document",
			icon = { "fas", "file-lines" },
			label = "Documents",
			permission = "TABLET_VIEW_DOCUMENT",
		},
		{
			id = "View/Document",
			hidden = true,
		},
		{
			id = "View/Receipt",
			hidden = true,
		},
		{
			id = "Create/Receipt",
			hidden = true,
		},
		{
			id = "Create/Document",
			hidden = true,
		},
		{
			id = "Create/Notice",
			hidden = true,
		},
		{
			id = "PDM/Sales",
			icon = { "fas", "cars" },
			label = "Vehicle Stock",
			permission = "dealership_sell",
		},
		{
			id = "PDM/Credit",
			icon = { "fas", "magnifying-glass-dollar" },
			label = "Run Credit Check",
			permission = "dealership_sell",
		},
		-- {
		-- 	name = 'pdm-licence-check',
		-- 	icon = {'fas', 'id-card'},
		-- 	label = 'Run License Check',
		-- 	path = '/business/search/documents',
		-- 	exact = true,
		-- 	permission = 'dealership_manage',
		-- },
		{
			id = "PDM/Manage",
			icon = { "fas", "list-check" },
			label = "Manage Dealership",
			permission = "JOB_MANAGEMENT",
		},
		{
			id = "PDM/SalesHistory",
			icon = { "fas", "clock-rotate-left" },
			label = "Sales History",
			permission = "dealership_manage",
		},
		{
			id = "Tweet",
			icon = { "fas", "face-awesome" },
			label = "Business Spammer",
			permission = "TABLET_TWEET",
		},
		{
			id = "TweetSettings",
			icon = { "fas", "face-awesome" },
			label = "Spammer Profile",
			permission = "JOB_MANAGEMENT",
		},
		{
			id = "FleetManagement",
			icon = { "fas", "cars" },
			label = "Fleet Management",
			permission = "FLEET_MANAGEMENT",
		},
	},
	dealership_mechanic = {
		{
			id = "Dashboard",
			icon = { "fas", "house" },
			label = "Dashboard",
		},
		{
			id = "Search/Document",
			icon = { "fas", "file-lines" },
			label = "Documents",
			permission = "TABLET_VIEW_DOCUMENT",
		},
		{
			id = "View/Document",
			hidden = true,
		},
		{
			id = "View/Receipt",
			hidden = true,
		},

		{
			id = "Create/Document",
			hidden = true,
		},
		{
			id = "Create/Notice",
			hidden = true,
		},
		{
			id = "Search/Receipt",
			icon = { "fas", "money-check-dollar" },
			label = "Receipts",
		},
		{
			id = "Search/ReceiptCount",
			icon = { "fas", "money-check-dollar" },
			label = "Receipts Count",
			permission = "TABLET_MANAGE_RECEIPT",
		},
		{
			id = "PDM/Sales",
			icon = { "fas", "cars" },
			label = "Vehicle Stock",
			permission = "dealership_sell",
		},
		{
			id = "PDM/Credit",
			icon = { "fas", "magnifying-glass-dollar" },
			label = "Run Credit Check",
			permission = "dealership_sell",
		},
		-- {
		-- 	name = 'pdm-licence-check',
		-- 	icon = {'fas', 'id-card'},
		-- 	label = 'Run License Check',
		-- 	path = '/business/search/documents',
		-- 	exact = true,
		-- 	permission = 'dealership_manage',
		-- },
		{
			id = "PDM/Manage",
			icon = { "fas", "list-check" },
			label = "Manage Dealership",
			permission = "dealership_manage",
		},
		{
			id = "PDM/SalesHistory",
			icon = { "fas", "clock-rotate-left" },
			label = "Sales History",
			permission = "dealership_manage",
		},
		{
			id = "Tweet",
			icon = { "fas", "face-awesome" },
			label = "Business Spammer",
			permission = "TABLET_TWEET",
		},
		{
			id = "TweetSettings",
			icon = { "fas", "face-awesome" },
			label = "Spammer Profile",
			permission = "JOB_MANAGEMENT",
		},
		{
			id = "FleetManagement",
			icon = { "fas", "cars" },
			label = "Fleet Management",
			permission = "FLEET_MANAGEMENT",
		},
		{
			id = "Create/Pos",
			icon = {"fas", "shop"},
			label = "POS Management",
			permission = "TABLET_CREATE_POS",
		},
	},
	realestate = {
		{
			id = "Dashboard",
			icon = { "fas", "house" },
			label = "Dashboard",
		},
		{
			id = "Search/Document",
			icon = { "fas", "file-lines" },
			label = "Documents",
			permission = "TABLET_VIEW_DOCUMENT",
		},
		{
			id = "View/Document",
			hidden = true,
		},
		{
			id = "View/Receipt",
			hidden = true,
		},

		{
			id = "Create/Document",
			hidden = true,
		},
		{
			id = "Create/Notice",
			hidden = true,
		},
		{
			id = "Dynasty/Credit",
			icon = { "fas", "magnifying-glass-dollar" },
			label = "Run Credit Check",
			permission = "JOB_SELL",
		},
		{
			id = "Dynasty/Properties",
			icon = { "fas", "house-building" },
			label = "Properties",
			permission = "JOB_SELL",
		},
		{
			id = "Tweet",
			icon = { "fas", "face-awesome" },
			label = "Business Spammer",
			permission = "TABLET_TWEET",
		},
		{
			id = "TweetSettings",
			icon = { "fas", "face-awesome" },
			label = "Spammer Profile",
			permission = "JOB_MANAGEMENT",
		},
		{
			id = "FleetManagement",
			icon = { "fas", "cars" },
			label = "Fleet Management",
			permission = "FLEET_MANAGEMENT",
		},
	},
	casino = {
		{
			id = "Dashboard",
			icon = { "fas", "house" },
			label = "Dashboard",
		},
		{
			id = "Search/Document",
			icon = { "fas", "file-lines" },
			label = "Documents",
			permission = "TABLET_VIEW_DOCUMENT",
		},
		{
			id = "View/Document",
			hidden = true,
		},
		{
			id = "View/Receipt",
			hidden = true,
		},

		{
			id = "Create/Document",
			hidden = true,
		},
		{
			id = "Create/Notice",
			hidden = true,
		},
		{
			id = "Create/Receipt",
			hidden = true,
		},
		{
			id = "Casino/BigWins",
			icon = { "fas", "cards" },
			label = "Big Wins",
			permission = "JOB_MANAGEMENT",
		},
		{
			id = "Tweet",
			icon = { "fas", "face-awesome" },
			label = "Business Spammer",
			permission = "TABLET_TWEET",
		},
		{
			id = "TweetSettings",
			icon = { "fas", "face-awesome" },
			label = "Spammer Profile",
			permission = "JOB_MANAGEMENT",
		},
		{
			id = "FleetManagement",
			icon = { "fas", "cars" },
			label = "Fleet Management",
			permission = "FLEET_MANAGEMENT",
		},
	},
}

_bizWizConfig = {
	pdm = {
		logo = "https://r2.fivemanage.com/OUbHFo51H4lC2VKIAsoov/PDM.png",
		type = "dealerships",
	},
	helmuts = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "dealership_mechanic",
	},
	ls_customs = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "mechanic",
	},
	hayes = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "mechanic",
	},
	realestate = {
		logo = "https://r2.fivemanage.com/OUbHFo51H4lC2VKIAsoov/DYNASTY.png",
		type = "realestate",
	},
	casino = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "casino",
	},
	cloud9 = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "default",
	},
	demonetti_storage = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "default",
	},
	vangelico = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "default",
	},
	al_dente = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "default",
	},
	burgershot = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "default",
	},
	bowling = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "default",
	},
	unicorn = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "default",
	},
	bahama = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "default",
	},
	pepega_pawn = {
		logo = "https://i.imgur.com/aSXFH3P.png",
		type = "default",
	},
}
