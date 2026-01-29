class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :password
      t.string :email
      t.integer :mobileNo
      t.string :city

      t.timestamps
    end
  end
end
