ActiveAdmin.register_page "Core" do
  menu priority: 1, label: "Dashboard"
  
  content title: "Dashboard" do
    columns do
      column do
        panel "Users" do
          para "Total: #{User.count}"
        end
      end
      
      column do
        panel "Chat Threads" do
          para "Total: #{HolomindThread.count}"
        end
      end
    end
  end
end