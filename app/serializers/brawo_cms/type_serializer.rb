module BrawoCms
  class TypeSerializer
    def initialize(name, config)
      @name = name
      @config = config
    end

    def as_json
      {
        type: @name.to_s,
        label: @config[:label],
        fields: @config[:fields] || []
      }
    end
  end
end
