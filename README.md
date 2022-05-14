# Ironmon-Tracker

![ironmon_v0 1 3](https://user-images.githubusercontent.com/103706338/164341565-ee640cf1-0d30-4d94-adcb-6fce328c563b.gif)

Ironmon-Tracker is a collection of lua scripts for the Bizhawk emulator used to track ironMON attempts.
For more information on ironMON, see https://gist.github.com/valiant-code/adb18d248fa0fae7da6b639e2ee8f9c1

Only Emerald, Leaf Green, and Fire Red (Generation 3 games) are supported. If you find any bugs or have feature requests, feel free to create a [GitHub issue](https://github.com/besteon/Ironmon-Tracker/issues) or DM me on Discord. You can find me on the Ironmon Discord server.

This project is based on MKDasher's PokemonBizhawkLua project.
https://github.com/mkdasher/PokemonBizhawkLua

## Installation

1. Download the project from the [releases](https://github.com/besteon/Ironmon-Tracker/releases/) section. The main branch has additional changes and may be broken.
   - If you are feeling adventurous and wish to help us in finding bugs, you are more than welcome to clone the main branch. If the tracker crashes, please provide the log dump from the Lua Console to us via Discord or the [Issues](https://github.com/besteon/Ironmon-Tracker/issues) tab.
2. Unzip the project anywhere you like. We recommend using the `Lua` folder where you installed BizHawk. The ironmon_tracker folder must be in the same directory as ironmon_tracker.lua.
3. Configure your settings in the `Settings.ini` file. Provide a location where you have installed your seeds in the `ROMS_FOLDER` setting. Configure your controller buttons if you wish.
4. Load your ROM in [Bizhawk](https://tasvideos.org/Bizhawk) (use **version v2.8** or later for maximum compatibility)
5. Open the Lua Console (Tools -> Lua Console). Click on the folder icon and open `ironmon_tracker.lua` in the location you extracted it to.
   - If you installed the tracker in Bizhawk's `Lua` folder, this location is shown by default and you should see the `ironmon_tracker.lua` file right away.

If you want to use your controller to toggle stat prediction markers on opponent Pokémon, set Button Mode in the in-game options to LR to prevent help menu from displaying.

**NOTE:** When using savestates to save tracker data, _SAVE TWICE!_ There is a bug that loads the previous save.

## Features

### Overworld View:

![overworld](https://user-images.githubusercontent.com/103706338/163878628-16465876-c8e1-41d4-abff-907c7d53cf80.png)

When not in battle, the tracker shows stats for the first pokemon in your party, including:

1. Species
2. Current HP
3. Level
4. Level or item needed to evolve.
5. Held item
6. Ability
7. All stats, with highlighting depending on the nature.
8. BST
9. Moves
10. How many moves your pokemon can learn. (does not take evolving into account)
11. The level at which your pokemon will learn another move.

### Battle View:

![battle](https://user-images.githubusercontent.com/103706338/163879091-b86f026e-050d-42a4-8ad8-28e110e763c5.png)

When in battle, similar information is shown, with the following differences:

1. Current HP is not shown
2. Stats are not shown. Instead, you can click to mark + or -, depending on if you think the pokemon may have good or bad stats. You can also use your controller to mark the stats. By default, the L button selects the box and the R button toggles between +, -, and empty.
3. Moves are only shown after being used in battle. If you have seen the Pokémon and some of it's moves previously, and this Pokémon has increased in level, an `*` will appear to denote that the move list is old and may have changed.
4. As you or the opponent receive stat modifiers, up or down arrows will appear next to the stat to show how much it has changed.

### Other features:

- **Settings.ini**: Modify this file to set your controller button configurations for toggling the battle view, selecting and toggling stat predictions, and quick loading a new seed.
- **Quick loading seeds**: You can create a bunch of seeds ahead of time, and then use a button combination to load the next seed. Seeds must be in a numerical order without leading zeroes.
  - _For example:_ you can start at 13 with a file name like `kaizo13.gba`. Pressing the button combination would then load `kaizo14.gba`. Press it again and `kaizo15.gba` is loaded. If you tried `kaizo00014.gba`, the quick load feature won't work. Remove the leading zeroes.

### Coming soon:

- **Move category markers:** icons that show if a move is a physical or special type of attack. Status effect moves will have no associated marker.
- **Type effectiveness:** Markers next to the move's power will appear to show how effective the move is against the opponent. Moves that have no effect will have an `X`.

## FAQ

### Common errors and solutions

---

Error: `ironmon_tracker/Tracker.lua: attempt to index field 'field' (a nil value)`

Cause: Updating to a new version of the tracker and using a savestate from an older version.

Fix: Only update the tracker between runs when you can make a new savestate.

---

Error: `NullHawk does not implement memory domains NLua.Exceptions.LuaException: unprotected error in call to Lua API (0)`

Cause: Your roms must not have spaces in the names, or the path specified in Settings.ROMS_FOLDER is not correct. Your rom number also can't have leading zeros, such as Kaizo001.gba, Kaizo002.gba, etc. They must be Kaizo1.gba, Kaizo2.gba, etc.

Fix: Rename your roms so they don't have spaces in the names, and make sure the slashes in your `ROMS_FOLDER` setting are double backspaced.

- Example: `C:\\gba\\roms` and NOT `C:\gba\roms`

---

Error: `Can't have lua running in two host threads at a time!`

Cause: Outdated version of Bizhawk

Fix: Use Bizhawk 2.8

---

### Frequently Asked Questions

---

Q: Are you going to add X information to the tracker?

A: All info on the tracker should be either googlable or presented to the player by the game. This tracker is designed to give NO informational edge whatsoever. For example, enemy mon health % is not something that will be added, because eyeballing the health bar and praying for a damage roll is a large part of the game.

---

Q: Enemy Abilities/Items are not tracked, what gives?

A: This feature is not implemented yet and far more complicated under the hood than move tracking is. These features will take a while.
