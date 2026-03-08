#include <pwquality.h>
#include <stdio.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>

static int check_password(lua_State *L)
{
    const char *password = luaL_checkstring(L, 1);
    const char *user = luaL_optstring(L, 2, NULL);
    const int nargs = lua_gettop(L);

    pwquality_settings_t *pwq = pwquality_default_settings();
    if (pwq == NULL)
    {
        return luaL_error(L, "failed to initialize pwquality settings");
    }

    if (nargs > 2)
    {
        luaL_checktype(L, 3, LUA_TTABLE);

        lua_pushnil(L);
        while (lua_next(L, 3) != 0)
        {
            const char *key = lua_tostring(L, -2);
            if (key == NULL)
            {
                pwquality_free_settings(pwq);
                return luaL_error(L, "option keys must be strings");
            }
            const char *value = lua_tostring(L, -1);
            if (value == NULL)
            {
                pwquality_free_settings(pwq);
                return luaL_error(L, "option values must be strings");
            }

            char buffer[strlen(key) + strlen(value) + 2];
            snprintf(buffer, sizeof(buffer), "%s=%s", key, value);
            if (pwquality_set_option(pwq, buffer) != 0)
            {
                pwquality_free_settings(pwq);
                return luaL_error(L, "failed to set option: %s", key);
            }

            lua_pop(L, 1);
        }
    }

    void *auxerror = NULL;
    int rv = pwquality_check(pwq, password, NULL, user, &auxerror);
    pwquality_free_settings(pwq);

    if (rv < 0)
    {
        char buffer[PWQ_MAX_ERROR_MESSAGE_LEN];
        const char *message = pwquality_strerror(buffer, sizeof(buffer), rv, auxerror);
        lua_pushnil(L);
        lua_pushinteger(L, rv);
        lua_pushstring(L, message);
        return 3;
    }

    lua_pushboolean(L, 1);
    lua_pushinteger(L, rv);
    return 2;
}

static const luaL_Reg module_functions[] = {
    {"check", check_password},
    {NULL, NULL}};

int luaopen_pwquality(lua_State *L)
{
    luaL_newlib(L, module_functions);
    return 1;
}
