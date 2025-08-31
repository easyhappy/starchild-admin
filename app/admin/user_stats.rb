ActiveAdmin.register_page "User Stats" do
  menu priority: 5, label: "User Stats"


  page_action :index do
    @page_title = "User Stats"
    from_date = Time.now.beginning_of_day
    to_date = Time.now.end_of_day
    @today_stats = HolomindContext.get_user_stats(from_date, to_date)
    @today_task_stats = Task.get_task_stats(from_date, to_date)
    @today_subscription_task_stats = SubscriptionTask.get_subscription_task_stats(from_date, to_date)

    from_date = 1.day.ago.beginning_of_day
    to_date = 1.day.ago.end_of_day
    @yesterday_stats = HolomindContext.get_user_stats(from_date, to_date)
    @yesterday_task_stats = Task.get_task_stats(from_date, to_date)
    @yesterday_subscription_task_stats = SubscriptionTask.get_subscription_task_stats(from_date, to_date)

    user_ids = @today_stats.keys + @yesterday_stats.keys + @today_task_stats.keys + @yesterday_task_stats.keys + @today_subscription_task_stats.keys + @yesterday_subscription_task_stats.keys

    @custom_date = nil
    if params[:custom_date].present?
      from_date = params[:custom_date].to_date.beginning_of_day
      to_date = params[:custom_date].to_date.end_of_day
      @custom_date = params[:custom_date]
      @custom_date_stats = HolomindContext.get_user_stats(from_date, to_date)
      @custom_date_task_stats = Task.get_task_stats(from_date, to_date)
      @custom_date_subscription_task_stats = SubscriptionTask.get_subscription_task_stats(from_date, to_date)

      user_ids += @custom_date_stats.keys + @custom_date_task_stats.keys + @custom_date_subscription_task_stats.keys
    end

    user_ids = user_ids.uniq
    @user_info = UserInfo.where(userid: user_ids)
    @user_info = @user_info.map { |user| [user.userid, user.user_name] }.to_h

    render "users/stats", layout: "active_admin"
  end
end