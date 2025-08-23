repeat task.wait() until game:IsLoaded()

if shared.oofer then
    pcall(function() shared.oofer:Uninject() end)
end

local request = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
local function webget(url)
    local res = request({Url = url, Method = "GET"})
    return res and res.Body or ""
end

local watermark = "--oofer_autogen"

local function isfile(path)
    local ok = pcall(function() return readfile(path) end)
    return ok
end
local function makefolder_safe(path)
    if not isfolder(path) then makefolder(path) end
end
local function downloadFile(path, url)
    if not isfile(path) then
        local body = webget(url)
        writefile(path, watermark .. "\n" .. body)
    end
    return readfile(path)
end

-- Ensure folder tree
makefolder_safe("oofer")
makefolder_safe("oofer/games")
makefolder_safe("oofer/assets")
makefolder_safe("oofer/libraries")
makefolder_safe("oofer/guis")

-- Always pull latest main.lua from main branch
local mainUrl = "https://raw.githubusercontent.com/ooferowner/oofer/main/main.lua"
local mainCode = downloadFile("oofer/main.lua", mainUrl)

shared.oofer = {}
loadstring(mainCode, "oofer_main")()
