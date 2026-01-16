# VaultEdge Analyst Tools (Ruby / Sinatra)
FROM ruby:3.3-alpine

# Set working directory
WORKDIR /app

# Install native dependencies for Mongo + Sinatra
RUN apk add --no-cache build-base

# Copy Ruby app
COPY . .

# Install dependencies
RUN gem install bundler
RUN bundle install

# Expose Sinatra port
EXPOSE 4567

# Start analyst dashboard
CMD ["ruby", "app.rb"]

