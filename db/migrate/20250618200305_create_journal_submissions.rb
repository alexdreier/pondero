class CreateJournalSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :journal, null: false, foreign_key: true
      t.datetime :completed_at
      t.string :status, default: 'in_progress'

      t.timestamps
    end
  end
end
