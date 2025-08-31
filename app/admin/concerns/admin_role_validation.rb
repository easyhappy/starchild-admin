module AdminRoleValidation
  extend ActiveSupport::Concern

  included do
    before_action :validate_admin_access
  end

  private

  def validate_admin_access
    return true
    # if Rails.env.development?
    #   return true
    # end

    # if ENV["ADMIN_VIEWER_LIST"]&.split(",")&.include?(request.headers["X-Forwarded-Email"])
    #   return true
    # end

    # flash[:error] = "sorry, don't have access, please contact with administrator"
    # redirect_to dashboard_path 
  end
end
