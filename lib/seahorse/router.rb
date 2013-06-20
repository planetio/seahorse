module Seahorse
  class Router
    def initialize(model, options = {})
      @model = model
      @exclude_rpc_routes = options[:exclude_rpc_routes]
    end

    def add_routes(router)
      operations = @model.operations
      controller = @model.model_name.pluralize
      operations.each do |name, operation|
        unless @exclude_rpc_routes
          router.match "/#{name}" => "#{controller}##{operation.action}",
            defaults: { format: 'json' },
            via: [:get, operation.verb.to_sym].uniq
        end
        router.match operation.url => "#{controller}##{operation.action}",
          defaults: { format: 'json' },
          via: operation.verb
      end
    end
  end
end
