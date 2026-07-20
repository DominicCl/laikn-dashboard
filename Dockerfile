# Use the same Ruby version as your generated file
FROM ruby:3.3.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libvips

# Set up app directory
WORKDIR /rails

# Install Gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy code
COPY . .

# Run in Development mode (So we can see errors and don't need strict keys)
ENV RAILS_ENV=development

# Start the server
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]