local QBCore = nil
local ESX = nil
local PlayerData = {}
local hunger = 100
local thirst = 100
QBCore = exports['qb-core']:GetCoreObject()
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(playerPed, false)

        if inVehicle then
            DisplayRadar(true)
        else
            DisplayRadar(false) 
        end
        
        Wait(500) 
    end
end)


RegisterNetEvent("babun-hud:toggleHUD")
AddEventHandler("babun-hud:toggleHUD", function()
    SendNUIMessage({ action = "toggleHUD" })
end)

RegisterCommand("hud", function()
    TriggerEvent("babun-hud:toggleHUD")
end, false)



-- Initialize framework
CreateThread(function()
    if Config.Framework == 'qb-core' then
        QBCore = exports['qb-core']:GetCoreObject()
        while not QBCore do
            Wait(100)
        end
    else
        ESX = exports['es_extended']:getSharedObject()
        while not ESX do
            Wait(100)
        end
    end
end)

local lastValues = {
    health = 0,
    armor = 0,
    food = 0,
    water = 0,
    id = 0,
    location = ""
}

-- Get current location
function GetLocationText()
    if not Config.ShowLocation then return "" end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    return street
end

function updateHUD()
    local oxygenIncreaseRate = 0.5 
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)
    local armor = GetPedArmour(ped)
    local oxygen = 0
    local currentId = Config.ShowPlayerId and GetPlayerServerId(PlayerId()) or 0
    local location = GetLocationText()

    if IsPedSwimmingUnderWater(ped) then
        oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10

        if oxygen < 0 then
            oxygen = 0
        elseif oxygen > 100 then
            oxygen = 100
        end
        SendNUIMessage({
            type = 'updateOxygenHUD',
            show = true,
            oxy = oxygen
        })
    else
        SendNUIMessage({
            type = 'updateOxygenHUD',
            show = false
        })
    end

    if health < 100 then
        health = 0
    else
        health = health - 100
    end

    -- Round all values to whole numbers
    health = math.floor(health + 0.5)
    armor = math.floor(armor + 0.5)
    hunger = math.floor(hunger + 0.5)
    oxygen = math.floor(oxygen + 0.5)
    thirst = math.floor(thirst + 0.5)

    -- Only send update if values changed
    if health ~= lastValues.health or 
       armor ~= lastValues.armor or 
       oxygen ~= lastValues.oxy or
       hunger ~= lastValues.food or 
       thirst ~= lastValues.water or
       stamina ~= lastValues.stamina or
       currentId ~= lastValues.id or
       location ~= lastValues.location then
        
        -- Update cache
        lastValues.health = health
        lastValues.armor = armor
        lastValues.food = hunger
        lastValues.oxy = oxygen
        lastValues.water = thirst
        lastValues.stamina = stamina
        lastValues.id = currentId
        lastValues.location = location
        
        -- Send to UI
        SendNUIMessage({
            type = 'updateStatusHud',
            show = true,
            health = health,
            armor = armor,
            oxy = oxygen,
            food = hunger,
            stamina = stamina,
            water = thirst,
            id = currentId,
            location = location,
            showId = Config.ShowPlayerId,
            showLocation = Config.ShowLocation
        })
    end
end


RegisterNetEvent('updateStatusHud', function(data)
    if data.show then
        SendNUIMessage({
            type = 'updateStatusHud',
            show = true,
            oxy = data.oxy
        })
    else
        SendNUIMessage({
            type = 'updateStatusHud',
            show = false
        })
    end
end)

function updateBar(type, value)
    SendNUIMessage({
        type = 'updateBar',
        barType = type,
        value = value
    })
end

CreateThread(function()
    while true do
        updateHUD()
        Wait(Config.UpdateInterval)
    end
end)

