# FiveM Sling System / Weapons on back

The resource allows players to manage weapon sling positions in the game, dynamically reflecting the weapons they have in their inventory. This enhances immersion and adds a realistic touch to your FiveM server. [Documentation](https://docs.forcedevelopments.com/) [Forum](https://forum.cfx.re/t/free-sling-system-weapons-on-back-esx-qb-core-custom/5290047)

---

## Features

- **Debug Mode**: Enable or disable debug mode for troubleshooting.
- **Locale Support**: Set the locale for the resource.
- **Admin Configuration**: Manage admin commands and permissions.
- **Framework Support**: ESX, QBCore and QBox out of the box. Other frameworks through `client/custom/frameworks/custom.lua`, which you fill in for your framework.
- **Inventory System**: Supports ox_inventory, qs-inventory, qb-inventory, core_inventory and tgiann-inventory, plus the default ESX loadout and QBCore/QBox player items. Other inventories through `client/custom/inventory.lua`.
- **Weapon Attachments**: Enable or disable weapon attachments.
- **Command Configuration**: Customize commands for configuring weapon positions.
- **Preset Commands**: Use preset configurations for weapon positions.
- **Bone Configuration**: Configure player bones where the weapon can be attached.
- **Editable Weapons**: Manage configurations for editable weapons.

### Preview

![Controls while placing](https://gyazo.com/b2210eeaf30198c1e55c5d5add9c3236/raw)
_Controls while placing_

![Config menu ingame](https://gyazo.com/21121fb8b2f86d9f8752baf3d91e239c/raw)
_Config menu ingame_

![Placement](https://gyazo.com/8f8babbad18d25745ebcc799cad05b2c/raw)
_Placement_

---

## Prerequisites

Before setting up the resource, ensure that you have the following dependency installed:

- **ox_lib**: This library is required for the resource to function correctly.
  - **GitHub Repository**: [ox_lib](https://github.com/overextended/ox_lib)
  - **Documentation**: [ox_lib Documentation](https://overextended.dev/ox_lib)

---

## Installation

1. **Download and Install**

   - Clone or download this repository to your `resources` folder in your FiveM server.

2. **Install ox_lib**

   - Ensure that you have `ox_lib` installed. You can find it on [GitHub](https://github.com/overextended/ox_lib) or refer to the [ox_lib Documentation](https://overextended.dev/ox_lib) for installation instructions.

3. **Configure**

   - Open the `config.lua` file and modify settings to fit your server’s framework and preferences.
   - Example:
     ```lua
     Config.Locale = "en" -- Change to your preferred language (e.g., "fr", "es", "ru").
     Config.Framework.name = "auto" -- Or set it: "esx", "qbcore", "qbx" or "custom".
     Config.Inventory = "auto" -- Or set it: "ox_inventory", "qs-inventory", "none", etc.
     ```
   - With `"auto"` the server detects the framework and inventory and passes the result to every client, so the start order in `server.cfg` doesn't matter. A framework that is installed but not started yet is waited for, with a red "Waiting for the framework" line every 10 seconds.
   - Custom frameworks: put your code inside the `RegisterFramework("custom", function() ... end)` block in `client/custom/frameworks/custom.lua`.

4. **Add to Server Config**

   - Add the following line to your `server.cfg`:
     ```cfg
     ensure ox_lib
     ensure force-sling
     ```

5. **Start Your Server**

   - Restart your server or the resource to load the resource.

---

## Configuration

The resource includes a [config.lua](https://github.com/Force-Developing/force-sling/blob/main/config.lua) file to customize functionality:

- **Debug Mode**:
  - Enable or disable debug logging.
- **Locale**:
  - Set the language for the system.
  - Supported languages: `ar`, `en`, `es`, `fr`, `pt`, `de`, `nl`, `pl`, `ru`, `sv`, or `auto` (follows the `ox:locale` convar).
- **Admin Tools**:
  - Global admins are players with the `admin` ace (`add_ace group.admin admin allow` in `server.cfg`) or listed in `Config.Admin.Global.players` (empty by default).
- **Framework Support**:
  - Supports ESX, QBCore, QBox, or custom frameworks.
- **Inventory Integration**:
  - Compatible with `ox_inventory`, `qs-inventory`, `qb-inventory`, `core_inventory` and `tgiann-inventory`.
- **Saved data**:
  - `json/positions.json` (player positions) and `json/presets_custom.json` (presets saved in-game) are created at runtime and kept when you update. `json/presets.json` holds the shipped defaults and is overwritten on update.

Refer to the Configuration section for detailed information on each setting.

---

## Commands

The resource provides several commands to manage weapon positions:

- **`/sling`**

  - **Description**: Configure weapon positions.
  - **Permission**: Any player can use this command.

- **`/resetsling [weapon]`**

  - **Description**: Reset your personal sling position for the weapon in your hand (or the weapon you name) back to the preset.
  - **Permission**: Any player can use this command.

- **`/slingpreset`**
  - **Description**: Configure global weapon positions. Saved to `json/presets_custom.json`.
  - **Permission**: Only global admins can use this by default.

Refer to the Commands section for a list of available commands and their usage.

---

## License

This project is licensed under the GPL License. See the [LICENSE](https://github.com/Force-Developing/force-sling/blob/main/LICENSE) file for more details.

---

## Contributing

We appreciate contributions! To contribute:

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature-name`
3. Commit your changes: `git commit -m 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Create a pull request.

---

## Support

For questions, issues, or feature requests, please open an [issue](https://github.com/Force-Developing/force-sling/issues) or reach out on our [Discord](https://discord.gg/927gfpcyDe).

---

Thank you for using the resource. We hope this documentation helps you get the most out of the resource.
