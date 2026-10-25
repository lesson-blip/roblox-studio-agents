# Seed Siege build report: M0 and M1

25 October 2026. Builder agent. Spec: `design/seed-siege-spec.md` (version 1).

## Summary

- **M0 done.** Rojo project, tool pins, a Lune test runner with a tiny assert library, README.
- **M1 built.** Backyard Patch is playable solo from start to win or loss: plant, upgrade, sell (with undo), target modes, start wave, 1x and 1.5x speed, results and Play again. All gameplay runs on the server in the same pure `WaveSim` the tests run.
- **Tests: 76 passed, 0 failed** (`lune run tests/run`, exit code 0).
- **Backyard result reproduced exactly**: the Appendix B order with no research wins with **17 hearts**, the same as the prototype. In fact all 24 cells of the spec 3.7 table match the prototype (`lune run tools/balance-report`).
- **`rojo build -o build/SeedSiege.rbxl` works** (Rojo 7.7.1, 54 KB place file).
- **Nothing has been run inside Roblox Studio.** There is no Studio or MCP server in this environment, so everything that needs a real Roblox client is unverified (listed below).

## Tools (M0)

| Tool | Version | How it was got | Result |
|---|---|---|---|
| Rojo | 7.7.1 | `curl -L` of the GitHub release asset `rojo-7.7.1-linux-x86_64.zip` (the `gh` route is blocked here: `gh release` uses GraphQL, which this environment refuses with 403, and `gh api` returns 403 for repositories not attached to the session; plain download URLs worked) | works, `rojo --version` prints `Rojo 7.7.1` |
| Lune | 0.11.1 | same, `lune-0.11.1-linux-x86_64.zip` | works, `lune 0.11.1` |
| luau-analyze | 0.744 | same, `luau-ubuntu.zip` | used for strict type checks of Logic and tests |
| luau-lsp | 1.70.1 | same, `luau-lsp-linux-x86_64.zip`, plus `scripts/globalTypes.d.luau` at tag 1.70.1 | used to type check the Roblox scripts against the Roblox API definitions |

Binaries sit in `tools/bin/` (git ignored). `rokit.toml` and `aftman.toml` pin Rojo 7.7.1, Lune 0.11.1 and luau-lsp 1.70.1, so the owner can run `rokit install`. SHA-256 of the downloaded zips: Rojo `00feb4fa0829a1dd72b49df2639da519a352bfe13cadcd83969e2ba2bb5693c4`, Lune `39859282ce677fce19e6eb45c37596a90a25c324c95b4e7e02d428b6cae294a1`.

## What was built

Project files: `default.project.json` (the spec 6.1 tree, plus `StarterGui.ScreenOrientation = LandscapeSensor` and `Players.CharacterAutoLoads = false` so no avatar walks about the plot), `rokit.toml`, `aftman.toml`, `.luaurc` (the `@lune` alias that `lune setup` writes), `.gitignore`, `README.md`.

Pure Logic (`src/shared/Logic`, every file `--!strict`, no `require`, no services, no clock; `tools/check-place` confirms this in the built place):

| Module | Contents |
|---|---|
| `Constants` | every constant in spec 6.3 |
| `Seeds`, `Pests`, `Fields` | all 10 seeds, 10 pests, 3 fields with every wave, frozen, with `order` lists |
| `Grid` | `expandPath`, `positionAt`, `isPathTile`, `inBounds`, `distance`, `coverage`, `mirror`, `validateField` |
| `Combat` | `hitDamage`, `dotDamage`, `burnDps`, `canTarget`, `pickTarget` (spec 3.1 Damage) |
| `WaveSim` | the full spec 3.1 rules, including modifiers, Second Wind, every error code and an event log |
| `Economy` | Sap parts only: `upgradeCost`, `sellValue`, `waveBonus`, `pestReward`, half up `round` |
| `Validate` | `int`, `str`, `oneOf`, `seedId`, `tile`, `plantId`, `loadout`, plus `payload(remote, args)` and the per remote rate limits `LIMITS` |
| `RateLimit` | token bucket, pure |
| `Views` | `runView` (the only run shape sent to clients), `pestSnapshot`, `unpackPests` |

