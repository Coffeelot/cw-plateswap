local QBCore = exports['qb-core']:GetCoreObject()
local useDebug = Config.Debug

function dump(o)
   if type(o) == 'table' then
   local s = '{ '
   for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
   end
   return s .. '} '
   else
   return tostring(o)
   end
end

function resetPlateIfFake(fakePlate, veh)
    QBCore.Functions.TriggerCallback('cw-plateswap:server:getRealPlateFromFakePlate', function(realPlate)
        if realPlate then
            SetVehicleNumberPlateText(veh, realPlate)
        end
    end, fakePlate)
end

function applyFakePlateIfExists(realPlate, veh)
    QBCore.Functions.TriggerCallback('cw-plateswap:server:getFakePlateFromRealPlate', function(fakePlate)
        if fakePlate then
            SetVehicleNumberPlateText(veh, fakePlate)
        end
    end, realPlate)
end

local function callCops()
    local coordinates = GetEntityCoords(PlayerPedId())
    local s1, s2 = GetStreetNameAtCoord(coordinates.x, coordinates.y, coordinates.z)
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    local streetLabel = street1
    if street2 ~= nil then
        streetLabel = streetLabel .. " " .. street2
    end
    TriggerServerEvent("cw-plateswap:server:callCops", coordinates,  streetLabel)
end

local function setPlate(fakePlate, vehicle)
    local captializedFakePlate = fakePlate:upper()
    if useDebug then
        print('fakeplate', captializedFakePlate)
        print('vehicle', vehicle)
    end
    local plate = QBCore.Functions.GetPlate(vehicle)
    QBCore.Functions.TriggerCallback('cw-plateswap:server:setFakePlate', function(plateWasAvailable)
        if plateWasAvailable then
            SetVehicleNumberPlateText(vehicle, captializedFakePlate)
            TriggerServerEvent('cw-plateswap:server:setFakePlate', plate, captializedFakePlate)
            Wait(200)
            QBCore.Functions.TriggerCallback('qb-vehiclekeys:server:GetVehicleKeys', function(keysList)
                
                if keysList[plate] then
                    TriggerEvent('qb-vehiclekeys:client:AddKeys', fakePlate:upper())
                else
                    if useDebug then
                        print('you didnt have keys to this car')
                    end
                end 
            end)
        else
            if useDebug then
                QBCore.Functions.Notify(Lang:t('error.plate_too_hot'), "error")
                print('Plate was used')
            end
        end
    end, captializedFakePlate, plate)

end

local function removeFakePlate(vehicle)
    if useDebug then
        print('removing fake plate from', dump(QBCore.Functions.GetVehicleProperties(vehicle)))
    end
    local fakePlate = QBCore.Functions.GetPlate(vehicle)
    if useDebug then
        print('fake plate', fakePlate)
    end
    QBCore.Functions.TriggerCallback('cw-plateswap:server:removeFakePlate', function(ogPlate)
        SetVehicleNumberPlateText(vehicle, ogPlate)
    end, fakePlate)
end

local function takePlate(entity)
    local plate = QBCore.Functions.GetPlate(entity)
    print("plate is", plate)
    if plate == '' then
        if useDebug then
            print('This plate doesnt exist')
        end
        QBCore.Functions.Notify('This Vehicle Doesnt Have A Plate', 'error', 4000)
    return end

    if useDebug then
        print('stealing plate', plate)
    end
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic3"})
    QBCore.Functions.Progressbar("removing_plate", Lang:t('info.removing'), Config.Settings.RemoveTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        QBCore.Functions.TriggerCallback('cw-plateswap:server:createItem', function(plateWasAvailable)
            if plateWasAvailable == 'OK' then
                local chance = math.random(1,100)
                if chance < Config.Settings.PoliceCallChance then
                    callCops()
                end
                if useDebug then
                    print('Item given')
                end
                SetVehicleNumberPlateText(entity, '')
            elseif plateWasAvailable == 'EXISTS' then
                removeFakePlate(entity)
            end
        end, plate)
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        QBCore.Functions.Notify(Lang:t('error.canceled'), "error")
    end)
