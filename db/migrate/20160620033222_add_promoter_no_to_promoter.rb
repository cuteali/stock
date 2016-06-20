class AddPromoterNoToPromoter < ActiveRecord::Migration
  def change
    add_column :promoters, :promoter_no, :string, after: :id
    add_index :promoters, :promoter_no
  end
end
