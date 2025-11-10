# la_core

`la_core` is the platform API for Los Animales RP. It sits between the codex (`la_codex`) and every runtime system, caching data,
providing query helpers, and exposing health information to operator tooling.

## Responsibilities

* Bootstrap codex datasets (`vehicles`, `peds`, `factions`) via the `la_codex` exports and cache them locally.
* Publish friendly exports for consumers (`GetVehicleList`, `GetPedList`, `GetFactionList`, `FindVehicle`, `GetStatusSnapshot`).
* Broadcast `la_core:ready` and `la_core:codexUpdated` events so systems can react to codex refreshes.
* Offer a console-only `/la_codex_reload` command (configurable via `Config.ReloadCommand`) to repopulate caches without a full ser
ver restart.

## Layout

```
server/main.lua     # codex bootstrap, dataset caching, logging
server/exports.lua  # exported query helpers used by other resources
server/la_status.lua# status snapshot export used by la_admin and tooling
client/main.lua     # reserved for future shared client helpers
config.lua          # resource configuration (codex resource name, debug flags)
```

## Exports

| Export | Description |
| --- | --- |
| `GetVehicleList()` | Returns a shallow copy of the cached vehicle descriptors. |
| `GetPedList()` | Returns a shallow copy of the cached ped descriptors. |
| `GetFactionList()` | Returns a shallow copy of the cached faction descriptors. |
| `FindVehicle(filters)` | Returns vehicles matching filters such as `model`, `label`, `era_tag`, `type`, or `faction`. |
| `GetData(name)` | Returns a shallow copy of the requested codex dataset. |
| `GetStatusSnapshot()` | Returns `{ time, codex_ok, vehicles_count, peds_count, factions_count, addons_registered }`. |
| `GetVersion()` | Returns the version string defined in `config.lua`. |
| `PrintStatus()` | Logs the version and cached dataset summary to the server console. |

All exports use cached codex data. When `la_codex` restarts or `/la_codex_reload` is executed, caches refresh automatically and `l
a_core:codexUpdated` fires with the new dataset table.

## Events

* `la_core:ready` — emitted once the resource starts and the initial codex sync completes. Payload: `{ vehicles = {...}, peds = {...}, factions = {...} }`.
* `la_core:codexUpdated` — emitted after every successful refresh (manual or due to `la_codex` restarting).

## Configuration

`config.lua` exposes the following values:

```lua
Config = {
    CodexResource = 'la_codex',  -- resource name that serves codex data
    ReloadCommand = 'la_codex_reload', -- console command to refresh datasets
}
```

Update `CodexResource` if you rename the codex resource. Keep `la_core` early in your `server.cfg` ensure order so dependents can r
esolve exports immediately after start.
