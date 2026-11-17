class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :title, null:false
      t.string :description, null:false
      t.integer :category, null:false
      t.integer :status, null:false
      t.datetime :date_found, null:false
      t.references :facility, foreign_key: true, null:false

      t.timestamps
    end
  end
end
