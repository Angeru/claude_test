class WarbandMember < ApplicationRecord
  MEMBER_TYPES = %w[warrior hero].freeze

  belongs_to :warband
  has_many :warband_equipments, dependent: :destroy
  has_many :warband_skills, dependent: :destroy
  has_many :battle_roster_units, dependent: :destroy

  # Enum for member type
  enum member_type: {
    warrior: "warrior",
    hero: "hero"
  }

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :member_type, inclusion: { in: MEMBER_TYPES }
  validates :warband_id, presence: true

  # Numeric validations for all attributes
  validates :movimiento, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 12 }
  validates :lucha, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :proyectiles, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :fuerza, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :defensa, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :ataques, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :heridas, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :coraje, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :inteligencia, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :might, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :will, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :fate, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :experience, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :warriors, -> { where(member_type: "warrior") }
  scope :heroes, -> { where(member_type: "hero") }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_name, -> { order(:name) }

  # Helper methods
  def hero?
    member_type == "hero"
  end

  def warrior?
    member_type == "warrior"
  end

  def display_type
    member_type.capitalize
  end
end
