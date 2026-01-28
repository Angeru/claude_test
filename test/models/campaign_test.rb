require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  test "should not save campaign without name" do
    campaign = Campaign.new(description: "Test description", user: users(:one))
    assert_not campaign.save, "Saved the campaign without a name"
  end

  test "should not save campaign without description" do
    campaign = Campaign.new(name: "Test Campaign", user: users(:one))
    assert_not campaign.save, "Saved the campaign without a description"
  end

  test "should not save campaign without user" do
    campaign = Campaign.new(name: "Test Campaign", description: "Test description")
    assert_not campaign.save, "Saved the campaign without a user"
  end

  test "should not save campaign with name shorter than 3 characters" do
    campaign = Campaign.new(name: "Ab", description: "Test description", user: users(:one))
    assert_not campaign.save, "Saved the campaign with name shorter than 3 characters"
  end

  test "should validate status inclusion" do
    campaign = campaigns(:one)
    campaign.status = "invalid_status"
    assert_not campaign.valid?, "Campaign is valid with an invalid status"
    assert campaign.errors[:status].any?, "Should have errors on status"
  end

  test "should validate end_date after start_date" do
    campaign = Campaign.new(
      name: "Test Campaign",
      description: "Test description",
      user: users(:one),
      start_date: Date.today,
      end_date: Date.today - 1.day
    )
    assert_not campaign.valid?, "Campaign is valid with end_date before start_date"
    assert_includes campaign.errors[:end_date], "debe ser posterior a la fecha de inicio"
  end

  test "should have many subscribers through subscriptions" do
    campaign = campaigns(:one)
    assert_respond_to campaign, :subscribers
    assert_kind_of User, campaign.subscribers.first
  end

  test "should belong to user" do
    campaign = campaigns(:one)
    assert_respond_to campaign, :user
    assert_equal users(:one), campaign.user
  end

  test "active? should return true for active campaigns" do
    campaign = campaigns(:one)
    assert campaign.active?, "active? should return true for active campaigns"
  end

  test "paused? should return true for paused campaigns" do
    campaign = campaigns(:four)
    assert campaign.paused?, "paused? should return true for paused campaigns"
  end

  test "finished? should return true for finished campaigns" do
    campaign = campaigns(:three)
    assert campaign.finished?, "finished? should return true for finished campaigns"
  end

  test "should destroy associated subscriptions when campaign is destroyed" do
    campaign = campaigns(:one)
    subscription_count = campaign.subscriptions.count
    assert subscription_count > 0, "Campaign should have subscriptions"

    campaign.destroy
    assert_equal 0, Subscription.where(campaign_id: campaign.id).count,
                 "Associated subscriptions should be destroyed"
  end
end
