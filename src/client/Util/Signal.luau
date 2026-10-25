--!strict
-- A tiny signal: connect returns a function that disconnects.

export type Signal = {
	handlers: { (...any) -> () },
	connect: (self: Signal, fn: (...any) -> ()) -> () -> (),
	fire: (self: Signal, ...any) -> (),
}

local Signal = {}

function Signal.new(): Signal
	local self = { handlers = {} } :: any
	function self.connect(s: Signal, fn: (...any) -> ()): () -> ()
		table.insert(s.handlers, fn)
		return function()
			local i = table.find(s.handlers, fn)
			if i then
				table.remove(s.handlers, i)
			end
		end
	end
	function self.fire(s: Signal, ...: any)
		for _, fn in table.clone(s.handlers) do
			task.spawn(fn, ...)
		end
	end
	return self
end

return Signal
