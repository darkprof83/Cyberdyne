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


function draw_speedgraph (display, element)
  draw_rectangle (display, element.rectangle)

  local line = {
    color = {
      r = element.rectangle.color.r,
      g = element.rectangle.color.g,
      b = element.rectangle.color.b,
      a = element.rectangle.color.a,
    },
    line_width = 1,
    from = {x, y = element.rectangle.from.y + element.rectangle.to.y,},
    to = {x = 0, y,},
  }

  local c = element.count
  local x = element.rectangle.from.x + element.rectangle.to.x
  for i = element.index, 1, -1 do
    if c > 1 then
      c = c - 1
      local pixels = element.value[i] / element.max_speed * element.rectangle.to.y
      line.from.x = x
      line.to.y = 0 - pixels
      draw_line (display, line)
      x = x - 1
    end-- if c > 0 then
  end-- end for

  for i = element.rectangle.to.x, element.index - 1, -1 do
    if c > 1 then
      c = c - 1
      local pixels = element.value[i]/element.max_speed * element.rectangle.to.y
      line.from.x = x
      line.to.y = 0 - pixels
      draw_line (display, line)
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
  --max_speed = 10240,
  max_speed = 2048,
  --max_x = upspeedgraph.rectangle.to.x,
  --max_y = upspeedgraph.rectangle.to.y,
}


function conky_main()
  if conky_window == nil then return end
  local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
  cr = cairo_create(cs)
  local updates=tonumber(conky_parse('${updates}'))

  if updates>5 then
    upspeedgraph.value[upspeedgraph.index] = tonumber(conky_parse('${upspeedf}'))
    --print (upspeedgraph.value[upspeedgraph.index])
    draw_speedgraph (cr, upspeedgraph)
  end-- if updates>5

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr=nil
end-- end main function
