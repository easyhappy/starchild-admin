# README

start dev server with `task compose-up` env

```
DATABASE_URL=postgresql://postgres:postgres@localhost:5438/tg_bot_db_dev RAILS_SERVE_STATIC_FILES=true SECRET_KEY_BASE=asd bundle exec puma -b tcp://0.0.0.0:13333
```

```
DATABASE_URL=postgresql://postgres:postgres@localhost:5438/tg_bot_db_dev rake db:migrate
```



start console with `task compose-up` env

```
DATABASE_URL=postgresql://postgres:postgres@localhost:5436/tg_bot_db_dev RAILS_SERVE_STATIC_FILES=true SECRET_KEY_BASE=asd  bundle exec rails c
```

# JOJO 管理系统

## 功能

- 用户上下文管理
- 管理员用户管理
- 密码修改

## 登录系统

管理员用户可以通过以下步骤登录系统：

1. 访问管理系统网址 (https://mgmt.mainnet.holominds.ai)
2. 输入邮箱和密码
3. 点击"登录"按钮

如果忘记密码，请联系系统管理员重置密码。

## 密码修改

管理员用户可以通过以下几种方式修改自己的密码：

### 方式一：通过用户菜单

1. 登录管理系统
2. 点击右上角的用户名
3. 在下拉菜单中选择"修改密码"
4. 输入当前密码和新密码
5. 点击"更新密码"按钮

### 方式二：通过管理员列表

1. 登录管理系统
2. 进入"管理员用户"页面
3. 在自己的用户行中点击"修改密码"按钮
4. 输入当前密码和新密码
5. 点击"更新密码"按钮

### 方式三：通过用户详情页

1. 登录管理系统
2. 进入"管理员用户"页面
3. 点击自己的用户名进入详情页
4. 点击"修改密码"按钮
5. 输入当前密码和新密码
6. 点击"更新密码"按钮

## 部署

系统使用 Docker 容器部署在 Kubernetes 集群中。部署配置文件位于 `deploy/kustomize/overlays/holomind/ns-default/admin-api-deployment.yaml`。

## 开发

### 环境设置

```
cd admin/activeadmin
bundle install
rails db:migrate
rails server
```

### 添加新功能

1. 创建新的 ActiveAdmin 资源
2. 添加必要的控制器和视图
3. 更新路由配置


```
AdminUser.create()
```
## 📋 Deployment Scripts

### Mainnet Deployment
```bash
./scripts/deploy-admin-mainnet.sh
```

### Testnet Deployment
```bash
./scripts/deploy-admin-testnet.sh
```

**Note:** Before using the testnet script, create the Heroku app first:
```bash
heroku apps:create admin-testnet
```
