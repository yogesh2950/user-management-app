class User < ApplicationRecord
  has_secure_password
  has_many :tickets

  validates :name, presence: true
  
  validates :password, presence: true, length: { in: 6..15 }, on: :create

  validates :email, format: {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}, presence: true, uniqueness: true

  # validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :mobile_no, presence: true, length: { minimum: 10 , maximum: 12}
  # validates :city
end
