class WarbandActivityLog < ApplicationRecord
  belongs_to :warband
  belongs_to :warband_member, optional: true
  belongs_to :user

  EXCLUDED_FIELDS = %w[id created_at updated_at warband_id warband_member_id].freeze

  scope :recent, -> { order(created_at: :desc) }

  def self.log(action, entity, user:, warband:, member: nil, changes: nil)
    return unless user.present? && warband.present?

    changes_json = changes.present? ? changes.to_json : nil

    create!(
      warband: warband,
      warband_member: member,
      user: user,
      action: action.to_s,
      entity_type: entity.class.name,
      entity_name: entity.name,
      changes_summary: changes_json
    )
  rescue => e
    Rails.logger.error("WarbandActivityLog.log failed: #{e.message}")
  end

  def human_description
    case action
    when "create"
      "#{entity_type_label} creado: #{entity_name}"
    when "destroy"
      "#{entity_type_label} eliminado: #{entity_name}"
    when "update"
      changes = parsed_changes
      if changes.any?
        diffs = changes.map { |field, (old_val, new_val)| "#{field}: #{old_val}→#{new_val}" }.join(", ")
        "#{entity_name} actualizado (#{diffs})"
      else
        "#{entity_name} actualizado"
      end
    end
  end

  def parsed_changes
    return {} unless changes_summary.present?

    JSON.parse(changes_summary)
  rescue JSON::ParserError
    {}
  end

  private

  def entity_type_label
    {
      "Warband" => "Warband",
      "WarbandMember" => "Miembro",
      "WarbandSkill" => "Skill",
      "WarbandEquipment" => "Equipo"
    }.fetch(entity_type, entity_type)
  end
end
