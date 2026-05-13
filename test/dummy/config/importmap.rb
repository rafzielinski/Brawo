# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Dummy lives at test/dummy; repo-root engine JS is ../../../app/javascript/...
pin_all_from File.expand_path("../../../app/javascript/brawo_cms/controllers", __dir__), under: "brawo_cms/controllers"
