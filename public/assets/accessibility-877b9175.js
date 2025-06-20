// WCAG 2.1 AA Accessibility Enhancement Module
// Implements comprehensive accessibility features for enterprise compliance

class AccessibilityEnhancer {
  constructor() {
    this.preferences = this.loadAccessibilityPreferences();
    this.announcements = [];
    this.initializeAccessibilityFeatures();
  }

  initializeAccessibilityFeatures() {
    this.setupAriaLiveRegion();
    this.enhanceKeyboardNavigation();
    this.setupFocusManagement();
    this.addSkipLinks();
    this.enhanceFormAccessibility();
    this.setupColorContrastDetection();
    this.implementScreenReaderOptimizations();
    this.addAccessibilityToolbar();
    this.monitorDynamicContent();
  }

  // ARIA Live Region for screen reader announcements
  setupAriaLiveRegion() {
    if (!document.getElementById('aria-live-region')) {
      const liveRegion = document.createElement('div');
      liveRegion.id = 'aria-live-region';
      liveRegion.setAttribute('aria-live', 'polite');
      liveRegion.setAttribute('aria-atomic', 'true');
      liveRegion.style.cssText = `
        position: absolute;
        left: -10000px;
        width: 1px;
        height: 1px;
        overflow: hidden;
      `;
      document.body.appendChild(liveRegion);
    }
  }

  announce(message, priority = 'polite') {
    const liveRegion = document.getElementById('aria-live-region');
    if (liveRegion) {
      liveRegion.setAttribute('aria-live', priority);
      liveRegion.textContent = '';
      setTimeout(() => {
        liveRegion.textContent = message;
      }, 100);
    }
  }

