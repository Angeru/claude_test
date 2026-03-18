class WarbandMember < ApplicationRecord
  MEMBER_TYPES = %w[warrior hero].freeze
  RANKS = %w[capitan sargento].freeze

  belongs_to :warband
  has_many :warband_equipments, dependent: :destroy
  has_many :warband_skills, dependent: :destroy
  has_many :battle_roster_units, dependent: :destroy

  after_create  :log_creation
  after_update  :log_update_changes
  after_destroy :log_destruction

  EXCLUDED_FIELDS = %w[id created_at updated_at warband_id warband_member_id].freeze
  STAT_FIELDS = %w[movimiento lucha proyectiles fuerza defensa ataques heridas coraje inteligencia might will fate].freeze

  # Enum for member type
  enum member_type: {
    warrior: "warrior",
    hero: "hero"
  }

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :member_type, inclusion: { in: MEMBER_TYPES }
  validates :warband_id, presence: true
  validates :rank, inclusion: { in: RANKS + [ nil ] }
  validate :rank_only_for_heroes
  validate :validate_rank_limits
  validate :stats_immutable_in_campaign, on: :update

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
  validates :ranking, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :warriors, -> { where(member_type: "warrior") }
  scope :heroes, -> { where(member_type: "hero") }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_name, -> { order(:name) }
  scope :by_rank_then_name, -> { order(Arel.sql("CASE rank WHEN 'capitan' THEN 0 WHEN 'sargento' THEN 1 ELSE 2 END, name")) }

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

  def total_modifier(stat)
    field = "#{stat}_modifier"
    warband_equipments.sum(field) + warband_skills.sum(field)
  end

  def total_ranking
    ranking + warband_equipments.sum(:ranking) + warband_skills.sum(:ranking) + (might + will + fate) * 5
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

  def display_rank
    case rank
    when "capitan" then "Capitán"
    when "sargento" then "Sargento"
    end
  end

  private

  def stats_immutable_in_campaign
    return unless warband&.in_campaign?
    changed_stats = STAT_FIELDS.select { |f| send(:"#{f}_changed?") }
    return if changed_stats.empty?
    errors.add(:base, "Las estadísticas base no pueden modificarse mientras la warband pertenece a una campaña")
  end

  def rank_only_for_heroes
    return if rank.blank?
    errors.add(:rank, "solo los héroes pueden tener rango") unless hero?
  end

  def validate_rank_limits
    return if rank.blank?
    siblings = warband.warband_members.where.not(id: id)
    if rank == "capitan" && siblings.where(rank: "capitan").exists?
      errors.add(:rank, "ya existe un Capitán en esta warband")
    end
    if rank == "sargento" && siblings.where(rank: "sargento").count >= 2
      errors.add(:rank, "ya hay 2 Sargentos en esta warband")
    end
  end
end
