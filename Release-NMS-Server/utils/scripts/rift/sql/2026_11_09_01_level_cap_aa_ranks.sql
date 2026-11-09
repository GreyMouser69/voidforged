-- Headshot, Assassinate and Dire Charm reach level 70 through AA (the level cap is 65).
-- AA and spell data load at server start: restart after applying. Dire Charm II needs its spells in the client's
-- spells_us.txt (44030-44032).

-- Headshot (Ranger, AA 218): ranks 64, 66, 68, 70 after the 62 rank, from the switched-off ranks 6017-6019 and 7359
UPDATE aa_ranks SET level_req = 1, expansion = 12 WHERE id IN (6017, 6018, 6019, 7359);
UPDATE aa_rank_effects SET base1 = 64 WHERE rank_id = 6017 AND effect_id = 346;
UPDATE aa_rank_effects SET base1 = 66 WHERE rank_id = 6018 AND effect_id = 346;
UPDATE aa_rank_effects SET base1 = 68 WHERE rank_id = 6019 AND effect_id = 346;
UPDATE aa_rank_effects SET base1 = 70 WHERE rank_id = 7359 AND effect_id = 346;

-- Assassinate (Rogue, part of Anatomy, AA 555): switch on the 68 and 70 ranks after the 62 rank
UPDATE aa_ranks SET expansion = 12 WHERE id IN (6032, 6033);

-- Dire Charm II: a second rank on each Dire Charm, charming up to level 70 instead of 46
CREATE TEMPORARY TABLE dire_charm_spells SELECT * FROM spells_new WHERE id IN (2759, 2760, 2761);
UPDATE dire_charm_spells SET id = 44030 WHERE id = 2761; -- Enchanter
UPDATE dire_charm_spells SET id = 44031 WHERE id = 2760; -- Druid, animals
UPDATE dire_charm_spells SET id = 44032 WHERE id = 2759; -- Necromancer, undead
UPDATE dire_charm_spells SET name = 'Dire Charm II', max1 = 70;
INSERT INTO spells_new SELECT * FROM dire_charm_spells;
DROP TEMPORARY TABLE dire_charm_spells;

CREATE TEMPORARY TABLE dire_charm_ranks SELECT * FROM aa_ranks WHERE id IN (145, 960, 961);
UPDATE dire_charm_ranks SET prev_id = id, next_id = -1;
UPDATE dire_charm_ranks SET id = 19560, spell = 44030 WHERE id = 145;
UPDATE dire_charm_ranks SET id = 19561, spell = 44031 WHERE id = 960;
UPDATE dire_charm_ranks SET id = 19562, spell = 44032 WHERE id = 961;
INSERT INTO aa_ranks SELECT * FROM dire_charm_ranks;
DROP TEMPORARY TABLE dire_charm_ranks;
UPDATE aa_ranks SET next_id = 19560 WHERE id = 145;
UPDATE aa_ranks SET next_id = 19561 WHERE id = 960;
UPDATE aa_ranks SET next_id = 19562 WHERE id = 961;
