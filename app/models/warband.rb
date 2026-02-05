class Warband < ApplicationRecord
  belongs_to :user
  belongs_to :campaign, optional: true
  has_many :warband_members, dependent: :destroy
  has_many :battle_rosters, dependent: :destroy
  has_many :heroes, -> { where(member_type: "hero") }, class_name: "WarbandMember"
  has_many :warriors, -> { where(member_type: "warrior") }, class_name: "WarbandMember"

  validates :name, presence: true, length: { minimum: 3 }
  validates :user_id, presence: true
  validates :gold, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :influence, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :campaign_must_be_subscribed
  validate :user_can_only_have_one_warband_per_campaign

  scope :available, -> { where(campaign_id: nil) }
  scope :in_campaign, -> { where.not(campaign_id: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def available?
    campaign_id.nil?
  end

  def in_campaign?
    campaign_id.present?
  end

  def assign_to_campaign(campaign)
    update(campaign: campaign)
  end

  def remove_from_campaign
    update(campaign: nil)
  end

  def member_count
    warband_members.count
  end

  def hero_count
    heroes.count
  end

  def warrior_count
    warriors.count
  end

  private

  def campaign_must_be_subscribed
    return if campaign_id.nil?
    return if user.campaigns.include?(campaign)

    errors.add(:campaign, "debes estar suscrito a la campaña para asignar tu warband")
  end

  def user_can_only_have_one_warband_per_campaign
    return if campaign_id.nil?
    return unless user_id.present?

    existing = Warband.where(user_id: user_id, campaign_id: campaign_id)
                      .where.not(id: id)

    if existing.exists?
      errors.add(:campaign, "ya tienes una warband asignada a esta campaña")
    end
  end
end
