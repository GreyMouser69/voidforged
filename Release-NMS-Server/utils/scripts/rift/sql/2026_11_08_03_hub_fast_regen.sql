-- Rest regen (sitting or mounted, no recent combat) refills health, mana and endurance from empty in 60 seconds
-- instead of 180 everywhere, and in 15 seconds in the hub zones. Only 180s change, so the Plane of Torment and
-- Lair of Terris Thule keep their 5000-second health regen. Zones read these at boot: restart them after applying.
UPDATE zone SET fast_regen_hp = 60 WHERE fast_regen_hp = 180;
UPDATE zone SET fast_regen_mana = 60 WHERE fast_regen_mana = 180;
UPDATE zone SET fast_regen_endurance = 60 WHERE fast_regen_endurance = 180;
UPDATE zone SET fast_regen_hp = 15, fast_regen_mana = 15, fast_regen_endurance = 15
WHERE short_name IN ('bazaar', 'thevoida', 'poknowledge', 'guildlobby');
