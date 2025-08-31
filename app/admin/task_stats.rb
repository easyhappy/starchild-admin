ActiveAdmin.register_page "Task Stats" do
  menu priority: 5, label: "Task Stats"

  
  page_action :index do
    @page_title = "Task Stats"
    @tasks = Task.order(subscription_user_count: :desc).limit(20)
    render "tasks/stats", layout: "active_admin"
  end
end