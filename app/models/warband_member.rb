class WarbandMember < ApplicationRecord
  MEMBER_TYPES = %w[warrior hero].freeze

  belongs_to :warband
  has_many :warband_equipments, dependent: :destroy
  has_many :warband_skills, dependent: :destroy
  has_many :battle_roster_units, dependent: :destroy

  after_create  :log_creation
  after_update  :log_update_changes
  after_destroy :log_destruction

  EXCLUDED_FIELDS = %w[id created_at updated_at warband_id warband_member_id].freeze

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
  def log_creation
    WarbandActivityLog.log(:create, self, user: Current.user, warband: warband, member: self)
  end

  def log_update_changes
    relevant = saved_changes.except(*EXCLUDED_FIELDS)
    return if relevant.empty?
    WarbandActivityLog.log(:update, self, user: Current.user, warband: warband, member: self, changes: relevant)
  end

  def log_destruction
    WarbandActivityLog.log(:destroy, self, user: Current.user, warband: warband, member: self)
  end

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
