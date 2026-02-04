require "test_helper"

class UsersTest < ActionDispatch::IntegrationTest

  # setup do
  #   @user = users(:user_1)
  #   pp @user
  #   @user.password = '1234567'
  #   @user.save
  # end

  # test "should login user" do
  #   pp @user.email
    # post "/login", params: { email: @user.email, password: "1234567" }
    
  #   assert_response :success
  #   pp JSON.parse(response.body)
  # end
  

  # test "should get index" do
  #   get '/users'
  #   assert_response :success
  # end


  test "should login user" do
    pp "=======#{set_user}=============="
    # set_user
  end

  test "should create user" do
    post "/users", params:{
          name: "yogesh",
          email: "yogeshmm1@gmail.com",
          password: "1234567",
          password_confirmation: "1234567",
          mobile_no: 3456789013,
          city: "pune"
      }
  end

  test "should get user" do
    get "/users", headers: { Authorization: "Bearer #{set_user}" }
  end

end
