class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token #this is to remove csrf token missing warning

  def index
    @users = User.all
    # render :show
  end
  
  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render :create, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity

    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      render json: {message: "User updated successfully"}, status: :ok
    else
      render json: {message: "Error"}, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      render json: {message: "User deleted successfully"}, status: :ok
    else
      render json: {message: "Error"}, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :mobile_no, :city)
  end

end
