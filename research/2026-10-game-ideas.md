# Roblox game ideas for a first-time solo developer (October 2026)

Researched 25 October 2026. Audience: one adult in Australia, new to Roblox Studio, building mostly with AI-written Luau through Rojo, with about 30 minutes a week of human time after launch and a small ad budget.

How to read this: every claim has numbered sources, listed at the end. **[official]** means a Roblox Creator Hub, DevForum staff or Roblox newsroom page read in this session. **[third party]** means a tracker, press or blog. **[unverified]** means I could not confirm it from a primary source, or sources disagree. Numbers from trackers are live snapshots and move daily.

---

## 0. The short version

1. The platform is huge but the long tail is thin: about 14 million average concurrent users spread over 6.7 million active experiences, with about 7 million of them in the top 50 [21]. A new game's realistic target is tens to a few hundred concurrent players, not thousands.
2. Discovery now rewards retention over 28 days (day 1, days 2 to 7, days 8 to 28), not flashy thumbnails, and there is no penalty for a weak start [5][6]. That suits a small, well-made game with a reason to come back, and it punishes thumbnail-bait clones.
3. Since mid 2026 a new game first reaches only age-checked players 16 and over. To reach the 5 to 15 audience (Roblox Kids and Select) the creator needs ID verification, 2-Step Verification, a refundable 1,000 Robux fee per game (or two months of Plus or Premium), and the game must clear a "highly engaged players" threshold [8][9]. **This is the single biggest new hurdle for a small game, and the first audience must be teens and adults.**
4. Cash out (DevEx) is 30,000 Earned Robux minimum, paid at 0.0038 USD per Robux (US$114 for 30,000), with no Premium requirement [1].
5. Recommendation: **Idea 1, "Seed Siege", a solo or co-op garden tower defence**, because it sits in an under-served genre, works with one player in a server, is data driven (so AI can add content in bulk) and can run for months without a human.

---

## 1. Which genres are big, and where the gaps are

### 1.1 What is played right now

- Live snapshot (25 October 2026, about 02:20 UTC): Murder Mystery 2 about 1.69M playing, Steal An Egg about 1.39M, Brookhaven RP about 477k, Steal a Brainrot about 281k, Jujutsu Shenanigans about 243k, RIVALS about 219k, 99 Nights in the Forest about 212k, Adopt Me! about 185k, Blox Fruits about 171k, Dandy's World about 126k. Fishing games Fish It! (about 98k) and Fisch (about 96k), Volleyball Legends (about 76k) and Pet Simulator 99! (about 59k) are also in the top 30 [10] [third party].
- Record peaks were set by "grow and steal" style simulators: Grow a Garden peaked at about 22.3 million concurrent players on 23 August 2025 [11], Steal a Brainrot at about 25.4 million in October 2025 [12], 99 Nights in the Forest at about 14.2 million [13] [third party]. These show that a simple, social, idle-ish loop can still explode, but they were one-in-millions outcomes.
- The top 50 is "dominated by long-running live-service titles rather than new launches" (Newzoo and GEEIQ, H1 2026) [21] [third party].

### 1.2 Genre share and competition (Statroblox live data, 25 October 2026) [14] [third party]

| Genre | Share of players | Games tracked | Players per game | Top game's share | Read |
|---|---|---|---|---|---|
| Simulation | 37.1% | 14,889 | 401 | 23% | Largest, crowded; Tycoon alone 5,611 games |
| Survival (incl. horror) | 20.0% | 3,084 | 1,042 | 50% | Fastest growing (+30% week on week), but one title dominates |
| Roleplay and avatar sim | 9.4% | 1,782 | 849 | 32% | Pet Care subgenre about 3,963 players per game over only about 50 games |
| Action | 8.9% | 2,251 | 632 | 17% | Battlegrounds heavy, needs combat feel |
| Obby and platformer | 4.6% | 4,300 | 173 | 11% | Saturated |
| Shooter | 3.7% | 868 | 692 | 36% | Concentrated |
| Sports and racing | 3.4% | 817 | 662 | 14% | Gap candidate |
| RPG | 3.0% | 603 | 794 | 36% | Big content demand |
| Party and casual | 3.0% | 1,920 | 249 | 7% | Saturated, falling |
| Strategy (incl. tower defence) | 1.9% | 575 | 532 | 10% | Gap candidate; tower defence about 623 players per game |
| Puzzle | 0.7% | 449 | 238 | 12% | Small and falling |

Also flagged as high density subgenres: Pet Care and "1 vs All" (601 games, about 3,425 players per game) [14].

