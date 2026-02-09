ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "json"

module ActiveSupport
  class TestCase

    def set_user
      post "/login",
      params: { email: "user@gmail.com", password: "1234567" }
      # pp "Response body #{response.body}"
      # # pp response.body
      # # parsed_data = JSON.parse(response.body)
      # # pp parsed_data
      # # @token = response_body["token"]
      # # @token = JSON.parse(response.body)["token"]
      # # pp @token
      res = JSON.decode(response.body)
      # pp res
      assert_equal "login successful", res['message']
    end

    def set_admin
      post "/login",
      params: { email: "yogeshk@gmail.com", password: "1234567" }
      res = JSON.decode(response.body)
      assert_equal "login successful", res['message']
    end

    def token
      set_user
      # pp set_user
      token = JSON.decode(response.body)["token"]
    end

    def admin_token
      set_admin
      token = JSON.decode(response.body)["token"]
    end

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
