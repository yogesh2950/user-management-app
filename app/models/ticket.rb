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
    urgent: 0,
    high: 1,
    medium: 2,
    low: 3
  }

  # scope :name, ->{where (:attribute => value)}

  scope :by_status, -> { where (status: status)}
  scope :by_status, ->(status) {
    where(status: status) if status.present?
  }

  # validates :status, presence: true
  validates :title, presence: true
  validates :priority, presence: true
  validates :user_id, presence: true
end
