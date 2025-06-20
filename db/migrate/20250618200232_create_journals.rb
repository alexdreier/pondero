class CreateJournals < ActiveRecord::Migration[8.0]
  def change
    create_table :journals do |t|
      t.string :title
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.references :theme, null: true, foreign_key: true
      t.datetime :available_from
      t.datetime :available_until
      t.boolean :published, default: false
      t.integer :position
      t.string :status, default: 'draft'

      t.timestamps
    end
  end
end
