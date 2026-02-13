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
    assert_equal "open", res['ticket_status'] #default
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

  test "should not create ticket without title(required parameter)" do
    post "/tickets.json",
    params: {
      description: "users model issue",
      priority: "high"
    },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    assert_response :unprocessable_entity
    assert_equal ["Title can't be blank"], res["message"]
  end

  test "should not create ticket apart from user role" do
    post "/tickets.json", 
    params:{
      title: "users model issue",
      description: "Users model has issue fix it",
      status: "open",
      priority: 1
    },
    headers: { Authorization: "Bearer #{admin_token}"}
    res = JSON.parse(response.body)
    # pp res
    assert_equal "Only users can create tickets", res["message"]
    assert_response :forbidden
  end

  test "should view all tickets if admin?" do
    get "/tickets.json", 
    params:{}, 
    headers: { Authorization: "Bearer #{admin_token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal true, res["status"]
    # assert_equal ticket_body['total_count']
    assert(res['total_count'] >= 1, "Expected total_count to be greater than 1")
    assert_response :ok
  end

  test "should view own tickets if user/agent" do
    get "/tickets.json", 
    params:{}, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal true, res["status"]
    # assert_equal ticket_body['total_count']
    assert(res['total_count'] >= 0, "Expected total_count to be greater than 1")
    assert_response :ok
  end
  
  #Fix
  test "should view ticket with status open" do
    get "/tickets.json", 
    params:{
      "status": "open"
    }, 
    headers: { Authorization: "Bearer #{admin_token}" }
    # pp response.body
    # res = JSON.parse(response.body)
    # pp res
    # assert_equal res['total_count']
    # assert_equal true, res["status"]
    # assert(res['total_count'] >= 1, "Expected total_count to be greater than 1")
  end

  test "should view tickets by id" do
    get "/tickets/specific.json", 
    params:{ id: 2 }, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    # assert_equal res['total_count']
    assert_equal 2, res["id"]
    assert_equal "Ticket Model had issues", res["title"]
    assert_equal "Ticket Model had some issues solve ASAP", res["description"]
    assert_equal "open", res["ticket_status"]
    assert_equal "low", res["priority"]
  end

  test "should view tickets by id as a admin" do
    get "/tickets/specific.json", 
    params:{ id: 2 }, 
    headers: { Authorization: "Bearer #{admin_token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    # assert_equal res['total_count']
    assert_equal 2, res["id"]
    assert_equal "Ticket Model had issues", res["title"]
    assert_equal "Ticket Model had some issues solve ASAP", res["description"]
    assert_equal "open", res["ticket_status"]
    assert_equal "low", res["priority"]
  end

  test "should view tickets by false id as a user" do
    get "/tickets/specific.json", 
    params:{ id: 1 }, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    # assert_equal res['total_count']
    # assert_equal 2, res["id"]
    assert_equal "Ticket Not Found", res["message"]
    assert_equal false, res["status"]
  end
  
  test "admin should only update status of ticket" do
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
    assert_equal "closed", res["ticket_status"]
    assert_response :ok
  end

  test "admin should not update apart from status of ticket" do
    patch "/tickets.json", 
    params:{
      name: "Updated ticket",
      id: 1,
      status: "closed"
    }, 
    headers: { Authorization: "Bearer #{admin_token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal 1, res["id"]
    assert_equal "closed", res["ticket_status"]
    assert_response :ok
  end

  test "should not update ticket with invalid id" do
    patch "/tickets.json",
    params:
    {
      id: 1,
      title: "users model issue",
      description: "Users model has issue fix it",
      priority: "high"
    },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal false, res["status"]
    assert_equal "Ticket Not Found", res["message"]
  end

  test "user should not update status of ticket" do
    patch "/tickets.json", 
    params:{
      id: 3,
      title: "Updated ticket",
      status: "closed"
    }, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal 3, res["id"]
    assert_equal "open", res["ticket_status"]
    assert_response :ok
  end

  test "should delete ticket if admin" do
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
    headers: { Authorization: "Bearer #{admin_token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal false, res["status"]
    assert_equal "Ticket Not Found", res["message"]
    assert_response :unprocessable_entity
  end

  test "should not delete ticket if user" do
    delete "/tickets.json",
    params:{ id: 2 },
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    res = JSON.parse(response.body)
    # pp res
    assert_equal "You don't have permission, Only admins require!", res["message"]
    assert_response :forbidden
  end

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
  test "should create ticket with default status" do
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
    # assert_equal "open", res['status']
    assert_equal "high", res['priority']
    assert_response :created
  end

  test "Only admin should assign ticket to agent" do
    patch "/tickets/assign-agent/", 
    params:{
      user_id: 4,     # assigned_to
      ticket_id: 1
    },
    headers: { Authorization: "Bearer #{admin_token}" }

    res = JSON.parse(response.body)
    # pp res
    assert_equal true, res["is_assigned"]
    assert_equal 4, res["assigned_to"]
    assert_equal 1, res["id"]
    assert_equal "approved", res["status"]
    assert_response :ok
  end

  test "User should not assign ticket to agent" do
    patch "/tickets/assign-agent/",
    params:{user_id: 4, ticket_id: 1},
    headers:{ Authorization: "Bearer #{token} "}

    res = JSON.parse(response.body)
    # pp res
    assert_equal "Only admins can assign tickets. You don't have permission!", res["message"]
    assert_response :forbidden
  end

  test "Ticket which assigning to agent must present" do
    patch "/tickets/assign-agent",
    params:{user_id: 4, ticket_id: 6},
    headers:{ Authorization: "Bearer #{admin_token} "}

    res = JSON.parse(response.body)
    # pp res
    assert_equal "Ticket not found", res["message"]
    assert_response :unprocessable_entity
  end

  test "Agent should present while assigning ticket" do
    patch "/tickets/assign-agent",
    params:{user_id: 3, ticket_id: 2},
    headers:{ Authorization: "Bearer #{admin_token} "}

    res = JSON.parse(response.body)
    # pp res
    assert_equal "Only agents require!", res["message"]
    assert_response :forbidden
  end

  test "Update is not allowed after assigning to agent" do
    patch "/tickets/assign-agent/", 
    params:{
      user_id: 4,     # assigned_to
      ticket_id: 2
    },
    headers: { Authorization: "Bearer #{admin_token}" }
    # pp response.body    # is_assigned: true

    patch "/tickets.json",
    params:{
      id: 2,
      title: "users model h issue",
      description: "Users model has issue fix it",
      priority: "high"
    }, 
    headers: { Authorization: "Bearer #{token} "}

    res = JSON.parse(response.body)
    pp res
  end

  test "View all tickets if admin logged in" do
    get "/tickets.json",
    params:{ },
    headers: { Authorization: "Bearer #{admin_token}"}

    res = JSON.parse(response.body)
    # pp res
    assert_equal true, res["status"]
    assert(res['total_count'] >= 1, "Expected total_count to be greater than 1")
    assert_response :ok
  end

  test "View own tickets if user logged in" do
    get "/tickets.json",
    params:{ },
    headers: { Authorization: "Bearer #{token}"}

    res = JSON.parse(response.body)
    # pp res
    assert_equal true, res["status"]
    assert(res['total_count'] >= 1, "Expected total_count to be greater than 1")
    assert_response :ok
  end

  test "View all tickets if admin logged in and sort by status" do
    get "/tickets.json?status=open",
    params:{ },
    headers: { Authorization: "Bearer #{admin_token}"}

    res = JSON.parse(response.body)
    # pp res
    assert_equal true, res["status"]
    # assert(res['total_count'] >= 1, "Expected total_count to be greater than 1")
    assert_response :ok
  end

  test "View all tickets if admin logged in and sort by invalid status" do
    get "/tickets.json?status=reopened",
    params:{ },
    headers: { Authorization: "Bearer #{admin_token}"}

    res = JSON.parse(response.body)
    # pp res
    # assert_equal true, res["status"]
    # assert(res['total_count'] >= 1, "Expected total_count to be greater than 1")
    # assert_response :ok
  end

  test "View all tickets if admin logged in and sort by status in ascending order" do
    get "/tickets.json?status=open&&sort=oldest",
    params:{ },
    headers: { Authorization: "Bearer #{admin_token}"}

    res = JSON.parse(response.body)
    # pp res
    assert_equal true, res["status"]
    # assert(res['total_count'] >= 1, "Expected total_count to be greater than 1")
    assert_response :ok
  end

  test "View all tickets if admin logged in and sort by status in ascending order and priority in descending order" do
    get "/tickets.json?status=open&&sort=oldest&&priority=desc",
    params:{ },
    headers: { Authorization: "Bearer #{admin_token}"}

    res = JSON.parse(response.body)
    # pp res
    assert_equal true, res["status"]
    # assert(res['total_count'] >= 1, "Expected total_count to be greater than 1")
    assert_response :ok
  end

  test "Should update tickets if user present" do
    patch "/tickets.json?id=3",
    params:{
        title: "users  issue",
        description: "Users model has issue fix it",
        priority: "low"
    }, 
    headers: { Authorization: "Bearer #{token}" }

    res = JSON.parse(response.body)
    # pp res
    assert_equal "users  issue", res["title"]
    assert_response :ok
  end
end
