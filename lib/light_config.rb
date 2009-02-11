module LightConfig
  class Configuration
    def initialize(&block)
      @properties = {}
      ::LightConfig::Builder.new(self).instance_eval(&block)
      singleton = (class <<self; self; end)
      @properties.keys.each do |property|
        singleton.module_eval do
          define_method property do
            @properties[property]
          end

          define_method "#{property}=" do |value|
            @properties[property] = value
          end
        end
      end
    end
  end

  class Builder
    def initialize(configuration)
      @configuration = configuration
    end

    def method_missing(method, *args, &block)
      unless args.length < 2
        raise ArgumentError("wrong number of arguments(#{args.length} for 1)")
      end
      value = if block then ::LightConfig::Configuration.new(&block)
              else args.first
              end
      @configuration.instance_variable_get(:@properties)[method] = value
    end
  end
end

class <<LightConfig
  def build(&block)
    LightConfig::Configuration.new(&block)
  end
end
