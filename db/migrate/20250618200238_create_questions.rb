class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :journal, null: false, foreign_key: true
      t.text :content
      t.string :question_type
      t.text :options
      t.boolean :required
      t.integer :position

      t.timestamps
    end
  end
end
