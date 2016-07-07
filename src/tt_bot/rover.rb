require 'tt_bot/node'
require 'tt_bot/sensor'

module TT::Plugins::Bot

  class Rover < Node

    RANGE = 500.mm
    ANGLE_PER_TICK = 2.degrees
    DISTANCE_PER_TICK = 5.mm

    def initialize
      super()
      add_sensor(RANGE, [ 20.mm, 50.mm, 0], -30.degrees)
      add_sensor(RANGE, [-20.mm, 50.mm, 0],  30.degrees)
      @path_traveled = []
    end

    def sensors
      @nodes.grep(Sensor)
    end

    def tick
      direction = forward

      pings = sensors.map { |sensor|
        response = sensor.ping
        response.empty? ? nil : response.min { |a, b| a.distance <=> b.distance }
      }
      pings.compact!

      unless pings.empty?
        # Figure out which sensor is closest to the target.
        closest = pings.min { |a, b| a.distance <=> b.distance }

        # Take into account that the censor is offset from the rover's centre
        # line and origin. Detect when it is close enough to the target.
        point = closest.source.position.project_to_line([ORIGIN, Y_AXIS])
        sensor_offset = point.distance(closest.source.position)
        if closest.distance - sensor_offset <= DISTANCE_PER_TICK
          # Remove the target as we reach it.
          simulation.remove_node(closest.target)
          return nil
        end

        # The new direction for the robot would be a weighted average of the
        # distances from the sensors that received a response to their pings.
        # By giving more weight to the sensor that's closest to the target the
        # robot should be able to find its way.
        direction = Geom::Vector3d.new(0, 0, 0)
        pings.each { |ping|
          weight = closest.distance / ping.distance / pings.size
          sensor_direction = ping.source.forward
          # Apply the transformation of the parent.
          sensor_direction.transform!(@transformation)
          # Apply the computed weight of the sensor direction to the final
          # direction.
          direction.x += (sensor_direction.x * weight)
          direction.y += (sensor_direction.y * weight)
          direction.z += (sensor_direction.z * weight)
        }

        # Restrict the robot from turning to much each tick.
        angle = forward.angle_between(direction)
        if angle > ANGLE_PER_TICK
          weight = ANGLE_PER_TICK / angle
          direction = Geom.linear_combination(
              weight, direction,
              1.0 - weight, forward
          )
        end

        @transformation = orient2d(position, direction) 
      end

      record_position
      move(direction)
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

      if @path_traveled.size > 2
        view.line_stipple = '-'
        view.drawing_color = 'gray'
        view.draw(GL_LINE_STRIP, @path_traveled)
      end
    end

    private

    def move(direction)
      vector = direction.clone
      vector.length = DISTANCE_PER_TICK
      tr = Geom::Transformation.new(vector)
      @transformation = tr * @transformation
      vector
    end

    def record_position
      @path_traveled << global_position
    end

    def add_sensor(range, position, angle)
      tr1 = Geom::Transformation.new(ORIGIN, Z_AXIS, angle)
      tr2 = Geom::Transformation.new(position)
      tr3 = tr2 * tr1
      sensor = Sensor.new(range)
      add_node(sensor, tr3)
      sensor
    end

  end # class Rover

end # module
