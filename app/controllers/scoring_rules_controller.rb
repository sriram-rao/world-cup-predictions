class ScoringRulesController < ApplicationController
  allow_unauthenticated_access only: :show
  before_action :set_rule
  before_action :require_admin, only: :update

  def show
  end

  def update
    if @rule.update(rule_params)
      redirect_to scoring_rules_path, notice: "Rules updated."
    else
      render :show, status: :unprocessable_content
    end
  end

  private
    def set_rule
      @rule = ScoringRule.current
    end

    def require_admin
      redirect_to scoring_rules_path, alert: "Admins only." unless Current.user&.admin?
    end

    def rule_params
      params.require(:scoring_rule).permit(:outcome_points, :goal_difference_points, :exact_score_points)
    end
end
