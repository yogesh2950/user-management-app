# json.array! @users do |user|
# json.extract! @user, :id, :name, :email # extract multiple attributes at once
# json.url user_url(user, format: :json) # add custom attributes/helpers
# end


json.partial! "tickets/ticket", ticket: @ticket
