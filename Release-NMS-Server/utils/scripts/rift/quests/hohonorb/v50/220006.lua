-- ============================================================================
-- MITHANIEL MARR, RAID PORTAL VERSION
-- Deploy to: quests/hohonorb/v50/220006.lua
-- Replaces the open-world script: shared mechanics and a leash, no flags, banish or titles.
-- ============================================================================

local portal = require("raid_portal")

function event_spawn(e)  portal.boss_spawn(e)  end
function event_combat(e) portal.boss_combat(e) end
function event_timer(e)  portal.boss_timer(e)  end
