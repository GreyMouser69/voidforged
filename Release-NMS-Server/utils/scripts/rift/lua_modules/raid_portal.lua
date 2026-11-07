-- ============================================================================
-- RAID PORTAL MODULE (raid_portal.lua)
-- Deploy to: lua_modules/raid_portal.lua
--
-- Shared by the portal NPC, the instance controller and the boss scripts in quests/<zone>/v50/.
-- Stat scaling and the Prism payout run in plugins/raid_portal.pl, called from global_npc.pl,
-- because that hook fires for every NPC. See docs/raids/RAID_PORTAL.md.
-- ============================================================================

local portal = {}

portal.INSTANCE_VERSION = 50
portal.INSTANCE_SECONDS = 7200
portal.MIN_RAID         = 6
portal.MAX_RAID         = 72

portal.NPC = {
    CONTROLLER = 1200070,
    KEEPER     = 1200071,
    ADD        = 1200020, -- Rift_Anachronism; in a raid instance it stays a plain add
}

portal.SHARED = {
    pulse_ms        = 8000,
    hate_wipe_every = 3,
    energy_wave     = 3473, -- Catastrophe: magic PBAoE, 850 damage before spellscale
    leash           = 400,  -- how far a boss may be pulled from its spawn point
    leash_z         = 80,
}

