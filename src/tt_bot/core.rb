require 'tt_bot/simulation_tool'

module TT::Plugins::Bot

  unless file_loaded?(__FILE__)
    cmd = UI::Command.new('Initialize Simulation') {
      self.init_simulation
    }
    cmd.tooltip = 'Initialize Bot Simulation'
    cmd.small_icon = File.join(PATH, 'icons', 'iconmonstr-media-control-47.svg')
    cmd.large_icon = File.join(PATH, 'icons', 'iconmonstr-media-control-47.svg')
    cmd_init_simulation = cmd

    cmd = UI::Command.new('Start Simulation') {
      self.start_simulation
    }
    cmd.tooltip = 'Start Bot Simulation'
    cmd.small_icon = File.join(PATH, 'icons', 'iconmonstr-video-15.svg')
    cmd.large_icon = File.join(PATH, 'icons', 'iconmonstr-video-15.svg')
    cmd_start_simulation = cmd

    toolbar = UI.toolbar('Bot Simulation')
    toolbar.add_item(cmd_init_simulation)
    toolbar.add_item(cmd_start_simulation)

    menu = UI.menu('Plugins').add_submenu('Bot Simulation')
    menu.add_item(cmd_init_simulation)
    menu.add_item(cmd_start_simulation)

    file_loaded(__FILE__)
  end

  def self.init_simulation
    model = Sketchup.active_model
    path = model.entities.grep(Sketchup::Edge).first
    cpoints = model.entities.grep(Sketchup::ConstructionPoint)

    @tool.simulation.stop if @tool && @tool.simulation

    @tool = SimulationTool.new(path, cpoints)
    model.select_tool(@tool)
    nil
  end

  def self.start_simulation
    self.init_simulation if @simulation_tool.nil?
    @tool.simulation.start
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