-- Framework specific events
if Config.Framework == 'qb-core' then
    -- QB-Core status updates
    RegisterNetEvent('hud:client:UpdateNeeds')
    AddEventHandler('hud:client:UpdateNeeds', function(newHunger, newThirst)
        hunger = math.floor(newHunger + 0.5)
        thirst = math.floor(newThirst + 0.5)
    end)
else
    -- ESX status updates
    RegisterNetEvent('esx_status:onTick')
    AddEventHandler('esx_status:onTick', function(status)
        for _, status in ipairs(status) do
            if status.name == 'hunger' then
                hunger = math.floor(status.percent + 0.5)
            end
            if status.name == 'thirst' then
                thirst = math.floor(status.percent + 0.5)
            end
        end
    end)
end


-- CARHUD
RegisterNetEvent('vehicle:entered')
AddEventHandler('vehicle:entered', function()
    SendNUIMessage({
        action = "setVehicleState",
        inVehicle = true
    })
end)

RegisterNetEvent('vehicle:exited')
AddEventHandler('vehicle:exited', function()
    SendNUIMessage({
        action = "setVehicleState",
        inVehicle = false
    })
end)


Citizen.CreateThread(function()
    local lastState = false
    while true do
        Citizen.Wait(200)
        local playerPed = PlayerPedId()
        local currentState = IsPedInAnyVehicle(playerPed, false)
        
        if currentState ~= lastState then
            lastState = currentState
            if currentState then
                TriggerEvent('vehicle:entered')
            else
                TriggerEvent('vehicle:exited')
            end
        end
    end
end)

-- MİK
local speak = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local status = NetworkIsPlayerTalking(PlayerId())
        if status and not speak then
            speak = true
            SendNUIMessage({action = 'speak', active = true})
        elseif not status and speak then
            speak = false
            SendNUIMessage({action = 'speak', active = false})
        end
    end
end)

RegisterNetEvent('pma-voice:setTalkingMode')
AddEventHandler('pma-voice:setTalkingMode', function(lvl)
    SendNUIMessage({action = 'voice', lvl = tostring(lvl)})
end)

-- HUD GİZLE




CreateThread(function()
    Wait(1000) 
    SendNUIMessage({ action = "hideHUD" }) 
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    SendNUIMessage({ action = "showHUD" })
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    SendNUIMessage({ action = "hideHUD" }) 
end)





--- SPEEDOMETERRR


local shouldSendNUIUpdate = false
local isHudHidden = false

seatbeltOn = false
local lastCarLS_r, lastCarLS_o, lastCarLS_h
local lastCarFuelAmount, lastCarHandbreak, lastCarBrakePressure
local lastCarIL, lastCarRPM, lastCarSpeed, lastCarGear

displayKMH = 0
local nitro = 0

seat_belt = false

local function DisableVehicleExit()
	while seat_belt do
		Wait(0)
		DisableControlAction(0, 75, true)
	end
end

RegisterCommand('*seat_belt', function()
	local PlayerPed = PlayerPedId()
	local PlayerVehicle = GetVehiclePedIsUsing(PlayerPed)
	local VehicleClass = GetVehicleClass(PlayerVehicle)

	if IsPedInAnyVehicle(PlayerPed, false) and VehicleClass ~= 8 and VehicleClass ~= 13 and VehicleClass ~= 14 then
		seat_belt = not seat_belt

		if seat_belt then
			TriggerServerEvent('InteractSound_SV:PlayOnSource', 'carbuckle', 0.25)
		else
			TriggerServerEvent('InteractSound_SV:PlayOnSource', 'carunbuckle', 0.25)
		end

		SetPedConfigFlag(PlayerPed, 32, not seat_belt)
		TriggerEvent('seatbelt:client:ToggleSeatbelt', seat_belt)
		DisableVehicleExit()
	end
end, false)

RegisterNetEvent("hudevents:leftVehicle")
AddEventHandler('hudevents:leftVehicle', function()
	isInVehicle = false

	if not isHudHidden then
		isHudHidden = true

		SendNUIMessage({
			HideHud = isHudHidden
		})
	end
end)

