-- Turn the tier 1 vendor line in thevoida to heading 338, the Jeweler at the north end and the
-- Quartermaster, Augmenter and Weaponsmith 10 units apart after it (matches the "placed" spots in tier_gear.json). Repop thevoida after applying.
UPDATE spawn2 SET x = 74.01, y = 70.49, z = 4.33, heading = 338 WHERE zone = 'thevoida' AND spawngroupID IN (SELECT spawngroupID FROM spawnentry WHERE npcID = 1200030);
UPDATE spawn2 SET x = 79.36, y = 62.05, z = 4.33, heading = 338 WHERE zone = 'thevoida' AND spawngroupID IN (SELECT spawngroupID FROM spawnentry WHERE npcID = 1200010);
UPDATE spawn2 SET x = 84.71, y = 53.60, z = 4.33, heading = 338 WHERE zone = 'thevoida' AND spawngroupID IN (SELECT spawngroupID FROM spawnentry WHERE npcID = 1200031);
UPDATE spawn2 SET x = 90.05, y = 45.16, z = 4.33, heading = 338 WHERE zone = 'thevoida' AND spawngroupID IN (SELECT spawngroupID FROM spawnentry WHERE npcID = 1200044);
DELETE FROM zone_state_spawns WHERE npc_id IN (1200010, 1200030, 1200031, 1200044);
