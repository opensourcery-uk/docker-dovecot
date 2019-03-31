FROM debian:stretch-slim
LABEL maintainer "open.source@opensourcery.uk"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get dist-upgrade -y \
 && apt-get install -y lsb-release wget gnupg apt-utils \
 && wget -O- https://rspamd.com/apt-stable/gpg.key | apt-key add - \
 && echo "deb [arch=amd64] http://rspamd.com/apt-stable/ $(lsb_release -c -s) main" > /etc/apt/sources.list.d/rspamd.list \
 && apt-get autoremove -y --purge lsb-release wget gnupg \
 && apt-get update \
 && apt-get install -y dovecot-imapd dovecot-ldap \
 && apt-get install -y rspamd dovecot-sieve \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/* \
 && sed -i -e 's,#log_path = syslog,log_path = /dev/stderr,' \
           -e 's,#info_log_path =,info_log_path = /dev/stdout,' \
           -e 's,#debug_log_path =,debug_log_path = /dev/stdout,' \
        /etc/dovecot/conf.d/10-logging.conf \
 && mkdir -p /usr/lib/dovecot/sieve \
 && mv /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.old

ADD 10-mail.conf \
    10-auth.conf \
    10-ssl.conf \
    21-imap-antispam-sieve.conf \
      /etc/dovecot/conf.d/

ADD report-spam.sieve \
    report-ham.sieve \
    sa-learn-ham.sh \
    sa-learn-spam.sh \
      /usr/lib/dovecot/sieve/

RUN chmod a+x \
      /usr/lib/dovecot/sieve/sa-learn-ham.sh \
      /usr/lib/dovecot/sieve/sa-learn-spam.sh

ADD entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 143

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/dovecot", "-F"]
