class UserContext < ApplicationRecord
  self.table_name = "user_context"

  def updated_at
    content["last_interaction_time"]
  end

  def title
    content["messages"].first["content"]
  end

  def human_readable_context
    content["messages"].map do |message|
        "<div class='message-item'>" \
        "<span class='message-source'>#{message['source']}</span>: " \
        "<span class='message-content'>#{message['content']}</span>, " \
        "<span class='message-time'>time: #{message['timestamp']}</span>" \
        "</div>"
    end.join("\n")
  end

  def content
    @content ||= JSON.parse(self.context)
  end
end
