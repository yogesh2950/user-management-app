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


  test "should login user" do
    # pp "=======#{set_user}=============="
    # set_user
    # @token = JSON.parse(response.body)['token']
    # pp @token
    # pp token
    set_user 
    assert_not_nil token
  end

  test "should create user" do
    post "/users", 
    params:{
          name: "yogesh",
          email: "yogeshmm1@gmail.com",
          password: "1234567",
          password_confirmation: "1234567",
          mobile_no: 3456789013,
          city: "pune"
      }
    users = JSON.parse(response.body)
    assert_equal "yogesh", users['name']
    assert_equal "yogeshmm1@gmail.com", users['email']
    # assert_equal "1234567", users['password_digest']
    assert_equal "3456789013", users['mobile_no']
    assert_equal "pune", users['city']

  end

  test "should get all users" do
    get "/users.json", headers: { Authorization: "Bearer #{token}" }
    # pp token
    parsed_body = JSON.parse(response.body)
    users = JSON.parse(response.body)["users"]
    # pp parsed_body
    # pp users
    assert_equal 1, users[0]['id']
    assert_equal "yogesh sutar", users[0]['full_name']
    assert_equal "yogeshk@gmail.com", users[0]['email_id']
    assert_equal "9876543210", users[0]['mobile_no']
  end

  test "should get user by id" do 
    get "/users/1.json", params: {}, headers: { Authorization: "Bearer #{token}"}

    users = JSON.parse(response.body)
    # pp users
    assert_equal "yogesh sutar", users['full_name']
    assert_equal "yogeshk@gmail.com", users['email_id']
    # assert_equal "1234567", users['password_digest']
    assert_equal "9876543210", users['mobile_no']
    # assert_equal "pune", users['city']
  end

  test "should update the user by id" do 
    patch "/users/1", params: {
        name: "yogesh sutar",
        email: "yogeshk@gmail.com",
        mobile_no: 3455689404,
        city: "pune"
    }, 
    headers: { Authorization: "Bearer #{token}"}
    
    # pp response.body
    users = JSON.parse(response.body)
    # pp users
    assert_equal "yogesh sutar", users['name']
    assert_equal "yogeshk@gmail.com", users['email']
    assert_equal "3455689404", users['mobile_no']
    assert_equal "pune", users['city']
  end

  test "should delete the user by id" do 
    delete "/users/1.json", 
    params: {}, 
    headers: { Authorization: "Bearer #{token}"}
    
    users = JSON.parse(response.body)
    assert_equal "User deleted successfully", users['message']
  end

  test "should create user without parameters" do 
    post "/users.json", 
    params: {}, 
    headers: { Authorization: "Bearer #{token}"}
    
    # pp response.body
    # users = JSON.parse(response.body)
    # assert_equal "User deleted successfully", users['message']
    assert_response :unprocessable_entity
  end

  test "should not login user without password" do 
    post "/login.json", 
    params: { email: "yogeshk@gmail.com" } 
    # headers: { Authorization: "Bearer #{token}"}
    
    # pp response.body
    users = JSON.parse(response.body)
    assert_equal "Invalid email or password", users['message']
    assert_response :unauthorized
  end

  test "should not login user with invalid email" do
    post "/login.json", params: {
      email: "yogeshgmail.com", password: "1234567"
    }
    # headers: { Authorization: "Bearer #{token}"}
    
    # pp response.body
    users = JSON.parse(response.body)
    assert_equal "Invalid email or password", users['message']
    assert_response :unauthorized
  end

  test "should not login user without login_params" do
    post "/login.json", params: {}
    # headers: { Authorization: "Bearer #{token}"}
    
    # pp response.body
    users = JSON.parse(response.body)
    assert_equal "Invalid email or password", users['message']
    assert_response :unauthorized
  end

  test "should not create user with duplicate email" do
    post "/users.json", params: {
      name: "yogesh sutar",
      email: "yogeshk@gmail.com",
      password: "1234567",
      password_confirmation: "1234567",
      mobile_no: "9876543210",
      city: "pune"
    }
    # headers: { Authorization: "Bearer #{token}"}

    users = JSON.parse(response.body)
    assert_equal "Some Values are missing | Require all values", users["message"]
    assert_response :unprocessable_entity
  end

  test "should not create user without mobile_no" do
    post "/users.json", params: {
      name: "yogesh sutar",
      email: "yogeshk@gmail.com",
      password: "1234567",
      password_confirmation: "1234567",
      mobile_no: "",
      city: "pune"
    }
    # headers: { Authorization: "Bearer #{token}"}

    users = JSON.parse(response.body)
    assert_equal "Some Values are missing | Require all values", users["message"]
    assert_response :unprocessable_entity
  end

  test "should not get all users without token" do
    get "/users.json", params: {},
    # headers: { Authorization: "Bearer #{token}"}

    # users = JSON.parse(response.body)

    assert_response :unauthorized
  end

  test "should print user not found for invalid user_id" do
    get "/users/154.json", params: {},
    headers: { Authorization: "Bearer #{token}" }

    users = JSON.parse(response.body)

    assert_equal false, users["status"]
    assert_equal "User Not Found", users["message"]
  end

  test "token should not be nil after successful login" do
    post "/login",
    params: { email: "yogeshk@gmail.com", password: "1234567" }
    # pp "Response body #{response.body}"
    # # pp response.body
    # # parsed_data = JSON.parse(response.body)
    # # pp parsed_data
    # # @token = response_body["token"]
    # # @token = JSON.parse(response.body)["token"]
    # # pp @token

    token = JSON.parse(response.body)["token"]

    assert_not_nil token
  end

  test "should not access deleted user" do
    delete "/users/1.json", params:{},
    headers: { Authorization: "Bearer #{token}" }

    # pp response.body

    get "/users/1.json", params:{},
    headers: { Authorization: "Bearer #{token}" }

    # pp response.body
    users = JSON.parse(response.body)

    assert_equal "User Not Found", users["message"]
    assert_equal false, users["status"]
  end

  # get all invalid token
end
