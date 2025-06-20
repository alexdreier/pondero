#!/bin/bash

# Auto-commit script for Claude Code changes
# Usage: ./auto_commit.sh "Your commit message"

if [ -z "$1" ]; then
    echo "Usage: ./auto_commit.sh \"Your commit message\""
    exit 1
fi

# Add all changes
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "No changes to commit"
    exit 0
fi

# Commit with provided message
git commit -m "$1"

# Push to GitHub
git push origin main

echo "✅ Changes committed and pushed to GitHub!"