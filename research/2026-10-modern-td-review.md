# Seed Siege against modern Roblox tower defence (October 2026)

Researched 25 October 2026 by the Scout. Question from the owner: does Seed Siege feel like an old school, single player, Plants vs Zombies style tower defence that a 25+ year old grew up on, rather than what kids and teens play on Roblox now?

Read with: `design/seed-siege-onepager.md`, `design/seed-siege-spec.md`, `research/2026-10-game-ideas.md` (earlier market research, cited here as "earlier research"; not repeated). Picture checked: `media/3d/preview-hero.png`.

Labels: **[official]** Roblox Creator Hub, Help or DevForum staff page, or a government page. **[tracker]** RoWatcher, Rolimons via a ranking site, Statroblox. **[press/guide]** a games site or fan wiki. **[community]** forum posts by players (anecdotes, not a survey). **[unverified]** I could not confirm it from a primary source, sources disagree, or it is my own reading. Player counts are snapshots that move daily.

---

## 0. The short answer

The owner's worry is **half right**.

- **The core is not out of date.** Placing units beside a path, upgrading them and holding waves is still exactly what the biggest Roblox tower defences do. Tower Defense Simulator is the number one TD with a 30 day peak of about 104,000 players [1], and a garden themed TD with plants fighting insects (Garden Tower Defense) peaked at about 66,000 and still holds 14,000 to 18,000 players with a 98% like ratio [1][2]. The garden and plant theme is proven inside this genre on Roblox, by a game that is not anime.
- **The wrapper around the core is out of date.** Seed Siege as specified is a solo puzzle with a spreadsheet research tree: 10 seeds, a 20 node tree, one friend at most, no lobby, no avatars on screen, no collection, no events. Every hit Roblox TD is instead a **social collecting game with a TD battle in the middle**: a lobby full of other players, queue pads for up to four friends, a growing roster of characters with rarity tiers, many modes, and an update every week or two [1][3][4][5][6]. That meta layer is what a 12 to 18 year old Roblox player means by "a TD game", and it is what Seed Siege is missing.
- **The hits pay for that wrapper with gambling style summons and trading.** We cannot copy those parts and should not. Section 4 shows how to get most of the pull (collection, rarity, surprise, showing off) from things earned by play, with no paid randomness and no open trading.

The tested M1 core (plant, waves, Sap, hearts, server authority) survives intact. The changes are in what sits around it.

---

## 1. The competition, game by game

| Game | Players (date) | How units are got | Rarity | Co-op and lobby | Trading | Modes | Updates | Theme | Money |
|---|---|---|---|---|---|---|---|---|---|
| **Tower Defense Simulator** (Paradoxum) | 30 day peak 104,491, 7 day peak 80,876, 94.1% approval (Rolimons, 3 Oct 2026) [1] **[tracker]** | Earned: free starters, towers bought with coins earned in matches, level and challenge rewards, evolutions, event towers; no summons [1][7] **[press/guide]** | Tower tiers, gold and evolved versions | Teams of friends against waves and bosses; big lobby with queue elevators (50 player servers seen) [7] | Not a feature [7] | Survival by difficulty (Easy to Fallen), Hardcore, PvP, Sandbox, Story, events [7] | New event or tower roughly every two weeks, e.g. 11 Sep to 23 Oct 2026 [7] | Soldiers, sci-fi, bosses, cutscenes | Robux towers (225 to 2,500+ R$) and skin bundles; parent guide says the grind is "intentionally designed to be exhausting to encourage spending", top towers take "40+ hours" [7][8] |
| **Anime Vanguards** (Kitawari) | All time peak 171K (Oct 2024); 30 day peak 44,979, 96.7% approval (Oct 2026) [1][3] **[tracker]**; once reported as the top earning Roblox game [9] **[press]** | Gacha summons on rotating banners, 50 gems a roll, levelled and evolved [3][10] | Rare to Mythic (0.5%), Secret, Vanguard, Shiny; pity at 50 and 400 rolls, 20,000 for event Vanguards [10] **[press/guide]** | Hub lobby, play with friends, many modes [1][3] | Trade button in the hub for tradeable units [10] | Story, challenges, raids, Underworld Dungeon, level editor, events [3] | Major numbered updates every 1 to 3 months (10.0 Dec 2025, 11.0 Feb 2026, 11.5 Mar 2026) [3] | Anime lookalikes | Robux luck potions (99 and 199 R$), Shiny Hunter pass [10] |
| **Anime Defenders** (Small World Games) | All time peak 202K (Sep 2024) [11] **[tracker]**; recent counts conflict | Gem summons; gems from story quests [12] | Up to Secret; one unit at 0.01% [12] | Lobby, co-op | Trading existed (a banner bug led to mass giveaways and trades) [12] | Story, challenges | Frequent | Anime | Gems and passes |
| **Anime Last Stand** | Peak about 157K [13] **[tracker, unverified date]** | Hourly rotating summon banner, 50 emeralds a roll [14] **[press/guide]** | Gacha tiers | Lobby, co-op | Yes, value lists and scam warnings [13][14] | Story, raids, events | Frequent | Anime | Gacha |
| **Toilet Tower Defense** (Telanthric) | About 6 billion visits; now 2,700 to 6,300 playing, 30 day peak 14.8K (13 Oct 2026) [15] **[tracker]** | Crates bought with coins and gems [15] | Many tiers; unit values tracked by fans [15] | Lobby, matches start from a platform [15] | Central to the game [15] | Waves, endless | Was weekly in its boom | Skibidi Toilet meme (2023 to 2024) | Gems for crates |
| **Garden Tower Defense** (Garden Defenders) | All time peak 66K (Aug 2025); 14,208 now; 30 day peak 18,606; 98.2 to 98.3% likes; launched May 2025 [1][2] **[tracker]** | Summoned with Seeds at "Gerald Gnome's summon shop"; codes give Seeds [16] **[press/guide]** | Seven tiers, Common to Exclusive (Godly, Mythical) [17] **[press/guide, tiers disagree]** | Team up to defend; one mode lets you morph into your plant, another has enemies chase players [1][2] | Yes: fan value lists price units and even a "10K Seeds Gift" pass [17] | Four modes, four difficulties [2] | Weekly, Saturdays 3pm UTC [2]; events (Bee Bloom, July 2025) | Plants v insects, cute | Seeds gift passes (Robux to summon currency, so paid random) [17] |
| **Tower Defense X** | 30 day peak 26,207 [1] | Not covered | | | | Air, land, sea towers | | Military | Battle pass with a 50% token boost offer [1] |
| **2026 risers** | Retro TD peak 36K (Aug 2026), now 4.5K to 16.5K; Slop TD 25K at launch (Jul 2026), 79% approval; Alliance TD 20.8K, three months old [1][18] **[tracker]** | Summons, crafting; Retro TD also lets you win rounds and buy towers [1] | Gacha | Retro TD: "friends earn more rewards" [1] | Retro TD added tower trading [1] | Casual to Endless | | Retro, meme, mixed | |

