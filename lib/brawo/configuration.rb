module Brawo
  class Configuration
    attr_accessor :name, :slug, :icon, :description

    def initialize
      @name = nil
      @slug = nil
      @icon = nil
      @description = nil
    end
  end
end