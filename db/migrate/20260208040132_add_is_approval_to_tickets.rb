class AddIsApprovalToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :is_approval, :boolean, default: false
  end
end
