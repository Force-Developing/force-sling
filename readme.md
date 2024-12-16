# FiveM Sling System / Weapons on back

The resource allows players to manage weapon sling positions in the game, dynamically reflecting the weapons they have in their inventory. This enhances immersion and adds a realistic touch to your FiveM server. [Documentation](https://force-developing.gitbook.io/docs/free-resources/force-sling)

---

## Features

- **Debug Mode**: Enable or disable debug mode for troubleshooting.
- **Locale Support**: Set the locale for the resource.
- **Admin Configuration**: Manage admin commands and permissions.
- **Framework Support**: Compatible with ESX, QBCore, and custom frameworks.
- **Inventory System**: Supports various inventory systems including qs-inventory, qb-inventory, core_inventory, and ox_inventory.
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
     Config.Framework.name = "esx" -- Set to your framework: "esx", "qbcore", or "custom".
     Config.Inventory = "ox_inventory" -- Match your inventory system: "auto", "qs_inventory", etc.
     ```

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
  - Supported languages: `ar`, `en`, `es`, `fr`, `pt`, `de`, `nl`, `pl`, `ru`, `se`, or `auto`.
- **Admin Tools**:
  - Add admin player identifiers under the `Config.Admin.Global.players` array.
- **Framework Support**:
  - Supports ESX, QBCore, or custom frameworks.
- **Inventory Integration**:
  - Compatible with popular inventory systems like `ox_inventory` and `qb_inventory`.

Refer to the Configuration section for detailed information on each setting.

---

## Commands

The resource provides several commands to manage weapon positions:

- **`/sling`**

  - **Description**: Configure weapon positions.
  - **Permission**: Any player can use this command.

- **`/resetsling`**

  - **Description**: Reset personal sling position to global.
  - **Permission**: Any player can use this command.

- **`/slingpreset`**
  - **Description**: Configure global weapon positions.
  - **Permission**: Only admins are allowed to use this by default.

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
