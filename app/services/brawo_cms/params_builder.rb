module BrawoCms
  class ParamsBuilder
    def self.from_request(type_config:, base_keys:, params:, wrap_key:)
      raw = params[wrap_key]
      return {} if raw.blank?

      from_hash(
        type_config: type_config,
        base_keys: base_keys,
        raw_hash: raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
      )
    end

    def self.from_hash(type_config:, base_keys:, raw_hash:)
      new(type_config, base_keys, raw_hash.deep_symbolize_keys).build
    end

    def initialize(type_config, base_keys, raw_hash)
      @type_config = type_config
      @base_keys = base_keys.map(&:to_sym)
      @raw_hash = raw_hash
    end

    def build
      if @raw_hash.key?(:fields) && @raw_hash[:fields].is_a?(Hash)
        return base_attrs_from(@raw_hash).merge(fields: @raw_hash[:fields].deep_stringify_keys)
      end

      permitted_fields, array_fields, repeater_field_names = field_permits
      repeater_data = extract_repeater_data(repeater_field_names)
      field_attrs = scalar_field_attrs(permitted_fields, array_fields)
      all_field_attrs = field_attrs.merge(repeater_data)

      base_attrs_from(@raw_hash).merge(fields: all_field_attrs.deep_stringify_keys)
    end

    private

    def base_attrs_from(hash)
      hash.slice(*@base_keys).stringify_keys
    end

    def field_permits
      permitted_fields = []
      array_fields = {}
      repeater_field_names = []

      (@type_config[:fields] || []).each do |field|
        case field[:type]
        when :reference
          array_fields[field[:name]] = []
        when :repeater
          repeater_field_names << field[:name].to_sym
        else
          permitted_fields << field[:name].to_sym
        end
      end

      [permitted_fields, array_fields, repeater_field_names]
    end

    def extract_repeater_data(repeater_field_names)
      repeater_field_names.each_with_object({}) do |repeater_name, repeater_data|
        repeater_param = @raw_hash[repeater_name] || @raw_hash[repeater_name.to_s]

        repeater_data[repeater_name.to_s] =
          if repeater_param.present? && repeater_param.is_a?(Hash)
            process_repeater_field(repeater_param, repeater_name)
          else
            []
          end
      end
    end

    def scalar_field_attrs(permitted_fields, array_fields)
      attrs = {}

      permitted_fields.each do |name|
        attrs[name.to_s] = @raw_hash[name] if @raw_hash.key?(name)
      end

      array_fields.each_key do |name|
        attrs[name.to_s] = @raw_hash[name] if @raw_hash.key?(name)
      end

      attrs
    end

    def process_repeater_field(repeater_param, repeater_name, parent_field_def = nil)
      return [] unless repeater_param.is_a?(Hash)

      field_def = if parent_field_def
        parent_field_def[:sub_fields]&.find { |f| f[:name].to_s == repeater_name.to_s }
      else
        @type_config[:fields].find { |f| f[:name].to_s == repeater_name.to_s }
      end

      return [] unless field_def

      sub_fields = field_def[:sub_fields] || []

      numeric_keys = repeater_param.keys.select { |k| k.to_s.match?(/\A\d+\z/) }

      numeric_keys.sort_by { |k| k.to_s.to_i }.filter_map do |index|
        row_data = repeater_param[index]
        next unless row_data.is_a?(Hash)

        row_data = row_data.respond_to?(:to_unsafe_h) ? row_data.to_unsafe_h : row_data.to_h
        processed_row = {}

        sub_fields.each do |sub_field_def|
          sub_field_name = sub_field_def[:name].to_s
          sub_field_type = sub_field_def[:type]
          value = row_data[sub_field_name] || row_data[sub_field_name.to_sym]

          processed_row[sub_field_name] =
            if sub_field_type == :repeater && value.is_a?(Hash)
              process_repeater_field(value, sub_field_name, field_def)
            else
              value
            end
        end

        processed_row.present? ? processed_row.stringify_keys : nil
      end
    end
  end
end
