# Seed Siege: game design and build plan

Version 1, 25 October 2026. Designer agent. Built on `research/2026-10-game-ideas.md` (cited below as "research 2.4" and so on).

Audience for this file:

- **Builder agent**: writes the Luau code in a Rojo project from sections 3, 4, 6 and 7. Every number in this file is meant to be typed in as data, not invented again.
- **Tester agent**: writes Lune tests from sections 3, 4, 6.4 to 6.8 and 8, using the test vectors in Appendix A.
- **Owner**: reads the one page summary (`design/seed-siege-onepager.md`), makes the decisions in section 11, and does the 15 minute playtest in section 8.3.

The balance numbers were checked with a small Python prototype of the rules in section 3 (`design/prototype/`, run `python3 reference_runs.py` and `python3 bot.py 26`). It is a reference, not the game: the Luau code is the source of truth once written, and the Lune balance tests in 8.1 replace the prototype.

## 0. Conventions and facts we have not confirmed

Conventions for all code:

- Luau with `--!strict` at the top of every module. Use the `task` library (`task.wait`, `task.spawn`, `task.delay`), never `wait` or `spawn`.
- All gameplay runs on the server. The client sends intents and draws what the server says.
- Pure logic lives in `src/shared/Logic`. A Logic module **never calls `require`, never touches a Roblox service, `game`, `workspace`, `Instance`, `os.clock`, `tick` or `DateTime`**. Time comes in as a number argument. This is what lets Lune run it (research 5).
- Logic modules that need other Logic modules expose `bind(L)`, where `L` is a table of all Logic modules. Two tiny bundle files do the wiring: `src/shared/LogicBundle.luau` (Roblox, `require(script.Parent.Logic.X)`) and `tests/bundle.luau` (Lune, string requires). Reason: Roblox requires by instance and Lune requires by path; whether Roblox's own require by string is fully released is **not confirmed in our research**, so we do not depend on it.
- Grid coordinates are `(x, y)` integers, `x` 0 to 11 (columns), `y` 0 to 7 (rows), with `y` 0 at the far edge of the plot from the camera. A tile centre is `(x + 0.5, y + 0.5)` in tile units. One tile is 4 studs.
- Rounding: "round" means `math.floor(v + 0.5)` everywhere (never banker's rounding).
- Australian English, no em or en dashes in any player text, comment or commit message.
- Avoid unions (`PartOperation`), `SurfaceAppearance`, `EditableImage`, `EditableMesh` and `BaseWrap`, because Open Cloud place publishing does not update them (research 5). Build plants, pests and tiles from Parts and simple MeshParts.

Facts the research marks unverified, and how this plan avoids depending on them:

| Fact | Research | How the plan handles it |
|---|---|---|
| Kids and Select entry threshold: 250 plays (Creator Hub) or 500 players (DevForum) from highly engaged, age-checked players | 2.4 | Owner checks the Audience Reach dashboard. Plan only needs "launch 16+, grow, then apply". |
| Current minimum Ads Manager budget | 2.5 | Owner reads the error the Ads Manager returns. Not needed before M4. |
| Rewarded video ads eligibility | 3 | Listed as "later, if eligible". Nothing in launch depends on it. |
| Open Cloud coverage for passes and developer products | 5 | Owner creates passes and products by hand in Creator Hub once; ids go into `Products.luau`. |
| Plus "one free private server per game" limit | 2.2 | Pricing still works either way. |
| Creating a new experience outside Studio | 5 | Owner does the first "Publish to Roblox" from Studio. CI publishes afterwards. |
| Higher DevEx rate on US 18+ buyers for an Australian creator | 4 | Revenue estimates use the base 0.0038 rate. |
| Roblox require by string, `UnreliableRemoteEvent` payload limits, `AnalyticsService` funnel calls, `UserService:GetUserInfosByUserIdsAsync` | not in research | Plan uses instance requires, a reliable `RemoteEvent` at 5 Hz for snapshots, and makes analytics and display name lookups optional with a fallback. Builder checks current Creator Hub docs before using any of these. |
| Exact content maturity label the questionnaire will give | 3 | Design keeps to cartoon "shooing" with no blood, no realistic violence, no free text input, no gambling. Owner answers the questionnaire honestly; we expect Minimal or Mild but cannot promise it. |

---

## 1. Pitch and target player

**Pitch.** Seed Siege is a garden tower defence. Pests march along a garden path towards your shed; you plant seeds beside the path that grow into defender plants, earn Sap from every pest you shoo away, and spend it on more plants and upgrades between and during waves. Every run pays Petals, which buy permanent research and new seeds. Three hand made fields teach the game; a fresh "weekly field" is generated every Monday from the week number, with two modifiers and a leaderboard where everyone plays on level soil. It plays fully solo, and two friends can share one plot.

**Target player at launch:** age-checked players 16 and over (research 2.4), so the first version must please 16 to 25 year olds: real decisions (counters, positioning, upgrade timing), a 1.5x speed button for everyone, short honest menus, no baby talk. **Kept Minimal or Mild maturity** so it can open to Roblox Kids and Select later: pests are cartoon insects and a possum that "poof" into a puff of leaves and scurry off when beaten (they are shooed, never killed or hurt on screen), no blood, no horror, no romance, no free text entry anywhere, no paid random items, no trading. The tone is warm Australian backyard: gumnuts, Hills Hoist, a gardener called Nan who gives one line tips.

**Why this fits the owner:** content is data (seeds, pests, waves), so AI can add it in bulk and Lune can check it by numbers; the weekly field runs itself; one player in a server is a full game (research 6).

---

## 2. Core loop

### 2.1 The loop in one line

Pick a field, plant seeds, start a wave, watch and adjust (place, upgrade, sell), earn Sap, clear waves, finish the run, get Petals, buy research or a new seed, pick the next field.

### 2.2 First session, minute by minute (teach by doing)

No menu and no text wall before play. The player spawns straight into a Backyard Patch run on their own plot. Every tip is one line of at most 8 words in a bubble pointing at the thing to tap (section 7.7). Times assume 1x speed.

| Time | What the player does | What it teaches |
|---|---|---|
| 0:00 to 0:15 | Loads in. Camera glides along the path from the gate to the shed, then settles over the plot. | Pests walk this path to the shed. |
| 0:15 to 0:40 | Tip "Tap the Thorn Sprout." Only that card is active. Then "Plant it beside the path." Tiles near the path glow; one has a sparkle (8, 2). Ghost and range ring appear; tap again to plant. | Choosing a seed, placing, range. |
| 0:40 to 1:20 | "Start the wave!" pulses. Wave 1: 4 aphids. The thorn pops them; "+3" Sap floats up each time. | Plants fight on their own; pests pay Sap. |
| 1:20 to 2:10 | "You earned Sap. Plant another." Then the Sunpetal card appears with "New seed!" and "Sunpetals grow Sap each wave." A seedling badge reads "Grows in 1 wave". | Economy plants and growth time. |
| 2:10 to 3:00 | Wave 2 (8 aphids). After it: "Tap a plant to upgrade it." The inspector opens with Upgrade highlighted. | Upgrading. |
| 3:00 to 4:00 | Wave 3 (ants and aphids). Burr Vine unlocks: "Burr Vine slows pests. Try a corner." | Slows and corners. |
| 4:00 to 5:00 | "Speed up?" points at the speed button (1x to 1.5x). Wave 4. | Speed control. Tutorial tips end here; a "Skip tips" link was on screen since 0:40. |
| 5:00 to 8:30 | Waves 5 to 10 with snails, caterpillars, then 2 beetles in wave 10. One reactive tip per new pest type, shown the first time it appears ("Snails are tough. Upgrade or add plants."). The player usually loses 2 to 5 hearts in wave 10. | Tension and counters, without failure. |
| 8:30 to 9:30 | Results screen: Petals breakdown, Dandelion unlocked, "You can afford research" button. Research opens with Pumpkin Mortar highlighted (60 Petals). | Permanent progress. |
| 9:30 to 10:00 | Garden Gate menu (section 7.3): Veggie Rows now open, the weekly field card is open, Loadout shows 4 seeds. | Choice of what next. |
| 10:00 to 22:00 | Veggie Rows. Wave 3 brings moths: "Moths fly! Not every plant reaches them." with sky icons on the seed cards. A new player often loses here around wave 7 to 12, gets Petals anyway, and sees exactly which pest beat them. | Flying pests and loadout choice. |

### 2.3 Day 1 reasons to return

- Veggie Rows is open and "nearly beaten"; the results screen names the pest that leaked most and suggests a counter seed or research node.
- Research tree is visible with the next node's cost and the player's Petals ("40 more Petals").
- Results screen line: "First win each day gives +50% Petals." Nothing is lost by skipping a day: no streak to break.
- A free Second Wind each day (section 5.1).

### 2.4 Days 2 to 7

- Clear Veggie Rows (unlocks Mint Mist and Night Orchard); reach wave 8 there (unlocks Snapjaw).
- Night Orchard brings moles that hide underground and a possum boss at wave 10 and 20; it normally needs some research (about 960 Petals of it, reached around day 4).
- The weekly field: everyone plays on level soil (section 3.8), so a new player can rank on day 2. Score shows on the Garden Gate card.
- Stars per field: 1 star clear, 2 stars clear with 15+ hearts left, 3 stars clear on Frost.

### 2.5 Days 8 to 28

- Finish the research tree (6,710 Petals; a free player at about 35 minutes a day finishes around day 21, section 4.5).
- Frost mode on each field after clearing Night Orchard: pests have 1.4x health, Petals 1.5x. It is the third star.
- Weekly ribbons: wave 15, 25 and 35 ribbons on the weekly field, and a "Top 100" ribbon for any week you finished in the top 100. Ribbons show on your plot sign and leaderboard row.
- Free cosmetics from stars: 3 stars total gives the Terracotta Pots garden theme, 6 gives the Gumnut plant skin set, 9 gives the Golden Trowel title. These prove the cosmetic system before any paid cosmetic exists.
- Garden Journal (M4): pest entries fill in as you shoo them, with milestone titles (shoo 500 snails: "Snail Whisperer").
- New weekly field every Monday 00:00 UTC (Monday 10am AEST, 11am AEDT).

---

## 3. Rules of play and launch content

### 3.1 Simulation rules (exact; WaveSim implements these, the Tester checks them)

Fixed step `TICK = 0.1` seconds of game time. Speed changes how many ticks run per real second (1x: 10, 1.5x: 15, 2x: 20), never the step size, so results do not depend on speed.

**Run start.** Sap = field `startSap` + research start Sap (+100 with the Drought modifier). Hearts = 20 + research hearts. Phase = `build`.

**Phases.** `build` (between waves; waits for Start wave, or auto start after 5 seconds if the player turned Auto start on in settings), `wave`, `over`. Planting, upgrading and selling are allowed in `build` and `wave`.

**Path.** A field path is a list of waypoints (tile coordinates). The pest route is the polyline through the waypoint tile centres; `L` is its length in tiles. Path tiles are every tile on the straight segments between waypoints. A pest's state is `d`, distance along the route from the first waypoint centre. Position is found by walking the segments.

**Spawning.** A wave is a list of groups `{pest, count, gap, start}`. Pest `k` (0 based) of a group spawns at wave time `start + k * gap`, at `d = 0`, with health `pest.hp * field.hpScale * modifierHp * frostHp * groupHpMult`. If 120 pests are alive in the run, further spawns wait until there is room (keeps phones smooth; never needed by the reference waves).

**Tick order (determinism depends on it).** Each tick:

1. Spawn every scheduled pest whose time has come, in schedule order (sorted by spawn time, then group order).
2. For each pest in list order: update burrow phase; move `d += speed * speedMod * (1 - slow) * TICK` (slow counts only while its timer is above 0); count down the slow timer; regenerate if it regenerates and is not burning (`hp = min(max, hp + regen * TICK)`); burning: add TICK to the burn clock and, each time it reaches 0.5 s, deal `burnDps * 0.5` fire damage (no armour, resist applies); count down the burn timer.
3. Leaks: every pest with `d >= L` is removed and costs its `leak` hearts. If hearts are 0 or less, at the end of this tick the run either ends (phase `over`, lost) or, when `config.secondWindAllowed` is true and Second Wind was not used this run and the wave number is at least 3, pauses (phase `lostPending`, no ticks run) until `secondWind()` or `giveUp()` is called.
4. Plants act in placement order (see attacks below).
5. Every pest with `hp <= 0`: add `round(reward * sapMult)` Sap, remove it, and if it splits, add its children at `d - 0.3 * k` (k = 0, 1, 2, never below 0) with full health.

A wave ends when every scheduled pest has spawned and none are alive. Then, in this order: wave number goes up by 1; Sap += `25 + 5 * waveNumber`; every plant with growth left loses 1; every grown Sunpetal pays its income. If that was the last wave of a fixed field, the run is won. The weekly field has 40 waves and the run ends only on a loss or after wave 40.

**Plants.** Placed on a tile that is inside the grid, not a path tile and empty. A new plant starts with `growth = max(0, seed.growth - growthBonus)` and attacks at once. While `growth > 0` it is a **seedling**: damage x0.5, and a seedling Mint Mist or Sunpetal does nothing. Cooldown starts at 0 (fires straight away).

**Attacks.** For each plant with a rate above 0: subtract TICK from its cooldown; if still above 0, skip. Range = `seed.range + levelRangeBonus + researchRange + modifierRange`. Candidates are pests within range (Euclidean, tile units, `<= range + 1e-9`) that the plant can target: flying pests only if the seed hits flying; hidden pests only if the seed detects, or the pest is inside the range of a grown Mint Mist. If no candidates, skip (the cooldown stays at or below 0, so it fires the moment a pest arrives). Otherwise set cooldown to `1 / (rate * (1 + researchRate) * (1 + mintBuff))`, where `mintBuff` is the largest buff of any grown Mint Mist whose range covers the plant (no stacking, a Mint never buffs itself), then:

- **Aura** (Nettle Patch): every candidate takes the hit as damage over time (armour ignored, resist applies).
- **Single target**: pick the target by the plant's mode: `first` (largest `d`, the default), `last` (smallest `d`), `strong` (highest current health), `close` (nearest to the plant). Ties go to the pest that spawned first.
- **Splash** (Pumpkin Mortar): every non-flying pest within 1.0 tile of the target's position takes a direct hit (hidden ones only if inside a Mint Mist's range), including the target.
- **Slow** (Burr Vine): the target's slow becomes the larger of its current slow and 0.30, with its timer reset to 2.0 s.
- **Burn** (Chilli Burner): the target's burn becomes `6 * levelDmg * (1 + researchDmg) * seedlingFactor` damage per second, timer reset to 3.0 s (refreshes, never stacks).

