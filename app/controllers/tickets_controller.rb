class TicketsController < ApplicationController
  skip_before_action :verify_authenticity_token # this is to remove csrf token missing warning
  before_action :set_ticket, only: [ :show, :destroy, :update ]

  def index
    # if show_params[:status].present?
    #   # pp "Inside if"
    #   @show_tickets = @current_user.tickets.where(status: show_params[:status])
    #   render ticket: @show_tickets, status: :ok
    #   return
    # else
    #   if @current_user.role == "admin"
    #     # pp "admin"
    #     @show_tickets = Ticket.all
    #     # pp @tickets
    #     render ticket: @show_tickets, status: :ok
    #   elsif @current_user.role == "user"
    #     # pp "else_---------------------------------"
    #     # @show_tickets = @current_user.tickets.all
    #     @show_tickets = @current_user.tickets.all
    #     # pp @show_tickets
    #     render ticket: @show_tickets, status: :ok
    #   end
    #   # @tickets = Ticket.all
    #   # render json: @current_user.tickets.all
    # end
    if @current_user.role == "admin"
      # get all tickets
      
    elsif @current_user.role == "agent"
      # get tickets assigned to particualr agent
      @show_tickets = Ticket.where(user_id: @current_user.id)
    else
      # get tickets created by particular user
      @show_tickets = Ticket.where(user_id: @current_user.id)
    end
  end

  def show
    # render json: @ticket
  end

  def create
    # only users can create ticket admins are assigning it to agents
    if @current_user.role != "user"
      render json: { message: "Only users can create tickets" }, status: :forbidden
      return
    end
    @ticket = @current_user.tickets.new( ticket_params )
    if @ticket.save
      pp @ticket
      created_by = @current_user.id
      render ticket: @ticket, status: :created
    else
      # pp "====="
      render json: {message: @ticket.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    if @current_user.role == "admin" || @current_user.role == "agent"
      permitted_params = params.permit(:status)
    elsif @current_user.role == "user" && @ticket.is_assigned == false
      permitted_params = params.permit(:title, :description, :priority)
    end

    if @ticket.update( permitted_params )
      render ticket: @ticket, status: :ok
    else
      # pp ""
      # render json: { message: "Ticket not found"}, status: :unprocessable_entity
      render json: { message: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    unless @current_user.role == "admin"
      render json: { message: "You don't have permission, Only agents require!" }, status: :forbidden
      return
    end

    if @ticket.destroy
      render json: { message: "Ticket deleted successfully" }, status: :ok
    else
      render json: { message: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def assign_agent
    # I have to update 
    unless @current_user.role == "admin"
      render json: {message: "Only admins can assign tickets. You don't have permission!"}, status: :forbidden
      return
    end

    @ticket = Ticket.find_by(id: assign_agent_params[:ticket_id])
    unless @ticket.present?
      render json: { message: "Ticket not found" }, status: :unprocessable_entity
      return
    end

    @agent = User.find_by(id: assign_agent_params[:user_id])
    unless @agent.present?
      render json: { message: "Agent not found" }, status: :unprocessable_entity
      return
    end
    unless @agent.role == "agent"
      render json: { message: "You don't have permission, Only agents require!" }, status: :forbidden
      return
    end

    if @ticket.update( assigned_to: @agent.id )
      is_assigned = true
      render json: @ticket, status: :ok
    else
      render json: { message: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private


  def assign_agent_params
    params.permit(:ticket_id, :user_id)
  end

  def set_ticket
    # user can see only his ; admin sees all
    if @current_user.role == "admin"
      @ticket = Ticket.find_by(id: params[:id])
    else
      @ticket = @current_user.tickets.find_by(id: params[:id])
    end
    # @ticket = @current_user.tickets.find_by(id: params[:id])
    unless @ticket.present?
      render json: { status: false, message: "Ticket Not Found" }, status: :unprocessable_entity
      return
    end
  end

  def ticket_params
    params.permit(:title, :description, :priority)
  end

  def show_params
    params.permit(:status)
  end
  
end


