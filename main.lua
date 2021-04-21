-- Debug with VSC
--[[ if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end ]]

-- LIBRARIES
Gamestate = require 'libs.gamestate'    -- https://hump.readthedocs.io/en/latest/gamestate.html
sti = require "libs.sti"                -- https://github.com/karai17/Simple-Tiled-Implementation
bump = require 'libs.bump'              -- https://github.com/kikito/bump.lua
Camera = require 'libs.camera'          -- https://github.com/a327ex/STALKER-X
Timer = require "libs.timer"            -- https://hump.readthedocs.io/en/latest/timer.html
Sound = require("libs/sounds")

-- GAME STATES / SCREENS
TitleScreen = require 'states.titlescreen'
GameScreen = require 'states.gamescreen'
PauseScreen = require 'states.pausescreen'
GameoverScreen = require 'states.gameoverscreen'

function love.load(arg)
    -- debug with ZEROBRANE Studio
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    --[[ if pcall(require, "lldebugger") then require("lldebugger").start() end
    if pcall(require, "mobdebug") then require("mobdebug").start() end ]]

    debug = false

    math.randomseed(os.time()) -- init generator
    
    love.graphics.setDefaultFilter("nearest", "nearest")
    Sprites = {
        
        player = love.graphics.newImage("myTiles/player.png"),
        -- bots
        red_bot = love.graphics.newImage("myTiles/red_bot.png"),
        blue_bot = love.graphics.newImage("myTiles/blue_bot.png"),
        --flags
        red_flag = love.graphics.newImage("myTiles/red_flag.png"),
        blue_flag = love.graphics.newImage("myTiles/blue_flag.png"),
        -- powerups
        powerup_health = love.graphics.newImage("myTiles/powerup_health.png"),
        powerup_megaHealth = love.graphics.newImage("myTiles/powerup_megaHealth.png"),
        powerup_armour = love.graphics.newImage("myTiles/powerup_armour.png"),
        powerup_megaArmour = love.graphics.newImage("myTiles/powerup_megaArmour.png"),
        powerup_quad = love.graphics.newImage("myTiles/powerup_quad.png"),
        powerup_speed = love.graphics.newImage("myTiles/powerup_speed.png"),
        -- ammo packs
        ammo_Rifle = love.graphics.newImage("myTiles/ammo_Rifle.png"),
        ammo_Shotgun = love.graphics.newImage("myTiles/ammo_Shotgun.png"),
        ammo_Plasma = love.graphics.newImage("myTiles/ammo_Plasma.png"),
        ammo_Rocket = love.graphics.newImage("myTiles/ammo_Rocket.png"),
        ammo_Railgun = love.graphics.newImage("myTiles/ammo_Railgun.png"),
        -- -- weapons
        weaponRifle = love.graphics.newImage("myTiles/weapon_rifle.png"),
        weaponShotgun = love.graphics.newImage("myTiles/weapon_shotgun.png"),
        weaponPlasma = love.graphics.newImage("myTiles/weapon_plasma.png"),
        weaponRocket = love.graphics.newImage("myTiles/weapon_rocket.png"),
        weaponRailgun = love.graphics.newImage("myTiles/weapon_railgun.png"),
        -- Bullets
        bullet_Rifle = love.graphics.newImage("myTiles/bullet_Rifle.png"),
        bullet_Shotgun = love.graphics.newImage("myTiles/bullet_Shotgun.png"),
        bullet_Plasma = love.graphics.newImage("myTiles/bullet_Plasma.png"),
        bullet_Rocket = love.graphics.newImage("myTiles/bullet_Rocket.png"),
        bullet_Railgun = love.graphics.newImage("myTiles/bullet_Railgun.png")
    }
     Fonts = {
        sm = love.graphics.newFont( --[[ 'assets/fonts/shattered-v1.ttf', ]] 12),
        md = love.graphics.newFont( --[[ 'assets/fonts/shattered-v1.ttf', ]] 24),
        lg = love.graphics.newFont( --[[ 'assets/fonts/shattered-v1.ttf', ]] 72)
    }

    Sound:init("backgroundTitle", "Sounds/Dark Intro.ogg", "static")
    -- firing
    Sound:init("Rifle", "Sounds/rifle.mp3", "static")
    Sound:init("Shotgun", "Sounds/shotgun.mp3", "static")
    Sound:init("Rocket", "Sounds/rocket.mp3", "static")
    Sound:init("Railgun", "Sounds/railgun.mp3", "static")
    Sound:init("Plasma", "Sounds/plasma.mp3", "static")

    Gamestate.registerEvents()
    -- set first state
    Gamestate.switch(TitleScreen)
end

function love.update()
    Sound:update() 
end

function love.draw() end

