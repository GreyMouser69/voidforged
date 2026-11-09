-- Ranger arrows on the tier Weaponsmiths: tier 1 matches Planar Arrow of Drunder (Legendary), the best arrow through
-- Planes of Power, and each tier multiplies its damage like the tier weapons (34, 51, 68, 85, 102). Ranger only,
-- No Trade, not lore and stackable: a ranger keeps one in the ammo slot and one in a quiver. Same unlock as the tier's
-- weapons. Items 940000 + (tier - 1) * 5000 + 2900.
-- Items load into shared memory at server start: restart after applying.
DELETE FROM merchantlist WHERE merchantid BETWEEN 1200044 AND 1200048 AND item IN (942900, 947900, 952900, 957900, 962900);
DELETE FROM items WHERE id IN (942900, 947900, 952900, 957900, 962900);

CREATE TEMPORARY TABLE tier_arrows SELECT * FROM items WHERE id = 2017842;
UPDATE tier_arrows SET classes = 8, nodrop = 0, loregroup = 0, attuneable = 0, price = 0;
UPDATE tier_arrows SET id = 942900, Name = 'Chronal Arrow', lore = 'Chronal Arrow', damage = 34;
INSERT INTO items SELECT * FROM tier_arrows;
UPDATE tier_arrows SET id = 947900, Name = 'Tempered Arrow', lore = 'Tempered Arrow', damage = 51;
INSERT INTO items SELECT * FROM tier_arrows;
UPDATE tier_arrows SET id = 952900, Name = 'Exalted Arrow', lore = 'Exalted Arrow', damage = 68;
INSERT INTO items SELECT * FROM tier_arrows;
UPDATE tier_arrows SET id = 957900, Name = 'Eternal Arrow', lore = 'Eternal Arrow', damage = 85;
INSERT INTO items SELECT * FROM tier_arrows;
UPDATE tier_arrows SET id = 962900, Name = 'Timeless Arrow', lore = 'Timeless Arrow', damage = 102;
INSERT INTO items SELECT * FROM tier_arrows;
DROP TEMPORARY TABLE tier_arrows;

INSERT INTO merchantlist (merchantid, slot, item, alt_currency_cost, classes_required, bucket_name, bucket_value, bucket_comparison) VALUES
	(1200044, 144, 942900, 15, 8, 'rift_deepest', '75', 2),
	(1200045, 144, 947900, 30, 8, 'rift_deepest', '175', 2),
	(1200046, 144, 952900, 60, 8, 'rift_deepest', '275', 2),
	(1200047, 144, 957900, 120, 8, 'rift_deepest', '375', 2),
	(1200048, 144, 962900, 240, 8, 'rift_deepest', '475', 2);
