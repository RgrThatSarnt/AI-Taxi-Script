local taxiVehicle = nil
local taxiDriver = nil
local taxiBlip = nil
local destination = nil

local rideActive = false
local taxiArrived = false
local currentDriveMode = "normal"

--------------------------------------------------
-- UTIL
--------------------------------------------------

local function Notify(msg)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function DrawHelp(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

--------------------------------------------------
-- RANDOM TAXI
--------------------------------------------------

local function GetRandomTaxi()
    local count = #Config.TaxiVehicles
    if count == 0 then return nil end
    return Config.TaxiVehicles[math.random(1, count)]
end

--------------------------------------------------
-- SPAWN TAXI
--------------------------------------------------

RegisterNetEvent("aiTaxi:spawnTaxi", function()

    if rideActive then
        Notify("Taxi already active.")
        return
    end

    local data = GetRandomTaxi()
    if not data then return end

    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)

    local spawnOffset = GetOffsetFromEntityInWorldCoords(
        player,
        math.random(Config.SpawnDistanceMin, Config.SpawnDistanceMax),
        math.random(-50,50),
        0
    )

    local vehicleModel = GetHashKey(data.vehicleModel)
    local driverModel = GetHashKey(data.driverModel)

    RequestModel(vehicleModel)
    RequestModel(driverModel)

    while not HasModelLoaded(vehicleModel) or not HasModelLoaded(driverModel) do
        Wait(10)
    end

    taxiVehicle = CreateVehicle(vehicleModel, spawnOffset.x, spawnOffset.y, spawnOffset.z, 0.0, true, false)
    taxiDriver = CreatePedInsideVehicle(taxiVehicle, 4, driverModel, -1, true, false)

    SetVehicleOnGroundProperly(taxiVehicle)
    SetBlockingOfNonTemporaryEvents(taxiDriver, true)

    taxiBlip = AddBlipForEntity(taxiVehicle)
    SetBlipSprite(taxiBlip, 198)
    SetBlipColour(taxiBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Your Taxi")
    EndTextCommandSetBlipName(taxiBlip)

    Notify("Taxi is on the way.")

    TaskVehicleDriveToCoordLongrange(
        taxiDriver,
        taxiVehicle,
        playerCoords.x,
        playerCoords.y,
        playerCoords.z,
        Config.DriveModes.normal.speed,
        Config.DriveModes.normal.drivingStyle,
        Config.StoppingRange
    )

    CreateThread(function()
        while not taxiArrived do
            Wait(1000)

            if not DoesEntityExist(taxiVehicle) then return end

            local dist = #(GetEntityCoords(taxiVehicle) - GetEntityCoords(player))

            if dist <= Config.ArrivalDistance then
                ClearPedTasks(taxiDriver)
                taxiArrived = true
                Notify("Taxi has arrived.")
                break
            end
        end
    end)

    CreateThread(function()
        while not rideActive do
            Wait(0)

            if taxiArrived then
                local playerCoords = GetEntityCoords(player)
                local taxiCoords = GetEntityCoords(taxiVehicle)
                local dist = #(playerCoords - taxiCoords)

                if dist <= 3.0 then
                    DrawHelp("Press ~INPUT_CONTEXT~ to enter Taxi")

                    if IsControlJustPressed(0, Config.EnterKey) then
                        TaskEnterVehicle(player, taxiVehicle, 5000, 2, 1.0, 1, 0)
                    end
                end

                if IsPedInVehicle(player, taxiVehicle, false) then
                    rideActive = true
                    OpenMapForDestination()
                    break
                end
            end
        end
    end)

end)

--------------------------------------------------
-- MAP / DESTINATION
--------------------------------------------------

function OpenMapForDestination()

    SetBigmapActive(true, false)
    Notify("Select a destination.")

    CreateThread(function()
        while true do
            Wait(500)

            local blip = GetFirstBlipInfoId(8)

            if DoesBlipExist(blip) then
                destination = GetBlipInfoIdCoord(blip)
                SetBigmapActive(false, false)
                StartDriving()
                break
            end
        end
    end)

end

--------------------------------------------------
-- DRIVE SYSTEM
--------------------------------------------------

function StartDriving()
    UpdateDriveTask()
end

function UpdateDriveTask()

    local mode = Config.DriveModes[currentDriveMode]

    TaskVehicleDriveToCoordLongrange(
        taxiDriver,
        taxiVehicle,
        destination.x,
        destination.y,
        destination.z,
        mode.speed,
        mode.drivingStyle,
        Config.StoppingRange
    )

end

--------------------------------------------------
-- INPUT WHILE RIDING
--------------------------------------------------

CreateThread(function()
    while true do
        Wait(0)

        if rideActive and IsPedInVehicle(PlayerPedId(), taxiVehicle, false) then

            if IsControlJustPressed(0, Config.CancelTripKey) then
                EndRide()
            end

            if IsControlJustPressed(0, Config.ChangeLocationKey) then
                OpenMapForDestination()
            end

            if IsControlJustPressed(0, Config.HurryKey) then
                if currentDriveMode ~= "hurry" then
                    currentDriveMode = "hurry"
                    Notify("Driver: Holding on!")
                    UpdateDriveTask()
                end
            end

        end
    end
end)

--------------------------------------------------
-- END RIDE
--------------------------------------------------

function EndRide()

    Notify("Trip cancelled.")

    ClearPedTasks(taxiDriver)
    TaskVehicleTempAction(taxiDriver, taxiVehicle, 27, 2000)

    rideActive = false
    taxiArrived = false
    currentDriveMode = "normal"

    if taxiBlip then
        RemoveBlip(taxiBlip)
    end

    CreateThread(function()
        Wait(Config.DeleteAfterSeconds * 1000)

        if DoesEntityExist(taxiVehicle) then
            DeleteEntity(taxiVehicle)
        end

        if DoesEntityExist(taxiDriver) then
            DeleteEntity(taxiDriver)
        end
    end)

end
