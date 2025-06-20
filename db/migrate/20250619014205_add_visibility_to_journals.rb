class AddVisibilityToJournals < ActiveRecord::Migration[8.0]
  def change
    add_column :journals, :visibility, :string, default: 'private', null: false
    add_column :journals, :access_level, :string, default: 'restricted', null: false
    
    add_index :journals, :visibility
    add_index :journals, :access_level
  end
end
