class ScoringRulesController < ApplicationController
  allow_unauthenticated_access only: %i[show var_robbed_me]
  before_action :require_admin, only: :update

  def show
    set_leaderboard(Leaderboard.standard)
  end

  def var_robbed_me
    set_leaderboard(Leaderboard.var_robbed_me)
    render :show
  end

  def update
    @leaderboard = leaderboard_for_variant

    if @leaderboard.update(leaderboard_params)
      redirect_to redirect_rules_path, notice: "Rules updated."
    else
      set_leaderboard(@leaderboard)
      render :show, status: :unprocessable_content
    end
  end

  private
    def set_leaderboard(leaderboard)
      @leaderboard = leaderboard
      @title = leaderboard.slug == Leaderboard::STANDARD_SLUG ? "Rules" : "#{leaderboard.name} Rules"
      @description = leaderboard.description
      @leaderboard_path = leaderboard.slug == Leaderboard::STANDARD_SLUG ? leaderboard_path : named_leaderboard_path(leaderboard.slug)
      @other_rules_label = leaderboard.slug == Leaderboard::STANDARD_SLUG ? "VAR Robbed Me rules" : "Standard rules"
      @other_rules_path = leaderboard.slug == Leaderboard::STANDARD_SLUG ? var_robbed_me_scoring_rules_path : scoring_rules_path
      @variant = leaderboard.slug
      @labels = [
        ["Correct outcome", :outcome_description, :outcome_points],
        ["Correct signed goal difference", :goal_difference_description, :goal_difference_points],
        ["Exact score", :exact_score_description, :exact_score_points]
      ]
    end

    def require_admin
      redirect_to scoring_rules_path, alert: "Admins only." unless admin_mode?
    end

    def leaderboard_for_variant
      params[:variant] == Leaderboard::VAR_ROBBED_ME_SLUG ? Leaderboard.var_robbed_me : Leaderboard.standard
    end

    def redirect_rules_path
      @leaderboard.slug == Leaderboard::VAR_ROBBED_ME_SLUG ? var_robbed_me_scoring_rules_path : scoring_rules_path
    end

    def leaderboard_params
      params.require(:leaderboard).permit(
        :outcome_points,
        :goal_difference_points,
        :exact_score_points,
        :outcome_description,
        :goal_difference_description,
        :exact_score_description
      )
    end
end
