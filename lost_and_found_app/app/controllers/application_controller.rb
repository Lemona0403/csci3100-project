class ApplicationController < ActionController::Base
  helper_method :current_user
  
  protected

  def require_login
    @current_user ||= User.find_by_id(session[:user_id])
    redirect_to login_path, alert: 'You must be logged in.' and return unless @current_user
  end

  def require_staff
    @current_user ||= User.find_by_id(session[:user_id])
    redirect_to root_path, alert: 'Staff access only.' and return unless @current_user&.staff?
  end

  def ensure_same_facility(target = @claim_or_item)
    @current_user ||= User.find_by_id(session[:user_id])
    target_facility_id = nil
    target_facility_id = target.facility_id if target.respond_to?(:facility_id)
    redirect_to root_path, alert: 'Your can only manage item of your own facility.' and return unless @current_user&.facility_id && @current_user.facility_id == target_facility_id
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
end
