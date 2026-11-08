-- Open #mystats to every player, the same access #zone has. Zones load command access at boot (or #reload commands).
UPDATE command_settings SET access = 0 WHERE command = 'mystats';
