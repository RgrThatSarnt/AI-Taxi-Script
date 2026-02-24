RegisterCommand(Config.Command, function(source)
    TriggerClientEvent("aiTaxi:spawnTaxi", source)
end)
