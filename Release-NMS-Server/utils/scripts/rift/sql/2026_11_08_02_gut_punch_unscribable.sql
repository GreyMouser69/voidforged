-- Gut Punch (12802) is the first rank of the Warrior AA Gut Punch, but it was also usable by Warriors at level 1, so
-- Custom:AutoScribeSpells put it in their spell books. Make it unusable by players (255) and take it out of the books;
-- the AA still casts it. Spells load at server start, and the books must not be in memory: apply with the server
-- stopped. Same fix as 2026_11_04_01_echo_spells_unscribable.sql.
UPDATE spells_new SET classes1 = 255 WHERE id = 12802;
DELETE FROM character_spells WHERE spell_id = 12802;
-- Players who had it memorized could not remove it from the spell bar once it left the book
DELETE FROM character_memmed_spells WHERE spell_id = 12802;