-- spellscale is a starting value until each boss has been tuned in game
portal.BOSSES = {
    vox = {
        name = "Lady Vox", tier = 1, npc_id = 73057, zone = "permafrost", zone_id = 73, spellscale = 200,
        spawn = { -262, 857, 22, 407 }, entry = { -380.88, 822, 13.13, 128 },
    },
    saryrn = {
        name = "Saryrn", tier = 4, npc_id = 207001, zone = "potorment", zone_id = 207, spellscale = 200,
        spawn = { 3.15, 10.89, 579.13, 255.5 }, entry = { 0, -72, 579, 0 },
    },
    warlord = {
        name = "Rallos Zek the Warlord", tier = 4, npc_id = 214113, zone = "potactics", zone_id = 214, spellscale = 200,
        spawn = { 702, 0, -294.9, 0 }, entry = { 519, 216, -293, 128 },
    },
    -- Shared mechanics only: quests/<zone>/v50/<npc id>.lua calls portal.boss_*
    nagafen = {
        name = "Lord Nagafen", tier = 1, npc_id = 32040, zone = "soldungb", zone_id = 32, spellscale = 200,
        spawn = { -871, -1395, 104.9, 45 }, entry = { -856, -1187, 86.1, 261.6 },
    },
    trakanon = {
        name = "Trakanon", tier = 1, npc_id = 89154, zone = "sebilis", zone_id = 89, spellscale = 200,
        spawn = { -679, -2133, -131.4, 0 }, entry = { -538, -2055, -139.5, 342.5 },
    },
    innoruuk = {
        name = "Innoruuk", tier = 1, npc_id = 2000552, zone = "hateplane", zone_id = 76, spellscale = 200,
        spawn = { 5.6, 234.8, 148.9, 127.5 }, entry = { 120.5, 336.7, 148.9, 324.6 },
    },
    pharadar = {
        name = "Phara Dar", tier = 1, npc_id = 108510, zone = "veeshan", zone_id = 108, spellscale = 200,
        spawn = { -1313.5, -1155.2, 299.9, 82.8 }, entry = { -1195.5, -1011, 283, 311.6 },
    },
    xygoz = {
        name = "Xygoz", tier = 1, npc_id = 108053, zone = "veeshan", zone_id = 108, spellscale = 200,
        spawn = { 1208.9, 1336.4, 779.6, 210.8 }, entry = { 1375.9, 1268.5, 772.1, 415.1 },
    },
    nexona = {
        name = "Nexona", tier = 1, npc_id = 108047, zone = "veeshan", zone_id = 108, spellscale = 200,
        spawn = { -560.8, 1170.6, 689.4, 481.5 }, entry = { -605.1, 1323.2, 682.8, 232.7 },
    },
    silverwing = {
        name = "Silverwing", tier = 1, npc_id = 108509, zone = "veeshan", zone_id = 108, spellscale = 200,
        spawn = { -257.2, 319.3, 465.5, 384.8 }, entry = { -397, 439, 456.2, 185.5 },
    },
    yelinak = {
        name = "Lord Yelinak", tier = 2, npc_id = 114106, zone = "skyshrine", zone_id = 114, spellscale = 200,
        spawn = { 1977, 2645, -146.1, 0 }, entry = { 1836, 2664, -153.6, 138.8 },
    },
    koidoken = {
        name = "Lord Koi`Doken", tier = 2, npc_id = 124103, zone = "templeveeshan", zone_id = 124, spellscale = 200,
        spawn = { -124, 738, 70, 73 }, entry = { -139, 945, 117.4, 249.9 },
    },
    dozekar = {
        name = "Dozekar the Cursed", tier = 2, npc_id = 124037, zone = "templeveeshan", zone_id = 124, spellscale = 200,
        spawn = { -1281, -1080, -15.5, 130 }, entry = { -1279, -1240, 0, 510.5 },
    },
    velketor = {
        name = "Velketor the Sorcerer", tier = 2, npc_id = 112025, zone = "velketor", zone_id = 112, spellscale = 200,
        spawn = { 135, 178, -53.4, 259 }, entry = { 40, 317, -68.3, 206.9 },
    },
    arbiter = {
        name = "The Final Arbiter", tier = 2, npc_id = 128045, zone = "sleeper", zone_id = 128, spellscale = 200,
        spawn = { -754, -2384, -960.6, 129 }, entry = { -1063.6, -2486.6, -980.4, 101.8 },
    },
    sontalak = {
        name = "Sontalak", tier = 2, npc_id = 120005, zone = "westwastes", zone_id = 120, spellscale = 200,
        spawn = { 701, 786, -186.8, 261 }, entry = { 808, 1323, -196, 271.8 },
    },
    vulak = {
        name = "Vulak`Aerr", tier = 2, npc_id = 124155, zone = "templeveeshan", zone_id = 124, spellscale = 200,
        spawn = { -739.4, 517.2, 121, 510 }, entry = { -782, 208, 98.6, 11.1 },
    },
    seru = {
        name = "Lord Inquisitor Seru", tier = 3, npc_id = 159691, zone = "sseru", zone_id = 159, spellscale = 200,
        spawn = { -231.5, -432.9, 202.4, 0.2 }, entry = { -373, -576, 193.1, 63.5 },
    },
    overfiend = {
        name = "Thought Horror Overfiend", tier = 3, npc_id = 164078, zone = "thedeep", zone_id = 164, spellscale = 200,
        spawn = { 2337, -1047, -61.4, 86 }, entry = { 2508, -1029, -51.1, 375.1 },
    },
    highpriest = {
        name = "High Priest of Ssraeshza", tier = 3, npc_id = 162076, zone = "ssratemple", zone_id = 162, spellscale = 200,
        spawn = { 77, 393, 262.9, 256 }, entry = { 92, 213, 252.5, 504.7 },
    },
    xerkizh = {
        name = "Xerkizh the Creator", tier = 3, npc_id = 162190, zone = "ssratemple", zone_id = 162, spellscale = 200,
        spawn = { 256, 252, 264.5, 256 }, entry = { 422, 183, 258.7, 415.7 },
    },
    kaasthox = {
        name = "Kaas Thox Xi Aten Ha Ra", tier = 3, npc_id = 158007, zone = "vexthal", zone_id = 158, spellscale = 200,
        spawn = { 141, 318, 130.6, 256 }, entry = { 126, 152, 130.6, 7.3 },
    },
    aten = {
        name = "Aten Ha Ra", tier = 3, npc_id = 158096, zone = "vexthal", zone_id = 158, spellscale = 200,
        spawn = { 1417, 0, 236, 384 }, entry = { 1153.3, -0.4, 235.3, 127.8 },
    },
    fennin = {
        name = "Fennin Ro", tier = 4, npc_id = 217054, zone = "pofire", zone_id = 217, spellscale = 200,
        spawn = { -1578.1, -904.1, -185.8, 265.6 }, entry = { -1410, -974, -185.8, 415.7 },
    },
    mithaniel = {
        name = "Mithaniel Marr", tier = 4, npc_id = 220006, zone = "hohonorb", zone_id = 220, spellscale = 200,
        spawn = { 2727, 0, 471, 387 }, entry = { 2565, 32, 480.5, 143.8 },
    },
    bertox = {
        name = "Bertoxxulous", tier = 4, npc_id = 200055, zone = "codecay", zone_id = 200, spellscale = 200,
        spawn = { -2, 283, -247, 0 }, entry = { -161.2, 199.7, -260.9, 88.6 },
    },
    -- Bosses with their own mechanics, ported to quests/<zone>/v50/ (2026-11-08, untested in game)
    tunare = {
        name = "Tunare", tier = 2, npc_id = 127098, zone = "growthplane", zone_id = 127, spellscale = 200,
        spawn = { -247, 1609, -40, 424 }, entry = { -368.9, 1664.9, -15.6, 160 },
    },
    tormax = {
        name = "King Tormax", tier = 2, npc_id = 113215, zone = "kael", zone_id = 113, spellscale = 200,
        spawn = { 1700, -1521, -180.4, 8 }, entry = { 1763, -1025, -204.3, 256 },
    },
    bristlebane = {
        name = "Bristlebane", tier = 2, npc_id = 126160, zone = "mischiefplane", zone_id = 126, spellscale = 200,
        spawn = { 164.5, 552.4, 146.2, 255.3 }, entry = { -26, 394, 168.1, 96 },
    },
    emperor = {
        name = "Emperor Ssraeshza", tier = 3, npc_id = 162227, zone = "ssratemple", zone_id = 162, spellscale = 200,
        spawn = { 997, -325, 415, 384 }, entry = { 820.3, -325, 400, 128 },
    },
    xegony = {
        name = "Xegony", tier = 4, npc_id = 215056, zone = "poair", zone_id = 215, spellscale = 200,
        spawn = { 64, 24.7, 1467.3, 386.8 }, entry = { -214.4, 64.3, 1442.8, 128 },
    },
    solusek = {
        name = "Solusek Ro", tier = 4, npc_id = 212025, zone = "solrotower", zone_id = 212, spellscale = 200,
        spawn = { 0, -1591, 269.5, 0 }, entry = { 38, -1391, 252.5, 256 },
    },
    agnarr = {
        name = "Agnarr the Storm Lord", tier = 4, npc_id = 209026, zone = "bothunder", zone_id = 209, spellscale = 200,
        spawn = { -899, -1740, 2263.6, 126 }, entry = { -901.5, -1542.7, 2252.4, 256 },
    },
    muzlakh = {
        name = "Muzlakh the Chosen", tier = 4, npc_id = 215053, zone = "poair", zone_id = 215, spellscale = 200,
        spawn = { -602.2, 15.2, 1447.7, 385.5 }, entry = { -520.1, 227.7, 1449.2, 256 },
    },
    quarm = {
        name = "Quarm", tier = 5, npc_id = 223201, zone = "potimeb", zone_id = 223, spellscale = 200,
        spawn = { -401, -1106, 32.5, 185.6 }, entry = { 244, -1106, -1.1, 194 },
    },
    rallos = {
        name = "Rallos Zek", tier = 5, npc_id = 223168, zone = "potimeb", zone_id = 223, spellscale = 200,
        spawn = { 264, -279, 18.75, 435 }, entry = { 82.6, -153, 3.3, 160 },
    },
    terris = {
        name = "Terris Thule", tier = 5, npc_id = 223075, zone = "potimeb", zone_id = 223, spellscale = 200,
        spawn = { -310, 307, 365, 190 }, entry = { -395, 0, 350, 0 },
    },
    vallon = {
        name = "Vallon Zek", tier = 5, npc_id = 223078, zone = "potimeb", zone_id = 223, spellscale = 200,
        spawn = { 405, 75, 358, 384 }, entry = { 405, -84, 358, 0 },
    },
    innoruukpot = {
        name = "Innoruuk (Plane of Time)", tier = 5, npc_id = 223167, zone = "potimeb", zone_id = 223, spellscale = 200,
        spawn = { 303.3, 306, 13.3, 323 }, entry = { 165.6, 103.5, 3.3, 64 },
    },
    noqufiel = {
        name = "Noqufiel", tier = 5, npc_id = 296065, zone = "inktuta", zone_id = 296, spellscale = 200,
        spawn = { 20, -706, -126, 384 }, entry = { -65, -587, -127.1, 192 },
    },
    tunat = {
        name = "Tunat`Muram Cuu Vauax", tier = 5, npc_id = 298055, zone = "tacvi", zone_id = 298, spellscale = 200,
        spawn = { 309, -170.8, 21.3, 118.8 }, entry = { 462, -171, 32, 384 },
    },
    matriarch = {
        name = "Ancient Cragbeast Matriarch", tier = 5, npc_id = 297056, zone = "txevu", zone_id = 297, spellscale = 200,
        spawn = { 627, 0, -364.8, 118 }, entry = { 724, -232, -371.6, 448 },
    },
    votal = {
        name = "Zun`Muram Votal", tier = 5, npc_id = 284080, zone = "ferubi", zone_id = 284, spellscale = 200,
        spawn = { -735.4, -1075.4, 39.5, 0 }, entry = { -883.4, -948.6, 37.6, 160 },
    },
}

