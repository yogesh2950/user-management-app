class Ticket < ApplicationRecord
  belongs_to :user


  enum :status, {
    open: 0,
    awaiting_approval: 1,
    approved: 2,
    in_progress: 3,
    resolved: 4,
    closed: 5
    # new: 6
  }

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2,
    urgent: 3
  }

  # scope :name, ->{where (:attribute => value)}

  scope :by_status, ->(params){ where(status: params[:status]) }
  # scope :by_priority, -> (priority){ where(priority: priority)}
  scope :by_order, ->(params) {
    # newest -> descending; oldest -> ascending
    filter = params[:sort] == "newest" ? :desc : :asc
    order(created_at: filter)
  }
  scope :order_by_priority, ->(params) {order( priority: params[:priority].to_sym)} 

  # validates :status, presence: true
  validates :title, presence: true
  validates :priority, presence: true
  validates :user_id, presence: true
end
