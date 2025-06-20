# frozen_string_literal: true

# Enterprise User Model Tests
# Comprehensive testing for Microsoft-level standards

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_inclusion_of(:role).in_array(%w[learner instructor admin]) }

    context 'email format validation' do
      it 'accepts valid email formats' do
        valid_emails = [
          'user@example.com',
          'test.user@wested.org',
          'user+tag@domain.co.uk'
        ]

        valid_emails.each do |email|
          user = build(:user, email: email)
          expect(user).to be_valid, "#{email} should be valid"
        end
      end

      it 'rejects invalid email formats' do
        invalid_emails = [
          'invalid',
          '@domain.com',
          'user@',
          'user..double.dot@domain.com'
        ]

        invalid_emails.each do |email|
          user = build(:user, email: email)
          expect(user).not_to be_valid, "#{email} should be invalid"
        end
      end
    end
  end

  describe 'associations' do
    it { should have_many(:journal_submissions).dependent(:destroy) }
    it { should have_many(:responses).through(:journal_submissions) }
    it { should have_many(:created_journals).class_name('Journal').with_foreign_key('created_by_id') }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(learner: 0, instructor: 1, admin: 2) }
  end

  describe 'scopes' do
    let!(:active_users) { create_list(:user, 3, updated_at: 1.day.ago) }
    let!(:inactive_users) { create_list(:user, 2, updated_at: 1.month.ago) }

    describe '.active' do
      it 'returns users active within the last week' do
        expect(User.active).to match_array(active_users)
      end
    end

    describe '.by_role' do
      let!(:instructors) { create_list(:user, 2, role: :instructor) }
      let!(:learners) { create_list(:user, 3, role: :learner) }

      it 'filters users by role' do
        expect(User.by_role(:instructor)).to match_array(instructors)
        expect(User.by_role(:learner)).to match_array(learners)
      end
    end
  end

  describe 'methods' do
    let(:user) { create(:user, first_name: 'John', last_name: 'Doe') }

    describe '#display_name' do
      it 'returns full name when both names present' do
        expect(user.display_name).to eq('John Doe')
      end

      it 'returns email when names are blank' do
        user.update!(first_name: '', last_name: '')
        expect(user.display_name).to eq(user.email)
      end

      it 'handles partial names gracefully' do
        user.update!(last_name: '')
        expect(user.display_name).to eq('John')
      end
    end

    describe '#full_name' do
      it 'returns properly formatted full name' do
        expect(user.full_name).to eq('John Doe')
      end
    end

    describe '#initials' do
      it 'returns user initials' do
        expect(user.initials).to eq('JD')
      end

      it 'handles single name' do
        user.update!(last_name: '')
        expect(user.initials).to eq('J')
      end

      it 'falls back to email first letter' do
        user.update!(first_name: '', last_name: '')
        expect(user.initials).to eq(user.email.first.upcase)
      end
    end

    describe 'role predicates' do
      it 'correctly identifies admin users' do
        admin = create(:user, role: :admin)
        expect(admin).to be_admin
        expect(admin).not_to be_instructor
        expect(admin).not_to be_learner
      end

      it 'correctly identifies instructor users' do
        instructor = create(:user, role: :instructor)
        expect(instructor).to be_instructor
        expect(instructor).not_to be_admin
        expect(instructor).not_to be_learner
      end

      it 'correctly identifies learner users' do
        learner = create(:user, role: :learner)
        expect(learner).to be_learner
        expect(learner).not_to be_admin
        expect(learner).not_to be_instructor
      end
    end

    describe '#can_access?' do
      let(:journal) { create(:journal) }

      context 'admin user' do
        let(:admin) { create(:user, role: :admin) }

        it 'can access any journal' do
          expect(admin.can_access?(journal)).to be true
        end
      end

      context 'instructor user' do
        let(:instructor) { create(:user, role: :instructor) }

        it 'can access their own journals' do
          own_journal = create(:journal, created_by: instructor)
          expect(instructor.can_access?(own_journal)).to be true
        end

        it 'cannot access other instructors journals' do
          other_journal = create(:journal, created_by: create(:user, role: :instructor))
          expect(instructor.can_access?(other_journal)).to be false
        end
      end

      context 'learner user' do
        let(:learner) { create(:user, role: :learner) }

        it 'can access published journals' do
          published_journal = create(:journal, published: true)
          expect(learner.can_access?(published_journal)).to be true
        end

        it 'cannot access unpublished journals' do
          unpublished_journal = create(:journal, published: false)
          expect(learner.can_access?(unpublished_journal)).to be false
        end
      end
    end

    describe '#activity_score', :performance do
      let(:user) { create(:user) }
      let(:journal) { create(:journal) }

      it 'calculates activity score efficiently' do
        # Create some activity data
        submission = create(:journal_submission, user: user, journal: journal)
        create_list(:response, 5, journal_submission: submission)

        expect_efficient_database_queries(max_queries: 3) do
          score = user.activity_score
          expect(score).to be_a(Numeric)
          expect(score).to be >= 0
        end
      end
    end
  end

  describe 'security' do
    describe 'password requirements' do
      it 'requires minimum password length' do
        user = build(:user, password: '123')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
      end

      it 'accepts strong passwords' do
        user = build(:user, password: 'SecurePassword123!')
        expect(user).to be_valid
      end
    end

    describe 'session security' do
      let(:user) { create(:user) }

      it 'tracks sign in attempts' do
        expect(user.sign_in_count).to eq(0)
        
        # Simulate sign in
        user.update!(
          sign_in_count: user.sign_in_count + 1,
          current_sign_in_at: Time.current,
          last_sign_in_at: user.current_sign_in_at
        )
        
        expect(user.sign_in_count).to eq(1)
      end
    end

    describe 'data sanitization' do
      it 'sanitizes user input' do
        malicious_input = '<script>alert("xss")</script>Honest User'
        user = create(:user, first_name: malicious_input)
        
        expect(user.first_name).not_to include('<script>')
        expect(user.first_name).to include('Honest User')
      end
    end
  end

  describe 'performance' do
    describe 'database queries', :performance do
      it 'loads associations efficiently' do
        user = create(:user)
        journal = create(:journal)
        submission = create(:journal_submission, user: user, journal: journal)
        create_list(:response, 3, journal_submission: submission)

        expect_efficient_database_queries(max_queries: 2) do
          loaded_user = User.includes(:journal_submissions, :responses).find(user.id)
          loaded_user.journal_submissions.each(&:responses)
        end
      end
    end

    describe 'memory usage', :memory do
      it 'uses memory efficiently when loading multiple users' do
        create_list(:user, 100)

        expect_memory_efficiency(max_memory_mb: 10) do
          User.includes(:journal_submissions).limit(50).to_a
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      it 'normalizes email to lowercase' do
        user = create(:user, email: 'USER@EXAMPLE.COM')
        expect(user.email).to eq('user@example.com')
      end

      it 'strips whitespace from names' do
        user = create(:user, first_name: '  John  ', last_name: '  Doe  ')
        expect(user.first_name).to eq('John')
        expect(user.last_name).to eq('Doe')
      end
    end

    describe 'after_create' do
      it 'sets default role if not specified' do
        user = User.create!(
          email: 'test@example.com',
          password: 'password123',
          first_name: 'Test',
          last_name: 'User'
        )
        expect(user.role).to eq('learner')
      end
    end
  end

  describe 'audit trail' do
    it 'creates audit log entries for important changes' do
      user = create(:user)
      
      expect {
        user.update!(role: :admin)
      }.to change { AuditLog.count }.by(1)
      
      audit_entry = AuditLog.last
      expect(audit_entry.action).to eq('role_changed')
      expect(audit_entry.user).to eq(user)
    end
  end
end