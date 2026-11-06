-- Raid portal test set: Lady Vox, Saryrn and Rallos Zek the Warlord at zone version 50, the controller and
-- portal NPCs, and the Chronal Prisms currency. Additive only. The portal's own spawn is in
-- 2026_11_02_02_raid_portal_spawn.sql because The Void must be shut down first (zone state saving).

START TRANSACTION;

-- Zones: no entry requirements, the roster's entry point as the safe spot
CREATE TEMPORARY TABLE raid_zone SELECT * FROM zone WHERE short_name IN ('permafrost', 'potorment', 'potactics') AND version = 0;
UPDATE raid_zone SET id = 0, version = 50, flag_needed = '', min_level = 0, min_status = 0;
UPDATE raid_zone SET safe_x = -380.88, safe_y = 822, safe_z = 13.13, safe_heading = 128 WHERE short_name = 'permafrost';
UPDATE raid_zone SET safe_x = 0, safe_y = -72, safe_z = 579, safe_heading = 0 WHERE short_name = 'potorment';
UPDATE raid_zone SET safe_x = 519, safe_y = 216, safe_z = -293, safe_heading = 128 WHERE short_name = 'potactics';
INSERT INTO zone SELECT * FROM raid_zone;
DROP TEMPORARY TABLE raid_zone;

-- Doors and zone points, as rift zones copy them: doors unlocked, no trash and no ground spawns
CREATE TEMPORARY TABLE raid_doors SELECT * FROM doors WHERE zone IN ('permafrost', 'potorment', 'potactics') AND version = 0;
UPDATE raid_doors SET id = 0, version = 50, keyitem = 0, lockpick = 0;
INSERT INTO doors SELECT * FROM raid_doors;
DROP TEMPORARY TABLE raid_doors;

CREATE TEMPORARY TABLE raid_points SELECT * FROM zone_points WHERE zone IN ('permafrost', 'potorment', 'potactics') AND version = 0;
UPDATE raid_points SET id = 0, version = 50;
INSERT INTO zone_points SELECT * FROM raid_points;
DROP TEMPORARY TABLE raid_points;

-- Controller, modeled on Rift_Controller, and the portal, modeled on Rift_Portal
CREATE TEMPORARY TABLE raid_npcs SELECT * FROM npc_types WHERE id IN (1200000, 1200009);
UPDATE raid_npcs SET id = 1200070, name = 'Raid_Controller' WHERE id = 1200000;
UPDATE raid_npcs SET id = 1200071, name = 'Raid_Portal' WHERE id = 1200009;
INSERT INTO npc_types SELECT * FROM raid_npcs;
DROP TEMPORARY TABLE raid_npcs;

INSERT INTO spawngroup (id, name) VALUES (5003895, 'Raid_Controller');
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (5003895, 1200070, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation, min_expansion, max_expansion) VALUES
    (5003895, 'permafrost', 50, -380.88, 822, 13.13, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'potorment', 50, 0, -72, 579, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1),
    (5003895, 'potactics', 50, 519, 216, -293, 0, 30, 0, 0, 0, 0, 1, 0, -1, -1);

-- Chronal Prisms, modeled on the Chronal Shard. The client needs db_str types 17 and 18, id 3, to name it.
CREATE TEMPORARY TABLE raid_item SELECT * FROM items WHERE id = 800002;
UPDATE raid_item SET id = 800005, Name = 'Chronal Prism';
INSERT INTO items SELECT * FROM raid_item;
DROP TEMPORARY TABLE raid_item;
INSERT INTO alternate_currency (id, item_id) VALUES (3, 800005);

COMMIT;
