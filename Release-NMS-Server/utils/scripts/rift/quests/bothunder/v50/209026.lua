-- ============================================================================
-- AGNARR THE STORM LORD, RAID PORTAL VERSION
-- Deploy to: quests/bothunder/v50/209026.lua
-- Keeps his four storm lords at 98, 75, 50 and 25%, and every 2 minutes in combat a storm add from
-- each of the four storm portals; all of them come to his side. In the open world the portals are
-- NPCs that wait for his signal; here he spawns the adds at their spots himself. No planar projection,
-- Karana or flag.
-- ============================================================================

local portal = require("raid_portal")

local LORD_SPOT  = { -1082, -1740, 2251, 127 }
local LORDS      = { [98] = { 209115, 75 }, [75] = { 209104, 50 }, [50] = { 209105, 25 }, [25] = { 209106, nil } }
local STORMS     = { 209107, 209124, 209125, 209126 } -- a_storm_cloud, a_firestorm, a_hurricane, a_comet
local PORTALS    = {
    { -1043.28, -1869.52, 2251.13, 69 }, { -901.49, -1542.72, 2252.38, 256.75 },
    { -898.72, -1924.84, 2252.38, 0 },   { -1034.89, -1565.27, 2251.13, 203.75 },
}
local HELPERS = { 209104, 209105, 209106, 209115, 209107, 209124, 209125, 209126 }
local IS_HELPER = {}
for _, npc_id in ipairs(HELPERS) do IS_HELPER[npc_id] = true end

local function help_agnarr(e)
    for npc in eq.get_entity_list():GetNPCList().entries do
        if npc.valid and IS_HELPER[npc:GetNPCTypeID()] and not npc:IsEngaged() then
            npc:SetRunning(true)
            npc:MoveTo(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0, false)
        end
    end
end

function event_spawn(e)
    eq.set_next_hp_event(98)
end

function event_combat(e)
    if e.joined then
        eq.set_timer("adds", 120 * 1000)
    else
        eq.stop_timer("adds")
    end
end

function event_timer(e)
    if e.timer == "help" then
        eq.stop_timer("help")
        help_agnarr(e)
    elseif e.timer == "adds" then
        eq.zone_emote(MT.White, "Agnarr strikes his staff to the ground, causing great ripples of energy to rage across the room.")
        for _, p in ipairs(PORTALS) do
            eq.spawn2(STORMS[math.random(#STORMS)], 0, 0, p[1], p[2], p[3], p[4])
        end
        eq.set_timer("help", 1000)
    end
end

function event_hp(e)
    local lord = LORDS[e.hp_event]
    if not lord then return end

    eq.unique_spawn(lord[1], 0, 0, LORD_SPOT[1], LORD_SPOT[2], LORD_SPOT[3], LORD_SPOT[4])
    eq.set_timer("help", 1000)
    if lord[2] then eq.set_next_hp_event(lord[2]) end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        portal.depop_all(HELPERS)
        eq.set_next_hp_event(98)
    end
end
