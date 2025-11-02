module Brawo
  class RouteConfiguration
    attr_accessor :archive_path, :single_path_pattern

    def initialize
      @archive_path = nil
      @single_path_pattern = nil
    end

    def archive(path)
      @archive_path = path
    end

    def single(pattern)
      @single_path_pattern = pattern
    end

    def single_path(content)
      return nil unless @single_path_pattern
      @single_path_pattern.gsub(':slug', content.slug)
    end
  end
end