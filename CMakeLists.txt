
cmake_minimum_required(VERSION 3.18.0)

project(pwquality
    VERSION 1.0.1
    LANGUAGES C
    HOMEPAGE_URL https://github.com/lkpot/lua-pwquality
    DESCRIPTION "Password quality checking library for Lua"
)

set(CMAKE_BUILD_TYPE Release)

include(CTest)
include(FindLua)
include(GNUInstallDirs)

find_package(PkgConfig REQUIRED)
pkg_check_modules(PWQUALITY REQUIRED IMPORTED_TARGET pwquality)

add_library(${CMAKE_PROJECT_NAME} MODULE lua_pwquality.c)
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${LUA_INCLUDE_DIR})
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE ${LUA_LIBRARIES} PkgConfig::PWQUALITY)
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES PREFIX "")

install(TARGETS ${CMAKE_PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_LIBDIR}/lua/${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR})

if(BUILD_TESTING)
    find_program(CPPCHECK_EXECUTABLE cppcheck REQUIRED)
    add_test(
        NAME CPPCHECK
        COMMAND ${CPPCHECK_EXECUTABLE}
            --language=c
            --enable=all
            --suppressions-list=${CMAKE_SOURCE_DIR}/cppcheck-suppressions.txt
            --error-exitcode=1
            lua_pwquality.c
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    )

    find_program(BUSTED_EXECUTABLE NAMES busted REQUIRED)
    add_test(
        NAME BUSTED
        COMMAND ${BUSTED_EXECUTABLE} -o junit -Xoutput=${CMAKE_BINARY_DIR}/busted.xml ${CMAKE_SOURCE_DIR}/test-pwquality.lua
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )

    find_program(LUACHECK_EXECUTABLE NAMES luacheck REQUIRED)
    add_test(
        NAME LUACHECK
        COMMAND ${LUACHECK_EXECUTABLE} --no-max-line-length ${CMAKE_SOURCE_DIR}/test-pwquality.lua
    )
endif()
