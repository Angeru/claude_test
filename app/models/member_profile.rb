class MemberProfile < ApplicationRecord
  MEMBER_TYPES = %w[warrior hero].freeze
  RANKS = %w[capitan sargento].freeze
  STAT_FIELDS = %w[movimiento lucha proyectiles fuerza defensa ataques heridas coraje inteligencia might will fate].freeze

  belongs_to :user

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :member_type, inclusion: { in: MEMBER_TYPES }
  validates :rank, inclusion: { in: RANKS + [ nil ] }
  validate :rank_only_for_heroes

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

  scope :by_name, -> { order(:name) }
  scope :heroes, -> { where(member_type: "hero") }
  scope :warriors, -> { where(member_type: "warrior") }

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

  # Builds a new WarbandMember with stats from this profile
  def apply_to_member(member)
    member.member_type = member_type
    member.rank = rank
    member.experience = experience
    member.ranking = ranking
    STAT_FIELDS.each { |f| member.send(:"#{f}=", send(f)) }
    member
  end

  private

  def rank_only_for_heroes
    return if rank.blank?
    errors.add(:rank, "solo los héroes pueden tener rango") unless hero?
  end
end
