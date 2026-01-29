class ApplicationController < ActionController::Base
  # Session timeout configuration
  SESSION_TIMEOUT = 15.minutes

  # Check session timeout before processing any action
  before_action :check_session_timeout

  helper_method :current_user, :logged_in?, :campaign_owner?, :can_manage_warband?,
                :campaign_subscriber?, :can_manage_campaign?, :can_view_campaign?,
                :user_has_subscriptions?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      session[:return_to] = request.fullpath if request.get?
      redirect_to login_path, alert: "Debes iniciar sesión para acceder a esta página"
    end
  end

  # Session timeout checking
  def check_session_timeout
    return unless session[:user_id].present?

    if session[:last_activity_at].present?
      last_activity = Time.parse(session[:last_activity_at])

      if last_activity < SESSION_TIMEOUT.ago
        # Session expired due to inactivity
        session[:return_to] = request.fullpath if request.get?
        reset_session
        redirect_to login_path, alert: "Tu sesión ha expirado por inactividad. Por favor, inicia sesión nuevamente."
        return
      end
    end

    # Update last activity timestamp
    reset_session_activity
  end

  def reset_session_activity
    session[:last_activity_at] = Time.current.iso8601
  end

  def campaign_owner?(campaign)
    campaign.user == current_user
  end

  def can_manage_warband?(warband)
    warband.user == current_user ||
      (warband.campaign.present? && warband.campaign.user == current_user)
  end

  # Check if user is subscribed to a campaign (includes owner)
  def campaign_subscriber?(campaign)
    campaign.user == current_user || campaign.subscribers.include?(current_user)
  end

  # Check if user can manage campaign content (owner or admin)
  def can_manage_campaign?(campaign)
    current_user.admin? || campaign.user == current_user
  end

  # Check if user can view campaign content (subscriber, owner, or admin)
  def can_view_campaign?(campaign)
    current_user.admin? || campaign_subscriber?(campaign)
  end

  # Check if user has any campaign subscriptions
  def user_has_subscriptions?
    logged_in? && current_user.campaigns.exists?
  end
end
