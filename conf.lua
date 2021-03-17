function love.conf(t)
    t.author = "LCorbella74"
    t.title = "My Topdown shooter" 
	t.version = "11.3"              -- The LÖVE version this game was made for 
	
    t.window.width = 1024
    t.window.height = 768
    t.window.minwidth = 100
    t.window.minheight = 100
    t.window.resizable = true
    t.window.vsync = true

    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
 
    -- Disable unused modules
    t.modules.physics = false
	t.modules.touch = false
    t.modules.physics = false
	t.modules.joystick = false

    t.console = false		-- comment this if VSC extention Local Lua Debugger is enabled 
    -- https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode
    -- https://stackoverflow.com/a/65066145
end


-- for reference: https://love2d.org/wiki/Config_Files

