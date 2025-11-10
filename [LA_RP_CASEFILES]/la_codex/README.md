# la_codex

`la_codex` is the Los Animales source of truth for world data. It ships structured JSON files only—no gameplay logic—so that oth
ers can load consistent definitions for vehicles, peds, factions, and future datasets.

## Layout

```
la_codex/
├── fxmanifest.lua          # declares server loader/export surface
├── server/main.lua         # loads & validates JSON data, exposes exports
├── data/
│   ├── vehicles.json       # vehicle descriptors with era tags and faction gating
│   ├── peds.json           # ped descriptors with categories
│   ├── factions.json       # faction descriptors
│   └── addons.json         # optional metadata describing addon packages
└── README.md
```

## JSON schemas

Each JSON file may contain inline comments (`//` or `/* */`) which the loader strips before decoding. The loader validates base f
ields and logs warnings tagged with `[la_codex]` when malformed entries are encountered.

### `vehicles.json`

Array of objects:

```jsonc
{
  "model": "speedo",            // spawn name (required)
  "label": "Vapid Speedo",      // display label (required)
  "era_tag": "universal",       // classification for admin filtering (required)
  "type": "commercial",         // category such as emergency/civilian (required)
  "allowed_factions": ["lapd"], // optional list of faction ids that may operate the vehicle
  "notes": "context"            // optional maintainer note
}
```

### `peds.json`

Array of objects:

```jsonc
{
  "model": "s_m_y_cop_01",  // ped model (required)
  "label": "Mission Row Patrol", // display label (required)
  "category": "law",         // classification used by gating logic (required)
  "notes": "optional notes"  // optional
}
```

### `factions.json`

Array of objects:

```jsonc
{
  "id": "lapd",               // unique identifier (required)
  "name": "Los Angeles Police Department", // display label (required)
  "category": "law",          // classification used by systems (required)
  "notes": "optional notes"   // optional
}
```

### `addons.json`

Optional array describing known addons. Fields are not enforced beyond being objects with `name` and `resource` strings so that
maintainers can document packaged extensions.

## Exports

`server/main.lua` exposes the following server exports for consumption by `la_core` and tests:

* `GetCodexData(dataType)` — returns the requested dataset (`"vehicles"`, `"peds"`, `"factions"`, or `"addons"`). When omitted,
  the entire codex table is returned.
* `GetVehicleByModel(model)` — returns the vehicle entry by spawn name.
* `GetPedByModel(model)` — returns the ped entry by model.
* `GetFactionById(id)` — returns the faction entry by id.

These exports never mutate the underlying JSON. If you need to reload the codex at runtime, restart the resource or implement a
trigger in `la_admin` that restarts it and notifies dependents.
