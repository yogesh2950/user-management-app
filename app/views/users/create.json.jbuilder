# json.extract! @user, :id, :name, :email
json.full_name @user.name
json.email_id @user.email

# json.(@user, :id, :name)