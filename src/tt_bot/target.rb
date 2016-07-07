require 'tt_bot/node'
require 'tt_bot/sensor'

module TT::Plugins::Bot

  class Target < Node

    include SensorTarget

    def draw(view)
      view.line_width = 2
      view.line_stipple = ''
      points = [global_position]
      view.draw_points(points, 10, GL_OPEN_SQUARE, 'purple')
    end

  end # class

end # module
