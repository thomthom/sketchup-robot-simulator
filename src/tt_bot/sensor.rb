require 'tt_bot/baseobject'
require 'tt_bot/node'

module TT::Plugins::Bot


  module SensorTarget

    def object_info
      "@ #{global_position.inspect}"
    end

  end # module


  class Ping < BaseObject

    attr_reader :source
    attr_reader :target
    attr_reader :distance

    def initialize(source, target)
      @source = source
      @target = target
      @distance = source.distance(target)
    end

    def object_info
      "range: #{source.range}, distance: #{@distance}"
    end

  end # class


  class Sensor < Node

    attr_reader :range

    def initialize(range)
      super()
      @range = range
    end

    def object_info
      "range #{@range} @ #{global_position.inspect}"
    end

    def ping
      response = []
      simulation.nodes.each { |node|
        next unless node.is_a?(SensorTarget)
        ping = Ping.new(self, node)
        response << ping if ping.distance <= @range
      }
      response
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
      view.draw_points([pt1], 10, GL_X, 'purple')

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
