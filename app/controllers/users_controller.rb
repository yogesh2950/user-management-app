class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token #this is to remove csrf token missing warning
  before_action :set_user, only: [:show, :create, :destroy]
  skip_before_action :authorize_request, only: [:create, :login]

  def index
    @users = User.all
    # render :show
  end
  
  def show
    # @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors.full_messages, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: login_params[:email])

    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      # pp token
      render json:{
        message: "login successful",
        token: token
      }
    else
      render json:{
        message: "Invalid email or password"
      }, status: :unauthorized
    end
  end

  def update
    pp update_user_params
    @user = User.find_by(id: params[:id])
    unless @user.present?
      render json: {status: false, message: "User Not Found"}
    end
    # pp "xxxxxxxxxx"
    if @user.update(name: update_user_params[:name], email: update_user_params[:email], mobile_no: update_user_params[:mobile_no], city: update_user_params[:city])
      render :update, status: :ok
    else
      render json: {message: @user.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    # @user = User.find(params[:id])
    if @user.destroy
      render json: {message: "User deleted successfully"}, status: :ok
    else
      render json: {message: "Error"}, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    unless @user.present?
      render json: {status: false, message: "User Not Found"}
    end 
  end

  def update_user_params
    params.require(:user).permit(:name, :email, :mobile_no, :city)
  end

  def login_params
    params.require(:user).permit(:email, :password)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password_digest, :mobile_no, :city)
  end

end
