-- https://stackoverflow.com/a/622172 WORKING
function transformBoudingBox(angle, x0, y0, w, h)

    local sin = math.sin(angle)
    local cos = math.cos(angle)

    function transformCoordinates(amgle, x0, y0, x, y)
        return {
            x = x0 + (x - x0) * cos + (y - y0) * sin,
            y = y0 - (x - x0) * sin + (y - y0) * cos
        }
    end

    local tl = transformCoordinates(angle, x0, y0, (x0 - w / 2), (y0 - h / 2))
    local tr = transformCoordinates(angle, x0, y0, (x0 + w / 2), (y0 - h / 2))
    local bl = transformCoordinates(angle, x0, y0, (x0 - w / 2), (y0 + h / 2))
    local br = transformCoordinates(angle, x0, y0, (x0 + w / 2), (y0 + h / 2))

    -- coordinates of bounding box's top left corner
    local minx = math.min(tl.x, tr.x, bl.x, br.x)
    local miny = math.min(tl.y, tr.y, bl.y, br.y)

    --  width & height of bounding box
    local aw = math.max(tl.x, tr.x, bl.x, br.x) - minx
    local ah = math.max(tl.y, tr.y, bl.y, br.y) - miny

    -- [x,y] coordinates of bounding box's corners
    return minx, miny, aw, ah
end
