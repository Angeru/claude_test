require "test_helper"

class WarbandSkillTest < ActiveSupport::TestCase
  def setup
    @member = warband_members(:one)
  end

  def build_skill(overrides = {})
    WarbandSkill.new({
      warband_member: @member,
      name: "Test Skill",
      skill_type: "combat",
      cost: 0,
      movimiento_modifier: 0, lucha_modifier: 0, proyectiles_modifier: 0,
      fuerza_modifier: 0, defensa_modifier: 0, ataques_modifier: 0,
      heridas_modifier: 0, coraje_modifier: 0, inteligencia_modifier: 0,
      might_modifier: 0, will_modifier: 0, fate_modifier: 0
    }.merge(overrides))
  end

  test "ataques modifier adds 10 ranking points per point" do
    skill = build_skill(ataques_modifier: 3)
    skill.save!
    assert_equal 30, skill.ranking
  end

  test "heridas modifier adds 10 ranking points per point" do
    skill = build_skill(heridas_modifier: 2)
    skill.save!
    assert_equal 20, skill.ranking
  end

  test "coraje modifier does not add ranking points" do
    skill = build_skill(coraje_modifier: 5)
    skill.save!
    assert_equal 0, skill.ranking
  end

  test "inteligencia modifier does not add ranking points" do
    skill = build_skill(inteligencia_modifier: 4)
    skill.save!
    assert_equal 0, skill.ranking
  end

  test "other stat modifiers add 5 ranking points per point" do
    skill = build_skill(fuerza_modifier: 2)
    skill.save!
    assert_equal 10, skill.ranking
  end

  test "movimiento modifier adds 5 ranking points per point" do
    skill = build_skill(movimiento_modifier: 3)
    skill.save!
    assert_equal 15, skill.ranking
  end

  test "negative modifiers do not subtract ranking points" do
    skill = build_skill(ataques_modifier: -2, heridas_modifier: -1, fuerza_modifier: -3)
    skill.save!
    assert_equal 0, skill.ranking
  end

  test "mixed modifiers accumulate correctly" do
    skill = build_skill(ataques_modifier: 1, heridas_modifier: 1, fuerza_modifier: 2, coraje_modifier: 3)
    skill.save!
    # ataques: 10, heridas: 10, fuerza: 10, coraje: 0
    assert_equal 30, skill.ranking
  end

  test "ranking recalculates on update" do
    skill = build_skill(ataques_modifier: 1)
    skill.save!
    assert_equal 10, skill.ranking

    skill.update!(ataques_modifier: 2)
    assert_equal 20, skill.ranking
  end
end
