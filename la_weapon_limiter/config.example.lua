local Config = {
    Mode = 'block',
    WeaponJobWhitelist = {
        police = { 'WEAPON_PISTOL', 'WEAPON_REVOLVER', 'WEAPON_FLARE', 'WEAPON_PUMPSHOTGUN', 'WEAPON_BAT' },
        detective = { 'WEAPON_PISTOL', 'WEAPON_DOUBLEACTION', 'WEAPON_KNUCKLE' },
        mob = { 'WEAPON_GUSENBERG', 'WEAPON_SAWNOFFSHOTGUN', 'WEAPON_CLEAVER', 'WEAPON_SWITCHBLADE' },
        fire = { 'WEAPON_HATCHET', 'WEAPON_FLARE' },
        farmer = { 'WEAPON_MUSKET', 'WEAPON_HATCHET' },
        bartender = { 'WEAPON_KNIFE', 'WEAPON_BAT' }
    }
}

return Config
