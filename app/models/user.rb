class User < ApplicationRecord
  ROLES = %w[user admin].freeze

  has_secure_password

  has_many :created_campaigns, class_name: "Campaign", dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :campaigns, through: :subscriptions
  has_many :warbands, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :role, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end

  def user?
    role == "user"
  end

  before_save :downcase_email

  def generate_password_reset_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save!
  end

  def clear_password_reset_token!
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    save!
  end

  def password_reset_token_valid?
    reset_password_sent_at.present? && reset_password_sent_at > 2.hours.ago
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
