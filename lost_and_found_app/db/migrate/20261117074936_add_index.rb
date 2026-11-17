class AddIndex < ActiveRecord::Migration[7.1]
  def change
    add_index :facilities, :name, unique: true
  end
end
