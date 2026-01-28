class Campaign < ApplicationRecord
  STATUSES = %w[activa pausada finalizada].freeze

  belongs_to :user
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user

  validates :name, presence: true, length: { minimum: 3 }
  validates :description, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :user_id, presence: true
  validate :end_date_after_start_date

  scope :active, -> { where(status: "activa") }
  scope :recent, -> { order(created_at: :desc) }

  def active?
    status == "activa"
  end

  def paused?
    status == "pausada"
  end

  def finished?
    status == "finalizada"
  end

  private

  def end_date_after_start_date
    if start_date.present? && end_date.present? && end_date <= start_date
      errors.add(:end_date, "debe ser posterior a la fecha de inicio")
    end
  end
end
