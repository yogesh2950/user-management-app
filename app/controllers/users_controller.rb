class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token #this is to remove csrf token missing warning
  before_action :set_user, only: [:show, :update, :destroy]
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
      render json: @user.errors, status: :unprocessable_entity
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
    # @user = User.find(params[:id])

    if @user.update(user_params)
      render :update, status: :ok
    else
      render json: {message: "Error"}, status: :unprocessable_entity
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
     @user = User.find(params[:id])
    #  render json: @user 
  end

  def login_params
    params.require(:user).permit(:email, :password)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :mobile_no, :city)
  end

end
