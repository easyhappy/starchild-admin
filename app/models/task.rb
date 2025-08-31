class Task < ApplicationRecord
  self.table_name = "task"


  def human_code
    "<pre><code class='python'>#{code}</code></pre>".html_safe
  end

  def human_trigger_history
    trigger_history.map do |event|
      trigger_time = event['trigger_time']
      message = event['message'] || event['error']
      
      <<~HTML
        <div class="trigger-event">
          <span class="timestamp">trigger time: #{trigger_time}</span>
          <pre><code class="python">Trigger content: #{message}</code></pre>
          <pre><code class="python"></code></pre>
        </div>
      HTML
    end.join("</br>------------------------</br>").html_safe
  end

  def subscribed_user_ids
    SubscriptionTask.where(task_id: id).map do |subscription|
      "#{subscription.user_id}, subscribed_at: #{subscription.created_at}"
    end.join("</br>").html_safe
  end

  def self.get_task_stats(from_date, to_date)
    @stats = Task.where("created_at > ?", from_date).where("created_at < ?", to_date).group(:user_id).count
    @stats = @stats.sort_by { |_, count| -count }[0..20].to_h
  end

  # Ransacker for categories filtering
  ransacker :categories_in do |parent|
    Arel::Nodes::SqlLiteral.new("categories")
  end
end