Wiring: `src/shared/LogicBundle.luau` (Roblox, instance requires) and `tests/bundle.luau` (Lune, string requires) both call `bind(L)`.

Server (`src/server`): `Main.server.luau` starts `PlotService` (one plot, built from Parts: grass, 96 tiles with `X`, `Y`, `IsPath` attributes, gate, shed), `RemoteRouter` (creates `ReplicatedStorage.Remotes`; each call checks ready, validates the payload, takes a rate limit token, runs the handler in `pcall`, returns `{ ok, err, data }`), `Broadcaster` (`RunUpdated` at most 10 a second on change, `PestSnapshot` 5 a second during waves, only to that run's players) and `RunManager` (the `WaveSim` on `Heartbeat`, ticks from speed, at most 6 a frame). A run starts on join. Remotes bound: `RequestStart`, `PlaceSeed`, `UpgradePlant`, `SellPlant`, `SetTargetMode`, `StartWave`, `SetSpeed`, and `LeaveRun` (for the menu's Leave run; it is in spec 6.5 though not in the M1 list).

Client (`src/client`): `Main.client.luau` builds one ScreenGui (`ScreenInsets = CoreUISafeInsets`, a `UIScale` of `clamp(min(w / 844, h / 390), 0.75, 1.5)`), then `StateStore` (server state, selection, remote calls with friendly error toasts), `CameraController` (fixed camera fitted to the plot), `BoardRenderer` (plants as coloured blocks and balls, level pips, a seedling badge with the waves left, the ghost plant, range rings, plantable tile hints), `PestRenderer` (pests as coloured spheres, smoothed between snapshots, hidden moles faded, burning ones glow, health bars), `EffectsController` (shot sparks, leafy poof and "+N" Sap), `PlacementController` (touch: tap card, tap tile for the ghost, tap again to plant; mouse: ghost follows, one click plants; right click or Escape cancels; tapping a plant opens the inspector), and the UI: `Hud` (hearts, Sap with a pulse, wave counter and bar, speed, menu, Start wave, toasts), `SeedBar` (72 by 88 cards with cost, "need N" and a lock), `Inspector` (name, level, stats, Upgrade, Sell or Undo, Target), `Results` (banner, waves, hearts, a counter hint for the pest that leaked most, Play again).

