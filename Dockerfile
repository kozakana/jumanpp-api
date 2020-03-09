FROM ruby:2.6.5-alpine3.11

MAINTAINER kozakana

ENV JUMAN_VERSION 1.02
ENV APP_ROOT /var/app/current/

RUN echo http://mirror.yandex.ru/mirrors/alpine/v3.11/main > /etc/apk/repositories; \
    echo http://mirror.yandex.ru/mirrors/alpine/v3.11/community >> /etc/apk/repositories

RUN apk add --update --no-cache --virtual=build-deps \
    boost-dev g++ make \
    build-base linux-headers

RUN wget -q http://lotus.kuee.kyoto-u.ac.jp/nl-resource/jumanpp/jumanpp-${JUMAN_VERSION}.tar.xz \
    && tar Jxfv jumanpp-${JUMAN_VERSION}.tar.xz \
    && cd jumanpp-${JUMAN_VERSION}/ \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm jumanpp-${JUMAN_VERSION}.tar.xz \
    && rm -rf /var/cache/*

WORKDIR $APP_ROOT
COPY . $APP_ROOT
RUN bundle install

EXPOSE 4567

CMD ["unicorn", "-c", "unicorn.rb"]
