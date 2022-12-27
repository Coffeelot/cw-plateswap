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

local function plateExistsAsFakePlate(fakePlate)
   local fakePlateFromDb = MySQL.Sync.fetchAll('SELECT fakeplate FROM player_vehicles WHERE fakeplate = ?', {fakePlate})
   if useDebug then
      print('fake plates', dump(fakePlateFromDb))
   end
   if #fakePlateFromDb > 0 then
      return true
   else
      return false
   end
end

local function plateBelongsToPlayer(plate)
   local realPlateFromDb = MySQL.Sync.fetchAll('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
   if useDebug then
      print('real plates', dump(realPlateFromDb))
   end
   if #realPlateFromDb > 0 then
      return true
   else
      return false
   end
end

local function getQBItem(item)
   local qbItem = QBCore.Shared.Items[item]
   if qbItem then
       return qbItem
   else
       print('Someone forgot to add the item')
   end
end

local function givePlate(source, plateNumber)
   local Player = QBCore.Functions.GetPlayer(source)
   local item = Config.LicensePlateItem
   local info = { plate = plateNumber }
   if Config.Inventory == 'qb' then
      Player.Functions.AddItem(item, 1, nil, info)
       TriggerClientEvent('inventory:client:ItemBox', source, getQBItem(item), "add")
   elseif Config.Inventory == 'ox' then
      exports.ox_inventory:AddItem(source, item, 1, {plate = plateNumber})
   end
end

-- NEEDS TESTING
QBCore.Functions.CreateCallback('cw-plateswap:server:isFakePlate', function(source, cb, fakePlate)
   if plateExistsAsFakePlate(fakePlate) then
      if useDebug then
         print('Was a fake plate')
      end
      cb(true)
   else
      if useDebug then
         print(fakePlate)
         print('Was not a fake plate')
      end
      cb(false)
   end
end)

-- NEEDS TESTING
QBCore.Functions.CreateCallback('cw-plateswap:server:getRealPlateFromFakePlate', function(source, cb, fakePlate)
   local realPlateFromDb = MySQL.Sync.fetchAll('SELECT plate FROM player_vehicles WHERE fakeplate = ?', {fakePlate})
   if useDebug then
      print('real plate:',dump(realPlateFromDb))
   end
   if realPlateFromDb[1] then
      cb(realPlateFromDb[1].plate)
   else
      cb(false)
   end
end)

QBCore.Functions.CreateCallback('cw-plateswap:server:getFakePlateFromRealPlate', function(source, cb, plate)
   local fakePlateFromDb = MySQL.Sync.fetchAll('SELECT fakeplate FROM player_vehicles WHERE plate = ?', {plate})
   if useDebug then
      print('fake plate', dump(fakePlateFromDb))
   end
   if fakePlateFromDb[1] then
      cb(fakePlateFromDb[1].fakeplate)
   else
      cb(false)
   end
end)

QBCore.Functions.CreateCallback('cw-plateswap:server:createItem', function(source, cb, fakePlate)
   if useDebug then
      print('creating plate item', fakePlate)
   end
   if plateExistsAsFakePlate(fakePlate) then
      if useDebug then
         print('CreateItem: ALREADY EXISTS')
      end
      cb('EXISTS')
   elseif plateBelongsToPlayer(fakePlate) then
      if useDebug then
         print('CreateItem: PLATE BELONGS TO PLAYER')
      end
      TriggerClientEvent('QBCore:Notify', source, Lang:t("error.plate_too_hot"), 'error')
      cb('PLAYER')
   else
      if useDebug then
         print('CreateItem: DIDNT EXIST')
      end
      local item = Config.LicensePlateItem
      local info = { plate = fakePlate }
   	local Player = QBCore.Functions.GetPlayer(source)
      if Config.Inventory == 'qb' then
         Player.Functions.AddItem(item, 1, nil, info)
         TriggerClientEvent('inventory:client:ItemBox', source, getQBItem(item), "add")
      elseif Config.Inventory == 'ox' then
         exports.ox_inventory:AddItem(source, item, 1, info)
      end
      cb('OK')
   end
end)

QBCore.Functions.CreateCallback('cw-plateswap:server:removeFakePlate', function(source, cb, fakePlate)
   if useDebug then
      print('Removing fake plate', fakePlate)
   end
   local results = MySQL.Sync.fetchAll('SELECT plate FROM player_vehicles WHERE fakeplate = ?', {fakePlate} )
   if useDebug then
      print(dump(results))
   end
   MySQL.Sync.execute('UPDATE player_vehicles SET fakeplate = NULL WHERE fakeplate = ?', {fakePlate} )
   givePlate(source, fakePlate)
   cb(results[1].plate)
end)

QBCore.Functions.CreateCallback('cw-plateswap:server:setFakePlate', function(source, cb, fakePlate, plate)
   if useDebug then
      print('Setting fakeplate to', fakePlate, plate)
   end
   if plateExistsAsFakePlate(fakePlate) then
      if useDebug then
         print('Setplate: ALREADY EXISTS')
      end
      cb(false)
   else
      if useDebug then
         print('Setplate: DIDNT EXIST')
      end
      local item = Config.LicensePlateItem
      local Player = QBCore.Functions.GetPlayer(source)

      if Config.Inventory == 'qb' then
         Player.Functions.RemoveItem(item , 1)
         TriggerClientEvent('inventory:client:ItemBox', source, getQBItem(item), "remove")
      elseif Config.Inventory == 'ox' then
         exports.ox_inventory:RemoveItem(source, item,1)
      end

      MySQL.Sync.execute('UPDATE player_vehicles SET fakeplate = ? WHERE plate = ?', {fakePlate, plate} )
      cb(true)
   end
end)

QBCore.Functions.CreateCallback('cw-plateswap:server:getFakePlateId', function(source, cb)
   if useDebug then
      print('Getting plate from inventory')
   end
   local Player = QBCore.Functions.GetPlayer(source)
   local licenseplates = Player.Functions.GetItemsByName(Config.LicensePlateItem)
   if licenseplates then
      print(dump(licenseplates))
      if Config.Inventory == 'qb' then
         if licenseplates[1].info then
            cb(licenseplates[1].info.plate)
         else
            print('getFakePlateId: plate has no info')
         end
      elseif Config.Inventory == 'ox' then
         if licenseplates[1].metadata then
            cb(licenseplates[1].metadata.plate)
         else
            print('getFakePlateId: plate has no info')
         end
      end
   else
      if useDebug then
         print('getFakePlateId: DIDNT EXISt')
      end
      cb(false)
   end
end)

QBCore.Commands.Add('setfakeplate', 'Change the license plate of a car to a fake one. (Admin Only)',{ { name = 'New plate', help = 'new plate for the vehicle' } }, true, function(source, args)
   TriggerClientEvent('cw-plateswap:client:setFakePlate', source, args[1])
end, 'admin')

QBCore.Commands.Add('removefakeplate', 'Change the license plate of a car to a original. (Admin Only)',{}, true, function(source)
   TriggerClientEvent('cw-plateswap:client:removeFakePlate', source)
end, 'admin')


QBCore.Commands.Add('cwdebugplateswap', 'toggle debug for plateswap', {}, true, function(source, args)
    useDebug = not useDebug
    print('debug is now:', useDebug)
    TriggerClientEvent('cw-plateswap:client:toggleDebug',source, useDebug)
end, 'admin')

RegisterNetEvent('cw-plateswap:server:callCops', function(coords, streetLabel)
   local alertData = {
       title = Lang:t('info.police_message'),
       coords = {x = coords.x, y = coords.y, z = coords.z},
       description = Lang:t('info.police_description').. ' '..streetLabel
   }
   TriggerClientEvent("qb-phone:client:addPoliceAlert", -1, alertData)
end)