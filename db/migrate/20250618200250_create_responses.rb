class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :content
      t.datetime :submitted_at
      t.string :status, default: 'draft'

      t.timestamps
    end
  end
end
