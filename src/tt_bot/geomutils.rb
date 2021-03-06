module TT::Plugins::Bot

  module GeomUtils

    # @param [Geom::Point3d] center
    # @param [Geom::Vector3d] xaxis
    # @param [Numeric] radius
    # @param [Numeric] start_angle
    # @param [Numeric] end_angle
    # @param [Integer] segments
    #
    # @return [Array<Geom::Point3d>]
    def arc2d(center, radius, start_angle, end_angle, xaxis = X_AXIS, segments = 24)
      full_angle = end_angle - start_angle
      segment_angle = full_angle / segments
      t = Geom::Transformation.axes(center, xaxis, xaxis * Z_AXIS, Z_AXIS)
      arc = []
      (0..segments).each { |i|
        angle = start_angle + (segment_angle * i)
        x = radius * Math.cos(angle)
        y = radius * Math.sin(angle)
        arc << Geom::Point3d.new(x, y, 0).transform!(t)
      }
      arc
    end

    # @param [Geom::Point3d] center
    # @param [Geom::Vector3d] xaxis
    # @param [Numeric] radius
    # @param [Integer] segments
    #
    # @return [Array<Geom::Point3d>]
    def circle2d(center, radius, xaxis = X_AXIS, segments = 24)
      segments = segments.to_i
      angle = 360.degrees - (360.degrees / segments)
      arc2d(center, radius, 0, angle, xaxis, segments - 1)
    end

    def pie2d(center, radius, start_angle, end_angle, xaxis = X_AXIS, segments = 24)
      points = arc2d(center, radius, start_angle, end_angle, xaxis, segments)
      points << center
      points
    end

    def orient2d(position, direction)
      yaxis = direction
      xaxis = yaxis * Z_AXIS
      Geom::Transformation.new(position, xaxis, yaxis)
    end

  end # module

end # module
