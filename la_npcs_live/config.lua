-- la_npcs_live / config.lua
-- Los Animales RP — Mission Row Precinct NPCs + Patrol Unit

Config = {}
Config.Debug = true -- Master debug toggle

Config.NPCS = {

    -- Jailor
    {
        coords = vector3(465.08, -990.15, 24.91),
        heading = 68.38,
        model = "s_m_y_cop_01",
        name = "Jailor",
        text = "Press ~o~[E]~w~ to talk to the ~y~Jailor",
        event = "la_npcs_live:jailor",
        dialogue = "Can I help you, buddy?",
        sound = "GENERIC_HI",
        debug = false
    },

    -- Fingerprint Clerk
    {
        coords = vector3(459.84, -988.79, 24.91),
        heading = 243.19,
        model = "s_f_y_cop_01",
        name = "Fingerprint Clerk",
        text = "Press ~o~[E]~w~ to scan your ~y~fingerprints",
        event = "la_npcs_live:fingerprint",
        dialogue = "Let me see those digits!",
        sound = "GENERIC_HOWS_IT_GOING",
        debug = false
    },

    -- Prisoner Cell 2
    {
        coords = vector3(459.49, -998.46, 24.91),
        heading = 339.01,
        model = "g_m_m_mexboss_01",
        name = "Cell Prisoner",
        text = "The ~y~prisoner~w~ mutters behind bars",
        event = "la_npcs_live:prisoner",
        dialogue = "I ain’t talkin’ till my lawyer’s here!",
        sound = "GENERIC_CURSE_MED",
        debug = false
    },

    -- Prisoner Cell 3
    {
        coords = vector3(458.73, -1000.99, 24.91),
        heading = 259.02,
        model = "g_m_m_korboss_01",
        name = "Cell Prisoner",
        text = "The ~y~prisoner~w~ stares at the wall",
        event = "la_npcs_live:prisoner",
        dialogue = "You’re all crooked, every last one of ya!",
        sound = "GENERIC_ANGRY_SHOUT",
        debug = false
    },

    -- Booking Room Dancer (crying)
    {
        coords = vector3(446.03, -987.81, 30.69),
        heading = 175.58,
        model = "u_f_y_danceburl_01",
        name = "Dancer",
        text = "The ~y~woman~w~ sobs uncontrollably",
        event = "la_npcs_live:dancerCrying",
        dialogue = "I didn’t do anything wrong!",
        emote = "WORLD_HUMAN_BUM_STANDING",
        sound = "GENERIC_FEM_CRY",
        debug = false
    },

    -- Officer Booking Her
    {
        coords = vector3(446.90, -987.34, 30.69),
        heading = 16.72,
        model = "s_m_y_cop_01",
        name = "Booking Officer",
        text = "The ~y~officer~w~ jots down notes",
        event = "la_npcs_live:bookingOfficer",
        dialogue = "Name, address, and occupation…",
        emote = "WORLD_HUMAN_CLIPBOARD",
        sound = "GENERIC_HI",
        debug = false
    },
{
    coords = vector3(439.52, -979.12, 30.69),
    heading = 185.72,
    model = "s_m_m_detective_01",
    name = "Busy Detective",
    text = "~y~Detective~w~ flips through files.",
    event = "la_npcs_live:detectiveBusy",
    dialogue = "Not right now, kid. Busy.",
    emote = "WORLD_HUMAN_CLIPBOARD",
    sound = "GENERIC_NO",
    debug = false
},

    -- Another Woman (angry)
    {
        coords = vector3(443.02, -981.11, 30.69),
        heading = 33.19,
        model = "a_f_y_vinewood_04",
        name = "Angry Woman",
        text = "The ~y~woman~w~ shouts across the room",
        event = "la_npcs_live:angryWoman",
        dialogue = "You can’t keep me here forever!",
        emote = "WORLD_HUMAN_YELLING",
        sound = "GENERIC_FEM_ANGRY",
        debug = false
    },

    -- Desk Officer
    {
        coords = vector3(441.10, -978.92, 30.69),
        heading = 178.73,
        model = "s_m_y_cop_01",
        name = "Desk Officer",
        text = "Press ~o~[E]~w~ to talk to the ~y~Desk Officer",
        event = "la_npcs_live:deskOfficer",
        dialogue = "Paperwork never ends...",
        emote = "WORLD_HUMAN_CLIPBOARD",
        sound = "GENERIC_HOWS_IT_GOING",
        blip = {
            sprite = 60, color = 38, scale = 0.8, display = 2, name = "Desk Officer"
        },
        debug = false
    },

    -- Angry Perp
    {
        coords = vector3(438.39, -986.75, 30.69),
        heading = 88.55,
        model = "csb_vagspeak",
        name = "Angry Perp",
        text = "The ~y~perp~w~ yells furiously",
        event = "la_npcs_live:perpArgue",
        dialogue = "You call this justice?!",
        emote = "WORLD_HUMAN_YELLING",
        sound = "GENERIC_ANGRY_SHOUT",
        debug = false
    },

    -- Lawyer
    {
        coords = vector3(436.65, -986.40, 30.69),
        heading = 243.23,
        model = "u_m_m_bankman",
        name = "Defense Lawyer",
        text = "The ~y~Lawyer~w~ tries to calm his client",
        event = "la_npcs_live:lawyerArgue",
        dialogue = "Calm down! Yelling won’t help your case.",
        emote = "WORLD_HUMAN_CLIPBOARD",
        sound = "GENERIC_HI",
        debug = false
    },

    -- Detective
    {
        coords = vector3(437.05, -978.69, 30.69),
        heading = 156.27,
        model = "s_m_m_ciasec_01",
        name = "Detective",
        text = "The ~y~Detective~w~ is reviewing a file",
        event = "la_npcs_live:detective",
        dialogue = "Murder on Fifth Street… this one stinks.",
        emote = "WORLD_HUMAN_CLIPBOARD",
        sound = "GENERIC_CURSE_MED",
        debug = false
    },

    -- Captain in Office
    {
        coords = vector3(450.13, -974.07, 30.69),
        heading = 171.43,
        model = "s_m_y_cop_01",
        name = "Police Captain",
        text = "The ~y~Captain~w~ is pacing in his office",
        event = "la_npcs_live:captain",
        dialogue = "These rookies are killing me!",
        emote = "WORLD_HUMAN_COP_IDLES",
        sound = "GENERIC_FRUSTRATED",
        debug = false
    },

    -- Patrol Car Unit
    {
        coords = vector3(408.22, -984.07, 29.27),
        heading = 242.64,
        model = "s_m_y_cop_01",
        partner = "s_m_y_cop_01",
        vehicle = "fdx47bsrf",
        patrolRoute = {
            { x = 397.72, y = -974.47, z = 29.31, heading = 195.39, wait = 2500 },
            { x = 396.11, y = -1022.81, z = 29.42, heading = 179.44, wait = 2500 },
            { x = 380.50, y = -1042.58, z = 29.29, heading = 90.98, wait = 2500 },
            { x = 250.38, y = -1037.02, z = 29.27, heading = 71.97, wait = 3000 },
            { x = 240.33, y = -1023.18, z = 29.23, heading = 354.89, wait = 2500 },
            { x = 260.31, y = -966.16, z = 29.23, heading = 341.68, wait = 2500 },
            { x = 273.56, y = -954.70, z = 29.33, heading = 273.74, wait = 2500 },
            { x = 389.49, y = -959.43, z = 29.31, heading = 263.57, wait = 2500 },
            { x = 397.19, y = -967.40, z = 29.35, heading = 183.58, wait = 2000 },
            { x = 409.40, y = -980.51, z = 29.27, heading = 228.06, wait = 30000 }
        },
        name = "Patrol Car Unit",
        text = "Two officers sit in the patrol car.",
        event = "la_npcs_live:patrolCar",
        dialogue = "Let’s make a loop around the block.",
        sound = "GENERIC_RADIO_CHATTER",
        debug = true
    }
}
