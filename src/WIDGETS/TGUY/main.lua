local MAX_SPEED = 10

local opts = {
    { "Text", STRING, "EdgeTX" }, -- Text input option with a default value
    { "TextColor", COLOR, COLOR_THEME_SECONDARY1 }, -- Adjustable text color
    { "Speed", VALUE, 5, 0, MAX_SPEED } -- Adjustable speed
}

local function log(widget, msg)
    if 0 then
        local dateTime = getDateTime()

        -- Format timestamp as [HH:MM:SS.MS]
        local timestamp = string.format(
                "[%04d-%02d-%02d %02d:%02d:%02d]",
                dateTime.year, dateTime.mon, dateTime.day,
                dateTime.hour, dateTime.min, dateTime.sec
        )

        local file = io.open(widget.logFilePath, "a")
        if file then
            io.write(file, timestamp, msg, "\r\n")
            io.close(file)
        end
    end
end

local function b2i(val)
    return val and 1 or 0
end

local function get_lower_frame_boundary(initial_frames_count, el_index)
    return el_index * (el_index + initial_frames_count - 1)
end


-- for some reason option string parameters might contain garbage,
-- filter characters which aren't present in keyboard
local function filter_garbage(str)
    local result = ""
    for i = 1, #str do
        local c = string.sub(str, i, i)
        if string.match(c, "[%w]") then
            result = result .. c
        end
    end
    return result
end

local function get_max_frames(widget)
    return get_lower_frame_boundary(widget.tgInitialFramesCount, #widget.tgTextStr) + 1
end

local function create(zone, options)
    local widget = {
        zone = zone,
        options = options,
        nextUpdate = getTime(),
        tgGeneratedStr = "",
        tgTextStr = "",
        tgFrame = 0,
        tgElementIndex = 0,
        tgInitialFramesCount = (4 + 1) * 2,
        tgMaxFrames = 0,
        logFilePath = string.format("/LOGS/TGUY_log%d.txt", getTime())
    }
    widget.tgTextStr = filter_garbage(options.Text)
    widget.tgMaxFrames = get_max_frames(widget)

    log(widget, string.format("Create max frames %d string [%s] len: %d", widget.tgMaxFrames, widget.tgTextStr, #widget.tgTextStr))
    return widget
end

local function update(widget, options)
    widget.tgTextStr = filter_garbage(options.Text)
    widget.tgMaxFrames = get_max_frames(widget)
    widget.tgFrame = 0
    widget.tgElementIndex = 0
    widget.options = options

    log(widget, string.format("Update max frames %d string [%s] len: %d", widget.tgMaxFrames, widget.tgTextStr, #widget.tgTextStr))
end

local function generate_tguy(widget)
    log(widget, "generate")
    -- number of frames needed to process element, see 2 */
    local frames_per_element = widget.tgInitialFramesCount + (2 * widget.tgElementIndex);
    -- index of the frame in the frame series (up to frames_per_element) */
    local sub_frame = (widget.tgFrame - get_lower_frame_boundary(widget.tgInitialFramesCount, widget.tgElementIndex))
    -- if we're in the first half frames we're moving right, otherwise left */
    local frames_per_direction = math.floor(frames_per_element / 2)
    local right = (sub_frame < frames_per_direction)
    -- TrashGuy index yields 0 twice, the difference is whether we're moving right or left */
    local i = (right) and sub_frame or frames_per_element - sub_frame - 1

    local tguy_sprite = "(> ^_^)>";
    if (not right) then
        tguy_sprite = string.format("%s<(^_^ <)",
                i ~= 0 and string.sub(widget.tgTextStr, widget.tgElementIndex + 1, widget.tgElementIndex + 1) or ""
        )
    end

    widget.tgGeneratedStr = string.format("U%s%s%s%s",
            string.rep(" ", i - b2i(not right)),
            tguy_sprite,
            string.rep(" ", frames_per_direction - i - b2i(right)),
            string.sub(widget.tgTextStr, widget.tgElementIndex + 1 + b2i(not right))
    )

    -- used to make set_frame faster by not setting same frame twice and to assert unset TrashGuyState */
    widget.tgFrame = widget.tgFrame + 1;
    widget.tgElementIndex = widget.tgElementIndex + b2i(i == 0 and not right);
end

local function refresh(widget)
    local now = getTime()

    log(widget, string.format("refresh now: %d nextUpdate: %d", now, widget.nextUpdate))
    local tgString = "";
    if (now >= widget.nextUpdate) then
        if widget.tgFrame >= widget.tgMaxFrames - 1 then
            widget.tgFrame = 0
            widget.tgElementIndex = 0
        end
        generate_tguy(widget)
        widget.nextUpdate = getTime() + (10 * (MAX_SPEED - widget.options.Speed)) -- time is in 10ms intervals so 10 == 100ms
    end

    tgString = widget.tgGeneratedStr

    -- Determine font size and color
    local color = widget.options.TextColor

    local zone = widget.zone

    lcd.drawRectangle(0, 0, zone.w, zone.h, COLOR_THEME_PRIMARY3)
    lcd.drawText(0, 0, widget.tgGeneratedStr, color)
end

return { name = "TGUY", options = opts, create = create, update = update, refresh = refresh }
