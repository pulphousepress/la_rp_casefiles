# Los Animales RP — `la_codex`

`la_codex` is the canonical data and config repository for the Los Animales RP server. It contains era policies, whitelists, shared JSON/Lua catalogs, server snippets, and contributor guidance used across LA resources. Gumshoe (the detective gameplay resource) is intentionally excluded and lives in `la_gumshoe`.

---

## Repository purpose

* Central place for era rules and whitelists (vehicles, peds, items) used by multiple resources.
* Shared data for pEditor, la_era_vehicles, la_npcs, la_radio, and other LA systems.
* Copy/paste ready server snippets and recommended ensure order.
* Contributor guidance and enforcement rules for keeping assets era-appropriate.

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

# Los Animales core / codex
ensure la_core
ensure la_codex
ensure la_era_vehicles
ensure la_npcs
ensure la_peditor
ensure la_admin

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

* `la_codex` is data only. Gameplay resources should import or query these files using `exports` or `oxmysql` rather than copying lists into code. This prevents drift and keeps a single source of truth.
* pEditor expects the codex format described in `la_peditor_promt.txt`. Update pEditor only after confirming format compatibility.
* Keep update frequency reasonable. Breaking whitelist format will cause startup errors across multiple LA resources.

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
