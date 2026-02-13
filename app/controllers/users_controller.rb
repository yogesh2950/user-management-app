class UsersController < ApplicationController
  # skip_before_action :verify_authenticity_token # this is to remove csrf token missing warning
  before_action :set_user, only: [ :show, :update, :destroy ]
  before_action :check_valid_user, except: [:index, :create, :login, :assign_roles]
  skip_before_action :authorize_request, only: [ :create, :login ]

  def index
    if @current_user.role == "admin"
      @users = User.all
    else
      render json: { message: "You're not allowed for this operation" }, status: :forbidden
    end

    # result = IndexUser.new().call(@current_user)
    # # pp result
    # @users = result
    # if result[:success] 
    #   render json: @users, status: :ok
    # else
    #   render json: { message: "You're not allowed for this operation" }, status: :forbidden
    # end

  end


  # To change roles if admin exist
  def assign_roles
    return render json: { message: "You are not authorised!" }, status: :unauthorized if @current_user.role != "admin"
        
      @user = User.find_by(id: assign_roles_params[:id])

      unless @user.present?
        render json: { status: false, message: "User Not Found" }
        return
      end

      if @current_user.id == @user.id
        render json: { message: "Admin cannot change own role." }, status: :forbidden
        return
      end

      if @user.update( assign_roles_params )
        # render @user, status: :ok
        render json: @user, status: :ok
      else
        render json: { message: @user.errors.full_messages }, status: :unprocessable_entity
      end
      
    # else
    #   render json: { message: "You are not authorised!" }, status: :unauthorized
    # end    
  end


  def show
    render json: @user, status: :ok
    # @user = User.find(params[:id])
  end

  def create
    @user = User.new( user_params )

    # @user = User.new(user_params)
    # pp "=====user#{@user}==============="
    
    if @user.save
      render json: @user, status: :created
    else
      render json: { message: @user.errors.full_messages }, status: :unprocessable_entity
    end
    
    # result = CreateUser.new().call(user_params)
    # # pp result
    # if result[:success]
    #   render json: result, status: :created
    # else
    #   render json: {message: "User not created"}, status: :unprocessable_entity
    # end

  end

  def login
    user = User.find_by(email: login_params[:email])

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

    # In update don't pass deconstructed params, means explicitely pass params it will assign nil if we don't pass the values in it and updates it.
    if @user.update( update_user_params )
      # render @user, status: :ok
      render json: @user, status: :ok
    else
      render json: { message: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
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
    unless @user.is_active == true
      render json: { message: "User is deactivated", status: false}
      return
    end
  end

  def update_user_params
    params.permit(:name, :email, :mobile_no, :city, :password, :password_confirmation)
  end

  def login_params
    params.permit(:email, :password)
  end

  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :mobile_no, :city)
  end

  def check_valid_user
    # pp @current_user
    unless @current_user.id == @user.id
      render json: { message: "You are not authorized user." }, status: :forbidden
      return
    end
  end

  def assign_roles_params
    params.permit(:id, :role)
  end
end
