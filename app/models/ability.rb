class Ability
  include CanCan::Ability

  def initialize(user)
    # 定义所有用户的权限
    user ||= AdminUser.new # 游客

    if user.super_admin?
      # 超级管理员可以管理所有内容
      can :manage, :all
    else
      # 普通编辑者可以查看所有内容
      can :read, :all
      
      # 普通编辑者可以更新自己的账户
      can :update_self, AdminUser, id: user.id
      
      # 允许编辑自己的账户（这是关键修改）
      can [:edit, :update], AdminUser, id: user.id
      
      # 普通编辑者可以管理用户上下文
      can :manage, UserContext

      can :manage, Task
      can :manage, HolomindContext
    end
  end
end 