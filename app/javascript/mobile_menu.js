// Mobile menu functionality
class MobileMenu {
  constructor() {
    this.setupMobileMenu();
  }

  setupMobileMenu() {
    const mobileMenuButton = document.getElementById('mobile-menu-button');
    const mobileOverlay = document.getElementById('mobile-sidebar-overlay');
    const mobileBackdrop = document.getElementById('mobile-sidebar-backdrop');
    const mobileCloseButton = document.getElementById('mobile-sidebar-close');
    
    if (mobileMenuButton && mobileOverlay) {
      mobileMenuButton.addEventListener('click', () => {
        mobileOverlay.classList.toggle('hidden');
      });
      
      if (mobileBackdrop) {
        mobileBackdrop.addEventListener('click', () => {
          mobileOverlay.classList.add('hidden');
        });
      }
      
      if (mobileCloseButton) {
        mobileCloseButton.addEventListener('click', () => {
          mobileOverlay.classList.add('hidden');
        });
      }
    }
  }
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
  new MobileMenu();
});

// Also initialize on Turbo load for SPA behavior
document.addEventListener('turbo:load', () => {
  new MobileMenu();
});

export default MobileMenu;