// Dark mode toggle functionality
class DarkMode {
  constructor() {
    this.setupDarkMode();
    this.loadSavedTheme();
  }

  setupDarkMode() {
    const darkModeToggle = document.getElementById('dark-mode-toggle');
    const darkModeToggleDesktop = document.getElementById('dark-mode-toggle-desktop');
    
    if (darkModeToggle) {
      darkModeToggle.addEventListener('click', () => this.toggleDarkMode());
    }
    
    if (darkModeToggleDesktop) {
      darkModeToggleDesktop.addEventListener('click', () => this.toggleDarkMode());
    }
  }

  toggleDarkMode() {
    const html = document.documentElement;
    const currentTheme = html.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    
    this.updateDarkModeIcons(newTheme);
  }

  updateDarkModeIcons(theme) {
    const sunIcon = `<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>`;
    const moonIcon = `<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>`;
    
    const icon = theme === 'dark' ? sunIcon : moonIcon;
    
    const darkModeToggle = document.getElementById('dark-mode-toggle');
    const darkModeToggleDesktop = document.getElementById('dark-mode-toggle-desktop');
    
    if (darkModeToggle) {
      const path = darkModeToggle.querySelector('svg path');
      if (path) {
        path.setAttribute('d', icon.match(/d="([^"]*)"/)[1]);
      }
    }
    
    if (darkModeToggleDesktop) {
      const path = darkModeToggleDesktop.querySelector('svg path');
      if (path) {
        path.setAttribute('d', icon.match(/d="([^"]*)"/)[1]);
      }
    }
  }

  loadSavedTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
    this.updateDarkModeIcons(savedTheme);
  }
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
  new DarkMode();
});

// Also initialize on Turbo load
document.addEventListener('turbo:load', () => {
  new DarkMode();
});

export default DarkMode;