require 'tt_bot/node'
require 'tt_bot/sensor'

module TT::Plugins::Bot

  class Rover < Node

    RANGE = 500.mm
    DISTANCE_PER_TICK = 5.mm

    def initialize(transformation = ORIGIN.clone)
      super(nil, transformation)

      @sensor_right = add_sensor(RANGE, [ 20.mm, 50.mm, 0], -30.degrees)
      @sensor_left  = add_sensor(RANGE, [-20.mm, 50.mm, 0],  30.degrees)
    end

    def tick
      direction = transformation.yaxis
      direction.length = DISTANCE_PER_TICK
      tr = Geom::Transformation.new(direction)
      @transformation = tr * @transformation
      nil
    end

    def draw(view)
      frame = transform_points(
        [ 30.mm,  60.mm, 0],
        [-30.mm,  60.mm, 0],
        [-30.mm, -60.mm, 0],
        [ 30.mm, -60.mm, 0]
      )
      view.line_stipple = ''
      view.line_width = 2
      view.drawing_color = 'blue'
      view.draw(GL_LINE_LOOP, frame)

      front = transform_points(
        [  0.mm,  60.mm, 0],
        [-30.mm,  20.mm, 0],
        [ 30.mm,  20.mm, 0]
      )
      view.draw(GL_LINE_LOOP, front)

      @sensor_right.draw(view)
      @sensor_left.draw(view)
    end

    private

    def add_sensor(range, position, angle)
      tr1 = Geom::Transformation.new(ORIGIN, Z_AXIS, angle)
      tr2 = Geom::Transformation.new(position)
      tr3 = tr2 * tr1
      Sensor.new(range, self, tr3)
    end

  end # class Rover

end # module
