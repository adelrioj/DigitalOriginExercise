module Banking
  class Bank

    attr_reader :name

    def initialize(name)
      @name = name
      validate!
    end

    def validate!
      raise ArgumentError, 'Empty name' if @name.nil?
      raise ArgumentError, 'Name must be a symbol' unless @name.is_a?(Symbol)
    end
  end
end
