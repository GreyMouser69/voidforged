# Guild Halls (design, in progress 2026-11-07)

Guilds earn Infamy from guild achievements, fill a treasury with platinum, and spend it on a private hall that grows
with the guild: a better zone each tier, amenities, decorations, and boss trophies that upgrade as the guild keeps
killing. Voidforged only. Nothing here is built yet. Every number marked *draft* is a placeholder to tune.

## Currencies

| Currency | What it is | Spent? |
|---|---|---|
| Infamy | The guild's running total of achievements | Never. It only unlocks things in the store |
| Treasury platinum | Platinum members donate to the guild | Yes. It pays for everything in the store |

- Any member can donate platinum to the treasury. Donations can't be withdrawn.
- Only the guild leader buys from the store.
- Guild chat announces Infamy earned and store purchases. Members can check the Infamy total and treasury balance.

## Earning Infamy

Boss kill Infamy scales with how many guild members were on the kill: each value below is per guild member credited.
Gear and items never earn Infamy.

| Source | Infamy *(draft)* |
|---|---|
| Rift Guardian kill | Rift tier / 10, per guild member |
| Raid portal boss | 25 x raid tier, per guild member |
| Open-world raid bosses | Per guild member: 10 Classic, 15 Kunark, 20 Velious, 25 Luclin, 30 Planes of Power |
| The guild's first kill of a boss | 5x the normal amount, once per boss |
| A member reaches max level | 100, once per character |

At these rates a six-member guild group clearing a tier 100 rift earns 60 Infamy, and a 12-member guild raid on
Lady Nagafen earns 120, or 600 on the guild's first kill.

Infamy goes to the guild the character is in at the time of the kill or level.

## Halls

- A guild owns one hall at a time. There are no free halls: the T1 hall also needs Infamy and platinum.
- Halls are bought in order. A guild can't skip a tier or save for T5 without owning T1 to T4 first.
- Upgrading replaces the old hall with no refund. Everything the guild bought comes along: amenities are set up in the
  new hall, and placed decorations and trophies go to the guild's stored list to be placed again.
- Each tier offers a choice of zones. The guild picks one.

| Tier | Infamy *(draft)* | Platinum *(draft)* | Zones |
|---|---:|---:|---|
| T1 | 1,000 | 250,000 | The existing guild hall |
| T2 | 5,000 | 1,000,000 | Open: city zones |
| T3 | 15,000 | 3,000,000 | Open: for example temples |
| T4 | 40,000 | 8,000,000 | Open: for example raid zones |
| T5 | 100,000 | 20,000,000 | Open |

Which zones go in which tier is still to be discussed.

### Layout

A hall is a small part of its zone, in the guild's own private copy of the zone. It has two areas:

- **Public showcase**, where everyone arrives. Trophies and decorations are on display, and any player can visit.
- **Private wing**, for members only. The guild bank, tribute master, banker and other amenities are here. A
  non-member who walks in is moved back to the showcase, and the amenity NPCs don't serve non-members.

The rest of the zone is empty and outside the hall. Players who leave the hall's area are moved back into it. The
zone's own NPCs don't spawn in guild copies.

### Entry

- The Waypoints map gets a Guild Hall entry. Members go to their own hall.
- Next to it, "Visit a Guild Hall" lists the guilds with a hall and sends the player to that guild's showcase.
- The guild leader can close the hall to visitors.

### Every hall includes

- Guild bank
- Guild tribute master
- Banker
- Regen bath (health and mana)

## Store

Everything costs Infamy to unlock and treasury platinum to buy. Amenities also need a minimum hall tier.

### Amenities *(draft)*

| Amenity | Min tier | Infamy | Platinum |
|---|---|---:|---:|
| Porter to the Bazaar and The Void | T1 | 1,500 | 100,000 |
| General merchant (food, drink, reagents) | T1 | 2,000 | 100,000 |
| Tradeskill stations (each bought separately) | T2 | 5,000 | 150,000 each |
| Corpse summoner | T2 | 7,500 | 500,000 |
| Buff NPC (the Bazaar buffs) | T2 | 10,000 | 750,000 |
| Better regen bath, level 1 / level 2 | T3 | 15,000 / 30,000 | 1,000,000 / 3,000,000 |
| Rift entrance | T3 | 20,000 | 2,000,000 |
| Portal pool to popular zones | T4 | 40,000 | 5,000,000 |
| Raid portal entrance | T4 | 50,000 | 5,000,000 |

