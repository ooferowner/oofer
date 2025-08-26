repeat task.wait() until game:IsLoaded()
if shared.oofer then shared.oofer:Uninject() end

-- ima just replace this all with my words :pray:
if identifyexecutor then
	if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local oofer
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and oofer then
		oofer:CreateNotification('Oofer', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/ooferowner/oofer/'..readfile('oofer/profiles/commit.txt')..'/'..select(1, path:gsub('oofer/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after oofer updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	oofer.Init = nil
	oofer:Load()
	task.spawn(function()
		repeat
			oofer:Save()
			task.wait(10)
		until not oofer.Loaded
	end)

	local teleportedServers
	oofer:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.ooferIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.ooferrreload = true
				if shared.ooferDeveloper then
					loadstring(readfile('oofer/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/ooferowner/oofer/'..readfile('oofer/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.ooferDeveloper then
				teleportScript = 'shared.ooferDeveloper = true\n'..teleportScript
			end
			if shared.ooferCustomProfile then
				teleportScript = 'shared.ooferCustomProfile = "'..shared.ooferCustomProfile..'"\n'..teleportScript
			end
			oofer:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.ooferrreload then
		if not oofer.Categories then return end
		if oofer.Categories.Main.Options['GUI bind indicator'].Enabled then
			oofer:CreateNotification('Finished Loading', oofer.OoferButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(oofer.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('oofer/profiles/gui.txt') then
	writefile('oofer/profiles/gui.txt', 'new')
end
local gui = readfile('oofer/profiles/gui.txt')

if not isfolder('oofer/assets/'..gui) then
	makefolder('oofer/assets/'..gui)
end
oofer = loadstring(downloadFile('oofer/guis/'..gui..'.lua'), 'gui')()
shared.oofer = oofer

if not shared.ooferIndependent then
	loadstring(downloadFile('oofer/games/universal.lua'), 'universal')()
	if isfile('oofer/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('oofer/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.ooferDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/ooferowner/oofer/'..readfile('oofer/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('oofer/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	oofer.Init = finishLoading
	return oofer
end
