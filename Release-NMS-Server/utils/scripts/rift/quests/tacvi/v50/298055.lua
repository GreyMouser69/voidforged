-- ============================================================================
-- TUNAT`MURAM CUU VAUAX, RAID PORTAL VERSION
-- Deploy to: quests/tacvi/v50/298055.lua
-- The second form from encounters/tmcv.lua: every 10% from 90 to 20 he turns into one of the
-- temple's bosses, with its adds, spells, rampage and rages. The first form with the phylacteries
-- is skipped, and so are the doors and zone status. Damage is set as a ratio of his 2250-7000 base.
-- A wipe reset respawns him fresh rather than unwinding nine phases.
-- ============================================================================

local portal = require("raid_portal")

local SELF = 298055
local SPAWN = { 309, -170.8, 21.3, 118.8 }
local ADDS = { 298041, 298042, 298043, 298044, 298013, 298045, 298050 }
local SPOTS = { { 334, -117, 21, 280 }, { 356, -154, 21, 356 }, { 353, -201, 21, 434 }, { 322, -215, 21, 496 }, { 322, -225, 21, 496 } }

-- Open-world damage numbers, kept as a ratio of the 2250-7000 base
local function damage(e, min_hit, max_hit)
    portal.set_damage(e.self, min_hit / 2250, max_hit / 7000)
end

local function stop(names)
    for _, name in ipairs(names) do eq.stop_timer(name) end
end

local function shift(e, race, name)
    e.self:Emote("shimmers and changes before your eyes.")
    e.self:SendIllusionPacket({ race = race, gender = 2, texture = 11 })
    e.self:TempName(name)
end

local function spawn_at_spots(npc_id, count)
    local target = eq.get_entity_list():GetNPCByNPCTypeID(SELF)
    target = target.valid and target:GetHateTop() or nil
    for i = 1, count do
        local spot = SPOTS[i]
        portal.spawn_add(npc_id, spot[1], spot[2], spot[3], spot[4], target)
    end
end

local function zmkp_power_up(e)
    local cycles = (tonumber(e.self:GetEntityVariable("zmkp_cycles")) or 0) + 1
    e.self:SetEntityVariable("zmkp_cycles", tostring(cycles))
    damage(e, 1424 + 188 * cycles, 3900 + 700 * cycles)
end

function event_spawn(e)
    eq.set_next_hp_event(90)
end

function event_combat(e)
    if e.joined then
        eq.set_timer("Spell_Tunat_Haste", 60 * 1000)
    end
end

function event_hp(e)
    if e.hp_event == 90 then
        -- Pixtt Xxeric Kex: flurry and four ukun
        eq.stop_timer("Spell_Tunat_Haste")
        shift(e, 393, "Pixtt Xxeric Kex")
        e.self:SetSpecialAbility(SpecialAbility.flurry, 1)
        damage(e, 1262, 4500)
        for i, npc_id in ipairs({ 298044, 298043, 298042, 298041 }) do
            local spot = SPOTS[i]
            portal.spawn_add(npc_id, spot[1], spot[2], spot[3], spot[4], e.self:GetHateTop())
        end
        eq.set_timer("Spell_PXK_SC", 2 * 1000)
        eq.set_timer("Spell_PXK_WOR", 60 * 1000)
        eq.set_next_hp_event(80)
    elseif e.hp_event == 80 then
        -- Pixtt Kretv Kakxt: mitigated AE rampage, hatchlings every 30s
        stop({ "Spell_PXK_SC", "Spell_PXK_WOR" })
        shift(e, 394, "Pixtt Kretv Kakxt")
        e.self:SetSpecialAbility(SpecialAbility.flurry, 0)
        e.self:SetSpecialAbility(SpecialAbility.area_rampage, 1)
        e.self:SetSpecialAbilityParam(SpecialAbility.area_rampage, 2, 25)
        damage(e, 1262, 4432)
        eq.set_timer("pkk_adds", 30 * 1000)
        eq.set_timer("Spell_PKK_DV", 2 * 1000)
        eq.set_timer("Spell_PKK_SC", 5 * 1000)
        eq.set_timer("Spell_PKK_WOTI", 30 * 1000)
        eq.set_next_hp_event(70)
    elseif e.hp_event == 70 then
        -- Pixtt Riel Tavas: unstable constructs every 30s
        stop({ "Spell_PKK_DV", "Spell_PKK_SC", "Spell_PKK_WOTI", "pkk_adds" })
        shift(e, 394, "Pixtt Riel Tavas")
        e.self:SetSpecialAbility(SpecialAbility.area_rampage, 0)
        damage(e, 1552, 4600)
        eq.set_timer("prt_adds", 30 * 1000)
        eq.set_timer("Spell_PRT_DV", 2 * 1000)
        eq.set_timer("Spell_PRT_WOTI", math.random(30, 60) * 1000)
        eq.set_next_hp_event(60)
    elseif e.hp_event == 60 then
        -- Zun`Muram Kvxe Pirik: powers up every 35s
        stop({ "Spell_PRT_DV", "Spell_PRT_WOTI", "prt_adds" })
        shift(e, 400, "Zun`Muram Kvxe Pirik")
        e.self:ModifyNPCStat("attack_delay", "9")
        e.self:SetEntityVariable("zmkp_cycles", "0")
        damage(e, 1424, 3900)
        eq.set_timer("zmkp_powerup_first", 35 * 1000)
        eq.set_next_hp_event(50)
    elseif e.hp_event == 50 then
        -- Zun`Muram Yihst Vor: flurry, mitigated AE rampage, Allure of Hatred and a hate wipe
        stop({ "zmkp_powerup_first", "zmkp_powerup_repeat" })
        shift(e, 400, "Zun`Muram Yihst Vor")
        e.self:ModifyNPCStat("attack_delay", "15")
        damage(e, 1643, 4500)
        e.self:SetSpecialAbility(SpecialAbility.rampage, 0)
        e.self:SetSpecialAbility(SpecialAbility.flurry, 1)
        e.self:SetSpecialAbility(SpecialAbility.area_rampage, 1)
        e.self:SetSpecialAbilityParam(SpecialAbility.area_rampage, 2, 25)
        eq.set_timer("Spell_ZMYV_AOH", 60 * 1000)
        eq.set_next_hp_event(40)
    elseif e.hp_event == 40 then
        -- Zun`Muram Mordl Delt: rampage, two copies after 20s
        eq.stop_timer("Spell_ZMYV_AOH")
        shift(e, 400, "Zun`Muram Mordl Delt")
        e.self:SetSpecialAbility(SpecialAbility.area_rampage, 0)
        e.self:SetSpecialAbility(SpecialAbility.rampage, 1)
        e.self:SetSpecialAbilityParam(SpecialAbility.rampage, 2, 25)
        damage(e, 1343, 4200)
        eq.set_timer("ZMMD_Adds", 20 * 1000)
        eq.set_next_hp_event(30)
    elseif e.hp_event == 30 then
        -- Zun`Muram Shaldn Boc: rages every 30s
        shift(e, 400, "Zun`Muram Shaldn Boc")
        e.self:SetSpecialAbility(SpecialAbility.flurry, 0)
        damage(e, 1462, 4700)
        eq.set_timer("zmsb_rage", 30 * 1000)
        eq.set_next_hp_event(20)
    elseif e.hp_event == 20 then
        -- Tunat again: rampage, flurry, rages and his final spells
        stop({ "zmsb_rage", "zmsb_rage_over" })
        shift(e, 399, "Tunat`Muram Cuu Vauax")
        e.self:Say("You are stronger than I anticipated. While you have exhausted the fleeting spirit of my underlings, you have yet to face my true fury!")
        damage(e, 1450, 4300)
        e.self:SetSpecialAbility(SpecialAbility.rampage, 1)
        e.self:SetSpecialAbilityParam(SpecialAbility.rampage, 2, 25)
        e.self:SetSpecialAbility(SpecialAbility.flurry, 1)
        e.self:CastSpell(4740, e.self:GetID()) -- Haste of the Tunat`Muram
        eq.set_timer("tunat_rage", 30 * 1000)
        eq.set_timer("Spell_Tunat_Haste", 60 * 1000)
        eq.set_timer("Spells_Tunat_Final1", 20 * 1000)
        eq.set_timer("Spells_Tunat_Final2", 35 * 1000)
    end
end

function event_timer(e)
    local t = e.timer
    if t == "pkk_adds" then
        spawn_at_spots(298013, 4)
    elseif t == "prt_adds" then
        spawn_at_spots(298045, 5)
    elseif t == "zmkp_powerup_first" then
        eq.stop_timer(t)
        e.self:SetSpecialAbility(SpecialAbility.rampage, 1)
        e.self:SetSpecialAbilityParam(SpecialAbility.rampage, 2, 25)
        e.self:ModifyNPCStat("attack_delay", "28")
        zmkp_power_up(e)
        eq.set_timer("zmkp_powerup_repeat", 35 * 1000)
    elseif t == "zmkp_powerup_repeat" then
        eq.zone_emote(MT.Yellow, "Zun`Muram Kvxe Pirik focuses his will and grows stronger.")
        zmkp_power_up(e)
    elseif t == "ZMMD_Adds" then
        eq.stop_timer(t)
        spawn_at_spots(298050, 2)
    elseif t == "zmsb_rage" or t == "tunat_rage" then
        local who = t == "zmsb_rage" and "Zun`Muram Shaldn Boc" or "Tunat`Muram Cuu Vauax"
        eq.zone_emote(MT.Yellow, who .. " starts to foam at the mouth as he enters a blind rage.")
        eq.stop_timer(t)
        e.self:ModifyNPCStat("attack_delay", "9")
        if t == "zmsb_rage" then damage(e, 2010, 6200) else damage(e, 1990, 5800) end
        eq.set_timer(t .. "_over", 25 * 1000)
    elseif t == "zmsb_rage_over" or t == "tunat_rage_over" then
        local rage = t:gsub("_over$", "")
        local who = rage == "zmsb_rage" and "Zun`Muram Shaldn Boc" or "Tunat`Muram Cuu Vauax"
        eq.zone_emote(MT.Yellow, who .. " looks weakened as the rage ends.")
        eq.stop_timer(t)
        e.self:ModifyNPCStat("attack_delay", "15")
        if rage == "zmsb_rage" then damage(e, 1462, 4700) else damage(e, 1450, 4300) end
        eq.set_timer(rage, 30 * 1000)
    elseif t == "Spell_Tunat_Haste" then
        if e.self:GetHPRatio() > 90 or e.self:GetHPRatio() < 20 then
            e.self:CastSpell(4740, e.self:GetID()) -- Haste of the Tunat`Muram
        end
        eq.set_timer(t, 60 * 1000)
    elseif t == "Spell_PXK_SC" then
        e.self:CastedSpellFinished(4729, e.self:GetHateTop()) -- Spirit Cleaver
        eq.set_timer(t, math.random(45, 60) * 1000)
    elseif t == "Spell_PXK_WOR" then
        e.self:CastedSpellFinished(4728, e.self:GetHateTop()) -- Wave of Rage
    elseif t == "Spell_PKK_DV" or t == "Spell_PRT_DV" then
        e.self:CastedSpellFinished(889, e.self:GetHateTop()) -- Delusional Visions
        eq.set_timer(t, (t == "Spell_PKK_DV" and 30 or math.random(30, 60)) * 1000)
    elseif t == "Spell_PKK_SC" then
        e.self:CastedSpellFinished(852, e.self:GetHateTop()) -- Soul Consumption
        eq.set_timer(t, math.random(35, 45) * 1000)
    elseif t == "Spell_PKK_WOTI" or t == "Spell_PRT_WOTI" then
        e.self:CastedSpellFinished(888, e.self:GetHateTop()) -- Wrath of the Ikaav
        eq.set_timer(t, (t == "Spell_PKK_WOTI" and math.random(30, 60) or math.random(60, 180)) * 1000)
    elseif t == "Spell_ZMYV_AOH" then
        for _ = 1, 2 do
            local target = e.self:GetHateRandom()
            if target.valid and target:IsPet() then target = target:GetOwner() end
            if target.valid and not target:FindBuff(4441) then
                e.self:SpellFinished(4441, target) -- Allure of Hatred
            end
        end
        e.self:WipeHateList()
        eq.set_timer(t, 60 * 1000)
    elseif t == "Spells_Tunat_Final1" then
        e.self:CastedSpellFinished(eq.ChooseRandom(4727, 4729, 852), e.self:GetHateRandom())
    elseif t == "Spells_Tunat_Final2" then
        e.self:CastedSpellFinished(eq.ChooseRandom(751, 4739, 4728), e.self:GetHateRandom())
    end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        eq.stop_all_timers()
        portal.depop_all(ADDS)
        eq.spawn2(SELF, 0, 0, SPAWN[1], SPAWN[2], SPAWN[3], SPAWN[4])
        eq.depop()
    end
end

function event_death_complete(e)
    portal.depop_all(ADDS)
end
