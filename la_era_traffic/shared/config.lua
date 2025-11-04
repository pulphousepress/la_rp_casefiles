--------------------------------------------
-- Los Animales RP · Era Config v1.3.0
-- Purpose: define 1950s-era vehicles and NPCs
-- Used by: la_era_vehicles, la_era_traffic, la_npcs, la_gumshoe
--------------------------------------------

Config = {}

-------------------------------------------------
-- DEBUG & CONTROL
-------------------------------------------------
Config.Enable = true
Config.Debug  = true   -- prints spawns / filters / replacements

-------------------------------------------------
-- MANUAL TEST LOCATIONS
-------------------------------------------------
Config.SpawnLocations = {
    vector3(215.0, -810.0, 30.7),
    vector3(-500.0, -200.0, 35.0),
    vector3(123.0, -1500.0, 28.0)
}

-------------------------------------------------
-- VEHICLE CATEGORIES (ERA-APPROPRIATE)
-------------------------------------------------
Config.EraVehicles = {
    classics = {
        "glendale","regina","stafford","blade","broadway","hustler",
        "peyote","tornado","tornado2","tornado3","tornado4","tornado5",
        "tornado6","ztype","btype","btype2","btype3","mamba","coquette5",
        "gt500","dynasty","fagaloa","brigham","eudora","ratloader",
        "hotknife","hermes","slamvan","slamvan2","coquetteblackfin",
        "club","weevil","issi3","brioso","brioso2","brioso3","winky",
        "bodhi2","kalahari","dloader","yosemite3"
    },

    service = {
        "bus","coach","airbus","fdx49taxi","tourbus",
        "trash","trash2","pbus","fdx47taxi"
    },

    emergency = {
        "cap58amb","alf46lscfire","cap58mfamb",
        "fdx47pol","mnl53pol","svy57pol","cap58srf","policeold1","policeold2",
        "fdx49srf","j50srf","pranger","fbi","fbi2","policeb","policet",
        "cap58pol","riot2","lifeguard","blazer2"
    },

    custom = {
        "ford52","ford53","willys46","willys48","belair","bmw507",
        "caddye","cap58pol","tbird"
    }
}

