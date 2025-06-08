local _ran = false

function Startup()
    if _ran then
        return
    end
    _ran = true
    LAPTOP_APPS = {}

    local excludedApps = {
		["redline"] = true, 
		["lsunderground"] = true,
		["gangs"] = true
	}
    
    for k, v in ipairs(_appData) do
        if not excludedApps[v.name] then
            LAPTOP_APPS[v.name] = v
        end
    end
end

_appData = {
    {
        name = "lsunderground",
        storeLabel = "UNDG",
        label = "UNDG",
        icon = "user-secret",
        color = "#E95200",
        params = ":tab?",
        hidden = false,
        canUninstall = true,
        store = true,
        unread = 0,
        restricted = {
            state = {"ACCESS_LSUNDERGROUND", "PHONE_VPN", "RACE_DONGLE"},
        },
    },
    {
        name = "teams",
        storeLabel = "Teams",
        label = "Teams",
        icon = "people-group",
        color = "#00FF8A",
        --params = ":tab?",
        hidden = false,
        canUninstall = true,
        store = true,
        unread = 0,
    },
    {
        name = "bizwiz",
        storeLabel = "BizWiz",
        label = "BizWiz",
        icon = "business-time",
        color = "#135dd8",
        --params = ":tab?",
        hidden = false,
        canUninstall = true,
        store = true,
        unread = 0,
    },
    {
        name = "settings",
        storeLabel = "Settings",
        label = "Settings",
        icon = "gear",
        color = "#18191e",
        params = "",
        canUninstall = false,
        store = true,
        unread = 0,
        requirements = {},
    },
    {
        name = "files",
        storeLabel = "Files",
        label = "Files",
        icon = "folder-open",
        color = "#D8A71E",
        params = "",
        canUninstall = false,
        store = true,
        unread = 0,
        requirements = {},
        fake = true,
    },
    {
        name = "terminal",
        storeLabel = "Terminal",
        label = "Terminal",
        icon = "terminal",
        color = "#000000",
        params = "",
        canUninstall = false,
        store = true,
        unread = 0,
        size = {width = 600, height = 400},
        requirements = {},
    },
	{
        name = "gangs",
        storeLabel = "Gangs",
        label = "Gangs",
        icon = "user-group-crown",
        color = "#9d1614",
        -- params = "",
        canUninstall = false,
        store = true,
        unread = 0,
        requirements = {},
    },
    {
        name = "redline",
        storeLabel = "Redline",
        label = "Redline",
        icon = "flag-checkered",
        color = "#8685EF",
        -- params = "",
        canUninstall = false,
        store = true,
        unread = 0,
        restricted = {
            state = {"PHONE_VPN", "RACE_DONGLE"},
        },
    },
}