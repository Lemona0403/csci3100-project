class AddOnlyOnePendingClaimPerItem < ActiveRecord::Migration[7.1]
  def change
    add_index :claims, :item_id, unique: true, where: "status = 0", 
    name: "index_claims_one_pending_per_item"
  end
end
