# Configure session store with security settings
Rails.application.config.session_store :cookie_store,
  key: '_claude_test_session',
  expire_after: 2.hours,  # Absolute maximum session lifetime
  secure: Rails.env.production?,  # HTTPS only in production
  httponly: true,  # Prevent JavaScript access
  same_site: :lax  # CSRF protection
