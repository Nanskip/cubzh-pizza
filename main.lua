Config = {
    Map = nil,
    Items = {
        "voxels.oak_floor", "voxels.toxic_barrel", "voxels.pezh_coin",
        "nanskip.joystick", "nanskip.joystick_stick",
    }
}

function Client.OnStart()
    _DEBUG = true
    _HASH = "25c209b"
    _LATEST_LINK = "https://raw.githubusercontent.com/Nanskip/cubzh-pizza/" .. _HASH .. "/"
    _LOGS = {}

    _DOWNLOAD_DATA()
end

log = function(text, type)
    if _DEBUG == true then
        if type == nil then
            type = "DEFAULT"
        end
        local timeStamp = os.date("[%H:%M:%S]")
        local log_text = timeStamp .. ": " .. "EMPTY LOG."
        if type == "DEFAULT" then
            log_text = timeStamp .. ": " .. text
        elseif type == "INIT" then
            log_text = timeStamp .. ": " .. "Module [" .. text .. ".lua] initialized."
        elseif type == "ERROR" then
            log_text = timeStamp .. ": " .. "ERROR: ".. text
        end

        print(log_text)
        _LOGS[#_LOGS+1] = log_text
    end
end

function _DOWNLOAD_DATA()
    local data = {
        _TEST = "data/test.lua",
    }
    local downloaded = 0
    log("Need to download " .. tableLength(data) .. " data files.")

    for k, v in pairs(data) do
        HTTP:Get(_LATEST_LINK .. v, function(response)
            if response.StatusCode ~= 200 then
                print("Error downloading " .. k .. ". Code: " .. response.StatusCode)

                return
            end

            _ENV[k] = load(response.Body:ToString(), nil, "bt", _ENV)()
            downloaded = downloaded + 1

            if downloaded == tableLength(data) then
                log("Downloaded all required data.")
                _DOWNLOAD_MODULES()
            end
        end)
    end
end

function _DOWNLOAD_MODULES()
    local modules = {
        save = "modules/save.lua",
        map = "modules/map.lua",
        player = "modules/player.lua",
        joysticks = "modules/joysticks.lua",
    }
    local downloaded = 0
    log("Need to download " .. tableLength(modules) .. " modules files.")

    for k, v in pairs(modules) do
        HTTP:Get(_LATEST_LINK .. v, function(response)
            if response.StatusCode ~= 200 then
                print("Error downloading " .. k .. ". Code: " .. response.StatusCode)

                return
            end

            _ENV[k] = load(response.Body:ToString(), nil, "bt", _ENV)()
            if _ENV[k].INIT ~= nil then
                local initialized = _ENV[k]:INIT()
                if initialized then
                    log(k, "INIT")
                else
                    log("Module [" .. k .. ".lua] initialization error.", "ERROR")
                end
            end

            downloaded = downloaded + 1
            if downloaded == tableLength(modules) then
                log("Downloaded all required modules.")
            end
        end)
    end
end

function tableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function lerp(a,b,t)
    return a * (1-t) + b * t
end

function easeOutBack(start, end_, percentage)
    local c1 = 1.70158
    local c3 = c1 + 1
    local x = percentage / 100

    local easedValue = 1 + c3 * ((x - 1)^3) + c1 * ((x - 1)^2)
    
    return start + (end_ - start) * easedValue
end