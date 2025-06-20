#!/bin/bash
git add .
git commit -m "Add mobile header with visible Sign Out button for learners

- Mobile users now see hamburger menu and sign out button in top bar
- Fixed missing mobile header implementation  
- Sign out button clearly visible on mobile devices"
git push origin main
echo "✅ Changes pushed to GitHub!"