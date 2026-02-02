class TicketsController < ApplicationController
  skip_before_action :verify_authenticity_token #this is to remove csrf token missing warning
  before_action :set_ticket, only: [:show, :destroy]

  def index
    # @tickets = Ticket.all
    render json: Ticket.all
  end
  
  def show
    render json: @ticket
  end

  def create
    @ticket = Ticket.new(ticket_params)

    if @ticket.save
      render json: @ticket, status: :created
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @ticket = Ticket.find_by(id: params[:id])
    unless @ticket.present?
      render json: {status: false, message: "User Not Found"}
    end
    # pp "xxxxxxxxxx"
    if @ticket.update(name: update_user_params[:name], email: update_user_params[:email], mobile_no: update_user_params[:mobile_no], city: update_user_params[:city])
      render :update, status: :ok
    else
      render json: {message: @ticket.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    if @ticket.destroy
      render json: {message: "User deleted successfully"}, status: :ok
    else
      render json: {message: "Error"}, status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find_by(id: params[:id])
    unless @ticket.present?
      render json: {status: false, message: "Ticket Not Found"}
    end 
  end

  def update_ticket_params
    params.require(:ticket).permit(:title, :description, :status, :priority)
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description, :status, :priority, :user_id)
  end
end
