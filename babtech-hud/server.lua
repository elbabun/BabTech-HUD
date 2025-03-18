QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('hudevents:leftVehicle')
AddEventHandler('hudevents:leftVehicle', function()
    TriggerClientEvent('hudevents:leftVehicle', source)
end)

RegisterServerEvent('hudevents:enteredVehicle')
AddEventHandler('hudevents:enteredVehicle', function(currentVehicle, currentSeat, vehicle_name, net_id)
    TriggerClientEvent('hudevents:enteredVehicle', source, currentVehicle, currentSeat, vehicle_name, net_id)
end)

function GetPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

function GetPlayerData(user)
    if not user then return nil end

    return {
        name = user.PlayerData.charinfo.firstname .. ' ' .. user.PlayerData.charinfo.lastname .. ' ('..user.PlayerData.source..')',
        cash = user.Functions.GetMoney('cash'),
        bank = user.Functions.GetMoney('bank'),
        job = user.PlayerData.job.label .. ' - ' .. user.PlayerData.job.grade.name
    }
end

QBCore.Functions.CreateCallback('babun-hud-get-datas', function(source, cb)
    local user = GetPlayer(source)
    if not user then
        cb(nil)
        return
    end

    local data = GetPlayerData(user)
    data.players = #QBCore.Functions.GetPlayers()

    cb(data)
end)
