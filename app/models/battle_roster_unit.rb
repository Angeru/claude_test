class BattleRosterUnit < ApplicationRecord
  belongs_to :battle_roster
  belongs_to :warband_member

  validates :current_wounds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_wounds, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :battle_roster_id, uniqueness: { scope: :warband_member_id }

  scope :alive, -> { where(defeated: false) }
  scope :defeated, -> { where(defeated: true) }

  def take_wound!
    return if defeated?
    self.current_wounds -= 1
    self.defeated = true if current_wounds <= 0
    self.current_wounds = 0 if current_wounds < 0
    save!
  end

  def restore_wound!
    return if current_wounds >= max_wounds
    self.defeated = false
    self.current_wounds += 1
    save!
  end

  def wounds_display
    "#{current_wounds}/#{max_wounds}"
  end
end