  // Enhanced keyboard navigation
  enhanceKeyboardNavigation() {
    // Skip to main content
    document.addEventListener('keydown', (event) => {
      if (event.altKey && event.key === 'm') {
        const main = document.querySelector('main, #main-content, .main-content');
        if (main) {
          main.focus();
          main.scrollIntoView();
          this.announce('Jumped to main content');
        }
      }
    });

    // Escape key handling for modals and dialogs
    document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        const activeModal = document.querySelector('.modal.active, [role="dialog"][aria-hidden="false"]');
        if (activeModal) {
          this.closeModal(activeModal);
        }
      }
    });

    // Arrow key navigation for lists and grids
    this.setupArrowKeyNavigation();
  }

  setupArrowKeyNavigation() {
    const navigableContainers = document.querySelectorAll('[role="listbox"], [role="grid"], .keyboard-navigable');
    
    navigableContainers.forEach(container => {
      container.addEventListener('keydown', (event) => {
        const items = container.querySelectorAll('[role="option"], [role="gridcell"], .nav-item');
        const currentIndex = Array.from(items).indexOf(document.activeElement);
        
        let newIndex = currentIndex;
        
        switch (event.key) {
          case 'ArrowDown':
            newIndex = Math.min(currentIndex + 1, items.length - 1);
            break;
          case 'ArrowUp':
            newIndex = Math.max(currentIndex - 1, 0);
            break;
          case 'Home':
            newIndex = 0;
            break;
          case 'End':
            newIndex = items.length - 1;
            break;
          default:
            return;
        }
        
        event.preventDefault();
        items[newIndex]?.focus();
      });
    });
  }

  // Focus management for SPA-like behavior
  setupFocusManagement() {
    // Focus management for Turbo navigation
    document.addEventListener('turbo:load', () => {
      this.manageFocusAfterNavigation();
    });

    // Trap focus in modals
    this.setupFocusTrapping();
  }

  manageFocusAfterNavigation() {
    // Focus on main heading or main content area
    const mainHeading = document.querySelector('h1');
    const mainContent = document.querySelector('main, #main-content');
    
    if (mainHeading) {
      mainHeading.focus();
      mainHeading.scrollIntoView();
    } else if (mainContent) {
      mainContent.focus();
      mainContent.scrollIntoView();
    }
    
    this.announce('Page loaded');
  }

  setupFocusTrapping() {
    document.addEventListener('focusin', (event) => {
      const activeModal = document.querySelector('.modal.active, [role="dialog"][aria-hidden="false"]');
      if (activeModal && !activeModal.contains(event.target)) {
        const firstFocusable = this.findFocusableElements(activeModal)[0];
        if (firstFocusable) {
          firstFocusable.focus();
        }
      }
    });
  }

  findFocusableElements(container) {
    const focusableSelectors = [
      'a[href]',
      'button:not([disabled])',
      'input:not([disabled])',
      'select:not([disabled])',
      'textarea:not([disabled])',
      '[tabindex]:not([tabindex="-1"])',
      '[contenteditable="true"]'
    ];
    
    return container.querySelectorAll(focusableSelectors.join(', '));
  }

  // Skip links for better navigation
  addSkipLinks() {
    if (!document.querySelector('.skip-links')) {
      const skipLinks = document.createElement('div');
      skipLinks.className = 'skip-links';
      skipLinks.innerHTML = `
        <a href="#main-content" class="skip-link">Skip to main content</a>
        <a href="#navigation" class="skip-link">Skip to navigation</a>
        <a href="#footer" class="skip-link">Skip to footer</a>
      `;
      
      skipLinks.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        z-index: 9999;
      `;
      
      document.body.insertBefore(skipLinks, document.body.firstChild);
      
      // Style skip links
      const style = document.createElement('style');
      style.textContent = `
        .skip-link {
          position: absolute;
          top: -40px;
          left: 6px;
          background: #000;
          color: #fff;
          padding: 8px;
          text-decoration: none;
          border-radius: 0 0 4px 4px;
          font-weight: bold;
          z-index: 100;
        }
        .skip-link:focus {
          top: 0;
        }
      `;
      document.head.appendChild(style);
    }
  }

  // Form accessibility enhancements
  enhanceFormAccessibility() {
    // Add proper labels and descriptions
    const forms = document.querySelectorAll('form');
    forms.forEach(form => this.enhanceFormElements(form));

    // Real-time validation feedback
    this.setupAccessibleValidation();
  }

  enhanceFormElements(form) {
    // Associate labels with inputs
    const inputs = form.querySelectorAll('input, select, textarea');
    inputs.forEach(input => {
      if (!input.getAttribute('aria-label') && !input.getAttribute('aria-labelledby')) {
        const label = form.querySelector(`label[for="${input.id}"]`);
        if (!label && input.id) {
          // Create label if missing
          const labelText = input.getAttribute('placeholder') || input.name || 'Input field';
          const newLabel = document.createElement('label');
          newLabel.setAttribute('for', input.id);
          newLabel.textContent = labelText;
          newLabel.className = 'sr-only'; // Screen reader only
          input.parentNode.insertBefore(newLabel, input);
        }
      }

      // Add required indicators
      if (input.required) {
        input.setAttribute('aria-required', 'true');
        const requiredIndicator = input.parentNode.querySelector('.required-indicator');
        if (!requiredIndicator) {
          const indicator = document.createElement('span');
          indicator.className = 'required-indicator';
          indicator.textContent = ' *';
          indicator.setAttribute('aria-label', 'required');
          input.parentNode.appendChild(indicator);
        }
      }

      // Add error containers
      if (!input.getAttribute('aria-describedby')) {
        const errorId = `${input.id}-error`;
        const errorContainer = document.createElement('div');
        errorContainer.id = errorId;
        errorContainer.className = 'error-message';
        errorContainer.setAttribute('aria-live', 'polite');
        input.setAttribute('aria-describedby', errorId);
        input.parentNode.appendChild(errorContainer);
      }
    });
  }

  setupAccessibleValidation() {
    document.addEventListener('invalid', (event) => {
      const input = event.target;
      const errorContainer = document.getElementById(input.getAttribute('aria-describedby'));
      
      if (errorContainer) {
        errorContainer.textContent = input.validationMessage;
        input.setAttribute('aria-invalid', 'true');
        this.announce(`Error in ${input.name || 'form field'}: ${input.validationMessage}`, 'assertive');
      }
    });

    document.addEventListener('input', (event) => {
      const input = event.target;
      if (input.checkValidity()) {
        const errorContainer = document.getElementById(input.getAttribute('aria-describedby'));
        if (errorContainer) {
          errorContainer.textContent = '';
          input.removeAttribute('aria-invalid');
        }
      }
    });
  }

  // Color contrast detection and enhancement
  setupColorContrastDetection() {
    if (this.preferences.highContrast) {
      document.body.classList.add('high-contrast');
    }

    // Add contrast adjustment controls
    this.addContrastControls();
  }

  addContrastControls() {
    const contrastButton = document.createElement('button');
    contrastButton.textContent = 'Toggle High Contrast';
    contrastButton.className = 'accessibility-control contrast-toggle';
    contrastButton.setAttribute('aria-pressed', this.preferences.highContrast);
    
    contrastButton.addEventListener('click', () => {
      this.preferences.highContrast = !this.preferences.highContrast;
      document.body.classList.toggle('high-contrast', this.preferences.highContrast);
      contrastButton.setAttribute('aria-pressed', this.preferences.highContrast);
      this.saveAccessibilityPreferences();
      this.announce(`High contrast ${this.preferences.highContrast ? 'enabled' : 'disabled'}`);
    });

    return contrastButton;
  }

  // Screen reader optimizations
  implementScreenReaderOptimizations() {
    // Add landmarks
    this.addLandmarks();
    
    // Enhance table accessibility
    this.enhanceTableAccessibility();
    
    // Add status announcements for dynamic content
    this.setupStatusAnnouncements();
  }

  addLandmarks() {
    // Add main landmark if missing
    if (!document.querySelector('main, [role="main"]')) {
      const mainContent = document.querySelector('.main-content, #content, .content');
      if (mainContent && !mainContent.getAttribute('role')) {
        mainContent.setAttribute('role', 'main');
      }
    }

    // Add navigation landmarks
    const navElements = document.querySelectorAll('nav');
    navElements.forEach((nav, index) => {
      if (!nav.getAttribute('aria-label') && !nav.getAttribute('aria-labelledby')) {
        nav.setAttribute('aria-label', `Navigation ${index + 1}`);
      }
    });
  }

  enhanceTableAccessibility() {
    const tables = document.querySelectorAll('table');
    tables.forEach(table => {
      // Add table caption if missing
      if (!table.querySelector('caption') && !table.getAttribute('aria-label')) {
        const caption = document.createElement('caption');
        caption.textContent = 'Data table';
        caption.className = 'sr-only';
        table.insertBefore(caption, table.firstChild);
      }

      // Associate headers with cells
      const headers = table.querySelectorAll('th');
      headers.forEach((header, index) => {
        if (!header.id) {
          header.id = `header-${Date.now()}-${index}`;
        }
        header.setAttribute('scope', header.parentNode.tagName === 'THEAD' ? 'col' : 'row');
      });

      const cells = table.querySelectorAll('td');
      cells.forEach(cell => {
        if (!cell.getAttribute('headers')) {
          const headerIds = [];
          const cellIndex = Array.from(cell.parentNode.children).indexOf(cell);
          const headerRow = table.querySelector('thead tr, tr:first-child');
          if (headerRow) {
            const correspondingHeader = headerRow.children[cellIndex];
            if (correspondingHeader && correspondingHeader.id) {
              headerIds.push(correspondingHeader.id);
            }
          }
          if (headerIds.length > 0) {
            cell.setAttribute('headers', headerIds.join(' '));
          }
        }
      });
    });
  }

  setupStatusAnnouncements() {
    // Auto-save status announcements
    document.addEventListener('auto-save-complete', () => {
      this.announce('Changes saved automatically');
    });

    // Form submission announcements
    document.addEventListener('submit', () => {
      this.announce('Form submitted, please wait');
    });

    // Loading state announcements
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'attributes' && mutation.attributeName === 'aria-busy') {
          const element = mutation.target;
          if (element.getAttribute('aria-busy') === 'true') {
            this.announce('Loading content, please wait');
          }
        }
      });
    });

    observer.observe(document.body, {
      attributes: true,
      subtree: true,
      attributeFilter: ['aria-busy']
    });
  }

  // Accessibility toolbar
  addAccessibilityToolbar() {
    const toolbar = document.createElement('div');
    toolbar.className = 'accessibility-toolbar';
    toolbar.setAttribute('role', 'toolbar');
    toolbar.setAttribute('aria-label', 'Accessibility options');
    
    const controls = [
      this.addContrastControls(),
      this.createFontSizeControls(),
      this.createMotionControls()
    ];

    controls.forEach(control => toolbar.appendChild(control));

    // Position toolbar
    toolbar.style.cssText = `
      position: fixed;
      top: 50px;
      right: 10px;
      background: #fff;
      border: 2px solid #000;
      padding: 10px;
      z-index: 1000;
      display: none;
      flex-direction: column;
      gap: 5px;
    `;

    // Toggle button
    const toggleButton = document.createElement('button');
    toggleButton.textContent = '⚙️ Accessibility';
    toggleButton.className = 'accessibility-toggle';
    toggleButton.setAttribute('aria-expanded', 'false');
    toggleButton.style.cssText = `
      position: fixed;
      top: 10px;
      right: 10px;
      z-index: 1001;
      padding: 10px;
      background: #000;
      color: #fff;
      border: none;
      border-radius: 4px;
    `;

    toggleButton.addEventListener('click', () => {
      const isVisible = toolbar.style.display === 'flex';
      toolbar.style.display = isVisible ? 'none' : 'flex';
      toggleButton.setAttribute('aria-expanded', !isVisible);
    });

    document.body.appendChild(toolbar);
    document.body.appendChild(toggleButton);
  }

  createFontSizeControls() {
    const container = document.createElement('div');
    container.innerHTML = `
      <label>Font Size:</label>
      <button data-font-size="small">Small</button>
      <button data-font-size="medium">Medium</button>
      <button data-font-size="large">Large</button>
    `;

    container.addEventListener('click', (event) => {
      if (event.target.dataset.fontSize) {
        document.body.className = document.body.className.replace(/font-size-\w+/, '');
        document.body.classList.add(`font-size-${event.target.dataset.fontSize}`);
        this.preferences.fontSize = event.target.dataset.fontSize;
        this.saveAccessibilityPreferences();
        this.announce(`Font size set to ${event.target.dataset.fontSize}`);
      }
    });

    return container;
  }

  createMotionControls() {
    const motionButton = document.createElement('button');
    motionButton.textContent = 'Reduce Motion';
    motionButton.setAttribute('aria-pressed', this.preferences.reduceMotion);
    
    motionButton.addEventListener('click', () => {
      this.preferences.reduceMotion = !this.preferences.reduceMotion;
      document.body.classList.toggle('reduce-motion', this.preferences.reduceMotion);
      motionButton.setAttribute('aria-pressed', this.preferences.reduceMotion);
      this.saveAccessibilityPreferences();
      this.announce(`Motion ${this.preferences.reduceMotion ? 'reduced' : 'enabled'}`);
    });

    return motionButton;
  }

  // Monitor dynamic content for accessibility
  monitorDynamicContent() {
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === Node.ELEMENT_NODE) {
              this.enhanceNewContent(node);
            }
          });
        }
      });
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  enhanceNewContent(element) {
    // Apply accessibility enhancements to dynamically added content
    if (element.matches('form')) {
      this.enhanceFormElements(element);
    }

    const forms = element.querySelectorAll('form');
    forms.forEach(form => this.enhanceFormElements(form));

    const tables = element.querySelectorAll('table');
    tables.forEach(table => this.enhanceTableAccessibility());
  }

  // Preference management
  loadAccessibilityPreferences() {
    try {
      const saved = localStorage.getItem('pondero_accessibility_preferences');
      return saved ? JSON.parse(saved) : {
        highContrast: false,
        fontSize: 'medium',
        reduceMotion: false
      };
    } catch (error) {
      return {
        highContrast: false,
        fontSize: 'medium',
        reduceMotion: false
      };
    }
  }

  saveAccessibilityPreferences() {
    try {
      localStorage.setItem('pondero_accessibility_preferences', JSON.stringify(this.preferences));
    } catch (error) {
      console.warn('Could not save accessibility preferences');
    }
  }

  // Modal accessibility helpers
  closeModal(modal) {
    modal.setAttribute('aria-hidden', 'true');
    modal.classList.remove('active');
    
    // Return focus to trigger element
    const triggerId = modal.dataset.triggeredBy;
    if (triggerId) {
      const triggerElement = document.getElementById(triggerId);
      if (triggerElement) {
        triggerElement.focus();
      }
    }
    
    this.announce('Dialog closed');
  }
}

// Initialize accessibility enhancements
document.addEventListener('DOMContentLoaded', () => {
  if (typeof window.ponderoAccessibility === 'undefined') {
    window.ponderoAccessibility = new AccessibilityEnhancer();
  }
});

// Add CSS for accessibility features
const accessibilityStyles = document.createElement('style');
accessibilityStyles.textContent = `
  /* High contrast mode */
  .high-contrast {
    filter: contrast(150%);
  }
  
  .high-contrast * {
    border-color: #000 !important;
  }
  
  /* Font size controls */
  .font-size-small { font-size: 14px; }
  .font-size-medium { font-size: 16px; }
  .font-size-large { font-size: 20px; }
  
  /* Reduced motion */
  .reduce-motion * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
  
  /* Screen reader only text */
  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0, 0, 0, 0);
    white-space: nowrap;
    border: 0;
  }
  
  /* Focus indicators */
  *:focus {
    outline: 2px solid #005fcc;
    outline-offset: 2px;
  }
  
  /* Error states */
  [aria-invalid="true"] {
    border-color: #d93025;
    box-shadow: 0 0 0 2px rgba(217, 48, 37, 0.2);
  }
  
  .error-message {
    color: #d93025;
    font-size: 14px;
    margin-top: 4px;
  }
  
  /* Required field indicators */
  .required-indicator {
    color: #d93025;
    font-weight: bold;
  }
`;

document.head.appendChild(accessibilityStyles);

export default AccessibilityEnhancer;