-- The controller signals the boss with this after a wipe reset, so a boss with phases can put them back
portal.RESET_SIGNAL = 50

function portal.bosses_in_tier(tier)
    local out = {}
    for _, boss in pairs(portal.BOSSES) do
        if boss.tier == tier then table.insert(out, boss) end
    end
    return out
end

-- Data bucket keys. raid_instance and raid_paid are also read by plugins/raid_portal.pl
function portal.key_instance(instance_id) return "raid_instance_" .. instance_id end
function portal.key_paid(instance_id)     return "raid_paid_" .. instance_id end
function portal.key_active(char_id)       return "raid_active_" .. char_id end

-- "tier,size,boss npc id,spellscale", written by the portal when the instance is created
function portal.get_instance(instance_id)
    local raw = eq.get_data(portal.key_instance(instance_id))
    local tier, size, boss_id = raw:match("^(%d+),(%d+),(%d+),%d+$")
    if not tier then return nil end
    return { tier = tonumber(tier), size = tonumber(size), boss_id = tonumber(boss_id) }
end

function portal.boss_by_npc_id(npc_id)
    for _, boss in pairs(portal.BOSSES) do
        if boss.npc_id == npc_id then return boss end
    end
    return nil
end

-- ----------------------------------------------------------------------------
-- Shared mechanics, the Rift Guardian's: 1 = AoE pulses, 2 = adds at 50%, 3 = hate wipes
-- ----------------------------------------------------------------------------
function portal.shared_spawn(npc)
    npc:SetEntityVariable("raid_mechanic", tostring(math.random(1, 3)))
    npc:SetEntityVariable("raid_pulses", "0")
    eq.set_timer("raid_pulse", portal.SHARED.pulse_ms)
