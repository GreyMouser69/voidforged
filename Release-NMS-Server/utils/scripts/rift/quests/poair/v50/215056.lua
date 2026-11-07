-- ============================================================================
-- XEGONY, RAID PORTAL VERSION
-- Deploy to: quests/poair/v50/215056.lua
-- Keeps her six waves: at 98, 82, 66, 50, 34 and 18% a lieutenant and five guards spawn around the
-- island and fly to her. The open world's #Xego_Controller only places untargetable stand-ins and
-- respawns her after a wipe; in the portal the raid controller does the reset, so she no longer
-- depops herself. No essence, flag or Muzlakh spawn change.
-- ============================================================================

local portal = require("raid_portal")

-- hp event = { next event, lieutenant, guard, guard spots, lieutenant spot }
local WAVES = {
    [98] = { 82, 215472, 215465, { { -401, -327, 1440.25 }, { -433, -306, 1440.25 }, { -487, -270, 1445.38 } }, { -460.7, -355.6, 1437.1, 42.4 }, 49 },
    [82] = { 66, 215434, 215466, { { -480, 240, 1445.38 }, { -582, 207, 1460.5 }, { -550, 217, 1457.5 } }, { -551.8, 258.6, 1455, 231 }, 231 },
    [66] = { 50, 215440, 215464, { { -257, -294, 1440.25 }, { -223, -251, 1440.25 }, { -195, -213, 1440.25 } }, { -173, -290.7, 1437.1, 431 }, 437 },
    [50] = { 34, 215445, 215479, { { -296, 323, 1440.25 }, { -351, 326, 1443.25 }, { -407, 329, 1447.13 } }, { -352.8, 372.7, 1440.35, 261 }, 261 },
    [34] = { 18, 215437, 215463, { { 14, -280, 1437.13 }, { -3, -231, 1437.13 }, { -2, -187, 1437.13 } }, { 39, -232.5, 1437.13, 386 }, 386 },
    [18] = { nil, 215444, 215462, { { -1, 371, 1442.13 }, { -5, 427, 1440.20 }, { -12, 481, 1440.25 } }, { 40.5, 432.9, 1437.13, 374 }, 374 },
}

local ADDS = { 215472, 215465, 215434, 215466, 215440, 215464, 215445, 215479, 215437, 215463, 215444, 215462 }
local IS_ADD = {}
for _, npc_id in ipairs(ADDS) do IS_ADD[npc_id] = true end

local function help_xegony(e)
    for npc in eq.get_entity_list():GetNPCList().entries do
        if npc.valid and IS_ADD[npc:GetNPCTypeID()] and not npc:IsEngaged() then
            npc:SetRunning(true)
            npc:MoveTo(e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0, false)
        end
    end
end

function event_spawn(e)
    eq.set_next_hp_event(98)
end

function event_hp(e)
    local wave = WAVES[e.hp_event]
    if not wave then return end

    -- Five guards: the open world doubles up the second and third spots
    local spots, guard_h = wave[4], wave[6]
    for _, i in ipairs({ 1, 2, 3, 2, 3 }) do
        eq.spawn2(wave[3], 0, 0, spots[i][1], spots[i][2], spots[i][3], guard_h)
    end
    local l = wave[5]
    eq.spawn2(wave[2], 0, 0, l[1], l[2], l[3], l[4])

    eq.set_timer("help", 1000)
    if wave[1] then eq.set_next_hp_event(wave[1]) end
end

function event_timer(e)
    if e.timer == "help" then
        eq.stop_timer("help")
        help_xegony(e)
    end
end

function event_signal(e)
    if e.signal == portal.RESET_SIGNAL then
        portal.depop_all(ADDS)
        eq.set_next_hp_event(98)
    end
end
