# json.extract! @ticket, :title, :description, :status, :priority, :user_id

json.partial! "tickets/ticket", ticket: @ticket
