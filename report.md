# Los Animales Codex – Comprehensive Audit (Rescan)

## Assumptions
- Environment: GravelHost-hosted FiveM server running QBox with txAdmin, Ox stack (`ox_lib`, `ox_target`, `oxmysql`, `ox_inventory`) preinstalled and started before Los Animales resources.
- Operators have shell access (Linux/macOS/WSL) with `git`, `lua`, MySQL client, and can install LuaRocks packages (`busted`, `luacheck`).
- Secrets (database credentials, Discord webhooks) are injected through environment variables or `server.cfg`; repository keeps only `config.example.lua` templates.
- `oxtarget` is available in the stack even though no current module consumes it; we reserve integration points in runtime design.
- `la_core` and the new `la_engine` runtime should be started ahead of gameplay modules; Gumshoe remains out-of-scope but must be able to subscribe later via exports.

## Executive Summary
- Added a production-safe `la_engine` scaffold that bootstraps `la_core`, exposes controller registration/dispatch helpers, and provides `init(cfg)` entrypoints for both server and client, satisfying the missing-runtime requirement for future Gumshoe subscriptions.
- Hardened `la_admin` by replacing leaked globals with explicit configs, introducing allow-listed console events, and wiring copy/paste-ready init scripts plus configuration templates.
- Expanded busted regression tests and helper stubs to cover `la_engine` and `la_admin`, keeping the global-leak guard intact so future modules must obey modular boundaries.
- Repository-wide rescan highlighted remaining legacy resources (`la_asset_registry`, `la_masks`, `la_era_traffic`, `la_phone_numbers`, `la_pop`) that still need modular refactors, SQL hygiene, and QBox-safe bootstraps; these are tracked below for follow-up patches.
- Runbook, dependency manifest, and standalone harnesses updated to include the new runtime layer while preserving novice-friendly deployment, rollback, and verification steps.

## Inventory Table
| Module/File | Purpose | Dependencies | Entry Point | Action |
|-------------|---------|--------------|-------------|--------|
| `la_core/server/main.lua` | Core status command + logging hook | `txAdmin`, optional `ox_lib`, consumed by `la_engine` | `Core.init(cfg)` | **Keep** (refactored) |
| `la_core/client/main.lua` | Client bootstrap / `/la_status` helper | None (optionally `ox_lib`) | `CoreClient.init(cfg)` | **Keep** (refactored) |
| `la_engine/server/main.lua` | Runtime controller hub, `la_core` integration | `la_core`, `txAdmin`, FiveM natives | `EngineServer.init(cfg)` | **Keep** (new) |
| `la_engine/client/main.lua` | Client runtime glue for future Gumshoe subscribers | `la_core` | `EngineClient.init(cfg)` | **Keep** (new) |
| `la_admin/server/main.lua` | Dispatch console event forwarder | `la_core` (optional), FiveM natives | `AdminServer.init(cfg)` | **Keep** (hardened) |
| `la_admin/client/main.lua` | Admin console UI toggles & NUI bridge | NUI, FiveM natives | `AdminClient.init(cfg)` | **Keep** (hardened) |
| `la_npcs/server/main.lua` | NPC whitelist/flag database management | `oxmysql`, `ph_shared`, `la_core`, GTA natives | `Server.init(cfg)` | **Rework** (needs config extraction for presets + query pooling) |
| `la_npcs/client/main.lua` | Local ped spawning / sandbox cleanup | GTA natives | `Client.init(cfg)` | **Keep** (monitor perf) |
| `la_medical/client.lua` | Player revive & notification loop | `ox_lib`, QBox events | `MedicalClient.init(cfg)` | **Keep** |
| `la_weapon_limiter/la_weapon_limiter.lua` | Weapon equip restriction with Ox inventory | `ox_inventory`, `ox_lib` | `Limiter.init(cfg)` | **Keep** |
| `la_asset_registry/la_asset_registry.lua` | Vehicle/ped whitelist enforcement | `ox_lib` optional, file I/O | Implicit global run | **Rework** (needs `init`, config modules, avoid `io.open`) |
| `la_masks/*` | Mask catalogue streaming + commands | FiveM natives | Implicit global run | **Rework** (missing `init`, leaked globals) |
| `la_era_traffic/client.lua` | Era vehicle spawn loop | GTA natives | Implicit global run | **Rework** (missing config module, infinite loop guard) |
| `la_phone_numbers` | Static phone number directory | None | `require` returning table | **Keep** (document) |
| `la_pop` | Population density overrides | FiveM natives | Implicit run | **Rework** (needs modular init & config) |
| `la_weather` | Weather board UI | NUI | Manifest load | **Keep** |
| `la_loadscreen` | Loading screen assets | NUI | Manifest load | **Keep** |
| `la_qbx__shim/server/framework/qbx.lua` | QBox compatibility exports | `ox_inventory`, `qbox` | `require` use | **Keep** (document) |
| `ph_shared/init.lua` | Shared key/value store | None | `require('ph_shared').new()` | **Keep** |
| `sql/*.sql` | NPC schema / seed / rollback | MySQL (`oxmysql`) | CLI execution | **Keep** |
| `patches/*.patch` | Turn-key fix bundles | git | `git apply --index` | **Keep** (add new admin/engine patch) |
| `standalone/*` | Harnesses for isolated testing | Module-specific | manifest `ensure` | **Keep** (added `la_engine`) |

