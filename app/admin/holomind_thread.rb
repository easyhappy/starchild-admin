ActiveAdmin.register HolomindThread do
  menu priority: 5, label: "Holomind Thread"

  actions :all, :detail
  filter :userid
  filter :thread_id

  controller do
    def index
      super
    end

    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, HolomindThread
    end
  end

  filter :user_id
  config.sort_order = 'created_at_desc'

  permit_params :user_id

  index do
    selectable_column
    column :thread_id_text
    column :userid
    column :title
    column :created_at
    actions defaults: false do |context|
      item "View", "/holomind_threads/detail?thread_id=#{context.thread_id}&user_id=#{context.userid}"
    end
  end

  collection_action :detail do
    @holomind_thread = HolomindThread.find_by(thread_id: params[:thread_id], userid: params[:user_id])

    @thread_title = @holomind_thread&.title
    if params[:thread_id] == "-"
      @thread_title = "TG bot chat"
    end
    @thread_id = params[:thread_id]
    @user_id = params[:user_id]
    @holomind_contexts = HolomindContext.where(thread_id: params[:thread_id], user_id: params[:user_id]).order(created_at: :asc).compact
    puts "holomind_contexts: #{@holomind_contexts.count}"
    render :detail
  end
end
