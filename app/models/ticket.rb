class Ticket < ApplicationRecord
  belongs_to :user


  enum :status, {
    open: 0,
    pending: 1,
    on_hold: 2,
    solved: 3,
    closed: 4,
    reopened: 5
    # new: 6
  }, default: :open


  validates :title, presence: true
  validates :priority, presence: true
  validates :user_id, presence: true
end
