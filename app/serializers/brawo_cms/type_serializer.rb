module BrawoCms
  class TypeSerializer
    def initialize(name, config)
      @name = name
      @config = config
    end

    def as_json
      payload = {
        type: @name.to_s,
        label: @config[:label],
        fields: @config[:fields] || [],
        header_fields: @config[:header_fields] || []
      }

      if @config[:tabs].present?
        payload[:tabs] = @config[:tabs].map do |tab|
          {
            key: tab[:key].to_s,
            label: tab[:label],
            fields: tab[:fields] || []
          }
        end
        payload[:seo] = @config[:seo]
      end

      payload
    end
  end
end
