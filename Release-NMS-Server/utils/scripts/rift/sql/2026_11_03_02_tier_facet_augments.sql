-- Tier augment vendors: the six themed augments become one all-stat Facet per tier, sold as I and II
-- (same stats, two item ids, so one item can hold both), aug types 1, 2 and 4. Tier 1 unlocks at a deepest
-- clear of 50 (was 75), each later tier 25 sooner too. Matches gen_tier_gear.py with tier_gear.json; no player
-- owned any of the old augments when this ran. Items load at server start, so restart after applying.

START TRANSACTION;

-- Tier 1
DELETE FROM merchantlist WHERE item IN (941802, 941803, 941804, 941805);
DELETE FROM items WHERE id IN (941802, 941803, 941804, 941805);
UPDATE items SET Name = 'Chronal Facet I', lore = 'Chronal Facet I', augtype = 11, icon = 3880, focuseffect = -1, focustype = 0, ac = 15, hp = 150, mana = 150, endur = 150, astr = 10, asta = 10, aagi = 10, adex = 10, awis = 10, aint = 10, acha = 10, mr = 10, fr = 10, cr = 10, dr = 10, pr = 10, heroic_str = 4, heroic_sta = 4, heroic_dex = 4, attack = 15, spelldmg = 15, healamt = 15 WHERE id = 941800;
UPDATE items SET Name = 'Chronal Facet II', lore = 'Chronal Facet II', augtype = 11, icon = 3876, focuseffect = -1, focustype = 0, ac = 15, hp = 150, mana = 150, endur = 150, astr = 10, asta = 10, aagi = 10, adex = 10, awis = 10, aint = 10, acha = 10, mr = 10, fr = 10, cr = 10, dr = 10, pr = 10, heroic_str = 4, heroic_sta = 4, heroic_dex = 4, attack = 15, spelldmg = 15, healamt = 15 WHERE id = 941801;
UPDATE merchantlist SET bucket_value = '50' WHERE item IN (941800, 941801);

-- Tier 2
DELETE FROM merchantlist WHERE item IN (946802, 946803, 946804, 946805);
DELETE FROM items WHERE id IN (946802, 946803, 946804, 946805);
UPDATE items SET Name = 'Tempered Facet I', lore = 'Tempered Facet I', augtype = 11, icon = 3880, focuseffect = -1, focustype = 0, ac = 22, hp = 225, mana = 225, endur = 225, astr = 15, asta = 15, aagi = 15, adex = 15, awis = 15, aint = 15, acha = 15, mr = 15, fr = 15, cr = 15, dr = 15, pr = 15, heroic_str = 6, heroic_sta = 6, heroic_dex = 6, attack = 22, spelldmg = 22, healamt = 22 WHERE id = 946800;
UPDATE items SET Name = 'Tempered Facet II', lore = 'Tempered Facet II', augtype = 11, icon = 3876, focuseffect = -1, focustype = 0, ac = 22, hp = 225, mana = 225, endur = 225, astr = 15, asta = 15, aagi = 15, adex = 15, awis = 15, aint = 15, acha = 15, mr = 15, fr = 15, cr = 15, dr = 15, pr = 15, heroic_str = 6, heroic_sta = 6, heroic_dex = 6, attack = 22, spelldmg = 22, healamt = 22 WHERE id = 946801;
UPDATE merchantlist SET bucket_value = '150' WHERE item IN (946800, 946801);

-- Tier 3
DELETE FROM merchantlist WHERE item IN (951802, 951803, 951804, 951805);
DELETE FROM items WHERE id IN (951802, 951803, 951804, 951805);
UPDATE items SET Name = 'Exalted Facet I', lore = 'Exalted Facet I', augtype = 11, icon = 3880, focuseffect = -1, focustype = 0, ac = 30, hp = 300, mana = 300, endur = 300, astr = 20, asta = 20, aagi = 20, adex = 20, awis = 20, aint = 20, acha = 20, mr = 20, fr = 20, cr = 20, dr = 20, pr = 20, heroic_str = 8, heroic_sta = 8, heroic_dex = 8, attack = 30, spelldmg = 30, healamt = 30 WHERE id = 951800;
UPDATE items SET Name = 'Exalted Facet II', lore = 'Exalted Facet II', augtype = 11, icon = 3876, focuseffect = -1, focustype = 0, ac = 30, hp = 300, mana = 300, endur = 300, astr = 20, asta = 20, aagi = 20, adex = 20, awis = 20, aint = 20, acha = 20, mr = 20, fr = 20, cr = 20, dr = 20, pr = 20, heroic_str = 8, heroic_sta = 8, heroic_dex = 8, attack = 30, spelldmg = 30, healamt = 30 WHERE id = 951801;
UPDATE merchantlist SET bucket_value = '250' WHERE item IN (951800, 951801);

-- Tier 4
DELETE FROM merchantlist WHERE item IN (956802, 956803, 956804, 956805);
DELETE FROM items WHERE id IN (956802, 956803, 956804, 956805);
UPDATE items SET Name = 'Eternal Facet I', lore = 'Eternal Facet I', augtype = 11, icon = 3880, focuseffect = -1, focustype = 0, ac = 38, hp = 375, mana = 375, endur = 375, astr = 25, asta = 25, aagi = 25, adex = 25, awis = 25, aint = 25, acha = 25, mr = 25, fr = 25, cr = 25, dr = 25, pr = 25, heroic_str = 10, heroic_sta = 10, heroic_dex = 10, attack = 38, spelldmg = 38, healamt = 38 WHERE id = 956800;
UPDATE items SET Name = 'Eternal Facet II', lore = 'Eternal Facet II', augtype = 11, icon = 3876, focuseffect = -1, focustype = 0, ac = 38, hp = 375, mana = 375, endur = 375, astr = 25, asta = 25, aagi = 25, adex = 25, awis = 25, aint = 25, acha = 25, mr = 25, fr = 25, cr = 25, dr = 25, pr = 25, heroic_str = 10, heroic_sta = 10, heroic_dex = 10, attack = 38, spelldmg = 38, healamt = 38 WHERE id = 956801;
UPDATE merchantlist SET bucket_value = '350' WHERE item IN (956800, 956801);

-- Tier 5
DELETE FROM merchantlist WHERE item IN (961802, 961803, 961804, 961805);
DELETE FROM items WHERE id IN (961802, 961803, 961804, 961805);
UPDATE items SET Name = 'Timeless Facet I', lore = 'Timeless Facet I', augtype = 11, icon = 3880, focuseffect = -1, focustype = 0, ac = 45, hp = 450, mana = 450, endur = 450, astr = 30, asta = 30, aagi = 30, adex = 30, awis = 30, aint = 30, acha = 30, mr = 30, fr = 30, cr = 30, dr = 30, pr = 30, heroic_str = 12, heroic_sta = 12, heroic_dex = 12, attack = 45, spelldmg = 45, healamt = 45 WHERE id = 961800;
UPDATE items SET Name = 'Timeless Facet II', lore = 'Timeless Facet II', augtype = 11, icon = 3876, focuseffect = -1, focustype = 0, ac = 45, hp = 450, mana = 450, endur = 450, astr = 30, asta = 30, aagi = 30, adex = 30, awis = 30, aint = 30, acha = 30, mr = 30, fr = 30, cr = 30, dr = 30, pr = 30, heroic_str = 12, heroic_sta = 12, heroic_dex = 12, attack = 45, spelldmg = 45, healamt = 45 WHERE id = 961801;
UPDATE merchantlist SET bucket_value = '450' WHERE item IN (961800, 961801);

COMMIT;
