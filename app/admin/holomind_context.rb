ActiveAdmin.register HolomindContext do
  menu priority: 5, label: "Holomind Context"

  actions :all, :detail
  filter :user_id
  filter :status

  controller do
    def index
      super
    end

    before_action :check_permissions
    
    def check_permissions
      authorize! :manage, HolomindContext
    end
  end

  filter :user_id
  config.sort_order = 'created_at_desc'

  permit_params :user_id

  index do
    selectable_column
    column :msg_id
    column :user_id
    column :user_name
    column :thread_id
    column :user_query
    column :created_at
    actions defaults: false do |context|
      item "View", "/holomind_contexts/detail?id=#{context.msg_id}"
    end

    actions defaults: false do |context|
      item "View Thread", "/holomind_threads/detail?thread_id=#{context.thread_id}&user_id=#{context.user_id}"
    end
  end

  collection_action :detail do
    @holomind_contexts = HolomindContext.where(msg_id: params[:id])
    render :detail
  end
end
