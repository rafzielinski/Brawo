# frozen_string_literal: true

# Namespaced slugs for API request specs so records never collide with
# test/dummy/db/seeds.rb or other fixtures.
module ApiTestData
  SLUG_PREFIX = "rspec-api-v1"

  module_function

  def slug(key)
    "#{SLUG_PREFIX}-#{key}"
  end
end
