class SubscriptionTask < ApplicationRecord
  self.table_name = "subscription_task"

  def self.get_subscription_task_stats(from_date, to_date)
    @stats = SubscriptionTask.where("created_at > ?", from_date).where("created_at < ?", to_date).group(:user_id).count
    @stats = @stats.sort_by { |_, count| -count }[0..20].to_h
  end
end