### 1.3 Gaps, and what that means for this person

- **Saturated for a newcomer:** obbies, party games, adventure, tycoons, and the "steal a ..." clones. Roblox's discovery FAQ also says games that look "virtually indistinguishable" from others may get reduced discoverability [6] [official], so cloning the current hit is now actively risky.
- **Gap candidates:** Strategy and tower defence (good players per game, top title holds only 10%), Sports and racing (top title 14%), and the Pet Care and 1 vs All subgenres [14] [third party, live snapshot; treat as momentum, not a lasting fact].
- **A fresh twist on a big genre works:** Fish It! was a more accessible take on Fisch and reached about 2.7M concurrent at peak, reportedly about US$3M a month [15] [third party, unverified estimate]. Its studio's other 19 games have no active players [15], which is a reminder that hits are rare even for teams that have one.
- **Horror and survival are growing** but the top game holds half the genre's players [14]; co-op horror also needs atmosphere, audio and level art that AI-written code does not solve.
- **Unverified:** several blogs claim "brainrot" games, horror, and specific mechanics are the 2026 trend [16][17]; they cite no method, and contradict each other.

---

## 2. What small new games realistically earn, and how discovery and ads work

### 2.1 Earnings reality

- Platform: 132 million daily active users (Q1 2026) [5] [official]; Roblox's DevEx fees were US$363 million in Q2 2026, up 15% year on year [18] [official filing].
- Earnings are extremely skewed. Reported figures from Roblox's developer conference: over 42,000 creators enrolled in DevEx, and the median earned about US$1,500 in the 12 months to June 2026, while the top 10 averaged about US$65.7M [19] [third party report of Roblox figures; unverified against Roblox's own page]. One analysis estimates about 85% of developers earn under US$100 a month [20] [third party, unverified].
- Revenue per daily user (third-party estimates, method not published): Simulator about US$0.08, RPG about US$0.06, Tycoon about US$0.05, Horror about US$0.03; games under 100 DAU about US$20 to 100 a month, 1k to 10k DAU about US$2k to 25k a month [22] [third party, unverified].
- Roblox does not publish D1 or D7 benchmarks openly. In Creator Analytics, benchmark scorecards against similar games appear once a game has 100+ DAU [23] [official]. Roblox's advice is to bring D1 and session time up to the benchmark before scaling acquisition, and it reads a weak D7 as a progression problem [23][24] [official]. Analytics can now show D1, D7 and D30 by acquisition source [25] [official].
- Rough targets quoted by developers: D7 at least 20%, 35%+ for growth [26] [DevForum user, flagged in the thread as an unreliable account; unverified]. A non-Roblox GameAnalytics snapshot gives D1 44% and D7 17% for the best hypercasual subgenres [27] [loose reference only].

**Illustrative scenario (my assumption, not a source):** 300 DAU, 2% of players buy something each day, average 100 Robux per buyer. That is 600 Robux spent a day; the creator keeps 70% [28], so about 420 Robux a day, about 12,600 a month, about US$48 a month at the DevEx rate. The 30,000 Robux DevEx minimum would take about 10 weeks. Creator Rewards (below) would add a little on top.

### 2.2 Premium Payouts are gone

- Engagement-based payouts (the old "Premium Payouts") were deprecated on 24 July 2025 and replaced by **Creator Rewards** [29] [official].
- Creator Rewards today: **Daily Engagement** pays 5 Robux per Active Spender per day when your game is one of the first three they launch that day and they play 10+ minutes (an Active Spender spent at least US$9.99 in 60 days). **Audience Expansion** pays 35% of a new or returning user's first US$100 of purchases in their first 60 days, only if your game averages 100+ DAU and you are ID verified [30] [official, updated 23 October 2026].
- **Roblox Plus** (US$4.99 a month, launched 30 April 2026) replaced Premium for new subscribers; new Premium sales stopped. Plus subscribers get paid private servers free; creators are paid up to 100 Robux per subscriber when the subscriber spends 60+ minutes in their paid private server in the past 30 days (top 5 servers per subscriber), and 250 Robux a month for three months for each new Plus subscriber signed up through your game's prompt (`PromptRobloxSubscriptionPurchase`) [31] [official]. A later report says Plus is limited to one free private server per game from 24 September [32] [third party, unverified].

### 2.3 Discovery for new games

