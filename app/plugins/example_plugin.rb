# Example Plugin
class ExamplePlugin
  def self.name
    "Example Plugin"
  end

  def self.description
    "A basic example plugin for demonstration"
  end

  def self.version
    "1.0.0"
  end

  def self.activate
    # Plugin activation logic
    Rails.logger.info "#{self.name} activated"
  end

  def self.deactivate
    # Plugin deactivation logic
    Rails.logger.info "#{self.name} deactivated"
  end

  def self.content_filter(content)
    # Example content filter
    content.upcase
  end
end