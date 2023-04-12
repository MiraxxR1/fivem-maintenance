---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by MiraxxR.
--- Copyright (c) MiraxxR - All Rights Reserved
--- DateTime: 05/04/2023 04:20
---

Maintenance = {}
Maintenance.Mode = true
Maintenance.Listening = 'JSON' -- JSON or nil
Maintenance.DiscordLink = 'https://discord.gg/wJmnKQHTWD'
Maintenance.DropMessage = 'The server is currently undergoing maintenance. Please try again later. For more information, please visit our Discord server: %s.'
Maintenance.Whitelisted = {}
Maintenance.Allowed = {
    'license:'
}

function Maintenance:LoadMaintenanceData()
    self.Whitelisted = LoadResourceFile(GetCurrentResourceName(), 'server/sv_whitelist.json')
    if self.Whitelisted ~= nil then
        self.Whitelisted = json.decode(self.Whitelisted)
    else
        self.Whitelisted = {}
    end
    self:Print('Loaded maintenance whitelist data')
end

function Maintenance:AddPlayerInWhitelist(license)
    table.insert(self.Whitelisted, license)
    local encoded = json.encode(self.Whitelisted)
    SaveResourceFile(GetCurrentResourceName(), 'server/sv_whitelist.json', encoded, -1)
    self:Print('Added ['..license..'] to the maintenance whitelist')
end

function Maintenance:isPlayerWhitelisted(identifier, playerName)
    local _tbl = {}
    if self.Listening == 'JSON' then _tbl = self.Whitelisted else _tbl = self.Allowed end
    for k, v in ipairs(_tbl) do
        if v == identifier then
            return true, self:Print('Allowed connection: ^3' .. playerName .. '^7')
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

function Maintenance:Print(text)
    print("^3Fivem-maintenance:^7 ^4["..os.date('%c').."]^7 "..text)
end

AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)
    local _source <const> = source
    local _license <const> = GetPlayerLicense(_source)

    Maintenance:Print('Connecting: ^3' .. playerName .. '^7')
    if Maintenance.Mode and not Maintenance:isPlayerWhitelisted(_license, playerName) then
        deferrals.defer()
        deferrals.done(string.format(Maintenance.DropMessage, Maintenance.DiscordLink))
        Maintenance:Print('Dropping: ^3' .. playerName .. '^7, Reason: ^3Not Whitelisted^7')
    end
end)

-- Command Usage : /set_maintenance_state [boolean]
RegisterCommand("set_maintenance_state", function(source, args, rawCommand)
    if source == 0 then
        if args[1] == 1 then
            Maintenance.Mode = true
            Maintenance:Print("The server is currently in maintenance mode")
        elseif args[1] == 0 then
            Maintenance.Mode = false
            Maintenance:Print("The server is currently in public mode")
        end
    end
end, true)

-- Command Usage : /add_maintenance [player_license]
RegisterCommand("add_maintenance", function(source, args, rawCommand)
    if source == 0 then
        if args[1] then
            Maintenance:AddPlayerInWhitelist(args[1])
        end
    end
end, true)

-- Command Usage : sync_maintenance
RegisterCommand("sync_maintenance", function(source, args, rawCommand)
    if source == 0 then
        Maintenance:LoadMaintenanceData()
    end
end, true)

Citizen.CreateThread(function() Maintenance:LoadMaintenanceData() end)
print("^4 fivem-maintenance - By MiraxxR#8801 - https://github.com/MiraxxR1/fivem-maintenance - https://discord.gg/wJmnKQHTWD^0")
