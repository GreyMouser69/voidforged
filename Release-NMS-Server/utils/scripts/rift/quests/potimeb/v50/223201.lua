-- ============================================================================
-- QUARM, RAID PORTAL VERSION
-- Deploy to: quests/potimeb/v50/223201.lua
-- Keeps his fight: three time vortexes every 50 seconds, an AE every 25 seconds from a list that
-- changes as each head falls at 76, 51 and 26%, and a buff strip at each head. He starts at his
-- spawn point instead of walking the phase 6 path, and nothing signals the zone status or Zebuxoruk.
-- ============================================================================

local portal = require("raid_portal")

local VORTEX = 223112
-- AE spells by phase: Epoch Conviction, Infernal Flames, Glacier Breath, Venomed Mist, Plagued Earth and later forms
local AE_SPELLS = {
    { 3767, 3768, 3769, 3770, 3771 },
    { 3772, 3773, 3774, 3775 },
    { 3776, 3777, 3778 },
    { 3779, 3780 },
}
-- hp event = { phase it starts, next event, helm texture, emote }
local HEADS = {
    [76] = { 2, 51, 1, " roars in pain as his red head explodes in a shower of flaming ethereal energy!" },
    [51] = { 3, 26, 2, " roars in pain as his blue head explodes into pure ethereal energy!" },
    [26] = { 4, nil, 3, " shakes the cavern with a bellow of pain as the white head explodes into a swirling vortex of ethereal energy!" },
}

local function phase(e)
    return tonumber(e.self:GetEntityVariable("quarm_phase")) or 1
end

local function reset_heads(e)
    e.self:SetEntityVariable("quarm_phase", "1")
    e.self:SendIllusionPacket({ race = 304, gender = 2, texture = 0, helmtexture = 0 })
    eq.set_next_hp_event(76)
end

local function spawn_vortexes(e)
    eq.depop_all(VORTEX)
    local x, y, h = e.self:GetX(), e.self:GetY(), e.self:GetHeading()
    for _ = 1, 3 do
        eq.spawn2(VORTEX, 0, 0, x + math.random(-50, 50), y + math.random(-50, 50), 3, h)
    end
end

function event_spawn(e)
    reset_heads(e)
end

function event_combat(e)
    if e.joined then
        eq.set_timer("adds", 2000)
        eq.set_timer("ae", math.random(1000, 3000))
    else
        eq.stop_timer("adds")
        eq.stop_timer("ae")
    end
end

function event_timer(e)
    if e.timer == "adds" then
        eq.set_timer("adds", 50 * 1000)
        spawn_vortexes(e)
    elseif e.timer == "ae" then
        eq.set_timer("ae", 25 * 1000)
        local spells = AE_SPELLS[phase(e)]
        e.self:CastSpell(spells[math.random(#spells)], e.self:GetID())
    end
end

function event_hp(e)
    local head = HEADS[e.hp_event]
    if not head then return end

    e.self:SetEntityVariable("quarm_phase", tostring(head[1]))
    e.self:Emote(head[4])
    e.self:SendIllusionPacket({ race = 304, gender = 2, texture = 0, helmtexture = head[3] })
    -- Each head strips his buffs and restarts the AE timer
    e.self:BuffFadeAll()
    eq.set_timer("ae", 6000)
    if head[2] then eq.set_next_hp_event(head[2]) end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        eq.depop_all(VORTEX)
        reset_heads(e)
    end
end

function event_death_complete(e)
    eq.depop_all(VORTEX)
end
