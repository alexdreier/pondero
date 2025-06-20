class AddLtiUserIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :lti_user_id, :string
    add_index :users, :lti_user_id
  end
end
