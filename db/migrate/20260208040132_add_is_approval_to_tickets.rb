class AddIsApprovalToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :is_approval_required, :boolean, default: false
    add_column :tickets, :is_assigned, :boolean, default: false
    # add_reference :tickets, :agent_id, :integer, foreign_key: { to_table: :users }
  end
end
