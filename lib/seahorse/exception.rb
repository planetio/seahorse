# Raise application level exceptions that send back particular status codes
# Eg, Unauthorized: 401
# class YourApp::Unauthorized < Seahorse::Exception
#   status 401
#   # overload name so the response code returned is clean
#   def self.name
#     "Unauthorized"
#   end
# end
module Seahorse
  class Exception < Exception
    cattr_accessor :status_code

    # setter and getter in one!
    def self.status(*code)
      self.status_code = code.first if code.first.present?
      self.status_code
    end

    def initialize(message)
      @status = self.class.status
      super
    end

    def status
      self.class.status
    end

  end

end