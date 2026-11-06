# Dynamic Items for Hailstone

A window for Voidforged's dynamic items in the [Hailstone](https://github.com/projecthailstone) client. It shows what
`#dyninfo` shows, as tables instead of popups: no pages, sortable by slot, with the differences in green and red.

## The window

- **Overview:** every slot you have dynamic items for. What you wear there comes first (marked *worn*), then each
  spare with how many of its stats are better or worse than the worn one, and its standout affix. Hover an item for
  all its stats; click it to compare.
- **Compare:** any two items, stat by stat: both values and the change, "(new)" and "(lost)" for stats only one has.
  Leave the second empty to see one item alone with where each random roll landed in its range.
- **Slot:** one slot: the worn item and every spare in columns, each spare's differences beside its values.
- **Worn:** the totals of everything you wear, as Dynamic / Items / Sets / Total, with a red *(cap)* where only part
  counts; your armor sets with their thresholds and which are active; the worn and focus effects that count.

**Refresh** asks the server again (after you swap gear or loot something). `* = random affix`.

## Installing

Until it is released as an add-on: copy the `dynitems` folder into the `scripts` folder of your Hailstone folder, so
that you have `scripts/dynitems/init.lua`. In the game, type `/lua run dynitems`. To start it at every login, tick
Autorun in the Lua Scripts window.

Then `/dyninfo` shows or hides the window (also the EQ menu: **Plugins > Dynamic Items**).

The windows are drawn for the Modern UI.

## Commands

| Command | |
|---|---|
| `/dyninfo` | show or hide the window (opening it refreshes) |
| `/dyninfo refresh` | ask the server again |

The server's own `#dyninfo` still works as before.

## How it works

The script asks the server for `#dyninfo data` and `#dyninfo data worn`. Those answer in tagged `DYNDATA|` chat lines
(listed in the server's `zone/gm_commands/dynamic_items.cpp`). The script reads them from the server's message
packets and drops those packets, so the lines never reach chat. It needs `read`, `chat` (to send the two commands),
`ui` and `packets`; without `packets` it reads them through a chat event (`events`) instead, and they show in chat.
