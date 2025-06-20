class AddJournalEntryToResponses < ActiveRecord::Migration[8.0]
  def change
    add_reference :responses, :journal_entry, null: true, foreign_key: true
    add_index :responses, [:journal_entry_id, :question_id], unique: true
  end
end
