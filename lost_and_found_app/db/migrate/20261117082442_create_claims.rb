class CreateClaims < ActiveRecord::Migration[7.1]
  def change
    create_table :claims do |t|
      t.references :user, foreign_key: true, null:false
      t.references :item, foreign_key: true, null:false
      t.integer :status, null:false
      t.string :contact_info, null:false
      t.string :message

      t.timestamps
    end
  end
end
