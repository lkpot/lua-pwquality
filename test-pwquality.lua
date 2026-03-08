require("busted.runner")()

local pwquality = require("pwquality")

-- luacheck: globals describe it assert

describe("pwquality", function()

    local test_cases = {
        { password = "Valid#Pass123", result = true, options = { minlen = 6, dcredit = -1, ucredit = -1, lcredit = -1, ocredit = -1 } },
        { password = "short", result = nil, options = { minlen = 30 } },
    }
    for _, test_case in ipairs(test_cases) do
        it(string.format("returns %s for password '%s'", tostring(test_case.result), test_case.password), function()
            local result = pwquality.check(test_case.password, nil, test_case.options)
            assert.is.equal(test_case.result, result)
        end)
    end

    it("returns code and message for a weak password", function()
        local minlen = 30
        local result, code, message = pwquality.check("short", nil, { minlen = minlen })
        assert.is.Nil(result)
        assert.is.Number(code)
        assert.is.String(message)
        assert.is.equal(string.format("The password is shorter than %d characters", minlen), message)
    end)

    it("returns boolean and score for valid password", function()
        local result, score = pwquality.check("Valid#Pass123", nil, { minlen = 6 })
        assert.is.True(result)
        assert.is.Number(score)
    end)

    it("returns exactly three values for weak passwords", function()
        local nresults = select("#", pwquality.check("short", nil, { minlen = 30 }))
        assert.is.equal(3, nresults)
    end)

    it("rejects unexpected argument types", function()
        assert.has_error(function() pwquality.check({}) end, "bad argument #1 to 'check' (string expected, got table)")
        assert.has_error(function() pwquality.check(function() end) end, "bad argument #1 to 'check' (string expected, got function)")

        assert.has_error(function() pwquality.check("password", {}) end, "bad argument #2 to 'check' (string expected, got table)")
        assert.has_error(function() pwquality.check("password", function() end) end, "bad argument #2 to 'check' (string expected, got function)")

        assert.has_error(function() pwquality.check("password", nil, "not-a-table") end, "bad argument #3 to 'check' (table expected, got string)")
        assert.has_error(function() pwquality.check("password", nil, function() end) end, "bad argument #3 to 'check' (table expected, got function)")
    end)

    it("rejects invalid options", function()
        assert.has_error(function() pwquality.check("password", nil, { invalid = 1 }) end, "failed to set option: invalid")
        assert.has_error(function() pwquality.check("password", nil, { [true] = "1" }) end, "option keys must be strings")
        assert.has_error(function() pwquality.check("password", nil, { minlen = {} }) end, "option values must be strings")
    end)

    it("handles nil user argument", function()
        local result = pwquality.check("Valid#Pass123", nil, { minlen = 6 })
        assert.is.True(result)
    end)

    it("handles empty options table", function()
        local result = pwquality.check("Valid#Pass123", nil, {})
        assert.is.True(result)
    end)

    it("handles missing options argument", function()
        local result = pwquality.check("Valid#Pass123")
        assert.is.True(result)
    end)

    it("has default options that can be overridden", function()
        local pw = "R0xy1!"

        local result = pwquality.check(pw)
        assert.is.Nil(result)

        result = pwquality.check(pw, nil, { minlen = 6 })
        assert.is.True(result)
    end)

    test_cases = {
        { password = "password", user = "password" },
        { password = "Password123", user = "password" },
        { password = "username123", user = "username" }
    }
    for _, test_case in ipairs(test_cases) do
        it(string.format("rejects password '%s' for user '%s'", test_case.password, test_case.user), function()
            local result, code, message = pwquality.check(test_case.password, test_case.user)
            assert.is.Nil(result)
            assert.is.Number(code)
            assert.is.String(message)
            assert.is.equal("The password contains the user name in some form", message)
        end)
    end
end)
