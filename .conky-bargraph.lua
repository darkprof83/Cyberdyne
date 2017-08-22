--this is a lua script for use in conky
require 'cairo'


function draw_rectangle (display, element)
  cairo_set_source_rgba (display, element.color.r, element.color.g, element.color.b, element.color.a)
  cairo_set_line_width (display, element.line_width)
  cairo_rectangle (display, element.from.x, element.from.y, element.to.x, element.to.y)
  cairo_stroke (display)
end-- end draw_speedgraph


function draw_line(display, element)
  cairo_set_source_rgba (display, element.color.r, element.color.g, element.color.b, element.color.a)
  cairo_set_line_width (display, element.line_width)
  cairo_move_to (display, element.from.x, element.from.y)
  cairo_rel_line_to (display, element.to.x, element.to.y)
  cairo_stroke(display);
end-- end draw_line


function draw_line_to(display, element)
  cairo_set_source_rgba (display, element.color.r, element.color.g, element.color.b, element.color.a)
  cairo_set_line_width (display, element.line_width)
  cairo_move_to (display, element.from.x, element.from.y)
  cairo_line_to (display, element.to.x, element.to.y)
  cairo_stroke(display);
end-- end draw_line

--[[
without scale    with scale
- 10000          - 10000
|                |
-                -
|                |
-                -
| 1000           |
-                -
|                | 5000
-                -
|                |
- 100            -
|                |
-                -
|                |
-                - 200 scale 0.3
| 10             |
-                - 33
|                |
-                - 6
|                |
- 1              - 1
]]--
function math_scale (value, max_speed, hight, scale)
  if value < 1 then
    return 1
  else
    return math.log10 (value) / math.log10 (max_speed) * hight * scale
  end
end-- end of


function draw_speedgraph (display, element)
  draw_rectangle (display, element.rectangle)

  local line = {
    color = {
      r = 1,
      g = 1,
      b = 1,
      a = 1,
    },
    line_width = 1,
    from = {x, y = element.rectangle.from.y + element.rectangle.to.y,},
    to = {x = 0, y,},
  }

  --local pixels = math_scale (element.value[element.index], element.max_speed, element.rectangle.to.y)
  element.value[element.index] = math_scale (element.value[element.index], element.max_speed, element.rectangle.to.y, element.scale)
  local x = element.rectangle.from.x + element.rectangle.to.x
  local c = element.count
  for i = element.index, 1, -1 do
    if c > 1 then
      c = c - 1
      -- пока для каждого столбца высота в пикселях расчитываетя каждый раз в цикле
      --local pixels = math_scale (element.value[i], element.max_speed, element.rectangle.to.y, element.scale)
      -- если график заливать не надо
      if element.fill == false then
        -- если еще нет сохраненной координаты y
        if element.last == 0 then
          line.from.y = element.rectangle.from.y + element.rectangle.to.y - element.value[i]
          line.from.x = x
        -- если уже есть сохраненные координаты y
        else
          line.from.y = element.last
          line.from.x = x - 1
        end-- end if element.last.x == 0 then
        line.to.y = element.rectangle.from.y + element.rectangle.to.y - element.value[i]
        line.to.x = x
        draw_line_to (display, line)
      -- если требуется залить график
      else
        -- с обходом цикла меняется только начальный х и dy
        line.from.x = x
        line.to.y = 0 - element.value[i]
        draw_line (display, line)
      end-- end if element.fill == false then
      element.last = line.to.y
      x = x - 1
    end-- if c > 0 then
  end-- end for

  for i = element.rectangle.to.x, element.index + 1, -1 do
    if c > 1 then
      c = c - 1
      --local pixels = math_scale (element.value[i], element.max_speed, element.rectangle.to.y, element.scale)
      -- если график заливать не надо
      if element.fill == false then
        -- если еще нет сохраненной координаты y
        if element.last == 0 then
          line.from.y = element.rectangle.from.y + element.rectangle.to.y - element.value[i]
          line.from.x = x
        -- если уже есть сохраненные координаты y
        else
          line.from.y = element.last
          line.from.x = x - 1
        end-- end if element.last.x == 0 then
        line.to.y = element.rectangle.from.y + element.rectangle.to.y - element.value[i]
        line.to.x = x
        draw_line_to (display, line)
      -- если требуется залить график
      else
        -- с обходом цикла меняется только начальный х и dy
        line.from.x = x
        line.to.y = 0 - element.value[i]
        draw_line (display, line)
      end-- end if element.fill == false then
      element.last = line.to.y
      x = x - 1
    end-- if c > 0 then
  end-- end for

  element.index = element.index + 1
  if element.index > element.rectangle.to.x then element.index = 1 end
  element.count = element.count + 1
  if element.count > element.rectangle.to.x then element.count = element.rectangle.to.x end
end-- end draw_speedgraph


upspeedgraph = {
  rectangle = {
    color = { r = 1, g = 1, b = 1, a = 1, },
    line_width = 1,
    from = {x = 3, y = 790,},
    to = {x = 200, y = 80,},
  },
  value = {},
  index = 1,
  count = 1,
  max_speed = 10000,
  fill = true,
  last = 0,
  scale = 1.0,
  --max_speed = 2048,
  --max_x = upspeedgraph.rectangle.to.x,
  --max_y = upspeedgraph.rectangle.to.y,
}

downspeedgraph = {
  rectangle = {
    color = { r = 1, g = 1, b = 1, a = 1, },
    line_width = 1,
    from = {x = 250, y = 790,},
    to = {x = 200, y = 80,},
  },
  value = {},
  index = 1,
  count = 1,
  max_speed = 10000,
  fill = true,
  last = 0,
  scale = 1.0,
  --max_speed = 2048,
  --max_x = upspeedgraph.rectangle.to.x,
  --max_y = upspeedgraph.rectangle.to.y,
}


function conky_main()
  if conky_window == nil then return end
  local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
  cr = cairo_create(cs)
  local updates=tonumber(conky_parse('${updates}'))

  if updates>2 then
    upspeedgraph.value[upspeedgraph.index] = tonumber(conky_parse('${upspeedf}'))
    --print (upspeedgraph.value[upspeedgraph.index])
    draw_speedgraph (cr, upspeedgraph)

    downspeedgraph.value[downspeedgraph.index] = tonumber(conky_parse('${downspeedf}'))
    draw_speedgraph (cr, downspeedgraph)
  end-- if updates>5

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr=nil
end-- end main function
