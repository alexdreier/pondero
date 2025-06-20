#!/bin/bash
git add .
git commit -m "Fix navigation and profile functionality for students

✅ Logo now clickable - takes users back to dashboard
✅ User profile clickable - opens editable profile page  
✅ Created beautiful profile edit page with name/email/password
✅ Mobile header now shows clickable profile avatar
✅ Added edit icon to desktop profile section

Features:
- Students can click logo to go home
- Students can click their avatar/name to edit profile
- Clean profile editing interface with validation
- Responsive design for mobile and desktop
- Account deletion option with confirmation

"
git push origin main
echo "✅ All fixes pushed to GitHub!"