---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MiraxxR.
--- Copyright (c) MiraxxR - All Rights Reserved
--- DateTime: 05/04/2023 04:20
---

local maintenanceMode = true
local maintenanceListening = nil -- "json_data" or nil
local maintenanceDiscord = 'https://discord.gg/wJmnKQHTWD'
local maintenanceWhitelist = {
    "license:"
}

local function _print(text)
    print("^3Fivem-maintenance:^7 "..text)
end

local _tbl_playerwhitelisted = {}
Citizen.CreateThread(function()
    _tbl_playerwhitelisted = LoadResourceFile(GetCurrentResourceName(), 'server/sv_data.json')
    if _tbl_playerwhitelisted ~= nil then
        _tbl_playerwhitelisted = json.decode(_tbl_playerwhitelisted)
    else
        _tbl_playerwhitelisted = {}
    end
    _print('Loaded maintenance whitelist list')
end)

local function AddPlayerInWhitelist(license)
    table.insert(_tbl_playerwhitelisted, license)
    local encoded = json.encode(_tbl_playerwhitelisted)
    SaveResourceFile(GetCurrentResourceName(), 'server/sv_data.json', encoded, -1)
    _print('Added ['..license..'] to the maintenance whitelist list')
end

local function isPlayerWhitelisted(identifier)
    local _tbl_data = {}
    if maintenanceListening == "json_data" then _tbl_data = _tbl_playerwhitelisted else _tbl_data = maintenanceWhitelist end
    for _, v in ipairs(_tbl_data) do
        if v == identifier then
            return true
        end
    end
    return false
end

local function GetPlayerLicense(id)
    local identifiers = GetPlayerIdentifiers(id)
    for _, v in pairs(identifiers) do
        if string.find(v, "license") then
            return v
        end
    end
end

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local _source <const> = source
    local _license <const> = GetPlayerLicense(_source)
    if maintenanceMode and not isPlayerWhitelisted(_license) then
        deferrals.defer()
        deferrals.done(string.format("The server is currently undergoing maintenance. Please try again later. For more information, please visit our Discord server: %s.", maintenanceDiscord))
    end
end)

RegisterCommand("maintenance", function(source, args, rawCommand)
    if source == 0 then
        if args[1] == "on" then
            maintenanceMode = true
            _print("The server is currently in maintenance mode")
        elseif args[1] == "off" then
            maintenanceMode = false
            _print("The server is currently in public mode")
        end
    end
end, true)

RegisterCommand("add_maintenance", function(source, args, rawCommand)
    if source == 0 then
        if args[1] then
            AddPlayerInWhitelist(args[1])
        end
    end
end, true)

print("^4 fivem-maintenance - By MiraxxR#8801 - https://github.com/MiraxxR1/fivem-maintenance - https://discord.gg/wJmnKQHTWD^0") 
