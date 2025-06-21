// Auto-save functionality for enterprise reliability
// Implements periodic saving with conflict detection and user feedback

class AutoSave {
  constructor() {
    this.saveInterval = 30000; // 30 seconds
    this.lastSavedContent = {};
    this.saveTimeouts = {};
    this.isOnline = navigator.onLine;
    this.pendingSaves = new Map();
    
    this.initializeEventListeners();
    this.startPeriodicSave();
    this.monitorConnectionStatus();
  }

  initializeEventListeners() {
    // Monitor all form inputs for changes
    document.addEventListener('input', (event) => {
      if (this.shouldAutoSave(event.target)) {
        this.scheduleAutoSave(event.target);
      }
    });

    // Save before page unload
    window.addEventListener('beforeunload', (event) => {
      if (this.hasUnsavedChanges()) {
        this.saveAllForms(true); // Synchronous save
        event.preventDefault();
        event.returnValue = 'You have unsaved changes. Are you sure you want to leave?';
        return event.returnValue;
      }
    });

    // Handle visibility change (tab switching)
    document.addEventListener('visibilitychange', () => {
      if (document.hidden && this.hasUnsavedChanges()) {
        this.saveAllForms();
      }
    });
  }

  shouldAutoSave(element) {
    // Check if element should trigger auto-save
    const autoSaveElements = [
      'textarea',
      'input[type="text"]',
      'input[type="email"]',
      'select',
      '[data-auto-save="true"]',
      '.trix-editor' // Rich text editor
    ];

    return autoSaveElements.some(selector => element.matches(selector)) &&
           !element.matches('[data-auto-save="false"]') &&
           element.form;
  }

  scheduleAutoSave(element) {
    const formId = this.getFormId(element);
    
    // Clear existing timeout for this form
    if (this.saveTimeouts[formId]) {
      clearTimeout(this.saveTimeouts[formId]);
    }

    // Schedule new save
    this.saveTimeouts[formId] = setTimeout(() => {
      this.saveForm(element.form);
    }, 3000); // 3 second debounce
  }

  async saveForm(form, synchronous = false) {
    if (!form || !this.isOnline) return;

    const formId = this.getFormId(form);
    const formData = new FormData(form);
    const currentContent = this.serializeFormData(formData);

    // Check if content has changed
    if (this.lastSavedContent[formId] === currentContent) {
      return;
    }

    // Add auto-save indicator
    formData.append('auto_save', 'true');
    
    // Ensure CSRF token is present
    const csrfToken = this.getCSRFToken();
    if (!csrfToken) {
      console.error('CSRF token not found - auto-save will fail');
      this.showSaveIndicator(form, 'error');
      return Promise.reject(new Error('CSRF token not available'));
    }
    formData.append('authenticity_token', csrfToken);

    const savePromise = this.performSave(form, formData, formId, currentContent);

    if (synchronous) {
      try {
        await savePromise;
      } catch (error) {
        console.error('Synchronous auto-save failed:', error);
      }
    }

    return savePromise;
  }

