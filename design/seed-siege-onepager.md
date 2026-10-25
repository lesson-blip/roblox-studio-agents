# Seed Siege: one page summary

**What it is.** A co-op garden tower defence in an Aussie backyard. Meet your mates at Nan's Backyard, step onto a garden gate together (1 to 4 players, no typing), and plant cheeky plants with faces beside the path to shoo off bugs, swooping magpies, cockatoos, possums and Kevin the Bin Chicken before they reach Nan's shed. Every wave drops a Seed Pod for a named plant, so you grow a collection of 24 plants from Common to Champion just by playing. Nothing random is ever sold.

**Who it is for first.** Players 16 and over, because Roblox shows new games only to age-checked 16+ players at first. It stays gentle so it can open to younger players later: bugs puff into leaves, animals are only ever shooed (they get grumpy and leave, never hurt), no blood, no scary bits, no typing, no gambling.

**What is in the first version.**

- **The cast.** Nan hosts the hub and cheers you on in runs ("Righto, gardeners. Here they come!"). 24 plants with faces and moods, from grumpy Thorn Sprout to the Grand Old Gum with a kookaburra on top. 20 pests: the original bugs plus blowies, stink bugs, cane toads, magpies, cockatoos, brush turkeys, flying foxes and a wombat, and three bosses: **Kevin the Bin Chicken** (nicks your plants and hides in a wheelie bin), **Swoopy the Magpie** and **Possum Pete**.
- **Co-op for 1 to 4.** A hub with four garden gates, Nan, the Seed Almanac, a display bed for everyone's favourite plants and a weekly board. Each player defends their own stretch of path with their own Sap; hearts are shared. Pests get tougher with more players, so it is about as hard together as alone. Invite friends with Roblox's own invite button.
- **The collection.** Six tiers named for an agricultural show: Common, Uncommon, Rare, Ribbon, Blue Ribbon, Champion. The chances are shown on screen, plants you don't have yet are twice as likely, and guarantees mean nobody gets stuck (a Champion within 300 pods, and you pick which). Spare pods level plants up to 10. A typical player (about 30 minutes a day) gets their first Champion around day 11 and all 24 plants around day 21.
- 3 gardens (Backyard Patch with Kevin as the finale, Veggie Rows with Swoopy, Night Orchard with Possum Pete and the Wombat), Frost mode, the research tree, and the automatic **weekly garden every Monday** where everyone plays with the same plants.

**Balance check.** A test bot plays every garden with 1 to 4 players. New player first try: Backyard about 90% wins, Veggie Rows about half, Night Orchard about 15 to 25%, much the same with friends.

**Money (fair by design).** Unchanged at launch: 2x speed (149 Robux; in a group, one owner unlocks it for everyone), a sixth seed slot (199), a "Second Wind" that saves a lost solo game once (25, and one free every day), private servers (100 a month). Never sold: pods, plants, plant levels, Petals, Gumnuts, luck or anything random. A bought Second Wind gives no pods afterwards, so Robux can never lead to a pod. Expect small money at first (tens of dollars a month for a small game).

**How it gets built (from here, about 49 builder days).**

1. **M2 Saves and the hub** (10 days): saving, Nan's Backyard, gates, the tutorial, three gardens, research.
2. **M3 Co-op runs** (9 days): parties of 1 to 4, zones, Ready, pings, leaving and rejoining.
3. **M4 The collection** (11 days): 24 plants, pods, guarantees, the Almanac.
4. **M5 Cast and bosses** (9 days): the Aussie pests, Kevin and Swoopy, Nan's lines.
5. **M6 Weekly garden, shop and launch** (10 days): then publish to 16+.

Parked for later: more game modes, weather and a Saturday event (room is left for each).

**What you need to do.** Studio on a Windows or Mac computer; the first "Publish to Roblox" from Studio; create the passes and products in Creator Hub; a short playtest at each step; answer the maturity questionnaire honestly.

**Decisions for you** (details in section 10 of `design/seed-siege-v2.md`):

1. Up to 12 players per server, with everyone's gardens in the same server? (Recommended yes.)
2. Kevin as the finale of the first garden? (Yes.)
3. In co-op, 2x speed if any one player owns it? (Yes.)
4. Gumnuts and the Seed Swap at launch, so nobody is stuck on one plant? (Yes, first to cut if late.)
5. No pods after a bought Second Wind? (Yes.)
6. Aussie names for the original bugs (Sugar Ant, Bogong Moth, Christmas Beetle, Possum Pete)? (Yes.)

Still open from before: launch prices, the route to younger players, membership price, weekly reset time, and a name search for "Seed Siege" on Roblox.

Full plan: `design/seed-siege-spec.md` (version 1) plus `design/seed-siege-v2.md` (the changes).
