fx_version 'cerulean'
game 'gta5'

name 'la_codex'
description 'Los Animales Codex: Data only (whitelists, manifests, popgroups, SQL seeds)'
version '1.0.0'

-- This resource is data-only. It contains JSON whitelists, popgroups, ped manifests and seed SQL.
-- Do not add any scripts or runtime logic here. Other resources should use LoadResourceFile to read data.

files {
    'codex_meta.json',
    'whitelists/*.json',
    'popgroups/*.json',
    'peds/manifest.json',
    'sql/*.sql'
}
