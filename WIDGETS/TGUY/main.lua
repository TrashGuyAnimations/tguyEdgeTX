local MAX_SPEED = 10

local opts = {
    { "Text", STRING, "EdgeTX" }, -- Text input option with a default value
    { "TextColor", COLOR, COLOR_THEME_SECONDARY1 }, -- Adjustable text color
    { "Speed", VALUE, 5, 0, MAX_SPEED } -- Adjustable speed
}

TGUY = assert(loadScript("/SCRIPTS/TGUYCommon.lua"), "/SCRIPTS/TGUYCommon.lua is missing!")()

local function create(zone, options)
    local widget = {
        zone = zone,
        options = options,
        nextUpdate = 0,
        tg = TGUY.init(options.Text)
    }

    local tg = widget.tg
    TGUY.log(string.format("Create max frames %d string [%s] len: %d", tg.tgMaxFrames, tg.tgTextStr, #tg.tgTextStr))
    return widget
end

local function update(widget, options)
    widget.options = options
    widget.tg = TGUY.init(options.Text)

    local tg = widget.tg
    TGUY.log(string.format("Update max frames %d string [%s] len: %d", tg.tgMaxFrames, tg.tgTextStr, #tg.tgTextStr))
end

local function refresh(widget)
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

    local zone = widget.zone

    lcd.drawRectangle(0, 0, zone.w, zone.h, COLOR_THEME_PRIMARY3)
    lcd.drawText(0, 0, widget.tgGeneratedStr, color)
end

return { name = "TGUY", options = opts, create = create, update = update, refresh = refresh }
