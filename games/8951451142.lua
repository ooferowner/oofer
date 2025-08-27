local oofer = shared.oofer

local loadstring = function(...)
	local res, err = loadstring(...)
	if err and oofer then
		oofer:CreateNotification("Oofer", "Failed to load : " .. err, 30, "alert")
	end
	return res
end

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ""
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet("https://raw.githubusercontent.com/ooferowner/oofer/" .. readfile("oofer/profiles/commit.txt") .. "/" .. select(1, path:gsub("oofer/", "")), true)
		end)
		if not suc or res == "404: Not Found" then
			error(res)
		end
		if path:find(".lua") then
			res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after oofer updates.\n" .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

oofer.Place = 8768229691

if isfile("oofer/games/" .. oofer.Place .. ".lua") then
	loadstring(readfile("oofer/games/" .. oofer.Place .. ".lua"), "skywars")()
else
	if not shared.OoferDeveloper then
		local suc, res = pcall(function()
			return game:HttpGet("https://raw.githubusercontent.com/ooferowner/oofer/" .. readfile("oofer/profiles/commit.txt") .. "/games/" .. oofer.Place .. ".lua", true)
		end)
		if suc and res ~= "404: Not Found" then
			loadstring(downloadFile("oofer/games/" .. oofer.Place .. ".lua"), "skywars")()
		end
	end
end
