# app/views/users/index.json.jbuilder
if @show_tickets.present?
  json.status true
  json.total_count @show_tickets.count
  json.ticket do
    json.array! @show_tickets, partial: "tickets/ticket", as: :ticket
    # json.array! instanceVariableNameFromController, partial: "usersView/partialName", as: :localVariableName
  end
else
  json.status true
  json.total_count 0
  json.ticket []
end


# json.extract! user, :id, :name, :email, :created_at # extract multiple attributes at once
# json.url user_url(user, format: :json) # add custom attributes/helpers
# end
