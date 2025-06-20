// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "trix"
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "@hotwired/stimulus-loading"

// Import Sortable for drag-and-drop functionality
import Sortable from "sortablejs"

// Import simplified auto-save functionality
import "simple_auto_save"

// Import UI modules
import "mobile_menu"
import "dark_mode"
import "toast_notifications"
import "form_validation"
import "loading_overlay"

// Import accessibility enhancements
// import "accessibility" // Temporarily disabled - causing UI issues

// Make Sortable available globally
window.Sortable = Sortable

// Trix configuration for enterprise WYSIWYG editing
document.addEventListener("trix-before-initialize", () => {
  // Customize Trix toolbar for journal editing
  Trix.config.blockAttributes.heading = {
    tagName: "h2",
    terminal: true,
    breakOnReturn: true,
    group: false
  }
  
  // Add custom formatting options
  Trix.config.blockAttributes.subheading = {
    tagName: "h3",
    terminal: true,
    breakOnReturn: true,
    group: false
  }
  
  // Enable accessibility features
  Trix.config.textAttributes.accessible = {
    tagName: "span",
    inheritable: true
  }
})

import "@rails/actiontext"
