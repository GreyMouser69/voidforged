-- ============================================================================
-- MIRROR IMAGE OF NOQUFIEL, RAID PORTAL VERSION
-- Deploy to: quests/inktuta/v50/296066.lua   (296065.lua, the True Image, is the portal boss)
-- Until revealed it is the True's double: the global scaling sets it as an add, so it copies the
-- True's HP and damage. At 5% it reveals, roots, hits softer, stops summoning, and explodes if it
-- is damaged after 2 seconds. Every 10% it calls the respawn of the pair, as in the open world.
-- ============================================================================

local portal = require("raid_portal")

local TRUE, MIRROR = 296065, 296066
local CURSEBEARERS = { 296059, 296060, 296061, 296062, 296063, 296064 }
local GHOST = { race = 385, gender = 0, texture = 4, helmtexture = 255, beard = 255, face = 0 }
local REVEALED = { race = 385, gender = 0, texture = 0, helmtexture = 47, beard = 255, face = 255 }

local PHASES = {
    { 95, 100 }, { 90, 100 }, { 85, 100 }, { 80, 90 }, { 75, 90 }, { 70, 80 }, { 65, 80 },
    { 60, 70 }, { 55, 70 }, { 50, 60 }, { 45, 60 }, { 40, 50 }, { 35, 50 }, { 30, 40 },
    { 25, 40 }, { 20, 30 }, { 15, 30 }, { 10, 20 }, { 5, 20 }, { 0, 10 },
}

local function get_var(name, default)
    return tonumber(eq.get_zone():GetVariable(name)) or default
end

local function spawn_pair()
    eq.depop_all(MIRROR)
    eq.depop_all(TRUE)
    local first, second = TRUE, MIRROR
    if math.random(2) == 1 then first, second = MIRROR, TRUE end
    eq.spawn2(first, 0, 0, 20, -706, -126, 384)
    eq.spawn2(second, 0, 0, 20, -633, -126, 384)
end

function event_spawn(e)
    e.self:TempName("Noqufiel")
    e.self:SendIllusionPacket(GHOST)
    eq.set_timer("raid_init", 500)
end

function event_timer(e)
    if e.timer == "raid_init" then
        eq.stop_timer(e.timer)
        local true_image = eq.get_entity_list():GetNPCByNPCTypeID(TRUE)
        if true_image.valid then
            e.self:ModifyNPCStat("max_hp", tostring(true_image:GetMaxHP()))
            e.self:ModifyNPCStat("min_hit", tostring(true_image:GetMinDMG()))
            e.self:ModifyNPCStat("max_hit", tostring(true_image:GetMaxDMG()))
        end
        e.self:SetHP(e.self:GetMaxHP() * get_var("noq_ratio", 100) / 100)
        eq.set_next_hp_event(PHASES[get_var("noq_phase", 1)][1])
    elseif e.timer == "leash" then
        if e.self:GetY() < -800 then
            e.self:GotoBind()
            e.self:WipeHateList()
        end
    elseif e.timer == "cursebearers" then
        if math.random(100) > 75 then
            local client = eq.get_entity_list():GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 500 * 500)
            portal.spawn_add(CURSEBEARERS[math.random(#CURSEBEARERS)], -238, -657, -126, 242, client)
        end
        eq.set_timer("cursebearers", (30 + math.random(15)) * 1000)
    elseif e.timer == "set_hp" then
        eq.stop_timer(e.timer)
        e.self:SetEntityVariable("shake_hp", tostring(e.self:GetHP()))
        eq.set_timer("check_hp", 500)
    elseif e.timer == "check_hp" then
        if e.self:GetHP() < (tonumber(e.self:GetEntityVariable("shake_hp")) or 0) - 100 then
            eq.stop_timer(e.timer)
            e.self:CastSpell(2490, e.self:GetHateRandom():GetID()) -- Detonation
            e.self:Emote("shudders and explodes!")
            eq.depop()
        end
    end
end

function event_combat(e)
    if e.joined then
        eq.set_timer("leash", 1000)
        eq.set_timer("cursebearers", (30 + math.random(15)) * 1000)
    else
        eq.stop_timer("leash")
        eq.stop_timer("cursebearers")
    end
end

function event_hp(e)
    if e.hp_event > 0 and e.hp_event % 10 == 5 then
        e.self:TempName("Mirror Image of Noqufiel")
        e.self:SendIllusionPacket(REVEALED)
        e.self:SetPseudoRoot(true)
        -- open world 220-600 against a 496-1788 base
        portal.set_damage(e.self, 220 / 496, 600 / 1788)
        e.self:SetSpecialAbility(SpecialAbility.summon, 0)
        e.self:RemoveAISpell(905) -- Avatar Knockback
        eq.set_timer("set_hp", 2000)
    elseif e.hp_event > 0 and e.hp_event % 10 == 0 then
        spawn_pair()
    end
end
