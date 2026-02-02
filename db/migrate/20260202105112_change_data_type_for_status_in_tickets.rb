class ChangeDataTypeForStatusInTickets < ActiveRecord::Migration[7.0]
  def up
    change_column :tickets, :status, :integer
  end

  def down
    change_column :tickets, :status, :string
  end
end
