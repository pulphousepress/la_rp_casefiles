# Los Animales RP — `la_rp_casefiles`

`la_rp_casefiles` is the canonical data and config repository for the Los Animales RP server. It contains era policies, whitelists, shared JSON/Lua catalogs, server snippets, and contributor guidance used across LA resources. Gumshoe (the detective gameplay resource) is intentionally excluded and lives in `la_gumshoe`.

---

## Repository purpose

* Serve as the canonical dataset for era policies, whitelists, and shared configuration consumed by Los Animales RP resources.
* Document the runtime responsibilities of the new `la_core`-centric architecture.
* Provide copy/paste ready server snippets and recommended ensure order for production and staging servers.
* Centralize contributor guidance that keeps every dependent resource era-appropriate.

---

## Resource responsibilities under the new design

### `la_codex`

* Houses immutable data: era policies, vehicle/ped/item whitelists, shared JSON/Lua catalogs, and documentation.
* Exposes codified datasets to `la_core` through file exports only—no gameplay logic or runtime state lives here.
* Ship updates only when data changes; the package should not require a server restart for logic fixes because it must stay logic-free.

### `la_core`

* Primary API surface for the Los Animales ecosystem. All resources query codex data and shared state exclusively via `exports['la_core']` helpers.
* Maintains cached, validated views of codex datasets and provides standardized query, filtering, and validation methods.
* Owns common logging utilities and forwards structured log events (see "Logging conventions" below).

### `la_engine`

* Gameplay runtime and orchestration layer. Consumes `la_core` APIs to drive missions, jobs, spawn logic, and scheduling.
* Never reads codex files directly; it only reacts to events and data served through `la_core`.
* Emits operational metrics via the `la_core.logRuntime()` helper to ensure consistency with other resources.

### `la_admin`

* Administrative control plane used to register and manage addons.
* Provides exports such as `registerAddon`, `setAddonState`, and `getAddonStatus`, all of which internally call `la_core` to resolve codex references and enforce policy.
* Offers webhook/console logging for addon lifecycle events using the shared logging conventions.

### Addon resources (within `[addons]/` or third-party)

* Must depend on `la_core` and `la_admin` for data access and registration.
* Implement their own gameplay logic but fetch codex-backed metadata exclusively with `exports['la_core']`.
* During startup, call `exports['la_admin']:registerAddon({ ... })` to announce capabilities, whitelists they consume, and contact info for maintainers.

---

## Repo layout (recommended)

```
la_codex/
├─ README.md
├─ era/
│  ├─ 1950s-authentic_list.txt
│  ├─ veh_popgroup.txt
│  └─ asset_policy.md
├─ whitelists/
│  ├─ QBX_OX_WHITELIST.txt
│  ├─ QBX_OX_PEDS_WHITELIST.txt
│  └─ QBX_OX_FACTIONS_OCCUPATIONS_WHITELIST.txt
├─ tools/
│  ├─ la_peditor_promt.txt
│  └─ developer-ready-directive.txt
├─ snippets/
│  ├─ server.ensure.sample.cfg
│  └─ la_codex_server_snippets.md
└─ docs/
   ├─ CONTRIBUTING.md
   └─ LICENSE.md
```

Files in this repository are intended as data and policy only. Do not duplicate gameplay logic here. Reference these files from gameplay resources.

---

## Setup and integration basics

1. **Install the core resources.** Place `la_codex`, `la_core`, `la_engine`, and `la_admin` inside `[LA_RP_CASEFILES]/` (or another shared folder) and ensure they are started before any dependent addons.
2. **Query data through `la_core`.** Any resource that needs codex values must call the exported helpers:

   ```lua
   local codex = exports['la_core']
   local vehicles = codex:getVehicleWhitelist()
   local faction = codex:getFaction('lspd')
   ```

   Direct file reads from `la_codex` are not permitted. `la_core` maintains cache invalidation and format guarantees so downstream resources stay decoupled from raw files.

3. **Register addons via `la_admin`.** During resource startup, register capabilities before using `la_core` data:

   ```lua
   AddEventHandler('onClientResourceStart', function(resourceName)
       if resourceName ~= GetCurrentResourceName() then return end

       exports['la_admin']:registerAddon({
           name = 'la_radio_dispatch',
           version = GetResourceMetadata(resourceName, 'version', 0),
           maintainer = 'radio@losanimales.dev',
           requires = {
               codex = {'vehicles', 'factions'},
               coreExports = {'getVehicleWhitelist', 'getFaction'}
           }
       })
   end)
   ```

   `la_admin` will surface registration failures through structured logs and optional Discord/webhook alerts.

4. **Addon data flow.** After registration, the addon uses `la_core` exports to fetch data, listens for `la_core:codexUpdated` events for invalidation, and sends admin actions (enable/disable) back through `la_admin`.

5. **Server operators** should review the "Logging conventions" below and point all resources to a shared logging sink for consistent observability.

---

## Logging conventions

