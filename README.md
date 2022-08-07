# Ironmon-Tracker

![Ironmon-Tracker_v0 2 0-min](https://user-images.githubusercontent.com/103706338/168518780-ceebdb88-57a8-49aa-b6b4-acc46c4d2101.gif)

Ironmon-Tracker is a collection of lua scripts for the [Bizhawk emulator](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher) used to track ironMON attempts.

For more information on ironMON, see <http://ironmon.gg>

If you find any bugs or have feature requests, feel free to create a [GitHub issue](https://github.com/besteon/Ironmon-Tracker/issues) or let us know in the Ironmon Discord server.

This project is based on [MKDasher's PokemonBizhawkLua project](https://github.com/mkdasher/PokemonBizhawkLua).

## Supported Games

For NDS (gen 4/5) games, please use the [NDS Ironmon Tracker](https://github.com/Brian0255/NDS-Ironmon-Tracker) by OnlySpaghettiCode

The following games are currently supported:

- Pokémon Ruby (U)
  - v1.0, v1.1, v1.2
- Pokémon Sapphire (U)
  - v1.0, v1.1, v1.2
- Pokémon Emerald (U)
- Pokémon FireRed (U)
  - v1.0, v1.1
- Pokémon LeafGreen (U)
  - v1.0, v1.1
- Pokémon Rojo Fuego (Spain)
- Pokémon Rouge Feu (France)
- Pokémon Rosso Fuoco (Italy)
- Pokémon Feuerrote (Germany)

With more non-english version support potentially coming in the future!

## Installation

1. **Get Bizhawk**: If you haven't used BizHawk before, [download the emulator](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher)
2. **Download the Tracker**: You can get the latest project release from the [releases](https://github.com/besteon/Ironmon-Tracker/releases/latest) section.
   - The main branch has additional changes and may not be stable. If you are feeling adventurous and wish to help us in finding bugs, you are more than welcome to clone the main branch. If the tracker crashes, please provide the log dump from the Lua Console to us via Discord or the [Issues](https://github.com/besteon/Ironmon-Tracker/issues) tab.
3. **Install and Setup**: See the full [Installation Guide](https://github.com/besteon/Ironmon-Tracker/wiki/Installation-Guide) for more detailed instructions for installing or upgrading.
4. **Quickstart Guide**: After getting it all setup, check out the [Quickstart Guide](https://github.com/besteon/Ironmon-Tracker/wiki/Quickstart-Guide) for an overview on how to use the Tracker and learn about all of the information that it displays.

## Latest Changes

- **_NEW!!_ Route tracking and info, Full ability tracking, Notes on last damage taken, and more!**

![image](https://user-images.githubusercontent.com/4258818/183269070-4ab20627-1364-47c1-ba99-b20115cc5609.png)

## Full Feature List

A full feature list is available on the [project's Wiki](https://github.com/besteon/Ironmon-Tracker/wiki/Feature-List).

## FAQ

### Common errors and solutions

---

Error: `Nothing happens and no error messages or output is shown in the Lua Console`

Cause: The `Ironmon-Tracker.lua` script was erased or overwritten. This often occurs when clicking the NEW button instead of OPEN.

Fix: Download the Tracker again from the release and replace your existing files.

---

Error: `Can't have lua running in two host threads at a time!`

Cause 1: Outdated version of Bizhawk.

Fix: Use [Bizhawk emulator](https://tasvideos.org/BizHawk/ReleaseHistory) version 2.8 or higher.

Cause 2: Having the "Autoload Last Slot" toggle turned on in `File -> Load State` when quick-loading seeds with savestates.

Fix: Disable the "Autoload Last Slot" toggle.
