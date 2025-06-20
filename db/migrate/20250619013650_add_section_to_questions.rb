class AddSectionToQuestions < ActiveRecord::Migration[8.0]
  def change
    add_reference :questions, :section, null: true, foreign_key: true
  end
end
