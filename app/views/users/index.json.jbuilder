# app/views/users/index.json.jbuilder

json.users do
  json.array! @users, partial: 'users/user', as: :user
  # json.array! instanceVariableNameFromController, partial: "usersView/partialName", as: :localVariableName
end


  # json.extract! user, :id, :name, :email, :created_at # extract multiple attributes at once
  # json.url user_url(user, format: :json) # add custom attributes/helpers
# end
