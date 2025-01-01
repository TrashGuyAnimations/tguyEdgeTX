-- toolName = "TNS|TGUY|TNE

local MAX_SPEED = 10

local options = {
    Text = "EdgeTX", -- Text input option with a default value
    TextColor = WHITE, -- Adjustable text color
    Speed = 5
}

TGUY = assert(loadScript("/SCRIPTS/TGUYCommon.lua"), "/SCRIPTS/TGUYCommon.lua is missing!")()

local widget = {}

local function init()
    widget = {
        options = options,
        nextUpdate = 0,
        tg = TGUY.init(options.Text)
    }

    local tg = widget.tg
    TGUY.log(string.format("Create max frames %d string [%s] len: %d", tg.tgMaxFrames, tg.tgTextStr, #tg.tgTextStr))
    return widget
end

local function run(event)

    if event == EVT_VIRTUAL_EXIT then
        return 1
    end

    local now = getTime()

    TGUY.log(string.format("refresh now: %d nextUpdate: %d", now, widget.nextUpdate))
    if (now >= widget.nextUpdate) then
        local tg = widget.tg
        if tg.tgFrame >= tg.tgMaxFrames - 1 then
            widget.tg = TGUY.init(widget.options.Text)
        end
        widget.tgGeneratedStr = TGUY.generate(widget.tg)
        widget.nextUpdate = getTime() + (10 * (MAX_SPEED - widget.options.Speed)) -- time is in 10ms intervals so 10 == 100ms
    end

    -- Determine font size and color
    local color = widget.options.TextColor
    lcd.clear()
    lcd.drawText(0, 0, widget.tgGeneratedStr, color)
    return 0
end

return { init = init, run = run }
