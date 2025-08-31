module ApplicationHelper
  # 安全地将对象转换为字符串
  def safe_to_s(obj)
    obj.nil? ? "" : obj.to_s
  end
end
