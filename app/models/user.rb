class User < ApplicationRecord
  has_secure_password
  has_many :tickets   

  enum :role, {
    user:  "user",
    admin: "admin",
    agent: "agent"
  }

  validates :name, presence: true, format: { with: /\A[a-zA-Z\s]+\z/, message: "only allows letters and spaces" }

  validates :password, presence: true, length: { in: 6..15 }, on: :create

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, presence: true, uniqueness: true

  validates :mobile_no, presence: true, length: { minimum: 10, maximum: 12 }, numericality: true

  private

  def is_admin?
    # current_user.role == "admin"
    self.role == "admin"
  end

  def is_user?
    self.role == "user"
  end

  def is_agent?
    self.role == "agent"
  end
end
