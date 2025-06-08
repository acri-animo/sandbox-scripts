function RegisterChatCommands()
    Chat:RegisterAdminCommand("boostingevent", function(source, args, rawCommand)
        if _boostingEvent then
            _boostingEvent = false
            Chat.Send.System:Single(source, "Boosting Event Disabled")
        else
            _boostingEvent = true
            Chat.Send.System:Single(source, "Boosting Event Enabled")
        end
	end, {
		help = "[Admin] Toggle Boosting Event Mode",
	}, 0)

    Chat:RegisterAdminCommand("boostingevent2", function(source, args, rawCommand)
        local char = Fetch:SID(tonumber(args[1]))
        if char then
            local profiles = char:GetData("Profiles")
            if profiles?.redline then
                Chat.Send.System:Single(source, string.format("%s %s (%s) - Alias %s", char:GetData("First"), char:GetData("Last"), char:GetData("SID"), profiles.redline.name))
            end
        end
	end, {
		help = "[Admin] Get Racing Alias",
        params = {
			{
				name = "SID",
				help = "SID",
			},
		}
	}, 1)

    Chat:RegisterAdminCommand('addlaptopapp', function(src, args, raw)
        local appName = args[1]
        if not appName then
            return Chat.Send.System:Single(src, "Usage: /addlaptopapp [appName]")
        end
    
        local char = Fetch:CharacterSource(src)
        if not char then
            return Chat.Send.System:Single(src, "Character not found.")
        end
    
        local laptopApps = char:GetData("LaptopApps") or { installed = {}, home = {} }
    
        local alreadyInstalled = TableContains(laptopApps.installed, appName)
        if alreadyInstalled then
            return Chat.Send.System:Single(src, ("App '%s' is already installed."):format(appName))
        end
    
        table.insert(laptopApps.installed, appName)
        table.insert(laptopApps.home, appName)
        char:SetData("LaptopApps", laptopApps)
    
        Chat.Send.System:Single(src, ("App '%s' has been added to your laptop."):format(appName))

    end, {
        help = 'Add a laptop app to your character',
        params = {
            { name = 'appName', help = 'The app name to add (e.g. terminal, notes, darkweb, etc)' },
        }
    }, 1)
end