RegisterNetEvent("hudevents:enteredVehicle")
AddEventHandler('hudevents:enteredVehicle', function(currentVehicle, currentSeat, vehicle_name, net_id)

	isInVehicle = true
	SetPedConfigFlag(PlayerPedId(), 32, true)
	seat_belt = false

	if isHudHidden then
		isHudHidden = false
		SendNUIMessage({
			HideHud = isHudHidden
		})
	end

	while isInVehicle do
		Wait(50)	

		local PlayerPed = PlayerPedId()
		
		if not isHudHidden then
			if IsVehicleEngineOn(currentVehicle) then
				local carRPM = GetVehicleCurrentRpm(currentVehicle)			
				
				local multiplierUnit = 2.8

				if Config.Unit == "KMH" then
					multiplierUnit = 3.6
				end

				local carSpeed = math.floor(GetEntitySpeed(currentVehicle) * multiplierUnit)
				local carGear = GetVehicleCurrentGear(currentVehicle)
				local carHandbrake = GetVehicleHandbrake(currentVehicle)
				local carBrakePressure = GetVehicleWheelBrakePressure(currentVehicle, 0)
				local fuelamount = GetVehicleFuelLevel(currentVehicle) or 0

				shouldSendNUIUpdate = false

				if lastCarRPM ~= carRPM then lastCarRPM = carRPM shouldSendNUIUpdate = true end
				if lastCarSpeed ~= carSpeed then lastCarSpeed = carSpeed shouldSendNUIUpdate = true end
				if lastCarGear ~= carGear then lastCarGear = carGear shouldSendNUIUpdate = true end
				if lastCarHandbreak ~= carHandbrake then lastCarHandbreak = carHandbrake shouldSendNUIUpdate = true end
				if lastCarBrakePressure ~= carBrakePressure then lastCarBrakePressure = carBrakePressure shouldSendNUIUpdate = true end

				if lastCarFuelAmount ~= fuelamount then lastCarFuelAmount = fuelamount shouldSendNUIUpdate = true end

				if shouldSendNUIUpdate then
					SendNUIMessage({
						ShowHud = true,
						CurrentCarRPM = carRPM * 10,
						CurrentUnitDistance = Config.Unit,
						CurrentCarGear = carGear,
						CurrentCarSpeed = carSpeed,
						CurrentCarHandbrake = carHandbrake,
						CurrentCarFuelAmount = math.ceil(fuelamount),
						CurrentDisplayKMH = displayKMH,
						CurrentCarBrake = carBrakePressure,
						CurrentNitro = nitro,						
						seatbelt = seatbeltOn
					})		
				end
			end
		end
	end
end)



RegisterNetEvent("babun-fuel:UpdateHUD")
AddEventHandler("babun-fuel:UpdateHUD", function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 and GetIsVehicleEngineRunning(vehicle) then
        local fuelLevel = GetFuelLevel(vehicle) 
        SendNUIMessage({
            action = "updateFuel",
            fuel = fuelLevel,
            display = true
        })
    else
        SendNUIMessage({
            action = "updateFuel",
            display = false 
        })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        TriggerEvent("babun-fuel:UpdateHUD")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle == 0 then
            SendNUIMessage({
                action = "updateFuel",
                display = false
            })
        end
    end
end)


function GetFuelLevel(vehicle)
    if Config.Benzinaskim == "LegacyFuel" then
        return math.floor(exports['LegacyFuel']:GetFuel(vehicle))
    elseif Config.Benzinaskim == "other_fuel_script" then
        return math.floor(exports['other_fuel_script']:GetFuel(vehicle)) 
    else
        return 100 
    end
end




