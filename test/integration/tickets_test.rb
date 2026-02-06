require "test_helper"

class TicketsTest < ActionDispatch::IntegrationTest
  

  test "should create ticket" do
    post "/tickets.json", 
    params:{
        title: "users model issue",
        description: "Users model has issue fix it",
        status: "open",
        priority: 1
    }, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_equal "users model issue", ticket_body['title']
    assert_equal "Users model has issue fix it", ticket_body['description']
    assert_equal "open", ticket_body['status']
    assert_equal 1, ticket_body['priority']
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
    # pp response.body
    # ticket_body = JSON.parse(response.body)
    assert_response :unauthorized
  end

  test "should not create ticket without title" do
    post "/tickets.json",
    params: {
      description: "users model issue",
      status: "open",
      priority: 1
    },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    # ticket_body = JSON.parse(response.body)
    assert_response :unprocessable_entity
  end

  test "should not create ticket with invalid status" do
    post "/tickets.json",
    params: {
      title: "users model issue",
      description: "users model had isses",
      status: "new",
      priority: 1
    },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    # ticket_body = JSON.parse(response.body)
    assert_response :unprocessable_entity
  end

  test "should view all tickets" do
    get "/tickets.json", 
    params:{}, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    # assert_equal ticket_body['total_count']
    assert(ticket_body['total_count'] >= 1, "Expected total_count to be greater than 1")
  end
  
  test "should view ticket with status pending" do
    get "/tickets.json", 
    params:{
      "status": "pending"
    }, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    # assert_equal ticket_body['total_count']
    assert(ticket_body['total_count'] >= 1, "Expected total_count to be greater than 1")
  end
  
  test "should get empty list for not assigned status" do
    get "/tickets.json",
    params: { status: "closed" },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_equal 0, ticket_body["total_count"]
  end


  test "should view tickets by id" do
    get "/tickets/1.json", 
    params:{}, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    # assert_equal ticket_body['total_count']
    assert_equal "Ticket Controller had issues", ticket_body['title']
    assert_equal "Ticket Controller had some issues solve ASAP", ticket_body['description']
    assert_equal "pending", ticket_body['status']
    assert_equal 1, ticket_body['priority']
  end
  
  test "should update ticket" do
    patch "/tickets/1.json", 
    params:{
      title: "Tickets had issues",
      description: "Tickets has issues fix it",
      status: "on_hold",
      priority: 1
    }, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_equal "Tickets had issues", ticket_body['title']
    assert_equal "Tickets has issues fix it", ticket_body['description']
    assert_equal "on_hold", ticket_body['status']
    assert_equal 1, ticket_body['priority']
  end
  
  test "should not update ticket with empty params" do
    patch "/tickets/1.json",
    params: {},
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    # ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_response :unprocessable_entity
  end

  test "should not update ticket with invalid id" do
    patch "/tickets/4154.json",
    params: { title: "users model issue" },
    headers: { Authorization: "Bearer #{token}" }

    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_equal false, ticket_body["status"]
    assert_equal "Ticket Not Found", ticket_body["message"]
  end

  test "should delete ticket" do
    delete "/tickets/1.json", 
    params:{}, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_equal "Ticket deleted successfully", ticket_body['message']
  end
  
  test "should not delete ticket with invalid id" do
    delete "/tickets/4154.json",
    params:{},
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_equal false, ticket_body["status"]
    assert_equal "Ticket Not Found", ticket_body["message"]
  end

  test "should not delete another users ticket" do
    post "/tickets.json",
    params: {
      title: "users model issue",
      description: "users model had issues",
      status: "open",
      priority: 1
    },
    headers: { Authorization: "Bearer #{token}" }

    delete "/tickets/2.json",
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_equal false, ticket_body["status"]
    assert_equal "Ticket Not Found", ticket_body["message"]
  end


  test "should return empty list when no tickets exist" do
    Ticket.destroy_all
    get "/tickets.json",
    params: {},
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_equal 0, ticket_body["total_count"]
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
    # ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_response :unprocessable_entity
  end

  test "should ignore extra parameters during create" do
    post "/tickets.json",
    params: {
      title: "Tickets had issues",
      description: "Tickets had issues fix it",
      status: "open",
      priority: 1,
      author: "yogesh"
    },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_nil ticket_body["hacked"]
  end

  test "deleting ticket which already deleted should fail" do
    delete "/tickets/1.json",
    headers: { Authorization: "Bearer #{token}" }

    delete "/tickets/1.json",
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_equal false, ticket_body["status"]
  end

  test "should not create ticket with priority as in string format" do
    post "/tickets.json",
    params: {
      title: "Tickets had issues",
      description: "Tickets had issues fix it",
      status: "open",
      priority: "high"
    },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    assert_response :unprocessable_entity
  end

end
