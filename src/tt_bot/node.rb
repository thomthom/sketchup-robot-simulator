require 'tt_bot/geomutils'
require 'tt_bot/glutils'

module TT::Plugins::Bot

  class Node

    attr_accessor :parent
    attr_accessor :transformation

    include GeomUtils
    include GLUtils

    def initialize(parent = nil, transformation = ORIGIN)
      @parent = parent
      @transformation = transformation
    end

    def tick
    end

    private

    def total_transformation
      tr = Geom::Transformation.new
      node = self
      until node.nil?
        tr = node.transformation * tr
        node = node.parent
      end
      tr
    end

    def transform_points(*points)
      if points.size == 1
        args = points[0]
        if args.is_a?(Array) && !args[0].is_a?(Length)
          return transform_points(*args)
        end 
      end
      tr = total_transformation
      points.map { |point| point.transform(tr) }
    rescue
      p points
      raise
    end

  end # class

end # module
