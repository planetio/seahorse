module Seahorse
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :api_path, :access_token_parameter

    def initialize
      @api_path = 'app/models/api'
      @access_token_parameter = nil
    end
  end
end
