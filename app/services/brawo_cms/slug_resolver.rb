module BrawoCms
  class SlugResolver
    def self.find(slug)
      BrawoCms.root_content_types.each do |type_name|
        config = BrawoCms.content_types[type_name.to_sym]
        next unless config

        record = config[:class].published.find_by(slug: slug)
        return record if record
      end

      nil
    end
  end
end
