module Respondable
  extend ActiveSupport::Concern

  def respond_html_or_json(redirect: false, action: nil, error: nil, object: {}, status: :ok)
    respond_to do |format|
      format.html do
        flash[:error] = error
        if redirect && action
          redirect_to action
        elsif action && !redirect
          render action
        end
      end
      format.json do
        if error
          render json: { error: error }, status: :bad_request
        else
          render json: object, status: status
        end
      end
    end
  end
end