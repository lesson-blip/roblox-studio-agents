# Seed Siege

A garden tower defence for Roblox (account BlockyAcres). Design: `design/seed-siege-spec.md`,
owner summary: `design/seed-siege-onepager.md`. Latest build notes: `build/BUILD_REPORT.md`.

## Layout

- `src/shared/Logic/` pure game rules (no Roblox services, no clock). Lune and Roblox run the same files.
- `src/shared/` also holds `LogicBundle.luau` (wires the Logic modules in Roblox), `Visuals.luau` and `Net/Remotes.luau`.
- `src/server/` server scripts (`Main.server.luau` and `Services/`).
- `src/client/` client scripts (`Main.client.luau`, `Controllers/`, `UI/`).
- `tests/` Lune tests (`*.spec.luau`), the runner, a tiny assert library and fixtures.
- `tools/` helper scripts run with Lune.

## Tools

Install [Rokit](https://github.com/rojo-rbx/rokit) and run `rokit install` in this folder. It installs the
versions pinned in `rokit.toml` (Rojo 7.7.1, Lune 0.11.1, luau-lsp 1.70.1). Aftman users can run
`aftman install` with `aftman.toml` instead. Then run `lune setup` once so editors know Lune's types.

## Build

```
rojo build -o build/SeedSiege.rbxl
```

Open `build/SeedSiege.rbxl` in Roblox Studio and press Play. For live editing, run `rojo serve` and
connect with the Rojo Studio plugin.

## Test

```
lune run tests/run            # every tests/*.spec.luau; exits 1 on any failure
lune run tests/run combat     # only spec files whose name contains "combat"
lune run tools/balance-report # prints the balance table (spec 3.7) from the Luau code
lune run tools/check-place    # checks the built place file has every script in the right spot
lune run tools/server-smoke   # runs the real server scripts headless with fake Roblox services
```

Type checking (optional):

```
rojo sourcemap default.project.json -o sourcemap.json
luau-lsp analyze --definitions=<path to globalTypes.d.luau> --sourcemap=sourcemap.json src
```

The Roblox definitions file is `scripts/globalTypes.d.luau` from the luau-lsp repository at tag 1.70.1.
