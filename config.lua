Config = {}

Config.Command = "taxi"

Config.SpawnDistanceMin = 200.0
Config.SpawnDistanceMax = 350.0
Config.ArrivalDistance = 15.0
Config.StoppingRange = 10.0

Config.EnterKey = 38 -- E
Config.CancelTripKey = 73 -- X
Config.ChangeLocationKey = 47 -- G
Config.HurryKey = 29 -- B

Config.DeleteAfterSeconds = 30

Config.DriveModes = {
    normal = {
        speed = 22.0,
        drivingStyle = 786468
    },
    hurry = {
        speed = 35.0,
        drivingStyle = 1074528293
    }
}

Config.TaxiVehicles = {
    {
        vehicleModel = "taxi",
        driverModel = "s_m_m_gentransport"
    }
}
