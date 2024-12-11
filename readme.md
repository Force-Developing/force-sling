# FiveM Sling System

FiveM sling system for positioning weapons on a player's body, dynamically reflecting the weapons they have in their inventory. This enhances immersion and adds a realistic touch to your FiveM server.

---

## Features

- **Realistic Weapon Placement**: Automatically attach weapons to a player’s body based on their carried weapons.
- **Configurable System**: Fully customizable options for frameworks, inventory systems, and language localization.
- **Dynamic Positions**: Completely customize weapons positions for each weapon on a player level.
- **Lightweight and Efficient**: Optimized to run smoothly on FiveM servers without impacting performance.

---

## Installation

1. **Download and Extract**

   - Clone or download this repository to your `resources` folder in your FiveM server.

2. **Configure**

   - Open the `config.lua` file and modify settings to fit your server’s framework and preferences.
   - Example:
     ```lua
     Config.Locale = "en" -- Change to your preferred language (e.g., "fr", "es", "ru").
     Config.Framework.name = "esx" -- Set to your framework: "esx", "qbcore", or "custom".
     Config.Inventory = "ox_inventory" -- Match your inventory system: "auto", "qs_inventory", etc.
     ```

3. **Add to Server Config**

   - Add the following line to your `server.cfg`:
     ```cfg
     ensure force-sling
     ```

4. **Start Your Server**

   - Restart your server or the resource to load the resource.

---

## Configuration

The resource includes a `config.lua` file to customize functionality:

- **Debug Mode**:
  - Enable or disable debug logging.
- **Locale**:
  - Set the language for the system.
  - Supported languages: `ar`, `en`, `es`, `fr`, `pt`, `de`, `nl`, `pl`, `ru`, `sv`, or `auto`.
- **Admin Tools**:
  - Add admin player identifiers under the `Config.Admin.Global.players` array.
- **Framework Support**:
  - Supports ESX, QBCore, or custom frameworks.
- **Inventory Integration**:
  - Compatible with popular inventory systems like `ox_inventory` and `qb_inventory`.

---

## Commands

- **`/sling`**
  - **Description**: Configure weapon positions.
  - **Permission**: Any player can use this command.

---

## Dependencies

This resource works out of the box but integrates seamlessly with:

- ox_lib: [github](https://github.com/overextended/ox_lib)

---

## License

This project is licensed under the GPL License. See the `LICENSE` file for more details.

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
