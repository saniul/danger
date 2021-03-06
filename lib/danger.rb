require "danger/version"
require "danger/dangerfile"
require "danger/environment_manager"

require 'claide'
require 'colored'

module Danger
  class DangerRunner < CLAide::Command
    self.description = 'Run the Dangerfile.'
    self.command = 'danger'

    def initialize(argv)
      @dangerfile_path = "Dangerfile" if File.exist? "Dangerfile"
      super
    end

    def validate!
      super
      unless @dangerfile_path
        help! "Could not find a Dangerfile."
      end
    end

    def run
      dm = Dangerfile.new
      dm.env = EnvironmentManager.new(ENV)
      dm.env.fill_environment_vars
      dm.update_from_env
      dm.env.git.diff_for_folder(".")
      dm.parse Pathname.new(@dangerfile_path)

      if dm.failures
        puts "Uh Oh failed"
        exit(1)
      else
        puts "The Danger has passed. Phew."
      end
    end
  end

  class DangerInit < DangerRunner
    self.description = 'Creates a Dangerfile.'
    self.command = 'init'

    def initialize(argv)
      @dangerfile_path = "Dangerfile" if File.exist? "Dangerfile"
      super
    end

    def validate!
      if @dangerfile_path
        help! "Found an existing Dangerfile."
      end
    end

    def run
      example_content = 'warn("PR is classed as Work in Progress") if pr_title.include? "[WIP]"'
      File.write("Dangerfile", example_content)
      puts "Successfully created 'Dangerfile'"
    end
  end
end
