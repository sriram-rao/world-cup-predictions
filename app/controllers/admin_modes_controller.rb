class AdminModesController < ApplicationController
  def update
    unless Current.user&.admin?
      redirect_back fallback_location: root_path, alert: "Admins only."
      return
    end

    session[:admin_mode] = ActiveModel::Type::Boolean.new.cast(params[:enabled])
    redirect_back fallback_location: root_path
  end
end
