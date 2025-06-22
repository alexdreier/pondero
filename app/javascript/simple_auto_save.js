// Simplified Auto-save functionality - cleaner and more maintainable
class SimpleAutoSave {
  constructor() {
    this.saveInterval = 30000; // 30 seconds
    this.saveTimeouts = new Map();
    this.lastSavedContent = new Map();
    this.isOnline = navigator.onLine;
    
    this.initializeEventListeners();
    this.monitorConnectionStatus();
  }

  initializeEventListeners() {
    // Monitor form inputs for changes
    document.addEventListener('input', (event) => {
      if (this.shouldAutoSave(event.target)) {
        this.scheduleAutoSave(event.target);
      }
    });

    // Save before page unload
    window.addEventListener('beforeunload', (event) => {
      if (this.hasUnsavedChanges()) {
        return 'You have unsaved changes. Are you sure you want to leave?';
      }
    });
  }

  shouldAutoSave(element) {
    const autoSaveElements = [
      'textarea',
      'input[type="text"]',
      'input[type="email"]',
      'select',
      '[data-auto-save="true"]',
      '.trix-editor'
    ];

    return autoSaveElements.some(selector => element.matches(selector)) &&
           !element.matches('[data-auto-save="false"]') &&
           element.form;
  }

  scheduleAutoSave(element) {
    const formId = this.getFormId(element.form);
    
    // Clear existing timeout
    if (this.saveTimeouts.has(formId)) {
      clearTimeout(this.saveTimeouts.get(formId));
    }

    // Schedule new save
    const timeoutId = setTimeout(() => {
      this.saveForm(element.form);
    }, 3000); // 3 second debounce
    
    this.saveTimeouts.set(formId, timeoutId);
  }

  async saveForm(form) {
    if (!form || !this.isOnline) return;

    const formId = this.getFormId(form);
    const formData = new FormData(form);
    const currentContent = this.serializeFormData(formData);

    // Check if content has changed
    if (this.lastSavedContent.get(formId) === currentContent) {
      return;
    }

    // Add auto-save indicator
    formData.append('auto_save', 'true');
    
    // Ensure CSRF token is present
    const csrfToken = this.getCSRFToken();
    if (!csrfToken) {
      console.error('CSRF token not found - auto-save will fail');
      this.showSaveIndicator(form, 'error');
      return;
    }
    formData.append('authenticity_token', csrfToken);

    this.showSaveIndicator(form, 'saving');
    
    try {
      const response = await fetch(form.action || window.location.pathname, {
        method: 'PATCH',
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
      });

      if (response.ok) {
        this.lastSavedContent.set(formId, currentContent);
        this.showSaveIndicator(form, 'saved');
        
        // Handle completion updates for journal forms
        const responseData = await response.json().catch(() => ({}));
        if (responseData.all_required_answered !== undefined) {
          this.updateSubmitButton(responseData.all_required_answered);
        }
      } else if (response.status === 422) {
        // CSRF token validation failed
        this.showSaveIndicator(form, 'error');
        console.error('CSRF token validation failed');
      } else {
        throw new Error(`Save failed with status: ${response.status}`);
      }
    } catch (error) {
      console.error('Auto-save failed:', error);
      this.showSaveIndicator(form, 'error');
    }
  }

  showSaveIndicator(form, status) {
    // Remove existing indicator
    const existingIndicator = document.querySelector('.auto-save-indicator');
    if (existingIndicator) {
      existingIndicator.remove();
    }

    const indicator = document.createElement('div');
    indicator.className = 'auto-save-indicator fixed top-4 right-4 px-4 py-2 rounded text-sm font-medium z-50';
    
    const configs = {
      saving: { text: 'Saving...', class: 'bg-blue-500 text-white' },
      saved: { text: 'Saved ✓', class: 'bg-green-500 text-white' },
      error: { text: 'Save failed', class: 'bg-red-500 text-white' }
    };

    const config = configs[status] || configs.saved;
    indicator.textContent = config.text;
    indicator.className += ` ${config.class}`;
    
    document.body.appendChild(indicator);

    if (status === 'saved') {
      setTimeout(() => indicator.remove(), 2000);
    }
  }

  hasUnsavedChanges() {
    const forms = document.querySelectorAll('form[data-auto-save="true"], .journal-form, .response-form');
    
    return Array.from(forms).some(form => {
      const formId = this.getFormId(form);
      const currentContent = this.serializeFormData(new FormData(form));
      return this.lastSavedContent.get(formId) !== currentContent;
    });
  }

  getFormId(form) {
    return form.id || form.dataset.formId || `form-${Array.from(document.forms).indexOf(form)}`;
  }

  serializeFormData(formData) {
    const pairs = [];
    for (const [key, value] of formData.entries()) {
      if (key !== 'authenticity_token' && key !== 'auto_save') {
        pairs.push(`${key}=${value}`);
      }
    }
    return pairs.sort().join('&');
  }

  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
  }

  updateSubmitButton(allRequiredAnswered) {
    const submitButton = document.querySelector('a[href*="journal_submission"], button[data-submit="journal"]');
    const disabledButton = document.querySelector('button[disabled][class*="Complete Required Questions"]');
    
    if (allRequiredAnswered) {
      // Enable submit button
      if (disabledButton) {
        disabledButton.style.display = 'none';
      }
      if (submitButton) {
        submitButton.style.display = 'inline-flex';
      }
    } else {
      // Disable submit button  
      if (submitButton) {
        submitButton.style.display = 'none';
      }
      if (disabledButton) {
        disabledButton.style.display = 'inline-flex';
      }
    }
  }

  monitorConnectionStatus() {
    window.addEventListener('online', () => {
      this.isOnline = true;
    });

    window.addEventListener('offline', () => {
      this.isOnline = false;
    });
  }
}

// Initialize auto-save when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  if (typeof window.ponderoAutoSave === 'undefined') {
    window.ponderoAutoSave = new SimpleAutoSave();
  }
});

// Also initialize on Turbo load
document.addEventListener('turbo:load', () => {
  if (typeof window.ponderoAutoSave === 'undefined') {
    window.ponderoAutoSave = new SimpleAutoSave();
  }
});

export default SimpleAutoSave;