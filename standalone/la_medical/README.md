# Standalone `la_medical`

Minimal example showing the revive handler by itself.

## Usage
1. Copy `la_medical` to your resources and ensure Ox stack is running.
2. Place this folder as `resources/la_medical_standalone`.
3. Update `server.cfg`:
   ```cfg
   ensure ox_lib
   ensure la_medical
   ensure la_medical_standalone
   ```
4. Optional: edit `config.lua` to change revive coordinates.

## Expected Output
- After a player dies they respawn at configured hospital coordinates with notification.
