class AddMissingIndexes < ActiveRecord::Migration[8.0]
  def change
    # Add indexes for frequently queried columns to improve performance
    
    # Users table indexes
    add_index :users, :role unless index_exists?(:users, :role)
    
    # Journals table indexes
    add_index :journals, :published unless index_exists?(:journals, :published)
    add_index :journals, :visibility unless index_exists?(:journals, :visibility)
    add_index :journals, :access_level unless index_exists?(:journals, :access_level)
    add_index :journals, [:user_id, :published] unless index_exists?(:journals, [:user_id, :published])
    add_index :journals, [:visibility, :published] unless index_exists?(:journals, [:visibility, :published])
    
    # Questions table indexes
    add_index :questions, [:journal_id, :position] unless index_exists?(:questions, [:journal_id, :position])
    add_index :questions, :question_type unless index_exists?(:questions, :question_type)
    
    # Responses table indexes
    add_index :responses, [:user_id, :question_id] unless index_exists?(:responses, [:user_id, :question_id])
    add_index :responses, :question_id unless index_exists?(:responses, :question_id)
    
    # Journal submissions table indexes
    add_index :journal_submissions, [:journal_id, :user_id] unless index_exists?(:journal_submissions, [:journal_id, :user_id])
    add_index :journal_submissions, :user_id unless index_exists?(:journal_submissions, :user_id)
    add_index :journal_submissions, :journal_id unless index_exists?(:journal_submissions, :journal_id)
    
    # Comments table indexes (if comments table exists)
    if table_exists?(:comments)
      add_index :comments, :journal_submission_id unless index_exists?(:comments, :journal_submission_id)
      add_index :comments, [:journal_submission_id, :created_at] unless index_exists?(:comments, [:journal_submission_id, :created_at])
    end
  end
end
