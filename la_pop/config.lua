-- la_pop/config.lua
-- Pulphouse Press – Los Animales RP Unified Population Controller

Config = {}
Config.Debug = true

-------------------------------------------------
-- WORLD DENSITY  (from qbx_density)
-------------------------------------------------
Config.Density = {
    Vehicles = 0.6,
    Peds = 0.8,
    Scenarios = 0.8,
    ParkedVehicles = 0.7
}

Config.Zones = {
    City      = { Veh = 0.8, Ped = 1.0 },
    Rural     = { Veh = 0.4, Ped = 0.6 },
    Toontown  = { Veh = 0.0, Ped = 0.0, Override = true }
}

-------------------------------------------------
-- MISSION ROW NPCS  (from la_npcs_live)
-------------------------------------------------
Config.NPCS = {
    -- Jailor
    { coords = vector3(465.08, -990.15, 24.91), heading = 68.38,
      model = "s_m_y_cop_01", name = "Jailor",
      text = "Press ~o~[E]~w~ to talk to the ~y~Jailor",
      event = "la_pop:jailor",
      dialogue = "Can I help you, buddy?", sound = "GENERIC_HI" },

    -- Fingerprint Clerk
    { coords = vector3(459.84, -988.79, 24.91), heading = 243.19,
      model = "s_f_y_cop_01", name = "Fingerprint Clerk",
      text = "Press ~o~[E]~w~ to scan your ~y~fingerprints",
      event = "la_pop:fingerprint",
      dialogue = "Let me see those digits!", sound = "GENERIC_HOWS_IT_GOING" },

    -- Cell Prisoners
    { coords = vector3(459.49, -998.46, 24.91), heading = 339.01,
      model = "g_m_m_mexboss_01", name = "Cell Prisoner",
      text = "The ~y~prisoner~w~ mutters behind bars",
      dialogue = "I ain’t talkin’ till my lawyer’s here!",
      sound = "GENERIC_CURSE_MED" },

    { coords = vector3(458.73, -1000.99, 24.91), heading = 259.02,
      model = "g_m_m_korboss_01", name = "Cell Prisoner",
      text = "The ~y~prisoner~w~ stares at the wall",
      dialogue = "You’re all crooked, every last one of ya!",
      sound = "GENERIC_ANGRY_SHOUT" },

    -- Patrol Car Unit
    { coords = vector3(408.22, -984.07, 29.27), heading = 242.64,
      model = "s_m_y_cop_01", partner = "s_m_y_cop_01", vehicle = "fdx47bsrf",
      patrolRoute = {
        {x=397.72,y=-974.47,z=29.31,heading=195.39,wait=2500},
        {x=396.11,y=-1022.81,z=29.42,heading=179.44,wait=2500},
        {x=380.50,y=-1042.58,z=29.29,heading=90.98,wait=2500},
        {x=250.38,y=-1037.02,z=29.27,heading=71.97,wait=3000},
        {x=240.33,y=-1023.18,z=29.23,heading=354.89,wait=2500},
        {x=260.31,y=-966.16,z=29.23,heading=341.68,wait=2500},
        {x=273.56,y=-954.70,z=29.33,heading=273.74,wait=2500},
        {x=389.49,y=-959.43,z=29.31,heading=263.57,wait=2500},
        {x=397.19,y=-967.40,z=29.35,heading=183.58,wait=2000},
        {x=409.40,y=-980.51,z=29.27,heading=228.06,wait=30000}
      },
      name = "Patrol Car Unit",
      text = "Two officers sit in the patrol car.",
      dialogue = "Let’s make a loop around the block.",
      sound = "GENERIC_RADIO_CHATTER", debug = true }
}
