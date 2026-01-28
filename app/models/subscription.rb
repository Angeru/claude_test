class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  validates :user_id, presence: true
  validates :campaign_id, presence: true
  validates :user_id, uniqueness: { scope: :campaign_id, message: "ya está suscrito a esta campaña" }

  scope :recent, -> { order(subscribed_at: :desc) }
end
