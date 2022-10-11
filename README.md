# Ironmon-Tracker

### [General Information](#general-information) | [Supported Games](#supported-games) | [Installation](#installation) | [Latest Changes](#latest-changes) | [Contributing](#contributing)

![Ironmon-Tracker_v0 2 0-min](https://user-images.githubusercontent.com/103706338/168518780-ceebdb88-57a8-49aa-b6b4-acc46c4d2101.gif)

## General Information

Ironmon-Tracker is a collection of lua scripts for the [Bizhawk emulator](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher) used to track ironMON attempts.

For more information on ironMON, see <http://ironmon.gg>

We have a set of [Wiki](https://github.com/besteon/Ironmon-Tracker/wiki/) pages documenting various parts of the tracker, including a full [Feature List](https://github.com/besteon/Ironmon-Tracker/wiki/Feature-List).

If you have any issues using the tracker, check the [FAQ & Troubleshooting](https://github.com/besteon/Ironmon-Tracker/wiki/FAQ-&-Troubleshooting) page first to see if your issue has a known solution.

If your issue isn't listed there, or if you find any bugs or have feature requests, feel free to create a [GitHub issue](https://github.com/besteon/Ironmon-Tracker/issues) or let us know in the Ironmon Discord server.

This project is based on [MKDasher's PokemonBizhawkLua project](https://github.com/mkdasher/PokemonBizhawkLua).

## Supported Games

For NDS (gen 4/5) games, please use the [NDS Ironmon Tracker](https://github.com/Brian0255/NDS-Ironmon-Tracker) by OnlySpaghettiCode

The following games/languages are currently supported:

| Version  | Pokémon Ruby | Pokémon Sapphire | Pokémon Emerald | Pokémon FireRed | Pokémon LeafGreen |
| :------: | :----------: | :--------------: | :-------------: | :-------------: | :---------------: |
| English  | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ |
| Spanish  | ❌ | ❌ | ❌ | ✔️ | ❌ |
| French   | ❌ | ❌ | ❌ | ✔️ | ❌ |
| Italian  | ❌ | ❌ | ❌ | ✔️ | ❌ |
| German   | ❌ | ❌ | ❌ | ✔️ | ❌ |
| Japanese | ❌ | ❌ | ❌ | ❌ | ❌ |

We'd ideally like to support all non-English versions if we can, see [here](https://github.com/besteon/Ironmon-Tracker/issues/62) for progress updates if you're curious.

## Installation

1. **Get Bizhawk**: If you haven't used BizHawk before, [download the emulator](https://tasvideos.org/BizHawk/ReleaseHistory) (v2.8 or higher)
   - If you are on windows, make sure to also download and run the [prereq installer](https://github.com/TASEmulators/BizHawk-Prereqs/releases) first.
2. **Download the Tracker**: You can get the latest project release from the [releases](https://github.com/besteon/Ironmon-Tracker/releases/latest) section.
   - The main branch contains some extra dev files not intended for the main releases. You can clone this if you want but for most users we'd recommend the downloads in the releases section.
	- The staging branch may have additional features not fully tested. If you're feeling adventurous then you are more than welcome to clone this. If you come across issues then let us know, providing full logs and output from the lua console for any errors.
3. **Install and Setup**: See the full [Installation Guide](https://github.com/besteon/Ironmon-Tracker/wiki/Installation-Guide) for more detailed instructions for installing or upgrading.
   - If you are on Linux you'll also want to install the Franklin Gothic Medium font located [here](https://fontsgeek.com/fonts/Franklin-Gothic-Medium-Regular).
4. **Quickstart Guide**: After getting it all setup, check out the [Quickstart Guide](https://github.com/besteon/Ironmon-Tracker/wiki/Quickstart-Guide) for an overview on how to use the Tracker and learn about all of the information that it displays.

## Latest Changes

- **_NEW!!_ Random Ball Picker!**

![image](https://user-images.githubusercontent.com/4258818/194925877-c97f8676-550a-40e7-b813-9b730ed53c38.png)

See the project's Wiki for a full [version changelog](https://github.com/besteon/Ironmon-Tracker/wiki/Version-Changelog).

## Contributing

If you'd like to contribute to the tracker, great! Here's some information for you on our processes and setup.

If you're planning to implement a new feature, we'd ask that you either open a feature request issue on GitHub or talk to us in the Ironmon Discord server about your idea first. This is so we can discuss if it's a good fit for the tracker and how best to implement the feature, before you go through any effort of coding it up.

### What is a good fit for the Ironmon Tracker?

Generally, we try to avoid revealing too much information that a player can't gather themself in-game in some way. For example, we *won't* show a Pokémon's EVs and IVs directly as you don't get that information in the games. We also like to try and make toggleable options for certain features for those that would rather have them disabled.

Additionally, if the feature involves a UI element on the tracker screen, we want to make it as clear and simple to use as we can. There's limited space on the tracker screens so we also want to avoid cramming too many things in. When it comes to displaying something on the tracker we want to make it clear to both users and potential stream viewers.

### Development Set-Up

There are a couple of VS Code extensions which we recommend, which should automatically be recommended to you in your VS Code:

- [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig): To help with consistent formatting.
- [vscode-lua](https://marketplace.visualstudio.com/items?itemName=trixnz.vscode-lua): Provides intellisense and linting for Lua.

Bizhawk currently uses Lua 5.1, and provides some additional [Lua Functions](https://tasvideos.org/Bizhawk/LuaFunctions) which allow for communicating with and drawing on the emulator.

### Branches and Processes

The Ironmon-Tracker main repository has three branches:

- Main: This is kept in a state of the latest release. We merge into this branch from staging when we are ready to do the final checks and make a new release.
- Staging: This is essentially the "beta" build of the next release, where the majority of contributions merge into. If you are contributing a feature we'd ask that you make your Pull request to this branch.
- Bugfixes: As the name implies, this branch is for any quick/minor bugfixes. It regularly gets updated to match and pull fixes into the staging branch. If your contribution is a bugfix of some sort, we'd recommend making the Pull request to this branch.

The workflow we'd recommend for contributing is as follows:

1. Create a fork of the repository.
2. Create a branch on your local fork for your new feature/contribution. Make your commits to this branch.
3. When you are ready to send it to us for review, open a Pull Request back to the main repository. Request to merge into either Staging or Bugfixes depending on what the contribution is (see above).
4. We'll review the Pull Request and decide whether it needs some changes / more work or if we're happy to merge it in.
