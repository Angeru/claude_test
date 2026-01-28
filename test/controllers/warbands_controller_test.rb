require "test_helper"

class WarbandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)
    @warband = warbands(:one)
    log_in_as(@user)
  end

  test "should require login for all actions" do
    log_out

    get warbands_url
    assert_redirected_to login_url

    get warband_url(@warband)
    assert_redirected_to login_url
  end

  test "should get index" do
    get warbands_url
    assert_response :success
  end

  test "should get new" do
    get new_warband_url
    assert_response :success
  end

  test "should create warband" do
    assert_difference("Warband.count") do
      post warbands_url, params: { warband: { name: "Nueva Warband" } }
    end

    assert_redirected_to warbands_url
  end

  test "should not create warband with invalid data" do
    assert_no_difference("Warband.count") do
      post warbands_url, params: { warband: { name: "AB" } }
    end

    assert_response :unprocessable_entity
  end

  test "should show own warband" do
    get warband_url(@warband)
    assert_response :success
  end

  test "should not show other user warband if not in same campaign" do
    other_warband = warbands(:three)

    get warband_url(other_warband)
    assert_redirected_to warbands_url
  end

  test "should get edit for own warband" do
    get edit_warband_url(@warband)
    assert_response :success
  end

  test "should not get edit for other user warband" do
    other_warband = warbands(:three)

    get edit_warband_url(other_warband)
    assert_redirected_to warbands_url
  end

  test "should update own warband" do
    patch warband_url(@warband), params: { warband: { name: "Nombre Actualizado" } }
    assert_redirected_to warbands_url

    @warband.reload
    assert_equal "Nombre Actualizado", @warband.name
  end

  test "should not update other user warband" do
    other_warband = warbands(:three)

    patch warband_url(other_warband), params: { warband: { name: "Hacked" } }
    assert_redirected_to warbands_url

    other_warband.reload
    assert_not_equal "Hacked", other_warband.name
  end

  test "should destroy own warband" do
    assert_difference("Warband.count", -1) do
      delete warband_url(@warband)
    end

    assert_redirected_to warbands_url
  end

  test "should not destroy other user warband" do
    other_warband = warbands(:three)

    assert_no_difference("Warband.count") do
      delete warband_url(other_warband)
    end

    assert_redirected_to warbands_url
  end

  test "should remove warband from campaign" do
    patch remove_from_campaign_warband_url(@warband)

    @warband.reload
    assert_nil @warband.campaign_id
    assert_redirected_to warbands_url
  end

  private

  def log_in_as(user)
    post login_url, params: { email: user.email, password: "password123" }
  end

  def log_out
    delete logout_url
  end
end
