class HolomindContext < ApplicationRecord
  self.table_name = "holomind_context"

  def updated_at
    content["last_interaction_time"]
  end

  def user_query
    content["user_query"]
  end

  def agent_response
    content["agent_response"]
  end

  def token_info
    if content["token_info"].present?
      JSON.parse(content["token_info"])["id"]
    else
      "N/A"
    end
  rescue
    "N/A"
  end

  def kline_image
    if content["kline_charts"].present?
      JSON.parse(content["kline_charts"])["charts"][0]["url"]
    else
      "N/A"
    end
  rescue
    "N/A"
  end

  def self.get_user_stats(from_date, to_date)
    @stats = HolomindContext.where("created_at > ?", from_date).where("created_at < ?", to_date).group(:user_id).count
    @stats = @stats.sort_by { |_, count| -count }[0..20].to_h
  end
end
