class TicketsController < ApplicationController
  # skip_before_action :verify_authenticity_token # this is to remove csrf token missing warning
  before_action :set_ticket, only: [ :show, :destroy ]

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

    if @current_user.is_admin?
      # get all tickets
      @show_tickets = Ticket.all
    elsif @current_user.is_agent?
      # get tickets assigned to particualr agent
      @show_tickets = Ticket.where(assigned_to: @current_user.id)
    else
      # get tickets created by particular user
      @show_tickets = Ticket.where(created_by: @current_user.id)
    end

    @show_tickets = @show_tickets.by_status(show_params) if show_params[:status].present?
    @show_tickets = @show_tickets.by_order(show_params) if show_params[:sort].present?
    @show_tickets = @show_tickets.order_by_priority(show_params) if show_params[:priority].present?

    render ticket: @show_tickets, status: :ok
  end

  def show
    # render json: @ticket
  end

  def create
    # only users can create ticket admins are assigning it to agents
    if !@current_user.is_user?
      render json: { message: "Only users can create tickets" }, status: :forbidden
      return
    end
    @ticket = @current_user.tickets.new( ticket_params )
    @ticket.created_by = @current_user.id
    if @ticket.save
      render ticket: @ticket, status: :created
    else
      render json: {message: @ticket.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    
    # user can see only his ; admin sees all

    # if @current_user.role == "admin" || @current_user.role == "agent"
    #   @ticket = Ticket.find_by(id: params[:id])
    #   permitted_params = params.permit(:status)
    # elsif @current_user.role == "user" && @ticket.is_assigned == false
    #   @ticket = @current_user.tickets.find_by(id: params[:id])
    #   permitted_params = params.permit( ticket_params )
    # end

    if @current_user.is_admin?
      @ticket = Ticket.find_by(id: params[:id])
      permitted_params = params.permit(:status)
    elsif @current_user.is_agent?
      # @ticket = @current_user.tickets.find_by(id: params[:id])
      @ticket = Ticket.find_by(id: params[:id], assigned_to: @current_user.id)
      permitted_params = params.permit(:status)
    elsif @current_user.is_user?
      @ticket = @current_user.tickets.find_by(id: params[:id])
      # permitted_params = params.permit(ticket_params)
      permitted_params = params.permit(:title, :description, :priority)
    end

    unless @ticket.present?
      render json: { status: false, message: "Ticket Not Found" }, status: :unprocessable_entity
      return
    end

    if permitted_params[:status].present?
      unless next_status_allowed?(@ticket, permitted_params[:status])
        return render json: {
          message: "Invalid status transition!"
        }, status: :unprocessable_entity
      end
    end

    if @ticket.update( permitted_params )
      render ticket: @ticket, status: :ok
    else
      render json: { message: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def destroy
    unless @current_user.is_admin?
      render json: { message: "You don't have permission, Only admins require!" }, status: :forbidden
      return
    end

    if @ticket.destroy
      render json: { message: "Ticket deleted successfully" }, status: :ok
    else
      render json: { message: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def assign_agent 
    unless @current_user.is_admin?
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
    unless @agent.is_agent?
      render json: { message: "Only agents require!" }, status: :forbidden
      return
    end

    
    if @ticket.update(assigned_to: @agent.id, is_assigned: true)
      # @ticket.is_assigned  = true
      render json: @ticket, status: :ok
    else
      render json: { message: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end


  private

  def next_status_allowed?(ticket, new_status)
    return false if new_status.blank?
    return false if ticket.status == "closed"

    current_value = Ticket.statuses[ticket.status]
    new_value     = Ticket.statuses[new_status]

    return false if new_value.nil?

    new_value == current_value + 1
  end


  def assign_agent_params
    params.permit(:ticket_id, :user_id)
  end

  def set_ticket
    # user can see only his ; admin sees all
    if @current_user.is_admin?
      @ticket = Ticket.find_by(id: params[:id])
    elsif @current_user.is_agent?
      @ticket = Ticket.find_by(assigned_to: params[:id])
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
    params.permit(:title, :description, :priority, :is_approval_required)
  end

  def show_params
    params.permit(:status, :sort, :priority)
  end
  
end