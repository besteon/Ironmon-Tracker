# Ironmon-Tracker

![Ironmon-Tracker_v0 2 0-min](https://user-images.githubusercontent.com/103706338/168518780-ceebdb88-57a8-49aa-b6b4-acc46c4d2101.gif)

Ironmon-Tracker is a collection of lua scripts for the [Bizhawk emulator](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher) used to track ironMON attempts.
For more information on ironMON, see https://gist.github.com/valiant-code/adb18d248fa0fae7da6b639e2ee8f9c1

Only Emerald, Leaf Green, and Fire Red (Generation 3 games) are supported. If you find any bugs or have feature requests, feel free to create a [GitHub issue](https://github.com/besteon/Ironmon-Tracker/issues) or DM me on Discord. You can find me on the Ironmon Discord server.

This project is based on MKDasher's PokemonBizhawkLua project.
https://github.com/mkdasher/PokemonBizhawkLua

## Installation

1. Download the project from the [releases](https://github.com/besteon/Ironmon-Tracker/releases/) section. The main branch has additional changes and may be broken.
   - If you are feeling adventurous and wish to help us in finding bugs, you are more than welcome to clone the main branch. If the tracker crashes, please provide the log dump from the Lua Console to us via Discord or the [Issues](https://github.com/besteon/Ironmon-Tracker/issues) tab.
2. Unzip the project anywhere you like. We recommend using the `Lua` folder where you installed BizHawk. The ironmon_tracker folder must be in the same directory as Ironmon_Tracker.lua.
3. Configure your settings in the `Settings.ini` file. Provide a location where you have installed your seeds in the `ROMS_FOLDER` setting. Configure your controller buttons if you wish.
4. Load your ROM in [Bizhawk](https://tasvideos.org/BizHawk/ReleaseHistory) (use **version v2.8** or later for maximum compatibility)
5. Open the Lua Console (Tools -> Lua Console). Click on the folder icon and open `Ironmon_Tracker.lua` in the location you extracted it to.
   - If you installed the tracker in Bizhawk's `Lua` folder, this location is shown by default and you should see the `Ironmon_Tracker.lua` file right away.

If you want to use your controller to toggle stat prediction markers on opponent Pokémon, set Button Mode in the in-game options to LR to prevent help menu from displaying.

## Latest Changes

<div style="display:flex">
	<img style="padding-right:5px" src="https://user-images.githubusercontent.com/5532354/171784220-39601761-3df8-48d1-aff4-620e7d34de46.png" alt="Tracker with new gear icon">
	<img src="https://user-images.githubusercontent.com/5532354/171784322-812000bb-55d2-4358-960b-79cfcb7f8c5d.png" alt="The tracker settings menu">
</div>

- **_NEW!!_ Settings**: You can now modify **nearly all** settings for the tracker within the tracker itself! Click on the gear icon near the Pokémon name to open the new Settings menu.
  - Click on a setting to turn it on or off!
  - Click on the Roms Folder setting to open a dialog that allows you to pick the folder where your files are stored.
    - Note: Pick any file in the desired folder. The folder itself will be saved as the setting.
    - Controller configuration will be coming to this menu soon!
  - The Settings.ini file will update with your changes when you close the settings menu. You can still modify this file to set your controller button configurations and any other option.

## Features

- **Your Pokémon**: Your Pokémon's stats, moves, ability, and more are tracked in real-time as you play! As you learn new moves and use them, level up, and use items, the tracker updates the appropriate information. It will also tell you the level or condition it needs to evolve, the number of moves it will learn, and the next level a move will be learned. All data is sourced from [Bulbapedia](https://bulbapedia.bulbagarden.net/wiki/Main_Page) except some evolution requirements based on the use of the randomizer.
- **Stat modifying moves**: If your opponent or you use a stat modifying move, like `Growl`, up and down chevrons are displayed next to the affected stat on the target. Up to three chevrons are displayed, and change color when the fourth, fifth, and sixth stack are applied.
- **Enemy moveset**: Enemy Pokémon moves are unknown AND they change as the various Pokémon level up throughout the game! The tracker will display moves a Pokémon has as they use them, along with the basic PP, power, and accuracy information. When you encounter the same Pokémon type later in the game, old moves are marked with a `*` at the end of the name. This allows you to know that the move may still be known or may be replaced by a new move.
- **Stat Prediction**: Enemy Pokémon stats are unknown, but you can mark a prediction on which stats may be high or low by adding a + or - icon to the appropriate stat. This is accomplished on the enemy Pokémon by cycling through the stats with the L button and toggling the prediction with the R button.
- **Quick loading seeds**: You can create a bunch of seeds ahead of time, and then use a button combination to load the next seed. Seeds must be in a numerical order without leading zeroes.
  - _For example:_ you can start at 13 with a file name like `kaizo13.gba`. Pressing the button combination would then load `kaizo14.gba`. Press it again and `kaizo15.gba` is loaded. If you tried `kaizo00014.gba`, the quick load feature won't work. Remove the leading zeroes.
- **Notes**: Click on the bottom bar to leave a note about the Pokémon you are facing!
- **Move effectiveness**: Moves that are super effective or not very effective against the opposing Pokémon will display one or two chevrons next to the move's power stat. Moves that are completely ineffective will display a red `X`.
- **Attack type icons**: Icons for moves that are physical or special attack types can be displayed next to the move name.
- **Healing items**: The tracker displays the number of healing items on hand in the bag and what percentage of max HP of the currently displayed Pokémon those items will heal by.

## FAQ

### Common errors and solutions

---

Error: `Can't have lua running in two host threads at a time!`

Cause: Outdated version of Bizhawk

Fix: Use [Bizhawk emulator](https://tasvideos.org/BizHawk/ReleaseHistory) version 2.8 or higher

---

Error: `ironmon_tracker/Tracker.lua: attempt to index field 'field' (a nil value)`

Cause: Updating to a new version of the tracker and using a savestate from an older version.

Fix: Only update the tracker between runs when you can make a new savestate.

---

Error: `NullHawk does not implement memory domains NLua.Exceptions.LuaException: unprotected error in call to Lua API (0)`

Cause: Your roms must not have spaces in the names, or the `ROMS_FOLDER` path specified in `Settings.ini` is not correct. Your rom number also can't have leading zeros, such as Kaizo001.gba, Kaizo002.gba, etc. They must be Kaizo1.gba, Kaizo2.gba, etc.

Fix: Rename your roms so they don't have spaces in the names.
