-- ============================================================================
-- EMPEROR SSRAESHZA, RAID PORTAL VERSION
-- Deploy to: quests/ssratemple/v50/162227.lua
-- His encounter script only runs the Blood of Ssraeshza spawn chain and the wraiths and flag after
-- his death; it has no combat mechanics. So in the portal he gets the shared mechanics and a leash,
-- and keeps his slay line. script_init_v50.lua already keeps the encounter out of version 50.
-- ============================================================================

local portal = require("raid_portal")

function event_spawn(e)  portal.boss_spawn(e)  end
function event_combat(e) portal.boss_combat(e) end
function event_timer(e)  portal.boss_timer(e)  end

function event_slay(e)
    e.self:Say("Your god has found you lacking.")
end
