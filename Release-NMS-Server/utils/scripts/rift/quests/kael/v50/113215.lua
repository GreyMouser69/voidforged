-- ============================================================================
-- KING TORMAX, RAID PORTAL VERSION
-- Deploy to: quests/kael/v50/113215.lua
-- His guards come with him: Kyenka and Yetarr, plus one of the two pairs of royal guards the open
-- world rolls at each spot. On the pull and every 5 minutes he calls them to his side, as in the open
-- world, and in the portal they also join the fight when they arrive. No faction, hails or flags.
-- ============================================================================

local portal = require("raid_portal")

local GUARDS = {
    { ids = { 113133 },                 loc = { 1581, -1419, -184.25, 128 } }, -- Kyenka
    { ids = { 113134 },                 loc = { 1820, -1419, -184.25, 382 } }, -- Yetarr
    { ids = { 113129, 113302, 113383 }, loc = { 1738, -1524, -183.63, 11 } },  -- Vkjen, Irrek or Klraggek
    { ids = { 113130, 113382 },         loc = { 1668, -1524, -183.63, 11 } },  -- Drendar or Velden
}
local ALL_GUARDS = { 113133, 113134, 113129, 113302, 113383, 113130, 113382 }

local function spawn_guards()
    portal.depop_all(ALL_GUARDS)
    for _, guard in ipairs(GUARDS) do
        local l = guard.loc
        eq.spawn2(guard.ids[math.random(#guard.ids)], 0, 0, l[1], l[2], l[3], l[4])
    end
end

local function call_guards(e)
    local entity_list = eq.get_entity_list()
    for _, npc_id in ipairs(ALL_GUARDS) do
        local guard = entity_list:GetNPCByNPCTypeID(npc_id)
        if guard.valid and not guard:IsEngaged() then
            guard:SetRunning(true)
            guard:MoveTo(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0, false)
            guard:AddToHateList(e.self:GetHateRandom(), 1)
        end
    end
end

function event_spawn(e)
    spawn_guards()
end

function event_combat(e)
    if e.joined then
        eq.set_timer("help", 300 * 1000)
        call_guards(e)
    else
        eq.stop_timer("help")
    end
end

function event_timer(e)
    if e.timer == "help" then
        e.self:Shout("Those who raise arms against me will suffer my wrath!")
        call_guards(e)
    end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        spawn_guards()
    end
end
