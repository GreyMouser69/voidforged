-- ============================================================================
-- LADY VOX, RAID PORTAL VERSION
-- Deploy to: quests/permafrost/v50/Lady_Vox.lua
-- Keeps her leash and adds the shared mechanics. No banish, flags or titles here.
-- ============================================================================

local portal = require("raid_portal")

function event_spawn(e)
    portal.shared_spawn(e.self)
end

function event_combat(e)
    if e.joined then
        eq.set_timer("leash", 1000)
    else
        eq.stop_timer("leash")
    end
end

function event_timer(e)
    if e.timer == "leash" then
        local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
        if x < -431 or x > -85 or y < 770 or y > 1090 or z < -50 then
            local s = portal.BOSSES.vox.spawn
            e.self:BuffFadeAll()
            e.self:WipeHateList()
            e.self:Heal()
            e.self:GMMove(s[1], s[2], s[3], s[4])
            eq.stop_timer("leash")
        end
    else
        portal.shared_timer(e.self, e.timer)
    end
end
