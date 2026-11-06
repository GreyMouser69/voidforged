-- Dynamic Items' window for the Modern pack. The script (../../init.lua) asks the server for #dyninfo's data and
-- keeps it; this shows it through the script's functions (eq.Plugin("dynitems"): state, data, command).
--   Overview  every slot you have dynamic items for: what you wear there, then each spare with how many of its stats
--             are better or worse than the worn one, and its standout affix. A click compares that item.
--   Compare   any two items side by side, stat by stat, with the change in green or red (one item alone if the
--             second is left empty).
--   Slot      one slot: the worn item and every spare in columns, each spare's differences beside its values.
--   Worn      the totals of everything worn (dynamic rolls, other items and augments, set bonuses) with caps, the
--             armor sets with their thresholds, and the worn and focus effects that count.
local hud = dofile("lib/hud.lua")
local T = hud.T
local C = T.color
local KEY = "DynItemsWnd"

local GOOD = C.good or { 0.40, 0.88, 0.55, 1 }
local BAD = C.bad or { 0.95, 0.42, 0.40, 1 }
local GOLD = C.gold or { 0.95, 0.80, 0.40, 1 }
local MUTED = C.muted or { 0.70, 0.70, 0.70, 1 }
local FAINT = C.faint or { 0.50, 0.50, 0.50, 1 }
local MAGIC = C.magic or { 0.50, 0.75, 1.00, 1 }

local P                    -- the script's functions (nil while it is not running)
local st = {}              -- its state, read each frame
local D = { items = {}, groups = {}, affix = {} }
local seen = -1            -- the data's rev last read
local byNumber = {}        -- item number -> item
local sel = { jump = nil, a = nil, b = nil, group = nil }

local function flag(t, name) return (t and t[name]) or 0 end

-- ---------------------------------------------------------------- the data

local function reload()
  local d = P.data() or {}
  D = { items = d.items or {}, groups = d.groups or {}, affix = d.affix or {}, worn = d.worn }
  byNumber = {}
  for _, e in ipairs(D.items) do byNumber[e.number] = e end
  -- choices that no longer exist are dropped
  if sel.a and not byNumber[sel.a] then sel.a = nil end
  if sel.b and not byNumber[sel.b] then sel.b = nil end
  if not sel.group and D.groups[1] then sel.group = D.groups[1].id end
end

local function affixLabel(id)
  local a = D.affix[id]
  return a and a.label or ("Affix " .. tostring(id))
end

local function unit(id)
  local a = D.affix[id]
  return (a and a.pct) and "%" or ""
end

local function rollOf(e, affix)
  if not e then return nil end
  for _, r in ipairs(e.rolls) do
    if r.affix == affix then return r end
  end
  return nil
end

