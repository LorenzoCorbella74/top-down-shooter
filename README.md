# Top down shooter

![IMG](doc/tds.gif)

![](https://img.shields.io/badge/type-JS_Library-brightgreen.svg "Project type")
![](https://img.shields.io/github/repo-size/LorenzoCorbella74/top-down-shooter "Repository size")
![](https://img.shields.io/github/package-json/v/LorenzoCorbella74/top-down-shooter)

After my first 2D experiment in [typescript](https://github.com/LorenzoCorbella74/test-canvas-game) I decided to switch to the Lua programming language and the amazing [love framework](https://love2d.org/) to realize a full feature top down shooter able to recreate the Arena shooters (Quake 3 Arena, Unreal Tournament...) mechanics.

## Features
- [x] the game engine use maps built with [tiled](https://www.mapeditor.org/) and imported with [Simple-Tiled-Implementation](https://github.com/karai17/Simple-Tiled-Implementation)
- [x] collision system with [bump](https://github.com/kikito/bump.lua)
- [x] debug mode (camera cycle for bots)
- [x] spawn mechanism
- [x] particles (debris, blood)
    - [ ] explosion
- [x] powerups system with different respawn time + counter
- [x] different weapons
    - []  different effects for each weapon
- [x] bots AI
    - [x] A* navigation based on waypoints and powerups  (powerups, ammo, weapons) desiderability based on utility theory
    - [x] brain with Finite state machine
    - [x] Line of sight and cone of view
    - [x] bots' aim with target position extimation 
    - [x] weapons'choice according to bot preferences
    - [x] BOT AI level
- [ ] portals and jump pads (with animation)
- [ ] UI MESSAGES
    - [x] warmup, 1 minute warning, etc
    - [ ] multiple, assist, etc
- [x] different game modes (deathmatch, team deathmach, ctf)
- [x] multiple maps
- [x] music and effects (sort of...)
- [ ] multiplayer
- [x] multiple screen, stat screen (game over screen), game configuration screen, pause screen


## Todos
- [ ] 


# Demo
Test things locally by just using the love framework.

## Bugs
- Uhm, many...!

## License
This project is licensed under the ISC License.