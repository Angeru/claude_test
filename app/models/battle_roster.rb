class BattleRoster < ApplicationRecord
  belongs_to :matchup
  belongs_to :warband
  has_many :battle_roster_units, dependent: :destroy

  validates :matchup_id, uniqueness: { scope: :warband_id, message: "ya tiene un roster de batalla para esta warband" }
  validate :warband_must_be_in_matchup

  scope :active, -> { where(active: true) }

  def populate_units!
    warband.warband_members.find_each do |member|
      battle_roster_units.find_or_create_by!(warband_member: member) do |unit|
        unit.max_wounds = member.heridas
        unit.current_wounds = member.heridas
        unit.defeated = false
      end
    end
  end

  def defeated_count
    battle_roster_units.where(defeated: true).count
  end

  def alive_count
    battle_roster_units.where(defeated: false).count
  end

  def total_count
    battle_roster_units.count
  end

  private

  def warband_must_be_in_matchup
    return if matchup.nil? || warband_id.nil?
    unless [matchup.warband_1_id, matchup.warband_2_id].include?(warband_id)
      errors.add(:warband, "debe ser participante del emparejamiento")
    end
  end
end
