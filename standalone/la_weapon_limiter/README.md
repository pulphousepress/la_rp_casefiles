# Standalone `la_weapon_limiter`

Example resource showing the limiter with default config.

## Usage
1. Install Ox Inventory and Ox Lib.
2. Copy `la_weapon_limiter` to resources and place this folder as `la_weapon_limiter_standalone`.
3. Update `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure ox_inventory
   ensure ph_shared
   ensure la_weapon_limiter
   ensure la_weapon_limiter_standalone
   ```
4. Adjust `config.lua` to map jobs to allowed weapons.

## Expected Output
- When a player equips a restricted weapon they receive a notification and the action is blocked/stripped according to mode.