**Damage.**

```
base   = seed.damage * LEVEL_DMG[level] * (1 + researchDmg) * seedlingFactor * vsMult
vsMult = seed.airMult if the target flies, seed.heavyMult if the target is Heavy, else 1
typed  = base * pest.resist[seed.damageType] (default 1) * (1.3 if fire and Heatwave)
direct hit: final = max(1, typed - (pest.armour + modifierArmour))
damage over time (aura, burn): final = typed, no armour, no minimum
```

`LEVEL_DMG = {1.0, 1.4, 1.9}`, `LEVEL_RANGE_BONUS = {0, 0, 0.5}`, `seedlingFactor` is 0.5 while growing.

**Burrowing** (Mole): a clock starts at spawn; the mole is hidden while `clock mod 5.0 < 3.0` (3 seconds under, 2 seconds up).

**Upgrades.** Level 1 to 2 costs `round(0.6 * seed.cost)`, level 2 to 3 costs `seed.cost`. Maximum level 3.

**Selling.** Refund `floor(0.6 * totalSpentOnPlant)`. **Undo:** a plant placed during the current build phase, before Start wave, refunds 100%.

**Hearts.** 20 at start (plus research). A leaked pest costs its `leak` value. Second Wind (section 5.1) sets hearts to 10 and resumes the wave where it stopped (pests on the path stay), once per run, solo, fixed fields only.

### 3.2 Seeds (10)

`air` = can target flying pests. Rate is attacks per second. Range is in tiles. Upgrade costs follow 3.1 (level 2 cost shown).

| id | Name | Cost | Grows (waves) | Damage | Range | Rate | Type | Air | Special | Lvl 2 cost | Unlock rule |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `thorn` | Thorn Sprout | 60 | 0 | 8 | 2.5 | 1.0 | pierce | yes | none | 36 | Start |
| `sunpetal` | Sunpetal | 75 | 1 | 0 | 0 | 0 | none | no | Pays 20 / 30 / 45 Sap at each wave end once grown (by level) | 45 | Start (card shown from tutorial step at wave 2) |
| `burr` | Burr Vine | 70 | 1 | 3 | 2.0 | 1.2 | pierce | no | Slows 30% for 2 s | 42 | First time you clear wave 3 of Backyard Patch (usable from the wave 4 build phase) |
| `nettle` | Nettle Patch | 90 | 1 | 3 | 1.5 | 2.0 | poison | no | Aura: hits every pest in range, ignores armour | 54 | Research L2 |
| `dandelion` | Dandelion Lofter | 100 | 1 | 8 | 4.0 | 1.4 | pierce | yes | x2 damage to flying | 60 | Clear Backyard Patch |
| `pumpkin` | Pumpkin Mortar | 130 | 2 | 22 | 3.5 | 0.4 | blunt | no | Splash 1.0 tile, ground only | 78 | Research L1 |
| `mint` | Mint Mist | 110 | 1 | 0 | 1.5 | 0 | none | no | Plants in range +15 / 20 / 25% rate; reveals hidden pests in range | 66 | Clear Veggie Rows |
| `chilli` | Chilli Burner | 150 | 2 | 6 | 2.5 | 0.8 | fire | yes | Burn 6 per second for 3 s, ignores armour | 90 | Research L4 |
| `snapjaw` | Snapjaw | 170 | 2 | 55 | 1.5 | 0.4 | bite | no | x2 damage to Heavy pests | 102 | First time you clear wave 7 of Veggie Rows (usable from wave 8) |
| `oak` | Oak Sentinel | 320 | 3 | 30 | 4.5 | 0.8 | pierce | yes | Detects hidden pests (for itself only) | 192 | Research L7 |

Seed rationale (damage per second per 100 Sap at level 1, before armour): Thorn 13.3 (cheap, weak to armour: 1 damage a hit on a beetle), Dandelion 11.2 (22.4 on flyers), Snapjaw 12.9 (25.9 on Heavy), Pumpkin 6.8 per target but splashes, Chilli about 7 plus burn that ignores armour and stops regeneration, Nettle 6.7 per target on every pest in range, Oak 7.5 with the longest reach and detection. Every pest in 3.3 has at least one seed that counters it.

Names and art are our own; do not copy names or looks from other plant defence games (for example no "Peashooter"), because lookalike games lose reach (research 2.3).

### 3.3 Pests (10)

Speed is tiles per second. `leak` = hearts lost if it reaches the shed. Resist multiplies damage of that type (below 1 resists, above 1 is weak). Threat and minimum wave are used only by the weekly generator.

| id | Name | Health | Speed | Reward (Sap) | Leak | Armour | Resist | Traits | Threat | Min wave |
|---|---|---|---|---|---|---|---|---|---|---|
| `aphid` | Aphid | 18 | 1.2 | 3 | 1 | 0 | none | none | 2 | 1 |
| `ant` | Ant | 34 | 1.0 | 4 | 1 | 0 | none | none | 3 | 1 |
| `snail` | Snail | 110 | 0.5 | 8 | 2 | 2 | poison 1.5 | Heavy | 8 | 2 |
| `moth` | Moth | 36 | 1.4 | 5 | 1 | 0 | none | Flying | 4 | 3 |
| `caterpillar` | Caterpillar | 140 | 0.8 | 10 | 2 | 0 | fire 1.5 | Regenerates 4 per second unless burning | 10 | 4 |
| `beetle` | Beetle | 200 | 0.7 | 12 | 3 | 5 | pierce 0.75, blunt 1.25 | Heavy | 16 | 5 |
| `wasp` | Wasp | 70 | 1.7 | 8 | 2 | 0 | poison 0.5 | Flying | 7 | 6 |
| `mole` | Mole | 170 | 0.8 | 14 | 3 | 1 | blunt 1.25 | Burrows: hidden 3 s, up 2 s | 14 | 5 |
| `slugmum` | Slug Matriarch | 280 | 0.5 | 18 | 4 | 0 | fire 0.5, poison 1.5 | Heavy; splits into 3 aphids | 26 | 8 |
| `possum` | Night Possum (boss) | 2600 | 0.45 | 150 | 20 | 4 | fire 0.75, bite 1.25 | Heavy; boss health bar | 200 | boss waves only |

### 3.4 Fields (3 hand made)

Maps: `E` entry (first waypoint), `X` the shed (last waypoint), `#` path, `.` plantable. Columns 0 to 11 shown as `0..9 A B`.

**Field 1: Backyard Patch** (`backyard`). Waypoints `(0,1) (9,1) (9,4) (2,4) (2,6) (11,6)`. Route length 30 tiles, 31 path tiles, 65 plantable. `startSap = 200`, `hpScale = 1.0`, 10 waves. Unlock: always open. Petals: 2 per wave, clear bonus 20, first clear 50.

```
    x 0 1 2 3 4 5 6 7 8 9 A B
  y0 . . . . . . . . . . . .
  y1 E # # # # # # # # # . .
  y2 . . . . . . . . . # . .
  y3 . . . . . . . . . # . .
  y4 . . # # # # # # # # . .
  y5 . . # . . . . . . . . .
  y6 . . # # # # # # # # # X
  y7 . . . . . . . . . . . .
```

| Wave | Groups (pest x count, every gap seconds, from start seconds) |
|---|---|
| 1 | aphid x4 every 1.5 from 0 |
| 2 | aphid x8 every 1.0 from 0 |
| 3 | ant x6 every 1.2 from 0; aphid x4 every 1.0 from 4 |
| 4 | ant x10 every 1.0 from 0 |
| 5 | snail x2 every 4.0 from 0; aphid x8 every 0.8 from 2 |
| 6 | ant x12 every 0.8 from 0; snail x2 every 3.0 from 6 |
| 7 | caterpillar x3 every 3.0 from 0; ant x8 every 0.8 from 2 |
| 8 | snail x5 every 2.5 from 0; aphid x12 every 0.6 from 1 |
| 9 | caterpillar x4 every 2.5 from 0; ant x14 every 0.7 from 1 |
| 10 | beetle x2 every 5.0 from 0; snail x4 every 2.0 from 2; ant x12 every 0.6 from 4 |

**Field 2: Veggie Rows** (`veggie`). Waypoints `(0,3) (3,3) (3,0) (6,0) (6,6) (9,6) (9,2) (11,2)`. Route 24 tiles, 25 path tiles, 71 plantable. `startSap = 300`, `hpScale = 1.2`, 15 waves. Unlock: clear Backyard Patch. Petals: 3 per wave, clear 40, first clear 100. Introduces flying pests (wave 3).

```
    x 0 1 2 3 4 5 6 7 8 9 A B
  y0 . . . # # # # . . . . .
  y1 . . . # . . # . . . . .
  y2 . . . # . . # . . # # X
  y3 E # # # . . # . . # . .
  y4 . . . . . . # . . # . .
  y5 . . . . . . # . . # . .
  y6 . . . . . . # # # # . .
  y7 . . . . . . . . . . . .
```

