require "test_helper"

class Admin::WarbandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @regular_user = users(:two)
    @warband = warbands(:one)
  end

  # Authentication tests
  test "should redirect to login when not logged in" do
    get admin_warbands_url
    assert_redirected_to login_path
  end

  test "should redirect to dashboard when not admin" do
    log_in_as(@regular_user)
    get admin_warbands_url
    assert_redirected_to dashboard_path
    assert_equal "No tienes permisos para acceder a esta sección", flash[:alert]
  end

  # Index tests
  test "should get index as admin" do
    log_in_as(@admin)
    get admin_warbands_url
    assert_response :success
  end

  # New tests
  test "should get new as admin" do
    log_in_as(@admin)
    get new_admin_warband_url
    assert_response :success
  end

  # Create tests
  test "should create warband as admin" do
    log_in_as(@admin)
    assert_difference("Warband.count") do
      post admin_warbands_url, params: {
        warband: {
          name: "Nueva Warband de Test",
          user_id: @regular_user.id
        }
      }
    end
    assert_redirected_to admin_warbands_url
    assert_equal "Warband creada correctamente", flash[:notice]
  end

  test "should not create warband with invalid data" do
    log_in_as(@admin)
    assert_no_difference("Warband.count") do
      post admin_warbands_url, params: {
        warband: {
          name: "Ab",  # Too short
          user_id: @regular_user.id
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Show tests
  test "should show warband as admin" do
    log_in_as(@admin)
    get admin_warband_url(@warband)
    assert_response :success
  end

  # Edit tests
  test "should get edit as admin" do
    log_in_as(@admin)
    get edit_admin_warband_url(@warband)
    assert_response :success
  end

  # Update tests
  test "should update warband as admin" do
    log_in_as(@admin)
    patch admin_warband_url(@warband), params: {
      warband: {
        name: "Nombre Actualizado"
      }
    }
    assert_redirected_to admin_warbands_url
    @warband.reload
    assert_equal "Nombre Actualizado", @warband.name
    assert_equal "Warband actualizada correctamente", flash[:notice]
  end

  test "should not update warband with invalid data" do
    log_in_as(@admin)
    patch admin_warband_url(@warband), params: {
      warband: {
        name: "A"  # Too short
      }
    }
    assert_response :unprocessable_entity
  end

  # Destroy tests
  test "should destroy warband as admin" do
    log_in_as(@admin)
    assert_difference("Warband.count", -1) do
      delete admin_warband_url(@warband)
    end
    assert_redirected_to admin_warbands_url
    assert_equal "Warband eliminada correctamente", flash[:notice]
  end

  # Remove from campaign tests
  test "should remove warband from campaign as admin" do
    log_in_as(@admin)
    assert @warband.campaign.present?, "Warband should have a campaign before test"

    patch remove_from_campaign_admin_warband_url(@warband)

    assert_redirected_to admin_warband_path(@warband)
    @warband.reload
    assert_nil @warband.campaign
    assert_equal "Warband removida de la campaña", flash[:notice]
  end
end
