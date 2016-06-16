class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :user
      t.integer :messageable_id
      t.string :messageable_type
      t.string :title
      t.string :info
      t.integer :is_new, limit: 1, null: false, default: 0
      t.integer :status, limit: 1, null: false, default: 0

      t.timestamps null: false
    end
    add_index :messages, :user_id
    add_index :messages, [:messageable_id, :messageable_type], name: 'messageable_index'
  end
end
