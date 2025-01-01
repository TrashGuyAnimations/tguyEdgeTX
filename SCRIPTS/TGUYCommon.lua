local TGUYCommon = { logFilePath = "/LOGS/TGUY_log.txt" }

function TGUYCommon.log(msg)
    if 0 then
        local dateTime = getDateTime()

        -- Format timestamp as [HH:MM:SS.MS]
        local timestamp = string.format(
                "[%04d-%02d-%02d %02d:%02d:%02d]",
                dateTime.year, dateTime.mon, dateTime.day,
                dateTime.hour, dateTime.min, dateTime.sec
        )

        local file = io.open(TGUYCommon.logFilePath, "a")
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
function TGUYCommon.filter_garbage(str)
    local result = ""
    for i = 1, #str do
        local c = string.sub(str, i, i)
        if string.match(c, "[%w]") then
            result = result .. c
        end
    end
    return result
end

function TGUYCommon.get_max_frames(tg)
    return get_lower_frame_boundary(tg.tgInitialFramesCount, #tg.tgTextStr) + 1
end

function TGUYCommon.init(text)
    local tg = {}
    tg.tgTextStr = text
    tg.tgFrame = 0
    tg.tgElementIndex = 0
    tg.tgInitialFramesCount = (4 + 1) * 2
    tg.tgMaxFrames = TGUYCommon.get_max_frames(tg)
    return tg
end

function TGUYCommon.generate(tg)
    -- number of frames needed to process element, see 2 */
    local frames_per_element = tg.tgInitialFramesCount + (2 * tg.tgElementIndex);
    -- index of the frame in the frame series (up to frames_per_element) */
    local sub_frame = (tg.tgFrame - get_lower_frame_boundary(tg.tgInitialFramesCount, tg.tgElementIndex))
    -- if we're in the first half frames we're moving right, otherwise left */
    local frames_per_direction = math.floor(frames_per_element / 2)
    local right = (sub_frame < frames_per_direction)
    -- TrashGuy index yields 0 twice, the difference is whether we're moving right or left */
    local i = (right) and sub_frame or frames_per_element - sub_frame - 1

    local tguy_sprite = "(> ^_^)>";
    if (not right) then
        tguy_sprite = string.format("%s<(^_^ <)",
                i ~= 0 and string.sub(tg.tgTextStr, tg.tgElementIndex + 1, tg.tgElementIndex + 1) or ""
        )
    end

    tg.tgGeneratedStr = string.format("U%s%s%s%s",
            string.rep(" ", i - b2i(not right)),
            tguy_sprite,
            string.rep(" ", frames_per_direction - i - b2i(right)),
            string.sub(tg.tgTextStr, tg.tgElementIndex + 1 + b2i(not right))
    )

    -- used to make set_frame faster by not setting same frame twice and to assert unset TrashGuyState */
    tg.tgFrame = tg.tgFrame + 1;
    tg.tgElementIndex = tg.tgElementIndex + b2i(i == 0 and not right);

    return tg.tgGeneratedStr
end

return TGUYCommon