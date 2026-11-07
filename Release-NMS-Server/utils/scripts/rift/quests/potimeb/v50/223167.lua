-- ============================================================================
-- INNORUUK (PLANE OF TIME), RAID PORTAL VERSION
-- Deploy to: quests/potimeb/v50/223167.lua
-- In the open world he only appears after his army of twelve dies. Here he spawns ready to fight with
-- his own script kept: 3-4 guardians and hatebringers at 75%, 4-5 at 20%, each on a random raid
-- member, and any idle add is pulled in every 3 seconds. No zone status signals.
-- ============================================================================

local portal = require("raid_portal")

local GUARDIAN, HATEBRINGER = 223231, 223232
local RANGE = 1000 * 1000

local function random_client(e)
    return eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), RANGE)
end

local function spawn_adds(e, min_adds, max_adds)
    local count = math.random(min_adds, max_adds)
    portal.spawn_add(GUARDIAN, 210, 315, 5, 257, random_client(e))
    portal.spawn_add(HATEBRINGER, 300, 215, 5, 387, random_client(e))
    if count >= 3 then portal.spawn_add(GUARDIAN, 280, 330, 15, 324, random_client(e)) end
    if count >= 4 then portal.spawn_add(HATEBRINGER, 325, 280, 15, 324, random_client(e)) end
    if count == 5 then
        portal.spawn_add(math.random(2) == 1 and GUARDIAN or HATEBRINGER, 255, 255, 5, 324, random_client(e))
    end
end

function event_spawn(e)
    eq.set_next_hp_event(75)
end

function event_hp(e)
    if e.hp_event == 75 then
        spawn_adds(e, 3, 4)
        eq.set_next_hp_event(20)
    elseif e.hp_event == 20 then
        spawn_adds(e, 4, 5)
    end
end

function event_combat(e)
    if e.joined then
        eq.set_timer("aggro_link", 3 * 1000)
    else
        eq.stop_timer("aggro_link")
    end
end

function event_timer(e)
    if e.timer == "aggro_link" then
        for npc in eq.get_entity_list():GetNPCList().entries do
            local npc_id = npc.valid and npc:GetNPCTypeID()
            if (npc_id == GUARDIAN or npc_id == HATEBRINGER) and not npc:IsEngaged() then
                npc:AddToHateList(e.self:GetHateRandom(), 1)
            end
        end
    end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        portal.depop_all({ GUARDIAN, HATEBRINGER })
        eq.set_next_hp_event(75)
    end
end
