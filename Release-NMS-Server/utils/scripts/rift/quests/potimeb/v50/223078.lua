-- ============================================================================
-- VALLON ZEK, RAID PORTAL VERSION
-- Deploy to: quests/potimeb/v50/223078.lua
-- Keeps his fight: two copies of him at 51% (#Vallon_Zek, whose open-world script tethers them), and
-- a tether to his arena that sends him home, wipes his hate and casts Balance of the Nameless. In the
-- open world Tallon Zek fights beside him; here he fights alone. No zone status signals.
-- ============================================================================

local portal = require("raid_portal")
local box = require("aa_box")

local COPY = 223164
local tether_box = box(229.2, -229.2, 246, 446.2)

function event_spawn(e)
    eq.set_next_hp_event(51)
    eq.set_timer("tether", 6 * 1000)
end

function event_timer(e)
    if e.timer == "tether" and not tether_box:contains(e.self:GetX(), e.self:GetY()) then
        e.self:GotoBind()
        e.self:WipeHateList()
        e.self:CastSpell(3230, e.self:GetID()) -- Balance of the Nameless
    end
end

function event_hp(e)
    if e.hp_event == 51 then
        eq.spawn2(COPY, 0, 0, 360, 75, 358, 384)
        eq.spawn2(COPY, 0, 0, 300, 75, 348, 384)
    end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        eq.depop_all(COPY)
        eq.set_next_hp_event(51)
    end
end
