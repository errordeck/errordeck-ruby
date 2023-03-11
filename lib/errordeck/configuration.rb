module Errordeck
  class Configuration
    attr_accessor :token, :project_id, :environment, :release, :dist, :level, :server_name

    def initialize
      @token = nil
      @project_id = nil
      @environment = "development"
      @release = "0.0.0"
      @dist = "0.0.0"
      @level = "error"
      @server_name = nil
    end
  end

  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
