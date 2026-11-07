-- Raid portal: the 17 bosses with their own fights in 11 more zones at version 50, as
-- 2026_11_03_01_raid_portal_shared_bosses.sql did for the shared bosses. Additive only. ssratemple already has its
-- version 50 rows, so the Emperor needs none here. Each zone gets its first boss's entry point as the safe spot and a
-- Raid_Controller spawn; the controller spawns whichever boss the instance holds.

START TRANSACTION;

CREATE TEMPORARY TABLE raid_zone SELECT * FROM zone WHERE short_name IN ('growthplane', 'kael', 'mischiefplane',
    'poair', 'solrotower', 'bothunder', 'potimeb', 'inktuta', 'tacvi', 'txevu', 'ferubi') AND version = 0;
UPDATE raid_zone SET id = 0, version = 50, flag_needed = '', min_level = 0, min_status = 0;
UPDATE raid_zone SET safe_x = -368.9, safe_y = 1664.9, safe_z = -15.6 WHERE short_name = 'growthplane';
UPDATE raid_zone SET safe_x = 1763, safe_y = -1025, safe_z = -204.3 WHERE short_name = 'kael';
UPDATE raid_zone SET safe_x = -26, safe_y = 394, safe_z = 168.1 WHERE short_name = 'mischiefplane';
UPDATE raid_zone SET safe_x = -214.4, safe_y = 64.3, safe_z = 1442.8 WHERE short_name = 'poair';
UPDATE raid_zone SET safe_x = 38, safe_y = -1391, safe_z = 252.5 WHERE short_name = 'solrotower';
UPDATE raid_zone SET safe_x = -901.5, safe_y = -1542.7, safe_z = 2252.4 WHERE short_name = 'bothunder';
UPDATE raid_zone SET safe_x = 244, safe_y = -1106, safe_z = -1.1 WHERE short_name = 'potimeb';
UPDATE raid_zone SET safe_x = -65, safe_y = -587, safe_z = -127.1 WHERE short_name = 'inktuta';
UPDATE raid_zone SET safe_x = 462, safe_y = -171, safe_z = 32 WHERE short_name = 'tacvi';
UPDATE raid_zone SET safe_x = 724, safe_y = -232, safe_z = -371.6 WHERE short_name = 'txevu';
UPDATE raid_zone SET safe_x = -883.4, safe_y = -948.6, safe_z = 37.6 WHERE short_name = 'ferubi';
INSERT INTO zone SELECT * FROM raid_zone;
DROP TEMPORARY TABLE raid_zone;

CREATE TEMPORARY TABLE raid_doors SELECT * FROM doors WHERE zone IN ('growthplane', 'kael', 'mischiefplane',
    'poair', 'solrotower', 'bothunder', 'potimeb', 'inktuta', 'tacvi', 'txevu', 'ferubi') AND version = 0;
UPDATE raid_doors SET id = 0, version = 50, keyitem = 0, lockpick = 0;
INSERT INTO doors SELECT * FROM raid_doors;
DROP TEMPORARY TABLE raid_doors;

CREATE TEMPORARY TABLE raid_points SELECT * FROM zone_points WHERE zone IN ('growthplane', 'kael', 'mischiefplane',
    'poair', 'solrotower', 'bothunder', 'potimeb', 'inktuta', 'tacvi', 'txevu', 'ferubi') AND version = 0;
UPDATE raid_points SET id = 0, version = 50;
INSERT INTO zone_points SELECT * FROM raid_points;
DROP TEMPORARY TABLE raid_points;

INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation, min_expansion, max_expansion) VALUES
    (5003895, 'growthplane', 50, -368.9, 1664.9, -15.6, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'kael', 50, 1763, -1025, -204.3, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'mischiefplane', 50, -26, 394, 168.1, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'poair', 50, -214.4, 64.3, 1442.8, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'solrotower', 50, 38, -1391, 252.5, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'bothunder', 50, -901.5, -1542.7, 2252.4, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'potimeb', 50, 244, -1106, -1.1, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'inktuta', 50, -65, -587, -127.1, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'tacvi', 50, 462, -171, 32, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'txevu', 50, 724, -232, -371.6, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'ferubi', 50, -883.4, -948.6, 37.6, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1);

COMMIT;