end

if Config.Inventory == 'ox' then
    exports.ox_inventory:displayMetadata("plate", "Plate Number")
end

local function applyPlate(entity)
    local plate = QBCore.Functions.GetPlate(entity)
    QBCore.Functions.TriggerCallback('cw-plateswap:server:isFakePlate', function(isFake)
        if not isFake then
            TriggerEvent('animations:client:EmoteCommandStart', {"mechanic3"})
            QBCore.Functions.Progressbar("applying_plate", Lang:t('info.applying'), Config.Settings.AddTime, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
                QBCore.Functions.TriggerCallback('cw-plateswap:server:getFakePlateId', function(fakePlate)
                    if fakePlate then
                        if useDebug then
                            print('item found', fakePlate)
                        end
                        setPlate(fakePlate, entity)
                    else
                        print('Nah')
                    end
                end)
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            end, function() -- Cancel
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                QBCore.Functions.Notify(Lang:t('error.canceled'), "error")
            end)
        else
            QBCore.Functions.Notify(Lang:t('error.remove_first'), "error")
        end
    end, plate)
end

RegisterNetEvent('cw-plateswap:client:setFakePlate', function(fakePlate)
    local captializedFakePlate = fakePlate:upper()
    print('fakeplate', captializedFakePlate)
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)
    QBCore.Functions.TriggerCallback('cw-plateswap:server:setFakePlate', function(plateWasAvailable)
        if plateWasAvailable then
            SetVehicleNumberPlateText(vehicle, captializedFakePlate)
            TriggerServerEvent('cw-plateswap:server:setFakePlate', plate, captializedFakePlate)
            Wait(200)
            TriggerEvent('qb-vehiclekeys:client:AddKeys', fakePlate:upper())
        else
            print('Nah')
        end
    end, captializedFakePlate, plate)
end)

RegisterNetEvent('cw-plateswap:client:removeFakePlate', function()
    local player = PlayerPedId()

    local vehicle = GetVehiclePedIsIn(player, false)
    if useDebug then
        print(dump(QBCore.Functions.GetVehicleProperties(vehicle)))
    end
    local fakePlate = QBCore.Functions.GetPlate(vehicle)
    if useDebug then
        print('fake plate', fakePlate)
    end
    QBCore.Functions.TriggerCallback('cw-plateswap:server:removeFakePlate', function(ogPlate)
        SetVehicleNumberPlateText(vehicle, ogPlate)
    end, fakePlate)
    --TriggerEvent('qb-vehiclekeys:client:AddKeys', fakePlate:upper())
end)

CreateThread(function()
    local bones = {
          'boot',
        }
    local options = {
        {
            type = "client",
            icon = 'fas fa-screwdriver',
            label = 'Take plate',
            -- item = Config.InteractionItem,
            action = function(entity)
                takePlate(entity)
            end,
            canInteract = function(entity, distance, data)
                return true
            end,
        },
        {
            type = "client",
            icon = 'fas fa-screwdriver',
            label = 'Put plate',
            item = Config.LicensePlateItem,
            action = function(entity)
            applyPlate(entity)
            end,
            canInteract = function(entity, distance, data)
                if Config.InteractionItem then
                    local hasItem = false

                    if Config.Inventory == 'qb' then
                        hasItem = QBCore.Functions.HasItem(Config.InteractionItem)
                        if hasItem then return true end
                    else
                        hasItem = exports.ox_inventory:Search('count', Config.InteractionItem)
                        if hasItem >= 1 then return true
                        end
                    end

                    return false
                else
                    return true
                end
            end,
        },
    }
    exports['qb-target']:AddTargetBone(bones, { -- The bones can be a string or a table
      options = options,
      distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
    })
end)

RegisterNetEvent('cw-plateswap:client:toggleDebug', function(debug)
   print('Setting debug to', debug)
   useDebug = debug
end)
