-- ============================================================================
-- RAID PORTAL: Zone Controller NPC
-- Deploy to: quests/global/Raid_Controller.lua   (npc_types.name Raid_Controller, ID 1200070)
--
-- An invisible, untargetable NPC with one spawn2 row at version 50 in every roster zone. It spawns
-- the instance's boss, and puts the boss back after a wipe so the raid can try again.
-- ============================================================================

local portal = require("raid_portal")

local RESET_AFTER_CHECKS = 6 -- 30 seconds out of combat; a hate wipe mechanic must not count as a wipe

function event_spawn(e)
    local instance_id = eq.get_zone_instance_id()
    local info = instance_id > 0 and portal.get_instance(instance_id) or nil
    if not info or eq.get_data(portal.key_paid(instance_id)) ~= "" then return end

    local boss = portal.boss_by_npc_id(info.boss_id)
    if not boss then return end

    eq.spawn2(boss.npc_id, 0, 0, boss.spawn[1], boss.spawn[2], boss.spawn[3], boss.spawn[4])
    e.self:SetEntityVariable("raid_idle", "0")
    eq.set_timer("raid_watch", 5000)
end

function event_timer(e)
    if e.timer ~= "raid_watch" then return end

    local instance_id = eq.get_zone_instance_id()
    local info = portal.get_instance(instance_id)
    local spawned = info and eq.get_entity_list():GetNPCByNPCTypeID(info.boss_id)
    if not spawned or not spawned.valid then return end

    if spawned:IsEngaged() or spawned:GetHP() >= spawned:GetMaxHP() then
        e.self:SetEntityVariable("raid_idle", "0")
        return
    end

    local idle = (tonumber(e.self:GetEntityVariable("raid_idle")) or 0) + 1
    e.self:SetEntityVariable("raid_idle", tostring(idle))
    if idle >= RESET_AFTER_CHECKS then
        local boss = portal.boss_by_npc_id(info.boss_id)
        spawned:BuffFadeAll()
        spawned:Heal()
        spawned:GMMove(boss.spawn[1], boss.spawn[2], boss.spawn[3], boss.spawn[4])
        spawned:DeleteEntityVariable("raid_adds")
        eq.signal(info.boss_id, portal.RESET_SIGNAL) -- a boss with phases puts them back
        e.self:SetEntityVariable("raid_idle", "0")
    end
end
