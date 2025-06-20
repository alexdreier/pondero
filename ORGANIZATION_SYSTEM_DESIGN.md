# Pondero Organization Management System Design

## 🏢 **System Architecture Overview**

### **Hierarchy Structure**
```
Organization (School/Company)
├── Administrators (manage org)
├── Instructors (create journals)
└── Learners (complete journals)
    └── Groups/Classes (optional grouping)
```

### **User Flow**
1. **Organization Admin** signs up and creates organization
2. **Admin invites Instructors** via email or bulk CSV
3. **Instructors invite Learners** to their classes/groups
4. **Instructors create journals** for their groups
5. **Learners access journals** within their organization context

## 📊 **Database Schema Design**

### **Organizations Table**
```ruby
class Organization < ApplicationRecord
  # Basic Info
  t.string :name, null: false
  t.text :description
  t.string :domain # Optional: school.edu domain for auto-assignment
  t.string :organization_type # school, company, nonprofit, etc.
  
  # Settings
  t.boolean :allow_self_registration, default: false
  t.string :registration_code # For student self-signup
  t.integer :max_users, default: 1000
  
  # Billing/Plan Info (future)
  t.string :plan_type, default: 'free'
  t.datetime :plan_expires_at
  
  # Contact Info
  t.string :contact_email
  t.string :contact_phone
  t.text :address
  
  # Timestamps
  t.timestamps
  
  # Relationships
  has_many :organization_memberships, dependent: :destroy
  has_many :users, through: :organization_memberships
  has_many :user_invitations, dependent: :destroy
  has_many :groups, dependent: :destroy
  
  # Scopes by role
  has_many :administrators, -> { where(organization_memberships: { role: 'administrator' }) }, 
           through: :organization_memberships, source: :user
  has_many :instructors, -> { where(organization_memberships: { role: 'instructor' }) }, 
           through: :organization_memberships, source: :user
  has_many :learners, -> { where(organization_memberships: { role: 'learner' }) }, 
           through: :organization_memberships, source: :user
           
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :domain, uniqueness: true, allow_blank: true
  validates :organization_type, inclusion: { 
    in: %w[school university company nonprofit government other] 
  }
end
```

### **Organization Memberships (Join Table)**
```ruby
class OrganizationMembership < ApplicationRecord
  t.references :organization, null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.string :role, null: false # administrator, instructor, learner
  t.boolean :active, default: true
  t.datetime :joined_at, default: -> { Time.current }
  t.timestamps
  
  belongs_to :organization
  belongs_to :user
  
  validates :role, inclusion: { in: %w[administrator instructor learner] }
  validates :user_id, uniqueness: { scope: :organization_id }
  
  scope :active, -> { where(active: true) }
  scope :administrators, -> { where(role: 'administrator') }
  scope :instructors, -> { where(role: 'instructor') }
  scope :learners, -> { where(role: 'learner') }
end
```

### **Groups/Classes Table**
```ruby
class Group < ApplicationRecord
  t.references :organization, null: false, foreign_key: true
  t.references :instructor, null: false, foreign_key: { to_table: :users }
  t.string :name, null: false
  t.text :description
  t.string :group_code # For easy student joining
  t.boolean :active, default: true
  t.timestamps
  
  belongs_to :organization
  belongs_to :instructor, class_name: 'User'
  has_many :group_memberships, dependent: :destroy
  has_many :learners, through: :group_memberships, source: :user
  has_many :journals, dependent: :destroy
  
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :group_code, uniqueness: { scope: :organization_id }, allow_blank: true
  
  before_create :generate_group_code
  
  private
  
  def generate_group_code
    self.group_code = SecureRandom.alphanumeric(8).upcase
  end
end
```

### **Group Memberships**
```ruby
class GroupMembership < ApplicationRecord
  t.references :group, null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.datetime :joined_at, default: -> { Time.current }
  t.timestamps
  
  belongs_to :group
  belongs_to :user
  
  validates :user_id, uniqueness: { scope: :group_id }
end
```

### **User Invitations**
```ruby
class UserInvitation < ApplicationRecord
  t.references :organization, null: false, foreign_key: true
  t.references :invited_by, null: false, foreign_key: { to_table: :users }
  t.string :email, null: false
  t.string :role, null: false
  t.string :token, null: false
  t.datetime :expires_at, null: false
  t.datetime :accepted_at
  t.boolean :used, default: false
  t.timestamps
  
  belongs_to :organization
  belongs_to :invited_by, class_name: 'User'
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[administrator instructor learner] }
  validates :token, uniqueness: true
  
  scope :pending, -> { where(used: false, accepted_at: nil) }
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :valid, -> { pending.where('expires_at > ?', Time.current) }
  
  before_create :generate_token_and_expiry
  
  def expired?
    expires_at < Time.current
  end
  
  def accept!(user_attributes = {})
    return false if expired? || used?
    
    # Create or update user
    user = User.find_by(email: email)
    if user
      # Add to organization
      organization.organization_memberships.create!(
        user: user,
        role: role
      )
    else
      # Create new user
      user = User.create!(user_attributes.merge(
        email: email,
        password: SecureRandom.alphanumeric(12)
      ))
      organization.organization_memberships.create!(
        user: user,
        role: role
      )
    end
    
    update!(used: true, accepted_at: Time.current)
    user
  end
  
  private
  
  def generate_token_and_expiry
    self.token = SecureRandom.urlsafe_base64(32)
    self.expires_at = 7.days.from_now
  end
end
```

