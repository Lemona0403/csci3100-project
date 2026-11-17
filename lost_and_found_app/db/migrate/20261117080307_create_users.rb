class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, index: {unique: true}, null:false
      t.string :password, null:false
      t.string :name, null:false
      t.integer :role, null:false
      t.references :facility, foreign_key: true

      t.timestamps
    end
  end
end
