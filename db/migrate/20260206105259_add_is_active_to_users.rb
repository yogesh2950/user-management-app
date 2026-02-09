class AddIsActiveToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :is_active, :boolean, default: true
    add_column :users, :role, :string, default: "user"
  end
end
