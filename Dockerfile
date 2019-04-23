FROM ruby:2.6.3-alpine3.9

WORKDIR /app
ENV APP_ENV production

RUN apk add --no-cache --update bash build-base cmake openssl-dev 
# RUN apk add --no-cache --update bash build-base file libcurl mysql-client \
#                                 mysql-dev nginx nodejs tzdata \
#                                 ffmpeg imagemagick libjpeg-turbo-utils libxml2-dev libxslt-dev \
#                                 libgcc libstdc++ libx11 glib libxrender libxext libintl libcrypto1.0 \
#                                 libssl1.0 ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle install --jobs `grep -c processor /proc/cpuinfo` --retry 5

COPY . .

RUN mkdir -p log/

EXPOSE 4567
CMD ["ruby", "api.rb"]
