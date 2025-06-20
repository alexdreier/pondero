class CreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :journal, null: false, foreign_key: true
      t.date :entry_date
      t.string :status, default: 'draft'
      t.string :title
      t.text :description
      t.datetime :submitted_at

      t.timestamps
    end
    
    add_index :journal_entries, [:user_id, :journal_id]
    add_index :journal_entries, :entry_date
    add_index :journal_entries, :status
  end
end
