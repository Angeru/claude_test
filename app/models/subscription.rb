class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :campaign
  belongs_to :warband, optional: true

  validates :user_id, presence: true
  validates :campaign_id, presence: true
  validates :user_id, uniqueness: { scope: :campaign_id, message: "ya está suscrito a esta campaña" }
  validate :warband_must_belong_to_user
  validate :warband_must_be_available

  scope :recent, -> { order(subscribed_at: :desc) }

  after_create :assign_warband_to_campaign
  after_destroy :remove_warband_from_campaign

  private

  def warband_must_belong_to_user
    return if warband_id.nil?

    unless warband&.user_id == user_id
      errors.add(:warband, "debe pertenecer al usuario")
    end
  end

  def warband_must_be_available
    return if warband_id.nil?

    if warband&.campaign_id.present? && warband.campaign_id != campaign_id
      errors.add(:warband, "ya está asignada a otra campaña")
    end
  end

  def assign_warband_to_campaign
    warband&.update(campaign: campaign)
  end

  def remove_warband_from_campaign
    warband&.update(campaign: nil)
  end
end
