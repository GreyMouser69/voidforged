-- A row of tradeskill stations in the Bazaar (version 0) by the banks, evenly spaced from -4.42, -837.16 to
-- -118.34, -839.06: forge, oven, brew barrel, loom, pottery wheel, kiln. Each is a copy of an existing station.
-- The floor there is z 0 (a #loc z is the player's height, not the floor's); the server's bazaar.map is the newer
-- Bazaar, so it can't place them on the floor itself.
-- Objects load at zone boot: restart or #repop the Bazaar after applying.
CREATE TEMPORARY TABLE bazaar_stations SELECT * FROM object WHERE id IN (69129, 69132, 69130, 227867, 69128, 69134);
UPDATE bazaar_stations SET xpos =   -4.42, ypos = -837.16 WHERE id = 69129;  -- forge
UPDATE bazaar_stations SET xpos =  -27.20, ypos = -837.54 WHERE id = 69132;  -- oven
UPDATE bazaar_stations SET xpos =  -50.00, ypos = -837.92 WHERE id = 69130;  -- brew barrel
UPDATE bazaar_stations SET xpos =  -72.77, ypos = -838.30 WHERE id = 227867; -- loom
UPDATE bazaar_stations SET xpos =  -95.56, ypos = -838.68 WHERE id = 69128;  -- pottery wheel
UPDATE bazaar_stations SET xpos = -118.34, ypos = -839.06 WHERE id = 69134;  -- kiln
UPDATE bazaar_stations SET id = 0, zoneid = 151, version = 0, zpos = 0, heading = 256;
INSERT INTO object SELECT * FROM bazaar_stations;
DROP TEMPORARY TABLE bazaar_stations;

-- Second row, from 148.44, -763.82 to 150.30, -674.23
CREATE TEMPORARY TABLE bazaar_stations SELECT * FROM object WHERE id IN (69129, 69132, 69130, 227867, 69128, 69134);
UPDATE bazaar_stations SET xpos = 148.44, ypos = -763.82 WHERE id = 69129;  -- forge
UPDATE bazaar_stations SET xpos = 148.81, ypos = -745.90 WHERE id = 69132;  -- oven
UPDATE bazaar_stations SET xpos = 149.18, ypos = -727.98 WHERE id = 69130;  -- brew barrel
UPDATE bazaar_stations SET xpos = 149.56, ypos = -710.07 WHERE id = 227867; -- loom
UPDATE bazaar_stations SET xpos = 149.93, ypos = -692.15 WHERE id = 69128;  -- pottery wheel
UPDATE bazaar_stations SET xpos = 150.30, ypos = -674.23 WHERE id = 69134;  -- kiln
UPDATE bazaar_stations SET id = 0, zoneid = 151, version = 0, zpos = 0, heading = 128;
INSERT INTO object SELECT * FROM bazaar_stations;
DROP TEMPORARY TABLE bazaar_stations;
