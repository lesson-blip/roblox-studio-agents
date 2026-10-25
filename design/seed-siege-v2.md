# Seed Siege v2: the change set

Version 2, 25 October 2026. Designer agent. A change set on top of `design/seed-siege-spec.md` (version 1, cited as "spec 3.2" and so on). It does **not** rewrite the spec: every section of the spec stays in force unless the table in section 0 says this file replaces or extends it.

Inputs: `design/seed-siege-onepager.md`, the spec, `research/2026-10-modern-td-review.md` (the Scout, cited as "review 6.3"), `build/BUILD_REPORT.md` (M1 and the m1-visuals branch), `src/shared/Logic` and `src/shared/Art`, `media/3d/preview-hero.png` and `media/3d/roblox-parts-game-1600x900.png`.

The owner approved exactly three changes:

1. **Funny Aussie characters:** Nan as host, plants with faces, bosses Kevin the Bin Chicken and Swoopy the magpie, more cheeky Aussie pests.
2. **Co-op for 1 to 4 players**, meeting in a hub called Nan's Backyard.
3. **A plant collection with rarities:** 24 plants from Common to Champion, earned only by playing, never sold.

Parked (only room is left for them, section 9): more game modes, weather, the Saturday event.

Audience: the **Builder** (Luau, from sections 2 to 7), the **Tester** (Lune, from sections 3, 4.7, 5 and 7), the **owner** (section 10 and the one pager).

---

## 0. What this file changes in the spec

| Spec section | What happens | Where in this file |
|---|---|---|
| 1 Pitch | Replaced | 1 |
| 2.2 First session | Extended: the tutorial run still starts on join; Kevin is the wave 10 finale; after the results the player walks into the hub | 4.2, 3.5 |
| 2.3 to 2.5 Days 1 to 28 | Extended: pods and the Almanac are the main day 1 to 28 pull | 5.9 |
| 3.1 Simulation rules | Extended: new plant and pest mechanics, plant statuses, plant level, 1 to 4 players | 3, 4.4 |
| 3.2 Seeds | Extended to 24 plants; the 10 keep every number | 2.2, 5.2 |
| 3.3 Pests | Extended to 20 pests; the 10 keep every number (some get Aussie display names) | 2.3 |
| 3.4 Fields | Wave tables replaced by version 2 tables; maps, start Sap, Petals unchanged; hpScale of Veggie Rows and Night Orchard changed | 3.5 |
| 3.5 to 3.6 Modifiers, weekly generator | Unchanged (the weekly field keeps the classic 10 plants and 10 pests until a later versioned generator) | 9 |
| 3.7 Balance | Extended with co-op tables; the version 1 table stays as a regression | 6 |
| 4.1 to 4.2 Sap, Petals | Extended: Sap is per player in co-op; Petals add a +10% mates bonus; a third currency, Gumnuts | 4.4, 4.6, 5.7 |
| 4.3 Research tree | Kept. Only the four "Unlock seed" nodes (L1, L2, L4, L7) change their effect to "Seed gift" | 5.5 |
| 4.4 Loadout | Extended to 24 plants; same slot counts | 5.6 |
| 5 Monetisation | Kept, with the collection rules added; Head Gardener's daily gift stays Petals only and can never reach pods | 5.8 |
| 6.2 to 6.5 Modules, services, remotes | Extended | 3.7, 4.7 |
| 6.6 DataStore schema | Replaced by schema 2 | 7 |
| 7 UI | Extended: hub HUD, gate panel, Almanac, pod reveal, co-op HUD | 4, 5.10 |
| 9 Milestones | Replaced from here on (M1 and m1-visuals are done) | 8 |
| 11 Decisions | Replaced | 10 |
| Appendix C prototype | Extended (new files only) | 6.1 |

Conventions are spec section 0, unchanged: `--!strict`, `task` library, pure Logic with no `require`, no services and no clock, `bind(L)`, half up rounding, Australian English, no em or en dashes in player text, comments or commits, Parts and simple MeshParts only.

---

## 1. Pitch (replaces spec 1)

Seed Siege is a co-op garden tower defence in an Aussie backyard. Meet your mates at Nan's Backyard, step onto a garden gate together, and plant a crew of cheeky plants with faces beside the path to shoo off bugs, swooping magpies, cockatoos, possums and Kevin the Bin Chicken before they reach Nan's shed. Every wave drops a Seed Pod for a named plant, so you grow your own collection of 24 plants from Common to Champion by playing, never by paying or rolling for Robux, with the chances shown on screen and a guarantee so nobody gets stuck. It plays solo or with up to three friends, with no typing, and the weekly garden still puts everyone on level soil.

Target player at launch is unchanged: age-checked 16+, kept Minimal or Mild so it can open to Kids and Select later (spec 1). Animals are always **shooed**, never hurt (section 2.4).

---

## 2. The cast

### 2.1 Nan (the host)

**Who she is.** A retired, cheerful backyard gardener in her seventies: cardigan, sunhat, gardening gloves, reading glasses on a chain. Warm, cheeky, unflappable, a little bit competitive. She calls everyone "love" or "mate", never tells you off, and turns every loss into "we'll get 'em next time". She is fond of the animals even while she shoos them ("Cheeky bird"). Her humour is gentle and dry, never mean, never crude.

**Model.** The existing `Art.Props` Nan (spec m1-visuals) stands on the hub verandah at full size; her head is the HUD portrait. Idle: sips a cuppa, waves when a player comes within 12 studs (one wave per player per 60 s). Reactions in runs come through the existing tip bubble with her portrait.

**Rules for her lines.**

- Tutorial tips stay at most 8 words (spec 7.7). Every other line is at most 14 words.
- Light Aussie touch only: "G'day", "mate", "love", "righto", "too easy", "ripper", "cuppa", "no worries". No slang that needs a glossary. Every line still makes sense to a kid in Ohio.
- She never says "kill", "die", "hurt", "attack" or "fight". Pests are shooed, sent packing, sent home.
- Lines are data in `Logic/NanLines.luau`: `{key, text, trigger, cooldown}`. A line with a cooldown is not repeated to the same player within that many seconds. When several lines share a trigger, pick the one this player has seen least (ties: list order), so it is deterministic and testable.

**Hub lines** (said in a bubble over her head to the player who triggers them, and in the HUD portrait):

| key | trigger | text |
|---|---|---|
| `hub_hello_first` | first time in the hub | G'day, love! I'm Nan. Stand on a garden gate to play. |
| `hub_hello` | enters the hub | Back again? Ripper. Kettle's on. |
| `hub_hello_win` | enters the hub after a win | Saw that from the verandah. Lovely gardening, mate! |
| `hub_hello_loss` | enters the hub after a loss | Pests got through? Happens to the best of us. |
| `hub_gate_solo` | alone on a gate for 5 s | Just you? No worries, I'll cheer extra loud. |
| `hub_gate_party` | a gate reaches 2 or more | Look at this crew! Those bugs won't know what's coming. |
| `hub_gate_full` | a gate reaches 4 | Full gate! Off you go, gardeners. |
| `hub_almanac` | walks up to the Almanac stand | That's my Seed Almanac. Every plant you grow goes in there. |
| `hub_display` | walks up to own display bed | Pick three favourites for your bed. Show 'em off. |
| `hub_swap` | walks up to the potting bench | Got spare Gumnuts? I'll swap you a pod. Fair's fair. |
| `hub_new_pod` | enters the hub with a new plant sprouted | Ooh, a new sprout! Have a look in the Almanac. |
| `hub_champion` | first Champion sprouted | A Champion! Haven't seen one of those since the Show in '82. |
| `hub_idle_kevin` | idle line | Kevin's been in the bins again. Cheeky bird. |
| `hub_idle_swoopy` | idle line | Swoopy's nesting in the gum tree. Wear a hat, love. |
| `hub_idle_possum` | idle line | Possum Pete was on the roof all night. Didn't sleep a wink. |
| `hub_idle_hoist` | idle line | Mind the Hills Hoist. It's older than me. |
| `hub_idle_cuppa` | idle line | Cuppa? No? More for me then. |
| `hub_idle_wattle` | idle line | Wattle's out early this year. Smells lovely. |
| `hub_tip_air` | idle line, player has lost to flyers | Flyers about? Dandelions and Wattle can reach the sky. |
| `hub_tip_hidden` | idle line, player has lost to moles | Moles hide underground. Mint Mist sniffs them out. |
| `hub_tip_armour` | idle line, player has lost to beetles | Beetles wear armour. A Macadamia cracks it right open. |

Idle lines: one every 45 to 75 s to a player standing within 30 studs of Nan (the gap is fixed per line: 45 + 5 times its index modulo 7, so no clock randomness is needed in Logic).

**In-run lines** (through the tip bubble, to every player in the run):

| key | trigger | text |
|---|---|---|
| `run_start` | run starts (not the tutorial) | Righto, gardeners. Here they come! |
| `run_clear_1` | wave cleared, no leaks | Too easy! |
| `run_clear_2` | wave cleared, no leaks (second pick) | Lovely work, that. |
| `run_clear_3` | wave cleared with leaks | Close one. Have a cuppa and plant some more. |
| `run_leak` | first leak of the run | Oi! Something got into the shed! |
| `run_low` | hearts fall to 5 or fewer | Getting close, love. Plant something quick! |
| `run_kevin` | Kevin spawns | It's Kevin! Hide the bins! |
| `run_kevin_snatch` | Kevin bags a plant | He's nicked a plant! It'll be back in a tick. |
| `run_kevin_dive` | Kevin's bin dive starts | He's in the wheelie bin. Wait for it... |
| `run_swoopy` | Swoopy spawns | Swoopy's swooping! Heads down, everyone. |
| `run_possum` | Possum Pete spawns | Possum Pete's off the roof. Big fella! |
| `run_wombat` | Wombat spawns | Wombat! He won't slow down for anyone. |
| `run_cocky` | first cockatoos of a run | Cockies! They'll ruffle your plants. |
| `run_turkey` | first brush turkey of a run | Brush turkey! He kicks mulch everywhere. |
| `run_shooed_boss` | a boss is shooed | Off you go, and don't come back! |
| `run_win` | run won | We did it! Cuppa's on me. |
| `run_loss` | run lost | Not to worry. Pests always come back, and so do we. |
| `run_ready_wait` | co-op, a player pressed Ready and others have not, after 8 s | Waiting on your mates. No rush. |
| `run_nap` | a teammate is marked napping (4.5) | Someone's having a nap. Their patch is open. |
| `run_pod` | a Ribbon or better pod drops for this player | A pod for you! Ooh, a good one. |
| `run_second_wind` | Second Wind used | Second wind! Back on your feet, love. |

The pest tips in spec 7.7 step 9 stay (each pest's `tip` field, at most 8 words; new pests' tips are in 2.3).

### 2.2 Plants with faces (24)

Every plant keeps the M1 Art rule: built from Parts in `src/shared/Art/Seeds.luau` with `Kit` (balls, squashed balls, sticks, cylinders, wedges, cones, `Kit.eyes`, `Kit.smile`), base at the context origin, facing +Z, 25 to 45 parts, parts tagged `head` (nods) and `jaw` where they snap. **Every plant now has a face**: two `Kit.eyes`, a mouth (`Kit.smile`, or a small dark ball for an "o" mouth) and, where listed, brows (two short dark sticks on the head, tagged `brow` so the client can tilt them for moods).

