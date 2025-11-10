# la_engine

`la_engine` hosts runtime systems that consume `la_core` APIs. Each system registers through a lightweight registry provided by `s
erver/main.lua`, keeping gameplay logic modular and decoupled from operator tooling.

## Systems

* **Weather Controller** (`server/weather_controller.lua`) — pulls weather rules from the codex and broadcasts updates to clients.
* **Era Vehicles** (`server/era_vehicles.lua`) — caches codex vehicle data and exposes whitelist helpers/commands.
* **Ped Gate** (`server/ped_gate.lua`) — caches codex ped data and answers allow/deny queries for spawn/appearance scripts.

Additional systems can be added by dropping a new Lua file in `server/` that returns either a system spec table or a function that calls `registry:Register(spec)`.

## Registry contract

A system spec looks like this:

```lua
return {
    id = 'my_system',
    label = 'My System',
    order = 50, -- optional load order (lower loads first)
    bootstrap = function(ctx)
        -- called during la_engine startup
    end,
    onCoreReady = function(ctx, datasets)
        -- optional: runs when la_core finishes its initial codex sync
    end,
    onCodexUpdated = function(ctx, datasets)
        -- optional: runs whenever la_core refreshes codex data
    end,
}
```

`ctx` helpers available to systems:

* `ctx.log(level, message)` — logs with `[la_engine][level][system]` prefix.
* `ctx.fetchVehicles()` / `ctx.fetchPeds()` / `ctx.fetchFactions()` — convenience wrappers over `la_core` exports.
* `ctx.fetchDataset(name)` — wraps `exports.la_core:GetData(name)` for arbitrary datasets.
* `ctx.registerTick(fn)` — runs `fn` inside a detached Citizen thread.
* `ctx.registerExport(name, fn)` — registers a server export on behalf of the system.
* `ctx.onCoreReady(handler)` / `ctx.onCodexUpdated(handler)` — event subscriptions.

Systems can still register commands or events directly if they prefer. The registry simply centralizes bootstrapping and context helpers.

## Exports

`la_engine` currently exposes:

* `IsVehicleAllowed(model, opts?)` — provided by the era vehicles system.
* `IsPedAllowed(model)` — provided by the ped gate system.
* `GetAllowedVehicleModels()` — provided for backwards compatibility; pulls from the same cache as `IsVehicleAllowed`.

## Commands

* `/la_engine_audit_vehicles` — prints codex vehicle counts and sample blocked models (console or players with ACE access).
* `/la_engine_audit_peds` — prints codex ped counts.

Commands are routed through individual systems using the shared `Config` values and can be modified per environment.
