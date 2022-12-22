# Ironmon-Tracker

### [General Information](#general-information) | [Supported Games](#supported-games) | [Installation](#installation) | [Latest Changes](#latest-changes) | [Contributing](#contributing)

![Ironmon-Tracker_v0 2 0-min](https://user-images.githubusercontent.com/103706338/168518780-ceebdb88-57a8-49aa-b6b4-acc46c4d2101.gif)

## General Information

Ironmon-Tracker is a collection of lua scripts for the [Bizhawk emulator](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher) or [mGBA emulator](https://mgba.io/downloads.html) (v0.10.0 or higher) used to track ironMON attempts.

For more information on ironMON, see <http://ironmon.gg>

We have a set of [Wiki](https://github.com/besteon/Ironmon-Tracker/wiki/) pages documenting various parts of the tracker, including a full [Feature List](https://github.com/besteon/Ironmon-Tracker/wiki/Feature-List).

If you have any issues using the tracker, check the [FAQ & Troubleshooting](https://github.com/besteon/Ironmon-Tracker/wiki/FAQ-&-Troubleshooting) page first to see if your issue has a known solution.

If your issue isn't listed there, or if you find any bugs or have feature requests, feel free to create a [GitHub issue](https://github.com/besteon/Ironmon-Tracker/issues) or let us know in the Ironmon Discord server.

This project is based on [MKDasher's PokemonBizhawkLua project](https://github.com/mkdasher/PokemonBizhawkLua).

## Supported Games

For NDS (gen 4/5) games, please use the [NDS Ironmon Tracker](https://github.com/Brian0255/NDS-Ironmon-Tracker) by OnlySpaghettiCode

Currently supported Pokémon games / languages:

| Version  | Ruby | Sapphire | Emerald | FireRed | LeafGreen |
| :------: | :----------: | :--------------: | :-------------: | :-------------: | :---------------: |
| English  | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |
| Spanish  | ❌ | ❌ | ❌ | ✔️ | ❌ |
| French   | ❌ | ❌ | ❌ | ✔️ | ❌ |
| Italian  | ❌ | ❌ | ❌ | ✔️ | ❌ |
| German   | ❌ | ❌ | ❌ | ✔️ | ❌ |
| Japanese | ❌ | ❌ | ❌ | ❌ | ❌ |

We'd ideally like to support all non-English versions if we can, progress updates can be found [here](https://github.com/besteon/Ironmon-Tracker/issues/62).

## Installation

1. **Get a Supported Emulator**:
   - We recommend using the Bizhawk emulator (Windows/Linux only).
	   - [Download Bizhawk](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher)
		- If you are on Windows, make sure to also download and run the [prereq installer](https://github.com/TASEmulators/BizHawk-Prereqs/releases) first
		- If you are on Linux, we recommend using Bizhawk 2.9 or higher
	- Alternatively, you can use the MGBA emulator (Windows/Mac/Linux).
	   - [Download MGBA](https://mgba.io/downloads.html) (v0.10.0 or higher)
2. **Download the Tracker**: You can get the latest project release from the [releases](https://github.com/besteon/Ironmon-Tracker/releases/latest) section.
   - The main branch contains some extra dev files not intended for the main releases. You can clone this if you want but for most users we'd recommend the downloads in the releases section.
	- The staging branch may have additional features not fully tested. If you're feeling adventurous then you are more than welcome to clone this. If you come across issues then let us know, providing full logs and output from the lua console for any errors.
3. **Install and Setup**: See the full [Installation Guide](https://github.com/besteon/Ironmon-Tracker/wiki/Installation-Guide) for more detailed instructions for installing or upgrading.
   - If you are on Linux you'll also want to install the Franklin Gothic Medium font located [here](https://fontsgeek.com/fonts/Franklin-Gothic-Medium-Regular).
4. **Quickstart Guide**: After getting it all setup, check out the [Quickstart Guide](https://github.com/besteon/Ironmon-Tracker/wiki/Quickstart-Guide) for an overview on how to use the Tracker and learn about all of the information that it displays.

## Latest Changes

- **_NEW!!_ MGBA Emulator Support!**

![image](https://user-images.githubusercontent.com/4258818/209012095-c2c4d9d7-7f09-4764-afe4-1461f77ceb16.png)

- **_NEW!!_ Full Tracked Move History**

![image](https://user-images.githubusercontent.com/4258818/209043481-ad71a433-92ca-47f1-9e24-94790dab70dc.png)

See the project's Wiki for a full [version changelog](https://github.com/besteon/Ironmon-Tracker/wiki/Version-Changelog).

## Contributing

If you'd like to contribute to the tracker, great! Here's some information for you on our processes and setup.

If you're planning to implement a new feature, we'd ask that you either open a feature request issue on GitHub or talk to us in the Ironmon Discord server about your idea first. This is so we can discuss if it's a good fit for the tracker and how best to implement the feature, before you go through any effort of coding it up.

### What is a good fit for the Ironmon Tracker?

Generally, we try to avoid revealing too much information that a player can't gather themself in-game in some way. For example, we *won't* show a Pokémon's EVs and IVs directly as you don't get that information in the games. We also like to try and make toggleable options for certain features for those that would rather have them disabled.

Additionally, if the feature involves a UI element on the tracker screen, we want to make it as clear and simple to use as we can. There's limited space on the tracker screens so we also want to avoid cramming too many things in or extending the current size of the tracker (as this would mess with many people's stream layouts).

### Development Set-Up

There are a couple of VS Code extensions which we recommend, which should automatically be recommended to you in your VS Code:

- [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig): To help with consistent formatting.
- [vscode-lua](https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua): Provides intellisense and linting for Lua.

Lua Versions:
- Bizhawk 2.8 uses Lua 5.1, this is the version currently set in our `.vscode/settings.json` file for linting.
- Bizhawk 2.9 and mGBA use Lua 5.4
   - Since we intend to still support Bizhawk 2.8 the code must be compatible with both Lua 5.1 and 5.4

Emu-specific Lua documentation:
- [Bizhawk Lua Functions](https://tasvideos.org/Bizhawk/LuaFunctions)
- [mGBA Scripting API](https://mgba.io/docs/scripting.html)

### Branches and Processes

The primary branches of the Ironmon-Tracker repository are as follows:

- Main: This is kept in a state of the latest release. We merge into this branch from staging when we are ready to do the final checks and make a new release.
- Staging: This is essentially the "beta" build of the next release, where the majority of contributions merge into.
- Bugfixes: This branch is for any quick/minor bugfixes. It regularly gets updated to match and pull fixes into the staging branch.

**Make your PRs to either Staging or Bugfixes, whichever is more fitting for the contribution.**

The workflow we'd recommend for contributing:

1. Create a fork of the repository.
2. Create a branch on your local fork for your new feature/contribution. Make your commits to this branch.
3. When you are ready to send it to us for review, open a Pull Request back to this repository. Request to merge into either Staging or Bugfixes depending on what the contribution is (see above).
4. We'll review the Pull Request and decide whether it needs some changes / more work or if we're happy to merge it in.
