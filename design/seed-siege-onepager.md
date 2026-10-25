# Seed Siege: one page summary

**What it is.** A garden tower defence on Roblox. Bugs march along a path to your shed. You plant seeds beside the path; they grow into plants that shoo the bugs away. Beating bugs gives Sap to plant more. Every game, win or lose, gives Petals, which you spend on lasting upgrades and new seeds. You can play alone or with one friend on the same garden.

**Who it is for first.** Players 16 and over, because Roblox now shows new games only to age-checked 16+ players at first. It is kept gentle (cartoon bugs puff into leaves and run off, no blood, no scary bits, no typing, no gambling) so it can later be opened to younger players too.

**What is in the first version.**

- 10 seeds (cheap Thorn Sprout up to the big Oak Sentinel) and 10 pests (aphids up to a Night Possum boss). Some pests fly, hide underground, wear armour or split in two, so you have to pick the right plants.
- 3 gardens: Backyard Patch (10 waves, also the tutorial), Veggie Rows (15 waves, flying bugs), Night Orchard (20 waves, moles and the possum). Plus a harder Frost mode for each.
- A new **weekly garden every Monday**, made automatically from the date, with two twists (for example Fog or Drought) and a leaderboard. Everyone plays it with the same plants, so nobody can buy a better score.
- A research tree of 20 upgrades. A free player who plays about half an hour a day finishes it in about three weeks; after that, stars, Frost and the weekly board keep it going.

**The first five minutes.** No reading. You land straight in your garden. Short tips (8 words or fewer) point at one thing at a time: tap a seed, plant it, start the wave. By minute five you have planted, upgraded, used a slowing plant and sped the game up.

**Money (fair by design).** At launch only four things: 2x speed (149 Robux), a sixth seed slot (199), a "Second Wind" that saves a lost game once (25, and one free every day), and private servers (100 a month; Roblox Plus members get these free and Roblox pays us for their time there). Later, once the game is open to younger players: a monthly "Head Gardener" membership (about US$2.99) and cosmetic plant and garden styles. Never sold: Petals, random packs, or anything that helps on the leaderboard. Be realistic: a small game might make tens of dollars a month; the research expects about 10 weeks to reach Roblox's 30,000 Robux cash out minimum even if things go well.

**How it gets built (4 steps).**

1. **M1 Playable:** one garden, plant, upgrade, sell, win or lose.
2. **M2 Progress and saving:** all three gardens, Petals, research, the tutorial, saves that are safe across servers.
3. **M3 Weekly garden:** the Monday generator and the leaderboard.
4. **M4 Shop and polish:** purchases, co-op with a friend, sounds, phone layout, thumbnail. Then publish to 16+.

The game logic is tested automatically outside Roblox Studio (every number, the weekly generator, saving, purchases). What tests cannot judge is whether it feels fun: that is your 15 minute checklist in section 8.3 of the full spec.

**What you need to do.** Have Studio on a Windows or Mac computer. Do the first "Publish to Roblox" from Studio. Create the passes and products in Creator Hub and paste their numbers to the Builder. Do the 15 minute playtest at each step. Answer the maturity questionnaire honestly.

**Decisions for you** (details in section 11 of the spec):

1. Are the four launch prices OK?
2. Sell the sixth seed slot at launch, or wait?
3. Later, to reach younger players: pay the refundable 1,000 Robux fee or keep Roblox Plus for two months?
4. Membership price later: US$2.99 (needs ID or phone check) or 249 Robux?
5. Weekly reset Monday 10am (11am in daylight saving) eastern Australian time: OK?
6. Please search Roblox for another game already called "Seed Siege" before we publish.
7. Happy with "Nan" as the tip giving gardener and the Aussie backyard look?
8. 8 players per server, and co-op at launch or just after?

Full plan: `design/seed-siege-spec.md`.
