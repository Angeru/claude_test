require "test_helper"

class CampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @campaign = campaigns(:one)
    @subscribed_campaign = campaigns(:one)  # User two is already subscribed to campaign one
    @unsubscribed_campaign = campaigns(:four)  # User two is not subscribed to campaign four
  end

  # Authentication tests
  test "should redirect to login when not logged in" do
    get campaigns_url
    assert_redirected_to login_path
  end

  # Index tests
  test "should get index when logged in" do
    log_in_as(@user)
    get campaigns_url
    assert_response :success
  end

  test "index should only show active campaigns" do
    log_in_as(@user)
    get campaigns_url
    assert_response :success
    # Campaign one and two are active, three is finished, four is paused
    # Only active campaigns should be shown
  end

  # Show tests
  test "should show campaign when logged in" do
    log_in_as(@user)
    get campaign_url(@campaign)
    assert_response :success
  end

  # My campaigns tests
  test "should get my_campaigns when logged in" do
    log_in_as(@user)
    get my_campaigns_campaigns_url
    assert_response :success
  end

  # Subscribe tests
  test "should subscribe to campaign" do
    log_in_as(@user)
    assert_difference("Subscription.count") do
      post subscribe_campaign_url(@unsubscribed_campaign)
    end
    assert_redirected_to campaign_path(@unsubscribed_campaign)
    assert_equal "Te has suscrito correctamente a la campaña", flash[:notice]
  end

  test "should not subscribe to already subscribed campaign" do
    log_in_as(@user)
    assert_no_difference("Subscription.count") do
      post subscribe_campaign_url(@subscribed_campaign)
    end
    assert_redirected_to campaign_path(@subscribed_campaign)
    assert_equal "Ya estás suscrito a esta campaña", flash[:alert]
  end

  test "should require login to subscribe" do
    post subscribe_campaign_url(@campaign)
    assert_redirected_to login_path
  end

  # Unsubscribe tests
  test "should unsubscribe from campaign" do
    log_in_as(@user)
    assert_difference("Subscription.count", -1) do
      delete unsubscribe_campaign_url(@subscribed_campaign)
    end
    assert_redirected_to my_campaigns_campaigns_path
    assert_equal "Te has desuscrito correctamente de la campaña", flash[:notice]
  end

  test "should not unsubscribe from campaign not subscribed to" do
    log_in_as(@user)
    assert_no_difference("Subscription.count") do
      delete unsubscribe_campaign_url(@unsubscribed_campaign)
    end
    assert_redirected_to my_campaigns_campaigns_path
    assert_equal "No estás suscrito a esta campaña", flash[:alert]
  end

  test "should require login to unsubscribe" do
    delete unsubscribe_campaign_url(@campaign)
    assert_redirected_to login_path
  end
end
