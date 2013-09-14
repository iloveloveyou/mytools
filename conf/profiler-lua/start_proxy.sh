#!/bin/sh
/usr/bin/unbuffer  /usr/local/bin/mysql-proxy --proxy-backend-addresses=127.0.0.1:3302 --pid-file=/tmp/proxy_id --proxy-lua-script=/usr/src/mysql-proxy-0.8.3/profiler-lua/query-time.lua | tee >/tmp/mysql_profile.log &