* **Namespace format:** `[LA][<resource>][<context>] message`. Example: `[LA][la_core][CodexSync] Cache refreshed (vehicles=542, peds=318)`.
* **Structured payloads:** When emitting JSON logs via `la_core.logStructured(event, payload)`, include `resource`, `level`, `version`, and `correlationId` fields.
* **Log levels:** `trace`, `debug`, `info`, `warn`, `error`, `fatal`. Default to `info`; reserve `error` and higher for actionable failures.
* **Cross-resource consistency:** Use `exports['la_core']:logRuntime(level, context, message, payload?)` from all resources (including addons) so logs include unified metadata and optional webhook forwarding.
* **GDPR/PII caution:** Do not log player identifiers beyond server IDs unless you have explicit policy approval documented in `docs/`.

---

## Server install - recommended ensure order

Place these `ensure` lines in your `server.cfg`. This example excludes Gumshoe. Adjust names to your resource folder names.

```cfg
# Base CFX resources
ensure mapmanager
ensure spawnmanager
ensure sessionmanager
ensure hardcap
ensure baseevents

# Core libraries
ensure oxmysql
ensure ox_lib

# QBox framework
ensure qbx_core
ensure qbx_management
ensure qbx_smallresources
ensure qbx_spawn
ensure qbx_vehicles

# Ox ecosystem
ensure ox_target
ensure ox_inventory
ensure ox_doorlock
ensure ox_fuel

# Voice and radio
ensure pma-voice
ensure mm_radio
ensure la_radio

# NPWD / phone
ensure screenshot-basic
ensure npwd
ensure qbx_npwd

# Los Animales codex + platform
ensure la_codex        # data only
ensure la_core         # centralized API, codex cache
ensure la_engine       # gameplay runtime uses la_core
ensure la_admin        # addon registry

# First-party addons (must register through la_admin)
ensure la_era_vehicles
ensure la_npcs
ensure la_peditor
# ensure la_radio_dispatch
# ensure la_courthouse

# Optional / experimental (keep after core)
# ensure la_toonzone
```

If you host Gumshoe separately, place `la_gumshoe` under a detective section or its own group.

---

## Era policy - quick rules

* Default allowed asset years: **1920 through 1969**. Anything outside this range requires explicit namespacing and justification.
* Namespacing conventions for exceptions:

  * Toontown / Cartoon: `la:toontown:*` or `peditor:toontown:*`
  * Offworld / Fantasy: `la:offworld:*` or `peditor:UFO:*`
  * Other exceptions: use `la:other:*` prefix and document intent.
* Modern, post-1969 items are blocked unless a contributor provides a PR with a gameplay justification and maintainer approval. See `developer-ready-directive.txt` for enforcement and style rules.

---

## How to add an asset or whitelist entry

1. Fork the repo and add your entry to the appropriate file in `/whitelists/`. Match the existing format exactly.
2. For non-era assets, use the correct namespace prefix and include a one-line justification.
3. Provide the following in your PR: a screenshot or model preview, exact asset name or model hash, source and license, and intended spawn context (ambient, job, vendor, etc.).
4. Run the 10-second in-game smoke test (below) locally or on a staging server, then open a PR. Keep PRs focused - one asset or one rule change per PR.

---

## 10-second in-game smoke test

Use this short checklist to validate la_codex changes before merging to production:

1. Ensure `la_codex` and dependent resources are ensured on the server.
2. Confirm the server console shows `ensure la_codex` with no startup errors.
3. Use admin status command (implement `la_status` in la_core) to verify codex version and whitelist counts.
4. Spawn one whitelisted era vehicle to verify the vehicle is allowed and spawns correctly.
5. Open the appearance editor and confirm the ped whitelist matches `QBX_OX_PEDS_WHITELIST.txt`.

If any step fails, check resource logs and verify file encoding and line endings on whitelist files.

---

## Integration notes

* `la_codex` is data only. Gameplay resources should never read its files directly—always depend on `exports['la_core']` for whitelists, factions, and policy lookups so cache invalidation remains centralized.
* pEditor (and other first-party addons) should declare their data requirements when registering with `la_admin`, then call the specific `la_core` exports described in `la_peditor_promt.txt`.
* Keep update frequency reasonable. Breaking whitelist format or `la_core` export contracts will cause startup errors across multiple LA resources.

---

## Contributing (short)

* Keep PRs focused and atomic.
* Provide evidence and license info for assets.
* Use proper namespacing for exceptions.
* Run the smoke test before submitting PRs.
* Follow the coding and formatting conventions in `developer-ready-directive.txt` and `CONTRIBUTING.md`.

See `docs/CONTRIBUTING.md` for PR templates and full review checklist.

---

## License

This repository uses the MIT License. See `docs/LICENSE.md` for full text. Attribution is appreciated.

---

## References and further reading

* `la_gumshoe` README and resource docs - Gumshoe is a separate resource and not included here.
* pEditor prompt and developer directive files in `/tools/`.
* Era asset guidance in `/era/1950s-authentic_list.txt`.

---

## Contact and maintenance

Maintain `la_codex` as the canonical dataset for Los Animales RP. For urgent changes that affect live servers, create a Pull Request with the required evidence and tag server maintainers.
