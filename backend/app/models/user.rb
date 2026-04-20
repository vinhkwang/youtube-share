class User < ApplicationRecord
  has_secure_password

  has_many :videos, dependent: :destroy

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "is not a valid email" }

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 30 },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "can only contain letters, numbers, and underscores" }

  validates :password,
            length: { minimum: 6 },
            if: -> { new_record? || !password.nil? }

  before_save :downcase_email

  def generate_jwt
    JsonWebToken.encode(user_id: id)
  end

  def as_public_json
    { id: id, email: email, username: username, created_at: created_at }
  end

  private

  def downcase_email
    self.email = email.downcase.strip
  end
end