local function GetPedVehicleSeat(entity)
    local Vehicle = GetVehiclePedIsIn(entity, false)

	for i= -2, GetVehicleMaxNumberOfPassengers(Vehicle) do
        if GetPedInVehicleSeat(Vehicle, i) == entity then
			return i
		end
    end

	return -2
end

AddEventHandler('onResourceStart', function()
	local PlayerPed = PlayerPedId()

	if IsPedInAnyVehicle(PlayerPed, false) then
		local currentVehicle = GetVehiclePedIsUsing(PlayerPed)
		local currentSeat = GetPedVehicleSeat(PlayerPed)
		local netID = VehToNet(currentVehicle)

		TriggerEvent('hudevents:enteredVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netID)

		cruiser = true
		ExecuteCommand('cruiser')
	end
end)


local vehiclemeters = -1
local previousvehiclepos = nil
local CheckDone = false
DrivingDistance = {}

Citizen.CreateThread(function()
    Wait(500)
    while true do
        local ped = PlayerPedId()
        local invehicle = IsPedInAnyVehicle(ped, true)
        if invehicle then
            local veh = GetVehiclePedIsIn(ped)
            local seat = GetPedInVehicleSeat(veh, -1)
            local pos = GetEntityCoords(ped)
            local vehclass = GetVehicleClass(GetVehiclePedIsIn(ped))
            local plate = GetVehicleNumberPlateText(veh)

            if plate ~= nil then
                if seat == ped then
                    if not CheckDone then
                        if vehiclemeters == -1 then
                            CheckDone = true
                           -- Core.Functions.TriggerCallback('vehicletuning:server:IsVehicleOwned', function(IsOwned)
                                if false then
                                    if DrivingDistance[plate] ~= nil then
                                        vehiclemeters = DrivingDistance[plate]
                                    else
                                        DrivingDistance[plate] = 0
                                        vehiclemeters = DrivingDistance[plate]
                                    end
                                else
                                    if DrivingDistance[plate] ~= nil then
                                        vehiclemeters = DrivingDistance[plate]
                                    else
                                        DrivingDistance[plate] = math.random(111111, 999999)
                                        vehiclemeters = DrivingDistance[plate]
                                    end
                                end
                           --[[ end , plate)]]
                        end
                    end
                else
                    if vehiclemeters == -1 then
                        if DrivingDistance[plate] ~= nil then
                            vehiclemeters = DrivingDistance[plate]
                        end
                    end
                end

                if vehiclemeters ~= -1 then
                    if seat == ped then
                        if previousvehiclepos ~= nil then
                            local Distance = GetDistanceBetweenCoords(pos, previousvehiclepos, true)

                            vehiclemeters = vehiclemeters + ((Distance / 100) * 325)
                            DrivingDistance[plate] = vehiclemeters
                           
                            local amount = round(DrivingDistance[plate] / 2500, -2)
                            TriggerEvent('hud:client:UpdateDrivingMeters', true, amount)
                        end
                    else
                        if invehicle then
                            if DrivingDistance[plate] ~= nil then
                                local amount = round(DrivingDistance[plate] / 2500, -2)
                                TriggerEvent('hud:client:UpdateDrivingMeters', true, amount)
                            end
                        else
                            if vehiclemeters ~= -1 then
                                vehiclemeters = -1
                            end
                            if CheckDone then
                                CheckDone = false
                            end
                        end
                    end
                end

                previousvehiclepos = pos
            end
        else
            if vehiclemeters ~= -1 then
                vehiclemeters = -1
            end
            if CheckDone then
                CheckDone = false
            end
            if previousvehiclepos ~= nil then
                previousvehiclepos = nil
            end
        end

        if invehicle then
            Citizen.Wait(2000)
        else
            Citizen.Wait(500)
        end
    end
end)


Citizen.CreateThread(function()
    while true do               
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped)
        local seat = GetPedInVehicleSeat(veh, -1)
        local plate = GetVehicleNumberPlateText(veh)
        if seat then
            if DrivingDistance[plate] ~= nil then
                local amount = round(DrivingDistance[plate] / 2500, -2)
                TriggerEvent('hud:client:UpdateDrivingMeters', true, amount)
            --  TriggerServerEvent('vehicletuning:server:UpdateDrivingDistance', DrivingDistance[plate], plate)
            end
        end        
        Wait(30000)
    end
end)


