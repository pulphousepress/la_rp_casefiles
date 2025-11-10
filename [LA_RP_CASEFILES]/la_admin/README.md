# la_admin

`la_admin` is the operator control surface for Los Animales RP. It exposes a centralized addon registry, status commands, and a s
keleton client ready for future NUI work. All gameplay-facing controls must route through this resource so server staff have a s
ingular touchpoint.

## Responsibilities

* Host the addon registry used by first- and third-party systems.
* Provide status and addon inventory commands (`/la_status`, `/la_addons`).
* Offer exports (`RegisterAddon`, `GetRegisteredAddons`, `GetAddonsByCapability`) so addons can announce capabilities at runtime.
* Query `la_core` for health snapshots to power dashboards and diagnostics.

## Layout

```
server/main.lua          # boots the registry, wires commands, exposes exports
server/addons_registry.lua # core registry implementation and normalization helpers
server/commands.lua      # `/la_status` and `/la_addons` command handlers
client/main.lua          # placeholder for future NUI logic
client/ui_fallback.lua   # temporary chat-based feedback
config.lua               # toggle keybinds, ACE principal, dev overrides
```

## Exports

| Export | Description |
| --- | --- |
| `RegisterAddon(descriptor)` | Register an addon with fields such as `name`, `resource`, `version`, `hooks`, `provides`. Returns `true, descriptor` on success. |
| `GetRegisteredAddons()` | Returns an array of registered addon descriptors sorted by registration order. |
| `GetAddonsByCapability(capability)` | Returns addons that advertise the specified capability (case-insensitive). |

### Descriptor schema

```lua
exports.la_admin:RegisterAddon({
    name = 'Weather Control',
    resource = GetCurrentResourceName(),
    version = '1.0.0',
    hooks = { 'onReady', 'onShutdown' },
    provides = { 'weather', 'time_control' },
    maintainer = 'systems@losanimales.dev',
})
```

The registry deduplicates by `resource` name and keeps the latest descriptor. Capabilities and hooks are stored as sorted, lowerc
ased strings for easy querying.

## Commands

* `/la_status` — prints codex health along with cached counts and addon totals.
* `/la_addons [capability]` — lists registered addons. When a capability is provided, results are filtered to matching entries.

Command access is guarded by `Config.AcePrincipal` (`group.admin` by default). Enable `Config.AllowAnyoneInDev = true` while buil
ding locally to bypass ACE checks.

## Config

`config.lua` exposes:

```lua
Config = {
    Debug = false,
    ToggleKey = 'F10',
    Command = 'la_admin',
    AllowAnyoneInDev = true,
    AcePrincipal = 'group.admin',
    StatusCommand = 'la_status',
    AddonsCommand = 'la_addons',
}
```

Adjust keybinds and ACE principal to fit your server policy. The client scripts remain placeholder-only; when the NUI is implemen
ted it should consume the registry exports instead of direct server calls.