end

function portal.shared_timer(npc, timer)
    if timer ~= "raid_pulse" or not npc:IsEngaged() then return end

    local mechanic = tonumber(npc:GetEntityVariable("raid_mechanic")) or 1
    local pulses = (tonumber(npc:GetEntityVariable("raid_pulses")) or 0) + 1
    npc:SetEntityVariable("raid_pulses", tostring(pulses))

    if mechanic == 1 then
        npc:Emote(" unleashes a devastating wave of energy!")
        npc:SpellFinished(portal.SHARED.energy_wave, npc)
    elseif mechanic == 2 then
        if npc:GetHPRatio() < 50 and not npc:EntityVariableExists("raid_adds") then
            npc:SetEntityVariable("raid_adds", "1")
            npc:Emote(" summons guardians to its aid!")
            eq.spawn2(portal.NPC.ADD, 0, 0, npc:GetX() + 10, npc:GetY(), npc:GetZ(), 0)
            eq.spawn2(portal.NPC.ADD, 0, 0, npc:GetX() - 10, npc:GetY(), npc:GetZ(), 0)
        end
    elseif pulses % portal.SHARED.hate_wipe_every == 0 then
        npc:Emote(" phases out of time and forgets its attackers!")
        npc:WipeHateList()
    end
end

-- A boss with no script of its own: the shared mechanics, plus a leash back to its spawn point
-- ----------------------------------------------------------------------------
function portal.boss_spawn(e)
    portal.shared_spawn(e.self)
