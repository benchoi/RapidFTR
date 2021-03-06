class Api::ApiController < ActionController::Base

  include Security::Authentication

  before_filter :check_authentication
  before_filter :check_device_blacklisted
  before_filter :extend_session_lifetime
  before_filter :current_user

  private

  rescue_from(Exception) do |e|
    render_error_response ErrorResponse.internal_server_error "session.internal_server_error"
  end
  rescue_from(CanCan::AccessDenied) do |e|
    render_error_response ErrorResponse.forbidden "session.forbidden"
  end
  rescue_from(ErrorResponse) do |e|
    render_error_response e
  end
  rescue_from(ActiveSupport::JSON.parse_error) do |e|
    render_error_response ErrorResponse.new 422, "session.invalid_request"
  end

  def session_expiry_timeout
    Rails.application.config.session_options[:rapidftr][:mobile_expire_after]
  end

  def check_device_blacklisted
    raise ErrorResponse.forbidden("session.device_blacklisted") if current_session && current_session.device_blacklisted?
  end

  def render_error_response(e)
    render status: e.status_code, text: e.message
  end

  def extend_session_lifetime
    session[:last_access_time] = Clock.now.rfc2822
  end

  def sanitize_params(object)
    params[object.to_sym] = JSON.parse(params[object.to_sym]) if params[object.to_sym].is_a?(String)
  end

end
