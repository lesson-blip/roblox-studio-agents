--!strict
local L = require("./bundle")
local A = require("./assert")
local RL = L.RateLimit

return function(test)
	test("burst then refill at the rate", function()
		local b = RL.new(8, 10)
		local allowed = 0
		for _ = 1, 15 do
			local ok
			ok, b = RL.take(b, 100)
			if ok then allowed += 1 end
		end
		A.eq(allowed, 10)
		local ok
		ok, b = RL.take(b, 100.1) -- 0.8 tokens: not yet
		A.falsy(ok)
		ok, b = RL.take(b, 100.125) -- 1.0 token
		A.truthy(ok)
	end)
	test("1 per 2 seconds", function()
		local b = RL.new(0.5, 1)
		local ok
		ok, b = RL.take(b, 0); A.truthy(ok)
		ok, b = RL.take(b, 1.9); A.falsy(ok)
		ok, b = RL.take(b, 2.0); A.truthy(ok)
	end)
	test("never more than the burst after a long wait, and take does not change its input", function()
		local b = RL.new(2, 2)
		local _, b1 = RL.take(b, 0)
		A.eq(b.tokens, 2)
		local n = 0
		local cur = b1
		for _ = 1, 5 do
			local ok
			ok, cur = RL.take(cur, 1000)
			if ok then n += 1 end
		end
		A.eq(n, 2)
	end)
	test("time going backwards never adds tokens", function()
		local b = RL.new(1, 1)
		local ok
		ok, b = RL.take(b, 10); A.truthy(ok)
		ok, b = RL.take(b, 5); A.falsy(ok)
	end)
end
