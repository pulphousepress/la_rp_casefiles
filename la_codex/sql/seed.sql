-- Los Animales Codex seed SQL

CREATE TABLE IF NOT EXISTS ped_whitelist (
  id INT AUTO_INCREMENT PRIMARY KEY,
  model VARCHAR(64) NOT NULL,
  category VARCHAR(64) NOT NULL,
  label VARCHAR(128),
  notes TEXT,
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS veh_whitelist (
  id INT AUTO_INCREMENT PRIMARY KEY,
  model VARCHAR(64) NOT NULL,
  year INT,
  category VARCHAR(64),
  label VARCHAR(128),
  spawn_weight INT DEFAULT 1,
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS popgroups (
  id INT AUTO_INCREMENT PRIMARY KEY,
  group_name VARCHAR(64) NOT NULL,
  model VARCHAR(64) NOT NULL,
  region VARCHAR(64)
);

CREATE TABLE IF NOT EXISTS codex_meta (
  id INT AUTO_INCREMENT PRIMARY KEY,
  `key` VARCHAR(64) NOT NULL,
  value VARCHAR(255) NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Example insert seeds
INSERT INTO codex_meta (`key`, value) VALUES ('version', '1.0.0'), ('updated_at', '2025-11-04');