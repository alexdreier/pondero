#!/bin/bash

echo "🏗️ Compiling assets locally..."

# Set production environment for asset compilation
export RAILS_ENV=production

# Precompile assets
bundle exec rails assets:precompile

# Add compiled assets to git (normally ignored)
git add public/assets/

echo "✅ Assets compiled and ready for deployment"