- Recommended For You was changed on 15 June 2026 to a 28-day view, with signals for day 1, days 2 to 7 and days 8 to 28; the old qualified play-through rate was split into play-through, session quality and spend signals [5] [official].
- From the Discovery FAQ [6] [official]:
  - "Early signals kick in immediately"; ranking starts after a very low number of plays from any source, then the game is tested daily with small groups and impressions grow if it performs.
  - The most important signals are play-through rate, first-play bounce rate, play days per user and playtime per user; they are per-user averages, so small engaged games are not disadvantaged.
  - "There is no penalty for games that did not perform well at first."
  - Misleading metadata, leading with giveaways, and lookalike games reduce reach. Tags are not ranking factors, but wrong tags cause bounces.
  - Ads do not change RFY ranking, and players acquired through ads are excluded from RFY signals.
- Measurement change on 12 October 2026: more impressions counted, so play-through rate may look lower; Roblox says this is measurement only [7] [official].

### 2.4 The new publishing gate (most important for this person)

- Since 17 December 2025, publishing or updating a public game needed ID verification or a real-money purchase since 1 January 2025 [33] [official].
- Roblox Kids (5 to 8) and Select (9 to 15) launched on 19 May 2026 in Australia, New Zealand, the Netherlands and Indonesia, and globally on 16 June 2026 [9] [official].
- To reach **16+ only**: account in good standing and 2+ days old, age check (face estimation or ID), maturity questionnaire. No fee and no evaluation [8] [official].
- To reach **Kids and Select**: verified creator account (government ID for 18+), 2-Step Verification, a one-time **refundable 1,000 Robux fee per game** or two consecutive months of Plus or Premium, the full maturity questionnaire, and an evaluation [8][9] [official].
- **Conflict:** the Creator Hub page says the game needs **250 unique plays from highly engaged, age-checked players within 60 days** [8]; the July 2026 DevForum announcement says **500 highly engaged players** to enter and 25 over 60 days to stay [9]. The Creator Hub page is probably newer (the forum said lowering the threshold was coming), but check the Audience Reach dashboard. **[unverified which is current]**
- **Conflict:** expedited review is 50,000 Robux (Creator Hub) [8] versus 100,000 Robux (DevForum) [9]. Not relevant at this budget.
- "Highly engaged" weighs account tenure, playtime in your game and Robux spend anywhere on Roblox in the last 60 days [8]. Plus is only needed when pushing an update, not to stay live [9].
- Practical meaning: design the first version so 16 to 25 year olds enjoy it, not only young children, and expect to use Ads Manager's Engagement objective to reach the threshold.

### 2.5 Ads Manager today

- One ad product for games: a labelled sponsored tile on Home and in search results, up to 10 thumbnails at 16:9. Objectives: Plays, Earnings (limited) and Engagement. Auto-bidding is available [34] [official].
- Billing: a card (18+ only; a temporary US$1 hold, and US$5 charged on a first campaign submission, applied to the first bill; charges at a threshold such as US$100 or at month end) or ad credits bought with Robux (permanent; unused credits refunded when a campaign ends) [34] [official]. 1 ad credit costs 263 Robux since September 2025 (was 285) [35] [official].
- Minimum budget: not stated by Roblox; the API returns it in the error message [36] [official]. Older official rules were 10 ad credits minimum (5 a day for 2 days) [37] [official, 2023; may be outdated]. **[unverified current minimum]**
- Targeting: all players, new players, recent and lapsed (lapsed and recent need 10k+ or 20k+ players), plus location, age, gender, genre and device [34]. The Ads API's age groups are 13 to 17, 18 to 24 and 25+ [36] [official], so ads do not reach under-13s.
- Review: Roblox aims to moderate each ad within 24 hours; invalid traffic is refunded after 16 days [34] [official].
- **Engagement objective (beta)** is only for games not yet in Kids and Select and targets players who count toward the highly engaged threshold; it can cost more per play and does not stop itself at the threshold [9] [official].
- Cost per play: Roblox said in September 2025 it is 71% cheaper and "less than US$0.01" is possible [35] [official]; developers report about US$7 to 11 per 1,000 plays [35][38] [DevForum users]; one 2026 thread suggests 20k to 30k Robux total and about 12 ad credits a day to get noticed [26] [single developer]; a third-party benchmark claims US$0.45 per play [39] [third party; far out of line with the others, treat as unverified].
- **Budget sketch:** A$100 is roughly US$65 (check the current rate). At US$0.01 to 0.05 per play that buys about 1,300 to 6,500 plays. Spend only after D1 and session length look healthy, because ad players are excluded from discovery signals [6] and are reported to retain 20 to 30% worse [26] [unverified].

