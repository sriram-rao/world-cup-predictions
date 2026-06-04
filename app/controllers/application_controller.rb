class ApplicationController < ActionController::Base
  include Authentication
  helper_method :admin_mode?

  def admin_mode?
    Current.user&.admin? && session.fetch(:admin_mode, true)
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
