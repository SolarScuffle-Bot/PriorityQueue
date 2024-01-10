--[[

 PriorityQueue - v1.0.0 - public domain Lua priority queue
 implemented with indirect binary heap
 no warranty implied; use at your own risk

 based on binaryheap library (github.com/iskolbin/binaryheap)

 author: Ilya Kolbin (iskolbin@gmail.com)
 modified: SolarScuffle-Bot
 url: https://github.com/SolarScuffle-Bot/PriorityQueue

 See documentation in README file.

 LICENSE

 This software is dual-licensed to the public domain and under the following
 license: you are granted a perpetual, irrevocable license to copy, modify,
 publish, and distribute this file as you see fit.

--]]

local function minishigher(a: number, b: number)
	return a < b
end

local function siftup<T>(self: PriorityQueue<T>, from: number)
	local items, priorities, indices = self, self.priorities, self.indices
	local index = from
	local parent = index // 2
	while index > 1 and minishigher(priorities[index], priorities[parent]) do
		priorities[index], priorities[parent] = priorities[parent], priorities[index]
		items[index], items[parent] = items[parent], items[index]
		indices[items[index]], indices[items[parent]] = index, parent
		index = parent
		parent = index // 2
	end
	return index
end

local function siftdown<T>(self: PriorityQueue<T>, limit: number)
	local items, priorities, indices, len = self, self.priorities, self.indices, self.len
	for index = limit, 1, -1 do
		local left = index + index
		local right = left + 1
		while left <= len do
			local smaller = left
			if right <= len and minishigher(priorities[right], priorities[left]) then
				smaller = right
			end
			if minishigher(priorities[smaller], priorities[index]) then
				items[index], items[smaller] = items[smaller], items[index]
				priorities[index], priorities[smaller] = priorities[smaller], priorities[index]
				indices[items[index]], indices[items[smaller]] = index, smaller
			else
				break
			end
			index = smaller
			left = index + index
			right = left + 1
		end
	end
end

local PriorityQueue = {}

export type PriorityQueue<T> = {
	priorities: { number },
	indices: { [T]: number },
	len: number,
	[number]: T,
}

local function new<T>(): PriorityQueue<T>
	return {
		priorities = {},
		indices = {},
		len = 0,
	}
end
PriorityQueue.new = new

local function insert<T>(self: PriorityQueue<T>, item: T, priority: number)
	local items, priorities, indices = self, self.priorities, self.indices
	if indices[item] ~= nil then
		error('Item ' .. tostring(indices[item]) .. ' is already in the heap')
	end

	local len = self.len + 1
	self.len = len
	items[len], priorities[len], indices[item] = item, priority, len
	siftup(self, len)
end
PriorityQueue.insert = insert

local function remove<T>(self: PriorityQueue<T>, item: T)
	local index = self.indices[item]
	if index == nil then
		return false
	end

	local len = self.len
	local items, priorities, indices = self, self.priorities, self.indices
	indices[item] = nil

	if len == index then
		items[len], priorities[len] = nil, nil
		self.len = len - 1
	else
		local lastitem = items[len]
		items[index], priorities[index] = items[len], priorities[len]
		items[len], priorities[len] = nil, nil
		indices[lastitem] = index
		len -= 1
		self.len = len
		if len > 1 then
			siftdown(self, siftup(self, index))
		end
	end

	return true
end
PriorityQueue.remove = remove

local function has<T>(self: PriorityQueue<T>, item: T)
	return self.indices[item] ~= nil
end
PriorityQueue.has = has

local function update<T>(self: PriorityQueue<T>, item: T, priority: number)
	local ok = remove(self, item)
	if ok then
		insert(self, item, priority)
		return true
	else
		return false
	end
end
PriorityQueue.update = update

local function pop<T>(self: PriorityQueue<T>)
	local len = self.len
	if len <= 0 then
		error 'Dequeueing when heap is empty!'
	end

	local items, priorities, indices = self, self.priorities, self.indices
	local item, priority = items[1], priorities[1]
	indices[item] = nil

	if len > 1 then
		local newitem = items[len]
		items[1], priorities[1] = newitem, priorities[len]
		items[len], priorities[len] = nil, nil
		indices[newitem] = 1
		len = len - 1
		self.len = len
		siftdown(self, 1)
	else
		items[1], priorities[1] = nil, nil
		self.len = 0
	end

	-- print('pop', item, priority)
	return item, priority
end
PriorityQueue.pop = pop

local function peek<T>(self: PriorityQueue<T>)
	-- print('peek', self[1], self.priorities[1])
	return self[1], self.priorities[1]
end
PriorityQueue.peek = peek

return PriorityQueue