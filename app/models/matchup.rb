class Matchup < ApplicationRecord
  RESULTS = %w[pending warband_1_win warband_2_win draw].freeze

  belongs_to :campaign_round
  belongs_to :warband_1, class_name: 'Warband', foreign_key: 'warband_1_id'
  belongs_to :warband_2, class_name: 'Warband', foreign_key: 'warband_2_id'
  belongs_to :winner, class_name: 'Warband', foreign_key: 'winner_id', optional: true
  has_many :battle_rosters, dependent: :destroy

  validates :warband_1_id, :warband_2_id, presence: true
  validates :warband_2_id, exclusion: { in: ->(matchup) { [matchup.warband_1_id] }, message: "no puede ser la misma warband" }
  validates :result, inclusion: { in: RESULTS }, allow_nil: true
  validates :warband_1_score, :warband_2_score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :warband_1_casualties, :warband_2_casualties, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  validate :winner_must_be_participant

  scope :pending, -> { where(result: ['pending', nil]) }
  scope :completed, -> { where.not(result: ['pending', nil]) }

  def pending?
    result.nil? || result == 'pending'
  end

  def completed?
    !pending?
  end

  def draw?
    result == 'draw'
  end

  def winner_name
    return 'Empate' if draw?
    return '-' if pending?
    winner&.name || '-'
  end

  def calculate_winner
    return 'draw' if warband_1_score == warband_2_score
    warband_1_score > warband_2_score ? 'warband_1_win' : 'warband_2_win'
  end

  def auto_calculate_result!
    self.result = calculate_winner
    self.winner_id = case result
                     when 'warband_1_win' then warband_1_id
                     when 'warband_2_win' then warband_2_id
                     else nil
                     end
    save
  end

  private

  def winner_must_be_participant
    return if winner_id.nil?
    unless [warband_1_id, warband_2_id].include?(winner_id)
      errors.add(:winner_id, "debe ser una de las warbands participantes")
    end
  end
end
