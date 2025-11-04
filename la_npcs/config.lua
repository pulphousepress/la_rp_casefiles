local Config = {
    Enable = true,
    seedOnStart = true,
    Debug = false,
    CheckInterval = 5000,
    SpawnRate = 2,
    MaxZonePeds = 20,
    SpawnRadius = 60.0,
    PedsFile = 'data/peds.json',
    Zones = {
        {
            name = "Downtown",
            center = vector3(235.0, -900.0, 30.0),
            radius = 400.0,
            categories = { "ambient_males", "ambient_females", "multiplayer" },
            scenarios = { "WORLD_HUMAN_STAND_IMPATIENT", "WORLD_HUMAN_SMOKING", "WORLD_HUMAN_TOURIST_MAP" },
            density = { max = 40, rate = 3 }
        },
        {
            name = "Sandy Shores",
            center = vector3(1700.0, 3600.0, 35.0),
            radius = 600.0,
            categories = { "ambient_males", "ambient_females", "gang_male" },
            scenarios = { "WORLD_HUMAN_DRUG_DEALER", "WORLD_HUMAN_SMOKING", "WORLD_HUMAN_HANG_OUT_STREET" },
            density = { max = 15, rate = 1 }
        },
        {
            name = "Vinewood",
            center = vector3(300.0, 550.0, 120.0),
            radius = 300.0,
            categories = { "ambient_males", "ambient_females", "cutscene" },
            scenarios = { "WORLD_HUMAN_MOBILE_FILM_SHOCKING", "WORLD_HUMAN_PARTYING", "WORLD_HUMAN_TOURIST_MAP" },
            density = { max = 30, rate = 2 }
        },
        {
            name = "Beach",
            center = vector3(-1600.0, -1100.0, 0.0),
            radius = 500.0,
            categories = { "ambient_males", "ambient_females" },
            scenarios = { "WORLD_HUMAN_SUNBATHE", "WORLD_HUMAN_MUSCLE_FLEX", "WORLD_HUMAN_DRINKING" },
            density = { max = 25, rate = 2 }
        },
        {
            name = "Airport",
            center = vector3(-1034.0, -2733.0, 13.0),
            radius = 600.0,
            categories = { "scenario_male", "scenario_female" },
            scenarios = { "WORLD_HUMAN_STAND_IMPATIENT", "WORLD_HUMAN_COP_IDLES", "WORLD_HUMAN_SMOKING" },
            density = { max = 20, rate = 2 }
        },
        {
            name = "Docks",
            center = vector3(-260.0, -2440.0, 6.0),
            radius = 500.0,
            categories = { "scenario_male", "ambient_males" },
            scenarios = { "WORLD_HUMAN_CLIPBOARD", "WORLD_HUMAN_CONST_DRILL", "WORLD_HUMAN_SMOKING" },
            density = { max = 20, rate = 2 }
        },
        {
            name = "Grapeseed",
            center = vector3(2500.0, 5000.0, 45.0),
            radius = 400.0,
            categories = { "ambient_males", "ambient_females", "scenario_male" },
            scenarios = { "WORLD_HUMAN_GARDENER_LEAF_BLOWER", "WORLD_HUMAN_BUM_SLUMPED", "WORLD_HUMAN_SMOKING" },
            density = { max = 20, rate = 1 }
        },
        {
            name = "Paleto Bay",
            center = vector3(-160.0, 6300.0, 30.0),
            radius = 600.0,
            categories = { "ambient_males", "ambient_females", "multiplayer" },
            scenarios = { "WORLD_HUMAN_STAND_IMPATIENT", "WORLD_HUMAN_MUSCLE_FLEX", "WORLD_HUMAN_HANG_OUT_STREET" },
            density = { max = 20, rate = 2 }
        },
        {
            name = "Fort Zancudo",
            center = vector3(-2040.0, 3150.0, 32.0),
            radius = 600.0,
            categories = { "scenario_male", "gang_male" },
            scenarios = { "WORLD_HUMAN_GUARD_STAND", "WORLD_HUMAN_COP_IDLES", "WORLD_HUMAN_BINOCULARS" },
            density = { max = 15, rate = 1 }
        },
        {
            name = "Toontown",
            center = vector3(-1422.0, -285.0, 46.0),
            radius = 120.0,
            categories = { "toontown_only", "animal_models" },
            scenarios = { "WORLD_HUMAN_CHEERING", "WORLD_HUMAN_PARTYING", "WORLD_HUMAN_MUSICIAN" },
            density = { max = 25, rate = 3 }
        }
    }
}

return Config
