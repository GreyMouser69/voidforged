-- The Raid Portal's spawn in The Void, beside Zebuxoruk. Run `#zoneshutdown zone thevoida` first:
-- a running zone saves its NPCs on shutdown and restores them on boot, ignoring new spawn2 rows.

START TRANSACTION;

INSERT INTO spawngroup (id, name) VALUES (5003896, 'Raid_Portal');
INSERT INTO spawnentry (spawngroupID, npcID, chance) VALUES (5003896, 1200071, 100);
INSERT INTO spawn2 (spawngroupID, zone, version, x, y, z, heading, respawntime, variance, pathgrid, path_when_zone_idle, _condition, cond_value, animation, min_expansion, max_expansion) VALUES
    (5003896, 'thevoida', 0, 28.94, -55.30, 0.53, 10.50, 30, 0, 0, 0, 0, 1, 0, -1, -1);

DELETE FROM zone_state_spawns WHERE zone_id = 459;

COMMIT;
