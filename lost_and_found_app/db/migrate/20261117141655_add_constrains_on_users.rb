class AddConstrainsOnUsers < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :users, 
      "(role = 1 AND facility_id IS NOT NULL) OR (role = 0 AND facility_id IS NULL)", 
      name: "role_check_for_user"
  end
end
