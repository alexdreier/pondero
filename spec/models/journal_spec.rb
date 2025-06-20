# frozen_string_literal: true

# Enterprise Journal Model Tests
# Microsoft-level testing standards for journal functionality

require 'rails_helper'

RSpec.describe Journal, type: :model do
  describe 'validations' do
    subject { build(:journal) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:created_by) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_length_of(:description).is_at_most(2000) }

    context 'title uniqueness within user scope' do
      let(:user) { create(:user) }
      let!(:existing_journal) { create(:journal, title: 'Existing Journal', created_by: user) }

      it 'validates uniqueness of title per user' do
        duplicate_journal = build(:journal, title: 'Existing Journal', created_by: user)
        expect(duplicate_journal).not_to be_valid
        expect(duplicate_journal.errors[:title]).to include('has already been taken')
      end

      it 'allows same title for different users' do
        other_user = create(:user)
        same_title_journal = build(:journal, title: 'Existing Journal', created_by: other_user)
        expect(same_title_journal).to be_valid
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:created_by).class_name('User') }
    it { should have_many(:questions).dependent(:destroy) }
    it { should have_many(:journal_submissions).dependent(:destroy) }
    it { should have_many(:responses).through(:journal_submissions) }
    it { should have_many(:participants).through(:journal_submissions).source(:user) }
    it { should have_many(:coaching_logs).dependent(:destroy) }
    it { should belong_to(:section).optional }
    it { should belong_to(:copied_from).class_name('Journal').optional }
    it { should have_many(:copies).class_name('Journal').with_foreign_key('copied_from_id') }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(draft: 0, published: 1, archived: 2) }
    it { should define_enum_for(:visibility).with_values(private: 0, public: 1) }
  end

  describe 'scopes' do
    let!(:published_journals) { create_list(:journal, 3, status: :published) }
    let!(:draft_journals) { create_list(:journal, 2, status: :draft) }
    let!(:public_journals) { create_list(:journal, 2, visibility: :public, status: :published) }
    let!(:private_journals) { create_list(:journal, 2, visibility: :private, status: :published) }
    let(:user) { create(:user) }

    describe '.published' do
      it 'returns only published journals' do
        expect(Journal.published).to match_array(published_journals + public_journals + private_journals)
      end
    end

    describe '.draft' do
      it 'returns only draft journals' do
        expect(Journal.draft).to match_array(draft_journals)
      end
    end

    describe '.public_journals' do
      it 'returns only public journals' do
        expect(Journal.public_journals).to match_array(public_journals)
      end
    end

    describe '.accessible_to' do
      let(:admin) { create(:user, role: :admin) }
      let(:instructor) { create(:user, role: :instructor) }
      let(:learner) { create(:user, role: :learner) }
      let!(:instructor_journal) { create(:journal, created_by: instructor, status: :published) }

      it 'returns all journals for admin' do
        expect(Journal.accessible_to(admin).count).to eq(Journal.count)
      end

      it 'returns own journals for instructor' do
        accessible = Journal.accessible_to(instructor)
        expect(accessible).to include(instructor_journal)
      end

      it 'returns only public published journals for learner' do
        accessible = Journal.accessible_to(learner)
        expect(accessible).to match_array(public_journals)
      end
    end

    describe '.recent' do
      let!(:old_journal) { create(:journal, created_at: 2.months.ago) }
      let!(:recent_journal) { create(:journal, created_at: 1.day.ago) }

      it 'returns journals from last 30 days' do
        expect(Journal.recent).to include(recent_journal)
        expect(Journal.recent).not_to include(old_journal)
      end
    end
  end

  describe 'methods' do
    let(:journal) { create(:journal) }
    let(:user) { create(:user) }

    describe '#accessible_to?' do
      context 'admin user' do
        let(:admin) { create(:user, role: :admin) }

        it 'returns true for any journal' do
          expect(journal.accessible_to?(admin)).to be true
        end
      end

      context 'instructor user' do
        let(:instructor) { create(:user, role: :instructor) }

        it 'returns true for own journals' do
          own_journal = create(:journal, created_by: instructor)
          expect(own_journal.accessible_to?(instructor)).to be true
        end

        it 'returns false for other instructor journals' do
          other_journal = create(:journal, created_by: create(:user, role: :instructor))
          expect(other_journal.accessible_to?(instructor)).to be false
        end
      end

      context 'learner user' do
        let(:learner) { create(:user, role: :learner) }

        it 'returns true for public published journals' do
          public_journal = create(:journal, visibility: :public, status: :published)
          expect(public_journal.accessible_to?(learner)).to be true
        end

        it 'returns false for private journals' do
          private_journal = create(:journal, visibility: :private, status: :published)
          expect(private_journal.accessible_to?(learner)).to be false
        end

        it 'returns false for draft journals' do
          draft_journal = create(:journal, visibility: :public, status: :draft)
          expect(draft_journal.accessible_to?(learner)).to be false
        end
      end
    end

    describe '#completion_rate' do
      let!(:submissions) { create_list(:journal_submission, 5, journal: journal) }

      it 'calculates completion rate correctly' do
        # Complete 3 out of 5 submissions
        submissions.first(3).each { |s| s.update!(status: 'submitted') }
        
        expect(journal.completion_rate).to eq(60.0)
      end

      it 'returns 0 when no submissions' do
        empty_journal = create(:journal)
        expect(empty_journal.completion_rate).to eq(0.0)
      end
    end

    describe '#average_response_time' do
      let!(:submissions) { create_list(:journal_submission, 3, journal: journal) }

      it 'calculates average response time correctly' do
        submissions[0].update!(created_at: 1.hour.ago, completed_at: Time.current)
        submissions[1].update!(created_at: 2.hours.ago, completed_at: 1.hour.ago)
        submissions[2].update!(created_at: 3.hours.ago, completed_at: 2.hours.ago)

        avg_time = journal.average_response_time
        expect(avg_time).to be_a(Float)
        expect(avg_time).to be > 0
      end

      it 'returns 0 when no completed submissions' do
        expect(journal.average_response_time).to eq(0.0)
      end
    end

    describe '#copy!' do
      let(:original_journal) { create(:journal, title: 'Original Journal') }
      let!(:questions) { create_list(:question, 3, journal: original_journal) }
      let(:new_user) { create(:user) }

      it 'creates a copy with all questions' do
        copied_journal = original_journal.copy!(new_user, 'Copied Journal')
        
        expect(copied_journal.title).to eq('Copied Journal')
        expect(copied_journal.created_by).to eq(new_user)
        expect(copied_journal.copied_from).to eq(original_journal)
        expect(copied_journal.questions.count).to eq(3)
        expect(copied_journal.status).to eq('draft')
      end

      it 'copies question content correctly' do
        copied_journal = original_journal.copy!(new_user, 'Copied Journal')
        
        original_questions = original_journal.questions.order(:position)
        copied_questions = copied_journal.questions.order(:position)
        
        original_questions.zip(copied_questions).each do |original, copied|
          expect(copied.title).to eq(original.title)
          expect(copied.content).to eq(original.content)
          expect(copied.question_type).to eq(original.question_type)
          expect(copied.position).to eq(original.position)
        end
      end
    end

    describe '#participant_count', :performance do
      let!(:submissions) { create_list(:journal_submission, 10, journal: journal) }

      it 'counts participants efficiently' do
        expect_efficient_database_queries(max_queries: 1) do
          count = journal.participant_count
          expect(count).to eq(10)
        end
      end
    end

    describe '#engagement_score', :performance do
      let!(:submissions) { create_list(:journal_submission, 5, journal: journal) }

      before do
        submissions.each do |submission|
          create_list(:response, rand(1..3), journal_submission: submission)
        end
      end

      it 'calculates engagement score efficiently' do
        expect_efficient_database_queries(max_queries: 3) do
          score = journal.engagement_score
          expect(score).to be_a(Numeric)
          expect(score).to be >= 0
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      it 'strips whitespace from title and description' do
        journal = create(:journal, title: '  Test Journal  ', description: '  Test Description  ')
        
        expect(journal.title).to eq('Test Journal')
        expect(journal.description).to eq('Test Description')
      end

      it 'sets default values' do
        journal = Journal.create!(
          title: 'Test Journal',
          description: 'Test Description',
          created_by: create(:user)
        )
        
        expect(journal.status).to eq('draft')
        expect(journal.visibility).to eq('private')
      end
    end

    describe 'after_create' do
      it 'creates audit log entry' do
        user = create(:user)
        
        expect {
          create(:journal, created_by: user)
        }.to change { AuditLog.count }.by(1)
        
        audit_entry = AuditLog.last
        expect(audit_entry.action).to eq('journal_created')
        expect(audit_entry.user).to eq(user)
      end
    end

    describe 'after_update' do
      let(:journal) { create(:journal, status: :draft) }

      it 'creates audit log for status changes' do
        expect {
          journal.update!(status: :published)
        }.to change { AuditLog.count }.by(1)
        
        audit_entry = AuditLog.last
        expect(audit_entry.action).to eq('journal_published')
      end
    end
  end

  describe 'security' do
    describe 'data sanitization' do
      it 'sanitizes malicious content in title' do
        malicious_title = '<script>alert("xss")</script>Clean Title'
        journal = create(:journal, title: malicious_title)
        
        expect(journal.title).not_to include('<script>')
        expect(journal.title).to include('Clean Title')
      end

      it 'sanitizes malicious content in description' do
        malicious_desc = '<img src=x onerror=alert("xss")>Clean Description'
        journal = create(:journal, description: malicious_desc)
        
        expect(journal.description).not_to include('onerror')
        expect(journal.description).to include('Clean Description')
      end
    end

    describe 'access control' do
      let(:journal) { create(:journal, visibility: :private) }
      let(:unauthorized_user) { create(:user, role: :learner) }

      it 'prevents unauthorized access to private journals' do
        expect(journal.accessible_to?(unauthorized_user)).to be false
      end

      it 'logs access attempts' do
        expect {
          journal.accessible_to?(unauthorized_user)
        }.to change { AuditLog.where(action: 'access_attempted').count }.by(1)
      end
    end
  end

  describe 'performance' do
    describe 'database queries', :performance do
      let(:journal) { create(:journal) }

      it 'loads associations efficiently' do
        create_list(:question, 3, journal: journal)
        submission = create(:journal_submission, journal: journal)
        create_list(:response, 5, journal_submission: submission)

        expect_efficient_database_queries(max_queries: 3) do
          loaded_journal = Journal.includes(:questions, :journal_submissions, :responses).find(journal.id)
          loaded_journal.questions.each(&:title)
          loaded_journal.journal_submissions.each(&:status)
          loaded_journal.responses.each(&:content)
        end
      end
    end

    describe 'memory usage', :memory do
      it 'uses memory efficiently when loading multiple journals' do
        create_list(:journal, 50)

        expect_memory_efficiency(max_memory_mb: 20) do
          Journal.includes(:questions, :created_by).limit(25).to_a
        end
      end
    end
  end

  describe 'search functionality' do
    let!(:journal1) { create(:journal, title: 'Ruby Programming Guide') }
    let!(:journal2) { create(:journal, title: 'JavaScript Basics') }
    let!(:journal3) { create(:journal, description: 'Learn Ruby fundamentals') }

    describe '.search' do
      it 'finds journals by title' do
        results = Journal.search('Ruby')
        expect(results).to include(journal1, journal3)
        expect(results).not_to include(journal2)
      end

      it 'finds journals by description' do
        results = Journal.search('fundamentals')
        expect(results).to include(journal3)
        expect(results).not_to include(journal1, journal2)
      end

      it 'is case insensitive' do
        results = Journal.search('ruby')
        expect(results).to include(journal1, journal3)
      end
    end
  end
end