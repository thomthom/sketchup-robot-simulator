require 'tt_bot/geomutils'
require 'tt_bot/glutils'
require 'tt_bot/rover'
require 'tt_bot/simulation'
require 'tt_bot/target'

module TT::Plugins::Bot

  class SimulationTool

    include GeomUtils
    include GLUtils

    attr_reader :simulation

    def initialize(path, cpoints)
      @path = path

      @simulation = Simulation.new

      tr = orient2d(path.start.position, path.line[1])
      @rover = Rover.new
      @simulation.add_node(@rover, tr)

      cpoints.each { |cpoint|
        tr = Geom::Transformation.new(cpoint.position)
        @target = Target.new
        @simulation.add_node(@target, tr)
      }
    end

    def activate
      Sketchup.active_model.active_view.invalidate
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
      @simulation.draw(view)
    end

  end # class

end # module
