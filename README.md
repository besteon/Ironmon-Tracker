# Ironmon-Tracker

![Ironmon-Tracker_v0 2 0-min](https://user-images.githubusercontent.com/103706338/168518780-ceebdb88-57a8-49aa-b6b4-acc46c4d2101.gif)

Ironmon-Tracker is a collection of lua scripts for the [Bizhawk emulator](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher) used to track ironMON attempts.

For more information on ironMON, see <http://ironmon.gg>

If you find any bugs or have feature requests, feel free to create a [GitHub issue](https://github.com/besteon/Ironmon-Tracker/issues) or let us know in the Ironmon Discord server.

This project is based on [MKDasher's PokemonBizhawkLua project](https://github.com/mkdasher/PokemonBizhawkLua).

## Supported Games

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

With more non-english version support potentially coming in the future!

For NDS (gen 4/5) games, please use the [NDS Ironmon Tracker](https://github.com/Brian0255/NDS-Ironmon-Tracker) by OnlySpaghettiCode

## Installation

0. If you haven't used BizHawk before, [download the emulator](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher).
   - **IMPORTANT**: _Run BizHawk once and **close** it_, then start it again before continuing! This ensures that BizHawk sets itself up properly on your system. Otherwise, the tracker may get some odd errors when trying to start it during your first use of BizHawk.
1. **Download** the project from the [releases](https://github.com/besteon/Ironmon-Tracker/releases/latest) section. The main branch has additional changes and may not be stable.
   - If you are feeling adventurous and wish to help us in finding bugs, you are more than welcome to clone the main branch. If the tracker crashes, please provide the log dump from the Lua Console to us via Discord or the [Issues](https://github.com/besteon/Ironmon-Tracker/issues) tab.
2. Unzip the project anywhere you like. We recommend extracting the full folder and all of its contents directly into the `Lua` folder where you installed BizHawk. Note: The `ironmon_tracker` folder must be in the same directory as `Ironmon-Tracker.lua`.
3. Load your ROM in [Bizhawk](https://tasvideos.org/BizHawk/ReleaseHistory) (use **version v2.8** or later for maximum compatibility)
4. Open the Lua Console in the Bizhawk program: `Tools -> Lua Console`). Then click the little folder icon to "Open a file" (or use `Script -> Open Script`) and select the `Ironmon-Tracker.lua` file in the location you extracted it to.
   - Be careful not to click the New file icon, Bizhawk does not warn you about overwriting scripts so it's easy to do so by mistake.
   - If you installed the tracker in Bizhawk's `Lua` folder, this location is shown by default and you should see the `Ironmon-Tracker.lua` file right away.
5. Configure the settings for the Tracker by clicking the gear/cog icon near the top of the tracker window. From here, provide a location where you keep your ROMs by clicking on the note icon next to where it says `Roms folder`. Additionally, you can customize the tracker's look-and-feel through the `Customize Theme` button.

If you want to use your controller to toggle stat prediction markers on opponent Pokémon, set Button Mode in the in-game options to LR to prevent the help menu from displaying.

## Latest Changes

- **_NEW!!_ Spanish/French support for FireRed**
- **_NEW!!_ Ruby/Sapphire Support, Move Info Look-up, & Optimization Improvements**

![image](https://user-images.githubusercontent.com/4258818/178802567-feb55355-a278-410b-8565-5216a56f44ec.png)

## Features

- **Your Pokémon**: Your Pokémon's stats, moves, ability, and more are tracked in real-time as you play! As you learn new moves and use them, level up, and use items, the tracker updates the appropriate information. It will also tell you the level or condition it needs to evolve, the number of moves it will learn, and the next level a move will be learned. All data is sourced from [Bulbapedia](https://bulbapedia.bulbagarden.net/wiki/Main_Page) except some evolution requirements based on the use of the randomizer.
- **Pokémon Info Look-up**: Click on the icon of your Pokémon or an enemy Pokémon to learn more details about them. This provides easy access to handy info like BST, Evolution(s), Weaknesses, and when the Pokémon learns each new move as it levels up.
- **Stat modifying moves**: If your opponent or you use a stat modifying move, like `Growl`, up and down chevrons are displayed next to the affected stat on the target. Up to three chevrons are displayed, and change color when the fourth, fifth, and sixth stack are applied.
- **Enemy abilities**: Click on the area where the enemy abilties are shown to change them, allowing you to take notes on which one or two abilities the Pokémon has. In some games, the abilities are automatically tracked for you.
- **Enemy moveset**: Enemy Pokémon moves are unknown AND they change as the various Pokémon level up throughout the game! The tracker will display moves a Pokémon has as they use them, along with the basic PP, power, and accuracy information. When you encounter the same Pokémon type later in the game, old moves are marked with a `*` at the end of the name. This allows you to know that the move may still be known or may be replaced by a new move.
- **Move Info Look-up**: Click on any move to learn more details about that move. This will often provide useful and cool details about the move you might not otherwise have known existed.
- **Stat Prediction**: Enemy Pokémon stats are unknown, but you can mark a prediction on which stats may be high or low by adding a + or - icon to the appropriate stat. This is accomplished on the enemy Pokémon by cycling through the stats with the L button and toggling the prediction with the R button.
- **Notes**: Click on the bottom bar to leave a note about the Pokémon you are facing!
- **Move effectiveness**: Moves that are super effective or not very effective against the opposing Pokémon will display one or two chevrons next to the move's power stat. Moves that are completely ineffective will display a red `X`.
- **Attack type icons**: Icons for moves that are physical or special attack types can be displayed next to the move name.
- **Healing items**: The tracker displays the number of healing items on hand in the bag and what percentage of max HP of the currently displayed Pokémon those items will heal by.
  - This feature only works in Emerald, Fire Red, and Leaf Green.
- **Quick loading seeds**: You can create a bunch of seeds (ROMs) ahead of time, and then use a button combination to load the next seed. Seeds must be in a numerical order.
  - _For example:_ you can start at 13 with a file name like `kaizo13.gba`. Pressing the button combination would then load `kaizo14.gba`. Press it again and `kaizo15.gba` is loaded.
- **Settings**: You can now modify **nearly all** settings for the tracker within the tracker itself! Click on the gear icon near the Pokémon name to open the new Settings menu.
  - Click on a setting to turn it on or off!
  - Click on the Roms Folder setting to open a dialog that allows you to pick the folder where your files are stored.
    - Note: Pick any file in the desired folder. The folder itself will be saved as the setting.
  - Edit Controller configuration to change up what buttons are used to toggle the view, or load the next seed.
  - The Settings.ini file will update with your changes when you close the settings menu. You can still modify this file if you really need to..
- **Themes**: Customize the way your tracker looks by editing the theme colors for any of it's element.
  - Choose from a handful of preloaded themes.
  - Want to make a small change, or change everything? Go for it! Changes will save in your Settings.ini file so they persist between play sessions.
  - Got a cool theme you want to share, or want to try using a theme someone else has created? You can use Export and Import to do just that.

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