Faces have three moods driven by the client from the run state (no server data): **idle** (listed below), **busy** (brows down, while it shot in the last second), **cheer** (eyes squashed to arcs, a hop, when a wave is cleared with no leaks or on a win). On a loss, plants look at the shed and droop for 1 s. Collection level 5 adds a small flower crown (3 to 5 balls in the plant's accent colour) and level 10 a gold rosette (a gold cylinder disc and two ribbon wedges, SmoothPlastic, `#E7B53C`) pinned to the pot or stem. These are the "new look at 5 and 10".

| # | id | Name | Rarity | Role | Face and personality | Almanac line (bio) |
|---|---|---|---|---|---|---|
| 1 | `thorn` | Thorn Sprout | Common | Cheap all rounder, hits flyers | Grumpy little prickle: low brows, small frown that turns into a smirk when busy | "Not a hugger." |
| 2 | `sunpetal` | Sunpetal | Common | Sap each wave | Beaming, rosy cheeks, never stops smiling, spins on cheer | "Makes Sap and friends. Mostly Sap." |
| 3 | `burr` | Burr Vine | Common | Slows | Giggly and clingy, big eyes, tongue poking out | "Sticks to you like a burr. Because it is one." |
| 4 | `wattle` | Wattle Burst | Common | Fast weak shots, hits flyers | Bubbly golden pompom with tiny eyes, bounces on every shot | "Fluffy, yellow, and very, very excited." |
| 5 | `lilly` | Lilly Pilly Popper | Common | Medium range lobber, ground | Shy, pink berry cheeks, hides behind a leaf on cheer | "Pops berries. Says sorry every time." |
| 6 | `nettle` | Nettle Patch | Uncommon | Aura, ignores armour | Three small scowling heads that grumble together | "Three grumps, one patch." |
| 7 | `dandelion` | Dandelion Lofter | Uncommon | Long range, double vs flyers | Dreamy half closed eyes, yawns between shots | "Has a wish for every pest." |
| 8 | `saltbush` | Old Salty (Saltbush) | Uncommon | Bonus Sap when pests are shooed nearby | Laid back grey green bush, half smile, a tiny straw hat | "Thrifty. Picks up every drop of Sap." |
| 9 | `roopaw` | Kangaroo Paw | Uncommon | Knocks pests back | Sporty: red furry flower "paws", a sweatband, bounces on its toes | "Does its own stunts." |
| 10 | `grevillea` | Grevillea Spinner | Uncommon | Hits 3 targets, hits flyers | Show off, curly red flowers like a whirligig, winks | "Why hit one when you can hit three?" |
| 11 | `pumpkin` | Pumpkin Mortar | Rare | Splash, ground | Big jolly lad with a wide grin, belly laughs on cheer | "Lobs first, asks questions later." |
| 12 | `mint` | Mint Mist | Rare | Speeds nearby plants, reveals hidden pests | Cool and calm, half lidded eyes, sunglasses from level 5 | "Stay chill. Plants nearby certainly do." |
| 13 | `banksia` | Banksia Bomber | Rare | Splash that also hits flyers | Craggy friendly cone with one big toothy grin and bushy brows | "Bursts like a seed cone. Because it is one." |
| 14 | `pigface` | Pigface Carpet | Rare | Slowing aura, small poison | Snorting, giggling ground cover, pink flowers like little snouts | "Snort. Snort. Snort. Sorry." |
| 15 | `macadamia` | Macadamia Cracker | Rare | Ignores armour | Tough nut: square jaw, nut shell helmet, determined brows | "Cracks shells. Cracks jokes. Mostly shells." |
| 16 | `chilli` | Chilli Burner | Ribbon | Burn, ignores armour | Hot headed: red face, steam puffs from the top on cheer | "Spicy, and proud of it." |
| 17 | `snapjaw` | Snapjaw | Ribbon | Big hits, double vs Heavy | Toothy show off, grins wide, snaps at the air on cheer (pests always flee, never bitten on screen) | "All bark. Big bark though." |
| 18 | `bottlebrush` | Bottlebrush Blaster | Ribbon | Rapid fire, extra vs flyers | Punk: spiky red brush hair, energetic, headbangs on cheer | "Turn it up to eleven." |
| 19 | `fingerlime` | Finger Lime Zinger | Ribbon | Sours pests so they take more | Permanently puckered sour face, eyes squeezed | "So sour, pests take extra." |
| 20 | `oak` | Oak Sentinel | Blue Ribbon | Long reach, detects hidden pests | Wise old bloke: bushy brows, mossy moustache | "Seen it all. Twice." |
| 21 | `boab` | Boab Bastion | Blue Ribbon | Huge single hits, double vs bosses | Gentle giant bottle trunk, slow blink, soft smile | "Big, slow, and very patient." |
| 22 | `waratah` | Waratah Flare | Blue Ribbon | Burns every pest in reach | Proud, dramatic red flower, eyebrows up, poses on cheer | "Born for the spotlight." |
| 23 | `wollemi` | Wollemi Pine | Champion | Commander: reveals and boosts damage nearby | Ancient and wise: round glasses, a tiny walking stick | "Older than the dinosaurs. Well, nearly." |
| 24 | `gumtree` | Grand Old Gum | Champion | Long range splash on everything, detects | Huge ghost gum with a face in the bark; a kookaburra sits on top and laughs on cheer | "Has seen a hundred summers and one very loud kookaburra." |

The first 10 keep their M1 models and get faces added. **Visual briefs for the 14 new plants** (preview units, 1 unit = 2 studs, same palette approach as `Art/Seeds.luau`):

- **Wattle Burst:** short green stem stick (r 0.05) to y 0.5; head = one yellow ball r 0.4 (`#F2C230`) ringed by 10 smaller yellow balls r 0.14 on its surface (pompom); eyes on the front, small "o" mouth. Shot: a tiny yellow ball.
- **Lilly Pilly Popper:** dark glossy green bush (3 balls r 0.35 to 0.45, `#2F7A3A`) with 6 bright pink berries (balls r 0.09, `#E2558B`); eyes peek over a leaf; pink cheek dots. Shot: a pink berry on an arc.
- **Old Salty:** low wide grey green bush (squashed balls scale 1.4, 0.7, 1.2, `#9DB59A`), half smile, tiny straw hat (yellow cylinder brim plus small cylinder crown). No shot; when it pays a bonus, a gold drop rises from it.
- **Kangaroo Paw:** 4 tall stems (sticks to y 1.2) each ending in a red furry "paw" (squashed ball 0.6, 1, 0.6, `#C7372F`) bent forward; face on a green leaf fan at the base; white sweatband (thin cylinder) on the face leaf. Shot: the front paw kicks forward (tag `jaw` reused as the kick part).
- **Grevillea Spinner:** green needle bush (6 thin sticks fanned) with 3 red curly flowers (each 4 small red balls on a curve) that spin (tag `head`); winking eyes. Shots: three red sparks at once.
- **Banksia Bomber:** brown orange cylinder cone (Kit.cone 4 tiers, `#C9762E`) covered with 12 small dark nubs (balls r 0.05); one wide toothy grin (white box teeth); bushy brows. Shot: a cone segment on a high arc with a splash ring.
- **Pigface Carpet:** flat mat of 8 fat green finger leaves (squashed balls scale 1.6, 0.4, 0.5) spread round; 4 pink daisy flowers (pink disc cylinder plus yellow centre) each with a snout nose (pink squashed ball with two dark dots); face in the middle. Pulses when its aura ticks.
- **Macadamia Cracker:** round brown nut body (ball r 0.45, `#8A5A33`) with a lighter cracked shell helmet (half ball on top, a dark zigzag of 4 short sticks); square jaw (a box under the eyes); green leaf collar. Shot: a nut that hits with a "crack" ring.
- **Bottlebrush Blaster:** grey stick stem; a red cylinder brush (r 0.25, h 0.8, `#D0312D`) with 20 short red sticks radiating (spiky hair) on top of the face; face on the brush base. Shots: rapid red bristles.
- **Finger Lime Zinger:** slim green finger fruit (ball scale 0.6, 1.4, 0.6, `#6E8F2E`) on a thorny stick; eyes squeezed to lines, mouth a small puckered "o"; lime pearls (tiny pale green balls) puff out on each shot.
- **Boab Bastion:** a fat bottle trunk (ball scale 1.3, 1.6, 1.3, pale grey brown `#B49A82`) with stubby branch sticks on top and a few leaf clumps; slow blinking face low on the trunk. Shot: a big seed pod (oval ball) thrown slowly.
- **Waratah Flare:** a large red dome flower (half ball of 16 red cone tiers ringed by red bracts: 8 wedges fanned, `#D1202F`) on a stiff stem; eyebrows raised; shot is a ring of warm light (PointLight flash, no fire particles on animals).
- **Wollemi Pine:** tall dark green stepped cone (Kit.cone 6 tiers, `#2C5E3F`) with bubbly bark on the trunk; round glasses (two thin black cylinders); a tiny walking stick stick. Shows a soft green ring on the ground for its boost range when selected.
- **Grand Old Gum:** pale white trunk (two curved stick segments, `#E8E2D6`), 3 clumped canopy balls (`#5E8C5A`) like the garden gums, a face in the bark, a kookaburra on the top branch (brown ball body, white head ball, dark eye stripe stick, big beak cone) that tilts its head back on cheer. Shot: a gumnut cluster on a high arc, splash ring.

### 2.3 Pests: the full roster (20)

The 10 bugs of spec 3.3 keep every number; some get an Aussie display name (the id never changes). 10 new pests are added. **All animals (`animal = true`) are shooed, never hurt** (rules in 2.4).

| # | id | Display name | Health | Speed | Reward | Leak | Armour | Resist | Traits and behaviour | Fields (v2 waves) | Threat | Min wave | Tip (8 words max) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `aphid` | Aphid | 18 | 1.2 | 3 | 1 | 0 | none | none | B, O | 2 | 1 | Aphids are quick but weak. |
| 2 | `ant` | Sugar Ant | 34 | 1.0 | 4 | 1 | 0 | none | none | B, V, O | 3 | 1 | Sugar ants come in big lines. |
| 3 | `snail` | Snail | 110 | 0.5 | 8 | 2 | 2 | poison 1.5 | Heavy | B, V, O | 8 | 2 | Snails are tough. Upgrade or add plants. |
| 4 | `moth` | Bogong Moth | 36 | 1.4 | 5 | 1 | 0 | none | Flying | V, O | 4 | 3 | Moths fly! Not every plant reaches them. |
| 5 | `caterpillar` | Caterpillar | 140 | 0.8 | 10 | 2 | 0 | fire 1.5 | Regenerates 4 a second unless burning | B, V, O | 10 | 4 | Caterpillars heal. Hit them hard and fast. |
| 6 | `beetle` | Christmas Beetle | 200 | 0.7 | 12 | 3 | 5 | pierce 0.75, blunt 1.25 | Heavy | V, O | 16 | 5 | Beetles wear armour. Try Macadamia or Pumpkin. |
| 7 | `wasp` | Wasp | 70 | 1.7 | 8 | 2 | 0 | poison 0.5 | Flying | V, O | 7 | 6 | Wasps are fast flyers. |
| 8 | `mole` | Mole | 170 | 0.8 | 14 | 3 | 1 | blunt 1.25 | Burrows: hidden 3 s, up 2 s | O | 14 | 5 | Moles hide! Mint Mist finds them. |
| 9 | `slugmum` | Slug Mum | 280 | 0.5 | 18 | 4 | 0 | fire 0.5, poison 1.5 | Heavy; splits into 3 aphids | V, O | 26 | 8 | Slug Mum brings the kids. |
| 10 | `possum` | Possum Pete (boss) | 2600 | 0.45 | 150 | 20 | 4 | fire 0.75, bite 1.25 | Heavy; boss bar; animal | O | 200 | boss | Possum Pete is huge. Gang up on him! |
| 11 | `blowie` | Blowie | 14 | 1.8 | 2 | 1 | 0 | none | Flying; comes in swarms | B, V | 2 | 2 | Blowies swarm! Quick plants help. |
| 12 | `stinkbug` | Stink Bug | 60 | 0.9 | 6 | 1 | 1 | none | **Pong:** when shooed, plants within 1.0 tile attack at 0.6x rate for 2 s | B, O | 6 | 3 | Stink bugs pong when shooed. Spread out. |
| 13 | `toad` | Cane Toad | 120 | 0.6 | 9 | 2 | 0 | poison 0.5 | **Hop:** every 3.0 s moves 1.0 tile forward at once; animal | V | 10 | 4 | Cane toads hop ahead. Slow them down! |
| 14 | `magpie` | Magpie | 80 | 1.3 | 9 | 2 | 0 | none | Flying; **swoop:** for the last 1.5 s of every 5.0 s it flies low (counts as not flying, so ground plants can reach it) and moves 1.5x; animal | V | 8 | 5 | Magpies swoop low. Ground plants get a go. |
| 15 | `cocky` | Cockatoo | 90 | 1.1 | 9 | 2 | 0 | none | Flying; **ruffle:** plants within 1.0 tile of it attack at 0.7x rate (lasts 0.5 s after it leaves); animal | V | 9 | 6 | Cockies ruffle plants. Shoo them from afar. |
| 16 | `turkey` | Brush Turkey | 260 | 0.6 | 15 | 3 | 3 | none | Heavy; **scratch:** every 5.0 s, plants within 1.0 tile are buried in mulch (stunned) for 2 s; animal | O | 18 | 6 | Brush turkeys kick mulch. Keep some distance. |
| 17 | `flyingfox` | Flying Fox | 180 | 0.9 | 14 | 3 | 1 | none | Flying and Heavy (Snapjaw cannot reach it, Boab can); animal | O | 15 | 7 | Flying foxes are big flyers. |
| 18 | `wombat` | Wombat (mini boss) | 900 | 0.4 | 50 | 8 | 8 | blunt 1.5, pierce 0.5 | Heavy; **unstoppable:** ignores slow and knockback; boss bar (but not a boss for `bossMult`); animal | O | 70 | 10 | Wombats don't slow down. Crack that armour! |
| 19 | `kevin` | Kevin the Bin Chicken (boss) | 1800 | 0.5 | 120 | 15 | 3 | bite 1.25 | Heavy; boss bar; animal. **Snatch:** every 7.0 s he bags the plant within 1.5 tiles with the most Sap spent on it (ties: placed first) that is not already stunned: stunned 5 s. **Bin dive:** the first time his health falls to 50% or less he hops into a wheelie bin for 3.0 s: nothing can target or damage him (burn timers pause), he keeps rolling along the path | B (wave 10, at 0.35 health), O (wave 20) | 180 | boss | Kevin nicks plants! Shoo him quick. |
| 20 | `swoopy` | Swoopy the Magpie (boss) | 1500 | 0.6 | 120 | 15 | 2 | none | Flying; boss bar; animal. **Big swoop:** for the last 2.0 s of every 6.0 s she flies low (ground plants can reach her); when a swoop starts, plants within 1.5 tiles flinch (stunned 1 s) | V (wave 15, at 0.6 health) | 160 | boss | Swoopy swoops! Ground plants, now's your chance. |

Distances are from the pest's position on the route to the plant's tile centre, in tiles, with the usual `<= r + 1e-9`. All timers count game time (TICK steps) from the pest's spawn.

**Visual briefs for the new pests** (style of `src/shared/Art/Pests.luau`: big `Kit.eyes`, round bodies, thin stick legs tagged `leg`, feet on the origin facing +Z; bugs 15 to 30 parts, animals 20 to 45, bosses up to 60). Flyers hover at y 1.6 (units) and bob; when "low" (swoop) they drop to y 0.5 with a whoosh trail.

- **Blowie:** metallic blue green ball r 0.2 (`#1F6F6A`, Reflectance 0.2), huge red eyes (`Kit.eyes` size 0.09 with red irises `#C9302C`), two clear wings (thin boxes, Transparency 0.5, tagged `leg` for flapping), tiny legs. Swarms share one buzz sound.
- **Stink Bug:** flat shield body (ball scale 1.2, 0.45, 1.3, olive brown `#6B6A3A`), small head ball, worried eyes; on shoo a green cloud (3 pale green balls, fade 0.8 s) puffs out and the affected plants scrunch their faces for 2 s.
- **Cane Toad:** squat olive ball (scale 1.2, 0.7, 1.1, `#7A7A3F`) with 8 darker warts (balls r 0.04), gold eyes on top, wide smile, chunky back legs; a hop is a 0.4 s arc of 1 tile with a "boing".
- **Magpie:** black body ball (scale 0.9, 0.8, 1.3), white nape and wing patches (squashed white balls), grey white beak (cone), red brown eyes; wings are two wedges tagged `leg`. Swoop: drops low with a white streak.
- **Cockatoo:** white body ball, yellow crest (3 yellow wedges fanned up, tagged `head`, rises when ruffling), grey beak cone, black eyes, grey feet; ruffled plants show 3 small white feathers floating above them.
- **Brush Turkey:** black body ball (scale 1.1, 1, 1.4), bald red head ball (`#C8302E`) on a stick neck, yellow collar ball, upright fan tail (squashed black ball rotated); scratch: kicks 6 small brown balls backwards; buried plants show a brown mulch mound ball up to their waist with eyes peeking out.
- **Flying Fox:** brown grey ball body, rusty orange collar, pointy fox face (cone nose), big dark membrane wings (two thin wedges with 3 finger sticks each, tagged `leg`); slow heavy flaps.
- **Wombat:** chunky rounded brown body (ball scale 1.3, 0.9, 1.6, `#7B6248`), small round ears, square dark nose (box), stubby legs; a determined frown; dust puff behind it. 1.5x the size of a beetle.
- **Kevin the Bin Chicken:** white body (ball scale 1.0, 0.9, 1.5, `#ECEBE6`), black bald head and long neck (two sticks and a ball, `#1E1E1E`), long curved black beak (3 sticks bending down), black tail feather wedges, thin dark legs with knees; a slightly smug half lidded look; under one wing a plain yellow chip packet (a yellow box, no logo or text). Snatch: the bagged plant is covered by a dark green bin bag (a squashed ball with a tie on top), the plant's eyes peek out, and the bag pops off after 5 s. Bin dive: a green wheelie bin (box body `#2F6B3A`, red lid wedge, two black cylinder wheels) appears; Kevin is inside with only his beak and eyes over the rim, rolling along the path; after 3 s he hops out. Shooed: he flaps off over the fence clutching the chip packet, squawking.
- **Swoopy the Magpie:** 1.6x the Magpie, with a fluffy chest, fierce but comic eyebrows, a twig in her beak (she is guarding her nest); her swoop leaves a long white streak; a tiny nest (brown torus of sticks) appears in a garden gum while she is on the field. Shooed: flies back to her nest in the gum.
- **Possum Pete** (existing model): add a name tag on his boss bar only. Shooed: he scampers up the shed roof and off.

### 2.4 Tone and maturity rules (extend spec 1)

- Animals are never hit by sharp things on screen. When a plant's shot reaches a pest with `animal = true`, the client draws the hit as a harmless splash (water droplets and leaves), the animal flinches with a comic "hmph", and nothing sticks in it. Bugs keep the M1 sparks and leaf poofs.
- Animal health bars are labelled as a **Shoo meter** (same bar, a small hand icon instead of a heart). When it empties the animal gives up and leaves the garden (flies, waddles, hops or scampers off the edge); it never falls over, flashes red or disappears in a poof.
- Leaks: a pest that reaches the shed "raids the shed" (the shed door rattles, a heart icon pops off), as in M1.
- Allowed humour: grumpy faces, a stink cloud (Mild crude at most: no sound of passing wind, no words about it), Kevin's chip packet, Nan's jokes. No real brands, no real people, no copying of other games' characters, no May Gibbs characters (her Banksia Men and gumnut babies are protected; our banksia is our own design).
- No free text anywhere, still (spec 1). Co-op uses pings (4.4), not chat.

---

## 3. Rules changes (extend spec 3.1)

Everything in spec 3.1 stays. These additions are exact; WaveSim implements them and the Tester checks them. `design/prototype/sim2.py` is the reference (section 6.1).

### 3.1 New plant data fields

`Seeds.luau` gains optional fields (all 10 classic plants leave them nil):

| Field | Type | Meaning |
|---|---|---|
| `rarity` | `"C" | "U" | "R" | "RB" | "BR" | "CH"` | Required for all 24 (section 5.1) |
| `targets` | integer | Single target plants hit this many pests per attack (the largest `d` first; ties to the earliest spawned) |
| `airSplash` | boolean | Its splash also hits flying pests |
| `crack` | boolean | Direct hits ignore armour (still at least 1 damage) |
| `knock` | number | Each hit moves a non boss, non `unslow` pest back this many tiles (`d = max(0, d - knock)`); half for Heavy pests |
| `auraSlow` | number | Aura plants: every ground pest hit gets slow = max(current, value) with timer 0.5 s |
| `sour` | `{mult, time}` | The target takes `mult` times damage from every source (direct and over time) while the timer runs; refresh, never stack |
| `bossMult` | number | Damage multiplier against `boss` pests (replaces `heavyMult` against a boss) |
| `burnAura` | `{dps, time}` | Each attack applies Chilli style burn to every candidate in range (including flying) instead of a hit |
| `reveal` | number | While grown, hidden pests within this range can be targeted by any plant (like Mint Mist's range) |
| `dmgBuff` | `{amount, range}` | While grown, other plants within range get damage x(1 + amount); the largest applies, never stacked, never on itself |
| `bounty` | integer | While grown, a pest shooed within its range gives its owner this many extra Sap (one bounty plant per pest: the first in placement order) |
| `bio`, `face` | string | Almanac line and a face preset name for the Art module |

### 3.2 New pest data fields

| Field | Type | Meaning |
|---|---|---|
| `displayName` | string | Shown in UI (id unchanged) |
| `animal` | boolean | Drives the 2.4 visual rules only |
| `hop` | `{every, dist}` | Every `every` seconds: `d += dist` |
| `swoop` | `{every, low, speedMult, flinch}` | Low (not flying) while `clock mod every >= every - low`; speed x`speedMult` while low; when it turns low, plants within 1.5 tiles get stun = max(stun, `flinch`) if `flinch > 0` |
| `ruffle` | `{mult, radius}` | Each tick, plants within `radius` get rate debuff `mult` for 0.5 s |
| `scratch` | `{every, radius, stun}` | Every `every` seconds, plants within `radius` get stun = max(stun, value) |
| `snatch` | `{every, radius, stun}` | Every `every` seconds, the one plant within `radius` with the most Sap spent on it that is not stunned gets stun = `stun` |
| `binDive` | `{atFraction, time}` | The first time health falls to `atFraction` of max or below (and is above 0), the pest is untouchable for `time` |
| `pong` | `{mult, time, radius}` | When shooed, plants within `radius` get rate debuff `mult` for `time` |
| `unslow` | boolean | Ignores slow and knockback |

### 3.3 Plant statuses

Each plant gains `stun` (seconds) and `debuff` (`mult`, `timer`).

- At the start of each tick (before pests move), every plant's debuff timer counts down by TICK; at 0 the multiplier resets to 1.
- A new debuff applies when its multiplier is smaller than or equal to the current one, or the current timer is 0; it sets the multiplier and the timer to max(current timer, new time). (Takes the strongest, refreshes, never stacks.)
- In step 4 (plants act): a plant with `stun > 0` subtracts TICK from `stun` and does nothing else that tick (its cooldown does not count down). Auras that are not attacks (Mint buff, Wollemi reveal and boost, Saltbush bounty, Sunpetal income) keep working while stunned.
- Rate used for the cooldown: `seed.rate * (1 + researchRate) * (1 + mintBuff) * debuffMult`.

### 3.4 Tick order additions (spec 3.1 "Tick order")

0. (new) Plant debuff timers count down.
1. Spawn, unchanged.
2. For each pest in list order: add TICK to its `clock`; burrow phase (unchanged); swoop phase (and flinch); bin dive timer counts down; move (`unslow` pests ignore slow; low swoopers use `speedMult`); hop; slow, sour and burn timers (burn does no damage while untouchable); regeneration; ruffle; scratch; snatch.
3. Leaks, unchanged.
4. Plants act in placement order. Candidates skip untouchable pests. `flying` means "has Flying and is not low right now". Hidden pests are candidates if the plant detects or the pest is within range of a grown Mint Mist or a grown Wollemi `reveal`. Damage:

```
base   = seed.damage * LEVEL_DMG[level] * (1 + researchDmg) * seedlingFactor * rankMult * (1 + dmgBuff) * vsMult
vsMult = bossMult if the target is a boss and the seed has one,
         else heavyMult if the target is Heavy and the seed has one,
         else airMult if the target is flying, else 1
typed  = base * pest.resist[type] * (1.3 if fire and Heatwave) * (sour.mult if soured)
direct hit: final = max(1, typed - armour) unless the seed has crack (then final = max(1, typed))
over time:  final = typed
```

   `rankMult = 1 + 0.04 * (rank - 1)` where `rank` is the owner's collection level of that plant (1 to 10) captured when it is planted (section 5.2). Splash with `airSplash` includes flying pests. After a direct hit: slow, burn, sour and knock apply to the target (knock after damage).
5. Shooed pests: Sap (4.4), then the first grown bounty plant in range pays its owner, then pong, then removal, then splits, unchanged.

**Event log additions:** `stunned {plant, by, time}`, `debuffed {plant, by, mult}`, `hopped {pest}`, `swoop {pest, low}`, `snatched {pest, plant}`, `binDive {pest}`, `bounty {plant, sap}`. The Broadcaster forwards them so the client can play the animations in 2.3.

**New pest flags in `PestSnapshot`:** 8 low (swooping), 16 untouchable (bin dive), 32 soured. New per plant fields in `RunUpdated` plants list: `stun` (true while stunned), `debuff` (true while debuffed), `owner` (slot), `rank`.

### 3.5 Version 2 wave tables (replace spec 3.4 waves; maps unchanged)

Group format as spec 3.4: pest x count every gap from start; `(at H health)` means `hpMult = H`. Changes from version 1 are in bold.

**Backyard Patch** (`hpScale 1.0`, unchanged): 1 aphid x4 every 1.5 from 0. 2 aphid x8 every 1.0 from 0. 3 ant x6 every 1.2 from 0; **blowie x5 every 1.0 from 4**. 4 ant x10 every 1.0 from 0. 5 snail x2 every 4.0 from 0; aphid x8 every 0.8 from 2. 6 ant x12 every 0.8 from 0; **stinkbug x3 every 2.5 from 6**. 7 caterpillar x3 every 3.0 from 0; ant x8 every 0.8 from 2. 8 snail x5 every 2.5 from 0; **blowie x10 every 0.6 from 1**. 9 caterpillar x4 every 2.5 from 0; ant x14 every 0.7 from 1. 10 **kevin x1 from 0 (at 0.35 health)**; snail x4 every 2.0 from 2; ant x12 every 0.6 from 4.

**Veggie Rows** (**`hpScale 1.25`**, was 1.2): 1 ant x8 every 1.2 from 0. 2 aphid x14 every 0.7 from 0; ant x4 every 1.0 from 5. 3 moth x6 every 1.2 from 0; ant x8 every 1.0 from 2. 4 snail x4 every 2.5 from 0; moth x6 every 1.0 from 3. 5 caterpillar x4 every 2.0 from 0; **blowie x12 every 0.6 from 1**. 6 **moth x10 every 0.8 from 0; magpie x3 every 2.0 from 2**. 7 beetle x3 every 3.5 from 0; ant x14 every 0.6 from 2. 8 wasp x6 every 1.5 from 0; **toad x3 every 2.5 from 1**. 9 caterpillar x6 every 1.8 from 0; **cocky x4 every 1.8 from 2**. 10 slugmum x2 every 6.0 from 0; **magpie x6 every 1.2 from 2**. 11 beetle x5 every 2.5 from 0; wasp x8 every 1.2 from 3. 12 slugmum x3 every 4.0 from 0; **cocky x6 every 1.2 from 1**. 13 **toad x6 every 1.5 from 0**; wasp x10 every 1.0 from 2. 14 beetle x7 every 2.0 from 0; slugmum x3 every 4.0 from 4; **blowie x20 every 0.4 from 1**. 15 **swoopy x1 from 0 (at 0.6 health); magpie x8 every 1.0 from 3; beetle x5 every 2.0 from 2**.

**Night Orchard** (**`hpScale 1.15`**, was 1.1): 1 ant x10 every 1.0 from 0. 2 snail x3 every 2.5 from 0; aphid x10 every 0.7 from 2. 3 mole x3 every 3.0 from 0; ant x10 every 0.8 from 1. 4 moth x10 every 0.8 from 0; caterpillar x3 every 2.5 from 2. 5 mole x5 every 2.5 from 0; **stinkbug x4 every 2.0 from 2**. 6 beetle x4 every 3.0 from 0; wasp x6 every 1.2 from 2. 7 slugmum x3 every 4.0 from 0; mole x4 every 2.5 from 2. 8 **flyingfox x4 every 2.5 from 0**; moth x12 every 0.7 from 1. 9 beetle x6 every 2.5 from 0; mole x6 every 2.0 from 2. 10 possum x1 from 0; ant x20 every 0.6 from 2. 11 wasp x14 every 0.7 from 0; slugmum x3 every 4.0 from 2. 12 mole x10 every 1.5 from 0; **turkey x3 every 3.0 from 3**. 13 caterpillar x10 every 1.2 from 0; **flyingfox x6 every 1.5 from 2**. 14 slugmum x5 every 3.0 from 0; beetle x7 every 2.0 from 1. 15 **wombat x1 from 0; mole x10 every 1.2 from 1; moth x14 every 0.5 from 3**. 16 beetle x10 every 1.6 from 0; wasp x14 every 0.7 from 2. 17 **turkey x5 every 2.5 from 0**; mole x10 every 1.4 from 2. 18 caterpillar x14 every 1.0 from 0; **flyingfox x8 every 1.6 from 2**; wasp x12 every 0.8 from 4. 19 mole x14 every 1.0 from 0; slugmum x6 every 2.5 from 2; beetle x8 every 1.6 from 4. 20 possum x1 from 0; **kevin x1 from 12 (at 0.8 health)**; beetle x10 every 1.5 from 2; wasp x14 every 0.7 from 6; mole x10 every 1.2 from 8.

**Boss waves** (for pod draws, 5.3): Backyard 10; Veggie 15; Orchard 10, 15, 20.

The classic version 1 tables stay in `Fields.luau` as `Fields.classic` (not playable) so the version 1 balance and determinism tests keep running unchanged.

### 3.6 Weekly field

Unchanged (spec 3.6 and Appendix A vectors still hold). Level soil uses the **classic 10 plants at rank 1** and the classic 10 pests. Co-op weekly runs are allowed and never post scores (spec 3.6 already says only solo runs post).

### 3.7 Logic modules (extend spec 6.3)

New pure modules in `src/shared/Logic` (no `require`, no services, no clock; `bind(L)` where they need others):

| Module | Contents |
|---|---|
| `Cast` | Display names, `animal`, faces, bios, tips for all plants and pests (UI data only; the numbers stay in `Seeds` and `Pests`) |
| `NanLines` | The lines in 2.1 as data; `pick(trigger, seenCounts) -> key` (least seen, ties list order) |
| `Zones` | `split(waypoints, n) -> { ["x,y"] = slot }` (4.3) |
| `Coop` | Scaling tables (4.4) and `shareOf(n)`, `startSapFor(field, bonuses, n)`, `hpScaleFor(n)` |
| `Party` | Pure gate party state machine (4.2): `new()`, `join(p, userId, now)`, `leave`, `choose(p, userId, fieldId, mode, profileView)`, `tick(p, now) -> (p, event)`; events `countdown`, `start`, `cancel` |
| `Almanac` | Rarity tiers, `SPROUT`, `LADDER`, `rankMult`, `addPod(profile, plantId) -> (profile, change)`, `grow(profile, plantId) -> (profile, ok, err)`, `owned(profile)` |
| `Drops` | Field drop tables, boss and Frost tables, pity, `draw(profile, ctx, rand) -> (profile, drop)` where `rand` is a function returning a float in [0, 1) passed in by the caller, so Lune can use a fixed sequence |
| `Gumnuts` | Earn rules and swap prices (5.7) |
| `SaveSchema` | Schema 2 (section 7) |

Changed modules: `Seeds` (24 plants, new fields), `Pests` (20 pests, new fields), `Fields` (version 2 waves, `classic` kept), `WaveSim` (sections 3 and 4.4), `Economy` (`petalsForRun` mates bonus, Gumnuts lines), `Validate` (new payloads), `Views` (co-op shapes, Almanac view), `Progression` (gifts instead of unlocks, 5.5).

---

## 4. Co-op for 1 to 4 players

### 4.1 Approach chosen: one server, a hub and separate garden plots

**Decision: runs happen in the same server as the hub, each party on its own garden plot. No TeleportService reserved servers.**

Reasons:

1. **M1 already works this way.** `PlotService` hands out plot indices at `Visuals.PLOT_GAP` (180 studs) apart, `RunManager` keeps one run per plot and sends snapshots only to that run's players, and the WaveSim is pure and cheap (a full Night Orchard run is about 0.1 s of CPU in Lune). Twelve runs at once is well within one server.
2. **It can be tested in Studio.** TeleportService does not work in Studio playtests; a teleport based design could only be tested on the live game. Same server co-op can be tested with Studio's local server and 2 to 4 test clients (Test, Clients and Servers), which is how every M3 "done when" below is checked.
3. **One place to publish.** The Open Cloud publish pipeline (spec 6.1) uploads one place. Reserved servers would need a second place, its own publish, and teleport data checks.
4. **No loading screen between hub and garden.** Walking off a gate puts you in the garden in under a second; after the run you walk back among the others. The hub stays busy because players come back to it between runs.
5. **Rejoining and inviting are simpler.** An invited friend lands in your server and walks to your gate.

Limits we accept: server size caps the crowd (12 players, below) and a busy server shares CPU between runs. If the game ever outgrows this, the run code does not care where it runs: a later change can start the same `RunManager.start` in a reserved server.

**Numbers:**

- Max players per server: **12** (Game Settings, Places). Plot slots: **12**, so every player can be in a solo run at once.
- Plot `i` origin: `Visuals.plotOrigin(i)` unchanged (`(i - 1) * 180` studs along X). The hub sits at `Visuals.HUB_ORIGIN = (0, 0, -600)`, far enough that no plot is in view.
- **Server builds only what needs collision or authority:** for a claimed plot, the 96 tiles (with `X`, `Y`, `IsPath`, `Bed` and new `Zone` attributes), the ground slab and the fence colliders (so avatars cannot walk off). **The decor moves to the client:** `Art.Garden` decor is built by each client for the plot it is in only, and destroyed when it leaves. This keeps the replicated part count at about 120 per plot (instead of 1,628) and means a phone never draws 12 gardens. Plots are built when claimed and cleared when released (spec 6.4 already builds on claim).
- The hub is built by the server once (it needs collision for walking): budget 2,500 parts.

### 4.2 The hub: Nan's Backyard

A wide Aussie backyard, about 200 by 140 studs, in the same look as the garden (`Art.Garden` pieces reused: fences, gums, Hills Hoist, shed, deck, barbie). Avatars load here (`Players.CharacterAutoLoads` becomes true; M1 set it false). Roblox's default third person camera and movement are used in the hub. Chat stays off (spec m1-visuals); the emote wheel is turned back on in the hub only.

```
  north (back fence, three gum trees, Swoopy's nest)
  +---------------------------------------------------------------------+
  |  [Almanac stand]        [Hills Hoist]        [Nan's shed + potting   |
  |   (book on a lectern,                          bench: Seed Swap]      |
  |    Plant parade bed)                                                  |
  |                                                                       |
  |  [Display beds: 12 small raised beds in two rows of 6, one per        |
  |   player in the server, name sign, their 3 favourite plants]          |
  |                                                                       |
  |  [Gate 1]   [Gate 2]   [Gate 3]   [Gate 4]     [Weekly board]         |
  |   (timber gate arches along the side fence, 4 stepping stones each)   |
  |                                                                       |
  |  [Nan on the verandah, tips board]                [Kevin's bins]      |
  |                                                                       |
  |  [Back deck: SPAWN, barbie, chairs]                                   |
  +---------------------------------------------------------------------+
  south (house wall)
```

- **Spawn:** the back deck (a `SpawnLocation` with no forcefield visuals, Neutral). First ever join skips the hub: the tutorial run starts on join exactly as spec 2.2 (on a plot; the avatar is placed at the gardener spot). After the tutorial results, "Back to Nan's" walks you into the hub with `hub_hello_first`.
- **Nan:** on the verandah, 12 studs from spawn. A `ProximityPrompt` "Chat with Nan" (no typing: it shows her next tip line and a "Show me how to play" button that replays the tutorial tips in a solo Backyard run).
- **Garden gates (party pads):** four timber gate arches. Each has 4 stepping stones (5 by 5 studs) in front of it, a sign above showing the chosen field, players `n/4` and the countdown, and a small Robux free "Invite mates" button panel that shows on the screen of anyone standing on it.
- **Almanac stand:** a big open book on a lectern; `ProximityPrompt` "Open Almanac" opens the Almanac UI (5.10). Beside it the **Plant parade bed**: the 24 plants in a curved bed, each shown as a seedling if nobody in the server owns it, or full size in its rarity's frame colour if somebody does, so players see what exists.
- **Display beds:** one per player (assigned in join order, freed on leave). Three favourites stand in the bed at their real level look (crown at 5, rosette at 10), with the player's display name and title on a timber sign (display name from Roblox, never typed). Players walk past and see each other's collections.
- **Potting bench (Seed Swap):** at Nan's shed, `ProximityPrompt` "Seed Swap" (5.7).
- **Weekly board:** the weekly garden's card and the top 10 (spec 7.3 data, drawn on a SurfaceGui).
- **Kevin's bins:** three wheelie bins by the side gate; Kevin (the boss model, idle animation) pokes his head out of one every 40 s and ducks back when a player comes within 10 studs. Pure decoration.
- **Room left for parked features (section 9):** an empty paved area by the weekly board (future mode gates), a rain gauge on the Hills Hoist post (future weather), a blank "What's new" noticeboard on the shed wall.

### 4.3 Forming a party (no typing)

**Gates.** The server checks every 0.25 s which stone each avatar's HumanoidRootPart stands on (a simple position in box check against each stone's CFrame and size; no Touched events). Rules (implemented in `Logic/Party` as a pure state machine, driven by `HubService`):

1. Stepping on a free stone of a gate joins that gate's party. The first player is the **host** (a small sunhat icon over their head). A player can be in one party only; stepping onto another gate's stone leaves the first.
2. The host's screen shows the **gate panel**: field cards (only fields the host has unlocked; Frost toggle if the host has cleared Night Orchard; the weekly garden card), last choice preselected. Other members see the choice and cannot change it.
3. When the host has a field picked, a **15 s countdown** runs. A new member joining resets it to at least 8 s. The host has "Start now". Anyone stepping off leaves; if the host leaves, the next member by join order becomes host and the countdown restarts at 15 s.
4. At 0: `RunManager.start(members, fieldId, mode)`. If no plot is free (all 12 busy, cannot happen with 12 players but kept), the gate shows "All gardens busy, one moment" and retries every 2 s.
5. Members who have not unlocked the field still play it (a friend can carry a newer friend); first clear rewards apply to their own profile only when they win.

**Solo without a gate.** The hub HUD has a big **Play** button (bottom right). It opens the same field picker and starts a solo run at once. Spec 2.2's "no menu before play" still holds for the first session.

**Invites (Roblox's own social prompt).** The gate panel and the hub HUD have **Invite mates**. It calls `SocialService:PromptGameInvite(player, options)` from the client after `SocialService:CanSendGameInviteAsync(player)` returns true (Builder: check the current `ExperienceInviteOptions` fields; put the host's userId in the launch data if supported). When an invited friend joins this server, Nan's arrow points them to the host's gate (the server reads `player:GetJoinData()` launch data; if missing, it points to the gate of any friend in the server, found with `Player:IsFriendsWith`, cached per pair). If Roblox puts them in another server, the hub shows "Your mate is in another garden. Join them?", which calls `TeleportService:TeleportAsync(game.PlaceId, {player}, options)` with `ServerInstanceId` set to the friend's server (from the MemoryStore record in 7.3; Builder checks the current TeleportOptions API). Following a friend through the Roblox app's Join button also works and needs nothing from us.

**After a run.** Results screen buttons: **Play again** (same party, same field; starts when every member present has pressed it, or 20 s after the first press with whoever pressed), **Back to Nan's** (walk into the hub at the gate you left from), **Next field** (host only, when unlocked).

### 4.4 Inside a co-op run

**Zones (each player defends a stretch of path).** `Zones.split(waypoints, n)`:

1. For each path tile, its route distance is the `d` at which the route passes its centre.
2. For each plantable tile, find the path tiles at the smallest Euclidean distance from its centre; its key is the smallest route distance among them.
3. Sort plantable tiles by (key, y, x) and cut the list into `n` runs in order: the first `N mod n` runs get `floor(N / n) + 1` tiles, the rest `floor(N / n)`. Slot 1 (the host) gets the gate end, slot `n` the shed end. Solo runs have no zones.

On screen each zone's tiles get a soft tint in the player's colour (slot colours: teal `#4E8A90`, amber `#E8735A`, purple `#7B5EA7`, gold `#C8913A`) and the player's name on a small stake at its first tile. Slots are assigned in party join order.

**Sap per player, hearts shared.**

| Players | Pest health x | Sap share (each player gets this fraction of every pest reward and wave bonus) | Start Sap each (fraction of the field's start Sap) | Team income vs solo |
|---|---|---|---|---|
| 1 | 1.0 | 1.0 | 1.0 | 1.0 |
| 2 | 1.7 | 0.85 | 0.85 | 1.7 |
| 3 | 2.2 | 0.75 | 0.75 | 2.25 |
| 4 | 2.5 | 0.68 | 0.68 | 2.72 |

- Each player's Sap is their own: `round(reward * ownerSapMult * share)` to every player for every pest shooed by anyone; wave bonus `round((25 + 5n) * share)` each; Sunpetal and Saltbush pay only their owner (with the owner's rank). Start Sap each = `floor((field.startSap + ownResearchStartSap) * share)`.
- Health multiplier applies to every spawn (and split children) on top of `hpScale`, Frost and `hpMult`. It is read at **each wave start** from the number of seated players (present, or away but within the 180 s hold of 4.5), so if someone leaves, the next wave gets easier. Pests already on the path keep their health.
- Hearts are shared: `20 + max(hearts research bonus of any member)`.
- Research bonuses apply per owner: damage, rate and range to their own plants; start Sap and Sap multiplier to their own Sap; growth bonus to their own plants.
- Plant cap: 20 per player and 64 per run (solo keeps 40).
- Each player's loadout is their own (5 or 6 slots); teammates may bring the same plant.
- Second Wind is solo only (spec 3.1, unchanged).

**Ready, not Start.** In co-op the Start wave button becomes **Ready** and shows `Ready 1/3`. The wave starts when every seated player is ready, or 20 s after the first Ready (a ring fills around the button). Napping players (4.5) count as ready. Auto start (settings) still works and counts as pressing Ready.

**Speed is a vote.** Each player picks 1x, 1.5x or 2x; the run uses the lowest choice. 2x is offered when **any** member owns Fast Forward (a friend's pass helps the whole party; nobody is pushed to buy). Weekly runs stay capped at 1.5x.

**Pings (no typing).** Long press (or right click) a tile or pest to open a ring of 4 pings: **"Plant here?"** (a seed icon), **"Help!"** (a red !), **"Watch out!"** (an eye, on a pest), **"Nice one!"** (a thumbs up). The ping shows for 4 s to the party with the sender's slot colour. Rate 2 a second, burst 3. Pings are icons only, never text.

**Seeing each other.** Each member's avatar stands at a gardener spot beside their zone (the zone's tile nearest the plot's front edge, 1 tile outside the grid), can walk within the plot fence and plays a watering animation when they plant. The camera stays the fixed plot camera of M1. The HUD shows each member as a small chip: headshot (`Players:GetUserThumbnailAsync`, fallback a coloured circle), slot colour, Sap, Ready tick.

### 4.5 Leaving, napping and rejoining

- **Napping:** a seated player who takes no action (no plant, upgrade, sell, target, ready or ping) for two build phases in a row is **napping**: shown with a "zzz" over their chip and avatar, counted as ready, and their zone is **open**: anyone may plant on its free tiles (the planter owns the plant). Any action wakes them; tiles stay open until the end of the current wave, then new planting there is theirs again (existing plants keep their owners).
- **Leaving a co-op run** (`LeaveRun`, closing the game or a disconnect): the run goes on for the others. The leaver's seat is **held for 180 s**: their plants keep working, their Sap is kept and their zone stays theirs (open to others as if napping). After 180 s the seat is released: their remaining Sap is split equally among seated players (floored, remainder to the lowest slot), their plants become **team plants** (any player may upgrade them by paying; nobody may sell them), and the zone stays open for the rest of the run. Health scaling drops at the next wave start (4.4).
- **Rejoining:** a player who comes back to the same server within the hold is reseated: plants, Sap and zone back, camera to the plot. If Roblox sends them to a different server, the MemoryStore record (7.3) offers "Your garden is still going. Go back?" which teleports them to that server (4.3). After the hold, there is no way back into that run; the run's progress already given (Petals for waves cleared, pod draws) stays with them.
- **A leaver's rewards:** pod draws are granted at each wave end and kept. Petals for waves cleared up to leaving are granted on leave, as a loss (spec 4.2). No clear bonus.
- **When everyone has left** (or the last seat's hold ends) the run ends as a loss and the plot is released.
- **The host** has no power inside a run beyond choosing the field before it. There is no kick (nothing a player can do in a run hurts another's zone; the worst is doing nothing, which napping handles).

### 4.6 Rewards per player

- **Petals:** every player gets the full amount of spec 4.2 for the run, plus **+10% "Planted with mates"** (rounded down) when 2 or more players were seated at the end. Solo is never penalised.
- **Pods:** each player rolls their own draws with their own pity counters (5.3): one per wave cleared while seated, boss and win draws to those seated at that moment.
- **Gumnuts, stars, first clears, unlocks, gifts, wave ribbons:** each player's own profile, from the run result.
- **Weekly score:** only solo weekly runs post (spec 3.6).

### 4.7 Server authority and remotes (extend spec 6.5)

Unchanged principles: the client sends intents only; every handler checks `not_ready`, validates with `Validate`, takes a rate limit token, runs in `pcall`, returns `{ok, err, data}`. The server never accepts a cost, damage, position other than a tile, owner, slot, reward, pod, plant level or drop from the client.

New services: `HubService` (hub build, gate polling every 0.25 s, parties via `Logic/Party`, display beds, Nan lines in the hub), `AlmanacService` (pod grants, grow, swap, favourites, pending pity choices), `PresenceService` (MemoryStore active run records, cross server rejoin). `RunManager` gains seats (slot to player), holds, napping, Ready and speed votes. `PlotService` gains 12 slots and the server only build of 4.1.

| Remote | Kind | Payload | Rate (per player) | Server checks and errors |
|---|---|---|---|---|
| `RequestStart` | RF | as spec | 1 per 2 s | Solo start from the Play button (unchanged shape). Refused while in a party: `in_party` |
| `GateLeave` | RF | none | 1 a second | In a party (`not_in_party`) |
| `GateChoose` | RF | `fieldId, mode` | 2 a second | Host only (`not_host`); field unlocked for the host and mode allowed (`locked`) |
| `GateStartNow` | RF | none | 1 per 2 s | Host only; field chosen (`no_field`) |
| `PlaceSeed` | RF | as spec | 8 a second | Plus: tile in the caller's zone or an open zone (`not_your_zone`); seed in the caller's loadout; caller's cap (`too_many_plants`); caller's Sap |
| `UpgradePlant` | RF | as spec | 8 a second | Caller owns it, or it is a team plant (`not_yours`); paid from the caller's Sap |
| `SellPlant` | RF | as spec | 8 a second | Caller owns it (`not_yours`); team plants cannot be sold (`team_plant`); refund to the caller |
| `SetTargetMode` | RF | as spec | 8 a second | Owner or team plant |
| `StartWave` | RF | none | 2 a second | Solo: as spec. Co-op: toggles the caller's Ready |
| `SetSpeed` | RF | `speed` | 2 a second | Records the caller's vote; 2 needs any member to own Fast Forward (`needs_pass`) and not weekly |
| `Ping` | RF | `kind: 1..4, x: int 0..11, y: int 0..7` or `kind, pestId: int` | 2 a second, burst 3 | In a co-op run |
| `LeaveRun` | RF | none | 1 a second | Solo: as spec. Co-op: leaves (4.5) |
| `RejoinRun` | RF | none | 1 per 5 s | A live record for the caller (7.3); reseats or teleports |
| `GrowPlant` | RF | `plantId: string <= 24` | 2 a second | Enough pods (`no_pods`), below level 10 (`max_level`) |
| `SwapPod` | RF | `plantId` | 1 a second | Discovered (`not_discovered`), below level 10, Gumnuts (`no_gumnuts`), daily limit (`swap_limit`) |
| `PickPity` | RF | `plantId` | 1 a second | A choice is pending (`no_choice`) and the plant is one of its options (`bad_choice`) |
| `SetFavourites` | RF | `plantIds: array of 0 to 3 strings` | 1 a second | Owned (level 1 or more), no repeats |
| `SetLoadout` | RF | as spec, ids from 24 | 1 a second | Owned (level 1 or more) instead of spec's derived unlocks |
| `PartyUpdated` | RE | gate states: field, mode, members (userId, slot, host), countdown | | to everyone in the hub, on change |
| `RunUpdated` | RE | spec shape plus `seats = {userId, slot, sap, ready, napping, away}`, plants with `owner`, `team`, `rank`, `stun`, `debuff`, zones as a 96 character string of slot digits (`0` path, `1` to `4`, `o` open) | | |
| `PodDrop` | RE | `{plantId, tier, forced, sprouted, levelReady, pityLeft = {R, RB, BR, CH}}` | | to that player only |
| `PityChoice` | RE | `{tier, options = {plantId}}` | | to that player only |
| `NanSays` | RE | `key` | | |
| `PingShown` | RE | `{slot, kind, x, y | pestId}` | | to the run's players |

`Invite` and `AcceptInvite` from spec 6.5 are dropped (Roblox's own invite prompt and gates replace them).

### 4.8 Anti-grief rules

1. You can plant only in your own zone (or an open one). Nobody can block your best tiles.
2. You can sell only your own plants. Nobody can sell a friend's plant or a team plant.
3. You can upgrade your own plants and team plants, never a teammate's (so nobody spends a friend's plan for them).
4. Your Sap is yours; nobody can spend it. There is no giving of Sap, plants, pods or anything else between players (no trading, no gifting at launch).
5. Speed is the lowest vote: one player cannot rush others.
6. Waves start when all are ready or after 20 s: one player cannot hold the run hostage, and napping players count as ready.
7. No text anywhere: names come from Roblox display names; pings are icons.
8. A leaving player never ends the run for others.
9. Rate limits per player on every remote (4.7); pings are capped so they cannot be spammed.

---

## 5. The plant collection (the Seed Almanac)

### 5.1 Rarity tiers

Named for an Australian agricultural show (Royal Easter Show style ribbons). Colours are for frames and pod shells; the name is always written, so colour is never the only signal (spec 7).

| Tier | Code | Frame colour | Pod shell | Plants |
|---|---|---|---|---|
| Common | C | soil brown `#8A6A4A` | plain brown pod | 5 |
| Uncommon | U | leaf green `#4E8A3A` | green pod | 5 |
| Rare | R | sky blue `#3A78B5` | blue pod | 5 |
| Ribbon | RB | ribbon red `#C0392B` | red pod with a ribbon | 4 |
| Blue Ribbon | BR | royal blue `#1F3F8F` with gold edge | blue pod with a gold ribbon | 3 |
| Champion | CH | gold `#E7B53C` with a rosette | gold pod with a rosette, sparkles | 2 |

### 5.2 Plants: stats at level 1 and growth to level 10

"Level" here is the **collection level** (rank 1 to 10), separate from the in-run upgrade level 1 to 3 (spec 3.1, unchanged). Stats below are at collection level 1 and in-run level 1, before research. In-run upgrades still cost 0.6x then 1.0x the plant's cost.

| id | Rarity | Cost | Grows | Damage | Range | Rate | Type | Air | Special |
|---|---|---|---|---|---|---|---|---|---|
| `thorn` | C | 60 | 0 | 8 | 2.5 | 1.0 | pierce | yes | none |
| `sunpetal` | C | 75 | 1 | 0 | 0 | 0 | none | no | 20 / 30 / 45 Sap at each wave end once grown |
| `burr` | C | 70 | 1 | 3 | 2.0 | 1.2 | pierce | no | Slow 30% for 2 s |
| `wattle` | C | 70 | 0 | 4 | 2.0 | 2.0 | pierce | yes | none |
| `lilly` | C | 80 | 1 | 14 | 3.0 | 0.6 | blunt | no | none |
| `nettle` | U | 90 | 1 | 3 | 1.5 | 2.0 | poison | no | Aura, ignores armour |
| `dandelion` | U | 100 | 1 | 8 | 4.0 | 1.4 | pierce | yes | x2 vs flying |
| `saltbush` | U | 90 | 1 | 0 | 2.0 | 0 | none | no | Bounty +2 Sap per pest shooed in range |
| `roopaw` | U | 100 | 1 | 10 | 1.5 | 0.5 | blunt | no | Knock back 0.6 tile (0.3 Heavy, none on bosses and Wombat) |
| `grevillea` | U | 110 | 1 | 6 | 2.5 | 1.0 | pierce | yes | Hits 3 targets |
| `pumpkin` | R | 130 | 2 | 22 | 3.5 | 0.4 | blunt | no | Splash 1.0, ground only |
| `mint` | R | 110 | 1 | 0 | 1.5 | 0 | none | no | Plants in range +15 / 20 / 25% rate; reveals hidden pests in range |
| `banksia` | R | 140 | 2 | 12 | 3.0 | 0.5 | blunt | yes | Splash 1.0 including flying |
| `pigface` | R | 120 | 1 | 2 | 1.5 | 1.0 | poison | no | Aura, ignores armour, slows ground pests 25% |
| `macadamia` | R | 150 | 2 | 20 | 2.5 | 0.6 | blunt | no | Crack: ignores armour |
| `chilli` | RB | 150 | 2 | 6 | 2.5 | 0.8 | fire | yes | Burn 6 a second for 3 s |
| `snapjaw` | RB | 170 | 2 | 55 | 1.5 | 0.4 | bite | no | x2 vs Heavy |
| `bottlebrush` | RB | 160 | 2 | 5 | 3.0 | 3.0 | pierce | yes | x1.6 vs flying |
| `fingerlime` | RB | 150 | 1 | 8 | 3.0 | 0.8 | pierce | yes | Sour: target takes x1.25 from everything for 3 s |
| `oak` | BR | 320 | 3 | 30 | 4.5 | 0.8 | pierce | yes | Detects hidden pests (for itself) |
| `boab` | BR | 260 | 3 | 90 | 3.0 | 0.25 | blunt | no | x2 vs bosses, x1.3 vs Heavy |
| `waratah` | BR | 220 | 2 | 0 | 2.0 | 1.0 | fire | yes | Burn aura: burns every pest in range 8 a second for 3 s |
| `wollemi` | CH | 300 | 3 | 20 | 3.5 | 0.6 | pierce | yes | Reveals hidden pests within 3.0 for all plants; other plants within 2.5 deal +20% damage |
| `gumtree` | CH | 400 | 3 | 40 | 5.0 | 0.5 | blunt | yes | Detects; splash 1.2 including flying |

The first 10 rows' numbers are spec 3.2 unchanged.

**Growth from collection level 1 to 10.** `rankMult = 1 + 0.04 * (level - 1)` (level 10 = x1.36), applied to the plant's main number:

| Plant | What grows | Level 1 | Level 5 | Level 10 |
|---|---|---|---|---|
| Every plant with damage (including burn from Chilli and Waratah) | damage x`rankMult` | x1.00 | x1.16 | x1.36 |
| `sunpetal` | income, rounded half up | 20 / 30 / 45 | 23 / 35 / 52 | 27 / 41 / 61 |
| `burr` | slow +0.01 per level | 30% | 34% | 39% |
| `mint` | buff +0.005 per level | 15 / 20 / 25% | 17 / 22 / 27% | 19.5 / 24.5 / 29.5% |
| `saltbush` | bounty +1 at level 5 and 10 | 2 | 3 | 4 |

Range, rate, cost and growth time never change with collection level (keeps the game readable). Level 5 and 10 also change the look (2.2). The weekly field ignores collection levels (everyone rank 1).

### 5.3 Seed Pods: where they come from

**One draw = one pod for one named plant.** Draws happen on the server and are shown at once (a pod pops out of the ground by the shed, flies to the player's chip, and a card shows the plant, its tier and "3 of 5 to sprout").

| Source | Draws |
|---|---|
| Each wave cleared (while seated) | 1 from the field's table (Frost: the Frost table) |
| Each boss wave cleared (Backyard 10, Veggie 15, Orchard 10, 15, 20) | 2 more from the boss table |
| A win | 2 more from the field's table |
| Weekly garden | 1 per 5 waves cleared, from the Night Orchard table |

Not draws: Petals, losses beyond the waves cleared, time spent. **A run continued with a Second Wind bought for Robux gives no further draws** (or Gumnuts) after the purchase; the free daily Second Wind keeps draws normal. (Section 5.8 explains why.)

**Field tables** (chance of each tier per draw, then the plants of that tier that drop there; every plant drops somewhere):

| Field | Common | Uncommon | Rare | Ribbon | Blue Ribbon | Champion |
|---|---|---|---|---|---|---|
| Backyard Patch | 70%: thorn, sunpetal, burr, wattle, lilly | 25%: dandelion, roopaw, saltbush | 4.5%: pumpkin, macadamia | 0.5%: chilli | none | none |
| Veggie Rows | 55%: thorn, wattle, lilly | 30%: nettle, dandelion, grevillea, roopaw | 11%: banksia, pigface, mint | 3.4%: bottlebrush, fingerlime, snapjaw | 0.5%: boab | 0.1%: gumtree |
| Night Orchard | 45%: sunpetal, burr | 32%: saltbush, grevillea, nettle | 15%: mint, macadamia, pigface, pumpkin | 6%: chilli, snapjaw, fingerlime | 1.6%: oak, waratah, boab | 0.4%: wollemi, gumtree |
| Frost (any field, that field's plants) | 35% | 32% | 20% | 9% | 3% | 1% |
| Boss table (that field's plants) | none | none | 70% | 24% | 5% | 1% |

When a field has no plant in a tier, that tier is left out and the rest are scaled to add to 100% (Backyard's boss draw is 74.5% Rare, 25.5% Ribbon). These exact percentages, per plant, are shown on the field card (5.10).

**Which plant in the tier.** Each plant of the drawn tier on that field has weight 1, **2 if you have not sprouted it yet**, and 0 if it is at level 10 (if every plant in the tier is at level 10, the pod is for one of them at weight 1 and turns into Gumnuts, 5.7). The card says "Plants you don't have yet are twice as likely."

**Pity (guarantees), per player across all runs:**

| Guarantee | Within |
|---|---|
| Rare or better | 15 draws |
| Ribbon or better | 50 draws |
| Blue Ribbon or better | 120 draws |
| Champion | 300 draws |

Counters `since.R`, `since.RB`, `since.BR`, `since.CH` count draws since the last pod of that tier or better. On each draw: roll the tier; then, checking from Champion down, if `since[T] + 1 >= limit[T]` and the field has a plant of tier T or better, and the roll is below T, the tier becomes T (or the next tier up that the field has). Then every counter whose tier is at or below the result resets to 0 and the others go up by 1. If the field has no plant at that tier (Blue Ribbon and Champion on Backyard Patch), the counter keeps growing and fires on the next draw on a field that has one. **When a Blue Ribbon or Champion pity fires, the player chooses the plant** from that tier's plants on the field (`PityChoice`; until they choose, the pod waits in the Almanac with a "Pick your pod" badge, and further pity choices queue). The Almanac shows the four counters: "Rare or better in 6 pods, Champion in 212 pods".

`Drops.draw(profile, ctx, rand)` is pure: `ctx = {fieldId, table = "field" | "frost" | "boss" | "weekly"}`, `rand()` returns floats in [0, 1); the tier is chosen with the first `rand()`, the plant with the second. The server passes `Random.new():NextNumber` from one `Random` per server; tests pass a fixed list.

### 5.4 Sprouting, duplicates and levels

- **Discovered:** you have had at least one pod of the plant. **Sprouted** (owned, level 1): you have had the plant's sprout count of pods.
- Pods needed to sprout: Common 5, Uncommon 6, Rare 6, Ribbon 5, Blue Ribbon 3, Champion 2. Sprouting is automatic (a celebration card: "Wollemi Pine sprouted!").
- **Duplicates level the plant up.** After sprouting, pods fill a bar toward the next level. When the bar is full the plant shows "Ready to grow"; the player taps **Grow** in the Almanac (free, an animation and a new stat line). Pods beyond a full bar wait in the bar. Pods per level up:

| Tier | 1 to 2 | 2 to 3 | 3 to 4 | 4 to 5 | 5 to 6 | 6 to 7 | 7 to 8 | 8 to 9 | 9 to 10 | Total to 10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Common | 10 | 15 | 20 | 30 | 40 | 50 | 65 | 80 | 100 | 410 |
| Uncommon | 8 | 12 | 16 | 24 | 32 | 40 | 52 | 64 | 80 | 328 |
| Rare | 6 | 9 | 12 | 18 | 24 | 30 | 39 | 48 | 60 | 246 |
| Ribbon | 4 | 6 | 8 | 12 | 16 | 20 | 26 | 32 | 40 | 164 |
| Blue Ribbon | 3 | 4 | 6 | 8 | 11 | 14 | 18 | 22 | 28 | 114 |
| Champion | 2 | 3 | 4 | 5 | 7 | 9 | 11 | 14 | 17 | 72 |

(The prototype `collect.py` levels up automatically; the Grow button only adds a tap.)

- A pod for a level 10 plant turns into Gumnuts: Common 1, Uncommon 2, Rare 4, Ribbon 8, Blue Ribbon 15, Champion 40.
- Levels never go down. Plants can never be sold, traded, gifted, deleted or rerolled.

### 5.5 Starter plants and milestone gifts (replace spec 3.2 unlock rules)

Seeds no longer "unlock"; you **own** a plant when it is sprouted. To keep the first session of spec 2.2 and the version 1 unlock moments, these are **gifts** (each given once per profile, recorded in `gifts`):

| Gift | When | Plant |
|---|---|---|
| `start` | Profile created | Thorn Sprout, Sunpetal (level 1) |
| `burr` | First time Backyard Patch wave 3 is cleared (mid run, usable from the wave 4 build phase, as M1) | Burr Vine |
| `dandelion` | First clear of Backyard Patch | Dandelion Lofter |
| `snapjaw` | First time Veggie Rows wave 7 is cleared (mid run) | Snapjaw |
| `mint` | First clear of Veggie Rows | Mint Mist |
| Research L1, L2, L4, L7 | Bought (spec 4.3 costs unchanged) | Pumpkin Mortar, Nettle Patch, Chilli Burner, Oak Sentinel |

A gift for a plant already sprouted (from pods) gives twice its sprout count in pods instead. The research nodes' names and costs stay; their effect text becomes "Seed gift: Pumpkin Mortar (or pods if you have it)". Fields still unlock as spec 3.4.

### 5.6 Loadout

Unchanged slot counts (spec 4.4): 5, or 6 with research L8 or the Big Seed Bag pass; 6 on the weekly field (classic 10 only). Any owned plant. The Loadout screen becomes the Almanac's "Seed bag" tab (5.10). New player first run: Thorn, Sunpetal, Burr (Burr appears at wave 4, as M1).

### 5.7 Gumnuts and the Seed Swap (no one is stuck on one plant)

**Gumnuts** are a third currency, earned only by play and never sold:

| Source | Gumnuts |
|---|---|
| A run that clears at least 3 waves | 1 |
| First win of the UTC day | 3 |
| A pod for a level 10 plant | 1 to 40 by tier (5.4) |

(Never from purchases; a run after a bought Second Wind earns none after the purchase.)

**Seed Swap** at Nan's potting bench: spend Gumnuts for one pod of a plant you have **discovered**. Prices: Common 2, Uncommon 4, Rare 8, Ribbon 20, Blue Ribbon 50, Champion 150. At most 5 swaps per UTC day. Not for plants at level 10. Fixed price, a named plant, nothing random. Petals never buy pods (Petals buy research only, spec 4.3).

### 5.8 What is never sold, and why the rules hold

**Never sold, never given by any pass, subscription, product or code bought with Robux:** pods, plants, plant levels, Gumnuts, Petals, pity progress, draws, drop chances, Seed Swaps, gifts. There is no trading or gifting between players.

Robux items stay as spec 5.1 (Fast Forward 149, Big Seed Bag 199, Second Wind 25 with one free a day, private servers 100 a month) and 5.2 later (cosmetics and the Head Gardener subscription). Rules added:

1. **No paid randomness at all.** Every random outcome (pod draws) comes only from play. Roblox's paid random items policy covers random items bought directly or indirectly with Robux (review 4.1); free random rewards from play need no odds disclosure, but we show the odds anyway (5.10). Because nothing random is ever paid for, `PolicyService:ArePaidRandomItemsRestricted` never needs to hide anything; the code still reads it and, if true, nothing changes, because nothing is paid and random.
2. **Australian classification:** since 22 September 2024, games with in-game purchases linked to chance get at least M (review 4.1). Seed Siege has no purchase linked to chance, so this line is never crossed. Keep it that way: no future item may touch `Drops`, `Almanac`, `Gumnuts` or pity.
3. **A Robux item may not create a draw that would not have happened.** Fast Forward makes the same waves quicker (same draws per wave). The Big Seed Bag and research change strength, not drops. A bought Second Wind would turn a loss into extra waves, so **draws and Gumnuts stop after a bought Second Wind** (5.3); the free daily one is play, so it keeps them.
4. **Head Gardener (later):** its daily gift stays 40 Petals, which only buy research; it gives no pods, Gumnuts or Swaps. Its exclusive garden theme is cosmetic.
5. **Cosmetics later** (plant skins, garden themes, spec 5.2) are bought directly at a shown price, never random, and never change a plant's numbers.

**Test** (`products.spec.luau`): read `Products` and the receipt grants; assert no grant touches `almanac`, `gumnuts`, `pity`, `petals` or adds a draw; assert `Drops.draw` and `Almanac.addPod` are called only from `RunManager` wave end, win and `AlmanacService.swap`, by reading the server source as text in Lune (a simple search that fails the test if `Drops.draw` appears in `PurchaseService`).

### 5.9 How long the collection takes (free player)

From `design/prototype/collect.py` (2,000 simulated players, the spec 4.5 daily play model unchanged: about 31 minutes a day at 1x; 22 draws on day 1, 38 on day 2, 28 on days 3 and 4, 47 a day from day 5; one weekly run a week; milestone gifts as 5.5; no Seed Swaps, so real players are a little faster):

| Tier | Plants | Median day all sprouted | 90% of players by day |
|---|---|---|---|
| Common | 5 | 2 | 2 |
| Uncommon | 5 | 5 | 6 |
| Rare | 5 | 6 | 7 |
| Ribbon | 4 | 10 | 16 |
| Blue Ribbon | 3 | 15 | 21 |
| Champion | 2 | 20 | 29 |

- First Champion: median **day 11**, 90% by day 18 (the Scout's target was "about 2 weeks").
- All 24 sprouted: median **day 21**, 90% by day 30; nobody of 2,000 was still missing a plant at day 60.

| Day | Plants sprouted (median) | Average level of sprouted plants | Plants at level 10 |
|---|---|---|---|
| 7 | 19 | 1.7 | 0 |
| 14 | 22 | 2.8 | 0 |
| 28 | 24 | 4.0 | 0 |
| 60 | 24 | 6.0 | 0 |

Level 10 is a long tail (months; Gumnut swaps and future drops shorten it), on purpose: it is a goal for keen players and the source of the rosette look, while stats only reach x1.36.

### 5.10 Almanac UI (extend spec 7)

Opened from the Almanac stand, the hub HUD (book button) and the results screen. Phone landscape, spec 7 rules (48 point targets, 14 point text, colour never alone).

- **Tabs:** Plants, Seed bag (loadout), Pods (pity, pending choices).
- **Plants:** a grid of 24 cards in rarity order. Each card: the 3D portrait (ViewportFrame of the real model, as M1 seed cards), name, tier name and frame, level, a pod bar ("12 / 15 to level 4"), and a "Ready to grow" badge. Undiscovered plants are a dark silhouette with "Drops on: Veggie Rows, Night Orchard". Tap a card: stats at this level and the next, bio, where it drops with its exact chance per draw on each field, Grow button, Favourite toggle (for the display bed).
- **Pods tab:** the four pity counters as bars with words ("Champion guaranteed within 212 pods"), any pending "Pick your pod" choices, Gumnuts and the Seed Swap list (from the potting bench only).
- **Field cards (Garden Gate panel and Play picker):** a "Pod chances" button listing every plant that drops there with its percentage per draw for this player (weights included), plus "Boss waves drop Rare or better".
- **Results screen:** a "Pods" row that lists each pod earned this run in order, with tier frames; a sprout gets a big card.

---

## 6. Balance

### 6.1 Prototype changes (additive)

New files in `design/prototype/` (the version 1 files are untouched and still give the spec 3.7 table: `python3 reference_runs.py`):

- `sim2.py`: the version 2 engine (`CoopRun`): 24 plants, 20 pests, every mechanic in section 3, ranks, 1 to 4 players with zones, per player Sap, shared hearts, scaling (4.4). `run_script_coop` runs version 1 scripts.
- `fields2.py`: version 2 waves (3.5), boss waves, pod tables (5.3).
- `coop_runs.py`: `--check` runs all 24 cells of the spec 3.7 table through the version 2 engine with one player and checks hearts, Sap and result are identical (**they are: "v2 engine reproduces v1: True"**); without flags it prints the tables below (careful bot once, casual bot 40 seeds per cell; about 3 minutes on 4 cores).
- `collect.py`: the collection timing in 5.9.

Bots (version 2 greedy bot, one per player, each in its own zone with its own Sap):

- **Careful:** the spec Appendix B greedy bot extended: Sunpetals early (2 solo, 1 in co-op until wave 4), Saltbush once, Mint or Wollemi when moles come, the best air plant when flyers come, then the best "effective damage per second times path coverage per Sap" plant or upgrade (effective damage subtracts an average armour of 2 from direct hits; splash, aura, multi target, crack, sour, boost, knock, slow and burn get fixed weights). Deterministic.
- **Casual:** the same candidates, but picks among the top 3 actions in random order, places on one of the 4 best tiles at random, skips the early Sunpetal rule 40% of the time, and 30% of the time stops building after one action in a build phase (distracted). A rough stand in for a new human; real players will vary more.

Stages: **A** new player (no research, collection level 1, Backyard thorn, sunpetal, burr; Veggie adds dandelion and wattle; Orchard dandelion and lilly). **B** about day 4 (RMID, commons at level 2; Veggie thorn, sunpetal, dandelion, pumpkin, grevillea; Orchard thorn, mint, pumpkin, dandelion, snapjaw). **C** about day 21 (RFULL, 6 slots, levels from 5.9: commons 5, uncommons and rares 4, ribbons 3, boab 2; Veggie wattle, sunpetal, grevillea, pumpkin, bottlebrush, boab; Orchard wattle, sunpetal, mint, pumpkin, bottlebrush, boab).

### 6.2 Results: win rate and hearts by player count and field

Careful bot: one deterministic run, result and hearts left (out of 20, or 25 at RFULL). Casual bot: win rate over 40 seeds, median hearts of the wins, median wave of the losses.

**Backyard Patch** (10 waves, Kevin at 0.35 health in wave 10)

| Stage | Players | Careful | Casual win rate | Casual hearts (wins) | Casual loss wave |
|---|---|---|---|---|---|
| A | 1 | win, 16 | 88% | 20 | 10 |
| A | 2 | win, 20 | 95% | 20 | 6 |
| A | 3 | win, 20 | 100% | 20 | none |
| A | 4 | win, 20 | 98% | 20 | 7 |
| B | 1 to 4 | win, 20 | 100% | 20 | none |
| C | 1 to 4 | win, 25 | 100% | 25 | none |

**Veggie Rows** (15 waves, Swoopy at 0.6 health in wave 15)

| Stage | Players | Careful | Casual win rate | Casual hearts (wins) | Casual loss wave |
|---|---|---|---|---|---|
| A | 1 | win, 3 | 55% | 9 | 6 |
| A | 2 | win, 9 | 82% | 7 | 11 |
| A | 3 | win, 3 | 72% | 5 | 11 |
| A | 4 | win, 6 | 52% | 5 | 11 |
| B | 1 | win, 19 | 95% | 15 | 2 |
| B | 2 | win, 20 | 100% | 18 | none |
| B | 3 | win, 18 | 100% | 17 | none |
| B | 4 | win, 19 | 100% | 17.5 | none |
| C | 1 | win, 17 | 82% | 19 | 5 |
| C | 2 | win, 22 | 98% | 20 | 6 |
| C | 3 | win, 23 | 100% | 22 | none |
| C | 4 | win, 20 | 95% | 21.5 | 6 |

**Night Orchard** (20 waves, Possum Pete at 10, Wombat at 15, Possum Pete and Kevin at 20)

| Stage | Players | Careful | Casual win rate | Casual hearts (wins) | Casual loss wave |
|---|---|---|---|---|---|
| A | 1 | win, 10 | 15% | 3 | 10 |
| A | 2 | win, 9 | 22% | 3 | 9 |
| A | 3 | win, 12 | 20% | 11.5 | 9.5 |
| A | 4 | win, 10 | 48% | 13 | 10 |
| B | 1 to 4 | win, 12 | 100% | 20 | none |
| C | 1 | win, 15 | 98% | 25 | 8 |
| C | 2 | win, 20 | 92% | 25 | 8 |
| C | 3 | win, 21 | 98% | 25 | 8 |
| C | 4 | win, 15 | 98% | 25 | 8 |

**Reading the tables.**

- The headline: with the scaling in 4.4, **co-op is about as hard as solo, a little kinder at 2 and 3 players**, and the first contact difficulty curve of spec 3.7 holds: Backyard about 90% for a new player (it is the tutorial; Kevin is a fun finale, not a wall), Veggie Rows a coin flip on day 1 (target 50%), Night Orchard about 15 to 25% before research (target 15%).
- 4 players on Veggie Rows at stage A is the hardest co-op case (52%), because each zone has only about 18 tiles and early plants cannot dent beetle armour on 2.5x health. Acceptable: four new players together are rare, and it is still better than solo Night Orchard.
- Night Orchard at stage B shows a careful 12 hearts in every count: the Wombat in wave 15 leaks once (8 hearts) for the careful bot, which over builds pierce plants (armour 8, pierce 0.5). That is the lesson the Wombat teaches (blunt or crack); humans will meet it.
- Stage B and C are easy for the casual bot: the casual bot is better than many humans, so read these as "a careful player at day 4 rarely loses". Spec 3.7's human targets (Veggie 80% and Orchard 45% around RMID) should be watched in analytics; if real players find the late game too easy, raise Frost first, then the Orchard `hpScale`.
- Casual losses at wave 2 to 8 in stages B and C come from the "distracted" rule (a build phase with one action) and are bot noise.

**Tuning knobs** (extend spec 3.7, in order): a field's `hpScale`; the co-op table in 4.4 (health first, then Sap share); one wave's counts; a plant's cost. Never the rules in section 3.

**Lune tests to add** (`balance.spec.luau`, bands wider than the prototype): with the version 2 bot ported to Lune (`tests/bots.luau`), careful bot wins every field at 1 to 4 players at stages A to C, except that Veggie stage A may lose for 3 or 4 players; Backyard stage A solo hearts 12 to 20; Orchard stage A casual win rate over 40 fixed seeds between 5% and 40% solo; version 1 cells of spec 3.7 still exact with `Fields.classic`.

---

## 7. Data saved per player

### 7.1 What moves from M1's "no saves"

M1 saved nothing: a run started on join, Burr re-locked each run. From M2 (milestone 2 below) everything in spec 6.6 is saved (Petals, research, fields, stars, weekly, ribbons, daily, tokens, cosmetics, settings, tutorial, receipts, stats), plus the collection, Gumnuts, favourites and Nan's seen lines. Spec 6.6's load, lock, autosave, `BindToClose`, migration and "never write a newer schema" rules are unchanged.

### 7.2 Profile schema 2 (DataStore `SS_Players`, key `u_<userId>`)

```
Profile (schema 2) = {
  schema = 2,
  -- everything in spec 6.6 schema 1, unchanged, except:
  --   loadout now holds any owned plant ids (24),
  --   stats.shooed covers all 20 pests.
  lock, createdAt, lastSeenAt, petals, petalsEarned, research, wavesSeen, fields,
  loadout, weekly, ribbons, daily, tokens, cosmetics, settings, tutorial, receipts, stats,

  almanac = {                        -- only plants with at least one pod appear
    [plantId] = {
      lv = 0..10,                    -- 0 = discovered, not sprouted
      pods = int,                    -- pods towards sprouting (lv 0) or the next level
      firstAt = number,              -- unix time first pod
      sproutAt = number | nil,
    },
  },
  pity = { R = 0, RB = 0, BR = 0, CH = 0 },     -- draws since the last pod of that tier or better
  pendingChoices = { { tier = "BR" | "CH", fieldId = string, at = number } },  -- at most 10
  gumnuts = 0, gumnutsEarned = 0,
  swaps = { dayKey = "", n = 0 },
  gifts = { [giftKey] = true },                 -- "start", "burr", "dandelion", "snapjaw", "mint", "L1", "L2", "L4", "L7"
  favourites = { plantId, ... },                -- 0 to 3, owned
  nan = { seen = { [lineKey] = count } },       -- caps each count at 99
  party = { lastField = "backyard", lastMode = "normal" },
  daily = { ..., firstWinGumnutsTaken = false },  -- added to spec's daily table
  stats = { ..., coopRuns = 0, pods = 0, draws = 0 },
}
```

Size: about 2 KB for almanac and pity, plus receipts (up to 200, about 10 KB): far under the 4 MB value limit.

- `SaveSchema.CURRENT = 2`. `MIGRATIONS[1]` (schema 1 to 2): for every seed that spec 3.2's derived unlock rules would unlock from `research`, `wavesSeen` and `fields`, set `almanac[id] = {lv = 1, pods = 0}` and the matching `gifts` key; add every new key with its default. Pure. (No schema 1 save exists in the wild, since M1 never saved; the migration exists for fixtures and safety.)
- `reconcile` drops unknown plant ids from `almanac`, `loadout` and `favourites`, clamps `lv` to 0..10 and `pods` to 0..10,000, and keeps `pendingChoices` to 10.
- `validate` also checks: every loadout and favourite id has `lv >= 1`; pity counters are integers 0 to 10,000; Gumnuts 0 to 1,000,000.
- **Saving moments** (on top of autosave every 90 s, on leave and `BindToClose`): after any Grow, Swap or PickPity (immediately, `UpdateAsync` with the lock), and at run end. Pod grants during a run are in memory and saved by the next autosave or run end; a crash can lose at most 90 s of pods, never a purchase.

### 7.3 Other stores

| Store | Kind | Key | Value | Notes |
|---|---|---|---|---|
| `SS_Players` | DataStore | `u_<userId>` | Profile schema 2 | Session lock as spec 6.6 |
| `SS_Weekly_<isoYear>W<ww>` | OrderedDataStore | `<userId>` | score | Unchanged (spec 6.8) |
| `SS_ActiveRun` | MemoryStore HashMap | `u_<userId>` | `{jobId, runId, plotIndex, slot, holdUntil}` | Written when a co-op player is seated, refreshed every 60 s, expiry 240 s, removed when the seat is released. Read on join by `PresenceService` (4.5). If MemoryStore fails, cross server rejoin is simply not offered. Builder: check MemoryStore HashMap limits in current docs before use. |

---

## 8. Milestones from here (replace spec 9 from M2 on)

M1 (playable Backyard, tested WaveSim, server authority) and the m1-visuals branch (Part art, camera, HUD) are done and reused. Effort is builder days for one Luau Builder agent with Lune tests, including Lune specs and a Studio check through MCP where available. Each milestone ends with all Lune tests passing, a Studio playtest with no errors in Output, and a short "not verified" note (spec 9 rule).

**M2: Saves and the hub (10 days).** Logic: Research, ResearchTree, Progression (gifts), SaveSchema 2, SessionLock, Tutorial, Economy (Petals), Fields (all three classic fields playable, Frost), NanLines, Party (pure). Server: DataStoreAdapter, SaveService, ProgressionService, TutorialService, HubService (hub build, gates for solo use, display beds with the 10 classic plants, Nan and her hub lines), PlotService with 12 slots and client side decor. Client: hub HUD (Play, Almanac placeholder, Invite), Garden Gate panel as field picker, Loadout, Research, tutorial, full results with Petals and "Back to Nan's". Avatars on in the hub. *Done when:*
- First join plays spec 2.2's first session exactly; "Back to Nan's" walks into the hub with `hub_hello_first`.
- Petals, research and loadout survive a rejoin; two Studio servers with the same player prove the session lock (the second waits).
- Stepping on a gate alone starts a solo run after the countdown; the Play button starts one at once.
- 12 Studio test clients can each run a solo garden at once with no Output errors; replicated parts per plot under 200 (server count) and the client builds decor only for its own plot.
- save, lock, economy, research, progression, tutorial, NanLines and Party specs pass; a schema 1 fixture migrates to schema 2; the version 1 balance cells still pass with `Fields.classic`.

**M3: Co-op runs (9 days).** Logic: Zones, Coop, WaveSim seats (per player Sap, owners, shared hearts, health scaling at wave start, plant caps), Validate and Views for co-op. Server: RunManager seats, Ready, speed votes, pings, napping, holds and team plants; HubService parties of 1 to 4 on gates; PresenceService (MemoryStore). Client: zone tints and stakes, member chips, Ready button, ping ring, napping and away states, avatars at gardener spots, Play again with the party. *Done when:*
- Two and four Studio test clients form a party on one gate with no typing and finish Backyard Patch together; each gets their own Petals with the mates bonus.
- `zones.spec`: every plantable tile in exactly one zone for n = 1 to 4 on all 3 fields; sizes differ by at most 1; slot 1 holds the tile nearest the gate.
- `coop.spec`: Sap shares, start Sap, wave start health scaling, hearts bonus and plant caps match 4.4 numbers on fixed scripts; a leaver's Sap split after 180 s.
- Remote abuse from the command bar: planting in a teammate's zone gives `not_your_zone`, selling a teammate's plant gives `not_yours`, selling a team plant gives `team_plant`.
- A client that disconnects and rejoins the same server within 180 s is reseated with plants and Sap; after 180 s its plants are team plants.
- Determinism: the same 4 player scripted run twice gives an identical event log; 1x and 2x ticks per frame identical.

**M4: The collection (11 days).** Logic: Seeds (24 with new fields), Almanac, Drops, Gumnuts, WaveSim plant mechanics (targets, airSplash, crack, knock, auraSlow, sour, bossMult, burnAura, reveal, dmgBuff, bounty) and ranks. Art: 14 new plant models (2.2) and faces on all 24 with the three moods, level 5 crown and level 10 rosette. Server: AlmanacService, pod grants at wave end, win and boss, PityChoice, Seed Swap. Client: Almanac (3 tabs), pod reveal, pod chances on field cards, results pods row, display beds with favourites, Plant parade bed. *Done when:*
- `drops.spec`: with a fixed `rand` sequence, the tier and plant chosen match hand worked vectors for each table; the shown percentages for each field sum to 100% and equal the draw maths; every plant drops somewhere; pity fires at exactly 15, 50, 120 and 300 draws without the tier and resets the right counters; Backyard Blue Ribbon and Champion counters carry over to the next Orchard draw; unsprouted weight 2 and level 10 weight 0.
- `almanac.spec`: sprout counts and ladders as 5.4; Grow only with a full bar; level 10 pods become Gumnuts; gifts give pods if owned.
- `products.spec` (5.8) passes; a bought Second Wind stops draws for the rest of that run, the free one does not.
- `mechanics.spec`: one vector per new plant mechanic (for example Grevillea hits the 3 largest `d`; Macadamia on a beetle does 20 x 1.25 = 25 with no armour taken off; Kangaroo Paw moves an ant back 0.6 and a snail 0.3 and a boss 0; Wollemi boosts a thorn to 9.6 and not itself; Saltbush pays 2 once per pest).
- `collect.spec` ports `collect.py` with a fixed seed: first Champion median between day 8 and day 16, all 24 by day 30 for at least 80% of 500 players.
- In Studio: a run drops pods with the reveal card; Grow works; favourites show on the display bed and other test clients see them.

**M5: Cast and bosses (9 days).** Logic: Pests (20 with new fields), Cast, WaveSim pest mechanics (hop, swoop, ruffle, scratch, snatch, binDive, pong, unslow), version 2 waves (3.5), plant statuses and events. Art: 10 new pest models (2.3) including Kevin's bin bag and wheelie bin and Swoopy's nest; animal rules (2.4: splashes, Shoo meter, leaving animations). Nan's in-run lines and reactions; hub idle lines and tips. *Done when:*
- `mechanics.spec` pest vectors: a toad hops at 3.0 s exactly; a magpie is low from 3.5 to 5.0 s of each 5 s; Swoopy's flinch stuns plants within 1.5 for 1 s; a turkey stuns plants within 1.0 every 5 s; Kevin snatches the costliest plant within 1.5 every 7 s and dives once at 50% for 3 s, untouchable (burn paused); stink pong debuffs to 0.6 for 2 s; wombat ignores slow and knock.
- `balance.spec` version 2 bands (6.2) pass for 1 to 4 players with the Lune bots; the version 1 cells still pass with `Fields.classic`; determinism and speed (full Orchard 4 player run under 3 s in Lune).
- In Studio: Kevin's snatch shows the bin bag and the plant comes back; his bin dive shows the wheelie bin; no animal ever shows sparks, a poof or falls over; Nan's boss lines fire once per boss.
- Owner's 10 minute look (8.1) has no "no" on items 1 to 6.

**M6: Weekly garden, shop and launch to 16+ (10 days).** Spec M3 (weekly field, unchanged, classic plants at rank 1, solo posting) and spec M4 (Products, Receipts, PurchaseService, Fast Forward with the any member rule, Big Seed Bag, Second Wind solo with the no draws rule, private servers, star cosmetics, settings, sounds, juice, phone layout, thumbnail and icon from real co-op play), plus the weekly board in the hub. *Done when:* spec M3 and M4 "done when" lists pass (Appendix A vectors exact; receipts idempotent); a bought Second Wind grants once and stops draws; the owner's checklist (spec 8.3 plus 8.1 below) has no "no" on items 1 to 12; the maturity questionnaire answered honestly (animals shooed, no blood, Mild crude at most, no paid random items, no free text); published to 16+.

**Total: 49 builder days** from today's M1 plus visuals. Cut order if it must be shorter (from review 6.6, adapted): Seed Swap and Gumnuts (pity still guarantees every plant), then cross server rejoin (same server rejoin stays), then display beds (the Plant parade stays), then the level 5 and 10 looks. Do not cut co-op, pods, pity or the cast.

### 8.1 Owner's 10 minute look for the cast (M5)

1. Can you tell Kevin, Swoopy, the magpie, the cockatoo and the bugs apart at a glance on a phone?
2. When Kevin bags a plant, is it clear it will come back?
3. Do animals ever look hurt? (They should only look grumpy and leave.)
4. Do Nan's lines make you smile, and is any of them confusing to someone outside Australia?
5. Do the plants' faces read at the normal camera distance?
6. Would a 10 year old and a 30 year old both find it funny?

---

## 9. Parked: room left, nothing designed

- **More game modes** (Story worlds, Endless, Boss Raid, Nan's Daily). Room: `Fields` already takes any field; `RunManager.start` takes a mode string; the hub has an empty paved area for more gates; `Drops` tables are keyed by field id, so a new mode adds a table. The weekly generator gets a versioned `v2` (new pest POOL, all 24 plants on level soil) starting from a chosen ISO week, so Appendix A stays valid for older weeks.
- **Weather** (server wide, changes runs). Room: `WaveSim` modifiers (spec 3.5) already change runs; weather would be a modifier chosen from the clock in a pure `Weather.at(unix)` function. The hub has a rain gauge prop. `Drops` could take a weather multiplier later, as long as it is free and the same for everyone.
- **The Saturday event.** Room: a pure clock function like the weekly reset; rewards must come back later (review 4.5), and nothing about it may be paid.

---

## 10. Open decisions for the owner (6)

1. **Server size 12 with gardens in the same server** (4.1). Recommendation: **yes**. It is testable in Studio and needs one place; if Seed Siege ever gets big, runs can move to reserved servers without changing the run code.
2. **Kevin as the finale of the tutorial field** (Backyard wave 10, at about a third of his health). Recommendation: **yes**. It is the funniest first five minutes we have, and the bots still win about 90% of first attempts.
3. **2x speed in co-op when any member owns Fast Forward** (4.4). Recommendation: **yes**. A friend's pass helps everyone, which feels generous and never pressures a kid to buy so the group can go faster.
4. **Gumnuts and Seed Swap at launch** (5.7). Recommendation: **yes**, it is the answer to "I'm stuck on one plant"; it is also first on the cut list if M4 runs long, because pity already guarantees every tier.
5. **No pods after a bought Second Wind** (5.3, 5.8). Recommendation: **yes**. It keeps a clean line that Robux never buys a pod, even indirectly, which matters for the Australian M classification line and for trust.
6. **Aussie display names for classic bugs** (Sugar Ant, Bogong Moth, Christmas Beetle, Slug Mum, Possum Pete). Recommendation: **yes**: a light touch that costs nothing, and "Bogong" and "Christmas Beetle" are fun to look up.

Still open from spec 11 and unchanged: launch prices, Kids and Select route, membership price, weekly reset time, and the Roblox name search for "Seed Siege".
