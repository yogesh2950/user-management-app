# json.extract! @user, :id, :name, :email

json.partial! "users/user", user: @user
