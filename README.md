# Ironmon-Tracker

### [General Information](#general-information) | [Supported Games](#supported-games) | [Installation](#installation) | [Latest Changes](#latest-changes) | [Contributing](#contributing)

![Ironmon-Tracker_v0 2 0-min](https://user-images.githubusercontent.com/103706338/168518780-ceebdb88-57a8-49aa-b6b4-acc46c4d2101.gif)

## General Information

Ironmon-Tracker is a collection of lua scripts for the [Bizhawk emulator](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher) or [mGBA emulator](https://mgba.io/downloads.html)* (v0.10.0 or higher) used to track IronMon attempts.
> *mGBA's lua scripting is currently limited and doesn't provide any drawing functionality, this means the tracker on mGBA is purely text-based in the scripting window as we can't draw images/screens like on Bizhawk.

For more information on IronMon, see <http://ironmon.gg>

We have a set of [Wiki](https://github.com/besteon/Ironmon-Tracker/wiki/) pages documenting various parts of the tracker, including a full [Feature List](https://github.com/besteon/Ironmon-Tracker/wiki/Feature-List).

If you have any issues using the tracker, check the [FAQ & Troubleshooting](https://github.com/besteon/Ironmon-Tracker/wiki/FAQ-&-Troubleshooting) page first to see if your issue has a known solution. If your issue isn't listed there, or if you find any bugs or have feature requests, feel free to create a [GitHub issue](https://github.com/besteon/Ironmon-Tracker/issues) or let us know in the [IronMon Discord server](https://discord.com/invite/jFPYsZAhjX).

This project is based on [MKDasher's PokemonBizhawkLua project](https://github.com/mkdasher/PokemonBizhawkLua).

## Supported Games

For NDS (gen 4/5) games, please use the [NDS IronMon Tracker](https://github.com/Brian0255/NDS-Ironmon-Tracker) by OnlySpaghettiCode

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

1. **Download the Ironmon Tracker**
   - You can get the latest project release from the [Releases](https://github.com/besteon/Ironmon-Tracker/releases/latest) section of this Github repository.
2. **Get a Supported Emulator**
   - We recommend using the Bizhawk emulator (Windows/Linux only)
	  - [Download Bizhawk](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher)
	  - If you are on Windows, make sure to also download and run the [prereq installer](https://github.com/TASEmulators/BizHawk-Prereqs/releases) first
	  - If you are on Linux, we recommend using Bizhawk 2.9 or higher
   - Alternatively, you can use the MGBA emulator (Windows/Mac/Linux)
      - [Download MGBA](https://mgba.io/downloads.html) (v0.10.0 or higher)
3. **Install and Setup**
   - See the full [Installation Guide](https://github.com/besteon/Ironmon-Tracker/wiki/Installation-Guide) for more detailed instructions for installing or upgrading.
   - If you are on Linux, you'll also want to install the [Franklin Gothic Medium font](https://fontsgeek.com/fonts/Franklin-Gothic-Medium-Regular).
4. **Quickstart Guide**
   - After getting it all setup, check out the [Quickstart Guide](https://github.com/besteon/Ironmon-Tracker/wiki/Quickstart-Guide) for an overview on how to use the Tracker and learn about all of the information that it displays.

## Latest Changes

### Custom Code Extensions

![image](https://user-images.githubusercontent.com/4258818/218183892-744fab56-6ed0-4797-bf7e-3c313cc017ef.png)

See the project's Wiki for a full [Version Changelog](https://github.com/besteon/Ironmon-Tracker/wiki/Version-Changelog).

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

- **Main**: This is kept in a state of the latest release. We merge into this branch from dev when we are ready to do the final checks and make a new release.
- **Dev**: This is essentially the "staging" build of the next release, where the majority of contributions merge into.
- **Beta-Test**: This branch is for test builds that Tracker users can opt-in to trying out. It regularly gets updated with new features from the dev branch.

**Make your PRs to the Dev branch.**

The workflow we'd recommend for contributing:

1. Create a fork of the repository.
2. Create a branch on your local fork for your new feature/contribution. Make your commits to this branch.
3. When you are ready to send it to us for review, open a Pull Request back to this repository. Request to merge into the **Dev** branch.
4. We'll review the Pull Request and decide whether it needs some changes / more work or if we're happy to merge it in.
