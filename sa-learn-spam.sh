#!/bin/sh
exec /usr/bin/rspamc -h rspamd:11334 -P { PASSWORD } learn_spam
