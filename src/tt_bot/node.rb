require 'tt_bot/baseobject'
require 'tt_bot/geomutils'
require 'tt_bot/glutils'

module TT::Plugins::Bot

  class Node < BaseObject

    attr_reader :nodes
    attr_accessor :parent
    attr_accessor :transformation

    include GeomUtils
    include GLUtils

    def initialize
      @transformation = IDENTITY.clone
      @nodes = []
      @parent = nil
    end

    def add_node(node, transformation = IDENTITY.clone)
      check_type(transformation, Geom::Transformation)
      raise ArgumentError, "#{node} already have a parent" if node.parent
      node.transformation = transformation
      node.parent = self
      @nodes << node
      nil
    end

    def remove_node(node)
      @nodes.delete(node)
    end

    def forward
      transformation.yaxis
    end

    def position
      @transformation.origin
    end

    def global_position
      transform_points(ORIGIN)[0]
    end

    def distance(node)
      global_position.distance(node.global_position)
    end

    def tick
    end

    # @param [Simulation]
    def simulation
      node = self
      until node.parent.nil?
        node = node.parent
      end
      node
    end

    def draw(view)
    end

    protected

    def draw_nodes(view)
      draw(view) unless parent.nil? # Avoid recursive draw by Simulation.
      @nodes.each { |node|
        node.draw_nodes(view)
      }
      draw_debug(view)
    end

    private

    def draw_debug(view)
      view.line_width = 2
      view.line_stipple = ''
      points = [global_position]
      view.draw_points(points, 10, GL_X, 'red')

      point = view.screen_coords(global_position)
      options = {
        :font => "Consolas",
        :size => 8,
        :color => 'red'
      }
      text = "#{self}\n#{position.inspect}"
      if false
        tr = format_transformation(transformation)
        text << "\n#{tr}"
      end
      view.draw_text(point, text, options)
    end

    def format_transformation(transformation)
      row = '%.3f,%.3f,%.3f,%.3f'
      sprintf("[\n  #{row}\n  #{row}\n  #{row}\n  #{row}\n]",
          *transformation.to_a)
    end

    def check_type(value, type, message = nil)
      message ||= "not a valid #{type}"
      raise TypeError, message unless value.is_a?(type)
    end

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
