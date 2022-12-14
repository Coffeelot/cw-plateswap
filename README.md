# Plate Swaps 🍽
A QB based script for stealing plates and attaching them to other vehicles. Plates are added to inventory as items. The original plates for player owned vehicles are left untouched in the database, and you can always swap back to original plates from a fakeplate.

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
- Export to see if cars are using a fake plate or not: `isFakePlate`
- Export to get the real plate of a car with a fake plate: `getRealPlateFromFakePlate`
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

Example use:
```
local isFakePlate = exports['cw-plateswap']:isFakePlate(vehiclePlate)
local realPlate = nil
if isFakePlate then
    realPlate = exports['cw-plateswap']:isFakePlate(getRealPlateFromFakePlate)
end
```
Now you can use `realPlate` somewhere as the plate to check DB or whatever. Good luck. 