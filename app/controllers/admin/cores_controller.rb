module Admin
  class CoresController < ApplicationController
    def index
      # 重定向到仪表盘或其他页面
      redirect_to tasks_path
    end
  end
end 