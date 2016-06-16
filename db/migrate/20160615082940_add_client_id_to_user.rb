class AddClientIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :client_id, :string, after: :client_type
  end
end