-- Every affix on any of the items, in the server's order (by affix id)
local function affixesOf(list)
  local set, out = {}, {}
  for _, e in ipairs(list) do
    for _, r in ipairs(e.rolls) do
      if not set[r.affix] then set[r.affix] = true out[#out + 1] = r.affix end
    end
  end
  table.sort(out)
  return out
end

local function groupName(id)
  for _, g in ipairs(D.groups) do if g.id == id then return g.name end end
  return "Slot " .. tostring(id)
end

local function wornIn(group)
  for _, e in ipairs(D.items) do
    if e.group == group and e.worn then return e end
  end
  return nil
end

local function title(e) return string.format("#%d %s", e.number, e.name) end

-- ---------------------------------------------------------------- pieces

local function text(c, s) ui.TextColored(c[1], c[2], c[3], c[4] or 1, s) end

local function icon(id, size)
  local tex, u0, v0, u1, v1 = eq.ItemIcon(id)
  if tex then ui.Image(tex, size, size, u0, v0, u1, v1) else ui.Dummy(size, size) end
end

local function signed(v, u) return string.format("%+d%s", v, u) end

local function diffText(d, u)
  if d > 0 then text(GOOD, signed(d, u))
  elseif d < 0 then text(BAD, signed(d, u))
  else text(FAINT, "-") end
end

-- An item's stat lines, for tooltips
local function rollsTip(e)
  local lines = { title(e), e.where }
  for _, r in ipairs(e.rolls) do
    lines[#lines + 1] = string.format("%s%s: %d%s%s", r.guaranteed and "" or "* ", affixLabel(r.affix), r.value,
      unit(r.affix), r.guaranteed and "" or string.format("  (roll %d%%)", r.position))
  end
  lines[#lines + 1] = "* = random affix"
  return table.concat(lines, "\n")
end

local function openCompare(a, b)
  sel.a, sel.b = a, b
  sel.jump = "Compare"
end

-- ---------------------------------------------------------------- Overview

local function overview(s)
  if #D.items == 0 then
    text(MUTED, st.loading and "Asking the server..." or "You don't have any dynamic items.")
    return
  end
  local ICON = math.floor(26 * s)
  local flags = ui.TableFlags.RowBg | ui.TableFlags.SizingFixedFit
  for _, g in ipairs(D.groups) do
    ui.SeparatorText(g.name:upper())
    local worn = wornIn(g.id)
    local list = {}
    if worn then list[1] = worn end
    for _, e in ipairs(D.items) do
      if e.group == g.id and e ~= worn then list[#list + 1] = e end
    end
    if ui.BeginTable("##ov" .. g.id, 5, flags) then
      ui.TableSetupColumn("##icon", ui.TableColumnFlags.WidthFixed, ICON + 4 * s)
      ui.TableSetupColumn("Item", ui.TableColumnFlags.WidthStretch, 1.0)
      ui.TableSetupColumn("Where", ui.TableColumnFlags.WidthFixed, 90 * s)
      ui.TableSetupColumn("vs worn", ui.TableColumnFlags.WidthFixed, 110 * s)
      ui.TableSetupColumn("Standout", ui.TableColumnFlags.WidthStretch, 0.8)
      for _, e in ipairs(list) do
        ui.TableNextRow()
        ui.PushID(e.number)
        ui.TableNextColumn()
        icon(e.icon, ICON)
        ui.TableNextColumn()
        local clicked = ui.Selectable(title(e) .. "##sel", false, ui.SelectableFlags.SpanAllColumns, 0, ICON)
        if ui.IsItemHovered() then ui.SetTooltip(rollsTip(e) .. "\n\nClick to compare") end
        if clicked then
          if e.worn or not worn then openCompare(e.number, nil) else openCompare(worn.number, e.number) end
        end
        ui.TableNextColumn()
        if e.worn then text(GOLD, "worn") else text(MUTED, e.where) end
        ui.TableNextColumn()
        if e.worn then
          text(FAINT, "-")
        elseif not worn then
          text(FAINT, "nothing worn")
        else
          text(GOOD, string.format("%d better", e.better))
          ui.SameLine()
          text(BAD, string.format("%d worse", e.worse))
        end
        ui.TableNextColumn()
        if e.standout ~= "" then text(MAGIC, e.standout) end
        ui.PopID()
      end
      ui.EndTable()
    end
    ui.Spacing()
  end
end

-- ---------------------------------------------------------------- Compare

local function itemCombo(id, current, allowNone, filterGroup)
  local e = current and byNumber[current]
  local shown = e and title(e) or (allowNone and "(none)" or "Pick an item")
  local out = current
  if ui.BeginCombo(id, shown) then
    if allowNone and ui.Selectable("(none)", current == nil) then out = nil end
    for _, g in ipairs(D.groups) do
      if not filterGroup or filterGroup == g.id then
        ui.SeparatorText(g.name)
        for _, it in ipairs(D.items) do
          if it.group == g.id and ui.Selectable(title(it) .. (it.worn and "  (worn)" or "") .. "##c" .. it.number,
              it.number == current) then
            out = it.number
          end
        end
      end
    end
    ui.EndCombo()
  end
  return out
end

local function compare(s)
  if #D.items == 0 then text(MUTED, "No dynamic items.") return end
  if not sel.a then
    local first = D.items[1]
    sel.a = (wornIn(first.group) or first).number
  end
  local a, b = byNumber[sel.a], sel.b and byNumber[sel.b]

  text(MUTED, "Base")
  ui.SameLine()
  ui.SetNextItemWidth(300 * s)
  sel.a = itemCombo("##cmpA", sel.a, false) or sel.a
  ui.SameLine()
  text(MUTED, "against")
  ui.SameLine()
  ui.SetNextItemWidth(300 * s)
  sel.b = itemCombo("##cmpB", sel.b, true)
  ui.SameLine()
  if b and ui.SmallButton("Swap") then sel.a, sel.b = sel.b, sel.a end
  a, b = byNumber[sel.a], sel.b and byNumber[sel.b]
  if not a then return end

  ui.Spacing()
  text(GOLD, title(a) .. (a.worn and "  (worn)" or "  (" .. a.where .. ")"))
  if b then text(MUTED, "vs " .. title(b) .. (b.worn and "  (worn)" or "  (" .. b.where .. ")")) end
  if b and a.group ~= b.group then
    text(FAINT, string.format("(different slots: %s and %s)", groupName(a.group), groupName(b.group)))
  end
  ui.Spacing()

  local list = { a }
  if b then list[2] = b end
  local affixes = affixesOf(list)
  local better, worse = 0, 0
  local _, ah = ui.GetContentRegionAvail()
  local flags = ui.TableFlags.RowBg | ui.TableFlags.BordersInnerV | ui.TableFlags.ScrollY | ui.TableFlags.SizingFixedFit
  local cols = b and 4 or 3
  if ui.BeginTable("##cmp", cols, flags, 0, math.max(80 * s, (ah or 300) - 28 * s)) then
    ui.TableSetupScrollFreeze(0, 1)
    ui.TableSetupColumn("Stat", ui.TableColumnFlags.WidthStretch, 1.0)
    ui.TableSetupColumn("#" .. a.number, ui.TableColumnFlags.WidthFixed, 90 * s)
    if b then
      ui.TableSetupColumn("#" .. b.number, ui.TableColumnFlags.WidthFixed, 90 * s)
      ui.TableSetupColumn("Change", ui.TableColumnFlags.WidthFixed, 90 * s)
    else
      ui.TableSetupColumn("Roll", ui.TableColumnFlags.WidthFixed, 90 * s)
    end
    ui.TableHeadersRow()
    for _, affix in ipairs(affixes) do
      local ra, rb = rollOf(a, affix), b and rollOf(b, affix)
      local u = unit(affix)
      local random = (ra and not ra.guaranteed) or (rb and not rb.guaranteed)
      ui.TableNextRow()
      ui.TableNextColumn()
      text(random and MAGIC or C.text or { 1, 1, 1, 1 }, (random and "* " or "") .. affixLabel(affix))
      ui.TableNextColumn()
      if ra then ui.Text(ra.value .. u) else text(FAINT, "-") end
      if ra and ui.IsItemHovered() and not ra.guaranteed then
        ui.SetTooltip(string.format("Rolled at %d%% of its range%s", ra.position, ra.reforged and " (reforged)" or ""))
      end
      ui.TableNextColumn()
      if b then
        if rb then ui.Text(rb.value .. u) else text(FAINT, "-") end
        if rb and ui.IsItemHovered() and not rb.guaranteed then
          ui.SetTooltip(string.format("Rolled at %d%% of its range%s", rb.position, rb.reforged and " (reforged)" or ""))
        end
        ui.TableNextColumn()
        local d = (rb and rb.value or 0) - (ra and ra.value or 0)
        if d > 0 then better = better + 1 elseif d < 0 then worse = worse + 1 end
        if not ra then text(GOOD, signed(d, u) .. " (new)")
        elseif not rb then text(BAD, signed(d, u) .. " (lost)")
        else diffText(d, u) end
      else
        if ra and not ra.guaranteed then text(FAINT, ra.position .. "%") else text(FAINT, "fixed") end
      end
    end
    ui.EndTable()
  end
  if b then
    text(GOOD, better .. " better")
    ui.SameLine()
    text(BAD, worse .. " worse")
    ui.SameLine()
    text(FAINT, "   * = random affix")
  else
    text(FAINT, "* = random affix. Roll = where it landed in its range.")
  end
end

-- ---------------------------------------------------------------- Slot

local function slot(s)
  if #D.groups == 0 then text(MUTED, "No dynamic items.") return end
  local shown = groupName(sel.group)
  ui.SetNextItemWidth(220 * s)
  if ui.BeginCombo("##slot", shown) then
    for _, g in ipairs(D.groups) do
      if ui.Selectable(g.name .. "##g" .. g.id, g.id == sel.group) then sel.group = g.id end
    end
    ui.EndCombo()
  end

  local worn = wornIn(sel.group)
  local list = {}
  if worn then list[1] = worn end
  for _, e in ipairs(D.items) do
    if e.group == sel.group and e ~= worn then list[#list + 1] = e end
  end
  if #list == 0 then text(MUTED, "Nothing for this slot.") return end
  ui.SameLine()
  text(FAINT, worn and "  differences are against your worn item" or "  nothing dynamic worn here")

  local affixes = affixesOf(list)
  local _, ah = ui.GetContentRegionAvail()
  local flags = ui.TableFlags.RowBg | ui.TableFlags.BordersInnerV | ui.TableFlags.ScrollY | flag(ui.TableFlags, "ScrollX")
    | ui.TableFlags.SizingFixedFit
  local ICON = math.floor(22 * s)
  if ui.BeginTable("##slot_t", #list + 1, flags, 0, math.max(80 * s, (ah or 300) - 4 * s)) then
    ui.TableSetupScrollFreeze(1, 1)
    ui.TableSetupColumn("Stat", ui.TableColumnFlags.WidthFixed, 170 * s)
    for _, e in ipairs(list) do
      ui.TableSetupColumn("#" .. e.number .. (e.worn and " (worn)" or ""), ui.TableColumnFlags.WidthFixed, 120 * s)
    end
    ui.TableHeadersRow()
    -- the items' icons and names, one row
    ui.TableNextRow()
    ui.TableNextColumn()
    text(FAINT, "Item")
    for _, e in ipairs(list) do
      ui.TableNextColumn()
      icon(e.icon, ICON)
      if ui.IsItemHovered() then ui.SetTooltip(rollsTip(e) .. "\n\nClick to compare") end
      if ui.IsItemClicked(ui.Mouse.Left) then
        if worn and e ~= worn then openCompare(worn.number, e.number) else openCompare(e.number, nil) end
      end
      if not e.worn and worn then
        ui.SameLine()
        text(GOOD, "+" .. e.better)
        ui.SameLine()
        text(BAD, "-" .. e.worse)
      end
    end
    for _, affix in ipairs(affixes) do
      local u = unit(affix)
      local base = worn and rollOf(worn, affix)
      ui.TableNextRow()
      ui.TableNextColumn()
      ui.Text(affixLabel(affix))
      for _, e in ipairs(list) do
        ui.TableNextColumn()
        local r = rollOf(e, affix)
        if r then ui.Text(r.value .. u) else text(FAINT, "-") end
        if worn and e ~= worn then
          local d = (r and r.value or 0) - (base and base.value or 0)
          if d ~= 0 then
            ui.SameLine()
            text(d > 0 and GOOD or BAD, "(" .. signed(d, u) .. ")")
          end
        end
      end
    end
    ui.EndTable()
  end
end

-- ---------------------------------------------------------------- Worn

local function wornTab(s)
  local w = D.worn
  if not w then text(MUTED, st.loading and "Asking the server..." or "No totals yet: press Refresh.") return end
  text(GOLD, string.format("%d dynamic, %d other item%s, %d augment%s worn", w.dynamic, w.items,
    w.items == 1 and "" or "s", w.augs, w.augs == 1 and "" or "s"))
  if #w.stats == 0 then text(MUTED, "Your worn gear doesn't give any stats.") end

  ui.BeginChild("##wornscroll", 0, 0, false)
  if #w.stats > 0 then
    local flags = ui.TableFlags.RowBg | ui.TableFlags.BordersInnerV | ui.TableFlags.SizingFixedFit
    if ui.BeginTable("##worn", 5, flags) then
      ui.TableSetupColumn("Stat", ui.TableColumnFlags.WidthStretch, 1.0)
      ui.TableSetupColumn("Dynamic", ui.TableColumnFlags.WidthFixed, 80 * s)
      ui.TableSetupColumn("Items", ui.TableColumnFlags.WidthFixed, 80 * s)
      ui.TableSetupColumn("Sets", ui.TableColumnFlags.WidthFixed, 80 * s)
      ui.TableSetupColumn("Total", ui.TableColumnFlags.WidthFixed, 150 * s)
      ui.TableHeadersRow()
      for _, r in ipairs(w.stats) do
        local u = r.pct and "%" or ""
        local total = r.dynamic + r.items + r.sets
        ui.TableNextRow()
        ui.TableNextColumn()
        ui.Text(r.label)
        for _, v in ipairs({ r.dynamic, r.items, r.sets }) do
          ui.TableNextColumn()
          if v ~= 0 then ui.Text(v .. u) else text(FAINT, "-") end
        end
        ui.TableNextColumn()
        text(GOLD, total .. u)
        if r.cap > 0 and total > r.cap then
          ui.SameLine()
          text(BAD, "(cap " .. r.cap .. u .. ")")
          if ui.IsItemHovered() then ui.SetTooltip("Only " .. r.cap .. u .. " counts in game") end
        end
      end
      ui.EndTable()
    end
    text(FAINT, "Items = other worn items and all augments. Gear only, not buffs or AAs. Base stat and resist caps also apply in game.")
  end

  if #w.sets > 0 then
    ui.Spacing()
    ui.SeparatorText("ARMOR SETS")
    for i, set in ipairs(w.sets) do
      ui.PushID("set" .. i)
      text(C.text or { 1, 1, 1, 1 }, set.name)
      ui.SameLine()
      text(FAINT, "(" .. set.kind .. ")")
      ui.SameLine()
      text(MUTED, string.format("%d worn, bonuses at %s,", set.pieces, set.thresholds ~= "" and set.thresholds or "none"))
      ui.SameLine()
      if set.active ~= "" then text(GOOD, "active: " .. set.active) else text(BAD, "none active") end
      for _, sp in ipairs(set.spells) do
        text(MAGIC, "    " .. sp)
      end
      ui.PopID()
    end
  end

  local worn_fx, focus_fx = {}, {}
  for _, e in ipairs(w.effects) do
    if e.kind == "focus" then focus_fx[#focus_fx + 1] = e else worn_fx[#worn_fx + 1] = e end
  end
  for _, part in ipairs({ { "WORN EFFECTS", worn_fx }, { "FOCUS EFFECTS", focus_fx } }) do
    if #part[2] > 0 then
      ui.Spacing()
      ui.SeparatorText(part[1])
      for _, e in ipairs(part[2]) do
        text(MAGIC, e.spell)
        ui.SameLine()
        text(FAINT, "(" .. e.source .. ")")
      end
    end
  end
  ui.EndChild()
end

-- ---------------------------------------------------------------- the window

local TABS = {
  { "Overview", overview },
  { "Compare", compare },
  { "Slot", slot },
  { "Worn", wornTab },
}

local function body(x, y, w, h, s)
  ui.SetCursorScreenPos(x, y)
  ui.BeginChild("##dynbody", w, h, false, ui.WindowFlags.NoBackground)
  if ui.SmallButton("Refresh") then P.command("refresh") end
  ui.SameLine()
  if st.loading then text(MUTED, "asking the server...")
  elseif st.at then text(FAINT, "updated " .. st.at) end
  ui.SameLine()
  text(FAINT, string.format("   %d dynamic item%s", #D.items, #D.items == 1 and "" or "s"))

  if ui.BeginTabBar("##dyntabs") then
    for _, t in ipairs(TABS) do
      local f = (sel.jump == t[1]) and ui.TabItemFlags.SetSelected or 0
      if ui.BeginTabItem(t[1], f) then
        ui.BeginChild("##tab" .. t[1], 0, 0, false, ui.WindowFlags.NoBackground)
        t[2](s)
        ui.EndChild()
        ui.EndTabItem()
      end
    end
    sel.jump = nil
    ui.EndTabBar()
  end
  ui.EndChild()
end

ui.window("Dynamic Items", function()
  P = eq.Plugin("dynitems")
  if not P or not eq.InGame() then return end
  st = P.state() or {}
  if not st.open then return end
  if st.rev ~= seen then
    reload()
    seen = st.rev
  end
  hud.Dialog(KEY, "Dynamic Items", {
    shown = true,
    keepTitle = true,
    size = function() return 780, 560 end,
    resizable = { 560, 360 },
    place = function(W, H, w, h) return (W - w) / 2, (H - h) / 2 end,
    onClose = function() P.command("close") end,
  }, body)
end)