| Wave | Groups |
|---|---|
| 1 | ant x8 every 1.2 from 0 |
| 2 | aphid x14 every 0.7 from 0; ant x4 every 1.0 from 5 |
| 3 | moth x6 every 1.2 from 0; ant x8 every 1.0 from 2 |
| 4 | snail x4 every 2.5 from 0; moth x6 every 1.0 from 3 |
| 5 | caterpillar x4 every 2.0 from 0; ant x12 every 0.7 from 1 |
| 6 | moth x12 every 0.8 from 0; aphid x12 every 0.6 from 2 |
| 7 | beetle x3 every 3.5 from 0; ant x14 every 0.6 from 2 |
| 8 | wasp x6 every 1.5 from 0; snail x5 every 2.0 from 1 |
| 9 | caterpillar x6 every 1.8 from 0; moth x10 every 0.8 from 2 |
| 10 | slugmum x2 every 6.0 from 0; ant x16 every 0.5 from 2 |
| 11 | beetle x5 every 2.5 from 0; wasp x8 every 1.2 from 3 |
| 12 | slugmum x3 every 4.0 from 0; moth x14 every 0.6 from 1 |
| 13 | caterpillar x8 every 1.5 from 0; wasp x10 every 1.0 from 2 |
| 14 | beetle x7 every 2.0 from 0; slugmum x3 every 4.0 from 4; aphid x20 every 0.4 from 1 |
| 15 | wasp x16 every 0.7 from 0; beetle x6 every 2.0 from 2; slugmum x3 every 3.5 from 6 |

**Field 3: Night Orchard** (`orchard`). Waypoints `(11,1) (1,1) (1,3) (8,3) (8,6) (0,6)`. Route 30 tiles, 31 path tiles, 65 plantable. `startSap = 400`, `hpScale = 1.1`, 20 waves. Unlock: clear Veggie Rows. Petals: 4 per wave, clear 70, first clear 200. Introduces moles (wave 3) and the possum boss (waves 10 and 20). Night lighting is cosy (lanterns, fireflies), never scary.

```
    x 0 1 2 3 4 5 6 7 8 9 A B
  y0 . . . . . . . . . . . .
  y1 . # # # # # # # # # # E
  y2 . # . . . . . . . . . .
  y3 . # # # # # # # # . . .
  y4 . . . . . . . . # . . .
  y5 . . . . . . . . # . . .
  y6 X # # # # # # # # . . .
  y7 . . . . . . . . . . . .
```

| Wave | Groups |
|---|---|
| 1 | ant x10 every 1.0 from 0 |
| 2 | snail x3 every 2.5 from 0; aphid x10 every 0.7 from 2 |
| 3 | mole x3 every 3.0 from 0; ant x10 every 0.8 from 1 |
| 4 | moth x10 every 0.8 from 0; caterpillar x3 every 2.5 from 2 |
| 5 | mole x5 every 2.5 from 0; snail x4 every 2.0 from 2 |
| 6 | beetle x4 every 3.0 from 0; wasp x6 every 1.2 from 2 |
| 7 | slugmum x3 every 4.0 from 0; mole x4 every 2.5 from 2 |
| 8 | caterpillar x8 every 1.5 from 0; moth x12 every 0.7 from 1 |
| 9 | beetle x6 every 2.5 from 0; mole x6 every 2.0 from 2 |
| 10 | possum x1 from 0; ant x20 every 0.6 from 2 |
| 11 | wasp x14 every 0.7 from 0; slugmum x3 every 4.0 from 2 |
| 12 | mole x10 every 1.5 from 0; beetle x5 every 2.5 from 3 |
| 13 | caterpillar x10 every 1.2 from 0; wasp x10 every 0.9 from 2 |
| 14 | slugmum x5 every 3.0 from 0; beetle x7 every 2.0 from 1 |
| 15 | mole x12 every 1.2 from 0; moth x16 every 0.5 from 1 |
| 16 | beetle x10 every 1.6 from 0; wasp x14 every 0.7 from 2 |
| 17 | slugmum x6 every 2.5 from 0; mole x10 every 1.4 from 2 |
| 18 | caterpillar x14 every 1.0 from 0; beetle x8 every 1.8 from 2; wasp x12 every 0.8 from 4 |
| 19 | mole x14 every 1.0 from 0; slugmum x6 every 2.5 from 2; beetle x8 every 1.6 from 4 |
| 20 | possum x2 every 12 from 0; beetle x10 every 1.5 from 2; wasp x14 every 0.7 from 6; mole x10 every 1.2 from 8 |

**Frost mode** (any field, after clearing Night Orchard): pest health x1.4 on top of `hpScale`, Petals x1.5 (per wave and clear bonus), first Frost clear bonus 100 / 150 / 250. Icy blue tint and frost on tiles.

### 3.5 Modifiers (weekly field)

| id | Name | Effect | Conflict group |
|---|---|---|---|
| `drought` | Drought | Pest Sap rewards x0.75; start Sap +100 | econ |
| `bloom` | Bloom | Sunpetal income x2 | econ |
| `rainy` | Rainy week | Growth times 1 wave shorter (minimum 0) | growth |
| `heatwave` | Heatwave | Fire damage x1.3; pests 10% faster | tempo |
| `fog` | Fog | All plant ranges -0.5 tiles | sight |
| `swarm` | Swarm | Group counts x1.5 (floor, at least 1, applied by the generator); pest health x0.7 | tempo |
| `ironshell` | Ironshell | All pests +2 armour | armour |
| `nightshift` | Night shift | Moles can appear from wave 2; Mint Mist range +0.5 | sight |

Two modifiers per week, never from the same conflict group.

### 3.6 Weekly field generator (deterministic from the ISO week)

`WeeklyField.generate(isoYear, isoWeek)` returns a field definition in the same shape as the fixed fields plus `title`, `modifiers`, `featured`, `levelSoil = true`. Same input, same output, on any machine. Draws must happen in exactly this order.

**ISO week** (`IsoWeek.fromUnix(t)`), pure arithmetic, UTC: `days = floor(t / 86400)`; weekday `wd = ((days + 3) % 7) + 1` (Monday 1, Sunday 7; 1 January 1970 was a Thursday); `thursday = days - (wd - 1) + 3`; `isoYear` = calendar year of day `thursday` (use the days to civil date algorithm); `isoWeek = floor((thursday - daysFromCivil(isoYear, 1, 1)) / 7) + 1`. Week key string `"2026-W44"` (two digit week). The week starts Monday 00:00 UTC: `weekStart = (days - (wd - 1)) * 86400`, next reset `weekStart + 604800`.

**PRNG** (`Prng.new(isoYear, isoWeek)`), xorshift32 with `bit32`:

```
state = ((isoYear * 100 + isoWeek) * 2654435761) % 4294967296   -- exact in doubles
if state == 0 then state = 0x9E3779B9 end
next():  x = state
         x = bit32.bxor(x, bit32.lshift(x, 13))
         x = bit32.bxor(x, bit32.rshift(x, 17))
         x = bit32.bxor(x, bit32.lshift(x, 5))
         state = x; return x
int(n):  return (next() % n) + 1                 -- 1 to n
warm up: call next() 8 times inside new(), results discarded
```

**Data used by the generator** (`WeeklyField.luau` holds these exactly):

- `TEMPLATES` (index 1 to 6): Long S `(0,1) (10,1) (10,3) (1,3) (1,5) (10,5) (10,7)`; Hook `(0,4) (5,4) (5,1) (9,1) (9,6) (11,6)`; Zig `(0,0) (3,0) (3,4) (6,4) (6,1) (9,1) (9,7)`; Spiral `(11,0) (1,0) (1,6) (9,6) (9,2) (4,2) (4,4)`; Short U `(0,2) (8,2) (8,5) (0,5)`; Comb `(0,6) (2,6) (2,1) (5,1) (5,6) (8,6) (8,1) (11,1)`. Route lengths 34, 19, 22, 35, 19, 26 tiles.
- `MODIFIERS` in the order of the table in 3.5.
- `ADJECTIVES` (16): Dewy, Sunny, Misty, Windy, Frosty, Golden, Muddy, Leafy, Breezy, Rusty, Mossy, Dusty, Rainy, Sleepy, Prickly, Bright.
- `NOUNS` (16): Paddock, Orchard, Allotment, Meadow, Hedgerow, Glasshouse, Courtyard, Vineyard, Creekbed, Verandah, Backyard, Terrace, Nursery, Clearing, Plot, Gully.
- `POOL` (7, in this order): snail, moth, caterpillar, beetle, wasp, mole, slugmum.
- `BUDGET` (threat points for waves 1 to 40; a table, not a formula, so floats cannot drift): `30, 34, 40, 46, 54, 63, 73, 84, 98, 114, 132, 153, 178, 206, 239, 277, 322, 374, 433, 503, 583, 677, 785, 911, 1057, 1226, 1422, 1650, 1914, 2220, 2575, 2987, 3465, 4020, 4663, 5409, 6274, 7278, 8443, 9794` (this is `floor(30 * 1.16^(n-1))`).

**Steps:**

1. `template = TEMPLATES[int(6)]`.
2. `mirror = (int(2) == 2)`; if mirrored, every waypoint `x` becomes `11 - x`.
3. `mod1 = MODIFIERS[int(8)]`; `allowed` = MODIFIERS without mod1's conflict group (original order); `mod2 = allowed[int(#allowed)]`.
4. `title = ADJECTIVES[int(16)] .. " " .. NOUNS[int(16)]`.
5. Shuffle a copy of POOL with Fisher and Yates: for `i = 7` down to `2`: `j = int(i)`; swap `pool[i]` and `pool[j]`. `featured = {"aphid", "ant", pool[1], pool[2], pool[3], pool[4]}`.
6. Minimum waves come from 3.3; with Night shift, mole's is 2.
7. For each wave `n = 1` to 40:
   - `B = BUDGET[n]`, `rem = B`, `groups = {}`.
   - Boss: if `n % 15 == 0`, `boss = n / 15` possums; `rem = B - boss * 200`; if `rem < floor(B * 0.3)` then `rem = floor(B * 0.3)`; add group `{possum, boss}` first.
   - `allowedP` = featured pests (in featured order) whose minimum wave is `<= n`. If `n >= 12` and removing aphid and ant leaves at least one, remove them.
   - `p1 = allowedP[int(#allowedP)]`, then `p2 = allowedP[int(#allowedP)]`.
   - If `p1 == p2`: one group `{p1, max(1, floor(rem / threat(p1)))}`. Else `c1 = max(1, floor(0.6 * rem / threat(p1)))`, `c2 = max(1, floor((rem - c1 * threat(p1)) / threat(p2)))`, groups `{p1, c1}`, `{p2, c2}`.
   - If Swarm: every non possum group's count becomes `max(1, floor(count * 1.5))`.
   - For each group at index `k` (0 based): if count is over 40, `hpMult = floor(100 * count / 40) / 100` and count = 40, else `hpMult = 1`. Gap: possum 12.0; others `max(0.4, min(2.5, floor(10 * 12 / count + 0.5) / 10))`. Start `= 2.0 * k`.
8. Field values: `startSap = 350` (plus Drought), `hpScale = 1.0`, Petals 3 per wave cleared, +10 every 5th wave cleared, +100 on your first weekly run of the week.

**Level soil** (weekly runs only): every seed unlocked; loadout of 6 for everyone; research ignored and replaced by fixed bonuses: damage +10%, rate +5%, Sap from pests +10%, hearts 20, range +0; speed at most 1.5x for everyone; Second Wind disabled; solo runs only post to the leaderboard. This keeps the leaderboard free of paid or time bought advantage (research 3, brief rule).

**Score** = `wavesCleared * 100 + heartsLeft` (integer, at most 4,020).

### 3.7 Balance rationale and targets

The rules above were run in the prototype with three research levels: **R0** (no research), **RMID** (start Sap +50, Sap +10%, damage +10%, rate +5%; costs 960 Petals including the Pumpkin node, reached around day 4) and **RFULL** (whole tree). The reference build orders are in Appendix B; they obey the 5 seed loadout and place seeds in sensible spots, so they stand in for a careful player.

| Field | R0 | RMID | RFULL | Frost R0 | Frost RMID | Frost RFULL |
|---|---|---|---|---|---|---|
| Backyard Patch | win, 17 hearts | win, 17 | win, 25 | win, 6 | win, 10 | win, 19 |
| Backyard, 3 Thorn Sprouts only | lose wave 9 | lose 9 | lose 10 | lose 7 | lose 8 | lose 9 |
| Veggie Rows | win, 12 hearts | win, 20 | win, 25 | lose 5 | win, 8 | win, 25 |
| Night Orchard | lose wave 9 | win, 17 | win, 25 | lose 5 | lose 6 | win, 25 |

