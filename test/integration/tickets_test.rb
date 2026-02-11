require "test_helper"

class TicketsTest < ActionDispatch::IntegrationTest
  

  test "should create ticket" do
    post "/tickets.json", 
    params:{
        title: "users model issue",
        description: "Users model has issue fix it",
        priority: "high"
    }, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal "users model issue", res['title']
    assert_equal "Users model has issue fix it", res['description']
    assert_equal "open", res['status'] #default
    assert_equal "high", res['priority']
    assert_response :created
  end

  test "should not create ticket without authorization" do
    post "/tickets.json", 
    params:{
        title: "users model issue",
        description: "Users model has issue fix it",
        status: "open",
        priority: 1
    },
    headers: {}
    res = JSON.parse(response.body)
    assert_equal "Token Not Found", res["message"]
    assert_response :unauthorized
  end

  test "should not create ticket without title" do
    post "/tickets.json",
    params: {
      description: "users model issue",
      status: "open",
      priority: "high"
    },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    assert_response :unprocessable_entity
    assert_equal ["Title can't be blank"], res["message"]
  end

  # test "should not create ticket with invalid status" do
  #   post "/tickets.json",
  #   params: {
  #     title: "users model issue",
  #     description: "users model had isses",
  #     status: "resolved",
  #     priority: 1
  #   },
  #   headers: { Authorization: "Bearer #{token}" }
  #   pp response.body
  #   # res = JSON.parse(response.body)
  #   # assert_response :unprocessable_entity
  # end

  test "should view all tickets" do
    get "/tickets.json", 
    params:{}, 
    headers: { Authorization: "Bearer #{admin_token}" }
    pp response.body
    res = JSON.parse(response.body)
    pp res
    assert_equal true, res["status"]
    # assert_equal ticket_body['total_count']
    assert(res['total_count'] >= 1, "Expected total_count to be greater than 1")
    assert_response :ok
  end
  
  test "should view ticket with status pending" do
    get "/tickets.json", 
    params:{
      "status": "pending"
    }, 
    headers: { Authorization: "Bearer #{admin_token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    # assert_equal res['total_count']
    assert_equal true, res["status"]
    # assert(res['total_count'] >= 1, "Expected total_count to be greater than 1")
  end
  
  test "should get empty list for not assigned status" do
    get "/tickets.json",
    params: { status: "closed" },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal true, res["status"]
    assert_equal 0, res["total_count"]
  end


  test "should view tickets by id" do
    get "/tickets/specific.json", 
    params:{ id: 1 }, 
    headers: { Authorization: "Bearer #{admin_token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    # assert_equal res['total_count']
    assert_equal 1, res["id"]
    assert_equal "Ticket Controller had issues", res["title"]
    assert_equal "Ticket Controller had some issues solve ASAP", res["description"]
    assert_equal "open", res["status"]
    assert_equal "high", res["priority"]
  end
  
  test "should update ticket" do
    patch "/tickets.json", 
    params:{
      id: 1,
      status: "closed"
    }, 
    headers: { Authorization: "Bearer #{admin_token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal 1, res["id"]
    assert_equal "closed", res["status"]
    assert_response :ok
  end
  
  test "should not update ticket with empty params" do
    patch "/tickets.json",
    params: { id: 1 },
    headers: { Authorization: "Bearer #{token}" }
    pp response.body
    res = JSON.parse(response.body)
    pp res
    assert_equal ["Title can't be blank", "Priority can't be blank"], res["message"]
    assert_response :unprocessable_entity
  end

  test "should not update ticket with invalid id" do
    patch "/tickets.json",
    params:
    {
      id: 2,
      title: "users model issue",
      description: "Users model has issue fix it",
      priority: 1
    },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal false, res["status"]
    assert_equal "Ticket Not Found", res["message"]
  end

  test "should delete ticket" do
    delete "/tickets.json", 
    params:{ id: 1 }, 
    headers: { Authorization: "Bearer #{admin_token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal "Ticket deleted successfully", res['message']
    assert_response :ok
  end
  
  test "should not delete ticket with invalid id" do
    delete "/tickets.json",
    params:{ id: 4154 },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal false, res["status"]
    assert_equal "Ticket Not Found", res["message"]
    assert_response :unprocessable_entity
  end

  # test "should not delete another users ticket" do
  #   post "/tickets.json",
  #   params: {
  #     title: "users model issue",
  #     description: "users model had issues",
  #     status: "open",
  #     priority: 1
  #   },
  #   headers: { Authorization: "Bearer #{token}" }
  #   pp "=="
  #   delete "/tickets/1.json",
  #   headers: { Authorization: "Bearer #{token}" }
  #   # pp response.body
  #   ticket_body = JSON.parse(response.body)
  #   pp ticket_body
  #   assert_equal false, ticket_body["status"]
  #   assert_equal "Ticket Not Found", ticket_body["message"]
  #   assert_response :ok
  # end


  test "should return empty list when no tickets exist" do
    Ticket.destroy_all
    get "/tickets.json",
    params: {},
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal true, res["status"]
    assert_equal 0, res["total_count"]
    assert_response :ok
  end

  test "should not create ticket without priority" do
    post "/tickets.json",
    params: {
      title: "Tickets had issues",
      description: "Tickets had issues fix it",
      status: "open"
    },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal ["Priority can't be blank"], res["message"]
    assert_response :unprocessable_entity
  end

  test "should ignore extra parameters during create" do
    post "/tickets.json",
    params: {
      title: "Tickets had issues",
      description: "Tickets had issues fix it",
      status: "open",
      priority: "high",
      author: "yogesh"
    },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_nil res["hacked"]
    assert_response :created
  end

  test "deleting ticket which already deleted should fail" do
    delete "/tickets.json",
    params: { id: 1},
    headers: { Authorization: "Bearer #{token}" }
    delete "/tickets.json",
    params: { id: 1},
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res 
    assert_equal false, res["status"]
    assert_equal "Ticket Not Found", res["message"]
  end

  # Check
  # test "should not create ticket with priority as in string format" do
  #   post "/tickets.json",
  #   params: {
  #     title: "Tickets had issues",
  #     description: "Tickets had issues fix it",
  #     status: "open",
  #     priority: "Low"
  #   },
  #   headers: { Authorization: "Bearer #{token}" }
  #   pp response.body
  #   assert_response :created
  # end

  # Check
  # test "should create ticket with default status" do
  #   post "/tickets.json",
  #   params:{
  #       title: "users model issue",
  #       description: "Users model has issue fix it",
  #       status: ,
  #       priority: 1
  #   }, 
  #   headers: { Authorization: "Bearer #{token}" }
  #   # pp response.body
  #   res = JSON.parse(response.body)
  #   pp res
  #   assert_equal "users model issue", res['title']
  #   assert_equal "Users model has issue fix it", res['description']
  #   # assert_equal "open", res['status']
  #   assert_equal 1, res['priority']
  #   assert_response :created
  # end

end

# 66, 140