Tools: `tools/balance-report.luau` (spec 3.7 table from the Luau code), `tools/check-place.luau` (opens the built place in Lune and checks every script's class and place, and that Logic is pure), `tools/server-smoke.luau` (see below).

## Test results (real runs)

`lune run tests/run`: **76 passed, 0 failed, 76 total**, exit code 0. I also checked the runner exits with code 1 when a test fails (a throwaway failing spec, then deleted).

| Spec file | Tests | Result |
|---|---|---|
| `balance.spec.luau` | Backyard R0 wins with 17 hearts (exact, as the prototype); Backyard R0 at least 12 hearts; Backyard RMID 17 and RFULL 25; Backyard Frost R0, RMID, RFULL 6, 10, 19; 3 Thorn Sprouts only loses on wave 9 (band 7 to 10); Veggie R0 6 to 18 hearts and RMID at least 15; Orchard R0 loses before 12, RMID wins, RFULL at least 20; Frost Orchard RMID loses, RFULL wins | 8 of 8 pass |
| `combat.spec.luau` | every spec 8.1 damage vector (thorn on beetle 1, thorn on aphid 8, seedling 4, snapjaw on snail 108, pumpkin on beetle 22.5, dandelion on moth 16, burn tick on caterpillar 4.5), burn factors, Ironshell, Heatwave, minimum 1, damage over time, levels and research, Heavy bonus, flying and hidden targeting, all four target modes with ties to the earliest spawn | 15 of 15 pass |
| `data.spec.luau` | constants; every seed and pest number in 3.2 and 3.3 typed in again from the spec; unlock rules point at real nodes, fields and waves; ids unique and tables frozen; field data and wave spot checks; every group well formed; `validateField` on all 3 fields, mirrored too; route lengths 30, 24, 30 | 9 of 9 pass |
| `economy.spec.luau` | upgrade costs for every seed; sell 60% rounded down and 100% undo; wave bonus; half up rounding | 4 of 4 pass |
| `grid.spec.luau` | path tiles 31, 25, 31 and plantable 65, 71, 65; `positionAt` at 0, every corner and past the end; bounds; coverage (8,2) 9, (3,5) 9, (11,0) 1; mirror; bad paths rejected | 6 of 6 pass |
| `ratelimit.spec.luau` | burst then refill; 1 per 2 s; burst cap and no input mutation; time going backwards | 4 of 4 pass |
| `validate.spec.luau` | every validator against good and bad values (NaN, infinities, floats for ints, long strings, wrong types, tables); every M1 remote payload good and bad | 7 of 7 pass |
| `views.spec.luau` | run view fields and prices; no pests or internals in the run view; snapshot packs and unpacks | 3 of 3 pass |
| `wavesim.spec.luau` | tick order; leaks; wave bonus; growth then Sunpetal pay; seedling half damage; Mint buff largest, not stacked, only grown; Mint never buffs itself; moles only with Mint or Oak; burrow pattern; slug split at d minus 0.3k; regeneration stops while burning; Burr slow and refresh; 120 pest cap; undo and sell; every error code reachable; Second Wind and give up; **determinism** (identical event log hash twice); **1x, 2x and 3x ticks per frame identical**; **full Night Orchard run under 2 s** (about 0.1 s here); state copies | 20 of 20 pass |

Other checks that ran here:

- `lune run tools/check-place`: place file OK (every Script, LocalScript and ModuleScript in the right service with the right class; Logic sources contain no `require(`, `game`, `workspace`, `Instance.`, `os.clock`, `tick(` or `DateTime`; orientation and CharacterAutoLoads set).
- `lune run tools/server-smoke`: **42 checks passed, 0 failed.** It loads the real `Main.server.luau` and services unchanged in Lune with small fakes of Roblox instances, `Players`, `RunService.Heartbeat` and the remotes, then acts as a client. It confirms: a Backyard run starts on join with 200 Sap and 20 hearts; the plot and 96 tiles are built; planting on a path tile gives `on_path`; fractional tiles, NaN, unknown seeds and a table payload give `bad_payload`; Burr is `locked` before wave 3; a seed outside the loadout is refused; 2x gives `needs_pass`; too little Sap gives `no_sap`; a taken tile is refused; undo refunds in full; `UpgradePlant` allows 8 then answers `rate_limited`; a second Start wave mid wave is `wrong_phase`; then the whole Appendix B order is played through the remotes at 1.5x and **ends with a win and 17 hearts, the same as the Lune result**; after the run, planting is `run_over`; Play again starts a fresh run on the same plot. This is not a Roblox playtest: the fakes only cover what these scripts call.
- Strict type checks: `luau-analyze` reports no errors for all Logic modules, the fixtures, helpers and spec files. The only two messages are the `@lune/fs` and `@lune/process` requires in `tests/run.luau`, because `luau-analyze` does not expand the `~` in `.luaurc`; with an absolute alias path that file is clean too. `luau-lsp analyze` with the Roblox definitions and a Rojo sourcemap reports **no errors** for everything in `src` (server, client and shared), which also confirms that every Roblox class, property and enum used (for example `Enum.ScreenInsets.CoreUISafeInsets`, `Enum.Font.FredokaOne`, `Enum.RaycastFilterType.Include`) exists in the current API definitions.

## Choices and differences to know about

1. **Spawn order ties.** The spec sorts by time, then group order; the prototype sorts by time, then pest name. They differ on Backyard waves 7 and 10 (two pests due in the same tick). It made no difference: every one of the 24 balance cells matches the prototype.
2. **Mint Mist range** for its buff and its reveal uses the seed's base range plus Night shift only, as the prototype does. The spec's attack range formula (level bonus, research range, Fog) is used for attacking plants. The spec does not say which applies to Mint; the Designer may want to decide.
3. **Burrow clock drift.** The mole's clock adds 0.1 a tick and checks `clock mod 5 < 3`, as written in the spec and the prototype. Floating point makes it pass 3.0 a hair early, so a mole is hidden for 29 ticks, then up for 21, not 30 and 20. I kept it because it matches the prototype the balance was checked with; `wavesim.spec` pins the pattern. A whole tick counter would give exactly 3 s and 2 s if the Designer prefers (it may move Orchard numbers slightly).
4. **Burn uses the seedling factor** (spec), which the prototype leaves out (spec Appendix C says so). No effect on any reference run.
5. **Split children** (aphids from a Slug Matriarch) are added even when 120 pests are alive; only scheduled spawns wait for room.
6. **M1 limits on purpose:** Backyard Patch normal mode only (`RequestStart` answers `locked` for anything else); loadout Thorn, Sunpetal, Burr; Burr unlocks inside the run when wave 3 is cleared (no saves yet, so it is locked again next run); no research, Petals, saves, tutorial, Second Wind or auto start (M2 and later); 2x speed answers `needs_pass` (Fast Forward is M4) and the button falls back to 1x.
7. **Snapshot extra:** `PestSnapshot` also carries `sap = { pestId, reward, ... }` so the client can show "+N" where a pest was shooed. Everything else follows the spec 6.5 shape.
8. **Plants are drawn on each client** from `RunUpdated` (as the spec says the client draws what the server says), so in M2 with 4 plots another player would not see your plants until the board renderer draws other plots too.
9. **Not committed by design:** `build/*.rbxl`, `tools/bin/` and `sourcemap.json` are in `.gitignore`. Rebuild with `rojo build -o build/SeedSiege.rbxl`.

## Not verified (needs Roblox Studio)

Everything below needs a real Roblox client; none of it was run here:

- That the place opens and the server and client scripts run without errors in Studio's Output (the server scripts ran headless against fakes; the client scripts have only been type checked).
- Camera framing on a phone sized screen, touch input and the raycast to tiles, the two tap placement, mouse hover on a computer.
- HUD layout with `CoreUISafeInsets` and `UIScale` (overlap with Roblox's own buttons, text size), and that the heart, dot and lock symbols render in the chosen fonts.
- Replication timing: the client waits for `Plots.Plot1` and its 96 tiles before drawing; that the first `RunUpdated` arrives (the client also calls `RequestStart` on load to resync, and the server re-sends the state on `in_run`).
- Smoothness of pest movement between 5 Hz snapshots, tween effects, frame rate on a cheap phone.
- Anything about feel, readability and whether wave 10 is tense but fair.
- The spec's M1 "done when" also asks for a Builder playtest through the Studio MCP server; that was not available in this environment.

## Owner's 10 minute playtest for M1

In Studio: open `build/SeedSiege.rbxl` (or `rojo serve` plus the Rojo plugin), then Test, Play. Use the device emulator (Test tab, Device) with a phone held sideways for steps 3 to 8. Tick each line and note any "no".

1. (1 min) The game loads into a garden with a path, a gate and a shed, with no red errors in Output. Output shows `[SeedSiege] server ready (M1)`.
2. The HUD shows hearts 20, Sap 200 and "Wave 1 / 10" at the top, three seed cards bottom left (Burr shows a lock), Start wave 1 bottom right. Nothing sits under Roblox's own buttons.
3. (2 min) Tap the Thorn card: it lifts and the grass beside the path lights up. Tap a tile next to the path: a see through plant with a white range ring and "Tap again to plant" appears. Tap the same tile: it plants and Sap drops to 140. Did it land on the tile you tapped?
4. Try to plant on the path: a message says pests walk there and nothing is planted. Keep planting until Sap is too low: the card greys and shows "need N".
5. Tap a plant: the inspector shows its level, Upgrade and Undo. Press Undo: Sap comes back in full. Plant it again.
6. (4 min) Press Start wave. Aphids (green spheres) walk the path, sparks fly from plants, "+3" floats up as each is shooed. Plant a Sunpetal and check its "1" badge disappears after the next wave and Sap jumps at the wave end.
7. After wave 3 a message says Burr Vine is unlocked and its lock goes. Plant one at a path corner and watch pests slow.
8. Press the speed button to 1.5x during a wave. Does anything stutter or jump? Press again: it should say 2x comes with Fast Forward and go back to 1x.
9. (3 min) Play to the end of wave 10. Did wave 10 (beetles and snails) feel tense but fair? Did you lose some hearts? The results panel shows "Garden saved!" or "The pests got through", waves cleared and hearts left; on a loss, a hint names a counter.
10. Press Play again: a fresh run starts with 200 Sap and no plants. Then use the menu, Leave run: the results panel appears.
11. Optional, check the server refuses cheats. During Play, switch the command bar to the Client view and run
    `print(game.ReplicatedStorage.Remotes.PlaceSeed:InvokeServer("thorn", 4, 1).err)`: it should print `on_path`.
    With `"thorn", 8.5, 2` it should print `bad_payload`, and with `"thorn", 0, 0` after spending your Sap, `no_sap`.
12. Would you play another run right now? One sentence why or why not.

## M1 visuals: the look of the 3D preview, built from Parts (branch `m1-visuals`)

25 October 2026. Presentation only: no Logic module, remote, payload or server rule changed
(76 tests and the server smoke run give the same results as before).

**What changed**

- `src/shared/Art/` (new). `Kit` turns design/preview3d/scene.js units into Parts (one unit is 2 studs):
  boxes, balls and squashed balls (sphere SpecialMesh), cylinders, sticks between two points, wedges,
  stepped cones, cartoon eyes and smiles, and a record of every part so the client can animate it.
  `Garden` builds the backyard unit for unit from scene.js: raised lawn tiles in six greens, sandstone
  pavers on a dirt base, 16 timber edged soil beds, grass tufts and flowers, Colorbond fences with
  ribs, white pickets, the open timber gate and the pests' burrow, Nan's shed (sage ribbed walls,
  red ribbed roof, green doors, "NAN'S SHED" sign, window and flower box, the heart), rainwater
  tank, Hills Hoist with washing, raised veggie bed, front flower bed, back deck with barbie, chairs
  and table, five gum trees with pale trunks and clumped canopies, shrubs, neighbours' fences, shed
  and trampoline. `Props` has the gnome and Nan (also her head for the HUD portrait). `Seeds` has
  all 10 plants (Thorn, Sunpetal with a PointLight glow, Burr, Dandelion, Pumpkin, Snapjaw from the
  preview; Nettle, Mint, Chilli and Oak in the same style). `Pests` has all 10 pests (aphid, ant,
  snail, beetle, caterpillar from the preview; moth, wasp, mole, slug mum, possum simpler).
  `CameraFit` is the camera maths.
- Server: `PlotService` calls `Garden.build`. The 96 tiles keep their names and X, Y, IsPath
  attributes (plus `Bed`); everything else is in a `Decor` folder with CanQuery off, so taps only hit
  tiles. `Visuals.PLOT_GAP` is now 180 studs so M2's four yards do not overlap.
- Lighting (in `default.project.json`, as Technology cannot be set from a script): ShadowMap, warm sun
  at 14.6 h, soft shadows, Sky, Atmosphere, ColorCorrection, a light Bloom and SunRays.
- Client: plants sway, nod, turn to the pest they shot and kick (Snapjaw snaps its jaw); pests bob,
  wiggle legs (flyers flap), face along the path, and caterpillar segments follow the path; all
  through one `workspace:BulkMoveTo` a frame per renderer. Rounded health bars that change colour.
  Shots by seed: glowing darts (Thorn), burrs, white puffs on an arc (Dandelion), a glowing pumpkin on
  a high arc with a splash ring (Pumpkin), a snap and flash (Snapjaw); leaf burst and a green "+N"
  when a pest is shooed; effect parts are pooled. Range rings are a cream disc with a white edge.
- Camera: fixed 3/4 view from the right, 44 degrees down, FOV 36, fitted so the grid and the front of
  the shed fill the screen between the HUD rows (`Visuals.CAMERA_SAFE`).
- HUD restyled like the preview: dark pills with heart and Sap drop icons drawn from frames, white
  Fredoka numbers with a dark stroke, "Wave n / 10" with a gold bar and "N pests left", blue 1.5x
  button and menu button, seed cards in each seed's colours with a ViewportFrame portrait of the real
  plant model, key number, name, cost and "need N" or "Locked" over the portrait, keys 1 to 6 pick a
  card, Start wave in green, Nan's tip bubble with her 3D portrait speaks every toast.
- Owner's first playtest fixes: the HUD now starts under the Roblox top bar (measured from
  `GuiService.TopbarInset` and `GetGuiInset`, `ScreenInsets = DeviceSafeInsets`); the player list,
  chat window, backpack, emotes and health bar are turned off (`SetCoreGuiEnabled`; the game has no
  typing, so chat is off; switch it back on in `Main.client.luau` if co-op wants it); the seed cards
  are a fixed 88 points tall with the "need N" note inside the card, and the UI scale is worked out
  from the height left under the top bar, so they fit at 1057 by 576 and on a phone held sideways;
  the camera is fitted tight like preview-hero.png.

**Part counts** (from the smoke run and `tools/export-parts`): the static plot is **1,628 parts**
(96 tiles, 1,532 decor). The 8 plants in the export scene are 276 parts (about 25 to 45 each, with
their soil plot) and the 8 pests 173 (about 15 to 30 each). A full late wave of 40 pests and 15 plants
adds about 1,500 moving parts on the client.

**Checks run here**

- `luau-lsp analyze` with the Roblox definitions: no errors in `src`.
- `lune run tests/run`: 76 passed, 0 failed.
- `lune run tools/server-smoke`: 47 passed, 0 failed (5 new: part count matches, under 2,500, only
  the 96 tiles can be hit by a raycast, every tile has its attributes, path and bed tiles marked).
- `rojo build -o build/SeedSiege.rbxl` builds; `lune run tools/check-place` OK (now also checks the
  Art modules, the Lighting children and Technology).
- `lune run tools/export-parts` builds the real Art code with Lune's Roblox instances and
  `design/preview3d/render-roblox.js` draws those exact parts with three.js:
  `media/3d/roblox-parts-game-1600x900.png`, `roblox-parts-game-1057x576.png` (the owner's screen
  size) and `roblox-parts-overview-1600x900.png`. They match preview-hero.png closely. This is
  three.js lighting, not Roblox's, and it assumes Roblox's wedge shape (full height at the back);
  it checks shapes, sizes, placement and framing only.

**Not verified (needs Studio):** how Roblox's lighting, shadows and post effects look; the sun
direction (if shadows fall towards the camera, change `Lighting.ClockTime` in
`default.project.json`, for example 9.5); the shed gables (if they look like a V, the wedges need
turning 180 degrees in `Garden.shed`); squashed balls (SpecialMesh) and thin parts at a distance;
frame rate on a phone with a full wave; the HUD clear of the top bar on a real phone; ViewportFrame
portraits; client scripts have only been type checked, not run.

### Owner's 3 minute look

1. Open `build/SeedSiege.rbxl` (after `rojo build`), press Play. Output has no red errors.
2. Compare with `media/3d/preview-hero.png`: a fenced backyard with the shed and Nan on the right,
   Hills Hoist and veggie bed at the back, deck and barbie at the front, pavers and soil beds, soft
   shadows. Hearts, Sap and the wave title sit under Roblox's top bar; speed and menu are visible
   top right; no player list or chat.
3. Plant a Thorn and a Sunpetal (the cards show 3D plants; "need N" fits inside a card). Start the
   wave: aphids walk with wiggling legs, darts fly, leaves burst with "+3".
4. Send a screenshot at the start of wave 1 and one mid wave, plus the Output window if anything is
   red. Say if the shadows fall towards the camera or the shed roof ends look wrong.
