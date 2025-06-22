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
      console.log('📝 Input event detected on:', event.target);
      if (this.shouldAutoSave(event.target)) {
        console.log('✅ Element should auto-save, scheduling...');
        this.scheduleAutoSave(event.target);
      } else {
        console.log('❌ Element should NOT auto-save');
        console.log('   - Element type:', event.target.tagName, event.target.type);
        console.log('   - Has form:', !!event.target.form);
        console.log('   - Data attributes:', event.target.dataset);
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
      'input[type="radio"]',
      'input[type="checkbox"]',
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
    console.log('💾 saveForm called with form:', form);
    if (!form || !this.isOnline) {
      console.log('❌ saveForm aborted - form:', !!form, 'online:', this.isOnline);
      return;
    }

    const formId = this.getFormId(form);
    const formData = new FormData(form);
    const currentContent = this.serializeFormData(formData);
    
    console.log('🔍 saveForm details:');
    console.log('   - Form ID:', formId);
    console.log('   - Form action:', form.action);
    console.log('   - Form method:', form.method);
    console.log('   - Current content:', currentContent);
    console.log('   - Last saved content:', this.lastSavedContent.get(formId));

    // Check if content has changed
    if (this.lastSavedContent.get(formId) === currentContent) {
      console.log('⚡ No changes detected, skipping save');
      return;
    }

    console.log('🚀 Content changed, proceeding with save...');

    // Add auto-save indicator
    formData.append('auto_save', 'true');
    
    // Ensure CSRF token is present
    const csrfToken = this.getCSRFToken();
    console.log('🔐 CSRF token check:', csrfToken ? 'Found' : 'Missing');
    if (!csrfToken) {
      console.error('❌ CSRF token not found - auto-save will fail');
      this.showSaveIndicator(form, 'error');
      return;
    }
    formData.append('authenticity_token', csrfToken);

    console.log('🎯 About to show saving indicator and make request...');
    this.showSaveIndicator(form, 'saving');
    
    try {
      // Determine method from form or default to PATCH for compatibility
      const method = form.method?.toUpperCase() === 'POST' ? 'POST' : 'PATCH';
      console.log('🌐 Making fetch request:', {
        url: form.action || window.location.pathname,
        method: method,
        hasFormData: !!formData
      });
      
      const response = await fetch(form.action || window.location.pathname, {
        method: method,
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
      });

      console.log('📡 Fetch response received:', {
        status: response.status,
        statusText: response.statusText,
        ok: response.ok
      });

      if (response.ok) {
        this.lastSavedContent.set(formId, currentContent);
        this.showSaveIndicator(form, 'saved');
        
        // Handle completion updates for journal forms
        const responseData = await response.json().catch(() => ({}));
        if (responseData.all_required_answered !== undefined) {
          this.updateSubmitButton(responseData.all_required_answered);
        }
        
        // Update form for subsequent saves if this was a creation (POST -> PATCH)
        if (method === 'POST' && responseData.response_id) {
          this.updateFormForExistingResponse(form, responseData.response_id);
        }
      } else if (response.status === 422) {
        // CSRF token validation failed
        this.showSaveIndicator(form, 'error');
        console.error('CSRF token validation failed');
      } else {
        throw new Error(`Save failed with status: ${response.status}`);
      }
    } catch (error) {
      console.error('❌ Auto-save failed:', error);
      console.error('❌ Error details:', {
        name: error.name,
        message: error.message,
        stack: error.stack
      });
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

  updateFormForExistingResponse(form, responseId) {
    // Update form to use PATCH method and response-specific URL for subsequent saves
    const questionId = form.id.replace('response-form-', '');
    form.action = `/responses/${responseId}`;
    form.method = 'patch';
    
    // Add hidden method field for Rails
    let methodInput = form.querySelector('input[name="_method"]');
    if (!methodInput) {
      methodInput = document.createElement('input');
      methodInput.type = 'hidden';
      methodInput.name = '_method';
      form.appendChild(methodInput);
    }
    methodInput.value = 'patch';
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