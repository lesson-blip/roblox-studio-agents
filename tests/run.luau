--!strict
-- Lune test runner: `lune run tests/run` from the project root.
-- Finds tests/*.spec.luau, runs every test, prints one line per test, exits 1 on any failure.
-- A spec file returns function(test), where test(name, fn) registers one test.

local fs = require("@lune/fs")
local process = require("@lune/process")

local DIR = "tests"
local files: { string } = {}
for _, name in fs.readDir(DIR) do
	if string.sub(name, -10) == ".spec.luau" then
		table.insert(files, name)
	end
end
table.sort(files)

local only = process.args[1] -- optional filter, for example `lune run tests/run combat`

local passed, failed = 0, 0
local failures: { string } = {}

for _, file in files do
	if only == nil or string.find(file, only, 1, true) then
		local modName = "./" .. string.sub(file, 1, -6)
		local okLoad, specOrErr = pcall(function()
			return (require :: any)(modName)
		end)
		if not okLoad or type(specOrErr) ~= "function" then
			failed += 1
			local msg = file .. ": could not load: " .. tostring(specOrErr)
			table.insert(failures, msg)
			print("FAIL  " .. msg)
		else
			local tests: { { name: string, fn: () -> () } } = {}
			(specOrErr :: any)(function(name: string, fn: () -> ())
				table.insert(tests, { name = name, fn = fn })
			end)
			for _, t in tests do
				local ok, err = pcall(t.fn)
				local label = string.sub(file, 1, -11) .. " > " .. t.name
				if ok then
					passed += 1
					print("pass  " .. label)
				else
					failed += 1
					table.insert(failures, label .. ": " .. tostring(err))
					print("FAIL  " .. label .. "\n        " .. tostring(err))
				end
			end
		end
	end
end

print(string.rep("-", 60))
print(string.format("%d passed, %d failed, %d total", passed, failed, passed + failed))
if failed > 0 then
	print("Failures:")
	for _, f in failures do
		print("  " .. f)
	end
	process.exit(1)
end
process.exit(0)
