local isfile = isfile or function(file)
    local suc, res = pcall(function()
        return readfile(file)
    end)
    return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
    writefile(file, '')
end

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

local function wipeFolder(path)
    if not isfolder(path) then return end
    for _, file in listfiles(path) do
        if file:find('loader') then continue end
        if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after oofer updates.')) == 1 then
            delfile(file)
        end
    end
end

for _, folder in {'oofer', 'oofer/games', 'oofer/profiles', 'oofer/assets', 'oofer/libraries', 'oofer/guis'} do
    if not isfolder(folder) then
        makefolder(folder)
    end
end

if not shared.ooferDeveloper then
    local _, subbed = pcall(function()
        return game:HttpGet('https://github.com/ooferowner/oofer')
    end)
    local commit = subbed:find('currentOid')
    commit = commit and subbed:sub(commit + 13, commit + 52) or nil
    commit = commit and #commit == 40 and commit or 'main'
    if commit == 'main' or (isfile('oofer/profiles/commit.txt') and readfile('oofer/profiles/commit.txt') or '') ~= commit then
        wipeFolder('oofer')
        wipeFolder('oofer/games')
        wipeFolder('oofer/guis')
        wipeFolder('oofer/libraries')
    end
    writefile('oofer/profiles/commit.txt', commit)
end

return loadstring(downloadFile('oofer/main.lua'), 'main')()
