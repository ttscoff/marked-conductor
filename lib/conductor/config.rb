# frozen_string_literal: true

module Conductor
  # Configuration methods
  class Config
    attr_reader :config, :tracks

    def initialize
      config_file = File.expand_path('~/.config/conductor/tracks.yaml')

      create_config(config_file) unless File.exist?(config_file)

      @config ||= YAML.safe_load(IO.read(config_file))

      @tracks = @config['tracks'].symbolize_keys
    end
  end

  def create_config(config_file)
    config_dir = File.dirname(config_file)
    scripts_dir = File.dirname(File.join(config_file, 'scripts'))
    FileUtils.mkdir_p(config_dir) unless File.directory?(config_dir)
    FileUtils.mkdir_p(scripts_dir) unless File.directory?(scripts_dir)
    File.open(config_file, 'w') { |f| f.puts sample_config }
    puts "Sample config created at #{config_file}"

    Process.exit 0
  end

  def sample_config
    <<~EOCONFIG
      tracks:
        - condition: phase is pre
          tracks:
          - condition: tree contains .obsidian
            tracks:
            - condition: extension is md
              script: obsidian-md-filter
          - condition: extension is md
            command: rdiscount $file
        - condition: yaml includes comments
          script: blog-processor
        - condition: any
          command: echo 'NOCUSTOM'
    EOCONFIG
  end
end
