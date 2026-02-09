# app/views/users/index.json.jbuilder
# app/views/users/index.json.jbuilder
if @users.present?
  json.status true
  json.total_count @users.count
  json.users do
    json.array! @users, partial: "users/user", as: :user
  end
else
  json.status true
  json.total_count 0
  json.users []
end



# json.extract! user, :id, :name, :email, :created_at # extract multiple attributes at once
# json.url user_url(user, format: :json) # add custom attributes/helpers
# end
