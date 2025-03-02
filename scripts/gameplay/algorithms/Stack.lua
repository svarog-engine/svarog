function Stack()
  return setmetatable({
    _stack = {},
    count = 0,

    clear = function(self)
      self._stack = {}
      self.count = 0
    end,

    push = function(self, obj)
      self.count = self.count + 1
      rawset(self._stack, self.count, obj)
    end,

    pop = function(self)
      if self.count <= 0 then return nil end
      self.count = self.count - 1
      return table.remove(self._stack)
    end,

    top = function(self)
      if self.count <= 0 then return nil end
      return self._stack[self.count]
    end,

    shift = function(self)
      self.count = self.count - 1
      return table.remove(self._stack, 1)
    end,

    each = function(self, callback)
      for i = 1, self.count do
        callback(rawget(self._stack, i), i)
      end
    end,

    map = function(self, callback)
      for i = 1, self.count do
        rawset(self._stack, i, callback(rawget(self._stack, i)))
      end
    end,

    where = function(self, callback)
      local stack = Stack()
      for i = 1, self.count do
        local value = rawget(self._stack, i)
        local r = callback(value, i)
        if r then
          stack:push(value)
        end
      end
      return stack
    end
  }, {
    __index = function(self, index)
      return rawget(self._stack, index)
    end,
  })
end