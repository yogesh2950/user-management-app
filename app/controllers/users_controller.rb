class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token # this is to remove csrf token missing warning
  before_action :set_user, only: [ :show, :update, :destroy ]
  before_action :check_valid_user, except: [:index, :create, :login]
  skip_before_action :authorize_request, only: [ :create, :login ]

  def index
    if current_user.role == "admin"
      @users = User.all
    else
      render json: { message: "You're not allowed for this operation" }, status: :forbidden
    end
    # render :show
  end

  def show
    # @user = User.find(params[:id])
  end

  def create
    @user = User.new(name: user_params[:name], email: user_params[:email], 
    password: user_params[:password], password_confirmation: user_params[:password_confirmation], 
    mobile_no: user_params[:mobile_no], city: user_params[:city], 
    is_active: user_params[:is_active] || true, role: user_params[:role] || "user")

    # @user = User.new(user_params)
    # pp "=====user#{@user}==============="
    if @user.save
      # pp @user
      render json: @user, status: :created
    else
      render json: { message: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    # pp login_params

    user = User.find_by(email: login_params[:email])
    # pp"==========after user=" 
    # pp user

    unless user.present?
      render json: { message: "Invalid email or password" }, status: :unauthorized
      return
    end

    # Check if in_active user tries to login
    # pp user.is_active
    if user.is_active == false 
      render json: {
        message: "Your account has been deactivated. Please contact admin."
      }, status: :forbidden
      return
    end

    # pp login_params[:password]

    if user&.authenticate(login_params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      # pp token
      render json: {
        message: "login successful",
        token: token
      }, status: :ok
    else
      render json: {
        message: "Invalid email or password"
      }, status: :unauthorized
    end
  end

  def update
    # @user = User.find_by(id: params[:id])

    # Temporarily stored is_active should remove later.
    if @user.update(name: update_user_params[:name], email: update_user_params[:email], 
      mobile_no: update_user_params[:mobile_no], city: update_user_params[:city], )
      # render @user, status: :ok
      render json: @user, status: :ok
    else
      render json: { message: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    # pp @user

    if @user.role == "admin"
      render json: { message: "You cannot deactivate an administrator account." },
      status: :forbidden
      return
    end

    if @user.is_active
      @user.update(is_active: false)
      render json: { message: "User deactivated successfully." }, status: :ok
    else
      render json: { message: "User is already inactive." }, status: :unprocessable_entity
    end
  end


  private

  def set_user
    @user = User.find_by(id: params[:id])
    unless @user.present?
      render json: { status: false, message: "User Not Found" }
      return
    end
  end

  def update_user_params
    params.permit(:name, :email, :mobile_no, :city, :is_active)
  end

  def login_params
    params.permit(:email, :password)
  end

  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :mobile_no, :city, :is_active, :role)
  end

  def check_valid_user
    # pp current_user
    unless current_user.id == @user.id
      render json: { message: "You are not authorized user." }, status: :forbidden
      return
    end
  end
end
