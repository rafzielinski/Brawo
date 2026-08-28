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

      permitted_fields, array_fields, repeater_field_names, blocks_field_names = field_permits
      repeater_data = extract_repeater_data(repeater_field_names)
      blocks_data = extract_blocks_data(blocks_field_names)
      field_attrs = scalar_field_attrs(permitted_fields, array_fields)
      all_field_attrs = field_attrs.merge(repeater_data).merge(blocks_data)

      base_attrs_from(@raw_hash).merge(fields: all_field_attrs.deep_stringify_keys)
    end

    private

    def base_attrs_from(hash)
      hash.slice(*@base_keys).stringify_keys
    end

    def all_custom_fields
      BrawoCms::ContentTypeTabs.all_fields(
        @type_config[:tabs] || [],
        header_fields: @type_config[:header_fields],
        fields: @type_config[:top_level_fields]
      )
    end

    def field_permits
      permitted_fields = []
      array_fields = {}
      repeater_field_names = []
      blocks_field_names = []

      all_custom_fields.each do |field|
        case field[:type]
        when :reference
          array_fields[field[:name]] = []
        when :repeater
          repeater_field_names << field[:name].to_sym
        when :blocks
          blocks_field_names << field[:name].to_sym
        else
          permitted_fields << field[:name].to_sym
        end
      end

      [permitted_fields, array_fields, repeater_field_names, blocks_field_names]
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

    def extract_blocks_data(blocks_field_names)
      blocks_field_names.each_with_object({}) do |blocks_name, blocks_data|
        blocks_param = @raw_hash[blocks_name] || @raw_hash[blocks_name.to_s]

        blocks_data[blocks_name.to_s] =
          if blocks_param.present? && blocks_param.is_a?(Hash)
            process_blocks_field(blocks_param)
          else
            []
          end
      end
    end

    def process_blocks_field(blocks_param)
      return [] unless blocks_param.is_a?(Hash)

      numeric_keys = blocks_param.keys.select { |k| k.to_s.match?(/\A\d+\z/) }

      numeric_keys.sort_by { |k| k.to_s.to_i }.filter_map do |index|
        block_data = blocks_param[index]
        next unless block_data.is_a?(Hash)

        block_data = block_data.respond_to?(:to_unsafe_h) ? block_data.to_unsafe_h : block_data.to_h
        block_type = block_data['type'] || block_data[:type]
        next if block_type.blank?

        type_config = BrawoCms.block_type(block_type)
        next unless type_config

        raw_data = block_data['data'] || block_data[:data] || {}
        processed_data = process_fields_hash(type_config[:fields], raw_data)

        { 'type' => block_type.to_s, 'data' => processed_data }
      end
    end

    def process_fields_hash(field_definitions, raw_hash)
      return {} unless raw_hash.is_a?(Hash)

      raw_hash = raw_hash.respond_to?(:to_unsafe_h) ? raw_hash.to_unsafe_h : raw_hash.to_h
      raw_hash = raw_hash.deep_symbolize_keys
      result = {}

      field_definitions.each do |field_def|
        field_name = field_def[:name].to_s
        field_type = field_def[:type]
        value = raw_hash[field_name.to_sym] || raw_hash[field_name]

        result[field_name] =
          case field_type
          when :repeater
            if value.is_a?(Hash)
              process_repeater_field(value, field_name, nil, field_def)
            else
              []
            end
          when :reference
            Array(value).compact
          else
            value
          end
      end

      result.stringify_keys
    end

    def process_repeater_field(repeater_param, repeater_name, parent_field_def = nil, field_def_override = nil)
      return [] unless repeater_param.is_a?(Hash)

      field_def = field_def_override || if parent_field_def
        parent_field_def[:sub_fields]&.find { |f| f[:name].to_s == repeater_name.to_s }
      else
        all_custom_fields.find { |f| f[:name].to_s == repeater_name.to_s }
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