### Decorations *(draft)*

| Type | Unlocked by | Platinum |
|---|---|---:|
| Furniture (items 61800-61821), plants, lights, banners | Hall tier | 5,000-25,000 |
| Statues and large pieces | Owning a T3 hall | 100,000 |
| Boss trophies | Killing that boss in the raid portal | 50,000 |

## Boss trophies

- Trophies come only from raid portal bosses, one per boss in the roster. Open-world kills earn Infamy but no trophy.
- A guild buys a boss's trophy once. After that it upgrades by itself from the guild's record for that boss.

| Record | Trophy change |
|---|---|
| Highest raid tier killed | Name plate and tint: Bronze, Silver, Gold, Platinum, Void (tier 1-5) |
| Total kills at any tier | Bigger at 10 and 25 kills, a glow at 50, a stronger effect at 100 |

- The name plate shows the tier and kill count, for example "Lady Vox - Gold, 50 kills".
- Some boss models ignore tints. Those trophies show their tier through the name plate only.

## Placement

- Free placement: the leader or an officer stands where an item should go and places it with a command. Commands
  also rotate, move, remove and list items.
- Removed items go back to the guild's stored list.
- Items can only be placed inside the hall's areas.
- Placed item limit per hall *(draft)*: about 25 at T1, rising to about 150 at T5, so halls load quickly.

## Zones

The zone list is open. Each hall zone is one entry in a config file. The shared code doesn't change when zones are
added or removed.

A zone entry holds:

- the arrival point
- the public and private areas, as boxes with height limits, so multi-floor buildings work
- where items can be placed
- which doors and zone exits stay in the guild copy
- any of the zone's own scripts that must skip guild copies

Effort per zone is about an hour of setup plus 15-30 minutes in game marking corners with `#loc`, then a walk-through.
Zones with odd geometry, a lot of height, or zone-wide scripts take longer.

**Changing the list**

- Adding a zone: a config entry and generated database rows. The zone shows up in its tier.
- Removing or replacing a zone: guilds in it move to a replacement zone in the same tier for free. Their placed items
  go to the stored list.

## New characters

The guild hall zone is also where new characters land today (`quests/crescent/player.pl` sends them there through
`SendToGuildHall`, and `quests/guildhall/player.pl` gives starter AAs). New characters keep a separate shared copy
of the zone, so guild halls stay private.

## Technical notes

What exists today:

- `Client::SendToGuildHall` (`zone/client.cpp`) keeps one guildhall instance per guild in the data bucket
  `guild-hall-instance-<guild id>`, using instance version 1, for 90 days (`Instances:GuildHallExpirationDays`).
- The guild bank only works in the guildhall zone. `Zones::GUILDHALL` checks are in `zone/client_packet.cpp`,
  `zone/guild.cpp` and `zone/zone.cpp` (`GuildBankManager` is only created there).
- `Client::TransportToWaypoint` (`zone/nms_waypoints.cpp`) sends players only to non-instanced zones or to their
  expedition.
- The Guild Lobby is GM-only (`min_status` 255) and its doors lead nowhere.
- The guild hall's regen bath is `quests/guildhall/Aporia.lua`.

Changes needed:

- Server code (rebuild and restart):
  - allow the guild bank in guild hall copies of other zones
  - make the map's Guild Hall entry find the guild's hall instance
  - possibly let a guild hall instance persist without expiring while the guild owns it
- Guild hall copies use their own zone version (proposed 60), with no normal spawns and only the doors and zone exits
  the zone entry keeps. The number must be checked against every hall zone, as the raid portal did with 50.
- New tables, for example:
  - the guild's Infamy total and log
  - treasury balance and donations
  - the guild's hall (tier, zone, instance)
  - unlocks and purchases
  - placed and stored items
  - trophy records (boss, highest tier, kills)
- Scripts:
  - Infamy awards on boss death and level up
  - the store and treasury NPC
  - placement commands
  - spawning placed items and trophies when the hall loads
  - the public and private area checks
- Back up the database before the migration.

## Tabled

- Guild hopping and alt farming protection. For now the players are friends on the tailnet.

## Open questions

- Hall zones for each tier.
- Store contents and every *draft* number above.
- How players donate and check totals: an NPC, a command, or both.
- What a visitor sees when a guild has closed its hall.
