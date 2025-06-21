# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "accessibility"
pin "simple_auto_save"
pin "mobile_menu"
pin "dark_mode"
pin "toast_notifications"
pin "form_validation"
pin "loading_overlay"
pin "trix" # @2.1.15
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "sortablejs", to: "https://cdn.jsdelivr.net/npm/sortablejs@1.15.3/modular/sortable.esm.js"
pin "@rails/actiontext", to: "actiontext.esm.js"
