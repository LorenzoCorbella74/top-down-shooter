-- Debug
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end
--[[ if pcall(require, "lldebugger") then require("lldebugger").start() end
if pcall(require, "mobdebug") then require("mobdebug").start() end ]]

-- LIBRARIES
Gamestate = require 'libs.gamestate' -- https://hump.readthedocs.io/en/latest/gamestate.html
sti = require "libs.sti" -- https://github.com/karai17/Simple-Tiled-Implementation
bump = require 'libs.bump' -- https://github.com/kikito/bump.lua
Camera = require 'libs.camera' -- https://github.com/a327ex/STALKER-X
Timer = require "libs.timer" -- https://hump.readthedocs.io/en/latest/timer.html

-- GAME STATES / SCREENS
title = require 'states.title'
gamescreen = require 'states.gamescreen'
pausescreen = require 'states.pausescreen'
gameover = require 'states.gameover'

require 'helpers.printTable'

debug = false

function love.load()
    -- debug
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    Sprites = {
        player = love.graphics.newImage("myTiles/player.png"),
        powerup_health = love.graphics.newImage("myTiles/powerup_health.png"),
        powerup_megaHealth = love.graphics.newImage("myTiles/powerup_megaHealth.png"),
        powerup_armour = love.graphics.newImage("myTiles/powerup_armour.png"),
        powerup_megaArmour = love.graphics.newImage("myTiles/powerup_megaArmour.png"),
        powerup_quad = love.graphics.newImage("myTiles/powerup_quad.png"),
        powerup_speed = love.graphics.newImage("myTiles/powerup_speed.png"),
        -- ammo packs
        -- ammoRifle = love.graphics.newImage("myTiles/powerup_health2.png"),
        -- ammoShotgun = {of = 'Shotgun', spawnTime = 30, amount = 24},
        -- ammoPlasma = {of = 'Plasma', spawnTime = 30, amount = 25},
        -- ammoRocket = {of = 'Rocket', spawnTime = 30, amount = 5},
        -- ammoRailgun = {of = 'Railgun', spawnTime = 30, amount = 5},
        -- -- weapons
        -- weaponShotgun = {of = 'Shotgun', spawnTime = 30, amount = 24},
        -- weaponPlasma = {of = 'Plasma', spawnTime = 30, amount = 25},
        -- weaponRocket = {of = 'Rocket', spawnTime = 30, amount = 5},
        -- weaponRailgun = {of = 'Railgun', spawnTime = 30, amount = 5}
    }
     Fonts = {
        sm = love.graphics.newFont( --[[ 'assets/fonts/shattered-v1.ttf', ]] 12),
        md = love.graphics.newFont( --[[ 'assets/fonts/shattered-v1.ttf', ]] 12),
        lg = love.graphics.newFont( --[[ 'assets/fonts/shattered-v1.ttf', ]] 12)
    }
    font_sm = love.graphics.newFont( --[[ 'assets/fonts/shattered-v1.ttf', ]] 12)
    font_md = love.graphics.newFont( --[[ 'assets/fonts/shattered-v1.ttf', ]] 24)
    font_lg = love.graphics.newFont( --[[ 'assets/fonts/shattered-v1.ttf', ]] 72)

    Gamestate.registerEvents()
    Gamestate.switch(title)
end

function love.draw() end

