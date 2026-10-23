# Does string:gsub() sometimes return a tuple?

`gsub` always returns two values: the new string and the number of replacements. Lua has no tuples; these are multiple return values. Usually the second value is dropped without notice.

```lua
local s = ('a b c'):gsub(' ', '-')       -- s = 'a-b-c', the count is dropped
local s, n = ('a b c'):gsub(' ', '-')    -- s = 'a-b-c', n = 2
```

## Where the count is dropped

Lua keeps only the first value when the call is:

- assigned to a single variable,
- used in an expression (`..`, arithmetic),
- chained (`s:gsub(...):gsub(...)`),
- not the last item in an argument list or table constructor.

## Where it leaks through

The call is the last item in a list. Then Lua passes both values on:

```lua
return s:gsub('x', 'y')               -- the function returns 2 values
print(s:gsub('x', 'y'))               -- prints the string and the count
table.insert(t, s:gsub('x', 'y'))     -- error: wrong number of arguments to 'insert'
local t = { s:gsub('x', 'y') }        -- the table gets 2 elements
f(s:gsub('x', 'y'))                   -- f receives a second argument
```

## Fix

Wrap the call in parentheses. That keeps only the first value:

```lua
return (s:gsub('x', 'y'))
table.insert(t, (s:gsub('x', 'y')))
```

`string.find` works the same way: it returns the start, the end, and then any captures.

## Help

```vim
:h string.gsub()
:h lua-function       " how multiple results work
```
