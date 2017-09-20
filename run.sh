#!/bin/bash

# service hqbird start

/opt/firebird/bin/fb_smp_server &

service hqbird console
