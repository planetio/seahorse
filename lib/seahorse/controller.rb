require_relative './param_validator'

module Seahorse
  module Controller
    extend ActiveSupport::Concern

    included do
      respond_to :json, :xml if respond_to?(:respond_to)

      rescue_from Exception, :with => :render_error

      self.responder = Seahorse::Responder

      wrap_parameters false if respond_to?(:wrap_parameters)

      before_filter do
        @params = params
        @params = operation.input.from_input(params, false)
        @params.update(operation.input.from_input(map_headers, false))

        begin
          input_rules = operation.to_hash['input']
          %w(action controller format).each {|v| params.delete(v) }
          validator = Seahorse::ParamValidator.new(input_rules)
          validator.validate!(params)
        rescue ArgumentError => error
          service_error(error, 'ValidationError')
        end

        @params = operation.input.from_input(@params)
        @params = params.permit(*operation.input.to_strong_params)

        true
      end
    end

    def output_model(model)
      operation.output.to_output(model)      
    end

    private

    def render_error(exception)
      service_error(exception, exception.class.name)
    end

    def params
      @params || super
    end

    def operation
      return @operation if @operation
      @operation = api_model.operation_from_action(action_name)
    end

    def api_model
      return @api_model if @api_model
      @api_model = ('Api::' + controller_name.singularize.camelcase).constantize
    end 

    def service_error(error, code = 'ServiceError', status = nil)
      status  ||= (error.respond_to?(:status) && error.status) || case code
      when "ValidationError"
        400
      when "ArgumentError"
        400
      else
        500
      end

      respond_with({ code: code, message: error.message }, error: status)
    end

    def map_headers
      return @map_headers if @map_headers
      @map_headers = {}
      return @map_headers unless operation.input.default_type == 'structure'
      operation.input.members.each do |name, member|
        if member.header
          hdr_name = member.header == true ? name : member.header
          hdr_name = "HTTP_" + hdr_name.upcase.gsub('-', '_')
          @map_headers[name] = request.headers[hdr_name]
        end
      end
      @map_headers
    end
  end
end
