# frozen_string_literal: true

module Conductor
  module Env
    def self.env
      @env ||= if ENV['CONDUCTOR_TEST'] == 'true'
                 load_test_env
               else
                 @env ||= {
                   home: ENV['HOME'],
                   css_path: ENV['MARKED_CSS_PATH'],
                   ext: ENV['MARKED_EXT'],
                   includes: ENV['MARKED_INCLUDES'],
                   origin: ENV['MARKED_ORIGIN'],
                   filepath: ENV['MARKED_PATH'],
                   phase: ENV['MARKED_PHASE'],
                   outline: ENV['OUTLINE'],
                   path: ENV['PATH']
                 }
               end

      @env
    end

    def self.load_test_env
      @env = {
        home: '/Users/ttscoff',
        css_path: '/Applications/Marked 2.app/Contents/Resources/swiss.css',
        ext: 'md',
        includes: [],
        origin: '/Users/ttscoff/Dropbox/Work/Oracle/oci-ai-industry-dbsolutions/text-analysis-and-translation/',
        filepath: '/Users/ttscoff/Dropbox/Work/Oracle/oci-ai-industry-dbsolutions/text-analysis-and-translation/README.md',
        phase: 'PREPROCESS',
        outline: 'NONE',
        path: '/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/Users/ttscoff/Dropbox/Work/Oracle/oci-ai-industry-dbsolutions/text-analysis-and-translation/'
      }
    end

    def self.to_s
      out_h = {
        'HOME' => @env[:home],
        'MARKED_CSS_PATH' => @env[:css_path],
        'MARKED_EXT' => @env[:ext],
        'MARKED_ORIGIN' => @env[:origin],
        'MARKED_INCLUDES' => @env[:includes],
        'MARKED_PATH' => @env[:filepath],
        'MARKED_PHASE' => @env[:phase],
        'OUTLINE' => @env[:outline],
        'PATH'=> @env[:path]
      }
      out_h.map { |k, v| %(#{k}="#{v}") }.join(' ')
    end
  end
end
