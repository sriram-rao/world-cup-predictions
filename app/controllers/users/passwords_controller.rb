module Users
  class PasswordsController < ApplicationController
    before_action :require_admin
    before_action :set_user

    def edit
    end

    def update
      if params[:password] != params[:password_confirmation]
        flash.now[:alert] = "Passwords do not match."
        render :edit, status: :unprocessable_content
        return
      end

      if @user.update(password: params[:password])
        redirect_to leaderboard_path, notice: "Password reset for #{@user.username}."
      else
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_content
      end
    end

    private
      def require_admin
        redirect_to root_path, alert: "Admins only." unless Current.user&.admin?
      end

      def set_user
        @user = User.find(params[:user_id])
      end
  end
end
