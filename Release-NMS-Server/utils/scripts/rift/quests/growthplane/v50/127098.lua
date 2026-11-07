-- ============================================================================
-- TUNARE, RAID PORTAL VERSION
-- Deploy to: quests/growthplane/v50/127098.lua
-- In the open world Tunare calls every NPC in the zone onto her attackers, on the pull and each minute.
-- A portal instance holds no other NPCs, so she calls her protectors in: two on the pull, two more
-- each minute. The tree swap, 15 minute depop and flag are open-world only.
-- ============================================================================

local portal = require("raid_portal")

local PROTECTORS = { 127002, 127003, 127014, 127016 } -- a_protector_of_growth x2, a_mosscovered_treant, keeper_of_the_glades
local CALL_MS    = 60 * 1000

local function call_protectors(e)
    local x, y, z, h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()
    e.self:Emote(" calls upon the Plane of Growth to defend its mother!")
    for i = 1, 2 do
        local offset = (i == 1) and 25 or -25
        portal.spawn_add(PROTECTORS[math.random(#PROTECTORS)], x + offset, y + offset, z, h, e.self:GetHateRandom())
    end
end

function event_combat(e)
    if e.joined then
        call_protectors(e)
        eq.set_timer("call", CALL_MS)
    else
        eq.stop_timer("call")
    end
end

function event_timer(e)
    if e.timer == "call" then
        if e.self:IsEngaged() then
            call_protectors(e)
        else
            eq.stop_timer("call")
        end
    end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        portal.depop_all(PROTECTORS)
    end
end

function event_death_complete(e)
    eq.stop_timer("call")
end
