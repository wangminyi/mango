class HistoryLogsController < ApplicationController
  before_action :require_login

  def create
    # 命名不慎啊 T.T
    current_user.history_logs.create(history_params.merge(action: params[:action_type]))
    head :ok
  end

  private
    def history_params
      params.permit(
        :details
      )
    end
end
