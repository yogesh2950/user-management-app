class ApplicationController < ActionController::Base
  # skip_before_action :verify_authenticity_token
  before_action :authorize_request

  private

  def authorize_request
    headers = request.headers['Authorization']
    token = headers.split(' ').last if headers

    decoded = JsonWebToken.decode(token)

    if decoded == :expired
      render json: {message: "Token expired"}, status: :unprocessable_entity
    elsif decoded.nil?
      render json: {message: "Invalid Token"}, status: :unauthorized
    else
      @current_user = User.find(decoded[:user_id])
      pp @current_user
    end
  end

end
