-- Raid portal: the 23 shared-mechanics bosses in 16 more zones at version 50, as
-- 2026_11_02_01_raid_portal_test.sql did for the first three. Additive only. Each zone gets its first boss's
-- entry point as the safe spot and a Raid_Controller spawn; the controller spawns whichever boss the instance holds.

START TRANSACTION;

CREATE TEMPORARY TABLE raid_zone SELECT * FROM zone WHERE short_name IN ('soldungb', 'sebilis', 'hateplane', 'veeshan',
    'skyshrine', 'templeveeshan', 'velketor', 'sleeper', 'westwastes', 'sseru', 'thedeep', 'ssratemple', 'vexthal',
    'pofire', 'hohonorb', 'codecay') AND version = 0;
UPDATE raid_zone SET id = 0, version = 50, flag_needed = '', min_level = 0, min_status = 0;
UPDATE raid_zone SET safe_x = -856, safe_y = -1187, safe_z = 86.1 WHERE short_name = 'soldungb';
UPDATE raid_zone SET safe_x = -538, safe_y = -2055, safe_z = -139.5 WHERE short_name = 'sebilis';
UPDATE raid_zone SET safe_x = 120.5, safe_y = 336.7, safe_z = 148.9 WHERE short_name = 'hateplane';
UPDATE raid_zone SET safe_x = -1195.5, safe_y = -1011, safe_z = 283 WHERE short_name = 'veeshan';
UPDATE raid_zone SET safe_x = 1836, safe_y = 2664, safe_z = -153.6 WHERE short_name = 'skyshrine';
UPDATE raid_zone SET safe_x = -139, safe_y = 945, safe_z = 117.4 WHERE short_name = 'templeveeshan';
UPDATE raid_zone SET safe_x = 40, safe_y = 317, safe_z = -68.3 WHERE short_name = 'velketor';
UPDATE raid_zone SET safe_x = -1063.6, safe_y = -2486.6, safe_z = -980.4 WHERE short_name = 'sleeper';
UPDATE raid_zone SET safe_x = 808, safe_y = 1323, safe_z = -196 WHERE short_name = 'westwastes';
UPDATE raid_zone SET safe_x = -373, safe_y = -576, safe_z = 193.1 WHERE short_name = 'sseru';
UPDATE raid_zone SET safe_x = 2508, safe_y = -1029, safe_z = -51.1 WHERE short_name = 'thedeep';
UPDATE raid_zone SET safe_x = 92, safe_y = 213, safe_z = 252.5 WHERE short_name = 'ssratemple';
UPDATE raid_zone SET safe_x = 126, safe_y = 152, safe_z = 130.6 WHERE short_name = 'vexthal';
UPDATE raid_zone SET safe_x = -1410, safe_y = -974, safe_z = -185.8 WHERE short_name = 'pofire';
UPDATE raid_zone SET safe_x = 2565, safe_y = 32, safe_z = 480.5 WHERE short_name = 'hohonorb';
UPDATE raid_zone SET safe_x = -161.2, safe_y = 199.7, safe_z = -260.9 WHERE short_name = 'codecay';
INSERT INTO zone SELECT * FROM raid_zone;
DROP TEMPORARY TABLE raid_zone;

CREATE TEMPORARY TABLE raid_doors SELECT * FROM doors WHERE zone IN ('soldungb', 'sebilis', 'hateplane', 'veeshan',
    'skyshrine', 'templeveeshan', 'velketor', 'sleeper', 'westwastes', 'sseru', 'thedeep', 'ssratemple', 'vexthal',
    'pofire', 'hohonorb', 'codecay') AND version = 0;
UPDATE raid_doors SET id = 0, version = 50, keyitem = 0, lockpick = 0;
INSERT INTO doors SELECT * FROM raid_doors;
DROP TEMPORARY TABLE raid_doors;

CREATE TEMPORARY TABLE raid_points SELECT * FROM zone_points WHERE zone IN ('soldungb', 'sebilis', 'hateplane', 'veeshan',
    'skyshrine', 'templeveeshan', 'velketor', 'sleeper', 'westwastes', 'sseru', 'thedeep', 'ssratemple', 'vexthal',
    'pofire', 'hohonorb', 'codecay') AND version = 0;
UPDATE raid_points SET id = 0, version = 50;
INSERT INTO zone_points SELECT * FROM raid_points;
DROP TEMPORARY TABLE raid_points;

INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation, min_expansion, max_expansion) VALUES
    (5003895, 'soldungb', 50, -856, -1187, 86.1, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'sebilis', 50, -538, -2055, -139.5, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'hateplane', 50, 120.5, 336.7, 148.9, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'veeshan', 50, -1195.5, -1011, 283, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'skyshrine', 50, 1836, 2664, -153.6, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'templeveeshan', 50, -139, 945, 117.4, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'velketor', 50, 40, 317, -68.3, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'sleeper', 50, -1063.6, -2486.6, -980.4, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'westwastes', 50, 808, 1323, -196, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'sseru', 50, -373, -576, 193.1, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'thedeep', 50, 2508, -1029, -51.1, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'ssratemple', 50, 92, 213, 252.5, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'vexthal', 50, 126, 152, 130.6, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'pofire', 50, -1410, -974, -185.8, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'hohonorb', 50, 2565, 32, 480.5, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'codecay', 50, -161.2, 199.7, -260.9, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1);

COMMIT;
