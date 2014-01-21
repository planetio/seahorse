module Seahorse
  class Responder < ::ActionController::Responder
    def json_resource_errors
       {:errors => nice_errors(resource, {})}
    end

    def default_render
      if options[:error]
        render json: resource.to_json, status: options[:error]
      else
        render json: controller.output_model(resource)
      end
    rescue Exception => e
      controller.send(:render_error, e)
    end
    private

    # recursively generate nested error structure
    def nice_errors(object, errors)
      object.errors.each do |key|
        error_obj = object.send(key)
        if error_obj.kind_of?(Array)
          errors[key] = {}
          error_obj.each {|item| nice_errors(item, errors[key])}
        elsif error_obj.kind_of?(ActiveRecord::Base)
          errors[error_obj.id] = {}
          nice_errors(error_obj, errors[error_obj.id])
        else
          errors[key] = object.errors[key]
        end
      end
      return errors
    end
  end
end