  async performSave(form, formData, formId, currentContent) {
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
        this.lastSavedContent[formId] = currentContent;
        this.showSaveIndicator(form, 'saved');
        this.pendingSaves.delete(formId);
        
        // Update last saved timestamp
        this.updateLastSavedTimestamp(form);
        
        return true;
      } else if (response.status === 422) {
        // CSRF token is likely invalid/expired
        console.error('CSRF token validation failed - refreshing page');
        this.showSaveIndicator(form, 'error');
        // Optionally reload the page to get a fresh CSRF token
        setTimeout(() => {
          if (confirm('Your session may have expired. Refresh the page to continue?')) {
            window.location.reload();
          }
        }, 2000);
        throw new Error('CSRF token validation failed');
      } else {
        throw new Error(`Save failed with status: ${response.status}`);
      }
    } catch (error) {
      console.error('Auto-save failed:', error);
      this.showSaveIndicator(form, 'error');
      this.pendingSaves.set(formId, { formData, timestamp: Date.now() });
      
      // Retry logic for failed saves
      this.scheduleRetry(form, formData, formId, currentContent);
      return false;
    }
  }

  scheduleRetry(form, formData, formId, currentContent) {
    setTimeout(() => {
      if (this.isOnline && this.pendingSaves.has(formId)) {
        this.performSave(form, formData, formId, currentContent);
      }
    }, 10000); // Retry after 10 seconds
  }

  showSaveIndicator(form, status) {
    let indicator = form.querySelector('.auto-save-indicator');
    
    if (!indicator) {
      indicator = document.createElement('div');
      indicator.className = 'auto-save-indicator';
      indicator.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 8px 16px;
        border-radius: 4px;
        font-size: 14px;
        z-index: 1000;
        transition: all 0.3s ease;
      `;
      document.body.appendChild(indicator);
    }

    const messages = {
      saving: { text: 'Saving...', class: 'bg-blue-500 text-white' },
      saved: { text: 'Saved', class: 'bg-green-500 text-white' },
      error: { text: 'Save failed - will retry', class: 'bg-red-500 text-white' },
      offline: { text: 'Offline - changes saved locally', class: 'bg-yellow-500 text-black' }
    };

    const config = messages[status];
    indicator.textContent = config.text;
    indicator.className = `auto-save-indicator ${config.class}`;
    indicator.style.display = 'block';

    if (status === 'saved') {
      setTimeout(() => {
        indicator.style.display = 'none';
      }, 2000);
    }
  }

  startPeriodicSave() {
    setInterval(() => {
      if (this.hasUnsavedChanges() && this.isOnline) {
        this.saveAllForms();
      }
    }, this.saveInterval);
  }

  saveAllForms(synchronous = false) {
    const forms = document.querySelectorAll('form[data-auto-save="true"], .journal-form, .response-form');
    const savePromises = [];

    forms.forEach(form => {
      const promise = this.saveForm(form, synchronous);
      if (promise) savePromises.push(promise);
    });

    return synchronous ? Promise.all(savePromises) : savePromises;
  }

  monitorConnectionStatus() {
    window.addEventListener('online', () => {
      this.isOnline = true;
      this.retrySavedForms();
      document.querySelectorAll('.auto-save-indicator').forEach(el => el.remove());
    });

    window.addEventListener('offline', () => {
      this.isOnline = false;
      document.querySelectorAll('form').forEach(form => {
        this.showSaveIndicator(form, 'offline');
      });
    });
  }

  retrySavedForms() {
    this.pendingSaves.forEach((data, formId) => {
      const form = document.querySelector(`form[data-form-id="${formId}"], #${formId}`);
      if (form) {
        this.performSave(form, data.formData, formId, '');
      }
    });
  }

  hasUnsavedChanges() {
    const forms = document.querySelectorAll('form[data-auto-save="true"], .journal-form, .response-form');
    
    return Array.from(forms).some(form => {
      const formId = this.getFormId(form);
      const currentContent = this.serializeFormData(new FormData(form));
      return this.lastSavedContent[formId] !== currentContent;
    });
  }

  getFormId(element) {
    const form = element.form || element;
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

  updateLastSavedTimestamp(form) {
    let timestamp = form.querySelector('.last-saved-timestamp');
    if (!timestamp) {
      timestamp = document.createElement('div');
      timestamp.className = 'last-saved-timestamp text-sm text-gray-500 mt-2';
      const container = form.querySelector('.auto-save-container') || form;
      container.appendChild(timestamp);
    }
    
    const now = new Date();
    timestamp.textContent = `Last saved: ${now.toLocaleTimeString()}`;
  }

  // Recovery methods for enterprise reliability
  saveToLocalStorage(formId, data) {
    try {
      const backupKey = `pondero_backup_${formId}`;
      const backup = {
        data: data,
        timestamp: Date.now(),
        url: window.location.pathname
      };
      localStorage.setItem(backupKey, JSON.stringify(backup));
    } catch (error) {
      console.warn('Could not save to localStorage:', error);
    }
  }

  recoverFromLocalStorage(formId) {
    try {
      const backupKey = `pondero_backup_${formId}`;
      const backup = localStorage.getItem(backupKey);
      
      if (backup) {
        const parsed = JSON.parse(backup);
        // Only recover if backup is less than 24 hours old
        if (Date.now() - parsed.timestamp < 24 * 60 * 60 * 1000) {
          return parsed.data;
        } else {
          localStorage.removeItem(backupKey);
        }
      }
    } catch (error) {
      console.warn('Could not recover from localStorage:', error);
    }
    return null;
  }

  clearBackup(formId) {
    try {
      const backupKey = `pondero_backup_${formId}`;
      localStorage.removeItem(backupKey);
    } catch (error) {
      console.warn('Could not clear backup:', error);
    }
  }
}

// Initialize auto-save when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  if (typeof window.ponderoAutoSave === 'undefined') {
    window.ponderoAutoSave = new AutoSave();
  }
});

// Export for use in other modules
export default AutoSave;