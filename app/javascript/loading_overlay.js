// Loading overlay functionality
class LoadingOverlay {
  constructor() {
    this.setupGlobalLoadingFunctions();
  }

  setupGlobalLoadingFunctions() {
    // Make loading functions available globally
    window.showLoading = () => this.showLoading();
    window.hideLoading = () => this.hideLoading();
  }

  showLoading() {
    const overlay = document.getElementById('loading-overlay');
    if (overlay) {
      overlay.classList.remove('hidden');
    }
  }

  hideLoading() {
    const overlay = document.getElementById('loading-overlay');
    if (overlay) {
      overlay.classList.add('hidden');
    }
  }
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
  new LoadingOverlay();
});

export default LoadingOverlay;