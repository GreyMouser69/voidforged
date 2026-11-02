-- Soulbinder_Ilsara in The Void, so players can bind next to the rifts. Run after the rift setup.
-- A copy of PoK's Soulbinder_Jera (202120), standing beside Zebuxoruk. Her script is
-- utils/scripts/rift/quests/thevoida/Soulbinder_Ilsara.pl (copy it to quests/thevoida/). A zone with saved state ignores new
-- spawns: delete The Void's zone_state_spawns rows (with the zone down) when adding her to a running server.
-- Safe to run again.

START TRANSACTION;

DELETE FROM spawn2 WHERE spawngroupID = 5003853;
DELETE FROM spawnentry WHERE spawngroupID = 5003853;
DELETE FROM spawngroup WHERE id = 5003853;
DELETE FROM npc_types WHERE id = 1200060;

DROP TEMPORARY TABLE IF EXISTS void_soulbinder_tmp;
CREATE TEMPORARY TABLE void_soulbinder_tmp SELECT * FROM npc_types WHERE id = 202120;
UPDATE void_soulbinder_tmp SET id = 1200060, name = 'Soulbinder_Ilsara', lastname = 'Soulbinder', loottable_id = 0, merchant_id = 0;
INSERT INTO npc_types SELECT * FROM void_soulbinder_tmp;
DROP TEMPORARY TABLE void_soulbinder_tmp;

INSERT INTO spawngroup (id, name) VALUES (5003853, 'thevoida_soulbinder');
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (5003853, 1200060, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid)
VALUES (5003853, 'thevoida', 0, 85.0, -12.0, 4.2, 420.0, 640, 0, 0);

COMMIT;
