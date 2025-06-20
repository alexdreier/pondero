class CreateSections < ActiveRecord::Migration[8.0]
  def change
    create_table :sections do |t|
      t.references :journal, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :position, null: false

      t.timestamps
    end
    
    add_index :sections, [:journal_id, :position]
    add_index :sections, :position
  end
end
