# frozen_string_literal: true

module Conductor
  class Config
    attr_reader :config, :tracks

    def initialize
      config_file = File.expand_path('~/.config/conductor/tracks.yaml')

      raise 'No config file at ~/.config/conductor/tracks.yaml' unless File.exist?(config_file)

      @config ||= YAML.safe_load(IO.read(config_file))

      @tracks = @config['tracks'].symbolize_keys
    end
  end
end
