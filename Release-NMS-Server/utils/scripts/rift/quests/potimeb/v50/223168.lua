-- ============================================================================
-- RALLOS ZEK (PLANE OF TIME), RAID PORTAL VERSION
-- Deploy to: quests/potimeb/v50/223168.lua
-- In the open world he only appears after his army of twelve dies and the stand-in depops. Here he
-- spawns ready to fight with his own script kept: minions and boars at 90, 75, 50 and 25%, faster
-- attacks and AE rampage from 75%, flurry from 50%, a wider rampage at 25%. No zone status signals.
-- ============================================================================

local portal = require("raid_portal")

local MINION, BOAR = 223229, 223230

local function set_default_stats(e)
    e.self:SetSpecialAbility(SpecialAbility.area_rampage, 0)
    e.self:SetSpecialAbility(SpecialAbility.flurry, 0)
    e.self:ModifyNPCStat("attack_delay", "13")
    eq.set_next_hp_event(90)
end

-- Two minions and two boars on his target, and one more of either at 25%
local function spawn_adds(e, extra)
    local target = e.self:GetTarget()
    for _ = 1, 2 do
        portal.spawn_add(MINION, 262, -280, 5, 449, target)
        portal.spawn_add(BOAR, 262, -280, 5, 449, target)
    end
    if extra then
        portal.spawn_add(math.random(2) == 1 and MINION or BOAR, 262, -280, 5, 449, target)
    end
end

function event_spawn(e)
    set_default_stats(e)
end

function event_hp(e)
    e.self:Emote("roars a mighty war cry and swings his axe with a vengeance.")
    if e.hp_event == 90 then
        spawn_adds(e, false)
        eq.set_next_hp_event(75)
    elseif e.hp_event == 75 then
        spawn_adds(e, false)
        e.self:ModifyNPCStat("attack_delay", "11")
        e.self:SetSpecialAbility(SpecialAbility.area_rampage, 1)
        e.self:SetSpecialAbilityParam(SpecialAbility.area_rampage, 0, 10)
        eq.set_next_hp_event(50)
    elseif e.hp_event == 50 then
        spawn_adds(e, false)
        e.self:SetSpecialAbility(SpecialAbility.flurry, 1)
        e.self:SetSpecialAbilityParam(SpecialAbility.flurry, 0, 10)
        eq.set_next_hp_event(25)
    elseif e.hp_event == 25 then
        spawn_adds(e, true)
        e.self:SetSpecialAbilityParam(SpecialAbility.area_rampage, 0, 20)
        e.self:ModifyNPCStat("attack_delay", "9")
    end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        portal.depop_all({ MINION, BOAR })
        set_default_stats(e)
    end
end
