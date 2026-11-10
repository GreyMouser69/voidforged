-- Move the Echo of the Past NPCs that stood far from where #zone drops players (each zone's safe point,
-- 500 to 7,500 units away) to 15 units from it, at the safe point's height (the server puts NPCs on the ground).
-- Zone state saving keeps NPC positions, so update the saved rows too, or the old positions come back.
-- Apply with the server stopped: a running zone saves its state when it shuts down.
--   skyfire, frontiermtns, emeraldjungle, kael, wakening, qvic, cobaltscar, highpasshold, timorous, mire,
--   qinimi, stonebrunt, gfaydark
UPDATE spawn2 s2
JOIN zone z ON z.short_name = s2.zone AND z.version = s2.version
SET s2.x = z.safe_x + 15, s2.y = z.safe_y, s2.z = z.safe_z
WHERE s2.id IN (2141231, 3387592, 2141229, 2141594, 2141352, 2141663, 2141637, 3387898, 3387591, 2141519,
                2141651, 3388038, 3388040);

UPDATE zone_state_spawns zs
JOIN spawn2 s2 ON s2.id = zs.spawn2_id
SET zs.x = s2.x, zs.y = s2.y, zs.z = s2.z
WHERE zs.spawn2_id IN (2141231, 3387592, 2141229, 2141594, 2141352, 2141663, 2141637, 3387898, 3387591, 2141519,
                       2141651, 3388038, 3388040);
