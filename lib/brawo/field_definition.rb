module Brawo
  class FieldDefinition
    attr_accessor :name, :type, :options

    def initialize(name, type, options = {})
      @name = name
      @type = type
      @options = options
    end

    def required?
      @options[:required] == true
    end

    def default
      @options[:default]
    end

    def choices
      @options[:choices]
    end

    def unique?
      @options[:unique] == true
    end
  end
end