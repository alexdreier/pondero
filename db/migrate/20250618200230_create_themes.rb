class CreateThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :themes do |t|
      t.string :name
      t.text :colors
      t.text :fonts
      t.text :layout_options
      t.text :description

      t.timestamps
    end
  end
end
