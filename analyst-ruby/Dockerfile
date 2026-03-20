FROM ruby:3.3-alpine

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache build-base

# Copy Gemfile
COPY Gemfile* ./

# Install gems
RUN bundle install

# Copy application
COPY . .

EXPOSE 4567

CMD ["bundle", "exec", "ruby", "app.rb"]
