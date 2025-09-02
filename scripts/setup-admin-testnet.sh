#!/bin/bash

# Setup script for admin-testnet Heroku app
# This script creates the Heroku app and sets up the initial configuration

set -e

APP_NAME="admin-testnet"
REMOTE="heroku-admin-testnet"

echo "🚀 Setting up Admin Testnet Backend..."
echo "🎯 Target: $APP_NAME"

# Check if app already exists
if heroku apps:info -a $APP_NAME >/dev/null 2>&1; then
    echo "✅ App '$APP_NAME' already exists"
else
    echo "📝 Creating Heroku app '$APP_NAME'..."
    heroku apps:create $APP_NAME
    echo "✅ App '$APP_NAME' created successfully"
fi

# Add git remote if it doesn't exist
if git remote get-url $REMOTE >/dev/null 2>&1; then
    echo "✅ Remote '$REMOTE' already exists"
else
    echo "🔗 Adding git remote '$REMOTE'..."
    git remote add $REMOTE https://git.heroku.com/$APP_NAME.git
    echo "✅ Remote '$REMOTE' added"
fi

# Set basic environment variables
echo "🔧 Setting up environment variables..."
heroku config:set SECRET_KEY_BASE=does-not-matter-for-now -a $APP_NAME
heroku config:set RAILS_SERVE_STATIC_FILES=true -a $APP_NAME
heroku config:set RAILS_ENV=production -a $APP_NAME
heroku config:set RAILS_LOG_TO_STDOUT=true -a $APP_NAME
heroku config:set RAILS_FORCE_SSL=false -a $APP_NAME

echo ""
echo "✅ Admin Testnet setup completed!"
echo "🌐 App URL: https://$APP_NAME.herokuapp.com/"
echo ""
echo "Next steps:"
echo "1. Run: ./scripts/deploy-admin-testnet.sh"
echo "2. Add the Heroku domain to allowed hosts in production.rb if needed"
echo ""
echo "🔧 Useful commands:"
echo "heroku logs --tail -a $APP_NAME"
echo "heroku config -a $APP_NAME"
