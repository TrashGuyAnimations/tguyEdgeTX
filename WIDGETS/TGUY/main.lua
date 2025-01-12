local MAX_SPEED = 10

local opts = {
    { "Text", STRING, "EdgeTX" }, -- Text input option with a default value
    { "TextColor", COLOR, COLOR_THEME_SECONDARY1 }, -- Adjustable text color
    { "Speed", VALUE, 5, 0, MAX_SPEED }, -- Adjustable speed
    { "Shadow", BOOL, 1 }, -- Make text shadowed
    { "LargeFont", BOOL, 0 }, -- Make text larger
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

local function refresh(widget, event, touchState)
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
    
    -- Needs explicit equality because BOOL option is returned as an integer
    local shadow = (widget.options.Shadow == 1 and SHADOWED) or 0
    local font_size = (widget.options.LargeFont == 1 and MIDSIZE) or 0
    local zone = widget.zone
    local text_x = zone.x
    local text_y = zone.y

    -- event indicates full screen mode
    if (event ~= nil) then
        zone.x = 0
        zone.y = 0
        zone.w = LCD_W
        zone.h = LCD_H
        font_size = DBLSIZE

        local text_w, text_h = 0, 0
        -- sizeText only exists since EdgeTX 2.5.0
        if (type(lcd.sizeText) == "function") then
            text_w, text_h = lcd.sizeText(widget.tgGeneratedStr, LEFT + CUSTOM_COLOR + font_size + shadow)
        end
        text_x = (LCD_W / 2) - (text_w / 2)
        text_y = (LCD_H / 2) - (text_h / 2)
    end

    lcd.drawRectangle(zone.x, zone.y, zone.w, zone.h, COLOR_THEME_PRIMARY3)
    -- Passing widget.options.TextColor to drawText instead of CUSTOM_COLOR works in practice,
    -- but official widgets use setColor + CUSTOM_COLOR so we do that too
    lcd.setColor(CUSTOM_COLOR, widget.options.TextColor)
    lcd.drawText(text_x, text_y, widget.tgGeneratedStr, LEFT + CUSTOM_COLOR + font_size + shadow)
end

return { name = "TGUY", options = opts, create = create, update = update, refresh = refresh }
