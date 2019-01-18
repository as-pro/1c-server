ARG BASE_IMAGE=i386/ubuntu:18.04

FROM $BASE_IMAGE as srv1c

RUN set -uxe \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        imagemagick \
        libMagickWand-6.Q16 \
        libfreetype6 \
        libgsf-1-114 \
        libgsf-bin \
        libglib2.0-0 \
        unixodbc \
        t1utils \
        libkrb5-3 \
        libgssapi-krb5-2 \
        xfonts-utils \
        cabextract \
        locales \
    && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
    && apt-get install -y ttf-mscorefonts-installer \

    && locale-gen en_US ru_RU ru_RU.UTF-8 \
    # set default locale
    && echo "\
      LANGUAGE=en_US.UTF-8\n\
      LC_ALL=en_US.UTF-8\n\
      LC_CTYPE=UTF-8\n\
      LANG=en_US.UTF-8\n"\
      > /etc/default/locale \
    # set keyboard setting
    && echo "\
      XKBMODEL=pc105\n\
      XKBLAYOUT=us,ru\n\
      XKBVARIANT=,\n\
      XKBOPTIONS=grp:alt_shift_toggle,grp_led:scroll"\
      >> /etc/default/keyboard \
    # set environment
    && echo TERM=xterm >> /etc/environment \

    # clear
    && apt-get purge -y --auto-remove locales \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# install gosu
ENV GOSU_VERSION 1.11
RUN apt-get update \
    && deps="\
        gnupg \
        wget \
    " \
    && apt-get install -y $deps \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    # clear
    && apt-get purge -y --auto-remove $deps \
    && rm -rf /var/lib/apt/lists/* /tmp/*

RUN apt-get update \
    && apt-get install -y \
        supervisor \
        apache2 \
    && rm -rf /var/lib/apt/lists/*

RUN echo "" > /var/www/html/index.html
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
RUN find /etc/apache2/ -type f -name '*.conf' \
    | xargs sed -ri \
    -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
    -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g'

COPY ./bin/ /usr/local/bin/
COPY ./docker-entrypoint-init.d/ /docker-entrypoint-init.d/
COPY ./supervisor.d/ /etc/supervisor/conf.d/

RUN chmod +x /usr/local/bin/start*

ENV LANG ru_RU.utf8
ENV ARCH1C=i386
ENV DIR_1C=/opt/1C/v8.3/$ARCH1C
ENV DIR_1C_USER=/home/usr1cv8
ENV RAGENT=$DIR_1C/ragent

EXPOSE 1540-1541 1560-1591 80

CMD ["start"]