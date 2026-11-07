-- ============================================================================
-- ZUN`MURAM VOTAL, RAID PORTAL VERSION
-- Deploy to: quests/ferubi/v50/284080.lua
-- Keeps his open-world script: two Pixtt Votal spawn with him and join when he is pulled, and he
-- goes home with a hate wipe if pulled out of his room (y above -400). A wipe reset brings the
-- Pixtt back at once instead of after 5 minutes.
-- ============================================================================

local portal = require("raid_portal")

local PIXTT = { 284079, 284103 }

local function spawn_pixtt()
    eq.unique_spawn(284079, 0, 0, -794, -1017, 35, 204) -- Pixtt_Votal
    eq.unique_spawn(284103, 0, 0, -685, -1019, 35, 331) -- Pixtt_Votal_
end

function event_spawn(e)
    eq.set_timer("popadds", 5 * 1000)
end

function event_combat(e)
    if e.joined then
        eq.set_timer("OOBcheck", 6 * 1000)
        for npc in eq.get_entity_list():GetNPCList().entries do
            local npc_id = npc.valid and npc:GetNPCTypeID()
            if npc_id == PIXTT[1] or npc_id == PIXTT[2] then
                npc:AddToHateList(e.self:GetHateRandom(), 1)
            end
        end
    else
        eq.stop_timer("OOBcheck")
    end
end

function event_timer(e)
    if e.timer == "OOBcheck" then
        if e.self:GetY() > -400 then
            e.self:GotoBind()
            e.self:WipeHateList()
        end
    elseif e.timer == "popadds" then
        eq.stop_timer(e.timer)
        spawn_pixtt()
    end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        portal.depop_all(PIXTT)
        eq.set_timer("popadds", 2 * 1000)
    end
end
