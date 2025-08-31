class HolomindThread < ApplicationRecord
  self.table_name = "holomind_threads"

  def updated_at
    content["last_interaction_time"]
  end

  def thread_id_text
    if self.thread_id == "-"
      "tg bot thread"
    else
      self.thread_id
    end
  end
end