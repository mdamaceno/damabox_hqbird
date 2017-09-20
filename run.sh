#!/bin/bash

service hqbird start
service firebird start

tail -n 100 /var/log/dataguard32.log
tail -f /var/log/dataguard32.log
