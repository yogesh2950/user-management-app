# json.extract! @ticket, :id, :title, :description
# json.title @ticket.title
# json.status @status.status
json.partial! "tickets/ticket", ticket: @ticket
