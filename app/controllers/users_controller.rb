class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token # this is to remove csrf token missing warning
  before_action :set_user, only: [ :show, :update, :destroy ]
  skip_before_action :authorize_request, only: [ :create, :login ]

  def index
    @users = User.all
    # render :show
  end

  def show
    # @user = User.find(params[:id])
  end

  def create
    @user = User.new(name: user_params[:name], email: user_params[:email], password: user_params[:password], password_confirmation: user_params[:password_confirmation], mobile_no: user_params[:mobile_no], city: user_params[:city])
    # @user = User.new(user_params)
    # pp "=====user#{@user}==============="
    if @user.save
      # pp @user
      render json: @user, status: :created
    else
      render json: {message: "Some Values are missing | Require all values"}, status: :unprocessable_entity
    end
  end

  def login
    # pp login_params
    user = User.find_by(email: login_params[:email])

    # pp"==========after user=" 
    # pp user
    # pp login_params[:password]
    if user&.authenticate(login_params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      # pp token
      render json: {
        message: "login successful",
        token: token
      }
    else
      render json: {
        message: "Invalid email or password"
      }, status: :unauthorized
    end
  end

  def update
    # @user = User.find_by(id: params[:id])
    if @user.update(name: update_user_params[:name], email: update_user_params[:email], mobile_no: update_user_params[:mobile_no], city: update_user_params[:city])
      # render @user, status: :ok
      render json: @user, status: :ok
    else
      render json: { message: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    # @user = User.find(params[:id])
    if @user.destroy
      render json: { message: "User deleted successfully" }, status: :ok
    else
      render json: { message: "Error" }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    unless @user.present?
      render json: { status: false, message: "User Not Found" }
    end
  end

  def update_user_params
    params.permit(:name, :email, :mobile_no, :city)
  end

  def login_params
    params.permit(:email, :password)
  end

  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :mobile_no, :city)
  end
end
