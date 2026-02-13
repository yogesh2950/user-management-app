class ApplicationController < ActionController::API
  skip_before_action :verify_authenticity_token, raise: false
  before_action :authorize_request

  private

  def authorize_request
    headers = request.headers["Authorization"]
    token = headers.split(" ").last if headers

    decoded = JsonWebToken.decode(token)

    if decoded == :expired
      render json: { message: "Token expired" }, status: :unprocessable_entity
    elsif decoded.nil?
      render json: { message: "Token Not Found" }, status: :unauthorized
    else
      @current_user = User.find(decoded[:user_id])
      # pp @current_user
    end
  end

  def current_user
    @current_user
  end
end
