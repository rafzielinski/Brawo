module BrawoCms
  module ContentTypeTabs
    CONTENT_KEY = :content
    SEO_KEY = :seo
    RESERVED_KEYS = [SEO_KEY].freeze

    DEFAULT_SEO_FIELDS = [
      { name: :meta_title, type: :string, label: "Meta title" },
      { name: :meta_description, type: :textarea, label: "Meta description" },
      { name: :og_image, type: :media, accept: "image/*", label: "Social image" },
      { name: :canonical_url, type: :url, label: "Canonical URL" },
      { name: :noindex, type: :boolean, label: "Noindex" }
    ].freeze

    module_function

    def build(options)
      tab_entries = Array(options[:tabs])
      return [] if tab_entries.blank?

      tabs = parse_tab_entries(tab_entries)
      validate_unique_keys!(tabs)
      tabs
    end

    def show_tabs?(options)
      options[:tabs].present?
    end

    def all_fields(tabs, header_fields: [], fields: [])
      Array(fields) + tabs.flat_map { |tab| tab[:fields] || [] } + Array(header_fields)
    end

    def content_tab_fields(tabs)
      tabs.find { |tab| tab[:key] == CONTENT_KEY }&.dig(:fields) || []
    end

    def seo_enabled?(tabs)
      tabs.any? { |tab| tab[:key] == SEO_KEY }
    end

    def parse_tab_entries(entries)
      entries.map { |entry| parse_tab_entry(entry) }
    end

    def parse_tab_entry(entry)
      if entry[:seo]
        seo_tab(entry)
      else
        custom_tab(entry)
      end
    end

    def seo_tab(entry)
      fields = entry[:fields].presence || DEFAULT_SEO_FIELDS

      {
        key: SEO_KEY,
        label: entry[:label],
        fields: fields
      }
    end

    def custom_tab(entry)
      key = entry[:key].to_sym
      raise ArgumentError, "Tab key :#{key} is reserved" if RESERVED_KEYS.include?(key)
      raise ArgumentError, "Tab requires a :key" if entry[:key].blank?

      {
        key: key,
        label: entry[:label],
        fields: entry[:fields] || []
      }
    end

    def validate_unique_keys!(tabs)
      keys = tabs.map { |tab| tab[:key] }
      duplicates = keys.group_by(&:itself).select { |_, group| group.size > 1 }.keys
      return if duplicates.empty?

      raise ArgumentError, "Duplicate tab keys: #{duplicates.map { |k| ":#{k}" }.join(', ')}"
    end
  end
end
