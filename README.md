# Ironmon-Tracker

![ironmon_v0 1 3](https://user-images.githubusercontent.com/103706338/164341565-ee640cf1-0d30-4d94-adcb-6fce328c563b.gif)

Ironmon-Tracker is a collection of lua scripts for the Bizhawk emulator used to track ironMON attempts.
For more information on ironMON, see https://gist.github.com/valiant-code/adb18d248fa0fae7da6b639e2ee8f9c1

Only Emerald, Leaf Green, and Fire Red are supported. If you find any bugs or have feature requests, feel free to create a github issue or DM me on Discord. You can find me on the Ironmon Discord server.

This project is based on MKDasher's PokemonBizhawkLua project.
https://github.com/mkdasher/PokemonBizhawkLua

## Installation
1. Download the project from the **releases** section. The master branch has additional changes and may be broken.
2. Unzip the project anywhere you like. The script will create a database file in the same directory as ironmon_tracker.lua. The ironmon_tracker folder must be in the same directory as ironmon_tracker.lua.
3. Load your ROM in Bizhawk (use Bizhawk v2.8 or later for maximum compatibility)
4. Tools -> Lua Console -> Open Script -> ironmon_tracker.lua

In the in-game options, set Button Mode to LR if using a controller to prevent help menu from displaying when using using the stat prediction feature.

NOTE: When using savestates to save tracker data, SAVE TWICE! There is a bug that loads the previous save.

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
2. Item and Ability are not shown until they are utilized. (NOT YET IMPLEMENTED)
3. Stats are not shown. Instead, you can click to mark + or -, depending on if you think the pokemon may have good or bad stats.
4. Moves are only shown after being used in battle.
