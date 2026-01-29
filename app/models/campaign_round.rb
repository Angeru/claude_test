class CampaignRound < ApplicationRecord
  belongs_to :campaign
  has_many :matchups, dependent: :destroy

  validates :round_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :round_number, uniqueness: { scope: :campaign_id }

  scope :ordered, -> { order(:round_number) }
  scope :recent, -> { order(round_number: :desc) }

  def display_name
    "Ronda #{round_number}"
  end

  def full_name
    scenario.present? ? "Ronda #{round_number}: #{scenario}" : display_name
  end
end