### 2.6 Australian context

- Roblox is outside Australia's under-16 social media ban as a gaming service [40] [press]. In August 2026 it gave the eSafety Commissioner an enforceable undertaking on child safety, and the Minister asked the Classification Board to review its PG rating [41] [press]. Expect more age gating, not less.

---

## 3. Monetisation rules and good practice

- **Game passes** (one-off) and **developer products** (repeatable) are bought with Robux; the creator gets 70% after the marketplace fee. Roblox says developer products generally monetise better because they repeat, warns that players downvote monetisation they dislike, and calls timers and appointment mechanics a poor fit for Roblox [28] [official]. Purchases must be recorded by the game itself (DataStoreService), or they can be lost [28].
- **Private servers** can be free or a monthly Robux price set by the creator; the game must be public, and they cannot be combined with paid access [42] [official]. Plus subscribers now get paid private servers free, with the creator paid as in 2.2 [31].
- **Experience subscriptions:** five fixed local currency tiers (US$2.99, 4.99, 7.99, 9.99, 14.99; needs ID or phone verification) or any Robux price of 49+. Creator share is 70% in month one and 100% after for local currency, 70% every month in Robux. Single tier only, same benefits on all platforms, battle passes allowed, no pointing users to buy elsewhere [43] [official].
- **Managed pricing:** Creator Hub has a Dynamic Price Check tool to test scripted prices [44] [official]; regional pricing for passes is described by a third-party guide [45] [unverified].
- **UGC (avatar items):** selling needs government ID verification (or a linked verified parent) [46] [official]; publishing avatar items is a Plus or Premium perk [31]. Not a good fit for 30 minutes a week.
- **Rewarded video ads** let creators earn from players watching an optional ad; it was expanding to "tens of thousands more creators" from late 2025 [35] [official; current eligibility unverified].
- **Paid random items (loot boxes):** any random outcome bought with Robux or Robux-bought currency (eggs, wheels, chests, luck boosts) must show every outcome with percentage odds that add to 100% before purchase; when `PolicyService:GetPolicyInfoForPlayerAsync` returns `ArePaidRandomItemsRestricted`, the game must offer an alternative (free path, fixed order, direct purchase at expected value, hide, block or move the player) and respect `IsPaidItemTradingAllowed` [47] [official, updated 23 October 2026]. In Brazil under-18s cannot use them [48] [official]. PEGI rates paid random items 16 from June 2026 [49] [third party]. **All three ideas below avoid them entirely**, which also keeps the content maturity label low.
- **Content maturity:** Minimal or Mild reaches Kids; Minimal, Mild or Moderate reaches Select; Restricted is 18+ verified only; "Content May Vary" (questionnaire not fully answered) is 16+ only. A game without accurate maturity information is restricted for everyone [8][50] [official].
- **Promotion rules:** thumbnails and videos must show real in-game content and must not misrepresent the core game; ambiguous imagery is discouraged; 16:9 at 1920 by 1080 is ideal; all are moderated [51] [official]. Misleading metadata, giveaway-led pages and lookalike games reduce reach [6]. Ads pass ad-policy review before serving [34][36].
- **Fair practice for this person (my recommendation, built on the above):** sell convenience and expression, never power over other players: cosmetics, extra save or loadout slots, x2 speed or auto-collect for PvE only, private servers, a modest monthly supporter subscription with cosmetics and a daily free reward. Show every price clearly. No timers that stop play.

---

## 4. DevEx (cashing out)

From the official Creator Hub page [1] [official]:

- **Rate:** 0.0038 USD per Earned Robux, US$114 for 30,000.
- **Higher rate:** 0.0054 for some Earned Robux from purchases by US players verified 18+ (developer products, passes, subscriptions, private servers). Start date not given on the page; a third-party page says 8 June 2026 [2] [unverified]. Whether an Australian creator earns it on US buyers' purchases appears yes (it depends on the buyer), but this is **[unverified]**.
- **Old balance:** Robux earned before 10am PT on 5 September 2025 cash out at 0.0035 and must go first.
- **Minimum:** 30,000 Earned Robux.
- **Eligibility:** at least 13, Roblox-verified email, a DevEx Portal account, an IRS **W-8** form on file for non-US taxpayers (an Australian would normally use W-8BEN; the page only says "W-8"), and full compliance with the Terms of Use and Community Standards. ID verification may be asked for if names differ.
- **Premium is not required.** Some third-party guides still say it is, and some say the minimum is 100,000 Robux [3]; both are outdated (Premium and the 100k minimum were dropped in January 2022 per a fan wiki [4] [unverified]). Premium can no longer be bought anyway [31].
- Australian income tax on DevEx earnings is outside this research: ask an accountant. **[unverified]**

