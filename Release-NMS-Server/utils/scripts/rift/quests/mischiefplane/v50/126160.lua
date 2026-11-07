-- ============================================================================
-- BRISTLEBANE, RAID PORTAL VERSION
-- Deploy to: quests/mischiefplane/v50/126160.lua
-- The open-world #Bristlebane.pl in Lua: puppets of the gods at 80%, 50% and 20%, each on his top hate.
-- Adds the reset after a wipe so the puppets come again on the next try.
-- ============================================================================

local portal = require("raid_portal")

local RALLOS, TUNARE, INNORUUK, SOLUSEK, EROLLISI, TRIBUNAL = 126265, 126163, 126153, 126249, 126291, 126246
local PUPPETS = { RALLOS, TUNARE, INNORUUK, SOLUSEK, EROLLISI, TRIBUNAL }

-- hp event = { next event, { puppet, x offset, y offset }, ... }
local WAVES = {
    [80] = { 50, { RALLOS, 10, 10 }, { TUNARE, -10, -10 }, { INNORUUK, 5, 5 } },
    [50] = { 20, { SOLUSEK, 10, 10 }, { TUNARE, -10, -10 }, { INNORUUK, 5, 5 }, { EROLLISI, -5, -5 } },
    [20] = { nil, { RALLOS, 10, 10 }, { TUNARE, -10, -10 }, { INNORUUK, 5, 5 }, { EROLLISI, -5, -5 },
             { TRIBUNAL, 15, -15 } },
}

function event_spawn(e)
    eq.set_next_hp_event(80)
end

function event_hp(e)
    local wave = WAVES[e.hp_event]
    if not wave then return end

    local x, y, z, h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()
    for i = 2, #wave do
        local puppet = wave[i]
        portal.spawn_add(puppet[1], x + puppet[2], y + puppet[3], z, h, e.self:GetHateTop())
    end
    if wave[1] then eq.set_next_hp_event(wave[1]) end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        portal.depop_all(PUPPETS)
        eq.set_next_hp_event(80)
    end
end
