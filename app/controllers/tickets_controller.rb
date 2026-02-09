class TicketsController < ApplicationController
  skip_before_action :verify_authenticity_token # this is to remove csrf token missing warning
  before_action :set_ticket, only: [ :show, :destroy, :update ]

  def index
    if show_params[:status].present?
      @show_tickets = current_user.tickets.where(status: show_params[:status])
      render :index, status: :ok
      return
    end
    if current_user.role == "admin"
      # pp "admin"
      @tickets = Ticket.all
      # pp @tickets
      render :index, status: :ok
    elsif current_user.role == "user"
      # pp "else_---------------------------------"
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
    # only users can create ticket admins are assigning it to agents
    if current_user.role != "user"
      render json: { message: "Only users can create tickets" }, status: :forbidden
      return
    end
    @ticket = current_user.tickets.new(
      title: ticket_params[:title], 
      description: ticket_params[:description], 
      priority: ticket_params[:priority]
    )
    if @ticket.save
      render ticket: @ticket, status: :created
    else
      # pp "====="
      render json: {message: @ticket.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update

    # if current_user.role == "admin"
    if @ticket.update(title: update_ticket_params[:title],
      description: update_ticket_params[:description], 
      status: update_ticket_params[:status], 
      priority: update_ticket_params[:priority])
      render ticket: @ticket, status: :ok
    else
      # pp ""
      # render json: { message: "Ticket not found"}, status: :unprocessable_entity
      render json: { message: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @ticket.destroy
      render json: { message: "Ticket deleted successfully" }, status: :ok
    else
      render json: { message: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = current_user.tickets.find_by(id: params[:id])
    unless @ticket.present?
      render json: { status: false, message: "Ticket Not Found" }, status: :unprocessable_entity
      return
    end
  end

  def update_ticket_params
    params.permit(:title, :description, :status, :priority)
  end

  def ticket_params
    params.permit(:title, :description, :priority)
  end

  def show_params
    params.permit(:status)
  end
end
