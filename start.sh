#!/bin/sh

# Start supervisor which will manage both nginx and nodejs
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf