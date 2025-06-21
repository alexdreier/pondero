// Enhanced form validation system
class FormValidation {
  constructor() {
    this.setupFormValidation();
  }

  setupFormValidation() {
    document.addEventListener('DOMContentLoaded', () => {
      this.initializeValidation();
    });
    
    document.addEventListener('turbo:load', () => {
      this.initializeValidation();
    });
  }

  initializeValidation() {
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
      const inputs = form.querySelectorAll('input, textarea, select');
      inputs.forEach(input => {
        input.addEventListener('blur', (event) => this.validateField(event));
        input.addEventListener('input', (event) => this.clearFieldError(event));
      });
    });
  }

  validateField(event) {
    const field = event.target;
    const value = field.value.trim();
    
    // Clear previous errors
    this.clearFieldError(event);
    
    // Validate required fields
    if (field.hasAttribute('required') && !value) {
      this.showFieldError(field, 'This field is required');
      return false;
    }
    
    // Validate email fields
    if (field.type === 'email' && value) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(value)) {
        this.showFieldError(field, 'Please enter a valid email address');
        return false;
      }
    }
    
    return true;
  }

  showFieldError(field, message) {
    field.classList.add('form-input-error');
    
    let errorDiv = field.parentNode.querySelector('.field-error');
    if (!errorDiv) {
      errorDiv = document.createElement('div');
      errorDiv.className = 'field-error text-red-600 text-sm mt-1';
      field.parentNode.appendChild(errorDiv);
    }
    errorDiv.textContent = message;
  }

  clearFieldError(event) {
    const field = event.target;
    field.classList.remove('form-input-error');
    
    const errorDiv = field.parentNode.querySelector('.field-error');
    if (errorDiv) {
      errorDiv.remove();
    }
  }
}

// Initialize validation
new FormValidation();

export default FormValidation;