end

function portal.boss_combat(e)
    if e.joined then
        eq.set_timer("raid_leash", 2000)
    else
        eq.stop_timer("raid_leash")
    end
end

function portal.boss_timer(e)
    if e.timer ~= "raid_leash" then
        portal.shared_timer(e.self, e.timer)
        return
    end

    local boss = portal.boss_by_npc_id(e.self:GetNPCTypeID())
    if not boss then return end

    local s = boss.spawn
    local dx, dy, dz = e.self:GetX() - s[1], e.self:GetY() - s[2], e.self:GetZ() - s[3]
    if dx * dx + dy * dy > portal.SHARED.leash ^ 2 or math.abs(dz) > portal.SHARED.leash_z then
        e.self:BuffFadeAll()
        e.self:WipeHateList()
        e.self:Heal()
        e.self:GMMove(s[1], s[2], s[3], s[4])
        e.self:DeleteEntityVariable("raid_adds")
        eq.stop_timer("raid_leash")
    end
end

-- ----------------------------------------------------------------------------
-- Helpers for bosses with their own mechanics
-- ----------------------------------------------------------------------------

-- The portal sets a boss's stats after its own spawn event runs, so the raid values are read on first use
local RESISTS = { mr = "GetMR", fr = "GetFR", cr = "GetCR", pr = "GetPR", dr = "GetDR" }

local function raid_base(npc)
    if not npc:EntityVariableExists("raid_min") then
        npc:SetEntityVariable("raid_min", tostring(npc:GetMinDMG()))
        npc:SetEntityVariable("raid_max", tostring(npc:GetMaxDMG()))
        for stat, getter in pairs(RESISTS) do
            npc:SetEntityVariable("raid_" .. stat, tostring(npc[getter](npc)))
        end
    end
    return tonumber(npc:GetEntityVariable("raid_min")), tonumber(npc:GetEntityVariable("raid_max"))
end

-- Open-world scripts set phase damage as fixed numbers. In the portal the same change is kept as a
-- ratio of the boss's own base damage, applied to its raid damage: set_damage(npc, 1262 / 2250, 4500 / 7000)
function portal.set_damage(npc, min_ratio, max_ratio)
    local base_min, base_max = raid_base(npc)
    npc:ModifyNPCStat("min_hit", tostring(math.floor(base_min * min_ratio)))
    npc:ModifyNPCStat("max_hit", tostring(math.floor(base_max * max_ratio)))
end

-- All five resists moved by the same amount from the boss's raid value (0 puts them back)
function portal.set_resists(npc, delta)
    raid_base(npc)
    for stat in pairs(RESISTS) do
        npc:ModifyNPCStat(stat, tostring(tonumber(npc:GetEntityVariable("raid_" .. stat)) + delta))
    end
end

-- Spawns an add and points it at the target, when there is one
function portal.spawn_add(npc_id, x, y, z, h, target)
    local add = eq.spawn2(npc_id, 0, 0, x, y, z, h)
    if add.valid and target and target.valid then
        add:AddToHateList(target, 1)
    end
    return add
end

function portal.depop_all(npc_ids)
    for _, npc_id in ipairs(npc_ids) do
        eq.depop_all(npc_id)
    end
end

return portal