---

## 5. AI tooling for Roblox (October 2026)

- **Roblox Assistant (in Studio):** April 2026 added Planning Mode (reads code and data model, asks questions, writes an editable plan), Mesh Generation, Procedural Model Generation, and playtesting tools that read logs, take screenshots and send keyboard and mouse input to find and fix bugs [52][53] [official and press]. Roblox reports 44% of the top 1,000 creators use Assistant or third-party AI through MCP [52].
- **Official Studio MCP server:** built into Studio (no separate download). Turn on in Assistant, then "Manage MCP Servers", "Enable Studio as MCP server". Claude Code is a quick-connect client; the CLI command is `cmd.exe /c %LOCALAPPDATA%\Roblox\mcp.bat` (Windows) or `/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP` (macOS), over stdio. Tools cover scripts, assets and generation, data model, running Luau in edit, client or server context, playtesting (start and stop play, console output, screenshots), simulated player input, docs, and choosing between open Studio windows. Connected clients can read and change your places [54] [official, updated 23 October 2026]. The older `Roblox/studio-rust-mcp-server` reference repo exists [55]. **Studio needs Windows or macOS**, so the human's machine must be one of those.
- **Rojo:** latest v7.7.1 (2 October; year not printed on the page, presumably 2026). v7.7.0 added `rojo syncback` (turn an existing place into a Rojo project), websocket serving and `.jsonc` [56] [official repo]. `rojo build` makes a `.rbxl` or `.rbxlx` for publishing; `rojo serve` plus the Studio plugin live-syncs while the MCP server playtests.
- **Lune:** standalone Luau runtime, latest v0.11.1 (21 October) [57] [official repo]. `@lune/roblox` can load place and model files and build a `DataModel` with `Instance.new`, which suits unit tests of pure game logic and checks on a built place outside Studio. Writing place files is not mentioned in recent release notes **[unverified here]**; Lune does not run a full Roblox game [58].
- **Open Cloud place publishing** [59] [official]:
  - `POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Published`
  - Headers: `x-api-key: <key>`; `Content-Type: application/octet-stream` for `.rbxl` or `application/xml` for `.rbxlx`.
  - API key permission: **universe-places** with **Write** on the chosen experience (the separate `universe.place:write` scope is for the PATCH that edits place settings, not for uploading a file) [59][60].
  - Returns `{ "versionNumber": N }`. HTTPS only. It does not update `EditableImage`, `EditableMesh`, `PartOperation` (unions), `SurfaceAppearance` or `BaseWrap`; places with those must be published from Studio.
  - **The experience must exist first.** The guide only publishes to an existing Universe ID and Place ID, and the Open Cloud reference lists no endpoint to create a universe or place [59][60] [official; absence inferred]. Create it once in Studio ("Publish to Roblox" or "Save to Roblox" creates the experience) [61]; creating from the Creator Hub web dashboard is described only by a third-party guide [62] **[unverified]**. Then CI can publish every build.
  - Monetisation items (passes, developer products) are still largely made in Creator Hub; Open Cloud coverage for them was a developer request in the Universes API thread [63] **[unverified current state]**.
- **Working pipeline for this person:** AI writes Luau in a Rojo project; Lune runs logic tests; Studio with the MCP server playtests (the human only has to have Studio open); `rojo build` then the Open Cloud POST publishes. Avoid unions (`PartOperation`) and SurfaceAppearance so API publishing always works.

---

## 6. Three game ideas

Constraints that shaped these: the first audience is age-checked 16+ (2.4); discovery rewards day 1 to day 28 return and co-play (2.3); there is no budget for live ops; a small game will often have one or two players in a server, so anything that needs a full server is risky; AI is strong at systems, data tables and UI and weak at "feel" and art; no paid random items.

### Idea 1 (recommended): "Seed Siege", a garden tower defence

