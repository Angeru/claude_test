class BattleRosterUnit < ApplicationRecord
  belongs_to :battle_roster
  belongs_to :warband_member

  SPENDABLE = %w[might will fate].freeze
  TICKS = %w[wounded_enemy fate_protected courage_broken on_objective].freeze

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

  def spend!(attribute)
    raise ArgumentError, "atributo inválido: #{attribute}" unless SPENDABLE.include?(attribute)
    current = send(:"current_#{attribute}")
    return if current <= 0
    update!(:"current_#{attribute}" => current - 1)
  end

  def restore!(attribute)
    raise ArgumentError, "atributo inválido: #{attribute}" unless SPENDABLE.include?(attribute)
    current = send(:"current_#{attribute}")
    max = warband_member.send(attribute)
    return if current >= max
    update!(:"current_#{attribute}" => current + 1)
  end

  def toggle_tick!(tick)
    raise ArgumentError, "tick inválido: #{tick}" unless TICKS.include?(tick.to_s)
    update!(tick => !public_send(tick))
  end

  def set_mvp!(value)
    if value
      battle_roster.battle_roster_units.where.not(id: id).update_all(mvp: false)
      update!(mvp: true)
    else
      update!(mvp: false)
    end
  end

  def kill!
    increment!(:kills)
  end

  def unkill!
    return if kills <= 0
    decrement!(:kills)
  end

  def has_spendable?
    warband_member.might > 0 || warband_member.will > 0 || warband_member.fate > 0
  end
end
