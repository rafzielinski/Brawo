# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    ActiveStorage::Current.url_options = { host: "www.example.com" }
  end
end

module ActiveStorageTestHelpers
  module_function

  def uploaded_file(name: "hero.png", content_type: "image/png", body: "image-bytes")
    file = Tempfile.new([File.basename(name, ".*"), File.extname(name)])
    file.binmode
    file.write(body)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, content_type, original_filename: name)
  end
end
