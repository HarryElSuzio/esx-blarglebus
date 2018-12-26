Bus = {}
Bus.bus = nil

function Bus.CreateBus(coords, model, color)
	local ped = GetPlayerPed(-1)
    ESX.Game.SpawnVehicle(model, coords, coords.heading, function(createdBus)
		
        Bus.bus = createdBus
        SetVehicleNumberPlateText(Bus.bus, string.format('BLARG%03d', math.random(0, 999)))
        SetVehicleColours(Bus.bus, color, color)
		TaskWarpPedIntoVehicle(ped, Bus.bus, -1)
        Bus.WaitForFirstEntryAndFillTankIfNeededAsync()
    end)
end

function Bus.WaitForFirstEntryAndFillTankIfNeededAsync()
    if not Config.UseFrFuel then
        return
    end

    Citizen.CreateThread(function()
        local maxFuel = GetVehicleHandlingFloat(Bus.bus, 'CHandlingData', 'fPetrolTankVolume')

        while true do
            Citizen.Wait(500)
            
            if GetVehiclePedIsIn(PlayerPedId(), false) == Bus.bus then
                exports.frfuel:setFuel(maxFuel)
                break
            end
        end
    end)
end

function Bus.DeleteBus()
    DeleteVehicle(Bus.bus)
    Bus.bus = nil
end

function Bus.DisplayMessageAndWaitUntilBusStopped(notificationMessage)
    while not IsVehicleStopped(Bus.bus) do
        ESX.ShowNotification(notificationMessage)
        Citizen.Wait(500)
    end
end

function Bus.OpenDoorsAndActivateHazards(doors)
    Bus.ActivateHazards(true)
    Bus.OpenBusDoors(doors)
end

function Bus.OpenBusDoors(doors)
    for i = 1, #doors do
        SetVehicleDoorOpen(Bus.bus, doors[i], false, false)
    end

    Citizen.Wait(Config.DelayBetweenChanges)
end

function Bus.CloseDoorsAndDeactivateHazards()
    Bus.ActivateHazards(false)
    SetVehicleDoorsShut(Bus.bus, false)
end

function Bus.ActivateHazards(isOn)
    SetVehicleIndicatorLights(Bus.bus, 0, isOn)
    SetVehicleIndicatorLights(Bus.bus, 1, isOn)
end

function Bus.FindFreeSeats(firstSeat, capacity)
    local freeSeats = {}

    for i = firstSeat, capacity do
        if IsVehicleSeatFree(Bus.bus, i) then
            table.insert(freeSeats, i)
        end
    end

    return freeSeats
end
