require 'tt_bot/node'

module TT::Plugins::Bot

  class Simulation < Node

    def initialize
      super()
      @timer = nil
    end

    def start
      @timer = UI.start_timer(0.1, true) {
        tick
      }
      nil
    end

    def stop
      UI.stop_timer(@timer) if @timer
      @timer = nil
      nil
    end

    def tick
      #puts "===== TICK (#{Time.now.to_i}) ====="
      @nodes.each { |node| node.tick }
      Sketchup.active_model.active_view.invalidate
      nil
    rescue
      warn 'stopping simulation'
      stop
      raise
    end

    def draw(view)
      draw_nodes(view)
    end

  end # class simulation

end # module
