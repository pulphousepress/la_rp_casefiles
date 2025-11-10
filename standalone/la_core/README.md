# Standalone `la_core`

## Structure
```
standalone/la_core/
├── fxmanifest.lua
├── config.lua
├── server.lua
└── client.lua
```

## Usage
1. Copy `la_core` directory from repository into the same `resources` folder as this standalone example.
2. Ensure Ox stack resources are started before this resource in `server.cfg`:
   ```cfg
   ensure oxmysql
   ensure ox_lib
   ensure la_core
   ensure la_core_standalone
   ```
3. Configure as needed:
   ```bash
   cp standalone/la_core/config.lua resources/la_core_standalone/config.lua
   ```
4. Start txAdmin or run `ensure la_core_standalone` from console.

## Expected Output
- Server console prints `[la_core][info] v1.0.2 loaded on server.`
- Running `/la_status` in-game or server console returns `[la_core][info] Active=true`.