Weekly field, greedy bot (Appendix B) on level soil over the 26 weeks from 2026-W44: median 29 waves cleared, lowest 17, highest 34. Spread is what a leaderboard needs; the possum pair at wave 30 is a deliberate wall.

**Target first attempt win rates for a new human** (to watch in analytics, not provable by tests): Backyard Patch 90% (it is the tutorial; a bad player still wins with hearts lost in wave 10); Veggie Rows 50% at R0, 80% after a few research nodes; Night Orchard 15% at R0, 45% around RMID, 85% at RFULL; Frost Night Orchard 30% at RFULL. Reasons: a first win in session one, a near miss on field 2 (the strongest day 1 pull), and a field 3 that research visibly unlocks, so progress feels earned.

**Tuning knobs, in order of preference:** a field's `hpScale`, then one wave's counts, then a seed's cost. Change seed damage only when a test in 8.1 shows a seed is useless or dominant. Never tune by changing the rules in 3.1.

---

## 4. Economy

### 4.1 In-run currency: Sap

- Start: field `startSap` (200 / 300 / 400; weekly 350) plus research.
- Income: pest rewards (3.3) x Sap multiplier; wave bonus `25 + 5 * waveNumber`; Sunpetal income.
- Spend: plant cost, upgrades (3.1). Sell refunds 60% (100% undo in the same build phase).
- Sap never carries over between runs and is never sold.

### 4.2 Permanent currency: Petals

Earned only by playing; **never sold for Robux** (keeps the shop honest and keeps us far from paid random item rules, research 3).

| Source | Petals |
|---|---|
| Per wave cleared | Backyard 2, Veggie 3, Orchard 4, Weekly 3 (+10 every 5th wave) |
| Clear bonus (win) | 20 / 40 / 70 |
| First clear of a field | 50 / 100 / 200 |
| First Frost clear | 100 / 150 / 250 |
| Frost multiplier | x1.5 on per wave and clear bonus |
| First win of the UTC day | +50% of that run's per wave and clear Petals (rounded down), once a day |
| First weekly run of the week | +100 |
| Loss | Per wave Petals for waves cleared; nothing else |

Duo runs give each player the full amount. `Economy.petalsForRun(result, ctx)` returns the total and a list of lines `{key, amount}` for the results screen.

### 4.3 Research tree (20 nodes, 6,710 Petals)

Three branches; each node needs the one before it in its branch. Bonuses add up.

| id | Branch | Name | Effect | Cost |
|---|---|---|---|---|
| R1 | Roots | Deep Roots I | Start Sap +25 | 40 |
| R2 | Roots | Sweet Sap I | Pest Sap +5% | 80 |
| R3 | Roots | Deep Roots II | Start Sap +25 | 150 |
| R4 | Roots | Sweet Sap II | Pest Sap +5% | 250 |
| R5 | Roots | Deep Roots III | Start Sap +50 | 400 |
| R6 | Roots | Sweet Sap III | Pest Sap +10% | 600 |
| S1 | Stems | Sharp Thorns I | Damage +5% | 60 |
| S2 | Stems | Quick Growth I | Rate +5% | 120 |
| S3 | Stems | Sharp Thorns II | Damage +5% | 200 |
| S4 | Stems | Long Reach | Range +0.25 | 350 |
| S5 | Stems | Sharp Thorns III | Damage +10% | 550 |
| S6 | Stems | Quick Growth II | Rate +5% | 800 |
| L1 | Leaves | Pumpkin Mortar | Unlock seed | 60 |
| L2 | Leaves | Nettle Patch | Unlock seed | 100 |
| L3 | Leaves | Thick Hedge I | Hearts +2 | 150 |
| L4 | Leaves | Chilli Burner | Unlock seed | 250 |
| L5 | Leaves | Fast Sprouting | Growth 1 wave shorter (min 0) | 450 |
| L6 | Leaves | Thick Hedge II | Hearts +3 | 500 |
| L7 | Leaves | Oak Sentinel | Unlock seed | 700 |
| L8 | Leaves | Seed Bag | Loadout slot 6 | 900 |

Roots cost 1,520, Stems 2,080, Leaves 3,110; total 6,710. Full tree bonuses: damage +20%, rate +10%, start Sap +100, Sap +20%, hearts +5, range +0.25, growth -1, slot 6 (this is RFULL in 3.7). For a Big Seed Bag pass owner, L8 shows "Owned" and costs nothing.

### 4.4 Loadout

5 seed slots per run (6 with L8 or the Big Seed Bag pass; 6 for everyone on the weekly field). Set in the Garden Gate before a run; the seed bar shows the loadout in order.

### 4.5 How fast a free player progresses

Model (Tester implements it in `economy.spec.luau` with `Progression.onRunEnd`, 8.1): day 1 Backyard win plus a Veggie loss at wave 8; day 2 two Veggie wins; days 3 and 4 an Orchard loss at wave 9 plus a Veggie win; from day 5 one Orchard win plus one Veggie win a day (about 31 minutes at 1x, 21 at 1.5x); one weekly run to wave 15 each week.

| Day | Petals that day | Total | Milestone |
|---|---|---|---|
| 1 | 134 | 134 | Pumpkin Mortar plus Deep Roots I |
| 3 | 338 | 784 | Most of RMID |
| 5 | 510 | 1,457 | RMID done; Night Orchard cleared |
| 7 | 310 | 2,077 | Fast Sprouting and Long Reach in reach |
| 14 | 310 | 4,422 | About two thirds of the tree |
| 21 | 310 | 6,767 | Whole tree done |
| 28 | 310 | 9,112 | Frost stars and weekly ribbons are the goal now |

So a free player finishes research in about three weeks of 30 to 35 minutes a day, inside the 28 day window discovery measures (research 2.3), with Frost, stars and the weekly field carrying days 21 to 28. Nothing paid shortens this except the Head Gardener daily gift (later update, about +13%) and the Big Seed Bag (saves 900 Petals).

---

## 5. Monetisation

Rules from the research: sell convenience and expression, never power over other players; developer products repeat so monetise better; players downvote monetisation they dislike; timers and appointment mechanics are a poor fit; every purchase recorded by the game; no paid random items (research 3). Creator keeps 70% of Robux spent (research 3). Robux values below are suggestions for the owner to approve (section 11).

### 5.1 At launch (16+ only)

| Item | Kind | Price | What it does | Weekly field | Why this price |
|---|---|---|---|---|---|
| Fast Forward | Game pass | 149 R$ | Adds 2x speed on fixed fields and Frost | Disabled (1.5x cap for all) | Common impulse band for a permanent convenience; about 104 R$ to us. |
| Big Seed Bag | Game pass | 199 R$ | 6th loadout slot now (normally research L8, 900 Petals) | No effect (all have 6) | PvE convenience worth roughly a week of Petals; priced above Fast Forward because it changes strategy. |
| Second Wind | Developer product | 25 R$ | +10 hearts once in a run you just lost (solo, fixed fields, from wave 3) | Not offered | Small repeatable product (research 3). Every player also gets one free Second Wind a day, so it never feels like a paywall. |
| Private server | Private server | 100 R$ a month | Your own server for friends and duo runs | Duo runs never post scores | A paid price matters: Plus subscribers get paid private servers free and the creator is paid up to 100 Robux per subscriber with 60+ minutes there (research 2.2). |

The shop at launch has these four, plus the free cosmetics earned by stars (3 stars, 6, 9) so players see cosmetics exist. The shop never shows a countdown, a fake "was" price or a pop up on join. Purchase prompts only appear when the player taps a Robux price.

### 5.2 Later update (after the game is in Kids and Select)

The research advises adding the subscription and the cosmetics shop in one batched update after clearing the Kids and Select threshold (research 6, recommendation).

| Item | Kind | Price | What it does | Why |
|---|---|---|---|---|
| Head Gardener | Experience subscription | US$2.99 a month (local currency tier) | A gift of 40 Petals a day (claimed on the first run of the day), one exclusive garden theme a month that stays usable while subscribed, a gold watering can icon on your plot sign | Lowest local tier; 70% in month one then 100% after (research 3). Needs ID or phone verification. Fallback: 249 R$ a month (70% every month). Every perk is cosmetic or a small PvE Petal gift a free player earns in one run. |
| Plant skin sets | Game passes | 99 R$ each (Autumn, Neon Night, Aussie Natives) | Recolours and small model changes for all 10 seeds | Cheap, many small choices. |
| Garden themes | Game passes | 149 R$ each (Beach Shack, Snow Gum) | Plot ground, fence, shed and music | Bigger visual change. |
| Roblox Plus prompt | `PromptRobloxSubscriptionPurchase` | Roblox's price | Shown only on the private server panel: "Plus members get private servers free." | Creator is paid 250 Robux a month for three months per new Plus subscriber from our prompt (research 2.2). |
| Rewarded video ad | Optional | Free | Watch an ad for a second free Second Wind a day | Only if the account is eligible (research 3, unverified). |
| Price testing | Dynamic Price Check tool | | Test 99 vs 149 on Fast Forward | Research 3. |

Never at any stage: Petals for Robux, random seed packs or eggs, luck boosts, paid score or leaderboard advantages, "always win" items, trading.

### 5.3 Honest revenue expectation

Using the research's own scenario (300 daily players, 2% buying 100 R$ a day) the game keeps about 12,600 R$ a month, about US$48 at the DevEx rate, and needs about 10 weeks to reach the 30,000 R$ DevEx minimum (research 2.1, 4). Most new games earn far less. Creator Rewards add a little (research 2.2). Treat money as a bonus, not the plan.

---

## 6. Systems and modules

### 6.1 Tooling

- `rokit.toml` (or `aftman.toml`) pins `rojo-rbx/rojo@7.7.1` and `lune-org/lune@0.11.1` (research 5). StyLua and selene are optional.
- `default.project.json`:

```json
{
  "name": "SeedSiege",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": { "Shared": { "$path": "src/shared" } },
    "ServerScriptService": { "Server": { "$path": "src/server" } },
    "StarterPlayer": {
      "StarterPlayerScripts": { "Client": { "$path": "src/client" } }
    }
  }
}
```

- Rojo file names: `*.server.luau` is a Script, `*.client.luau` a LocalScript, anything else a ModuleScript.
- Build: `rojo build -o build/SeedSiege.rbxl`. Publish: `lune run tools/publish.luau` posts the file to `POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Published` with header `x-api-key` from the environment variable `ROBLOX_API_KEY` and `Content-Type: application/octet-stream` (API key permission universe-places, Write; research 5). Ids come from environment variables `SS_UNIVERSE_ID` and `SS_PLACE_ID`. Never commit the key.
- The owner creates the experience once in Studio (Publish to Roblox), turns on "Enable Studio Access to API Services" in Game Settings, Security, for testing saves in Studio, and sets Max players to 8 in Game Settings, Places.

### 6.2 Folder tree

