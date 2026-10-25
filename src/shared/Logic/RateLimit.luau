--!strict
-- Token bucket (spec 6.3). Pure: time comes in as a number.

export type Bucket = { rate: number, burst: number, tokens: number, at: number? }

local RateLimit = {}

function RateLimit.new(rate: number, burst: number): Bucket
	return { rate = rate, burst = burst, tokens = burst, at = nil }
end

-- Returns whether one action is allowed and the new bucket (the input is not changed).
function RateLimit.take(bucket: Bucket, now: number): (boolean, Bucket)
	local tokens = bucket.tokens
	if bucket.at ~= nil then
		local elapsed = math.max(0, now - bucket.at)
		tokens = math.min(bucket.burst, tokens + elapsed * bucket.rate)
	end
	if tokens >= 1 then
		return true, { rate = bucket.rate, burst = bucket.burst, tokens = tokens - 1, at = now }
	end
	return false, { rate = bucket.rate, burst = bucket.burst, tokens = tokens, at = now }
end

return RateLimit
