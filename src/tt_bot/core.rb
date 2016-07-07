require 'tt_bot/simulation_tool'

module TT::Plugins::Bot

  unless file_loaded?(__FILE__)
    menu = UI.menu('Plugins')
    menu.add_item('Simulate Triangulation') {
      self.start_simulation
    }
    file_loaded(__FILE__)
  end

  def self.start_simulation
    model = Sketchup.active_model
    path = model.entities.grep(Sketchup::Edge).first
    arrow = model.entities.grep(Sketchup::ConstructionPoint).first

    @tool.simulation.stop if @tool && @tool.simulation

    @tool = SimulationTool.new(path, arrow)
    model.select_tool(@tool)
  end

  def self.simulation
    @tool.simulation
  end

  # TT::Plugins::Bot.reload
  def self.reload( tt_lib = false )
    original_verbose = $VERBOSE
    $VERBOSE = nil
    x = Dir.glob(File.join(PATH, '**/*.{rb,rbs}') ).each { |file|
      load file
    }
    x.length
  ensure
    $VERBOSE = original_verbose
  end

end # module
