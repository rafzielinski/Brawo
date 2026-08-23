module BrawoCms
  class SlugGenerator
    Result = Struct.new(:slug, :adjusted, :conflict, :suggested_slug, keyword_init: true) do
      def conflict?
        conflict == true
      end
    end

    def self.generate(base, record_class:, exclude_id: nil, adjust: true)
      new(record_class: record_class, exclude_id: exclude_id, adjust: adjust).generate(base)
    end

    def initialize(record_class:, exclude_id: nil, adjust: true)
      @record_class = record_class
      @exclude_id = exclude_id
      @adjust = adjust
      @adjusted = false
    end

    def generate(base)
      slug = base.to_s.parameterize.presence
      return Result.new(slug: slug, adjusted: false, conflict: false) if slug.blank?

      if @adjust
        generate_adjusted(slug)
      else
        generate_preview(slug, base)
      end
    end

    private

    def generate_adjusted(slug)
      slug = resolve_reserved(slug) if root_type?
      slug = resolve_within_type(slug)
      slug = resolve_among_root_types(slug) if root_type?
      Result.new(slug: slug, adjusted: @adjusted, conflict: false)
    end

    def generate_preview(slug, base)
      if needs_adjustment?(slug)
        suggested = self.class.generate(base, record_class: @record_class, exclude_id: @exclude_id, adjust: true).slug
        Result.new(slug: slug, adjusted: false, conflict: true, suggested_slug: suggested)
      else
        Result.new(slug: slug, adjusted: false, conflict: false)
      end
    end

    def needs_adjustment?(slug)
      return true if root_type? && BrawoCms.reserved_slugs.include?(slug)
      return true if taken_within_type?(slug)
      return true if root_type? && taken_by_other_root_type?(slug)

      false
    end

    def root_type?
      BrawoCms.root_content_type?(content_type_name)
    end

    def content_type_name
      @record_class.name.demodulize.underscore
    end

    def resolve_reserved(slug)
      return slug unless BrawoCms.reserved_slugs.include?(slug)

      @adjusted = true
      resolve_within_type("#{slug}-2")
    end

    def resolve_within_type(slug)
      candidate = slug
      suffix = 2

      while taken_within_type?(candidate)
        @adjusted = true
        candidate = "#{slug}-#{suffix}"
        suffix += 1
      end

      candidate
    end

    def resolve_among_root_types(slug)
      candidate = slug
      suffix = 2

      while taken_by_other_root_type?(candidate)
        @adjusted = true
        candidate = "#{slug}-#{suffix}"
        suffix += 1
      end

      candidate
    end

    def taken_within_type?(slug)
      scope = @record_class.unscoped.where(type: @record_class.name, slug: slug)
      scope = scope.where.not(id: @exclude_id) if @exclude_id
      scope.exists?
    end

    def taken_by_other_root_type?(slug)
      BrawoCms.root_content_types.any? do |type_name|
        next false if type_name.to_sym == content_type_name.to_sym

        config = BrawoCms.content_types[type_name.to_sym]
        next false unless config

        config[:class].unscoped.where(type: config[:class].name, slug: slug).exists?
      end
    end
  end
end
