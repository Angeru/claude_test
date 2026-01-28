require "test_helper"

class WarbandTest < ActiveSupport::TestCase
  test "should not save warband without name" do
    warband = Warband.new(user: users(:two))
    assert_not warband.save
  end

  test "should not save warband with name shorter than 3 characters" do
    warband = Warband.new(name: "AB", user: users(:two))
    assert_not warband.save
  end

  test "should not save warband without user" do
    warband = Warband.new(name: "Test Warband")
    assert_not warband.save
  end

  test "should save warband without campaign" do
    warband = Warband.new(name: "Test Warband", user: users(:two))
    assert warband.save
  end

  test "should save warband with campaign if user is subscribed" do
    user = users(:two)
    campaign = campaigns(:two)
    # El usuario two ya está suscrito a campaign two por fixtures

    warband = Warband.new(name: "Test Warband", user: user, campaign: campaign)
    assert warband.save
  end

  test "should not allow warband in campaign if user not subscribed" do
    user = users(:three)
    campaign = campaigns(:one)
    user.campaigns.delete(campaign) if user.campaigns.include?(campaign)

    warband = Warband.new(name: "Test Warband", user: user, campaign: campaign)
    assert_not warband.save
    assert_includes warband.errors[:campaign], "debes estar suscrito a la campaña para asignar tu warband"
  end

  test "should not allow user to have multiple warbands in same campaign" do
    user = users(:two)
    campaign = campaigns(:one)
    # El usuario two ya está suscrito a campaign one por fixtures
    # La warband 'one' ya está asignada a esta campaña

    # Intentar crear segunda warband en misma campaña
    warband2 = Warband.new(name: "Warband 2", user: user, campaign: campaign)
    assert_not warband2.save
    assert_includes warband2.errors[:campaign], "ya tienes una warband asignada a esta campaña"
  end

  test "should allow user to have multiple warbands in different campaigns" do
    # Los fixtures ya tienen:
    # - warband 'one' del user two en campaign one
    # - warband 'two' del user two sin campaign
    # El user two está suscrito a campaigns one, two y three

    warband_one = warbands(:one)
    assert_equal users(:two), warband_one.user
    assert_equal campaigns(:one), warband_one.campaign

    # Crear otra warband en campaign three (diferente)
    warband_new = Warband.new(name: "Warband Nueva", user: users(:two), campaign: campaigns(:three))
    assert warband_new.save, "Debería poder crear warband en campaña diferente"
  end

  test "should allow multiple users to have warbands in same campaign" do
    campaign = campaigns(:two)
    user1 = users(:two)
    user2 = users(:three)

    # Suscribir user2 a campaign two
    user2.campaigns << campaign unless user2.campaigns.include?(campaign)

    # user1 ya tiene warband en otra campaña, crear otra para esta
    warband1 = Warband.new(name: "Warband User1", user: user1, campaign: campaign)
    warband2 = Warband.new(name: "Warband User2", user: user2, campaign: campaign)

    assert warband1.save, "User1 debería poder tener warband en campaign two"
    assert warband2.save, "User2 debería poder tener warband en campaign two"
  end

  test "available? should return true when no campaign" do
    warband = warbands(:two)
    assert warband.available?
  end

  test "in_campaign? should return true when has campaign" do
    warband = warbands(:one)
    assert warband.in_campaign?
  end

  test "should nullify warband campaign_id when campaign is destroyed" do
    warband = warbands(:one)
    campaign = warband.campaign

    campaign.destroy
    warband.reload

    assert_nil warband.campaign_id
    assert warband.available?
  end

  test "should destroy warband when user is destroyed" do
    user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "password123",
      role: "user"
    )
    warband = user.warbands.create!(name: "Test Warband")

    assert_difference "Warband.count", -1 do
      user.destroy
    end
  end

  test "scopes should work correctly" do
    available_count = Warband.available.count
    in_campaign_count = Warband.in_campaign.count

    assert available_count > 0
    assert in_campaign_count > 0
  end
end
