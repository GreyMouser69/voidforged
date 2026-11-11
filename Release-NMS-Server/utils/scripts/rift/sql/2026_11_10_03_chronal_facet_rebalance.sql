-- Rift Facet augments, rebalanced. Chronal Facet I and II (tier-50 Chronal_Augmenter) were several times the best
-- Planes of Power augment (Frozen Ball Lightning: 65 HP, 20 mana, 20 endurance, 2 STA). Chronal comes down to a
-- little above it, and the later vendors keep their old steps over Chronal (1.5x, 2x, 2.5x, 3x) on the new base.
-- Each vendor's Facet I and II stay identical. No attack, heal amount or spell damage at any tier.
-- Items load at server start; the server sends item stats to the client, so no client file changes.
-- Facets already bought or slotted change too.
--   tier      vendor (deepest)   AC  HP   mana/end  stats/resists  heroic stats
--   Chronal   50                 10  75   30        3              1
--   Tempered  150                15  115  45        5              2
--   Exalted   250                20  150  60        6              2
--   Eternal   350                25  190  75        8              3
--   Timeless  450                30  225  90        9              3
UPDATE items i
JOIN (
	          SELECT 941800 AS id, 10 AS ac,  75 AS hp, 30 AS me, 3 AS st, 1 AS he
	UNION ALL SELECT 941801, 10,  75, 30, 3, 1
	UNION ALL SELECT 946800, 15, 115, 45, 5, 2
	UNION ALL SELECT 946801, 15, 115, 45, 5, 2
	UNION ALL SELECT 951800, 20, 150, 60, 6, 2
	UNION ALL SELECT 951801, 20, 150, 60, 6, 2
	UNION ALL SELECT 956800, 25, 190, 75, 8, 3
	UNION ALL SELECT 956801, 25, 190, 75, 8, 3
	UNION ALL SELECT 961800, 30, 225, 90, 9, 3
	UNION ALL SELECT 961801, 30, 225, 90, 9, 3
) t ON t.id = i.id
SET
	i.ac = t.ac, i.hp = t.hp, i.mana = t.me, i.endur = t.me,
	i.astr = t.st, i.asta = t.st, i.adex = t.st, i.aagi = t.st, i.aint = t.st, i.awis = t.st, i.acha = t.st,
	i.mr = t.st, i.fr = t.st, i.cr = t.st, i.dr = t.st, i.pr = t.st,
	i.heroic_str = t.he, i.heroic_sta = t.he, i.heroic_dex = t.he, i.heroic_agi = t.he,
	i.heroic_int = t.he, i.heroic_wis = t.he, i.heroic_cha = t.he,
	i.attack = 0, i.healamt = 0, i.spelldmg = 0;
