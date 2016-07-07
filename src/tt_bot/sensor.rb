require 'tt_bot/node'

module TT::Plugins::Bot

  class Sensor < Node

    def initialize(range, parent, transformation)
      super(parent, transformation)
      @range = range
    end

    def ping
    end

    def draw(view)
      front = transform_points(
        [  0.mm,  15.mm, 0],
        [ -5.mm,   0.mm, 0],
        [  5.mm,   0.mm, 0]
      )
      view.line_stipple = ''
      view.line_width = 2
      view.drawing_color = 'green'
      view.draw(GL_LINE_LOOP, front)

      pt1 = transform_points(ORIGIN)
      view.draw_points([pt1], 10, GL_X, 'red')

      angle = 45.degrees
      pie = pie2d(ORIGIN, @range, -angle, angle, Y_AXIS)
      range = transform_points(pie)
      view.drawing_color = 'purple'
      view.draw(GL_LINE_LOOP, range)

      center_line = transform_points(ORIGIN, [0, @range, 0])
      view.line_stipple = '_'
      view.draw(GL_LINES, center_line)
    end

  end # class Sensor

end # module
