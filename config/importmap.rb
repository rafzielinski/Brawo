pin "brawo_cms/application", to: "brawo_cms/application.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "sortablejs", to: "https://ga.jspm.io/npm:sortablejs@1.15.2/modular/sortable.core.esm.js"
pin "brawo_cms/coloris", to: "brawo_cms/coloris.js"

pin_all_from File.expand_path("../app/javascript/brawo_cms/controllers", __dir__), under: "brawo_cms/controllers"
