class AddPromoterIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :promoter_id, :integer, after: :rand
    add_index :users, :promoter_id
  end
end
