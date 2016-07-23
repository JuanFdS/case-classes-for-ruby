class CaseClass
  def initialize(super_class, *class_parameters)
    @klass = Class.new(super_class) do
      attr_reader *class_parameters
      define_singleton_method(:class_parameters) do
        class_parameters
      end
      def class_parameters
        self.class.class_parameters
      end
      def initialize(values = {})
        raise ArgumentError unless values.keys.sort == class_parameters.sort
        values.each do |attr, value|
          instance_variable_set "@#{attr}", value
        end
        self.freeze
      end
      def equal?(obj)
        return false unless self.class == obj.class
        values == obj.values
      end
      def eql?(obj)
        equal?(obj)
      end
      def ==(obj)
        equal?(obj)
      end
      def values
        class_parameters.map{|parameter| instance_variable_get "@#{parameter}"}
      end
      def hash
        values.hash
      end
    end
  end
  def method_missing(sym, *args, &block)
    @klass.send(sym, *args, &block)
  end
  def respond_to?(sym)
    @klass.respond_to?(sym)
  end
  def respond_to_missing?(sym, include_private = false)
    @klass.send(:respond_to_missing?, sym, include_private)
  end
  def methods
    super + @klass.methods
  end
end