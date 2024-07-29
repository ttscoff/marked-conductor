# frozen_string_literal: true

module Conductor
  # Configuration methods
  class Config
    # Configuration
    attr_reader :config
    # Tracks element
    attr_reader :tracks
    # Config file path
    attr_writer :config_file

    ##
    ## Instantiate a configuration
    ##
    ## @return     [Config] Config object
    ##
    def initialize
      @config_file = File.expand_path("~/.config/conductor/tracks.yaml")
    end

    def configure
      res = create_config(@config_file)
      return false unless res

      @config ||= YAML.safe_load(IO.read(@config_file))

      @tracks = @config["tracks"].symbolize_keys

      return true
    end

    private

    ##
    ## Generate a blank config and directory structure
    ##
    ## @param      config_file  [String] The configuration file to create
    ##
    def create_config(config_file = nil)
      config_file ||= @config_file
      config_dir = File.dirname(config_file)
      scripts_dir = File.dirname(File.join(config_dir, "scripts"))
      styles_dir = File.dirname(File.join(config_dir, "css"))
      js_dir = File.dirname(File.join(config_dir, "js"))
      FileUtils.mkdir_p(config_dir) unless File.directory?(config_dir)
      FileUtils.mkdir_p(scripts_dir) unless File.directory?(scripts_dir)
      FileUtils.mkdir_p(styles_dir) unless File.directory?(styles_dir)
      FileUtils.mkdir_p(js_dir) unless File.directory?(js_dir)
      unless File.exist?(config_file)
        File.open(config_file, "w") { |f| f.puts sample_config }
        puts "Sample config created at #{config_file}"
        return false
      end

      return true
    end

    ##
    ## Content for sample configuration
    ##
    ## @return     [String] sample config
    ##
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
end
