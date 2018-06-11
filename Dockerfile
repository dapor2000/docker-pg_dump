FROM postgres:latest
MAINTAINER Frank Wagener <docker@dapor.de> # Previously Ilya Stepanov <dev@ilyastepanov.com>

RUN apt-get update && \
    apt-get install -y cron && \
    apt-get install -y gpg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN sed -i '/session    required     pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron

ADD dump.sh /dump.sh
RUN chmod +x /dump.sh

ADD weekly.sh /weekly.sh
RUN chmod +x /weekly.sh

ADD restore.sh /restore.sh
RUN chmod +x /restore.sh

ADD start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /dump
VOLUME /weekly
VOLUME /status
VOLUME /keys

ENTRYPOINT ["/start.sh"]
CMD [""]
