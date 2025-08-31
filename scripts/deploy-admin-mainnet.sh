#!/bin/bash

# Admin Backend Deployment Script
# Usage: ./scripts/deploy-admin-mainnet.sh [branch]
# Example: ./scripts/deploy-admin-mainnet.sh main

set -e

BRANCH=${1:-main}
# Use a dedicated remote alias to avoid clashing with other apps
REMOTE="heroku-admin"
APP_NAME="admin-mainnet"

echo "🚀 Deploying Admin Backend..."
echo "📦 Branch: $BRANCH"
echo "🎯 Target: $APP_NAME"

echo "🔄 Pulling latest changes from origin..."
git pull origin main || echo "No changes to pull"

echo "🔄 Pushing latest changes to origin..."
git push origin main || echo "No changes to push"

# Ensure the remote exists and points to the correct Heroku app
echo "🔍 Checking git remotes..."
if git remote get-url $REMOTE >/dev/null 2>&1; then
    echo "✅ Using existing remote: $REMOTE"
else
    echo "ℹ️  Adding remote '$REMOTE' for app '$APP_NAME'"
    git remote add $REMOTE https://git.heroku.com/$APP_NAME.git
fi

if heroku git:remote -a $APP_NAME -r $REMOTE >/dev/null 2>&1; then
    echo "✅ Linked remote '$REMOTE' to app '$APP_NAME'"
else
    echo "❌ Failed to link remote. Ensure the Heroku app '$APP_NAME' exists and you have access."
    echo "   Create app manually: heroku apps:create $APP_NAME"
    exit 1
fi

# Create Procfile for Rails admin app if it doesn't exist
echo "📝 Setting up Rails Admin Procfile..."
if [ ! -f "Procfile.admin" ]; then
    cat > Procfile.admin << 'PROCFILE_EOF'
web: bundle exec puma -b tcp://0.0.0.0:$PORT
release: bundle exec rails db:migrate
PROCFILE_EOF
    echo "✅ Created Procfile.admin"
fi

# Backup existing Procfile if it exists
if [ -f "Procfile" ]; then
    cp Procfile Procfile.backup
    echo "📋 Backed up existing Procfile"
fi

# Copy the admin Procfile
cp Procfile.admin Procfile

echo "🔧 Configuring environment variables..."
heroku config:set SECRET_KEY_BASE=does-not-matter-for-now -a $APP_NAME
heroku config:set RAILS_SERVE_STATIC_FILES=true -a $APP_NAME
heroku config:set RAILS_ENV=production -a $APP_NAME
heroku config:set RAILS_LOG_TO_STDOUT=true -a $APP_NAME
heroku config:set RAILS_FORCE_SSL=false -a $APP_NAME

# Set buildpacks (Ruby first)
echo "📦 Setting up buildpacks..."
heroku buildpacks:clear -a $APP_NAME
heroku buildpacks:add heroku/ruby -a $APP_NAME

# Ensure Gemfile exists
if [ ! -f "Gemfile" ]; then
    echo "❌ Gemfile not found in root directory"
    exit 1
fi

# Create app.json for Heroku configuration if it doesn't exist
if [ ! -f "app.json" ]; then
    echo "📝 Creating app.json..."
    cat > app.json << 'APPJSON_EOF'
{
  "name": "Admin Backend",
  "description": "Rails admin management system",
  "repository": "https://github.com/your-username/starchild-admin",
  "keywords": ["ruby", "rails", "admin", "management"],
  "env": {
    "SECRET_KEY_BASE": {
      "description": "Rails secret key base",
      "value": "does-not-matter-for-now"
    },
    "RAILS_SERVE_STATIC_FILES": {
      "description": "Serve static files",
      "value": "true"
    },
    "RAILS_ENV": {
      "description": "Rails environment",
      "value": "production"
    },
    "RAILS_LOG_TO_STDOUT": {
      "description": "Log to stdout",
      "value": "true"
    },
    "RAILS_FORCE_SSL": {
      "description": "Force SSL",
      "value": "false"
    }
  },
  "buildpacks": [
    {
      "url": "heroku/ruby"
    }
  ],
  "formation": {
    "web": {
      "quantity": 1,
      "size": "basic"
    }
  }
}
APPJSON_EOF
    git add app.json
    git commit -m "Add app.json for Heroku configuration" || echo "No changes to commit"
fi

echo ""
echo "📤 Pushing $BRANCH to $REMOTE (app: $APP_NAME)..."
git add Procfile
git commit -m "Update Procfile for admin deployment" || echo "No changes to commit"
git push $REMOTE $BRANCH:main

# Restore original Procfile
echo "🔄 Restoring original Procfile..."
if [ -f "Procfile.backup" ]; then
    mv Procfile.backup Procfile
    echo "✅ Restored original Procfile"
else
    rm Procfile
    echo "✅ Removed temporary Procfile"
fi

# Additional git push to origin (optional)
echo "📤 Pushing to origin..."

echo ""
echo "✅ Admin Backend deployment completed!"
echo "🌐 App URL: https://$APP_NAME.herokuapp.com/"
echo "📊 Logs: heroku logs --tail -a $APP_NAME"
echo ""
echo "🧪 Test the admin system:"
echo "curl https://$APP_NAME.herokuapp.com/"
echo ""
echo "🔧 Useful commands:"
echo "heroku logs --tail -a $APP_NAME"
echo "heroku run bash -a $APP_NAME"
echo "heroku config -a $APP_NAME"
echo "heroku run rails console -a $APP_NAME"
echo ""
echo "📋 Database commands:"
echo "heroku run rails db:migrate -a $APP_NAME"
echo "heroku run rails db:seed -a $APP_NAME"
