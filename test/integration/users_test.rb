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
    res = JSON.parse(response.body)
    assert_equal "yogesh", res['name']
    assert_equal "yogeshmm1@gmail.com", res['email']
    # assert_equal "1234567", res['password_digest']  # stored digested Password Not the integer 
    assert_equal "3456789013", res['mobile_no']
    assert_equal "pune", res['city']
    assert_response :created
  end

  test "should get all users" do
    get "/users.json", headers: { Authorization: "Bearer #{token}" }
    # pp token
    parsed_body = JSON.parse(response.body)
    res = JSON.parse(response.body)["users"]
    # pp parsed_body
    # pp res
    assert_equal true, parsed_body["status"]
    assert_equal 1, res[0]['id']
    assert_equal "yogesh sutar", res[0]['full_name']
    assert_equal "yogeshk@gmail.com", res[0]['email_id']
    assert_equal "9876543210", res[0]['mobile_no']
  end

  test "should get user by id" do 
    get "/users/1.json", params: {}, headers: { Authorization: "Bearer #{token}"}
    res = JSON.parse(response.body)
    # pp res
    assert_equal 1, res['id']
    assert_equal "yogesh sutar", res['full_name']
    assert_equal "yogeshk@gmail.com", res['email_id']
    # assert_equal "1234567", res['password_digest']
    assert_equal "9876543210", res['mobile_no']
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
    res = JSON.parse(response.body)
    # pp res
    assert_equal "yogesh sutar", res['name']
    assert_equal "yogeshk@gmail.com", res['email']
    assert_equal "3455689404", res['mobile_no']
    assert_equal "pune", res['city']
    assert_response :ok
  end

  test "should delete the user by id" do 
    delete "/users/1.json", 
    params: {}, 
    headers: { Authorization: "Bearer #{token}"}
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal "User deleted successfully", res['message']
    assert_response :ok
  end

  test "should create user without parameters" do 
    post "/users.json", 
    params: {}, 
    headers: { Authorization: "Bearer #{token}"}
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal ["Password can't be blank",
      "Name can't be blank",
      "Password is too short (minimum is 6 characters)",
      "Email is invalid",
      "Email can't be blank",
      "Mobile no can't be blank",
      "Mobile no is too short (minimum is 10 characters)"], res['message']
    assert_response :unprocessable_entity
  end

  test "should not login user without password" do 
    post "/login.json", 
    params: { email: "yogeshk@gmail.com" } 
    # headers: { Authorization: "Bearer #{token}"}
    # pp response.body
    res = JSON.parse(response.body)
    assert_response :unauthorized
    assert_equal "Invalid email or password", res['message']
  end

  test "should not login user with invalid email" do
    post "/login.json", params: {
      email: "yogeshgmail.com", password: "1234567"
    }
    # headers: { Authorization: "Bearer #{token}"}
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_response :unauthorized
    assert_equal "Invalid email or password", res['message']
  end

  test "should not login user without login_params" do
    post "/login.json", params: {}
    # headers: { Authorization: "Bearer #{token}"}
    
    # pp response.body
    res = JSON.parse(response.body)
    assert_response :unauthorized
    assert_equal "Invalid email or password", res['message']
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
    res = JSON.parse(response.body)
    # pp res
    assert_equal ["Email has already been taken"], res["message"]
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
    res = JSON.parse(response.body)
    # pp res
    assert_equal ["Email has already been taken", "Mobile no can't be blank", "Mobile no is too short (minimum is 10 characters)"], res["message"]
    assert_response :unprocessable_entity
  end

  test "should not get all users without token" do
    get "/users.json", params: {}
    # headers: { Authorization: "Bearer #{token}"}
    res = JSON.parse(response.body)
    # pp response.body
    assert_equal "Token Not Found", res["message"]
    assert_response :unauthorized
  end

  test "should print user not found for invalid user_id" do
    get "/users/154.json", 
    params: {},
    headers: { Authorization: "Bearer #{token}" }
    res = JSON.parse(response.body)
    assert_equal false, res["status"]
    assert_equal "User Not Found", res["message"]
  end

  test "token should not be nil after successful login" do
    post "/login",
    params: { email: "yogeshk@gmail.com", password: "1234567" }
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
    res = JSON.parse(response.body)
    # pp res
    assert_equal "Token Not Found", res["message"]
    assert_response :unauthorized
  end

  test "should get all users with invalid token" do
    get "/users.json", headers: { Authorization: "Bearer #{"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo5OTksInRlbXBvcmFyeXRlc3RpbmciOiJoZWxsbyJ9.b_kAhcLSGeV_cs84xS6KAbczNB_he24QESNcWEqecAQ"}" }
    # pp token
    res = JSON.parse(response.body)
    # res = JSON.parse(response.body)["users"]
    # pp parsed_body
    # pp res
    assert_equal "Token Not Found", res["message"]
    assert_nil res["users"]
  end
end
