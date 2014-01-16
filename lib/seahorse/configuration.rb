module Seahorse
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :api_path

    def initialize
      @api_path = 'app/models/api'
    end
  end
end
