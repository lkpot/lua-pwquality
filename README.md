# lua-pwquality

Lua bindings for `libpwquality`.

## Lua Example

Check a password against `libpwquality`'s default settings:

```lua
local pwquality = require("pwquality")

local ok, score_or_code, message = pwquality.check("Valid#Pass123")

if ok then
	print("Password is valid, score:", score_or_code)
else
	print("Password rejected:", score_or_code, message)
end
```

Check a password against a username and additional user options. User options extend on `libpwquality`'s default settings:options).

```lua
local pwquality = require("pwquality")

local ok, score_or_code, message = pwquality.check(
	"Valid#Pass123",
	"alice",
	{ minlen = 10, dcredit = -1, ucredit = -1, lcredit = -1, ocredit = -1 }
)

if ok then
	print("Password is valid, score:", score_or_code)
else
	print("Password rejected:", score_or_code, message)
end
```

Option keys and values are passed through to `libpwquality` as string.