```
seed-siege/
  default.project.json
  rokit.toml
  src/
    shared/
      LogicBundle.luau            -- requires every Logic module, calls bind(L), returns L
      Visuals.luau                -- part recipes and colours per seed, pest, theme (data)
      Net/
        Remotes.luau              -- names and setup/get of RemoteEvents and RemoteFunctions
      Logic/                      -- PURE: no require, no services, no clock
        Constants.luau
        Seeds.luau
        Pests.luau
        Fields.luau
        Modifiers.luau
        Research.luau
        Cosmetics.luau
        Products.luau
        Grid.luau
        Combat.luau
        WaveSim.luau
        Economy.luau
        ResearchTree.luau
        Progression.luau
        Prng.luau
        IsoWeek.luau
        WeeklyField.luau
        Score.luau
        SaveSchema.luau
        SessionLock.luau
        Receipts.luau
        RateLimit.luau
        Validate.luau
        Views.luau
        Tutorial.luau
    server/
      Main.server.luau
      Services/
        DataStoreAdapter.luau
        SaveService.luau
        PlotService.luau
        RunManager.luau
        Broadcaster.luau
        RemoteRouter.luau
        ProgressionService.luau
        WeeklyService.luau
        PurchaseService.luau
        TutorialService.luau
        AnalyticsHooks.luau       -- M4, optional
    client/
      Main.client.luau
      Util/
        Signal.luau
      Controllers/
        StateStore.luau
        CameraController.luau
        BoardRenderer.luau
        PestRenderer.luau
        EffectsController.luau
        PlacementController.luau
      UI/
        Theme.luau
        Components.luau
        Hud.luau
        SeedBar.luau
        Inspector.luau
        GardenGate.luau
        Loadout.luau
        Research.luau
        Shop.luau
        Results.luau
        Leaderboard.luau
        Settings.luau
        TutorialUI.luau
  tests/
    run.luau                      -- finds *.spec.luau, runs them, exits 1 on any failure
    bundle.luau                   -- string requires of src/shared/Logic/*, bind(L)
    assert.luau                   -- eq, near, truthy, throws, deepEq
    fixtures/                     -- saved profiles per schema version, reference scripts
    *.spec.luau
  tools/
    balance-report.luau           -- prints the table in 3.7 from the Luau code
    publish.luau                  -- Open Cloud upload
```

### 6.3 Pure Logic modules (shared/Logic)

Types are written Luau style. All functions are pure unless marked "mutates".

**Constants.** `GRID_W = 12`, `GRID_H = 8`, `TILE_STUDS = 4`, `TICK = 0.1`, `START_HEARTS = 20`, `LOADOUT_BASE = 5`, `LOADOUT_MAX = 6`, `UPGRADE_COST = {0.6, 1.0}`, `LEVEL_DMG = {1.0, 1.4, 1.9}`, `LEVEL_RANGE_BONUS = {0, 0, 0.5}`, `SELL_REFUND = 0.6`, `SEEDLING_DMG = 0.5`, `WAVE_BONUS_BASE = 25`, `WAVE_BONUS_PER = 5`, `MAX_PESTS = 120`, `MAX_PLANTS = 40`, `SPEEDS = {1, 1.5, 2}`, `WEEKLY_MAX_SPEED = 1.5`, `FROST_HP = 1.4`, `FROST_PETALS = 1.5`, `SECOND_WIND_HEARTS = 10`, `SECOND_WIND_MIN_WAVE = 3`, `WEEKLY_WAVES = 40`, `WEEKLY_START_SAP = 350`, `LEVEL_SOIL = {dmg = 0.10, rate = 0.05, sapMult = 0.10, hearts = 0, range = 0, startSap = 0, grow = 0}`, `SCHEMA_VERSION = 1`.

**Seeds, Pests, Fields, Modifiers, Research, Cosmetics, Products.** Frozen data tables (`table.freeze`) exactly as in sections 3 to 5, keyed by id, each with an `order` list. Field shape: `{id, name, waypoints, startSap, hpScale, waves = {{ {pest, count, gap, start, hpMult?} }}, petals = {perWave, clear, firstClear, frostFirstClear}, unlock = {kind, ...}}`. Seed unlock shape: `{kind = "start"} | {kind = "research", node} | {kind = "fieldWave", field, wave} | {kind = "fieldClear", field}` (fieldWave means "cleared that wave at least once"). Products: `{key, kind = "pass" | "product", id = 0, priceHint}`; ids are 0 until the owner creates them in Creator Hub and pastes them in.

**Grid.** `expandPath(waypoints) -> {tiles: {[string]: true}, segments, length}` (tile key `"x,y"`); `positionAt(path, d) -> (x, y)`; `isPathTile(path, x, y)`; `inBounds(x, y)`; `distance(ax, ay, bx, by)`; `coverage(path, x, y, range) -> integer` (path tiles whose centre is in range); `mirror(waypoints) -> waypoints`; `validateField(field) -> ok, errors` (waypoints in bounds, each segment straight, no tile used twice, at least 40 plantable tiles).

**Combat.** `hitDamage(seed, level, bonuses, isSeedling, pest, mods) -> number`; `dotDamage(...)`; `canTarget(seed, pestState, revealed) -> boolean`; `pickTarget(candidates, mode, plantX, plantY) -> pestState?`. Implements 3.1 "Damage" exactly.

**WaveSim.** The heart of the game; server and tests run the same code.

```
WaveSim.new(config) -> Sim
  config = { field, modifiers = {ids}, bonuses = ResearchTree.bonuses(...) or LEVEL_SOIL,
             loadout = {seedIds}, hpExtra = 1 (1.4 for Frost), weekly = false,
             secondWindAllowed = solo and not weekly }
sim:place(seedId, x, y) -> (ok, errCode | plantId)        mutates
sim:upgrade(plantId) -> (ok, errCode)                     mutates
sim:sell(plantId) -> (ok, errCode | refund)               mutates
sim:setTargetMode(plantId, mode) -> (ok, errCode)         mutates
sim:startWave() -> (ok, errCode)                          mutates
sim:step()                                                one TICK, mutates
sim:runUntilPhaseChange(maxTicks) -> phase                 test helper
sim:secondWind() -> (ok, errCode)                         from lostPending: hearts = 10, phase back to wave, mutates
sim:giveUp()                                               from lostPending: phase over (lost), mutates
sim:getState() -> SimState                                 copy safe for views
sim:drainEvents() -> {Event}                               spawned, shot, defeated, leaked, waveEnded, runEnded
```

Phases: `build`, `wave`, `lostPending`, `over`. Error codes: `bad_seed`, `not_in_loadout`, `out_of_bounds`, `on_path`, `tile_taken`, `no_sap`, `too_many_plants`, `max_level`, `no_plant`, `bad_mode`, `wrong_phase`, `run_over`, `second_wind_used`. Plant and pest ids are integers counting up from 1 per run.

**Economy.** `upgradeCost(seedId, level)`, `sellValue(plant, phaseInfo)`, `waveBonus(n)`, `petalsForRun(result, ctx) -> (total, lines)` where `result = {fieldId, mode = "normal" | "frost" | "weekly", won, wavesCleared, heartsLeft, duo}` and `ctx = {firstClear, firstFrostClear, firstWinToday, firstWeeklyRunThisWeek}`.

**ResearchTree.** `canBuy(research, nodeId, petals) -> (ok, reason)`; `bonuses(research, ownsBigSeedBag) -> Bonuses`; `nextNodes(research) -> {nodeId}`.

**Progression.** `unlockedSeeds(profile) -> {[seedId]: true}`; `unlockedFields(profile)`; `canStart(profile, fieldId, mode) -> (ok, reason)`; `onWaveCleared(profile, fieldId, waveNumber) -> (profile, newUnlocks)` (Burr and Snapjaw unlock mid run); `onRunEnd(profile, result, ctx) -> (profile, summary)` with `ctx = {now, dayKey, weekKey}`, which updates bests, clears, stars, Petals (via Economy), daily and weekly flags, cosmetics earned from stars and ribbons; `summary = {petals, lines, unlocks, stars, newBest, score?}`. Copies, never mutates its input.

**Prng, IsoWeek, WeeklyField, Score.** As in 3.6. `IsoWeek.fromUnix(t) -> (isoYear, isoWeek)`, `IsoWeek.key(y, w)`, `IsoWeek.storeName(y, w) -> "SS_Weekly_2026W44"`, `IsoWeek.weekStart(t)`, `IsoWeek.nextReset(t)`, `IsoWeek.dayKey(t) -> "2026-10-25"`, `IsoWeek.previous(y, w)`. `WeeklyField.generate(y, w) -> field`. `Score.weekly(wavesCleared, heartsLeft) -> integer`.

**SaveSchema.** `CURRENT = 1`; `default(userId, now) -> Profile`; `migrate(data) -> (Profile, fromVersion)`; `reconcile(profile) -> Profile` (fills missing keys from the default, drops unknown seed and node ids); `validate(profile) -> (ok, errors)`.

**SessionLock.** Pure decisions over the stored value, called inside `UpdateAsync`:
`acquire(stored, jobId, now) -> (newStored | nil, status)` with status `acquired`, `reacquired` (same job), `stolen_stale` (lock older than `LOCK_STALE = 600` seconds) or `locked` (returns nil so no write happens); `refresh(stored, jobId, now) -> (newStored | nil, status)` (`refreshed` or `lost` when another job holds it); `release(stored, jobId) -> newStored` (clears only our own lock).

**Receipts.** `has(profile, purchaseId) -> boolean`; `apply(profile, receiptInfo, products) -> (profile, decision)` where decision is `granted`, `already` or `unknown`; it records `{id, at}` in `profile.receipts` (keeps the newest 200) and adds the grant (Second Wind: `tokens.secondWind += 1`).

**RateLimit.** Token bucket: `new(rate, burst)`; `take(bucket, now) -> (allowed, bucket)`.

**Validate.** `int(v, min, max)`, `str(v, maxLen)`, `oneOf(v, set)`, `seedId(v)`, `tile(x, y)`, `plantId(v)`, `loadout(list, unlocked, slots)`; each returns `(ok, value | errCode)`.

**Views.** `runView(simState, run) -> table` and `profileView(profile, passes) -> table`: the only shapes sent to clients (no receipts, no lock).

**Tutorial.** Step list (section 7.7) and `next(stepState, event) -> stepState` so the tutorial flow is testable.

### 6.4 Server services

| Service | Responsibility | Public functions |
|---|---|---|
| `Main.server` | Start services in order: DataStoreAdapter, SaveService, PurchaseService, PlotService, WeeklyService, ProgressionService, TutorialService, RunManager, Broadcaster, RemoteRouter. | none |
| `DataStoreAdapter` | Wraps `DataStoreService:GetDataStore` and `GetOrderedDataStore`. Retries with backoff (1, 2, 4, 8 s; then give up). In Studio without API access, falls back to an in memory store with the same methods and prints one warning. | `store(name)`, `ordered(name)`, each with `get`, `update(key, fn)`, `getSorted(ascending, pageSize)` |
| `SaveService` | Loads, locks, autosaves (every 90 s, refreshing the lock), saves on leave and on `game:BindToClose` (all players in parallel, within the close time limit). | `load(player) -> profile?`, `get(player)`, `mutate(player, fn)`, `saveNow(player, reason) -> ok`, `onLoaded` signal |
| `PlotService` | Four plots in `Workspace.Plots` (Plot1 to Plot4, spaced apart). Assigns one per run, builds tiles, path, shed and decorations for a field from Parts. | `claim(players) -> plotIndex?`, `release(plotIndex)`, `build(plotIndex, field, theme)`, `tileToWorld(plotIndex, x, y)` |
| `RunManager` | One run per plot. Owns the WaveSim, the tick accumulator on `RunService.Heartbeat` (ticks per frame from speed, at most 6 ticks a frame), applies intents, mid run unlocks, Second Wind, ends runs, calls Progression and WeeklyService. | `start(players, fieldId, mode) -> runId?, err`, `runOf(player)`, `intent(player, kind, args) -> ok, err`, `leave(player)` |
| `Broadcaster` | Sends `RunUpdated` on any change (debounced to 10 a second) and `PestSnapshot` 5 times a second to that run's players only. | `push(run)`, `snapshot(run)` |
| `RemoteRouter` | Creates remotes (Net/Remotes), binds handlers, runs validation and rate limits, wraps every handler in `pcall`, returns `{ok, err, data}`. | `bind(name, schema, limiter, handler)` |
| `ProgressionService` | Research purchase, loadout, cosmetics equip, settings. | `buyResearch`, `setLoadout`, `equip`, `setSettings` |
| `WeeklyService` | Caches this week's field (regenerates on week change), submits scores, caches top 50 for 120 s, checks last week's top 100 for ribbons at join. | `current() -> field, weekKey`, `submit(player, score)`, `top(n)`, `ribbonCheck(player)` |
| `PurchaseService` | `MarketplaceService.ProcessReceipt`, pass ownership cache (`UserOwnsGamePassAsync` at join, updated on `PromptGamePassPurchaseFinished`), prompts. | `owns(player, passKey)`, `prompt(player, key)` |
| `TutorialService` | Server side tutorial state in the profile; first join starts a Backyard run with tutorial on. | `onEvent(player, event)` |
| `AnalyticsHooks` | Optional (M4): tutorial funnel and economy events. Check the current `AnalyticsService` docs first. | `step(player, name)` |

