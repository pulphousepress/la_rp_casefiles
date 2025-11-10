# Los Animales RP — `la_rp_casefiles`

`la_rp_casefiles` houses the canonical data and core platform resources that power Los Animales RP. The repository is organized a
round four primary resources (`la_codex`, `la_core`, `la_engine`, and `la_admin`) plus an `addons/` directory for plug-in systems.
Each layer has a narrow focus so gameplay code, data, and operator tooling remain decoupled.

---

## Resource responsibilities

### `la_codex` — data only
* Stores JSON datasets that describe the world (vehicles, peds, factions, future add-ons).
* Validates files at runtime and exposes read-only exports (`GetCodexData`, `GetVehicleByModel`, `GetPedByModel`, `GetFactionById`).
* Emits console logs prefixed with `[la_codex]` summarizing dataset counts on start.

### `la_core` — API + status layer
* Boots before any gameplay resource, calls `la_codex` exports, and caches datasets locally.
* Publishes helper exports (`GetVehicleList`, `GetPedList`, `GetFactionList`, `FindVehicle`, `GetData`) so consumers never touch JSON directly.
* Provides `GetStatusSnapshot()` returning `{ time, codex_ok, vehicles_count, peds_count, factions_count, addons_registered }`.
* Emits `la_core:ready` and `la_core:codexUpdated` events whenever data is refreshed; exposes `/la_codex_reload` for console reloads.

### `la_engine` — runtime systems
* Loads modular systems (weather controller, era vehicle enforcement, ped gate) through a simple registry.
* Supplies exports such as `IsVehicleAllowed`, `IsPedAllowed`, and `GetAllowedVehicleModels` built entirely on `la_core` data.
* Provides audit commands (`/la_engine_audit_vehicles`, `/la_engine_audit_peds`) for debugging spawn lists.
* Expects all operator actions to flow through `la_admin`; no UI logic lives here.

### `la_admin` — control surface + addon registry
* Hosts the plugin registry with exports `RegisterAddon`, `GetRegisteredAddons`, and `GetAddonsByCapability`.
* Registers `/la_status` (codex snapshot) and `/la_addons [capability]` commands gated by ACE (`Config.AcePrincipal`).
* Queries `la_core:GetStatusSnapshot()` on startup and whenever commands are used to keep operators informed.
* Future NUI clients should consume registry exports instead of calling other resources directly.

### Addons (`addons/`)
* Each addon registers itself via `exports.la_admin:RegisterAddon({ ... })` during startup.
* Gameplay logic fetches data exclusively through `la_core` exports and interacts with systems via `la_engine`.
* Example: `addons/la_era_vehicles_ext` registers capabilities, queries `la_core` for vehicles, and prints allowed models on demand.

---

## Repo layout

```
[LA_RP_CASEFILES]/
├── la_codex/            # JSON datasets and loader exports
├── la_core/             # API + status layer built on codex exports
├── la_engine/           # Runtime systems registry (weather, vehicles, ped gate)
├── la_admin/            # Operator control surface + addon registry
├── addons/              # Example addons that plug into the registry
└── server.cfg           # Ensure order reference
```

---

## Working with the framework

1. **Ensure order** — place the core resources early so caches warm before gameplay scripts:
   ```cfg
   ensure la_codex        # data source of truth
   ensure la_core         # API layer and status exports
   ensure la_engine       # runtime systems consuming la_core
   ensure la_admin        # operator control + addon registry
   # addons register themselves via la_admin
   ensure addons/la_era_vehicles_ext
   ```

2. **Query data via `la_core` only**:
   ```lua
   local core = exports.la_core
   local vehicles = core:GetVehicleList()
   local lawPeds = core:FindVehicle({ type = 'emergency' })
   local status = core:GetStatusSnapshot()
   ```

3. **Register addons through `la_admin`**:
   ```lua
   AddEventHandler('onResourceStart', function(resource)
       if resource ~= GetCurrentResourceName() then return end

       exports.la_admin:RegisterAddon({
           name = 'la_radio_dispatch',
           resource = resource,
           version = '1.2.0',
           hooks = { 'onReady', 'onShutdown' },
           provides = { 'radio', 'dispatch' },
           maintainer = 'dispatch@losanimales.dev',
       })
   end)
   ```

4. **Interact with runtime systems through `la_engine`**:
   ```lua
   local allowed, entry = exports.la_engine:IsVehicleAllowed('police3', { faction = 'lapd' })
   if not allowed then
       print(('Vehicle blocked: %s'):format(entry and entry.label or 'unknown'))
   end
   ```

5. **Monitor health** — run `/la_status` or `/la_addons` (console or in-game with permissions) to inspect codex status and registered capabilities.

---

## Logging conventions

* `[la_codex]` — dataset load and validation warnings.
* `[la_core][level]` — API layer logs (codex sync, cache reloads).
* `[la_engine][level][system]` — runtime system output.
* `[la_admin][level]` — addon registry activity and command responses.
* `[LA_ADDON:<name>]` — addon-specific logs (see example addon for usage).

---

## Contributing guidelines

* Keep `la_codex` data-only; avoid embedding gameplay logic.
* Use `la_core` exports for all codex access—never read JSON files from other resources.
* Extend `la_engine` by adding new server modules that register through the system registry; do not hardcode integrations in `server/main.lua`.
* Surface new operator controls through `la_admin` so staff have a single entry point.
* When adding addons, include a startup registration snippet and document capabilities for discoverability.
