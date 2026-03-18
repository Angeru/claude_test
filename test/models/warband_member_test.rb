require "test_helper"

class WarbandMemberTest < ActiveSupport::TestCase
  test "should not update stats when warband is in a campaign" do
    member = warband_members(:one)
    assert member.warband.in_campaign?, "Fixture warband should be in a campaign"

    member.lucha = member.lucha + 1
    assert_not member.save
    assert_includes member.errors[:base].join, "estadísticas base"
  end

  test "should allow updating non-stat fields when warband is in a campaign" do
    member = warband_members(:one)
    assert member.warband.in_campaign?

    member.experience = member.experience + 5
    assert member.save, member.errors.full_messages.inspect
  end

  test "should allow updating stats when warband is not in a campaign" do
    # Create a warband member in a warband without campaign
    warband = warbands(:two)
    assert_not warband.in_campaign?, "Fixture warband two should not be in a campaign"

    member = warband.warband_members.create!(
      name: "Test Warrior",
      member_type: "warrior",
      movimiento: 6, lucha: 3, proyectiles: 3, fuerza: 3,
      defensa: 3, ataques: 1, heridas: 1, coraje: 3, inteligencia: 1,
      might: 0, will: 0, fate: 0, experience: 0, ranking: 0
    )

    member.lucha = 5
    assert member.save, member.errors.full_messages.inspect
  end

  test "all stat fields are included in STAT_FIELDS constant" do
    expected = %w[movimiento lucha proyectiles fuerza defensa ataques heridas coraje inteligencia might will fate]
    assert_equal expected.sort, WarbandMember::STAT_FIELDS.sort
  end
end
