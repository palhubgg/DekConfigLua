# DekConfigLua

This script works with [Mod Config Menu](https://www.nexusmods.com/palworld/mods/577) created by @Dekita and allows you to use his configuration menu with Lua scripts.

## Installation

1. Follow [Mod Config Menu](https://www.nexusmods.com/palworld/mods/577) installation instructions.
2. Download and the source for [`lunajson`](https://github.com/grafi-tt/lunajson/tree/master/src) and place into your `Mods/shared/` folder.
3. Download [`scripts/DekConfig.lua`](./scripts/DekConfig.lua) and copy into your `Mods/shared/` folder.

Your final `Mods/shared` folder should look like this:

```plaintext
Mods/shared/
├── DekConfig.lua
├── lunajson.lua
└── lunajson/
    ├── ...
```

## Usage

After following the instructions at [palworld-modconfig-devhelp](https://github.com/dekita/palworld-modconfig-devhelp) to create your mod configuration file. You can use the following Lua code to consume the settings in your own Lua mod:

To consume settings from the configuration menu, you need to create a Lua script and use the `DekConfig` class.

```lua
local DekConfig = require "DekConfig"
local ModConfig = DekConfig.Use("AutoJoinConfiguredServer", "0.1")

-- Manually reload the configuration:
ModConfig:Reload()

-- Get the current ServerAddress live setting
CurrentServer = ModConfig:GetSetting("ServerAddress")

-- Set the ServerAddress live setting and write it to disk
ModConfig:SetSetting("ServerAddress", "127.0.0.1:12345")

```
