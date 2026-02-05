require "test_helper"

class TicketsTest < ActionDispatch::IntegrationTest
  

  test "should create ticket" do
    post "/tickets.json", 
    params:{
      ticket: {
        title: "users model issue",
        description: "Users model has issue fix it",
        status: "open",
        priority: 1
      }
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

  test "should delete ticket" do
    delete "/tickets/1.json", 
    params:{}, 
    headers: { Authorization: "Bearer #{token}" }
    # pp response.body
    ticket_body = JSON.parse(response.body)
    # pp ticket_body
    assert_equal "Ticket deleted successfully", ticket_body['message']
  end
  
end
