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
        fields: @config[:fields] || [],
        header_fields: @config[:header_fields] || []
      }
    end
  end
end