RegisterNetEvent('hud:client:UpdateDrivingMeters')
AddEventHandler('hud:client:UpdateDrivingMeters', function(toggle, amount)
	displayKMH = amount
end)

RegisterNetEvent("seatbelt:client:ToggleSeatbelt")
AddEventHandler("seatbelt:client:ToggleSeatbelt", function(toggle)
    if toggle == nil then
        seatbeltOn = not seatbeltOn
    else
        seatbeltOn = toggle    
    end
end)


RegisterNetEvent('sendNosVehicle')
AddEventHandler('sendNosVehicle', function(result)
	nitro = result
end)


function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces>0 then
      local mult = 10^numDecimalPlaces
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function GetDamageMultiplier(meters)
    local check = round(meters / 1000, -2)
    local retval = nil
    for k, v in pairs(Config.MinimalMetersForDamage) do
        if check >= v.min and check <= v.max then
            retval = k
            break
        elseif check >= Config.MinimalMetersForDamage[#Config.MinimalMetersForDamage].min then
            retval = #Config.MinimalMetersForDamage
            break
        end
    end
    return retval
end


local isInVehicle = false
local isEnteringVehicle = false

local currentVehicle = 0
local currentSeat = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		local ped = PlayerPedId()

		if not isInVehicle and not IsPlayerDead(PlayerId()) then
			if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
				-- trying to enter a vehicle!
				local vehicle = GetVehiclePedIsTryingToEnter(ped)
				local seat = GetSeatPedIsTryingToEnter(ped)
				local netId = VehToNet(vehicle)
				isEnteringVehicle = true
				TriggerServerEvent('hudevents:enteringVehicle', vehicle, seat, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), netId)
			elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
				-- vehicle entering aborted
				TriggerServerEvent('hudevents:enteringAborted')
				isEnteringVehicle = false
			elseif IsPedInAnyVehicle(ped, false) then
				-- suddenly appeared in a vehicle, possible teleport
				isEnteringVehicle = false
				isInVehicle = true
				currentVehicle = GetVehiclePedIsUsing(ped)
				currentSeat = GetPedVehicleSeat(ped)
				local model = GetEntityModel(currentVehicle)
				local name = GetDisplayNameFromVehicleModel()
				local netId = VehToNet(currentVehicle)

				TriggerServerEvent('hudevents:enteredVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
			end
		elseif isInVehicle then
			if not IsPedInAnyVehicle(ped, false) or IsPlayerDead(PlayerId()) then
				-- bye, vehicle
				local model = GetEntityModel(currentVehicle)
				local name = GetDisplayNameFromVehicleModel()
				local netId = VehToNet(currentVehicle)
				TriggerServerEvent('hudevents:leftVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
				isInVehicle = false
				currentVehicle = 0
				currentSeat = 0
			end
		end
		Citizen.Wait(500)
	end
end)

function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i=-2,GetVehicleMaxNumberOfPassengers(vehicle) do
        if(GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end

RegisterCommand('testhud', function(source)
    local src = source
    local testData = {
        name = "SASASA AMCIKK MEME GÖTT",
        cash = "1000",
        bank = "5000",
        job = "Police - Officer 3"
    }
    
    -- NUI'ye mesaj gönderme
    SendNUIMessage({
        type = "updateHudData",
        data = testData
    })
end, false)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) 
        QBCore.Functions.TriggerCallback('babun-hud-get-datas', function(data)
            if data then
                SendNUIMessage({
                    type = "updateHudData",
                    data = data
                })
            else
            end
        end)
    end
end)

