# Ironmon-Tracker

Ironmon-Tracker is a collection of lua scripts for the Bizhawk emulator used to track ironMON attempts.
For more information on ironMON, see https://gist.github.com/valiant-code/adb18d248fa0fae7da6b639e2ee8f9c1

Currently, only Emerald, Leaf Green, and Fire Red are supported. If you find any bugs or have feature requests, feel free to create a github issue or DM me on Discord (Dementio#7078). You can find me on the Ironmon Discord server.

## Installation
1. Unzip the project anywhere you like. The script will create a database file in the same directory as ironmon_tracker.lua. The ironmon_tracker folder must be in the same directory as ironmon_tracker.lua.
2. Load your ROM in Bizhawk
3. Tools -> Lua Console -> Open Script -> ironmon_tracker.lua

## Features
OVERWORLD

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

BATTLE

![battle](https://user-images.githubusercontent.com/103706338/163879091-b86f026e-050d-42a4-8ad8-28e110e763c5.png)

When in battle, similar information is shown, with the following differences:
1. Current HP is not shown
2. Item and Ability are not shown until they are utilized. (NOT YET IMPLEMENTED)
3. Stats are not shown. Instead, you can click to mark + or -, depending on if you think the pokemon may have good or bad stats.
4. Moves are only shown after being used in battle.

### TODO

1. Opponent Pokemon's item
2. Opponent Pokemon's ability
3. Controller support