## Issue List
1. **High – Legacy resources bypass modular runtime (`la_asset_registry`, `la_masks`, `la_era_traffic`, `la_pop`)**
   - *Repro:* Start resources; observe global `Config` tables and side-effecting loops without `init(cfg)`.
   - *Root Cause:* Pre-modular scripts never refactored after la_core/la_engine design.
   - *Fix:* Create config modules + bootstrap scripts mirroring `la_medical` pattern, replace `io.open` logging with structured logger, and integrate through `la_engine` controllers.
   - *Files:* `la_asset_registry/la_asset_registry.lua`, `la_masks/config.lua`, `la_masks/client/*.lua`, `la_era_traffic/client.lua`, `la_pop/*.lua`.

2. **Medium – `oxtarget` integration pathways undocumented**
   - *Repro:* Search repo; no references to `oxtarget` despite requirement.
   - *Root Cause:* Target zones not yet implemented in Los Animales modules.
   - *Fix:* Document in runbook and future tasks how to register zones via `lib.zones` once modules require interactive targets (e.g., la_medical clinics).
   - *Files:* Documentation (`report.md`, future modules).

3. **Medium – NPC seed data lacks migration tests**
   - *Repro:* Run `busted`; no spec ensures `sql/create.sql` matches runtime queries.
   - *Root Cause:* Test suite only covers Lua init.
   - *Fix:* Add integration spec using `oxmysql` mock verifying table/index names and parameter usage.
   - *Files:* `tests/test_modules_spec.lua`, `tests/spec_helper.lua` (future work).

4. **Low – Standalone harness coverage incomplete**
   - *Repro:* `standalone/` lacks bundles for la_asset_registry/la_masks.
   - *Root Cause:* Legacy modules not yet modularized.
   - *Fix:* After refactor, mirror harness template used for `la_core` and new `la_engine`.

5. **Low – Missing documentation for la_qbx__shim**
   - *Repro:* No README describing shim exports for QBox.
   - *Root Cause:* Historical oversight.
   - *Fix:* Author README with usage examples and ensure tests guard expected exports.

## Security Review
- `la_admin` now enforces allow-listed server events and validates payload shapes before forwarding, reducing RCE-style abuse from the dispatch console.
- `la_engine` restricts `la_engine:dispatch` to server-side invocations and wraps controller execution with `pcall`, emitting structured logs on failure.
- Database interactions remain parameterized through `oxmysql` (`?` placeholders) and initialization scripts remain idempotent.
- No secrets committed; all configuration updates rely on `config.example.lua` templates across `la_core`, `la_admin`, `la_medical`, `la_weapon_limiter`, and `la_engine`.

## Performance & Stability Notes
- `la_engine` aggregates status command wiring, reducing duplicate command registrations and providing a central logger hook used by `la_core`.
- New allow list in `la_admin` prevents event storming; debug logging is optional and defaults to false in templates.
- Legacy infinite loops (`la_era_traffic`) remain but are flagged for refactor; integrate them into `la_engine` to gain pacing/back-pressure.

## Merge Strategy & PR Plan
- Branch per patch: `audit-fix/la-engine-bootstrap` (new), `audit-fix/la-admin-modular`, future `audit-fix/legacy-modular` for remaining resources.
- Apply patches with `git apply --index patches/<name>.patch`, run tests via `PATH="$(pwd)/deps/bin:$PATH" busted` and `luacheck` before pushing to `work`.
- Submit PRs targeting `work` branch, request review from LA Ops; avoid direct pushes to `main`.

## Runbook (Updated)
1. **Setup**
   ```bash
   git clone https://github.com/pulphousepress/la_codex.git
   cd la_codex
   cp config.example.lua config.lua
   cp la_core/config.example.lua la_core/config.lua
   cp la_admin/config.example.lua la_admin/config.lua
   cp la_engine/config.example.lua la_engine/config.lua
   ```
2. **Apply patches**
   ```bash
   git checkout -b audit-fix/la-engine-bootstrap
   git apply --index patches/la_engine_bootstrap.patch
   ```
3. **Install test tooling**
   ```bash
   luarocks install --tree deps busted 2.1.0-1
   luarocks install --tree deps luacheck 1.1.0-1
   PATH="$(pwd)/deps/bin:$PATH" luacheck .
   PATH="$(pwd)/deps/bin:$PATH" busted
   ```
4. **Configure server**
   ```cfg
   ensure la_core
   ensure la_engine
   ensure ph_shared
   ensure la_npcs
   ensure la_medical
   ensure la_weapon_limiter
   ensure la_admin
   ```
5. **Deploy**
   ```bash
   git commit -am "feat: add la_engine scaffold and harden la_admin"
   git push origin audit-fix/la-engine-bootstrap
   ```
6. **Rollback**
   ```bash
   git apply -R --index patches/la_engine_bootstrap.patch
   git reset --hard HEAD~1  # if already committed
   ```
7. **Verify**
   ```bash
   txAdmin monitor
   /la_status
   /la_engine_status
   /la_admin_toggle  # via keybind
   ```

## Final Checklist
- [ ] `git status` clean after applying patches.
- [ ] `PATH="$(pwd)/deps/bin:$PATH" luacheck .` passes.
- [ ] `PATH="$(pwd)/deps/bin:$PATH" busted` passes (global leak guard green).
- [ ] `/la_status` and `/la_engine_status` respond server/client.
- [ ] `la_admin` only forwards events present in `AllowedEvents` list.
- [ ] Database tables (`la_flags`, `ped_whitelist`) exist via `oxmysql`.

## Clarifying Questions
1. Should remaining legacy modules (`la_asset_registry`, `la_masks`, `la_era_traffic`, `la_pop`) be prioritized in a single follow-up sprint or staged separately to minimize live server risk?
2. Are there target-zone interactions expected soon that would require immediate `oxtarget` bindings in `la_medical` or `la_admin`?