### 6.5 Remotes and validation

All remotes live in `ReplicatedStorage.Remotes`, created by the server. Client to server calls are RemoteFunctions that return `{ok: boolean, err: string?, data: any?}`. The server never invokes a client RemoteFunction.

Every handler first checks: the player's profile is loaded (`not_ready`), types and ranges with `Validate` (`bad_payload`), and the rate limit (`rate_limited`). The server never accepts a cost, a damage, a position other than a tile, a score or a reward from the client.

| Remote | Payload | Rate limit (per player) | Extra server checks |
|---|---|---|---|
| `RequestStart` (RF) | `fieldId: string, mode: "normal" or "frost" or "weekly"` | 1 per 2 s | Field unlocked (`Progression.canStart`); Frost needs Orchard cleared; not already in a run; a plot is free (`no_plot`) |
| `PlaceSeed` (RF) | `seedId: string <= 24, x: int 0..11, y: int 0..7` | 8 a second, burst 10 | In a run, run not over, rest checked by `WaveSim:place` (loadout, tile, Sap, plant cap) |
| `UpgradePlant` (RF) | `plantId: int >= 1` | 8 a second | Plant in this run |
| `SellPlant` (RF) | `plantId: int` | 8 a second | Plant in this run |
| `SetTargetMode` (RF) | `plantId: int, mode: first, last, strong, close` | 8 a second | Plant in this run |
| `StartWave` (RF) | none | 2 a second | Phase is build |
| `SetSpeed` (RF) | `speed: 1, 1.5 or 2` | 2 a second | 2 needs Fast Forward and not weekly; duo runs use the lower of the two players' allowed speeds |
| `UseSecondWind` (RF) | none | 1 a second | Run is in phase `lostPending`, solo, not weekly, wave >= 3, not used this run, and a free daily or a token is available; else the client shows the buy button |
| `LeaveRun` (RF) | none | 1 a second | Ends the run as a loss with waves cleared so far |
| `BuyResearch` (RF) | `nodeId: string` | 2 a second | `ResearchTree.canBuy` |
| `SetLoadout` (RF) | `seedIds: array of 1 to 6 strings` | 1 a second | All unlocked, no repeats, within slots, not during a run |
| `Equip` (RF) | `slot: "plantSkin" or "gardenTheme" or "title", id: string or nil` | 2 a second | Owned (earned, or pass owned) |
| `SetSettings` (RF) | table of known keys only | 1 a second | Each value validated; unknown keys ignored |
| `GetLeaderboard` (RF) | `which: "this" or "last"` | 1 per 5 s | Returns cached top 50 plus the player's own best |
| `TutorialEvent` (RF) | `event: string` from the known list | 4 a second | Tutorial not done; can only advance, never grants anything |
| `PromptPurchase` (RF) | `key: string` | 1 a second | Known product or pass key |
| `Invite` / `AcceptInvite` (RF, M4) | `userId: int` / `hostUserId: int` | 1 a second | Same server, host in build phase of a non weekly run, plot has 1 player |
| `ProfileUpdated` (RE, server to client) | `Views.profileView` | | |
| `RunUpdated` (RE) | `Views.runView`: phase (including `lostPending`), wave, waves total, hearts, sap, speed, plants list, Second Wind options | | |
| `PestSnapshot` (RE) | packed arrays: `pests = {id, typeIndex, dCenti, hpPercent, flags, ...}` (flags 1 hidden, 2 slowed, 4 burning), `shots = {plantId, pestId, ...}`, `gone = {pestId, ...}`, `serverTick` | | |
| `RunEnded` (RE) | `Progression` summary plus result | | |
| `Toast` (RE) | `key, args` | | |
| `TutorialCue` (RE) | `stepId` | | |

Reliable `RemoteEvent` at 5 Hz is the safe default for snapshots; switching to `UnreliableRemoteEvent` is an optimisation only after checking its payload limits in current docs.

### 6.6 DataStore schema, session locking and versioning

Store `SS_Players`, key `u_<userId>`. One value per player, well under the size limit.

```
Profile (schema 1) = {
  schema = 1,
  lock = { jobId = string, at = number } | nil,
  createdAt = number, lastSeenAt = number,
  petals = 0, petalsEarned = 0,
  research = { [nodeId] = true },
  wavesSeen = { [fieldId] = highestWaveClearedEver },
  fields = { [fieldId] = { bestWave = 0, clears = 0, frostClears = 0, best2Star = false } },
  loadout = { "thorn", "sunpetal" },
  weekly = { weekKey = "", bestScore = 0, bestWave = 0, runs = 0, firstRunBonusTaken = false },
  ribbons = { { kind = "wave15" | "wave25" | "wave35" | "top100", weekKey = string } },
  daily = { dayKey = "", firstWinTaken = false, freeSecondWindUsed = false, gardenerGiftTaken = false },
  tokens = { secondWind = 0 },
  cosmetics = { owned = { [cosmeticId] = true }, equipped = { plantSkin = nil, gardenTheme = nil, title = nil } },
  settings = { autoStart = false, speed = 1, music = 0.5, sfx = 0.7, reducedMotion = false, showRanges = true },
  tutorial = { done = false, step = 0 },
  receipts = { { id = string, at = number } },   -- newest 200
  stats = { runs = 0, wins = 0, shooed = { [pestId] = n }, minutes = 0 },
}
```

Seeds unlocked are derived (`Progression.unlockedSeeds`) from `research`, `wavesSeen` and `fields`, never stored, so a data fix in a table fixes everyone.

**Loading.** `UpdateAsync(key, fn)` where `fn(stored)` runs `SessionLock.acquire(stored or SaveSchema.default(...), game.JobId, os.time())`. On `locked`, wait 6 s and try again, up to 5 tries; then kick with "Your garden is still saving in another server. Please rejoin in a minute." After acquiring: `migrate`, then `reconcile`, then `validate` (on failure keep playing but do not save, and log, so we never overwrite good data with bad).

**Saving.** Autosave every 90 s and on leave with `UpdateAsync`, using `SessionLock.refresh`; if the lock was `lost`, do not write and stop autosaving for that player. On leave, `release`. `BindToClose` saves and releases every loaded profile in parallel.

**Versioning.** `schema` goes up by one for any shape change. `SaveSchema.MIGRATIONS[n]` turns version `n` into `n + 1` and must be pure. A save from a newer schema than the code knows is never written to (the server keeps the player read only and logs it), which protects against a rolled back build.

### 6.7 ProcessReceipt idempotency

`MarketplaceService.ProcessReceipt = function(info)`:

1. Find the player by `info.PlayerId`; if absent or the profile is not loaded, return `NotProcessedYet` (Roblox will retry later).
2. If `Receipts.has(profile, info.PurchaseId)`, return `PurchaseGranted`.
3. `newProfile, decision = Receipts.apply(profile, info, Products)`. If `unknown`, log and return `NotProcessedYet`.
4. Save at once with `UpdateAsync` (refreshing the lock). If the save fails or the lock is lost, put the old profile back in memory and return `NotProcessedYet`.
5. Only now apply live effects (a Second Wind token is consumed by the waiting run if the player is at the loss screen), then return `PurchaseGranted`.

Grants are always "add a token", never "do something now", so a retried or late receipt is still safe. Game passes are not stored; Roblox is the source of truth.

### 6.8 Weekly leaderboard (OrderedDataStore)

- One ordered store per week: `SS_Weekly_<isoYear>W<isoWeek two digits>`, for example `SS_Weekly_2026W44`. Key `tostring(userId)`, value the integer score.
- Submit at the end of a **solo** weekly run only if the score beats `profile.weekly.bestScore`: `UpdateAsync(key, function(old) return math.max(old or 0, score) end)`.
- Read: `GetSortedAsync(false, 50)`, cached per server for 120 s; display names cached per server (look up with the Players service; show "Gardener" if the lookup fails).
- Ribbons: at join (once per server per week), read last week's top 100 page; a player in it gets a `top100` ribbon for that week if not already held. Wave ribbons are given by `Progression.onRunEnd`.
- Week changes at Monday 00:00 UTC; a run started before the reset finishes on its own week's field and posts to that week's store.

---

## 7. UI (phone first)

Design for a phone held sideways (landscape, `StarterGui.ScreenOrientation = LandscapeSensor`), reference size 844 by 390 points. A `UIScale` sets `scale = clamp(min(viewW / 844, viewH / 390), 0.75, 1.5)` so tablets and computers enlarge the same layout. Every ScreenGui uses `ScreenInsets = CoreUISafeInsets` so nothing sits under the notch or Roblox's own buttons. Touch targets at least 48 by 48 points at scale 1. Text at least 14 points; numbers that matter (Sap, hearts, cost) 18 points bold. Fonts: one rounded font family (Builder picks from the built in fonts, for example `FredokaOne` for headings and `GothamSSm` or `BuilderSans` for body; check names in the Font list). Colour is never the only signal: a locked or unaffordable card is greyed and shows a lock or the cost with a small "need 20 more".

### 7.1 HUD (during a run)

```
+--------------------------------------------------------------------------+
| [Roblox] [heart 18] [sap 245]       Wave 4 / 15  [=====-----]   [1.5x][=]|
|                                                                          |
|                          (the plot, top down)                            |
|                                                                          |
|  [card][card][card][card][card]                          [ Start wave 5 ]|
+--------------------------------------------------------------------------+
```