Genre size: about 236,000 people play tower defence at once across 346 games, about 682 players per game, one of the best ratios on Roblox (Statroblox, 25 Oct 2026) [19] **[tracker]**.

What every one of them has in common, and Seed Siege does not:

1. **A lobby with other people in it.** You walk your avatar around, see what others own, step onto a pad or elevator to start a match with up to three others.
2. **A roster that keeps growing.** Hundreds of units in Garden TD (350+ claimed) [2]; new towers every couple of weeks in TDS [7].
3. **Rarity you can show off.** Named tiers, shiny or gold versions, evolutions.
4. **Lots of ways to play.** Story, hard, endless, challenge, raid or boss, events.
5. **A visible update rhythm.** Weekly (Garden TD on Saturdays) or event every two weeks (TDS), with "[UPD]" in the title.

What they mostly do that we will not: paid or Robux linked summons (Anime Vanguards, Anime Defenders, Garden TD's Seeds gift), Robux luck boosts, open trading with fan value lists, multi thousand Robux shortcuts. Note TDS proves the top spot does not need gacha: its towers are earned or bought directly [1][7].

---

## 2. Grow a Garden: what made it huge, and what fits a TD

Facts: released 26 March 2025 by a 16 year old developer, then co-owned with Splitting Point; about 5 million concurrent on 18 May 2025, 21.3 million on 21 June 2025, about 22.3 million on 23 August 2025 during a staged "admin war"; fastest game to a billion visits (33 days); about 35% of players under 13 by the owner's own estimate [20] **[press via Wikipedia]**. Grow a Garden 2 (combat focused) launched mid 2026 with over 400,000 players in its first 20 minutes and a tracker peak of about 976K [21] **[press/tracker, unverified peak]**.

What drove it, and whether it fits Seed Siege:

| Grow a Garden feature | What it did | Fit for a TD | How |
|---|---|---|---|
| Your garden is visible to everyone in the server [20][22] | Showing off; you see what is possible | **Yes, high** | Each player's garden plot or plant collection on display in the hub |
| Server wide weather (rain gives "Wet" x2, rarer storms up to much higher multipliers), the same for everyone at once [22] | Shared moments, reason to be online, talk in chat | **Yes, high** | Weather that changes a run (Rain slows pests, Heatwave speeds Chilli) and gives a chance of a variant plant |
| Mutations (Gold, Rainbow and so on) raise a crop's value [22] | Surprise and rarity from ordinary play | **Yes** | Free variant plants (Giant, Golden, Frosted) from play, cosmetic or tiny PvE bonus |
| Grows while offline [20][22] | Return reason | **Partly** | A "seed tray" that ripens a seed pod while away, collected next visit; no penalty for missing it |
| Weekly Saturday update plus "Admin Abuse" live event, 30 minutes, run by the developer [23] **[press/guide]** | Huge synchronised crowds; YouTube and TikTok content | **Partly** | An automatic Saturday weather event (no human needed). Rewards must come back later, so it is not pressure |
| Pets from eggs (random, some bought) [20] | Collection, gambling feel | **Only the collection part** | Free seed pods; never sold |
| Stealing crops for Robux (37 R$, announced to the server) [24] | Drama, memes, money | **No** | Pay to harm another player; also bad for kids. Grow a Garden 2 made stealing a night time mechanic with defences [24] |
| Trading and gifting (scams led to a proper trade window; pet gifting was switched off over a duplication bug) [25] | Economy and status | **No, at least at launch** | See section 4.4 |
| Rare items sold for real money on eBay and Discord, against Roblox's terms [20] | A sign of an economy kids get scammed in | **No** | |
| A 0.08% pet drop drew backlash and an apology [25] | Shows how low odds feel to kids | Lesson | If we do any free randomness, show the odds and add a guarantee |

Honest caution: Grow a Garden was a one in millions outcome, and reviewers called it a prototype [20]. Its features explain the shape of the hit, not a recipe for repeating it.

---

## 3. What players say they like and hate

Evidence here is **thin**. Reddit and the DevForum were mostly unreachable or returned off topic results; what follows is a handful of forum posts, a parent guide and review sites, not a survey.

Likes:
- **Co-op and teamwork.** The parent guide says TDS rewards "patience, teamwork, and resource management" and that kids talk tactics in matches [8] **[press/guide]**. Retro TD advertises that friends earn more rewards [1].
- **Earned progress.** TDS is praised for having no gacha randomness [26]; a review of Universal Tower Defense likes that codes and repeatable maps stop it "feeling stuck on luck" [27] **[press/guide]**.
- **Events and cutscenes.** One player only returns to TDS for events and their "pretty good" cutscenes [28] **[community]**.
- **Characters people already love** (anime lookalikes, the Skibidi meme). The anime TDs and Toilet TD grew on existing fandoms [3][15] **[my reading]**.

Hates:
- **Grind plus big paywalls:** "boring grindfests with 3000 robux gamepasses to unlock towers early"; "either p2w or abandoned" [28] **[community, July 2025]**.
- **Abandonment:** several old favourites died when the developer moved on [28] **[community]**. Players notice when updates stop.
- **Tiny odds:** 0.5% Mythics, 0.01% units, 0.08% pets, pity at 400 rolls [10][12][25]. The Grow a Garden backlash is the clearest evidence it hurts trust [25].
- **Toxic lobbies:** low level players "voted out" or ignored in TDS, which pushes kids to ask for Robux to fit in [8] **[press/guide]**.
- **Scams around trading and "carries"** [8][14][24] **[press/guide]**.
- **Sameness:** one player says Roblox TDs all follow the same loop and the anime gacha look "puts people off" [29] **[community, single post]**. This is the opening for a non-anime game.

---

## 4. Roblox rules that limit copying the hits

### 4.1 Paid random items
- Anything random bought "directly or indirectly with Robux" (packs, keys, luck boosts, currency bought with Robux) must show every outcome with percentage odds summing to 100% before purchase [30] **[official]**.
- When `ArePaidRandomItemsRestricted` is true for a player, the game must give a free path, fixed order, direct purchase at expected value, or hide or block it [30] **[official]**. Brazil bars under 18s from them (earlier research, source 48).
- **Random rewards from play that involve no Robux or in-game currency do not need odds disclosure** [30] **[official]**. So free seed pods from play are allowed. If a currency that buys pods could ever be bought with Robux, the whole system becomes paid random. Our rule must stay: **the currency that opens anything random is never sold, never gifted by a pass, never boosted by Robux.**
- Australia: since 22 September 2024 games with in-game purchases linked to chance get at least an M classification (not recommended under 15) [31] **[official]**. This applies to classified games, not individual Roblox experiences, but it shows where Australian regulators draw the line, and the Minister has asked for Roblox's own rating to be reviewed (earlier research, 2.6). Keeping all chance unpaid keeps us on the right side of it.
- Garden TD's "10K Seeds Gift" pass buys summon currency with Robux [17], which is exactly the pattern we avoid.

### 4.2 Trading
- Roblox's maturity questionnaire asks creators to disclose **paid item trading** (buying items that can then be traded), and when `IsPaidItemTradingAllowed` is false the game must hide or block trading of paid items and of paid random outcomes [30][32] **[official]**.
- Platform trading (avatar limiteds) now needs an age check and Roblox Plus, reported from September 2026 [33] **[official help page via search snippet; page itself returned 403, so unverified wording]**. This is about Roblox's own trading, not in-game trading, but it shows the direction: trading is being age gated.
- A third party guide claims a separate `IsTradingAllowed` policy flag exists [34] **[unverified; the official PolicyService page did not list it]**. The Builder must check the current API before any trading feature.
- Real money trading of game items is against Roblox's terms [20].
- Conclusion: trading of **earned, cosmetic only** items is allowed under these rules, but it brings scams, value lists and pressure that are a poor fit for a game meant to open to 9 to 15 year olds. Recommend no open trading (4.4 in section 6).

### 4.3 The 16+ start, and Kids and Select
- New games reach only age-checked 16+ players first; Kids (5 to 8) and Select (9 to 15) need ID verification, 2-Step Verification, the questionnaire at Minimal or Mild (Kids) or up to Moderate (Select), a refundable fee or two months of Plus, and **250 unique plays by highly engaged age-checked users within 60 days** [35] **[official]**. (The earlier research found a DevForum post saying 500; the Creator Hub page read today still says 250.)
- Chat is off by default for Kids, off for self-declared Select accounts and introduced gradually after an age check [35] **[official]**; chat everywhere needs an age check since early 2026 [36] **[official]**.
- What it means for the design: **co-op must work without chat.** Party pads, invite buttons, quick emotes and pings, not typing. That is also safer.
- It also means the first players are 16 to 25. The good news is that what the hits do (co-op, collection, modes, events) also appeals to that age; anime TD players are largely teens and young adults **[my reading, no age data found]**. Grow a Garden had about 35% under 13 [20], so the "kids" features are not only for kids.

### 4.4 Content maturity
- "Bodies disappearing the moment their health reaches zero" counts as unrealistic violence, Mild [32] **[official]**. Pests that poof into leaves and run off should be Minimal or Mild; answer honestly.
- Mild crude humour (burps, farts) is allowed at Mild [32]. A farting stink bug is fine for Kids; going further is not.
- Mild fear (jump scares, ominous music) is Mild [32]: keep night levels cosy, not scary.
- Playable gambling is not allowed at any label [32].
- Free form drawing or writing visible to others is 16+ only [32]: no custom signs or plot names.

### 4.5 Pressure tactics (our own rule, backed by the evidence)
Limited time items with countdowns, "last chance" banners, and events whose rewards never return are the main pressure tools in the hits. Roblox itself calls timers and appointment mechanics a poor fit (earlier research, source 28). Our rule: events can be time boxed, but **every event reward comes back in a later rotation or can be earned another way**, and the shop never shows a countdown.

---

## 5. Can a garden theme beat anime and memes? Where are the gaps?

- **Yes, there is direct proof:** Garden Tower Defense, plants against insects, cute style, 66K peak and 98% likes [1][2]. It is the closest competitor and the biggest threat: it already owns "garden TD" in search. Seed Siege must look and feel different from it (Australian backyard, Nan, native wildlife pests, no gacha) or Roblox may treat it as a lookalike (earlier research, 1.3).
- **Anime fatigue is real but anecdotal** [29]. A clean, funny, non-anime TD with no gacha is a clear position: "the fair one".
- **Gaps nobody fills well (from this research, my reading):**
  1. A TD with **no paid randomness at all** that still has a deep collection. TDS is closest but sells towers for thousands of Robux [8].
  2. **Australian humour.** Bin chickens (ibis) raiding the bins, swooping magpies, a possum on the roof, cockatoos shredding the deck, a brush turkey stealing mulch. Nobody on Roblox owns this, it is instantly funny to Australians and novel overseas, and it suits Minimal or Mild maturity.
  3. **Family co-op.** A parent and a child, or siblings, playing one garden together without chat. Fits Roblox Plus private servers and the coming Kids and Select audience.
  4. **Cosy TD.** Calm music, no fail screen shaming, a garden that looks nicer the more you play. The "cosy simulator" trend is claimed as the fastest growing genre in 2026 by one source [37] **[unverified]**.

---

## 6. Recommendation

### 6.1 What to keep

- The tested M1 core: plant, grow, waves, Sap, hearts, sell, upgrade, counters (flying, hidden, armour, splitting), 1x and 1.5x speed, server authority, deterministic WaveSim and Lune tests. This is the same core the top games run.
- The weekly garden with level soil and a leaderboard. It is the one feature that is already modern and nobody else has it in this form.
- The look in `media/3d/preview-hero.png`: bright, chunky, plants and bugs with faces, Hills Hoist, gnomes, Nan. It reads as a Roblox game today and is clearly not anime. (Add avatars; see change 1.)
- Petals earned only by play, never sold. No paid random items. No pay to win on leaderboards. Honest shop with no countdowns.
- Phone first UI, 8 word tips, no typing.
- Nan, and the Aussie backyard.

### 6.2 What is out of date

- Solo first, with one friend "later". Every hit is co-op first.
- No lobby and no avatars: the player is a floating camera. On Roblox the avatar is the player's identity.
- 10 seeds total, unlocked by a 20 node research tree. That is a 2009 browser game meta. Players expect a collection that keeps growing, with rarity and something to show.
- Three fields and Frost as the only modes.
- No events and no update rhythm in the plan. "The weekly field runs itself" is good, but players also need to see new plants and pests arrive.
- Pests and seeds as stat lines. They need names, faces and jokes.

### 6.3 The changes, ranked by likely impact on players

Effort is for one Luau Builder agent working from a spec, with Lune tests: **S** 1 to 2 days, **M** 3 to 5 days, **L** 6 to 10 days. Policy risk: Low, Medium, High.

**1. Co-op for 1 to 4 players from a shared hub (Nan's Backyard).** Impact: highest. Effort: **L** (8 to 10 days). Policy risk: Low.
- A hub place where avatars walk around: Nan's porch, the Seed Almanac board, the leaderboard, a display bed for each player's favourite plants, and four "garden gates" (party pads) that start a run for whoever stands on them (1 to 4, with a 15 second countdown and a Start now button). Friend invite and "Join friend" buttons; no chat needed.
- In the run, the garden has four planting zones around the path, one per player, each with its own Sap; hearts are shared. Scaling: pest health x1.0, 1.6, 2.1, 2.6 for 1 to 4 players (tune in Lune). Waves start when all are ready or after a timer.
- Every player gets full Petals. A small "played with a friend" bonus (+10%), never a penalty for solo.
- Evidence: all of TDS, Anime Vanguards, Garden TD, Retro TD are co-op with a lobby [1][3][7]; co-play is a discovery signal (earlier research, 2.3); the M1 server authority model already supports several clients.
- Reuse: M1's RunManager and Validate need an owner per plant and per Sap pool; WaveSim is unchanged apart from scaling.

**2. A plant collection with rarity, earned by play (the Seed Almanac).** Impact: very high. Effort: **L** (6 to 8 days for the system, content after). Policy risk: Low if the rules below hold; High if broken.
- Grow the roster from 10 to about 24 plants by launch, then 1 to 2 a fortnight. Each plant has a rarity, named for an agricultural show: **Common, Uncommon, Rare, Ribbon (epic), Blue Ribbon (legendary), Champion (mythic)**.
- How you get them, with **no paid randomness**:
  - Every wave drops **Seed Pods** for a named plant (the drop table is shown on the field card). 10 pods of one plant sprout it. Shards to a known unit is predictable and feels fair.
  - Bosses and harder modes drop rarer pods. Weekly ribbons and event rewards give specific plants.
  - Optional free surprise: a **Mystery Pod** (one a day, from play) with odds shown on screen anyway and a guarantee (every 10th is Rare or better). Free random from play needs no odds by Roblox rules [30], but we show them because kids deserve to know.
  - **Never sold**: pods, Mystery Pods, Petals, luck, or a pass that gives any of these.
- Duplicate pods level that plant up (plant level 1 to 10, small stat gains, a new look at 5 and 10, like evolutions). This replaces most of the research tree's stat nodes; keep a short research tree for hearts, start Sap and loadout slots.
- Weekly garden keeps level soil: everyone uses level 1 plants, so collection never buys rank.
- Evidence: every hit TD centres on collecting units with tiers [3][10][12][17]; players resent tiny odds and paywalls [25][28]; TDS shows earned unlocks can top the genre [1].

**3. Characters with personality: Nan, funny Australian pests, plants with faces.** Impact: high. Effort: **M** (4 to 5 days code and data; art is the long pole). Policy risk: Low (keep crude humour at Mild or below).
- Nan: the hub host with a few dozen one liners, reacts to wins and losses, gives a daily "Nan's job" (plant 5 Burr Vines, beat wave 10 without leaks).
- Pests with names and gags: **Kevin the Bin Chicken** (ibis boss who steals a plant and runs), **Swoopy** (magpie, flying, dive bombs in spring weather), **Possum** (already in), **Cocky Crew** (cockatoos that shred a plant's leaves), **Brush Turkey** (scrapes mulch, buries a plant), **Stinky** (stink bug that slows plants with a puff). Each poofs into leaves and scurries off.
- Plants with faces, idle animations and a victory pose; each plant a one line bio in the Almanac.
- Evidence: anime TDs and Toilet TD ride on beloved characters and memes [3][15]; Garden TD has Gerald Gnome [16]; the gap in Australian humour (section 5).
- Avoid: real brands, real people, copying Skibidi or anime looks, anything gross beyond Mild.

**4. More game modes.** Impact: high. Effort: **M** (4 to 5 days; WaveSim already handles fields and modifiers). Policy risk: Low.
- **Story**: the three fields become World 1 (Backyard) with more worlds over time (Front Yard, Veggie Patch, Orchard at Night, Bush Block, Beach Shack).
- **Hard** (the existing Frost mode).
- **Endless (the Compost Heap)**: how long can you last; a weekly best wave board.
- **Boss Raid**: co-op only, one big boss with phases (Kevin the Bin Chicken), drops rare pods.
- **Weekly Garden**: keep as is, level soil, leaderboard.
- **Nan's Daily**: one short fixed challenge a day, same for everyone, small reward, no streak.
- Evidence: every hit has many modes [1][3][7]; the generator from M3 already produces fields from a seed.

**5. Weather and a Saturday garden event.** Impact: medium to high. Effort: **M** (3 to 4 days). Policy risk: Medium (only if it becomes FOMO).
- Server wide weather in the hub and in runs that start during it: Rain (pests slower, plants grow 1 wave sooner), Heatwave (Chilli stronger, Mint weaker), Windy (flying pests blown back), Spring (magpies swoop, Champion pod chance up). Changes every 15 minutes, announced by Nan.
- **Saturday Big Weather**: at a fixed time each Saturday, 30 minutes of a rare weather with a higher variant chance (Golden or Giant plants, cosmetic plus a tiny PvE bonus). Runs automatically from the clock; no human needed.
- Rule: every event reward returns in a later rotation or through another mode. No countdown in the shop, no "last chance" wording.
- Evidence: Grow a Garden's weather and Saturday events drew its biggest crowds [20][22][23].

**6. A public update rhythm.** Impact: medium to high (players notice abandonment [28]). Effort: **S** per drop (1 to 2 days each), ongoing. Policy risk: Low.
- Every second Saturday a small drop, built by the Builder and checked by Lune: one new plant or one new pest, plus a balance pass. Monthly a bigger themed update (a new world or mode). Version and "[UPD]" in the title, a "What's new" board in the hub.
- The owner's 30 minutes a week covers reading the change list and a short playtest. Content stays data, so AI can batch it (spec section 10).
- Evidence: Garden TD weekly on Saturdays [2]; TDS events every two weeks [7]; Anime Vanguards numbered updates [3].
- Honest limit: a solo AI built game will not match a studio's pace. Fortnightly is a realistic promise; weekly is not.

**7. Your avatar in the garden, with one active ability.** Impact: medium. Effort: **M** (3 to 5 days). Policy risk: Low.
- The player's own avatar stands in their planting zone, can walk around and emote. One tap ability on a cooldown: **Watering Can** (a plant grows or attacks faster for 5 seconds), later a choice of tools (Rake to push pests back, Hose to slow a lane).
- Gives a young player something to do between placements, puts the avatar on screen for thumbnails and clips.
- Evidence: Garden TD has modes where you morph into units or enemies chase you [1][2]; Grow a Garden 2 moved to combat [21]. **[my reading]**

**8. Showing off and recognition.** Impact: medium. Effort: **S to M** (2 to 3 days). Policy risk: Low.
- A display bed in the hub with your 3 favourite plants (with variants), your title and ribbons over your head, Almanac completion percentage, per mode boards (Weekly, Endless, Raid). Titles from milestones ("Snail Whisperer" already planned).
- Evidence: Grow a Garden's visible gardens [22]; rarity is worth more when other players can see it.

**9. Friend features that are safe: invites, a friends bonus, codes, and one way gifting of cosmetics.** Impact: medium. Effort: **S** (2 days). Policy risk: Low for invites and codes; Medium for gifting.
- Invite button (Roblox's own invite prompt), +10% Petals when a friend is in your run, Roblox group join gives a cosmetic, redeem codes for Petals or pods posted on social and in update notes (standard practice across TDs [16]).
- **No player to player trading at launch.** Instead, after a co-op run you may gift one **cosmetic cutting** (a plant skin you have a duplicate of) to a teammate, one way, nothing asked in return, nothing sold. This gives the generosity moment without a market, value lists or "you go first" scams.
- Revisit trading only after Kids and Select, and only for earned cosmetics, with Roblox's current policy flags checked first (4.2).
- Evidence: scams and toxicity around trading and carries [8][14][24][25]; Roblox gating trading by age [33].

**10. Turn monetisation into cosmetics and a fair season pass, earlier.** Impact: medium (on income, small on fun). Effort: **S to M** (2 to 4 days). Policy risk: Low if the rules hold.
- At launch add a few plant skin sets and garden themes (99 to 149 R$), not only in the later update. 16+ buyers expect cosmetics.
- Optional later: a **Garden Pass** each season (about 8 weeks) with a free track and a paid cosmetic track (Roblox allows battle passes in subscriptions; earlier research section 3). Rewards on the paid track are cosmetic; the pass can still be finished in the last week; past pass items come back in the shop later. No paid XP skips aimed at children.
- Keep: Fast Forward, private servers, Second Wind (solo, with a free one daily). Drop the Big Seed Bag if loadout slots move into plant levels.
- Never: pods, Petals, luck, Mystery Pods or anything random for Robux; no Robux shortcut for a Champion plant (the TDS 2,500 R$ pattern [8]).

**11. Cut the solo research tree back to a short "Garden Shed" tree.** Impact: low to medium (it simplifies). Effort: **S** (1 to 2 days, mostly data and tests). Policy risk: Low.
- Keep 6 to 8 nodes: hearts, start Sap, loadout slots, Sunpetal income. Plant power comes from plant levels (change 2). Fewer menus, less spreadsheet feel.

Changes 1 to 5 are the ones that answer the owner's worry. 6 to 11 make it last.

### 6.4 Where copying the hits would break our rules

| What the hits do | Why we will not | What we do instead |
|---|---|---|
| Summons paid with currency that can be bought with Robux | Paid random items; odds rules; Australian M line; kids | Seed Pods to a named plant; free Mystery Pod with odds and a guarantee |
| Robux luck potions | Same | Weather luck that everyone in the server shares, free |
| Open trading and value lists | Scams, pressure, age gating | One way cosmetic gifting after co-op |
| 2,500 R$ to skip a 40 hour grind | Pay to win pressure on kids | Every plant reachable by play in a fair time (target: a Champion in about 2 weeks of normal play) |
| Limited items that never return, countdown banners | FOMO aimed at kids | Rotating events whose rewards come back |
| Robux to steal from another player | Harm, drama, kids | Bosses that "steal" a plant you win back (Kevin) |
| Anime lookalike characters | IP risk and lookalike reach penalty | Our own Aussie cast |

### 6.5 Revised pitch

Seed Siege is a co-op garden tower defence in an Aussie backyard: team up with up to three mates, plant a crew of cheeky plants beside the path, and shoo off waves of bin chickens, swooping magpies, possums and bugs before they reach Nan's shed. Every run drops Seed Pods for the plant you want, so you grow your own collection from Common to Champion by playing, never by paying or rolling; weather rolls through the server, a Saturday storm brings golden plants, new plants and pests arrive every fortnight, and a Monday weekly garden puts everyone on level soil for the leaderboard. It is the fair one: no paid luck, no trading scams, nothing you can only buy, and you can play it with your little brother or your nan.

### 6.6 Revised milestone order (M2 onwards)

M1 stays as built: one garden, plant, grow, upgrade, sell, waves, Sap, hearts, server authority, Lune tests.

**M2: Saves and the co-op shell.** DataStore saves with session locking (spec 6.6, unchanged); the hub place with Nan, party pads for 1 to 4, Join friend and invite; runs for 1 to 4 players with per player planting zones and Sap, shared hearts, health scaling; avatars in the garden; the tutorial (spec 2.2) played inside a solo run that starts from the hub. *Done when:* two and four Studio test players finish a run together; a save survives a rejoin; the M1 tests still pass with a player count argument added; scaling tests in Lune.
Effort about 12 to 15 builder days. Reuses RunManager, Validate, WaveSim, Economy.

**M3: Collection.** Seed Almanac, Seed Pods per wave with shown drop tables, rarity tiers, plant levels 1 to 10, about 24 plants and 14 pests (adding the Aussie cast), the short Garden Shed tree, Petals, results screen with pods. Optional free Mystery Pod with shown odds and guarantee. *Done when:* Lune shows a free player at about 35 minutes a day reaches a Champion plant in about 14 days and fills 80% of the Almanac in about 28; balance tests pass with level 1 and level 10 plants; no code path grants pods, Petals or randomness from a purchase (a test reads Products and checks it).
Effort about 10 to 12 days.

**M4: Modes, weather and the weekly garden.** Story World 1 (the three fields) plus Hard; Endless; Boss Raid (co-op only, Kevin); Nan's Daily; the weekly generator and leaderboard (spec M3, unchanged); server weather and the automatic Saturday Big Weather. *Done when:* the existing weekly test vectors still match; weather is deterministic from the clock in tests; level soil holds on the weekly garden (level 1 plants only).
Effort about 10 to 12 days.

**M5: Shop, polish and launch to 16+.** Fast Forward, Second Wind, private servers, plant skins and garden themes; display beds, titles and per mode boards; codes, group reward, one way cosmetic gifting; sounds, juice, phone layout, thumbnails from real co-op play; maturity questionnaire. *Done when:* receipt tests pass; the owner's checklist passes; published to 16+.
Effort about 8 to 10 days.

**After launch (the rhythm, change 6):** a small drop every second Saturday (one plant or pest, a balance pass), a themed update monthly (a new world, a new raid boss, or the season Garden Pass), each checked by Lune before publish. Then the Kids and Select application once 250 engaged plays are reached (co-op helps get there).

Compared with the old plan: co-op moves from "M4 or after launch" to M2; the research tree shrinks and the collection takes its place; events and modes are added; the build is roughly 40 to 50 builder days to launch instead of about 30 **[my estimate]**. If that is too long, the cut order is: Boss Raid, then Garden Pass, then avatar abilities, then Mystery Pod. Do not cut co-op or the collection.

### 6.7 Where the evidence is thin

- Player sentiment rests on a few forum posts, one parent guide and review sites. No survey of what Roblox kids want was found.
- Player counts are tracker snapshots from different days; Anime Defenders and Toilet TD figures conflict between trackers.
- I found no age breakdown for TD players, so "co-op and collection also suit 16 to 25" is my reading of the genre, not data.
- The impact ranking is judgement from what all the hits share, not a measured test. Creator Analytics after launch should settle it: watch D1, D7, sessions with 2+ players, and Almanac progress.
- The trading policy flag and the September 2026 trading age check are not confirmed from primary pages read in full.

---

## Sources

1. Adellion, Best Roblox Tower Defense Games 2026: 8 Picks for October, Ranked (Rolimons figures, 3 Oct 2026). https://adellion.com/roblox-tower-defense
2. RoWatcher, Garden Tower Defense tracker page. https://rowatcher.com/games/7703614594
3. RoWatcher, Anime Vanguards tracker page. https://rowatcher.com/games/5578556129
4. Switchblade Gaming, Best Roblox Tower Defense Games in 2026. https://www.switchbladegaming.com/roblox/best-tower-defense-games/
5. Towers Defense, 12 Best Roblox Tower Defense Games to Play in 2026. https://towersdefense.org/articles/best-roblox-tower-defense-games
6. Statroblox live genre data (see 19).
7. Bloxodes, Tower Defense Simulator wiki page (fan wiki, checked 25 Oct 2026). https://bloxodes.com/wiki/tower-defense-simulator
8. Screenwise, Tower Defense Simulator: Strategy Class or Robux Rabbit Hole? (updated 8 Oct 2026). https://screenwiseapp.com/guides/tower-defense-simulator-roblox
9. Beebom, Anime Vanguards Surpasses Blox Fruits to Become Top Earning Roblox Game. https://beebom.com/anime-vanguards-surpasses-blox-fruits-top-earning-roblox-game/amp/
10. Anime Vanguards summon and pity guides: West Games pity calculator https://west-games.com/anime-vanguards-pity-calculator/ and All Things How https://allthings.how/anime-vanguards-on-roblox-how-to-get-and-equip-units/
11. RoWatcher, Anime Defenders tracker page. https://rowatcher.com/games/5836869368/anime-defenders
12. Pro Game Guides, Anime Defenders banner bug and The Gamer unit. https://progameguides.com/roblox/anime-defenders-players-giving-away-the-gamer-after-the-banner-bug-allowed-a-100-chance-summoning/ and Ginx https://www.ginx.tv/en/anime-defenders-the-gamer-unit
13. Rotrends, Anime Last Stand. https://rotrends.com/game/4509896324/Shibuya-Pt1-Anime-Last-Stand
14. Anime Last Stand Wiki, Summoning Banners. https://alsroblox.fandom.com/wiki/Summoning_Banners
15. Profitable.app, Toilet Tower Defense (13 Oct 2026) https://profitable.app/roblox/games/toilet-tower-defense ; RoWatcher legacy page https://rowatcher.com/games/4778845442 ; Mobile Matters unit value list https://mobilematters.gg/guides/roblox/toilet-tower-defense-units-value-list
16. Pocket Gamer, Garden Tower Defense codes. https://www.pocketgamer.com/roblox/garden-tower-defense-codes
17. Of Zen and Computing, Garden Tower Defense Best Units 2026 https://ofzenandcomputing.com/garden-tower-defense-best-units/ ; Game.guide value pages https://www.game.guide/seedmill-value-garden-tower-defense and https://www.game.guide/10k-seeds-gift-value-garden-tower-defense
18. RoWatcher, Retro Tower Defense https://rowatcher.com/games/7738524573/upd-retro-tower-defense and Slop Tower Defense https://rowatcher.com/games/10529769390/patch-slop-tower-defense
19. Statroblox, Most Popular Roblox Genres in 2026 (data 25 Oct 2026). https://statroblox.com/guides/most-popular-roblox-genres
20. Wikipedia, Grow a Garden. https://en.wikipedia.org/wiki/Grow_a_Garden
21. GosuGamers, Grow a Garden 2 has launched on Roblox https://www.gosugamers.net/entertainment/news/78614-grow-a-garden-2-has-launched-on-roblox-here-s-everything-new-added-in-this-sequel ; RoWatcher https://rowatcher.com/games/10004943774/grow-a-garden-2
22. Sportskeeda, Why is Grow a Garden so popular? https://www.sportskeeda.com/roblox-news/why-grow-garden-popular ; Deltia's Gaming, Grow a Garden mutations guide https://deltiasgaming.com/grow-a-garden-roblox-complete-mutations-guide
23. Digital Citizen, Grow A Garden Admin Abuse Schedule and Why It Matters https://www.digitalcitizen.life/grow-a-garden-admin-abuse-schedule/ ; bo3.gg https://bo3.gg/articles/grow-a-garden-when-does-admin-abuse-start
24. Of Zen and Computing, How to Steal in Grow a Garden (July 2026) https://ofzenandcomputing.com/steal-in-grow-a-garden/ ; bo3.gg, Grow a Garden 2: How to Steal Crops https://bo3.gg/games/articles/grow-a-garden-2-how-to-steal-crops ; Sikayetvar trade scam report https://www.sikayetvar.com/en/roblox-us/lost-my-pet-in-roblox-grow-a-garden-after-trade-scam
25. Dexerto, Grow a Garden dev confirms trading feature is coming to prevent scamming https://www.dexerto.com/roblox/grow-a-garden-finally-getting-trading-amid-complaints-of-rampant-scamming-3230688/ ; Gaming Amigos https://www.gamingamigos.com/post/grow-a-garden-add-trading-feature ; Roonby https://roonby.com/2025/07/28/trading-is-coming-in-grow-a-garden-heres-why-it-was-delayed-by-jandel/
26. Switchblade Gaming (as 4).
27. Vocal Media, Universal Tower Defense Review. https://vocal.media/gamers/universal-tower-defense-review-strategy-gacha-and-pure-fun
28. Arcane Odyssey forum, As a Bloons "Player", are there any good tower defense games on Roblox? (July 2025). https://forum.arcaneodyssey.dev/t/as-a-bloons-player-are-there-any-good-tower-defense-games-on-roblox/151276
29. TDS Wiki discussion, Tower defence games on Roblox have started to become very stale (seen via search summary; page itself not readable). https://tds.fandom.com/f/p/4400000000000182741/r/4400000000001033301
30. Roblox Creator Hub, Paid random items policy guidelines. https://create.roblox.com/docs/en-us/production/monetization/paid-random-items
31. Australian Government (Infrastructure, Transport, Regional Development, Communications and the Arts), New mandatory minimum classifications for gambling-like games content. https://www.infrastructure.gov.au/department/media/news/new-mandatory-minimum-classifications-gambling-games-content
32. Roblox Creator Hub, Content maturity. https://create.roblox.com/docs/production/promotion/content-maturity
33. Roblox Help, Trading on Roblox (read via search snippet; direct read returned 403) https://en.help.roblox.com/hc/en-us/articles/203313310-Trading-on-Roblox ; RoUtility report, 17 Sep 2026 https://routility.io/news/2100374275739783426
34. Roblox Studio Policy Service Compliance (third party guide). https://robloxstudiopolicyservicecompliance.pages.dev/ ; official PolicyService reference https://create.roblox.com/docs/reference/engine/classes/PolicyService
35. Roblox Creator Hub, Roblox Kids and Select. https://create.roblox.com/docs/production/publishing/kids-and-select
36. DevForum, Age Check Requirement to Chat Now Live Globally https://devforum.roblox.com/t/age-check-requirement-to-chat-now-live-globally/4226101 ; Roblox Newsroom, Roblox Requires Age Checks for Communication (Nov 2025) https://about.roblox.com/newsroom/2025/11/roblox-requires-age-checks-limits-minor-and-adult-chat
37. creation.dev, What Roblox game mechanics are trending in 2026. https://www.creation.dev/learn/what-roblox-game-mechanics-are-trending-2026
