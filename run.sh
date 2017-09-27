#!/bin/bash

# service hqbird start

# /opt/firebird/bin/fb_smp_server &
${PREFIX}/bin/fbguard &

service hqbird console