-------------------------------------------------
-- PED GROUPS (FOR NPC POPULATION)
-------------------------------------------------
Config.EraPeds = {
    ambient_females = {
        "a_f_m_bevhills_02","a_f_o_genstreet_01","a_f_y_bevhills_01",
        "a_f_y_bevhills_02","a_f_y_bevhills_04","a_f_y_business_01",
        "a_f_y_business_02","a_f_y_clubcust_01","a_f_y_clubcust_02",
        "a_f_y_clubcust_03","a_f_y_hipster_01","a_f_y_scdressy_01",
        "a_f_y_vinewood_04","a_f_y_smartcaspat_01","a_f_m_beach_01",
        "a_f_y_beach_01","a_f_y_topless_01"
    },

    ambient_males = {
        "a_m_m_business_01","a_m_m_farmer_01","a_m_m_golfer_01",
        "a_m_m_hasjew_01","a_m_m_hillbilly_01","a_m_m_hillbilly_02",
        "a_m_m_prolhost_01","a_m_m_salton_04","a_m_m_soucent_02",
        "a_m_m_tramp_01","a_m_o_genstreet_01","a_m_o_soucent_01",
        "a_m_o_soucent_03","a_m_y_beach_03","a_m_y_busicas_01",
        "a_m_y_business_01","a_m_y_business_02","a_m_y_business_03",
        "a_m_y_hasjew_01","a_m_y_genstreet_02","a_m_y_hippy_01",
        "a_m_y_musclbeac_02","a_m_y_salton_01","a_m_y_vinewood_01",
        "a_m_y_smartcaspat_01"
    },

    cutscene = {
        "cs_andreas","cs_bankman","cs_barry","cs_carbuyer","cs_davenorton",
        "cs_debra","cs_drfriedlander","cs_fbisuit_01","cs_floyd","cs_gurk",
        "cs_martinmadrazo","cs_martinmadrazo_02","cs_milton","cs_movpremf_01",
        "cs_movpremm_01","cs_mrs_thornhill","cs_nigel","cs_old_man1a",
        "cs_old_man2","cs_orleans","cs_paper","cs_priest","cs_prolsec_02",
        "cs_solomon","cs_taostranslato","cs_tom","csb_anton","csb_avon",
        "csb_chef","csb_chef2","csb_cletus","csb_cop","csb_groom",
        "csb_janitor","csb_mp_agent14","csb_oscar","csb_popov","csb_prolsec",
        "csb_ramp_hic","csb_ramp_marine","csb_rashcosvki","csb_reporter",
        "csb_stripper_01","csb_stripper_02","csb_trafficwarden",
        "csb_undercover","csb_vagspeak","csb_agatha","csb_avery",
        "csb_thornton","csb_tomcasino","csb_weiss","csb_vincent"
    },

    gang_male = {
        "g_m_m_armboss_01","g_m_m_armgoon_01","g_m_m_armlieut_01",
        "g_m_m_chemwork_01","g_m_m_chiboss_01","g_m_m_korboss_01",
        "g_m_m_mexboss_01","g_m_m_mexboss_02","g_m_y_korean_01",
        "g_m_y_korlieut_01","g_m_y_lost_01","g_m_y_lost_02","g_m_y_lost_03",
        "g_m_y_mexgang_01","g_m_y_salvagoon_02","g_m_m_casrn_01"
    },

    multiplayer = {
        "mp_f_boatstaff_01","mp_f_chbar_01","mp_f_cocaine_01","mp_f_deadhooker",
        "mp_f_stripperlite","mp_f_meth_01","mp_f_weed_01","mp_g_m_pros_01",
        "mp_m_avongoon","mp_m_boatstaff_01","mp_m_claude_01","mp_m_counterfeit_01",
        "mp_m_execpa_01","mp_m_fibsec_01","mp_m_g_vagfun_01","mp_m_meth_01",
        "mp_m_securoguard_01","mp_m_shopkeep_01","mp_m_weapwork_01",
        "mp_s_m_armoured_01"
    },

    scenario_female = {
        "s_f_m_maid_01","s_f_y_airhostess_01","s_f_m_shop_high","s_f_y_factory_01",
        "s_f_y_hooker_01","s_f_y_hooker_02","s_f_y_ranger_01","s_f_y_scrubs_01",
        "s_f_y_shop_mid","s_f_y_stripper_01","s_f_y_stripper_02","s_f_y_stripperlite",
        "s_f_y_casino_01"
    },

    scenario_male = {
        "s_m_m_ammucountry","s_m_m_armoured_01","s_m_m_armoured_02",
        "s_m_m_autoshop_02","s_m_m_ccrew_01","s_m_m_ciasec_01","s_m_m_cntrybar_01",
        "s_m_m_dockwork_01","s_m_m_doctor_01","s_m_m_fiboffice_01","s_m_m_fiboffice_02",
        "s_m_m_fibsec_01","s_m_m_gaffer_01","s_m_m_gardener_01","s_m_m_gentransport",
        "s_m_m_highsec_01","s_m_m_highsec_02","s_m_m_janitor","s_m_m_lathandy_01",
        "s_m_m_linecook","s_m_m_lsmetro_01","s_m_m_mariachi_01","s_m_m_marine_01",
        "s_m_m_marine_02","s_m_m_paramedic_01","s_m_m_pilot_01","s_m_m_movprem_01",
        "s_m_m_pilot_02","s_m_m_postal_01","s_m_m_prisguard_01","s_m_m_scientist_01",
        "s_m_m_security_01","s_m_m_strpreach_01","s_m_m_strvend_01","s_m_m_trucker_01",
        "s_m_m_ups_01","s_m_m_ups_02","s_m_y_airworker","s_m_y_ammucity_01",
        "s_m_y_autopsy_01","s_m_y_barman_01","s_m_y_busboy_01","s_m_y_chef_01",
        "s_m_y_clubbar_01","s_m_y_construct_01","s_m_y_construct_02","s_m_y_cop_01",
        "s_m_y_devinsec_01","s_m_y_dockwork_01","s_m_y_doorman_01","s_m_y_dwservice_01",
        "s_m_y_dwservice_02","s_m_y_factory_01","s_m_y_fireman_01","s_m_y_garbage",
        "s_m_y_grip_01","s_m_y_hwaycop_01","s_m_y_pestcont_01","s_m_y_pilot_01",
        "s_m_y_prismuscl_01","s_m_y_prisoner_01","s_m_y_ranger_01","s_m_y_sheriff_01",
        "s_m_y_uscg_01","s_m_y_valet_01","s_m_y_waiter_01","s_m_y_casino_01",
        "s_m_y_westsec_01"
    },

    -- Special Toontown peds (may be toggled off)
    toontown = {
        "s_m_m_movalien_01","s_m_m_movspace_01","s_m_y_clown_01","s_m_m_strperf_01",
        "s_m_y_mime","ig_skeleton_01","ig_zombie_dj_01","ig_orleans","u_m_m_streetart_01",
        "u_m_y_imporage","u_m_y_pogo_01","u_m_y_rsranger_01","u_m_o_filmnoir",
        "u_m_y_zombie_01"
    }
}

-------------------------------------------------
-- Helper
-------------------------------------------------
function getConfig()
    return Config
end
