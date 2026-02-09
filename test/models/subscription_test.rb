require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  test "should not allow duplicate subscriptions" do
    subscription = Subscription.new(
      user: subscriptions(:one).user,
      campaign: subscriptions(:one).campaign
    )
    assert_not subscription.save, "Saved a duplicate subscription"
  end

  test "should require user" do
    subscription = Subscription.new(campaign: campaigns(:one))
    assert_not subscription.save, "Saved the subscription without a user"
  end

  test "should require campaign" do
    subscription = Subscription.new(user: users(:two))
    assert_not subscription.save, "Saved the subscription without a campaign"
  end

  test "should belong to user" do
    subscription = subscriptions(:one)
    assert_respond_to subscription, :user
    assert_equal users(:two), subscription.user
  end

  test "should belong to campaign" do
    subscription = subscriptions(:one)
    assert_respond_to subscription, :campaign
    assert_equal campaigns(:one), subscription.campaign
  end

  test "should belong to warband" do
    subscription = subscriptions(:one)
    assert_respond_to subscription, :warband
    assert_equal warbands(:one), subscription.warband
  end

  test "should allow same user to subscribe to different campaigns" do
    warband = warbands(:two)
    subscription = Subscription.new(
      user: users(:two),
      campaign: campaigns(:four),
      warband: warband
    )
    assert subscription.save, "Should allow same user to subscribe to different campaigns"
  end

  test "should allow different users to subscribe to same campaign" do
    subscription = Subscription.new(
      user: users(:three),
      campaign: campaigns(:one),
      warband: warbands(:three)
    )
    assert subscription.save, "Should allow different users to subscribe to same campaign"
  end

  test "should not allow warband belonging to another user" do
    subscription = Subscription.new(
      user: users(:three),
      campaign: campaigns(:four),
      warband: warbands(:two)  # belongs to user :two
    )
    assert_not subscription.save, "Saved subscription with another user's warband"
    assert_includes subscription.errors[:warband], "debe pertenecer al usuario"
  end

  test "should not allow warband already assigned to another campaign" do
    subscription = Subscription.new(
      user: users(:two),
      campaign: campaigns(:four),
      warband: warbands(:one)  # already assigned to campaign :one
    )
    assert_not subscription.save, "Saved subscription with warband already in another campaign"
    assert_includes subscription.errors[:warband], "ya está asignada a otra campaña"
  end

  test "should allow subscription without warband" do
    subscription = Subscription.new(
      user: users(:three),
      campaign: campaigns(:four)
    )
    assert subscription.save, "Should allow subscription without warband (for campaign creator)"
  end

  test "should assign warband to campaign after creation" do
    warband = warbands(:two)
    assert_nil warband.campaign_id, "Warband should start without campaign"

    Subscription.create!(
      user: users(:two),
      campaign: campaigns(:four),
      warband: warband
    )

    warband.reload
    assert_equal campaigns(:four).id, warband.campaign_id, "Warband should be assigned to campaign"
  end

  test "should remove warband from campaign after destruction" do
    subscription = subscriptions(:one)
    warband = subscription.warband

    assert_equal campaigns(:one).id, warband.campaign_id, "Warband should be in campaign"

    subscription.destroy

    warband.reload
    assert_nil warband.campaign_id, "Warband should be removed from campaign"
  end
end
