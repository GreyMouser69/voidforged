-- These spells are what an AA casts, but each one is also flagged usable by a class at a normal level, so
-- Custom:AutoScribeSpells puts it in spell books and players get the AA for free. None is sold as a scroll.
-- Make them unusable by players (255) and take them out of books and spell bars; the AAs still cast them.
-- Same fix as 2026_11_08_02_gut_punch_unscribable.sql. Spells load at server start, and the books must not be
-- in memory: apply with nobody online, then restart the server.
--   5234  Area Taunt           Warrior 51
--   5939  Press the Attack     Warrior 1
--   11033 Grappling Strike     Warrior 1, Monk 1
--   16172 Bite of the Asp      Beastlord 1
--   16228 Focus of Arcanum     Shadow Knight, Necromancer, Wizard, Magician, Enchanter 51
--   37196 Imperator's Command  Warrior 51
UPDATE spells_new SET
	classes1 = 255, classes2 = 255, classes3 = 255, classes4 = 255, classes5 = 255, classes6 = 255,
	classes7 = 255, classes8 = 255, classes9 = 255, classes10 = 255, classes11 = 255, classes12 = 255,
	classes13 = 255, classes14 = 255, classes15 = 255, classes16 = 255
WHERE id IN (5234, 5939, 11033, 16172, 16228, 37196);
DELETE FROM character_spells WHERE spell_id IN (5234, 5939, 11033, 16172, 16228, 37196);
DELETE FROM character_memmed_spells WHERE spell_id IN (5234, 5939, 11033, 16172, 16228, 37196);
