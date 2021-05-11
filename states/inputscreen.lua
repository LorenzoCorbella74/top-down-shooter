local state = {}

local config = require 'config'

local Slab = require 'libs.Slab.Slab'

local SelectedGameType = 1
local GameTypeOptions = { "Deathmatch","Team deathmatch","Capture the flag"}
local GameTypes = { "deathmatch","team_deathmatch","ctf"}

local scoreLimit = 10
local timeLimit = 5
-- https://quake.fandom.com/wiki/Quake_III_Arena#Difficulty
local botSkillOptions = {
    "I Can Win", -- bots will get handicapped at 50%, very slow reaction time, low awareness, slow movement, very low accuracy
    "Bring It On", -- bots will get handicapped at 70%, slow reaction time, low awareness, slow movement, mediocre accuracy
    "Hurt Me Plenty", --  bots will get handicapped at 90%, mediocre reaction time, alert, predictable movement, mediocre accuracy
    "Hardcore", -- no handicaps, fast reaction time, highly alert, unpredictable movement, high accuracy.
    "Nightmare!" -- no handicaps, league level reaction time, always alert, unpredictable movement, full accuracy.
}
local SelectedBotSkill = 3
local numberOfBots = 1

function state:enter() Slab.Initialize() end

function state:draw()
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setFont(Fonts.md)
    love.graphics.printf("Choose your game:", 0, H / 3, W, 'center')

    Slab.Draw()
end

function state:update(dt)
    Slab.Update(dt)

    Slab.BeginWindow('MyFirstWindow', {
        Title = "Choose your game:",
        AllowMove = false,
        AllowResize = false,
        X = 0,
        W = 250
    })
    Slab.Text("Gametype: ")
    for I, V in ipairs(GameTypeOptions) do
        if Slab.RadioButton(V, {Index = I, SelectedIndex = SelectedGameType}) then
            SelectedGameType = I
            if SelectedGameType == 3 then
                scoreLimit = 3
            else
                scoreLimit = 10
            end
        end
    end
    Slab.Separator()
    Slab.Text("Score limit: ")
    if Slab.Input('scoreLimit', {
        Text = tostring(scoreLimit),
        ReturnOnText = false,
        NumbersOnly = true,
        MinNumber = 1,
        MaxNumber = 25
    }) then scoreLimit = Slab.GetInputNumber() end
    Slab.Text("Time limit: ")
    if Slab.Input('timeLimit', {
        Text = tostring(timeLimit),
        ReturnOnText = false,
        NumbersOnly = true,
        MinNumber = 1,
        MaxNumber = 15
    }) then timeLimit = Slab.GetInputNumber() end

    Slab.Separator()

    Slab.Text("Bots number: ")
    if Slab.Input('numberOfBots', {
        Text = tostring(numberOfBots),
        ReturnOnText = false,
        NumbersOnly = true,
        MinNumber = 1,
        MaxNumber = 9
    }) then numberOfBots = Slab.GetInputNumber() end

    Slab.Text("Bots skill:")
    if Slab.BeginComboBox('MyComboBox', {Selected = SelectedBotSkill}) then
        for I, V in ipairs(botSkillOptions) do
            if Slab.TextSelectable(V) then SelectedBotSkill = I end
        end
        Slab.EndComboBox()
    end
    Slab.Separator()

    if Slab.Button("Fight") then
        print('Game type: ', SelectedGameType, GameTypes[SelectedGameType])
        print('Score limit: ', scoreLimit)
        print('Time limit: ', timeLimit)
        print('Selected Bot Skill: ', SelectedBotSkill)
        print('Number of bots: ', numberOfBots)

        config.setGame({
            BOTS_NUMBERS = numberOfBots,
            BOTS_SKILL = SelectedBotSkill,
            MATCH_DURATION = timeLimit * 60,
            SCORE_TO_WIN = scoreLimit,
            MATCH_TYPE = GameTypes[SelectedGameType]
        })
        Gamestate.push(GameScreen, 1)
    end
    Slab.EndWindow()
end

function state:keyreleased(key, code) if key == 'escape' then Gamestate.pop() end end

-- works only for Gamestate.switch
function state:leave()
    print('Leaving Input screen')
    Sound:stop('background_music')
end

return state