- **Core loop:** Plant seeds on a grid that grow into defender plants between waves, then hold the path against waves of garden pests; harvests pay for new seed types and upgrades. Each run unlocks permanent seed research, and a new seeded "weekly field" with modifiers and a leaderboard appears automatically every Monday.
- **Why now:** Strategy and tower defence have good players per game and the top title holds only about 10% [14]; the garden theme borrows the proven appeal of Grow a Garden [11] without being a lookalike [6]; tower defence progression gives day 2 to 7 and 8 to 28 reasons to return [5][24]; it plays well solo (no empty-server problem) and better with friends (co-play is a signal) [6]. The theme and difficulty can suit 16+ and still pass Minimal or Mild maturity for Kids and Select later [50].
- **What players buy (fair):** cosmetic plant skins and garden themes (passes); a x2 speed pass and extra loadout slot (PvE convenience only); private servers for friend groups; a monthly "Head Gardener" subscription with a cosmetic set and a daily free seed bundle that any player can also earn [43]; developer products for revive-a-wave in solo only. No random seed packs; every seed is earned or bought directly.
- **Build size:** about 25 to 35 scripts in 10 systems: wave spawner and pathing, enemy table, plant (tower) placement and targeting, growth timers within a run, in-run economy, permanent research tree, DataStore saves with session locking, weekly field generator from a date seed plus leaderboard (OrderedDataStore), purchases (ProcessReceipt with idempotency), UI (shop, research, HUD), tutorial. Content lives in data tables, so AI can add seeds and pests in bulk before launch.
- **Biggest risk:** balance and content depth. Tower defence players finish content fast and expect new units; with 30 minutes a week, updates must be batched by AI and checked by numbers (simulated waves in Lune), not by hand.

### Idea 2: "Ghost Lap", a weekly time trial racer

- **Core loop:** Drive a simple kart through a short track against the ghosts of your own best lap and the top times, shaving tenths to climb a leaderboard. Every week a new track is generated from a seed and the board resets, with cosmetic rewards for finishing bands.
- **Why now:** Sports and racing has good players per game and a top title with only 14% [14]; asynchronous ghosts mean one player in a server is still a full experience; the weekly reset gives a built-in reason to return without human work [5].
- **What players buy (fair):** kart bodies, trails, horns (all cosmetic, identical physics); private servers for friend races; a supporter subscription with a monthly cosmetic; a "replay studio" pass to save and share runs. No paid speed.
- **Build size:** about 20 to 30 scripts in 8 systems: vehicle controller (client physics with server validation), track generator from spline pieces, checkpoints and anti-cheat timing, ghost recording and compressed storage, leaderboards, cosmetics and purchases, DataStore saves, UI.
- **Biggest risk:** driving feel. Vehicle physics needs many hand tuning passes by a human playing it, which this person cannot easily give; AI can write the code but cannot judge if it feels good. Ghost data storage limits also need care.

### Idea 3: "Hide the Gnome", a 1 vs All party game

- **Core loop:** One player is the garden owner hunting everyone else, who disguise themselves as garden objects; each short round rotates the hunter. Points unlock new props and disguises.
- **Why now:** the 1 vs All subgenre has very high players per game (about 3,425 over 601 games) [14]; it is strongly social, which the new discovery signals reward [5][6]; rounds need no new content to stay fun.
- **What players buy (fair):** disguise and hunter cosmetics, emotes and taunts, private servers (party games sell these well), a supporter subscription. Not "always be the hunter" tokens, which would be pay to win.
- **Build size:** about 15 to 25 scripts in 7 systems: round state machine, role rotation, prop disguise and hitboxes, hunter tools, scoring and unlocks, matchmaking into busy servers, bots to fill small lobbies, UI.
- **Biggest risk:** player liquidity. With a handful of concurrent players, rounds are empty or one-sided; bots help but are hard to make convincing, and ad-bought players do not stay [26]. Also the most crowded idea of the three in thinking style (many hide and seek games exist).

### Ranking

| Rank | Idea | Works with few players | Low upkeep | Fits AI-written code | Genre gap | Overall |
|---|---|---|---|---|---|---|
| 1 | Seed Siege (tower defence) | Yes | Yes (weekly field) | Strong (data and systems) | Yes [14] | Best fit |
| 2 | Ghost Lap (time trial) | Yes | Yes (weekly track) | Medium (needs feel tuning) | Yes [14] | Good, riskier build |
| 3 | Hide the Gnome (1 vs All) | No | Yes | Strong | Dense but busy [14] | Highest upside, highest risk |

**Recommendation: build Seed Siege first.** Launch to 16+ with a small, polished first world (about 10 seeds, 10 pests, 3 fields, the weekly field), watch D1 and session length for two weeks in Creator Analytics, then spend the ad budget in small Engagement campaigns to clear the Kids and Select threshold [8][9], pay the refundable 1,000 Robux fee (or two months of Plus), and only then add the subscription and cosmetics shop in a batched update.

---

## Sources

