# Plate Swaps 🍽
A QB based script for stealing plates and attaching them to other vehicles. Plates are added to inventory as items. The original plates for player owned vehicles are left untouched in the database, and you can always swap back to original plates from a fakeplate.

It does come with some limitations currently. You can not park your vehicles with a fake plate on without editing your garage script (see last section of readme for examples). Modifying a vehicle will not save changes in database (same thing as garages). The script is also set up to not allow stealing player-plates. Just because this might cause problems with saving in databases etc, a toggle to enable this at your own risk might be introduced.

# Preview 📽
[![YOUTUBE VIDEO](http://img.youtube.com/vi/m9LxymEF9wI/0.jpg)](https://youtu.be/m9LxymEF9wI)


# Developed by Coffeelot and Wuggie
[More scripts by us](https://github.com/stars/Coffeelot/lists/cw-scripts)  👈

**Support, updates and script previews**:

[![Join The discord!](https://cdn.discordapp.com/attachments/977876510620909579/1013102122985857064/discordJoin.png)](https://discord.gg/FJY4mtjaKr )

**All our scripts are and will remain free**. If you want to support what we do, you can buy us a coffee here:

[![Buy Us a Coffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/cwscriptbois )

# Features 🌟
- Steal license plates from local cars and apply them to yours
# Planned features 🤔
- Legal plate changes

# Not happening ⛔
- Adding this to any phone or laptop script

# Config 🔧
**LicensePlateItem**: The item used for the plates, if you wanna change em
**InteractionItem**: Set this if you want to have an item requirement to remove and add the plate

***Settings:***
**RemoveItem**: How long to remove a plate
**AddTime**: How long to apply a plate
**PoliceCallChance**: How big the chance of police being called

It uses qb-phone for the police alert by default, if you want to change it then you can find the Event trigger at the bottom of `server.lua`

## Being able to park or modify cars with fake plates
You'll have to figure this out yourself. Somewhere in the scripts, wherever there's a plate check that compares to the database you'll need to use the exports `isFakePlate` to check the plates and then `getRealPlateFromFakePlate` to get the real plate you want to modify. 

Example use: Let's say you have a script where it needs to check the car in the database. It obviously uses plate to map to something in the db, but your plate is fake! Naughty Naughty!
In the code the plate of the car is `plate` and the vehicle entity is `veh`.
```
exports['cw-plateswap']:resetPlateIfFake(plate, veh)
```
After this is used, your car will have it's real plate, but keep the fake plate in the db.

Whenever you want to put the fake plate back on you can call this:
```
exports['cw-plateswap']:applyFakePlateIfExists(plate, veh)
```

Example of implementation in qb-garages (gotta honk twice to park lol):
![example](https://media.discordapp.net/attachments/1038602226282807446/1053002560597934210/image.png)
