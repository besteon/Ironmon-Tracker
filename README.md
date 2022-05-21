# Ironmon-Tracker

![Ironmon-Tracker_v0 2 0-min](https://user-images.githubusercontent.com/103706338/168518780-ceebdb88-57a8-49aa-b6b4-acc46c4d2101.gif)

Ironmon-Tracker is a collection of lua scripts for the Bizhawk emulator used to track ironMON attempts.
For more information on ironMON, see https://gist.github.com/valiant-code/adb18d248fa0fae7da6b639e2ee8f9c1

Only Emerald, Leaf Green, and Fire Red (Generation 3 games) are supported. If you find any bugs or have feature requests, feel free to create a [GitHub issue](https://github.com/besteon/Ironmon-Tracker/issues) or DM me on Discord. You can find me on the Ironmon Discord server.

This project is based on MKDasher's PokemonBizhawkLua project.
https://github.com/mkdasher/PokemonBizhawkLua

## Installation

1. Download the project from the [releases](https://github.com/besteon/Ironmon-Tracker/releases/) section. The main branch has additional changes and may be broken.
   - If you are feeling adventurous and wish to help us in finding bugs, you are more than welcome to clone the main branch. If the tracker crashes, please provide the log dump from the Lua Console to us via Discord or the [Issues](https://github.com/besteon/Ironmon-Tracker/issues) tab.
2. Unzip the project anywhere you like. We recommend using the `Lua` folder where you installed BizHawk. The ironmon_tracker folder must be in the same directory as Ironmon_Tracker.lua.
3. Configure your settings in the `Settings.ini` file. Provide a location where you have installed your seeds in the `ROMS_FOLDER` setting. Configure your controller buttons if you wish.
4. Load your ROM in [Bizhawk](https://tasvideos.org/Bizhawk) (use **version v2.8** or later for maximum compatibility)
5. Open the Lua Console (Tools -> Lua Console). Click on the folder icon and open `Ironmon_Tracker.lua` in the location you extracted it to.
   - If you installed the tracker in Bizhawk's `Lua` folder, this location is shown by default and you should see the `Ironmon_Tracker.lua` file right away.

If you want to use your controller to toggle stat prediction markers on opponent Pokémon, set Button Mode in the in-game options to LR to prevent help menu from displaying.

- **Settings.ini**: Modify this file to set your controller button configurations for toggling the battle view, selecting and toggling stat predictions, and quick loading a new seed.
- **Quick loading seeds**: You can create a bunch of seeds ahead of time, and then use a button combination to load the next seed. Seeds must be in a numerical order without leading zeroes.
  - _For example:_ you can start at 13 with a file name like `kaizo13.gba`. Pressing the button combination would then load `kaizo14.gba`. Press it again and `kaizo15.gba` is loaded. If you tried `kaizo00014.gba`, the quick load feature won't work. Remove the leading zeroes.

## FAQ

### Common errors and solutions

---

Error: `ironmon_tracker/Tracker.lua: attempt to index field 'field' (a nil value)`

Cause: Updating to a new version of the tracker and using a savestate from an older version.

Fix: Only update the tracker between runs when you can make a new savestate.

---

Error: `NullHawk does not implement memory domains NLua.Exceptions.LuaException: unprotected error in call to Lua API (0)`

Cause: Your roms must not have spaces in the names, or the `ROMS_FOLDER` path specified in `Settings.ini` is not correct. Your rom number also can't have leading zeros, such as Kaizo001.gba, Kaizo002.gba, etc. They must be Kaizo1.gba, Kaizo2.gba, etc.

Fix: Rename your roms so they don't have spaces in the names.

---

Error: `Can't have lua running in two host threads at a time!`

Cause: Outdated version of Bizhawk

Fix: Use Bizhawk 2.8
