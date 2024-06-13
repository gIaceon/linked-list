--!strict
--!native

local linked_list = {}
linked_list.__index = linked_list
linked_list.__iter = function<T>(list: linked_list<T>): (typeof(next), { T })
	local arr = list:array()
	return next, arr
end

export type list_item<T> = {
	next: list_item<T>?,
	previous: list_item<T>?,
	item: T,
}

export type linked_list<T> = typeof(setmetatable(
	{} :: {
		_head: list_item<T>?,
		head: (self: linked_list<T>) -> T?,
		tail: (self: linked_list<T>) -> T?,
		add: (self: linked_list<T>, item: T) -> () -> (),
		forEach: (self: linked_list<T>, fn: (T) -> ()) -> nil,
		clear: (self: linked_list<T>, desctructor: ((T) -> ())?) -> nil,
		array: (self: linked_list<T>) -> { T },
		find: (self: linked_list<T>, comp: (current: T) -> boolean) -> T?,
		remove: (
			self: linked_list<T>,
			item: T,
			desctructor: ((item: T) -> ())?,
			finder: ((item: T) -> boolean)?
		) -> nil,
	},
	linked_list
))

function linked_list.new<T>(head: T?)
	local self: linked_list<T> = (setmetatable({}, linked_list) :: any) :: linked_list<T>
	if head then
		self:add(head)
	end
	return self
end

function linked_list.head<T>(self: linked_list<T>): T?
	return (self :: any)._head and (self :: any)._head.item :: T
end

function linked_list.tail<T>(self: linked_list<T>): T?
	local current = self._head

	if current == nil then
		return nil
	end

	while current do
		local nxt = current.next
		if nxt then
			current = nxt
		else
			break
		end
	end

	return current.item
end

function linked_list.forEach<T>(self: linked_list<T>, iter: (T) -> ())
	local current = self._head

	if current == nil then
		return nil
	end

	while current do
		iter(current.item)
		current = current.next
	end

	return
end

function linked_list.add<T>(self: linked_list<T>, item: T)
	local new_item: list_item<T> = {
		next = self._head,
		item = item,
	}
	self._head = new_item
	if new_item.next then
		new_item.next.previous = new_item
	end
	return function()
		local current_next = new_item.next
		local current_previous = new_item.previous

		if current_next then
			current_next.previous = current_previous
		end
		if current_previous then
			current_previous.next = current_next
		else
			self._head = current_previous
		end

		new_item.next = nil
		new_item.previous = nil
		new_item.item = nil :: any
	end
end

function linked_list.clear<T>(self: linked_list<T>, desctructor: ((T) -> ())?)
	local current = self._head

	while current do
		local now = current
		current = current.next
		if desctructor and now and now.item then
			desctructor(now.item)
		end
		now.previous = nil
		now.next = nil
		now.item = nil :: any
	end

	if desctructor and self._head and self._head.item then
		desctructor(self._head.item)
	end
	self._head = nil
end

function linked_list.array<T>(self: linked_list<T>): { T }
	local array: { T } = {}
	self:forEach(function(item: T)
		table.insert(array, item)
	end)
	return array
end

function linked_list.find<T>(self: linked_list<T>, compare: (item: T) -> boolean): T?
	local found: T?
	self:forEach(function(item)
		local comp = compare(item)
		if comp then
			found = item
		end
	end)
	return found
end

function linked_list.remove<T>(
	self: linked_list<T>,
	item: T,
	desctructor: ((item: T) -> ())?,
	finder: ((item: T) -> boolean)?
)
	local current = self._head

	if current == nil then
		return nil
	end

	while current do
		if (finder or function(current: T)
			return item == current
		end)(current.item) then
			break
		end
		current = current.next
	end

	if current == nil then
		return
	end

	if desctructor then
		desctructor(current.item)
	end

	local current_next = current.next
	local current_previous = current.previous

	if current_next then
		current_next.previous = current_previous
	end
	if current_previous then
		current_previous.next = current_next
	else
		self._head = current_previous
	end

	current.next = nil
	current.previous = nil
	current.item = nil :: any

	return
end

return linked_list
