-- Open-world Lord Inquisitor Seru (leash form): 1,201,500 HP and 1,000 regen made reaching High Inquisitor Xeru
-- (2026_11_06_01_xeru.sql, copied from the old values and left as is) a very long fight. Raid portal Seru sets
-- its own HP, so this does not change it.

UPDATE npc_types SET hp = 250000, hp_regen_rate = 50 WHERE id = 159691;
