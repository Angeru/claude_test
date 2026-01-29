class WarbandSkill < ApplicationRecord
  SKILL_TYPES = %w[combat magic passive special heroic].freeze

  belongs_to :warband_member

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :skill_type, presence: true, inclusion: { in: SKILL_TYPES }
  validates :cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Stat modifiers validations (can be positive or negative)
  validates :movimiento_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :lucha_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :proyectiles_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :fuerza_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :defensa_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :ataques_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :heridas_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :coraje_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :inteligencia_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :might_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :will_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }
  validates :fate_modifier, numericality: { only_integer: true, greater_than_or_equal_to: -10, less_than_or_equal_to: 10 }

  # Scopes
  scope :by_name, -> { order(:name) }
  scope :by_type, ->(type) { where(skill_type: type) }
  scope :combat, -> { where(skill_type: 'combat') }
  scope :magic, -> { where(skill_type: 'magic') }
  scope :passive, -> { where(skill_type: 'passive') }

  # Helper methods
  def display_type
    skill_type.capitalize
  end

  def has_modifiers?
    [movimiento_modifier, lucha_modifier, proyectiles_modifier, fuerza_modifier,
     defensa_modifier, ataques_modifier, heridas_modifier, coraje_modifier,
     inteligencia_modifier, might_modifier, will_modifier, fate_modifier].any? { |mod| mod != 0 }
  end

  def modifier_summary
    modifiers = []
    modifiers << "Mov: #{format_modifier(movimiento_modifier)}" if movimiento_modifier != 0
    modifiers << "Lucha: #{format_modifier(lucha_modifier)}" if lucha_modifier != 0
    modifiers << "Proyectiles: #{format_modifier(proyectiles_modifier)}" if proyectiles_modifier != 0
    modifiers << "Fuerza: #{format_modifier(fuerza_modifier)}" if fuerza_modifier != 0
    modifiers << "Defensa: #{format_modifier(defensa_modifier)}" if defensa_modifier != 0
    modifiers << "Ataques: #{format_modifier(ataques_modifier)}" if ataques_modifier != 0
    modifiers << "Heridas: #{format_modifier(heridas_modifier)}" if heridas_modifier != 0
    modifiers << "Coraje: #{format_modifier(coraje_modifier)}" if coraje_modifier != 0
    modifiers << "Inteligencia: #{format_modifier(inteligencia_modifier)}" if inteligencia_modifier != 0
    modifiers << "Might: #{format_modifier(might_modifier)}" if might_modifier != 0
    modifiers << "Will: #{format_modifier(will_modifier)}" if will_modifier != 0
    modifiers << "Fate: #{format_modifier(fate_modifier)}" if fate_modifier != 0
    modifiers.join(", ")
  end

  private

  def format_modifier(value)
    value.positive? ? "+#{value}" : value.to_s
  end
end
