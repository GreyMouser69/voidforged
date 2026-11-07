-- ============================================================================
-- TERRIS THULE, RAID PORTAL VERSION
-- Deploy to: quests/potimeb/v50/223075.lua
-- Keeps her fight: at 91, 51 and 11% two pairs of nightmare adds walk in from the north and west
-- doors, two different kinds each time. No zone status signals or phase lockout.
-- ============================================================================

local portal = require("raid_portal")

local ADDS = { 223079, 223081, 223080, 223082 } -- Summoned Guardian, Summoned Knight, Phantasm, Nightmare Knight

local function spawn_adds()
    local first = ADDS[math.random(#ADDS)]
    local second
    repeat second = ADDS[math.random(#ADDS)] until second ~= first

    for _ = 1, 2 do
        local add = eq.spawn2(first, 0, 0, -219, 344, 348, 256)
        add:MoveTo(-219, 250, 348, 256, true)
        local add2 = eq.spawn2(second, 0, 0, -347, 210, 348, 128)
        add2:MoveTo(-260, 210, 348, 128, true)
    end
end

function event_spawn(e)
    eq.set_next_hp_event(91)
end

function event_hp(e)
    if e.hp_event == 91 then
        spawn_adds()
        eq.set_next_hp_event(51)
    elseif e.hp_event == 51 then
        spawn_adds()
        eq.set_next_hp_event(11)
    elseif e.hp_event == 11 then
        spawn_adds()
    end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        portal.depop_all(ADDS)
        eq.set_next_hp_event(91)
    end
end
