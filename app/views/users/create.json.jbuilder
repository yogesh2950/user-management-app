# json.extract! @user, :id, :name, :email
# json.full_name @user.name
# json.email_id @user.email

json.partial! "users/user", user: @user
