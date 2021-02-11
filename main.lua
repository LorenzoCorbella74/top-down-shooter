-- Debug
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

-- LIBRARIES
Gamestate = require 'libs.gamestate'    -- https://hump.readthedocs.io/en/latest/gamestate.html
sti = require "libs.sti"                -- https://github.com/karai17/Simple-Tiled-Implementation
bump = require 'libs.bump'              -- https://github.com/kikito/bump.lua
Camera = require 'libs.camera'          -- https://github.com/a327ex/STALKER-X
Timer = require "libs.timer"            -- https://hump.readthedocs.io/en/latest/timer.html

-- GAME STATES / SCREENS
title = require 'states.title'
gamescreen = require 'states.gamescreen'
pausescreen = require 'states.pausescreen'
gameover = require 'states.gameover'

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    font_md = love.graphics.newFont('assets/fonts/shattered-v1.ttf', 24)
    font_lg = love.graphics.newFont('assets/fonts/shattered-v1.ttf', 72)

    Gamestate.registerEvents()
    Gamestate.switch(title)
end
