class AddPromoterIdToMember < ActiveRecord::Migration
  def change
    add_column :members, :promoter_id, :integer
    add_index :members, :promoter_id
  end
end
