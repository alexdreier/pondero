# 🚀 Pondero Demo Setup Guide

## Quick Demo Setup (5 minutes)

### Prerequisites
- Ruby 3.0+ and Rails 8.0+
- PostgreSQL running locally
- Git installed

### 1. Setup Environment

```bash
# Navigate to the project
cd /Users/alexdreier/Documents/GitHub/pondero/pondero

# Install dependencies
bundle install

# Setup database
rails db:setup
rails db:migrate

# Seed with demo data
rails db:seed
```

### 2. Start the Demo Server

```bash
# Start Rails server
rails server

# Or with specific port
rails server -p 3000
```

**🌐 Access the demo at: http://localhost:3000**

### 3. Demo User Accounts

The seed data creates these demo accounts:

#### Administrator Account
- **Email:** `admin@pondero.demo`
- **Password:** `demo123456`
- **Role:** Administrator
- **Features:** Full system access, user management, analytics

#### Instructor Account  
- **Email:** `instructor@pondero.demo`
- **Password:** `demo123456`
- **Role:** Instructor
- **Features:** Create journals, view submissions, provide feedback

#### Learner Account
- **Email:** `learner@pondero.demo`  
- **Password:** `demo123456`
- **Role:** Learner
- **Features:** Complete journals, view dashboard, export PDFs

### 4. Demo Scenarios

#### Scenario 1: Administrator Experience
1. Login as admin@pondero.demo
2. View user management dashboard
3. Create new themes and templates
4. Monitor system analytics
5. Configure LTI settings

#### Scenario 2: Instructor Experience  
1. Login as instructor@pondero.demo
2. Create a new reflective journal
3. Add different question types (text, multiple choice, Likert scale)
4. Organize with sections
5. Set availability dates
6. View learner submissions
7. Provide feedback via comments
8. Export submission analytics

#### Scenario 3: Learner Experience
1. Login as learner@pondero.demo
2. View available journals dashboard
3. Complete a journal entry with auto-save
4. Experience rich text editing
5. Upload files (if enabled)
6. View completion progress
7. Export personal journal as PDF
8. Test accessibility features

### 5. Key Features to Demonstrate

#### 🎯 Core Functionality
- **Journal Creation** - Template system with drag-and-drop
- **Rich Text Editing** - WYSIWYG with Trix editor
- **Auto-save** - Real-time saving with conflict detection
- **Multi-format Questions** - 8 different question types
- **Progress Tracking** - Completion percentages and status

#### 🔐 Enterprise Features
- **Role-based Access** - Different views per user type
- **FERPA Compliance** - Secure logging and data handling
- **LTI Integration** - Canvas-ready configuration
- **PDF Export** - Professional formatting
- **Accessibility** - WCAG 2.1 AA compliant interface

#### 📊 Analytics & Reporting
- **Instructor Dashboard** - Submission overview
- **Progress Analytics** - Individual and cohort insights
- **Export Capabilities** - PDF and data export
- **Activity Logging** - Comprehensive audit trails

### 6. Demo Talking Points

#### For Educational Leaders:
- **FERPA Compliance:** "All student data is handled according to strict privacy regulations"
- **Accessibility:** "Fully WCAG 2.1 AA compliant for inclusive learning"
- **Scalability:** "Enterprise-grade architecture supports thousands of users"
- **Integration:** "Seamless Canvas LTI integration with single sign-on"

#### For IT Directors:
- **Security:** "Role-based access control with comprehensive audit logging"
- **Performance:** "PostgreSQL multi-database setup with optimized queries"
- **Monitoring:** "Built-in error handling and performance tracking"
- **Deployment:** "Docker-ready with automated deployment pipelines"

#### For Instructors:
- **Ease of Use:** "Intuitive journal creation with drag-and-drop interface"
- **Flexibility:** "8 question types support diverse reflection activities"
- **Feedback Tools:** "Rich commenting system for meaningful instructor feedback"
- **Analytics:** "Track student engagement and reflection quality over time"

#### For Students:
- **Auto-save:** "Never lose your work with automatic saving every 30 seconds"
- **Accessibility:** "Works with screen readers and supports keyboard navigation"
- **Mobile Friendly:** "Complete journals on any device with responsive design"
- **Export:** "Download your reflection journey as a professional PDF"

### 7. Advanced Demo Features

#### LTI Integration Demo
```xml
<!-- Canvas LTI Configuration -->
<configuration>
  <title>Pondero Reflective Journaling</title>
  <description>Enterprise journaling platform</description>
  <launch_url>http://localhost:3000/lti/launch</launch_url>
  <privacy_level>public</privacy_level>
</configuration>
```

#### API Demonstration
```bash
# Test API endpoints
curl -X GET http://localhost:3000/api/journals \
  -H "Authorization: Bearer YOUR_TOKEN"

# Export analytics
curl -X GET http://localhost:3000/api/analytics/export \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## 🎥 Demo Flow (15-minute presentation)

### Minutes 1-3: Overview & Login
- Show homepage and explain value proposition
- Demonstrate secure login process
- Highlight role-based access

### Minutes 4-7: Instructor Experience
- Create new journal with multiple question types
- Show drag-and-drop organization
- Set scheduling and visibility options
- Demonstrate theme customization

### Minutes 8-11: Learner Experience  
- Complete journal with auto-save demonstration
- Show rich text editing capabilities
- Test accessibility features (keyboard navigation)
- Export PDF of completed journal

### Minutes 12-15: Enterprise Features
- View analytics dashboard
- Show FERPA-compliant logging
- Demonstrate LTI configuration
- Highlight security and scalability features

## 🔧 Troubleshooting

### Common Issues:

#### Database Connection Error
```bash
# Check PostgreSQL is running
brew services start postgresql
# Or
sudo service postgresql start
```

#### Missing Gems
```bash
bundle install --without production
```

#### Assets Not Loading
```bash
rails assets:precompile
```

#### Permission Issues
```bash
# Fix file permissions
chmod -R 755 /Users/alexdreier/Documents/GitHub/pondero/pondero
```

## 📱 Mobile Demo

The application is fully responsive. Test on:
- iPhone/iPad Safari
- Android Chrome
- Tablet orientations
- Screen readers (VoiceOver, JAWS)

## 🌐 Production Demo

For a production-ready demo:

1. Deploy to Heroku/Railway/DigitalOcean
2. Configure environment variables
3. Set up PostgreSQL database
4. Configure Redis for caching
5. Enable SSL certificates
6. Set up monitoring (Sentry, New Relic)

## 📞 Demo Support

If you encounter issues during setup:
1. Check the Rails logs: `tail -f log/development.log`
2. Verify database connectivity
3. Ensure all migrations have run
4. Check browser console for JavaScript errors

---

**🎯 Demo Objective:** Showcase Pondero as an enterprise-ready, accessible, and secure reflective journaling platform that seamlessly integrates with existing LMS infrastructure while providing powerful analytics and user management capabilities.