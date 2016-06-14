class AddClientTypeToUser < ActiveRecord::Migration
  def change
    add_column :users, :client_type, :string, after: :user_id
  end
end
