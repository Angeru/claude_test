require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "anonymous user sees login page" do
    get root_url
    assert_response :success
    assert_select "h1", "Iniciar Sesión"
  end

  test "logged-in user with subscriptions redirects to dashboard" do
    user = users(:one)
    campaign = campaigns(:one)
    user.campaigns << campaign unless user.campaigns.include?(campaign)

    login_as(user)
    get root_url
    assert_redirected_to dashboard_path
  end

  test "logged-in user without subscriptions redirects to campaigns" do
    user = User.create!(
      name: "New User",
      email: "newuser#{rand(10000)}@test.com",
      password: "password",
      role: "user"
    )

    login_as(user)
    get root_url
    assert_redirected_to campaigns_path
  end

  private

  def login_as(user)
    post login_url, params: { email: user.email, password: 'password' }
  end
end
