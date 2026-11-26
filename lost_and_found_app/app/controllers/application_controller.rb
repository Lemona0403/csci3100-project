class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def require_login
    authenticate_user!
  end

  def require_staff
    redirect_to root_path, alert: "Staff access only." unless current_user&.staff?
  end

  def parse_filter_date(value)
    return if value.blank?
    return unless value.is_a?(String) && value.match?(/\A\d{4}-\d{2}-\d{2}\z/)

    Date.iso8601(value)
  rescue ArgumentError
    nil
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name role facility_id])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name role facility_id])
  end

  def ensure_same_facility(record)
    unless current_user&.staff? && record&.facility_id == current_user.facility_id
      redirect_to root_path, alert: "You can only manage records at your facility."
    end
  end
end
