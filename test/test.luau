local Queue = require 'src/init'

local function populate()
	local bh = Queue.new()
	Queue.insert(bh, 'a', 2)
	Queue.insert(bh, 'b', 4)
	Queue.insert(bh, 'c', 1)
	Queue.insert(bh, 'd', 6)
	return bh
end

local cases = {
	length = function()
		local bh = populate()
		return #bh == 4 and bh.len == 4
	end,

	enq_deq = function()
		local bh = populate()
		return Queue.pop(bh) == 'c' and Queue.pop(bh) == 'a' and Queue.pop(bh) == 'b' and Queue.pop(bh) == 'd'
	end,

	empty = function()
		local bh = populate()
		local bh2 = Queue.new()

		return not (#bh <= 0)
			and Queue.pop(bh) == 'c'
			and Queue.pop(bh) == 'a'
			and Queue.pop(bh) == 'b'
			and Queue.pop(bh) == 'd'
			and (#bh <= 0)
			and (#bh2 <= 0)
	end,

	peek = function()
		local bh = populate()
		return Queue.peek(bh) == 'c' and Queue.pop(bh) == 'c' and Queue.peek(bh) == Queue.pop(bh)
	end,

	heapsort = function()
		local bh = Queue.new()

		local array = {}
		for i = 1, 1000 do
			array[i] = math.random()
			Queue.insert(bh, array[i], array[i])
		end

		table.sort(array)

		for i = 1, #bh do
			if Queue.pop(bh) ~= array[i] then
				return false
			end
		end

		return true
	end,

	simulation = function()
		local items = {}
		local bh = Queue.new()

		for i = 1, 1000 do
			if #items == 0 or math.random() < 0.5 then
				local item = math.random()
				Queue.insert(bh, item, item)
				table.insert(items, item)
				table.sort(items)
			else
				local item = Queue.pop(bh)
				if item ~= table.remove(items, 1) then
					return false
				end
			end
		end

		return true
	end,

	existence = function()
		local bh = populate()
		return Queue.has(bh, 'a')
			and Queue.has(bh, 'b')
			and Queue.has(bh, 'c')
			and Queue.has(bh, 'd')
			and (not Queue.has(bh, 'z'))
			and (not Queue.has(bh, 'x'))
			and (not Queue.has(bh, 'y'))
			and (not Queue.has(bh, 'q'))
	end,

	remove = function()
		local bh = populate()
		return Queue.has(bh, 'a')
			and (not Queue.remove(bh, 'z'))
			and bh.len == 4
			and #bh == 4
			and Queue.remove(bh, 'a')
			and (not Queue.has(bh, 'a'))
			and bh.len == 3
			and #bh == 3
			and Queue.remove(bh, 'b')
			and Queue.remove(bh, 'd')
			and Queue.remove(bh, 'c')
			and #bh <= 0
	end,

	update = function()
		local bh = populate()
		return Queue.update(bh, 'a', 0)
			and Queue.peek(bh) == 'a'
			and Queue.remove(bh, 'a')
			and (not Queue.has(bh, 'a'))
			and (Queue.update(bh, 'c', 2))
			and (not Queue.update(bh, 'z', 5))
	end,

	contains_remove = function()
		local bh = Queue.new()
		Queue.insert(bh, 'a', 22)
		Queue.insert(bh, 'b', 33)
		return Queue.has(bh, 'a')
			and #bh == 2
			and Queue.remove(bh, 'a')
			and #bh == 1
			and Queue.remove(bh, 'b')
			and #bh == 0
	end,
}

local log = { '', 'Testing PriorityQueue' }
table.insert(log, ('='):rep(#log[2]))

local function runCases(cs)
	local count, passed = 0, 0
	for name, case in pairs(cs) do
		count = count + 1
		local pass = case()
		if pass then
			passed = passed + 1
		end
		table.insert(log, name .. ' => ' .. (pass and 'OK' or 'FAIL'))
	end
	local failed = count - passed
	table.insert(log, ('\nSummary\n-------\nPassed: %d\nFailed: %d'):format(passed, failed))
	return passed, failed
end

local passed, failed = runCases(cases)

print(table.concat(log, '\n'))
if failed > 0 then
	error 'Tests failed!'
else
	print('Tests passed!')
end
