
RegisterServerEvent('hudevents:leftVehicle')
AddEventHandler('hudevents:leftVehicle', function()	
    TriggerClientEvent('hudevents:leftVehicle', source)
end)
QBCore = exports['qb-core']:GetCoreObject()
RegisterServerEvent('hudevents:enteredVehicle')
AddEventHandler('hudevents:enteredVehicle', function(currentVehicle, currentSeat, vehicle_name, net_id)	
    TriggerClientEvent('hudevents:enteredVehicle', source, currentVehicle, currentSeat, vehicle_name, net_id)
end)

function GetPlayer(src)
    local QBCore = exports['qb-core']:GetCoreObject() 
    return QBCore.Functions.GetPlayer(src) 
end


function GetName(user)
    local QBCore = exports['qb-core']:GetCoreObject()
    return user.PlayerData.charinfo.firstname..' '..user.PlayerData.charinfo.lastname
end

function GetJob(user)
    local QBCore = exports['qb-core']:GetCoreObject()
    return user.PlayerData.job.label..' - '..user.PlayerData.job.grade.name
end

function GetCash(user)
    local QBCore = exports['qb-core']:GetCoreObject()
    return user.Functions.GetMoney('cash')
end

function GetBank(user)
    local QBCore = exports['qb-core']:GetCoreObject()
    return user.Functions.GetMoney('bank')
end

function GetAllPlayers()
    local QBCore = exports['qb-core']:GetCoreObject()
    return QBCore.Functions.GetPlayers()
end



QBCore.Functions.CreateCallback('babun-hud-get-datas', function(source, cb)
    local src = source
    local user = GetPlayer(src)
    if not user then 
        cb(nil)
        return
    end

    local data = {
        name = GetName(user) .. ' ('..src..')',
        cash = GetCash(user),
        bank = GetBank(user),
        players = #GetAllPlayers(),
        job = GetJob(user)
    }
    cb(data)
end)


