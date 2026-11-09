-- Berserker Decapitation (AA 133) works like Headshot on Frenzy (Mob::TryDecapitation). The level cap and damage
-- come from the rank in code: 60, 62, 64, 66, 68, 70. Rank 1 (14200) already exists; add ranks 2-6.
-- AA data loads at server start: restart after applying.
INSERT INTO aa_ranks (id, upper_hotkey_sid, lower_hotkey_sid, title_sid, desc_sid, cost, level_req, spell, spell_type,
	recast_time, expansion, prev_id, next_id) VALUES
	(19563, -1, -1, 14200, 14200, 5, 50, -1, 0, 0, 0, 14200, 19564),
	(19564, -1, -1, 14200, 14200, 5, 50, -1, 0, 0, 0, 19563, 19565),
	(19565, -1, -1, 14200, 14200, 7, 50, -1, 0, 0, 0, 19564, 19566),
	(19566, -1, -1, 14200, 14200, 9, 50, -1, 0, 0, 0, 19565, 19567),
	(19567, -1, -1, 14200, 14200, 12, 50, -1, 0, 0, 0, 19566, -1);
UPDATE aa_ranks SET next_id = 19563 WHERE id = 14200;
-- Rank 1 carried a 50,000 damage spell with no recast; Decapitation is a Frenzy proc, not a clicky
UPDATE aa_ranks SET spell = -1 WHERE id = 14200;
-- Decapitation (AA 133) was titled Cleaving Frenzy; the description now covers the Frenzy crits and the decapitate proc
UPDATE db_str SET value = 'Decapitation' WHERE id = 14200 AND type = 1;
UPDATE db_str SET value = 'Your Frenzy attacks inflict significantly more damage whenever they critically hit, and you become increasingly likely to land critical hits when using Frenzy. Your Frenzy attacks can also decapitate a humanoid target for massive damage. Rank 1 works on targets up to level 60, and each further rank raises that by 2 levels, to 70 at rank 6.' WHERE id = 14200 AND type = 4;
