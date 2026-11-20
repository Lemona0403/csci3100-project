class ReplacePlaintextPasswordWithDevisePassword < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :password, :string
    add_column :users, :encrypted_password, :string, null: false, default: ""
  end
end