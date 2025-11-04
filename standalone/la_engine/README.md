# Standalone Harness: la_engine

Minimal resource to exercise `la_engine` without other modules. Useful for manual smoke testing on a blank QBox stack.

## Files
- `fxmanifest.lua`
- `config.lua`
- `server.lua`
- `client.lua`

## Usage
```bash
cp config.lua.example config.lua
ensure la_engine_standalone
```

The `/la_engine_status` command should print `engine active` in the console.
