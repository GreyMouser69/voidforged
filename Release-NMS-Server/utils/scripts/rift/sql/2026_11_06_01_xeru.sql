-- High Inquisitor Xeru (quests/sseru/encounters/xeru_custom.lua): a copy of Lord Inquisitor Seru's leash form
-- (159691) under its own id and name. No loot table: the script grants his Fragments of Truth. Rerunnable.

START TRANSACTION;

DELETE FROM npc_types WHERE id = 1120002172;
CREATE TEMPORARY TABLE xeru SELECT * FROM npc_types WHERE id = 159691;
UPDATE xeru SET id = 1120002172, name = 'High_Inquisitor_Xeru', loottable_id = 0;
INSERT INTO npc_types SELECT * FROM xeru;
DROP TEMPORARY TABLE xeru;

COMMIT;
