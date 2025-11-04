INSERT IGNORE INTO la_flags (name, value) VALUES ('ped_seed', 1);

INSERT IGNORE INTO ped_whitelist (model, category, label, notes, added_by) VALUES
    ('a_c_cat_01', 'animal_models', 'Cat (ambient)', 'Default GTA animal ped', 'manual_seed'),
    ('a_c_husky', 'animal_models', 'Husky (dog)', 'Ambient dog ped', 'manual_seed'),
    ('FilmNoir', 'ambient_males', 'Film Noir', 'Noir-themed NPC', 'manual_seed'),
    ('Doorman01SMY', 'scenario_male', 'Doorman', 'Door staff ped', 'manual_seed');
