-- ============================================================================
-- RALLOS ZEK THE WARLORD, RAID PORTAL VERSION
-- Deploy to: quests/potactics/v50/#Rallos_Zek_the_Warlord.lua
-- Keeps his corpse adds and Cazic Touch outside the arena. The pit spawn handling, trigger signal
-- and flags belong to the open-world fight, which has its own script.
-- ============================================================================

function event_combat(e)
    if e.joined then
        eq.set_timer("Adds", 60 * 1000) -- 60 Seconds
        eq.set_timer("Out of Arena", 5 * 1000) -- 5 Seconds
    else
        e.self:SaveGuardSpot(e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- Doesn't move
    end
end

function event_death_complete(e)
    eq.stop_timer("Adds")
end

function event_timer(e)
    if e.timer == "Adds" then
        if e.self:IsEngaged() then
            local npc_ids = { 214114, 214136 }
            eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 519, 216, -293, 132)
            eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 647, 346, -293, 132)
            eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 853, 220, -293, 132)
            eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 779, -30, -293, 132)
            eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 507, -164, -293, 132)
            eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 847, -327, -293, 132)
            eq.spawn2(npc_ids[math.random(#npc_ids)], 0, 0, 518, -357, -293, 132)
            e.self:Emote("The corpses across the grounds of the arena begin to twitch and spasm as the will of the Warlord brings them to life.")
        else
            eq.stop_timer("Adds")
        end
    elseif e.timer == "Out of Arena" then
        if e.self:GetHateListCount() > 0 then
            local hate_entries = e.self:GetHateList().entries
            for hate_entry in hate_entries do
                if hate_entry.ent:IsClient() and hate_entry.ent:GetX() > 950 then
                    e.self:CastSpell(982, hate_entry.ent:GetID()) -- Spell: Cazic Touch
                end
            end
        end
    end
end
