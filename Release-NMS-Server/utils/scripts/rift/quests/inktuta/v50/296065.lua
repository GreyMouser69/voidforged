-- ============================================================================
-- TRUE IMAGE OF NOQUFIEL, RAID PORTAL VERSION
-- Deploy to: quests/inktuta/v50/296065.lua   (the portal boss; 296066.lua is the Mirror)
-- Keeps the open-world fight from encounters/noqufiel.lua: every 10% both images depop and respawn,
-- swapping spots at random, at the True's HP. At each 5% the True reveals itself and gains its
-- lifetap. Cursebearers come in now and then. Shared state is in zone variables, because the
-- images are respawned many times in one fight. No trigger NPC, doors or zone status.
--
-- The global spawn scaling runs after event_spawn, so HP is set from a short timer.
-- ============================================================================

local portal = require("raid_portal")

local TRUE, MIRROR = 296065, 296066
local CURSEBEARERS = { 296059, 296060, 296061, 296062, 296063, 296064 }
local GHOST = { race = 385, gender = 0, texture = 4, helmtexture = 255, beard = 255, face = 0 }
local REVEALED = { race = 385, gender = 0, texture = 0, helmtexture = 47, beard = 255, face = 255 }

-- phase = { next hp event, previous hp event }; the HP the pair respawns at is in noq_ratio
local PHASES = {
    { 95, 100 }, { 90, 100 }, { 85, 100 }, { 80, 90 }, { 75, 90 }, { 70, 80 }, { 65, 80 },
    { 60, 70 }, { 55, 70 }, { 50, 60 }, { 45, 60 }, { 40, 50 }, { 35, 50 }, { 30, 40 },
    { 25, 40 }, { 20, 30 }, { 15, 30 }, { 10, 20 }, { 5, 20 }, { 0, 10 },
}

local function get_var(name, default)
    return tonumber(eq.get_zone():GetVariable(name)) or default
end

local function set_var(name, value)
    eq.get_zone():SetVariable(name, tostring(value))
end

local function spawn_pair()
    eq.depop_all(MIRROR)
    eq.depop_all(TRUE)
    local first, second = TRUE, MIRROR
    if math.random(2) == 1 then first, second = MIRROR, TRUE end
    eq.spawn2(first, 0, 0, 20, -706, -126, 384)
    eq.spawn2(second, 0, 0, 20, -633, -126, 384)
end

local function reset_fight()
    set_var("noq_phase", 1)
    set_var("noq_ratio", 100)
    portal.depop_all(CURSEBEARERS)
    spawn_pair()
end

function event_spawn(e)
    e.self:TempName("Noqufiel")
    e.self:SendIllusionPacket(GHOST)
    eq.set_timer("raid_init", 500)
end

function event_timer(e)
    if e.timer == "raid_init" then
        eq.stop_timer(e.timer)
        local phase = PHASES[get_var("noq_phase", 1)]
        e.self:SetHP(e.self:GetMaxHP() * get_var("noq_ratio", 100) / 100)
        eq.set_next_hp_event(phase[1])
        eq.set_next_inc_hp_event(phase[2])
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
    local phase = get_var("noq_phase", 1)
    if e.hp_event > 0 and e.hp_event % 10 == 5 then
        -- Reveal at each 5%
        phase = math.min(phase + 1, #PHASES)
        set_var("noq_phase", phase)
        eq.set_next_hp_event(PHASES[phase][1])
        eq.set_next_inc_hp_event(PHASES[phase][2])
        e.self:TempName("True Image of Noqufiel")
        e.self:SendIllusionPacket(REVEALED)
        e.self:AddAISpell(0, 2376, 64, -1, 2, -150) -- Spectral Quintessence
    elseif e.hp_event > 0 and e.hp_event % 10 == 0 then
        -- Every 10% the pair respawns at this HP
        set_var("noq_ratio", PHASES[phase][1])
        set_var("noq_phase", math.min(phase + 1, #PHASES))
        spawn_pair()
    elseif e.inc_hp_event > 0 and e.inc_hp_event < 100 and e.inc_hp_event % 10 == 0 then
        -- Regenerated back past a 10% line
        set_var("noq_phase", math.max(phase - 1, 1))
        spawn_pair()
    end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        reset_fight()
    end
end

function event_death_complete(e)
    e.self:Say("This is but a temporary setback. I will return.")
    eq.depop_all(MIRROR)
    portal.depop_all(CURSEBEARERS)
    set_var("noq_phase", 1)
    set_var("noq_ratio", 100)
end
