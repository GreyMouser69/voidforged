-- The seven Echo server buffs (cast by Apocrypha) were usable by every class at level 1, so Custom:AutoScribeSpells
-- put them in every spell book. Make them unusable by players (255) and take them out of the books; Apocrypha
-- still casts them. Spells load at server start, and the books must not be in memory: apply with the server stopped.
UPDATE spells_new SET classes1 = 255, classes2 = 255, classes3 = 255, classes4 = 255, classes5 = 255, classes6 = 255,
	classes7 = 255, classes8 = 255, classes9 = 255, classes10 = 255, classes11 = 255, classes12 = 255, classes13 = 255,
	classes14 = 255, classes15 = 255, classes16 = 255
WHERE id IN (36856, 43003, 43004, 43005, 43006, 43007, 43008);
DELETE FROM character_spells WHERE spell_id IN (36856, 43003, 43004, 43005, 43006, 43007, 43008);