### **Updated User Model**
```ruby
class User < ApplicationRecord
  # Add organization relationships
  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :sent_invitations, class_name: 'UserInvitation', 
           foreign_key: 'invited_by_id', dependent: :destroy
  
  # Current organization context (for multi-org users)
  attr_accessor :current_organization
  
  def administrator_of?(organization)
    organization_memberships.find_by(
      organization: organization, 
      role: 'administrator', 
      active: true
    ).present?
  end
  
  def instructor_in?(organization)
    organization_memberships.find_by(
      organization: organization, 
      role: 'instructor', 
      active: true
    ).present?
  end
  
  def learner_in?(organization)
    organization_memberships.find_by(
      organization: organization, 
      role: 'learner', 
      active: true
    ).present?
  end
  
  def primary_organization
    organization_memberships.order(:created_at).first&.organization
  end
end
```

### **Updated Journal Model**
```ruby
class Journal < ApplicationRecord
  # Add organization context
  belongs_to :organization, optional: true
  belongs_to :group, optional: true
  
  # Scope journals by organization
  scope :for_organization, ->(org) { where(organization: org) }
  scope :for_group, ->(group) { where(group: group) }
  
  def accessible_to_user?(user)
    return false unless user
    
    if organization
      # Check if user belongs to organization
      return false unless user.organizations.include?(organization)
      
      # Instructors can access their own journals
      return true if user == self.user
      
      # Administrators can access all org journals
      return true if user.administrator_of?(organization)
      
      # Learners can access published journals in their groups
      if user.learner_in?(organization)
        return published? && (
          group.nil? || user.groups.include?(group)
        )
      end
    end
    
    # Fallback to existing logic for non-org journals
    accessible_to?(user)
  end
end
```

## 🎯 **User Experience Flows**

### **Organization Setup Flow**
1. **Admin Registration**
   - Name, email, password
   - Organization name, type, description
   - Contact information
   
2. **Organization Configuration**
   - Set registration policies
   - Upload logo/branding
   - Configure user limits
   - Generate registration codes

3. **User Invitation**
   - Bulk CSV upload
   - Individual email invitations
   - Self-registration codes

### **Instructor Workflow**
1. **Accept Invitation** or **Self-Register**
2. **Create Groups/Classes** (optional)
3. **Invite Students** to groups
4. **Create Journals** for groups or organization
5. **Monitor Student Progress**

### **Student Workflow**
1. **Accept Invitation** or **Join with Code**
2. **Browse Available Journals**
3. **Complete Journal Responses**
4. **Track Personal Progress**

## 🔧 **Administrative Features**

### **Organization Dashboard**
- User count and activity metrics
- Journal creation and completion stats
- Storage usage (for file uploads)
- Recent activity feed

### **User Management**
- View all users by role
- Bulk actions (activate/deactivate)
- Role changes
- Usage analytics per user

### **Group Management**
- Create/edit groups
- Assign instructors to groups
- Move learners between groups
- Group-specific analytics

### **System Settings**
- Organization profile
- Registration policies
- Email templates customization
- Data export options

## 🚀 **Implementation Priority**

### **Phase 1: Core Organization System (Week 1)**
1. Database migrations for all new models
2. Basic organization creation and management
3. User invitation system
4. Organization-scoped user authentication

### **Phase 2: User Management (Week 2)**
1. Admin dashboard for user management
2. Bulk user import via CSV
3. Group/class creation and management
4. Organization-scoped journal access

### **Phase 3: Enhanced Features (Week 3)**
1. Self-registration with codes
2. Advanced analytics and reporting
3. Email template customization
4. Organization branding options

### **Phase 4: Polish and Scale (Week 4)**
1. Performance optimization
2. Advanced permissions
3. Data export features
4. Mobile app considerations

## 📧 **Email Templates Needed**

1. **Organization Invitation** - Admin invites instructors
2. **Instructor Invitation** - Instructors invite students
3. **Welcome Email** - New user onboarding
4. **Password Reset** - Organization-specific branding
5. **Activity Digest** - Weekly progress summaries

## 🔒 **Security Considerations**

1. **Multi-tenancy** - Strict organization data isolation
2. **Role-based Access Control** - Granular permissions
3. **Invitation Security** - Time-limited tokens
4. **Data Privacy** - GDPR/FERPA compliance ready
5. **Audit Logging** - Track administrative actions

---

This design creates a robust, scalable organization management system that supports:
- Schools with multiple teachers and classes
- Companies with training departments
- Nonprofits with program coordinators
- Any group-based learning environment

Ready to start building this out?