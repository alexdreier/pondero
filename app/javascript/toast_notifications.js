// Toast notification system
class ToastNotifications {
  constructor() {
    this.setupGlobalToastFunction();
  }

  setupGlobalToastFunction() {
    // Make showToast available globally for Rails integration
    window.showToast = (message, type = 'info') => {
      this.showToast(message, type);
    };
  }

  showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    if (!container) {
      console.warn('Toast container not found');
      return;
    }

    const toast = document.createElement('div');
    
    const bgColor = {
      success: 'bg-green-600',
      error: 'bg-red-600',
      warning: 'bg-yellow-600',
      info: 'bg-blue-600'
    }[type] || 'bg-blue-600';
    
    toast.className = `${bgColor} text-white px-6 py-4 rounded-lg shadow-lg transform transition-all duration-300 translate-x-full opacity-0`;
    
    // Create elements safely to prevent XSS
    const messageContainer = document.createElement('div');
    messageContainer.className = 'flex items-center justify-between';
    
    const messageSpan = document.createElement('span');
    messageSpan.className = 'font-medium';
    messageSpan.textContent = message; // Use textContent instead of innerHTML
    
    const closeButton = document.createElement('button');
    closeButton.className = 'ml-4 text-white hover:text-gray-200';
    closeButton.onclick = function() { toast.remove(); };
    closeButton.innerHTML = `
      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
      </svg>
    `;
    
    messageContainer.appendChild(messageSpan);
    messageContainer.appendChild(closeButton);
    toast.appendChild(messageContainer);
    
    container.appendChild(toast);
    
    // Animate in
    setTimeout(() => {
      toast.classList.remove('translate-x-full', 'opacity-0');
    }, 100);
    
    // Auto remove
    setTimeout(() => {
      toast.classList.add('translate-x-full', 'opacity-0');
      setTimeout(() => toast.remove(), 300);
    }, 5000);
  }
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
  new ToastNotifications();
});

export default ToastNotifications;