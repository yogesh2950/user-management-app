class TicketsController < ApplicationController
  skip_before_action :verify_authenticity_token # this is to remove csrf token missing warning
  before_action :set_ticket, only: [ :show, :destroy ]

  def index
    pp "Inside index++++++++++++++++++++++++++++++++++++++"
    if show_params[:status].present?
      @show_tickets = current_user.tickets.where(status: show_params[:status])
      render :index, status: :ok
    else
      pp "else_---------------------------------"
      @show_tickets = current_user.tickets.all
      render :index, status: :ok
    end
    # @tickets = Ticket.all
    # render json: current_user.tickets.all
  end

  def show
    # render json: @ticket
  end

  def create
    # pp @current_user
    @ticket = current_user.tickets.new(title: ticket_params[:title], description: ticket_params[:description], status: ticket_params[:status], priority: ticket_params[:priority])

    if @ticket.save
      render json: @ticket, status: :created
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @ticket = current_user.tickets.find_by(id: params[:id])
    unless @ticket.present?
      render json: { status: false, message: "Ticket Not Found" }
    end
    # pp "xxxxxxxxxx"
    if @ticket.update(title: update_ticket_params[:title], description: update_ticket_params[:description], status: update_ticket_params[:status], priority: update_ticket_params[:priority])
      # render :update, status: :ok
      render json: @ticket, status: :ok
    else
      render json: { message: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @ticket.destroy
      render json: { message: "Ticket deleted successfully" }, status: :ok
    else
      render json: { message: "Error" }, status: :unprocessable_entity
    end
  end


  private

  def set_ticket
    @ticket = current_user.tickets.find_by(id: params[:id])
    unless @ticket.present?
      render json: { status: false, message: "Ticket Not Found" }
    end
  end

  def update_ticket_params
    params.require(:ticket).permit(:title, :description, :status, :priority)
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description, :status, :priority, :user_id)
  end

  def show_params
    params.permit(:status)
  end
end
