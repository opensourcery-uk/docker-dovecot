#!/bin/bash
echo "1"
sed -i "s/{ MAIL_GID }/${MAIL_GID}/" /etc/dovecot/conf.d/10-mail.conf
sed -i "s/{ PASSWORD }/${RSPAMD_PASSWORD}/" /usr/lib/dovecot/sieve/sa-learn-ham.sh /usr/lib/dovecot/sieve/sa-learn-spam.sh
sed -i "s/{ MAILNAME }/${MAILNAME}/" /etc/dovecot/conf.d/10-ssl.conf
echo "2"

# Done here because it relies on MAIL_GID
sievec /usr/lib/dovecot/sieve/report-ham.sieve
sievec /usr/lib/dovecot/sieve/report-ham.sieve

cat /etc/dovecot/conf.d/10-mail.conf

sed -i 's/#mail_debug = no/mail_debug = yes/' /etc/dovecot/conf.d/10-logging.conf

echo "disable_plaintext_auth=no" > /etc/dovecot/conf.d/99-hacks.conf

if [ $? -eq 0 ]; then
  exec "$@"
fi
