require 'tt_bot/glutils'
require 'tt_bot/simulation'

module TT::Plugins::Bot

  class SimulationTool

    include GLUtils

    attr_reader :simulation

    def initialize(path, arrow)
      @path = path
      @arrow = arrow

      @simulation = Simulation.new

      yaxis = path.line[1]
      xaxis = yaxis * Z_AXIS
      tr = Geom::Transformation.new(path.start.position, xaxis, yaxis)
      @rover = Rover.new(tr)

      @simulation.add_node(@rover)
    end

    def deactivate(view)
      @simulation.stop
      view.invalidate
    end

    def suspend(view)
      view.invalidate
    end

    def resume(view)
      view.invalidate
    end

    def onMouseMove(flags, x, y, view)
      view.invalidate
    end

    def draw(view)
      pt1 = @arrow.position
      pt2 = @path.start.position
      pt3 = @path.end.position

      vector1 = pt2.vector_to(pt1)
      vector2 = pt3.vector_to(pt1)

      view.line_width = 2
      view.line_stipple = ''

      view.draw_points([pt1], 10, GL_OPEN_SQUARE, 'red')
      #view.draw_points([pt2], 10, GL_OPEN_TRIANGLE, 'green')
      #view.draw_points([pt3], 10, GL_OPEN_TRIANGLE, 'blue')

       view.line_stipple = '_'

       view.drawing_color = 'green'
       #view.draw(GL_LINES, pt1, pt2)

       view.drawing_color = 'blue'
       #view.draw(GL_LINES, pt1, pt3)

       @rover.draw(view)
    end

  end # class

end # module