- Top left (after Roblox's own button space): hearts and Sap, each an icon plus number; Sap animates when it changes (scale pulse, off with reduced motion).
- Top centre: wave counter and a thin bar showing spawned and remaining pests in the current wave; boss waves show the boss health bar under it.
- Top right: speed button cycling 1x, 1.5x, 2x (2x shows a small lock and opens the Fast Forward card if not owned; hidden on the weekly field); menu button (settings, leave run).
- Bottom right: Start wave button (120 by 56) in build phase, pulsing gently; in wave phase it becomes "Next wave in..." only if Auto start is on, otherwise it is hidden.

### 7.2 Seed bar and placement

- Bottom left: one card per loadout seed (72 by 88): picture, name (short), cost. States: ready, cannot afford (grey, cost plus "need N"), new (small leaf badge).
- Tap a card: it lifts; plantable tiles show a soft outline; path tiles and taken tiles show nothing. Tap a tile: a ghost plant with its range ring appears and the tile shows "Tap again to plant". Tap the same tile: plant. Tap another tile: move the ghost. Tap the card again or the X: cancel. On a computer the ghost follows the mouse and one click plants.
- Seedlings show a small sprout badge "1" (waves left to grow).
- Tap a planted plant: the **inspector** replaces the seed bar: name, level pips, damage, range, rate, special line; buttons Upgrade (cost), Sell (+refund, or "Undo +full" in the same build phase), Target (cycles First, Strong, Last, Close). The range ring shows on the ground. Tap empty ground to close.

### 7.3 Garden Gate (menu between runs)

Camera drifts slowly over the player's plot (static with reduced motion). A left column of cards, a right panel for the selected card.

- Field cards: name, picture, stars (0 to 3), best wave, a lock with the rule ("Clear Backyard Patch"). Buttons Play and Frost (when open).
- Weekly card: the week's title, path picture, two modifier chips with one line each, "New field in 3d 4h", your best and your rank if in the top 50, top 3 names. Play.
- Buttons along the bottom: Loadout, Research (with a dot when you can afford a node), Shop, Leaderboard, Journal (M4), Settings.

### 7.4 Loadout

A grid of all 10 seeds (locked ones show their unlock rule), and the 5 or 6 slots on top. Tap a seed to add it to the first empty slot; tap a slot to remove. Each seed shows icons: sky (hits flying), eye (detects or reveals), splash, slow, fire.

### 7.5 Research tree

Three horizontal rows (Roots, Stems, Leaves), each a chain of round nodes joined by lines; the screen scrolls sideways on a phone. Bought nodes are filled; the next one in each row is outlined and shows its cost; later ones are faint. Tap a node: a detail card on the right with name, effect in plain words ("Every plant hits 5% harder"), cost, your Petals and a Buy button. Petals total at the top.

### 7.6 Shop

Tabs: Passes, Cosmetics, Help (Second Wind and private servers explained). Each item card: picture, name, one line of what it does, where it does not apply ("Not on the weekly field"), the Robux price on the button. Owned items say Owned. No timers, no "best value" badges, no pop ups.

### 7.7 Tutorial prompts

Nan, a small gardener portrait, with a speech bubble of at most 8 words and an arrow pointing at the target. The target pulses; during steps 1 to 3 only the target accepts input, after that everything works and the bubble just suggests. Bubbles go away when the action is done, never on a timer. "Skip tips" (small, top of the bubble) from step 3.

| Step | Trigger | Bubble | Done when |
|---|---|---|---|
| 1 | Run starts | Tap the Thorn Sprout. | Card selected |
| 2 | Card selected | Plant it beside the path. | Plant placed |
| 3 | Plant placed | Start the wave! | Wave 1 started |
| 4 | Wave 1 ended | You earned Sap. Plant another. | Plant placed |
| 5 | Wave 2 build | Sunpetals grow Sap each wave. | Sunpetal placed or wave started |
| 6 | Wave 2 ended | Tap a plant to upgrade it. | Upgrade bought or wave started |
| 7 | Wave 3 ended | Burr Vine slows pests. Try a corner. | Burr placed or wave started |
| 8 | Wave 4 build | Speed up? | Speed changed or wave started |
| 9 | First sight of each new pest type (any run) | One line from that pest's `tip` field | Shown once per pest |
| 10 | First results screen | Spend Petals on research. | Research opened |

### 7.8 Results

Banner "Garden saved!" or "The pests got through". Waves cleared, hearts left, Petals as lines that count up (per wave, clear bonus, first clear, first win today, weekly first run), new unlocks as cards with "New!", stars earned, and on a loss the pest that leaked most with a hint ("Moths flew past. Try a Dandelion Lofter."). Buttons: Play again, Next field (when unlocked), Research (highlighted if a node is affordable), Garden Gate. Weekly runs also show score and rank.

**Second Wind screen** (on a loss in a solo fixed field run from wave 3): "Keep going? +10 hearts" with "Use free Second Wind" if today's is unused, "Use token" if you hold one, otherwise "25 R$"; and "End run". No countdown; the run waits.

---

## 8. Testing

### 8.1 Automatic tests with Lune (Tester)

Run with `lune run tests/run.luau` from the project root; it must exit 1 on any failure and print a short table. Tests require only `tests/bundle.luau` (string requires of `src/shared/Logic`). They must also pass with `--!strict` type checking clean.

| Spec file | What it checks |
|---|---|
| `data.spec.luau` | Every table matches sections 3 to 5 (spot check every number in 3.2 and 3.3); ids unique; every seed unlock refers to a real node, field or wave; every pest has threat and minimum wave; every wave group uses a real pest with count >= 1, gap > 0, start >= 0; `Grid.validateField` passes for all 3 fields and all 6 templates, mirrored and not; route lengths 30, 24, 30 and 34, 19, 22, 35, 19, 26. |
| `grid.spec.luau` | `positionAt` at 0, at each corner and at `L`; path tile sets (count 31, 25, 31); `coverage` known values on Backyard Patch at range 2.5: tile (8, 2) covers 9 path tiles, (3, 5) covers 9, (11, 0) covers 1. |
| `combat.spec.luau` | Damage formula: thorn level 1 on beetle = 1 (8 x 0.75 = 6, minus 5 = 1); thorn on aphid = 8; seedling thorn on aphid = 4; snapjaw on snail = 55 x 2 - 2 = 108; pumpkin on beetle = 22 x 1.25 - 5 = 22.5; dandelion on moth = 16; chilli burn tick on caterpillar = 6 x 1.5 x 0.5 = 4.5; ironshell adds 2 armour; heatwave fire x1.3; minimum 1 on direct hits; aura ignores armour; targeting modes pick the right pest with ties to the earliest spawn. |
| `wavesim.spec.luau` | Rule by rule: tick order; a leak costs `leak` hearts; wave end bonus `25 + 5n`; growth counts down after the bonus; Sunpetal pays only when grown; seedling half damage; mint buff largest, not stacked, not on itself; hidden moles only targetable with Mint range or Oak; slug splits into 3 aphids at `d - 0.3k`; regeneration stops while burning; slow refresh; 120 pest cap; undo refunds 100% only in the same build phase; sell 60%; every error code reachable. **Determinism:** the same build order run twice gives an identical event log (compare a simple hash of the events), and running at 1x or 2x (ticks per frame) gives the same result. **Speed:** a full Night Orchard run finishes in under 2 seconds in Lune. |
| `balance.spec.luau` | With the Appendix B scripts (a step waits until it is affordable; unlock rules ignored, loadouts respected): Backyard R0 wins with >= 12 hearts; Backyard "3 thorns only" R0 loses between waves 7 and 10; Veggie R0 wins with 6 to 18 hearts and RMID with >= 15; Orchard R0 loses before wave 12, RMID wins, RFULL wins with >= 20; Frost Orchard RMID loses and RFULL wins. Weekly greedy bot over the 26 weeks from 2026-W44: median 24 to 32 waves, lowest >= 14, highest <= 38. These bands are wider than the prototype numbers in 3.7 to allow for small differences in the Luau code; if one fails, tune with the knobs in 3.7 and update this file. |
| `weekly.spec.luau` | ISO week vectors (Appendix A); PRNG vectors; generator output for 2026-W44 and 2027-W01 matches Appendix A exactly; 520 weeks from 2026-W44: every field valid, two modifiers from different groups, counts 1 to 40, every featured pest respects its minimum wave, possums only on waves 15, 30, 45, each template picked between 60 and 120 times and mirror between 220 and 300 times. Same input twice gives a deep equal result. |
| `economy.spec.luau` | `petalsForRun` lines for: Backyard first win (20 + 20 + 50 = 90, plus 20 for first win today = 110); a Veggie loss at wave 8 (24); a Frost Orchard win (80 x 1.5 + 70 x 1.5 = 225, plus first Frost clear 250); weekly to wave 15 first run (45 + 30 + 100 = 175). Upgrade costs and sell values for every seed. The pacing model in 4.5 completes the tree on day 19 to 24. |
| `research.spec.luau` | Branch order enforced; cannot buy twice; cannot overspend; full tree bonuses equal RFULL; Big Seed Bag makes L8 free and owned. |
| `progression.spec.luau` | Unlock rules for every seed and field; mid run unlocks of Burr (after wave 3 of Backyard) and Snapjaw (after wave 7 of Veggie); stars; star cosmetics at 3, 6, 9; daily first win once per day key; weekly fields reset on a new week key; ribbons at waves 15, 25, 35; `onRunEnd` does not change its input. |
| `save.spec.luau` | `default` passes `validate`; `migrate` from every fixture in `tests/fixtures/` (at least a schema 0 test save and a schema 1 save) reaches `CURRENT` and passes `validate`; `reconcile` adds missing keys and drops unknown ids; a profile with `schema` above `CURRENT` is reported as too new; round trip through a JSON encode and decode keeps it equal. |
| `lock.spec.luau` | `acquire` on nil, on own lock, on another fresh lock (`locked`, no write), on a stale lock (`stolen_stale`); `refresh` on a lost lock; `release` never clears another job's lock. A fake store with `UpdateAsync` semantics plays two servers racing. |
| `receipts.spec.luau` | Same receipt twice grants once; 201 receipts keep the newest 200; unknown product gives `unknown` and no change; the apply step never mutates its input. |
| `ratelimit.spec.luau`, `validate.spec.luau` | Bucket refill maths; every validator accepts good and rejects bad values (NaN, inf, floats for ints, long strings, wrong types, tables). |
| `tutorial.spec.luau` | Steps advance only on their events, never skip backwards, skip ends cleanly. |

`tools/balance-report.luau` prints the 3.7 table from the Luau code so numbers in this file can be refreshed after any tuning.

### 8.2 What only a human in Studio can judge

Lune does not run a real Roblox game (research 5), so these need eyes and hands: whether it feels good, camera and touch on a real phone, readability of plants and pests, the tutorial pace, sound, frame rate on a cheap phone, purchase prompts, DataStore behaviour across real servers, and whether a 16 year old would keep playing. The Builder and Tester can use the Studio MCP server to start and stop playtests, read the console and take screenshots (research 5), which covers crashes and errors; the owner covers feel.

### 8.3 Owner's 15 minute playtest checklist

Do this in Studio (Test, Play) and then once on your phone through the published game. Tick each line; write a note for any no.

1. (1 min) The game loads with no red errors in the Output window.
2. (3 min) Play the tutorial without reading anything else. Did you always know what to tap next? Did any tip feel like a wall of text?
3. Can you tell the plants apart, and the pests apart, at a glance? Is the path obvious?
4. Placing on the phone: did any plant land on the wrong tile? Was the two tap placement annoying?
5. (4 min) Finish Backyard Patch. Did wave 10 feel tense but fair? Did you lose some hearts?
6. Turn on 1.5x speed. Does anything stutter or jump?
7. Results screen: do the Petals lines make sense? Buy Pumpkin Mortar. Did it appear in Loadout?
8. (3 min) Start Veggie Rows. When moths came, did the game make it clear why some plants ignored them?
9. Leave the game and rejoin. Are your Petals and research still there?
10. Open the Shop. Are the prices clear? Is anything pushy? (Use Studio's test purchase for Second Wind: it should add one, and only one, even if you buy twice quickly.)
11. Open the weekly field card. Does the time to the next field look right for Monday 10 or 11am in Australia?
12. (2 min) On the phone: is any text too small, any button too close to the edge or under Roblox's buttons?
13. Would you play another run right now? Why or why not? (One sentence.)

---

## 9. Build order (milestones)

Each milestone ends with the Lune tests for it passing, a Studio playtest by the Builder through MCP with no errors in the output, and a short note of what was not verified.

**M1: Playable single field.** Logic: Constants, Seeds, Pests, Fields (Backyard only needed, all three data entered), Grid, Combat, WaveSim, Economy (Sap parts), Validate, RateLimit, Views. Server: PlotService (one plot), RunManager, Broadcaster, RemoteRouter with `RequestStart`, `PlaceSeed`, `UpgradePlant`, `SellPlant`, `SetTargetMode`, `StartWave`, `SetSpeed` (1x, 1.5x). Client: board, pests, effects, HUD, seed bar, inspector, results (no Petals yet). No saves (a run starts on join).
*Done when:* a player can play Backyard Patch from start to win or loss on a phone sized Studio emulator; data, grid, combat, wavesim and Backyard balance tests pass; the determinism and speed tests pass; no client can place on a path tile or with too little Sap (tested by calling the remote with bad payloads from the command bar).

**M2: Progression and saves.** Logic: Research, ResearchTree, Progression, SaveSchema, SessionLock, Tutorial, all three fields and Frost. Server: DataStoreAdapter, SaveService, ProgressionService, TutorialService, four plots. Client: Garden Gate, Loadout, Research, tutorial prompts, full results with Petals.
*Done when:* the first session in 2.2 plays as written; Petals and research survive a rejoin; two Studio test servers with the same player prove the lock (the second waits, then loads after the first leaves); save, lock, economy, research, progression, tutorial and full balance tests pass; a fixture from M1 test data migrates.

**M3: Weekly field and leaderboard.** Logic: Prng, IsoWeek, WeeklyField, Score, Modifiers. Server: WeeklyService, OrderedDataStore, ribbons. Client: weekly card, leaderboard screen, modifier chips, level soil rules visible ("Everyone plays with the same plants").
*Done when:* weekly tests match Appendix A exactly; a weekly run posts a score to `SS_Weekly_<week>` and shows in the top list; changing the clock argument to next Monday in a test produces next week's field; speed is capped at 1.5x and Second Wind is absent on the weekly field.

**M4: Shop and polish.** Logic: Products, Cosmetics, Receipts. Server: PurchaseService (passes, Second Wind, private server info), duo invites, optional AnalyticsHooks. Client: Shop, star cosmetics, Journal, settings (music, sound, reduced motion), sounds, juice (planting pop, pest poof), boss bar, phone layout pass, a 16:9 thumbnail and icon from real gameplay (research 3: thumbnails must show the real game).
*Done when:* receipt tests pass and a Studio test purchase of Second Wind twice grants twice and a replayed receipt grants nothing; passes work after purchase without rejoining; duo run works with two Studio test players; the owner's checklist in 8.3 has no "no" left on items 1 to 12; maturity questionnaire answered; game published to 16+ (research 2.4).

After launch (not a milestone of this plan): two weeks of watching D1, session length and the field 2 loss wave in Creator Analytics; then small Ads Manager Engagement campaigns; then the Kids and Select application; then the 5.2 update.

---

## 10. Risks and how the plan reduces them

| Risk | Why it matters | What the plan does |
|---|---|---|
| Players finish content fast (research 6) | Tower defence players expect new units | 28 days of research, stars and Frost; an endless weekly field every week with no human work; content is data so AI can add seeds and pests in batches, checked by `balance.spec`. |
| Balance is wrong | Too hard loses day 1, too easy loses day 7 | Prototype numbers, reference scripts and bot bands in Lune; three tuning knobs in a fixed order; analytics targets in 3.7. |
| Small 16+ first audience (research 2.4) | Fewer players to learn from; threshold for Kids and Select unclear | Designed for teens and adults first; no child only tone; Engagement ads only after D1 looks healthy (research 2.5); owner checks the threshold on the dashboard. |
| Owner has 30 minutes a week | No live ops | Weekly field automatic; no events to run; no moderation needs (no free text); checklist in 8.3 is 15 minutes. |
| Lost or duplicated saves or purchases | Trust and refunds | Session lock, versioned migrations, never write unvalidated or newer schema data, receipts stored and saved before granting. |
| Cheating on the leaderboard | Ruins the weekly field | Server runs the simulation; the client sends only taps; score computed on the server; level soil; solo only; rate limits. |
| Phones lag | Most players are on phones | 120 pest cap, Part models, 5 Hz snapshots, client interpolation, at most 6 ticks a frame, reduced motion option. |
| Logic differs between Lune and Roblox | Tests pass but the game differs | Same Luau files in both; no services in Logic; integer budget table; one rounding rule; xorshift with `bit32`. |
| Lookalike or IP trouble (research 2.3) | Lower reach, takedowns | Own names (no "Peashooter"), own art, garden theme without copying Grow a Garden's look; thumbnails show real gameplay. |
| Monetisation backlash (research 3) | Downvotes hurt discovery | Four honest items at launch; no Petals for Robux; no timers; prices visible; the weekly field cannot be bought. |
| Maturity label creep | Blocks Kids and Select | Cartoon shooing only, no blood, no scary night, no free text, no random paid items; questionnaire answered truthfully. |
| Publishing pipeline breaks | Owner cannot update | Avoid unions and SurfaceAppearance (research 5); first publish from Studio; key in an environment variable. |
| Roblox details we could not confirm | Code that relies on them may break | Listed in section 0; the plan uses safe defaults and asks the Builder to check docs first. |
| AI cannot judge feel (research 6) | A correct game can still be dull | Owner's checklist; Nan tips limited to 8 words; juice in M4; watch first play bounce in analytics. |

## 11. Decisions for the owner

1. Approve prices: Fast Forward 149 R$, Big Seed Bag 199 R$, Second Wind 25 R$ (with one free a day), private server 100 R$ a month.
2. Sell Big Seed Bag at launch, or hold it for the later update.
3. For Kids and Select later: pay the refundable 1,000 Robux fee per game or keep two months of Plus (research 2.4).
4. Head Gardener subscription later: US$2.99 local currency (needs ID or phone verification) or 249 R$.
5. Weekly reset at Monday 00:00 UTC (10am or 11am in eastern Australia), or another time.
6. Name check: search Roblox for existing games called "Seed Siege" before the first publish (not checked in our research).
7. Mascot name "Nan" and the Australian backyard flavour.
8. Server size 8 players (4 plots), and whether duo co-op ships in M4 or after launch.

---

## Appendix A: test vectors

**ISO week** (Unix seconds, UTC):

| Time | Unix | Week key | Week start | Next reset |
|---|---|---|---|---|
| 2026-10-25 23:59:59 | 1792972799 | 2026-W43 | 1792368000 | 1792972800 |
| 2026-10-26 00:00:00 | 1792972800 | 2026-W44 | 1792972800 | 1793577600 |
| 2026-12-31 12:00:00 | 1798718400 | 2026-W53 | 1798416000 | 1799020800 |
| 2027-01-01 00:00:00 | 1798761600 | 2026-W53 | 1798416000 | 1799020800 |
| 2027-01-04 00:00:00 | 1799020800 | 2027-W01 | 1799020800 | 1799625600 |
| 2028-01-02 23:59:59 | 1830470399 | 2027-W52 | 1829865600 | 1830470400 |
| 2028-01-03 00:00:00 | 1830470400 | 2028-W01 | 1830470400 | 1831075200 |
| 2024-12-30 00:00:00 | 1735516800 | 2025-W01 | 1735516800 | 1736121600 |

**PRNG** for (2026, 44): seed state before warm up 3776201044; state after the 8 warm up calls 1275758089; the next three `next()` values 2243864044, 1902289101, 2316917872. A fresh `Prng.new(2026, 44)` then `int(6)` returns 5.

**Generator, 2026-W44:** template Short U (index 5), mirrored, waypoints `(11,2) (3,2) (3,5) (11,5)`; modifiers drought, swarm; title "Sleepy Orchard"; featured aphid, ant, snail, beetle, caterpillar, wasp. Waves (pest, count, gap, start, hpMult):
- 1: ant 15, 0.8, 0, 1.0
- 2: ant 9, 1.3, 0, 1.0; aphid 12, 1.0, 2, 1.0
- 3: aphid 18, 0.7, 0, 1.0; ant 7, 1.7, 2, 1.0
- 15: possum 1, 12, 0, 1.0; beetle 3, 2.5, 2, 1.0; snail 6, 2.0, 4, 1.0
- 30: possum 2, 12, 0, 1.0; caterpillar 40, 0.4, 2, 4.07; wasp 40, 0.4, 4, 3.9
- 40: caterpillar 40, 0.4, 0, 36.7

**Generator, 2027-W01:** template Hook, mirrored, waypoints `(11,4) (6,4) (6,1) (2,1) (2,6) (0,6)`; modifiers heatwave, ironshell; title "Dusty Hedgerow"; featured aphid, ant, moth, beetle, slugmum, snail. Waves:
- 1: ant 6, 2.0, 0, 1.0; aphid 6, 2.0, 2, 1.0
- 2: aphid 10, 1.2, 0, 1.0; ant 4, 2.5, 2, 1.0
- 3: moth 6, 2.0, 0, 1.0; snail 2, 2.5, 2, 1.0
- 15: possum 1, 12, 0, 1.0; moth 10, 1.2, 2, 1.0; snail 3, 2.5, 4, 1.0
- 30: possum 2, 12, 0, 1.0; slugmum 40, 0.4, 2, 1.05; moth 40, 0.4, 4, 4.55
- 40: moth 40, 0.4, 0, 61.2

If the Luau output differs from these, the Luau code is wrong unless a deliberate change to 3.6 was made and this appendix updated (regenerate with `design/prototype/weekly.py`).

## Appendix B: reference build orders and the greedy bot

Steps run in order whenever affordable (a step waits; it never skips). `P(seed, x, y)` plants; `U(x, y)` upgrades the plant on that tile by one level. Research levels R0, RMID and RFULL are defined in 3.7.

**Backyard Patch** (loadout thorn, sunpetal, burr): P(thorn,8,2) P(thorn,3,5) P(sunpetal,11,0) P(thorn,5,3) P(thorn,6,5) P(burr,8,3) U(8,2) U(3,5) P(thorn,5,2) U(5,3) U(6,5) P(burr,3,3) U(8,2) U(3,5) P(thorn,10,5) U(11,0).

**Backyard, 3 thorns only** (should lose): P(thorn,8,2) P(thorn,3,5) P(thorn,5,3).

**Veggie Rows** (loadout thorn, sunpetal, dandelion, pumpkin, snapjaw): P(thorn,4,1) P(thorn,7,3) P(sunpetal,0,7) P(dandelion,5,2) P(thorn,7,4) P(sunpetal,1,7) P(pumpkin,4,2) U(4,1) U(7,3) P(dandelion,8,5) P(pumpkin,8,3) U(5,2) U(4,2) P(thorn,10,4) U(0,7) U(1,7) P(snapjaw,5,5) U(8,5) U(8,3) U(5,2) U(4,2) U(4,1) U(7,3) P(pumpkin,2,1) U(2,1) P(dandelion,7,5) U(7,5) U(8,5) U(8,3) U(2,1) U(7,5) U(7,4) U(7,4).

**Night Orchard** (loadout thorn, mint, pumpkin, dandelion, snapjaw): P(thorn,4,2) P(thorn,7,2) P(mint,7,4) P(pumpkin,5,2) P(dandelion,2,2) P(thorn,9,4) U(4,2) U(7,2) P(snapjaw,9,3) P(mint,2,4) P(pumpkin,7,5) U(5,2) U(2,2) P(dandelion,3,2) U(9,3) P(pumpkin,4,4) U(7,5) U(5,2) U(2,2) U(4,2) U(7,2) P(snapjaw,9,2) U(9,3) P(pumpkin,5,4) U(5,4) U(3,2) U(7,5) U(4,4) P(dandelion,9,5) U(9,5) U(9,2) U(5,4) U(3,2) U(4,4) U(9,5) U(9,2) U(9,4) U(9,4) U(7,4) U(2,4).

**Greedy bot** (weekly field, level soil, loadout thorn, sunpetal, pumpkin, dandelion, mint, snapjaw). At each build phase, repeat until no action is taken:

1. Build a list of candidate actions with a score:
   - If wave <= 6 and fewer than 2 Sunpetals: Sunpetal on the plantable tile with the **lowest** coverage at range 2.5, score 1e9.
   - If a mole is featured, wave >= 2, and Mint Mists < 1 + floor(wave / 8): Mint on the tile with the highest coverage at 1.5, score 1e8.
   - If a moth or wasp is featured, wave >= 2, and Dandelions < 1 + floor(wave / 6): Dandelion on the highest coverage tile at 4.0, score 1e7.
   - For each of thorn, pumpkin, snapjaw: plant on its highest coverage tile, score `damage * rate * coverage / cost` (level 1 values).
   - For each plant with a rate above 0 below level 3: upgrade, score `(dps at next level - dps now) * coverage at the next level's range / upgrade cost`.
   - Coverage ties go to the lowest `y`, then the lowest `x` (scan `y` 0 to 7, `x` 0 to 11, keep the first best).
2. Sort by score, highest first. Try each in turn: the first that succeeds is taken and the loop repeats. If a candidate scored 1e7 or more cannot be afforded, stop for this build phase (save up for it).

## Appendix C: the prototype

`design/prototype/` holds the Python used to check these numbers: `sim.py` (the rules in 3.1), `fields.py` (3.4), `reference_runs.py` (3.7 table), `weekly.py` (3.6 and Appendix A), `bot.py` (the greedy bot over many weeks). Two known small differences from the spec, both too small to move the bands: the prototype rounds Sap rewards with Python's `round` (half to even) instead of half up, and does not apply the seedling factor to burn. The Luau code follows this spec, not the prototype.
