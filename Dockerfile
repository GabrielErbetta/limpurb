FROM ruby:2.6.3-alpine3.9

WORKDIR /app
ENV APP_ENV production

RUN apk add --no-cache --update bash build-base cmake git openssh openssl-dev

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle install --jobs `grep -c processor /proc/cpuinfo` --retry 5

COPY . .

RUN mkdir -p log/
RUN chmod 700 ssh_script.sh

EXPOSE 4567
CMD ["ruby", "api.rb"]
