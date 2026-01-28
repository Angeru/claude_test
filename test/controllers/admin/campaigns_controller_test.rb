require "test_helper"

class Admin::CampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @regular_user = users(:two)
    @campaign = campaigns(:one)
  end

  # Authentication tests
  test "should redirect to login when not logged in" do
    get admin_campaigns_url
    assert_redirected_to login_path
  end

  test "should redirect to dashboard when not admin" do
    log_in_as(@regular_user)
    get admin_campaigns_url
    assert_redirected_to dashboard_path
    assert_equal "No tienes permisos para acceder a esta sección", flash[:alert]
  end

  # Index tests
  test "should get index as admin" do
    log_in_as(@admin)
    get admin_campaigns_url
    assert_response :success
  end

  # New tests
  test "should get new as admin" do
    log_in_as(@admin)
    get new_admin_campaign_url
    assert_response :success
  end

  # Create tests
  test "should create campaign as admin" do
    log_in_as(@admin)
    assert_difference("Campaign.count") do
      post admin_campaigns_url, params: {
        campaign: {
          name: "Nueva Campaña de Test",
          description: "Descripción de prueba para la campaña",
          status: "activa"
        }
      }
    end
    assert_redirected_to admin_campaigns_url
    assert_equal "Campaña creada correctamente", flash[:notice]
  end

  test "should not create campaign with invalid data" do
    log_in_as(@admin)
    assert_no_difference("Campaign.count") do
      post admin_campaigns_url, params: {
        campaign: {
          name: "Ab",  # Too short
          description: "Test",
          status: "activa"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  # Show tests
  test "should show campaign as admin" do
    log_in_as(@admin)
    get admin_campaign_url(@campaign)
    assert_response :success
  end

  # Edit tests
  test "should get edit as admin" do
    log_in_as(@admin)
    get edit_admin_campaign_url(@campaign)
    assert_response :success
  end

  # Update tests
  test "should update campaign as admin" do
    log_in_as(@admin)
    patch admin_campaign_url(@campaign), params: {
      campaign: {
        name: "Nombre Actualizado"
      }
    }
    assert_redirected_to admin_campaigns_url
    @campaign.reload
    assert_equal "Nombre Actualizado", @campaign.name
    assert_equal "Campaña actualizada correctamente", flash[:notice]
  end

  test "should not update campaign with invalid data" do
    log_in_as(@admin)
    patch admin_campaign_url(@campaign), params: {
      campaign: {
        name: "A"  # Too short
      }
    }
    assert_response :unprocessable_entity
  end

  # Destroy tests
  test "should destroy campaign as admin" do
    log_in_as(@admin)
    assert_difference("Campaign.count", -1) do
      delete admin_campaign_url(@campaign)
    end
    assert_redirected_to admin_campaigns_url
    assert_equal "Campaña eliminada correctamente", flash[:notice]
  end

  # Manage subscriptions tests
  test "should get manage_subscriptions as admin" do
    log_in_as(@admin)
    get manage_subscriptions_admin_campaign_url(@campaign)
    assert_response :success
  end

  test "should update subscriptions as admin" do
    log_in_as(@admin)
    patch update_subscriptions_admin_campaign_url(@campaign), params: {
      campaign: {
        subscriber_ids: [users(:two).id, users(:three).id]
      }
    }
    assert_redirected_to admin_campaign_path(@campaign)
    assert_equal "Suscripciones actualizadas correctamente", flash[:notice]
  end
end
