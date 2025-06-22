class CreateResponseFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :response_feedbacks do |t|
      t.references :response, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.boolean :read_by_student, default: false, null: false
      t.integer :parent_id
      t.integer :position, default: 0, null: false

      t.timestamps
    end
    
    # Indexes for performance
    add_index :response_feedbacks, :parent_id
    add_index :response_feedbacks, [:response_id, :position]
    add_index :response_feedbacks, [:response_id, :read_by_student]
    
    # Add feedback tracking to responses
    add_column :responses, :feedback_count, :integer, default: 0, null: false
    add_column :responses, :unread_feedback_count, :integer, default: 0, null: false
    add_column :responses, :last_feedback_at, :datetime
    
    # Add notification preferences to users
    add_column :users, :notify_on_feedback, :boolean, default: true, null: false
    add_column :users, :notify_on_feedback_reply, :boolean, default: true, null: false
  end
end
