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

  test "should allow same user to subscribe to different campaigns" do
    subscription = Subscription.new(
      user: users(:two),
      campaign: campaigns(:four)
    )
    assert subscription.save, "Should allow same user to subscribe to different campaigns"
  end

  test "should allow different users to subscribe to same campaign" do
    subscription = Subscription.new(
      user: users(:three),
      campaign: campaigns(:one)
    )
    assert subscription.save, "Should allow different users to subscribe to same campaign"
  end
end
