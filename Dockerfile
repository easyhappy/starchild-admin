FROM ruby:3.2.1-alpine3.17
WORKDIR /app
COPY . .
RUN apk update && apk add --virtual build-dependencies build-base libpq-dev libc6-compat tzdata gcompat
RUN bundle config set --local without 'development test'
RUN bundle install
ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
RUN DATABASE_URL='postgresql://fake' \
    SECRET_KEY_BASE=foo \
    rake assets:precompile
CMD rails s -u puma

# 安装依赖
COPY Gemfile Gemfile.lock ./
RUN bundle install