1. Roblox Creator Hub, Developer Exchange. https://create.roblox.com/docs/en-us/production/monetization/developer-exchange
2. Generalist Programmer, Robux to USD (third party). https://generalistprogrammer.com/tools/robux-to-usd/1000
3. RoLearn, Roblox DevEx guide (third party). https://rolearn.dev/guidance/roblox-devex-guide-requirements-rates
4. Roblox Wiki (fan), Create. https://roblox.fandom.com/wiki/Create
5. Roblox Newsroom, Optimizing Discovery: How Great Games Reach Millions of Players on Roblox (15 June 2026). https://about.roblox.com/newsroom/2026/06/optimizing-discovery-great-games-reach-millions-players-roblox
6. Roblox Creator Hub, Discovery FAQ. https://create.roblox.com/docs/discovery-faq
7. DevForum, Improved Discovery Measurement in Creator Analytics. https://devforum.roblox.com/t/improved-discovery-measurement-in-creator-analytics/4930122
8. Roblox Creator Hub, Roblox Kids and Select. https://create.roblox.com/docs/production/publishing/kids-and-select
9. DevForum, Roblox Kids and Select Global Launch: Upcoming Updates to Eligibility, Ads Manager, and Expedited Review. https://devforum.roblox.com/t/roblox-kids-and-select-global-launch-upcoming-updates-to-eligibility-ads-manager-and-expedited-review/4685717
10. Livecounts, Most Played Roblox Games Right Now (October 2026). https://livecounts.nl/roblox-charts/
11. Wikipedia, Grow a Garden. https://en.wikipedia.org/wiki/Grow_a_Garden
12. Wikipedia, Steal a Brainrot. https://en.wikipedia.org/wiki/Steal_a_Brainrot
13. Sportskeeda, Best Roblox games to play right now (October 2026). https://www.sportskeeda.com/roblox-news/best-roblox-games-to-play-right-now
14. Statroblox, Most Popular Roblox Genres in 2026, and Which Are Growing. https://statroblox.com/guides/most-popular-roblox-genres
15. RoWatcher, Fish It! tracker page. https://rowatcher.com/games/6701277882
16. creation.dev, Trending Roblox game genres 2026. https://www.creation.dev/learn/trending-roblox-game-genres-2026
17. Cubix, Top 10 Most Popular Roblox Games in 2026. https://www.cubix.co/blog/top-10-most-popular-roblox-games/
18. Roblox Corp, Form 8-K, Q2 2026 results. https://www.sec.gov/Archives/edgar/data/0001315098/000162828026051059/ex991-robloxq22026earnin.htm
19. SAYS, Roblox reveals its top 10 creators earned an average of RM267 million. https://says.com/my/tech/roblox-creators-earn-1-7-billion-developer-payouts
20. Shane the Gamer, Roblox Creator Economy Statistics. https://www.shanethegamer.com/research/roblox-creator-economy-analysis/
21. Tech Insider (Newzoo and GEEIQ report), Roblox older players: 4.05B hours in H1 2026. https://tech-insider.org/roblox-older-players-4-05-billion-hours-newzoo-2026/
22. Bloxg, Roblox Game Revenue Statistics 2026. https://bloxg.com/statistics/roblox-game-revenue-statistics
23. Roblox Creator Hub, Analytics. https://create.roblox.com/docs/production/analytics
24. Roblox Creator Hub, Analytics essentials. https://create.roblox.com/docs/production/game-design/analytics-essentials
25. DevForum, Analytics: View retention by acquisition source and select your benchmark set. https://devforum.roblox.com/t/analytics-view-retention-by-acquisition-source-and-select-your-benchmark-set/4010157
26. DevForum, How much money should I spent to "get into the algorithm"? https://devforum.roblox.com/t/how-much-money-should-i-spent-to-get-into-the-algorithm/4551439
27. GameDev Reports, GameAnalytics: Hypercasual Games metrics snapshot. https://gamedevreports.substack.com/p/gameanalytics-hypercasual-games-metrics
28. Roblox Creator Hub, Monetization. https://create.roblox.com/docs/production/monetization
29. Roblox Creator Hub, Engagement-based payouts (deprecated notice). https://create.roblox.com/docs/production/monetization/engagement-based-payouts
30. Roblox Creator Hub, Creator Rewards. https://create.roblox.com/docs/en-us/creator-rewards
31. DevForum, Introducing Roblox Plus. https://devforum.roblox.com/t/introducing-roblox-plus/4567894/1
32. PCGamesN, Roblox Plus private server limit. https://www.pcgamesn.com/roblox/plus-private-server-limit
33. DevForum, New Requirements to Publish and Update Public Experiences. https://devforum.roblox.com/t/new-requirements-to-publish-and-update-public-experiences/4143953
34. Roblox Creator Hub, Ads Manager. https://create.roblox.com/docs/production/promotion/ads-manager
35. DevForum, Ads for Creators: RDC Recap and What's Next (10 September 2025). https://devforum.roblox.com/t/ads-for-creators-rdc-recap-and-what%E2%80%99s-next/3929106
36. Roblox Creator Hub, Open Cloud advertising guide. https://create.roblox.com/docs/cloud/guides/advertising
37. DevForum, Sponsored Experiences moving to Ads Manager (2023). https://devforum.roblox.com/t/sponsored-experiences-moving-to-ads-manager/2661756
38. DevForum, Optimizing my game's Cost Per Play from Ads. https://devforum.roblox.com/t/optimizing-my-games-cost-per-play-from-ads/3047197
39. Bloxg, Roblox Advertising Benchmarks 2026. https://bloxg.com/statistics/roblox-advertising-benchmarks
40. The Nightly, Roblox rolls out major changes to avoid Australia's under-16s social media ban. https://thenightly.com.au/politics/gaming-site-roblox-rolls-out-major-changes-in-attempt-to-avoid-australias-under-16s-social-media-ban-c-20711923
41. Information Age (ACS), Australia puts Roblox "on notice" over child safety concerns. https://ia.acs.org.au/article/2026/australia-puts-roblox--on-notice--over-child-safety-concerns.html
42. Roblox Creator Hub, Private servers. https://create.roblox.com/docs/production/monetization/private-servers
43. Roblox Creator Hub, Subscriptions. https://create.roblox.com/docs/production/monetization/subscriptions
44. Roblox Creator Hub, Price optimization. https://create.roblox.com/docs/production/monetization/price-optimization
45. ProGameGuides, How to Enable Regional Pricing for Roblox. https://progameguides.com/roblox-creators/how-to-enable-regional-pricing-for-roblox-creator-guide/
46. Roblox Creator Hub, Marketplace policy. https://create.roblox.com/docs/marketplace/marketplace-policy
47. Roblox Creator Hub, Paid random items policy guidelines. https://create.roblox.com/docs/en-us/production/monetization/paid-random-items
48. Roblox Help, Brazil Digital ECA updates. https://en.help.roblox.com/hc/cs/articles/48706630819476-Brazil-Digital-ECA-Updates
49. Ask About Games, Loot Boxes and Paid Random Items. https://askaboutgames.com/news/loot-boxes-and-paid-random-items
50. Roblox Creator Hub, Content maturity. https://create.roblox.com/docs/production/promotion/content-maturity
51. Roblox Creator Hub, Thumbnails. https://create.roblox.com/docs/production/publishing/thumbnails
52. Roblox Newsroom, Roblox Studio going agentic (April 2026). https://about.roblox.com/newsroom/2026/04/roblox-studio-going-agentic
53. TechCrunch, Roblox's AI assistant gets new agentic tools to plan, build and test games (16 April 2026). https://techcrunch.com/2026/04/16/robloxs-ai-assistant-gets-new-agentic-tools-to-plan-build-and-test-games/
54. Roblox Creator Hub, Connect to the Roblox Studio MCP server. https://create.roblox.com/docs/studio/mcp
55. GitHub, Roblox/studio-rust-mcp-server. https://github.com/Roblox/studio-rust-mcp-server
56. GitHub, rojo-rbx/rojo releases. https://github.com/rojo-rbx/rojo/releases
57. GitHub, lune-org/lune releases. https://github.com/lune-org/lune/releases
58. docs.rs, lune crate. https://docs.rs/crate/lune/latest
59. Roblox Creator Hub, Usage guide for place publishing. https://create.roblox.com/docs/cloud/guides/usage-place-publishing
60. Roblox Creator Hub, Open Cloud Universes and Places reference. https://create.roblox.com/docs/cloud/reference/features/universes
61. DevForum, Cannot create, save as, publish as new experience. https://devforum.roblox.com/t/cannot-create-save-as-publish-as-new-experience/3979030
62. ExitLag, Roblox Creator Hub: Complete Guide for New Creators (third party). https://www.exitlag.com/blog/roblox-creator-hub/
63. DevForum, Open Cloud Universes API. https://devforum.roblox.com/t/open-cloud-universes-api-beta/2865540
