class RenamemobilNoTomobileNumberInusers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :mobileNo, :mobile_no
    change_column :users, :mobile_no, :string
  end
end
