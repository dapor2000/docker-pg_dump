FROM postgres:latest
MAINTAINER Cristoffer Fairweather <cfairweather@annixa.com> # Previously Ilya Stepanov <dev@ilyastepanov.com>

RUN apt-get update && \
    apt-get install -y cron && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD dump.sh /dump.sh
RUN chmod +x /dump.sh

ADD restore.sh /restore.sh
RUN chmod +x /restore.sh

ADD start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /dump
VOLUME /status

ENTRYPOINT ["/start.sh"]
CMD [""]
