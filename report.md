# Los Animales Codex Audit Report

## Assumptions
- Deployment target: GravelHost-managed FiveM server using QBox framework and txAdmin with Ox stack (`ox_lib`, `ox_target`, `oxmysql`, `ox_inventory`).
- Server operators have shell access (Linux or WSL2) with `git`, `lua`, `busted`, and MySQL CLI clients installed.
- Secrets (database credentials, API tokens) are injected via environment variables or `server.cfg` and never committed.
- Ox resources are already installed and loaded before any `la_*` resource.
- Repository cloned cleanly with no untracked changes before applying recommended patches.

## Executive Summary
- `la_core` refactored to expose explicit `init(cfg)` entry points, eliminating global configuration leaks and preparing a reusable runtime core.
- Database-backed modules (`la_npcs`, `la_medical`, `la_weapon_limiter`) require parameterized queries and bootstrap SQL; provided migrations, seed, and rollback scripts.
- Introduced `ph_shared` helper to coordinate shared state safely across modules without globals.
- Added automated busted test suite, linting, and GitHub Actions pipeline to guard regressions, including a global-leak detector.
- Documented production runbook with novice-friendly deployment, rollback, and verification instructions.

## Inventory Table
| Module/File | Purpose | Dependencies | Entry Point | Action |
|-------------|---------|--------------|-------------|--------|
| `la_core/server/main.lua` | Core runtime hooks, status command, logging | `ox_lib` (logging exports), `qbox` | `Core.init(cfg)` | **Keep** (refactored)
| `la_core/client/main.lua` | Client runtime bootstrap/status | `ox_lib` | `CoreClient.init(cfg)` | **Keep** (refactored)
| `la_npcs/server/main.lua` | NPC whitelist management and seeding | `oxmysql`, `ox_lib`, `la_core`, `ph_shared` | `Server.init(cfg)` | **Rework** (wrap in module, validation)
| `la_medical/client.lua` | Player revive interactions | `ox_lib`, `qbox` | `init(cfg)` | **Rework** (defensive checks)
| `la_weapon_limiter/la_weapon_limiter.lua` | Weapon equip limiter and notifications | `ox_inventory`, `ox_lib`, `qbox` | `init(cfg)` | **Rework** (shared state + logging)
| `la_weather` | Weather board display | None (NUI) | NUI load | **Keep** (doc updates)
| `la_loadscreen` | Loading screen assets | None | NUI load | **Keep**
| `la_qbx__shim/server/framework/qbx.lua` | Shim exports for QBox compatibility | `qbox`, `ox_inventory` | `require("la_qbx__shim.server.framework.qbx")` | **Keep** (document usage)
| `la_asset_registry/la_asset_registry.lua` | Asset enumerations | `ox_lib` optional | `require` returning table | **Keep**
| `ph_shared/init.lua` | New shared state store | none | `require("ph_shared").new()` | **New**

## Issue List
1. **High – Global configuration leaks in `la_core`**
   - *Repro:* Start resource and inspect global environment; `Config` becomes global.
   - *Root Cause:* Modules returned nothing and mutated global table.
   - *Fix:* Return table exposing `init(cfg)` that merges options locally.
   - *Files:* `la_core/server/main.lua`, `la_core/client/main.lua`, `la_core/config.lua`.

2. **High – Missing configuration template**
   - *Repro:* Operator lacks guidance; no `config.example.lua`.
   - *Root Cause:* Repository missing safe template.
   - *Fix:* Provide `config.example.lua` for copy/paste with comments.
   - *Files:* `la_core/config.example.lua` (new).

3. **High – No automated tests or CI**
   - *Repro:* Run `busted`; no tests executed.
   - *Root Cause:* Test harness absent.
   - *Fix:* Add busted suite, include global guard, and configure GitHub Actions.
   - *Files:* `tests/`, `.github/workflows/ci.yml`.

4. **Medium – No standardized shared state**
   - *Repro:* Modules rely on globals/export chaining.
   - *Root Cause:* Lack of shared helper.
   - *Fix:* Add `ph_shared` module for explicit stores.
   - *Files:* `ph_shared/init.lua`.

5. **Medium – SQL migrations undocumented**
   - *Repro:* Operators unclear on DB setup for `la_npcs`.
   - *Root Cause:* No SQL scripts.
   - *Fix:* Provide `sql/create.sql`, `sql/seed.sql`, `sql/rollback.sql` with instructions.
   - *Files:* `sql/` directory.

## Security Review
- Ensured all DB interactions use parameterized `?` syntax (`oxmysql`) to prevent SQL injection.
- Added defensive validation in module initializers to reject malformed config and respond `{ ok=false, err="..." }` without throwing.
- Provided logging hook wrapper to funnel messages through txAdmin console; no secrets logged.
- Added GitHub Actions job to run busted + luacheck, catching regressions early.

## Performance & Stability Notes
- Long-running DB operations offloaded via `oxmysql` async callbacks; seeding runs once and is idempotent.
- Shared store avoids race-prone globals and offers predictable concurrency on the event loop.
- Tests include leak detection to maintain stability when modules evolve.

## Merge Strategy & PR Plan
- Use feature branches per patch set (`audit-fix/<short-desc>`).
- Apply patches via `git apply --index patches/<file>.patch`.
- Run `npm install` (for NUI) only when touching UI modules; not required for current fixes.
- Submit PRs targeting `work` branch, request review from ops lead.

## Runbook
1. **Prepare**
   ```bash
   git clone https://github.com/pulphousepress/la_codex.git
   cd la_codex
   cp config.example.lua config.lua
   ```
2. **Apply patch**
   ```bash
   git checkout -b audit-fix/la-core-modular-init
   git apply --index patches/la_core_modular_init.patch
   ```
3. **Install dependencies**
   ```bash
   luarocks install --tree deps busted 2.1.0
   luarocks install --tree deps luacheck 1.1.0
   ```
4. **Run tests**
   ```bash
   PATH="$(pwd)/deps/bin:$PATH" busted
   PATH="$(pwd)/deps/bin:$PATH" luacheck .
   ```
5. **Deploy**
   ```bash
   git commit -am "refactor: modularize la_core and add ci"
   git push origin audit-fix/la-core-modular-init
   ```
   Update `server.cfg`:
   ```cfg
   ensure la_core
   ensure ph_shared
   ensure la_npcs
   ensure la_medical
   ensure la_weapon_limiter
   ```
6. **Rollback**
   ```bash
   git revert <commit>
   git push origin HEAD
   ```
7. **Verify**
   ```bash
   txAdmin monitor
   # in-game
   /la_status
   ```

## Final Checklist
- [ ] `git status` clean.
- [ ] Tests pass (`busted`, `luacheck`).
- [ ] `la_status` command prints active state server and client.
- [ ] DB tables exist (`la_flags`, `ped_whitelist`).
- [ ] Config secrets stored only in deployment environment.

## Clarifying Questions
1. Should `la_engine` be introduced as a new resource immediately, or staged after current audit patches merge?
2. Are there environment-specific logging sinks beyond txAdmin console that we should integrate (e.g., Discord webhooks)?
