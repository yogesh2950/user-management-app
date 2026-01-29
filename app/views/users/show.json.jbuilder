# json.array! @users do |user|
  # json.extract! @user, :id, :name, :email # extract multiple attributes at once
  # json.url user_url(user, format: :json) # add custom attributes/helpers
# end


# json @users, partial: 'users/user', as: :user
# json.users do
#   json.array! @users, partial: 'users/user', as: :user
# end

json.partial! 'users/user', as: :user