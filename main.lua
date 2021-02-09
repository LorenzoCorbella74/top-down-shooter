-- Debug
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local Gamestate = require 'libs.gamestate'
local title = require 'states.title'

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  Gamestate.registerEvents()
  Gamestate.switch(title)
end