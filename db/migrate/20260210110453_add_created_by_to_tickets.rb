class AddCreatedByToTickets < ActiveRecord::Migration[8.1]
  def change
    # created_by user
    add_column :tickets, :created_by, :integer
    # assigned_to agent
    add_column :tickets, :assigned_to, :integer
  end
end
