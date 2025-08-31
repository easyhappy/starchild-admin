class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  # 处理未授权访问
  def access_denied(exception)
    respond_to do |format|
      format.html do
        flash[:error] = exception.message
        puts exception.message
        redirect_back(fallback_location: core_path)
      end
      format.js { head :forbidden, content_type: 'text/html' }
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end
end
