-- Dynamic Items for Hailstone: the Voidforged server's #dyninfo in a window instead of popups.
--   /dyninfo (or the EQ menu's Plugins > Dynamic Items) shows or hides it. Opening it, and its Refresh button, ask the
--   server for "#dyninfo data" and "#dyninfo data worn", which answer in DYNDATA| lines (the server's
--   zone/gm_commands/dynamic_items.cpp lists them); this script reads them, hides them, and keeps the result for the
--   window (ui/modern/dynitems.lua, through eq.Plugin("dynitems"): state, data, command).
--
-- /dyninfo [show | refresh]
local mq = require('mq')
local hs = require('hailstone')

local TICK_MS = 50
local ANSWER_MS = 8000 -- a request not answered by then is given up

local open = false
local rev = 0          -- bumped when new data has come (the window reads it again)
local data = { items = {}, groups = {}, affix = {}, worn = nil, at = nil }
local loading = { items = false, worn = false, since = nil }
local pending_items, pending_worn

local function say(text) hs.chat('[Dynamic Items] ' .. text, 15) end

-- "a|b||c" -> { "a", "b", "", "c" } (the empty fields kept)
local function split(s, sep)
  local out, from = {}, 1
  while true do
    local at = s:find(sep, from, true)
    if not at then out[#out + 1] = s:sub(from) return out end
    out[#out + 1] = s:sub(from, at - 1)
    from = at + 1
  end
end

local function num(v) return tonumber(v) or 0 end

-- <affix>:<value>:<guaranteed>:<position>:<reforged>, comma separated
local function rolls(field)
  local out = {}
  if field == nil or field == "" then return out end
  for _, r in ipairs(split(field, ",")) do
    local p = split(r, ":")
    out[#out + 1] = { affix = num(p[1]), value = num(p[2]), guaranteed = p[3] == "1", position = num(p[4]),
      reforged = p[5] == "1" }
  end
  return out
end

local function request()
  loading.items, loading.worn, loading.since = true, true, mq.gettime()
  mq.cmd('/say #dyninfo data')
  mq.cmd('/say #dyninfo data worn')
end

-- One DYNDATA| line. Returns true (the line is hidden).
local function line(text)
  local f = split(text, "|")
  local kind = f[2]
  if kind == "items" then
    if f[3] == "begin" then
      pending_items = { items = {}, groups = {}, affix = {} }
    elseif f[3] == "end" and pending_items then
      data.items, data.groups, data.affix = pending_items.items, pending_items.groups, pending_items.affix
      pending_items = nil
      loading.items = false
      data.at = os.time()
      rev = rev + 1
    end
  elseif kind == "group" and pending_items then
    pending_items.groups[#pending_items.groups + 1] = { id = num(f[3]), name = f[4] or "" }
  elseif kind == "affix" and pending_items then
    pending_items.affix[num(f[3])] = { label = f[4] or "", pct = f[5] == "1" }
  elseif kind == "item" and pending_items then
    pending_items.items[#pending_items.items + 1] = {
      number = num(f[3]), id = num(f[4]), icon = num(f[5]), group = num(f[6]), worn = f[7] == "1",
      where = f[8] or "", name = f[9] or "", rolls = rolls(f[10]), baseline = num(f[11]), better = num(f[12]),
      worse = num(f[13]), standout = f[14] or "",
    }
  elseif kind == "worn" then
    if f[3] == "begin" then
      pending_worn = { dynamic = num(f[4]), items = num(f[5]), augs = num(f[6]), stats = {}, sets = {}, effects = {} }
    elseif f[3] == "end" and pending_worn then
      data.worn = pending_worn
      pending_worn = nil
      loading.worn = false
      data.at = os.time()
      rev = rev + 1
    end
  elseif kind == "wstat" and pending_worn then
    pending_worn.stats[#pending_worn.stats + 1] = { label = f[3] or "", pct = f[4] == "1", dynamic = num(f[5]),
      items = num(f[6]), sets = num(f[7]), cap = num(f[8]) }
  elseif kind == "set" and pending_worn then
    pending_worn.sets[#pending_worn.sets + 1] = { kind = f[3] or "", name = f[4] or "", pieces = num(f[5]),
      thresholds = f[6] or "", active = f[7] or "", spells = {} }
  elseif kind == "setspell" and pending_worn then
    local last = pending_worn.sets[#pending_worn.sets]
    if last then last.spells[#last.spells + 1] = f[4] or "" end
  elseif kind == "effect" and pending_worn then
    pending_worn.effects[#pending_worn.effects + 1] = { kind = f[3] or "", spell = f[4] or "", source = f[5] or "" }
  end
  return true
end

-- ---------------------------------------------------------------- what the window sees

hs.ui_function("state", function()
  return { open = open, rev = rev, loading = loading.items or loading.worn, at = data.at and os.date("%H:%M", data.at) }
end)

hs.ui_function("data", function() return data end)

hs.ui_function("command", function(what)
  if what == "close" then open = false
  elseif what == "refresh" then request()
  end
  return true
end)

hs.menu("Dynamic Items", "/dyninfo show")

mq.bind('/dyninfo', function(a)
  a = (a or ""):lower()
  if a == "" or a == "show" then
    open = not open
    if open then request() end
  elseif a == "refresh" then
    request()
  else
    say("/dyninfo [show | refresh]. The server's #dyninfo still works as before.")
  end
end)

-- ---------------------------------------------------------------- the lines

-- The server sends them as OP_SpecialMesg (RoF2 0x0083). A chat event sees a line but cannot hide it, so the
-- packet is read here and dropped before it reaches chat. That needs the 'packets' capability; without it the
-- chat event reads the lines instead, and they show.
local OP_SPECIAL_MESG = 0x0083
local hooked = pcall(hs.on_packet, 'zone', 'in', OP_SPECIAL_MESG, function(_, data)
  local at = data:find('DYNDATA|', 1, true)
  if not at then return nil end
  local stop = data:find('\0', at, true)
  line(data:sub(at, stop and stop - 1 or nil))
  return true
end)
if not hooked then
  mq.event('dynitems_data', 'DYNDATA|#*#', function(text) return line(text) end)
end
-- the echo of the requests
mq.event('dynitems_echo', "You say, '#dyninfo data#*#", function() return true end)

-- ---------------------------------------------------------------- the loop

while true do
  mq.doevents()
  if loading.since and (loading.items or loading.worn) and mq.gettime() - loading.since > ANSWER_MS then
    loading.items, loading.worn, loading.since = false, false, nil
    say("the server did not answer. Is this Voidforged, with #dyninfo data?")
  end
  mq.delay(TICK_MS)
end
