class Class
  def case_class(with: {})
    extend CaseClass::ClassBehaviour
    include CaseClass::InstanceBehaviour
    self.class_parameters = with
    self
  end
end

module CaseClass
  module ClassBehaviour
    attr_reader :class_parameters

    def class_parameters=(class_parameters)
      @class_parameters = class_parameters
      define_case_class_instance_getters
      define_case_class_instantiation_method
    end

    private

    def define_case_class_instance_getters
      @class_parameters.each do |parameter|
        define_method(parameter) { instance_variable_get "@#{parameter}" }
      end
    end

    def define_case_class_instantiation_method
      this_class = self
      class_name = self.name
      Kernel.instance_eval do
        define_method(class_name) { |*values, **values_as_hash| this_class.new(*values, **values_as_hash) }
      end
    end
  end

  module InstanceBehaviour
    def initialize(*values_as_varargs, **values_as_hash)
      initializing_parameters = initializing_parameters(*values_as_varargs, **values_as_hash)

      initializing_parameters.each { |attr, value| instance_variable_set "@#{attr}", value }

      self.freeze
    end

    def equal?(obj)
      [self.class, self.values] == [obj.class, obj.values]
    end

    def eql?(obj)
      equal?(obj)
    end

    def ==(obj)
      equal?(obj)
    end

    def values
      class_parameters.map { |parameter| send parameter }
    end

    def hash
      [self.class, values].hash
    end

    def copy(new_values = {})
      instantiating_values = parameters_with_values.to_h.merge(new_values)

      self.class.new(instantiating_values)
    end

    def to_s
      class_name = self.class.name

      show_pair_parameter_value = -> (parameter, value) { "#{parameter}: #{value}"}

      parameters_and_values = parameters_with_values.map(&show_pair_parameter_value).join(', ')

      "#{class_name}(#{parameters_and_values})"
    end

    def inspect
      to_s
    end

    private

    def class_parameters
      self.class.class_parameters
    end

    def parameters_with_values
      class_parameters.zip(values)
    end

    def initializing_parameters(*values_as_varargs, **values_as_hash)
      values_as_varargs.empty? ? initializing_parameters_as_hash(**values_as_hash)
                               : initializing_parameters_as_varargs(*values_as_varargs)
    end

    def initializing_parameters_as_varargs(*values_as_varargs)
      raise ArgumentError unless values_as_varargs.size == class_parameters.size
      class_parameters.zip(values_as_varargs)
    end

    def initializing_parameters_as_hash(**values_as_hash)
      raise ArgumentError unless values_as_hash.keys.sort == class_parameters.sort
      values_as_hash
    end
  end
end