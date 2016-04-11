#!/bin/sh
#
# Daemonize my sample application
#
# chkconfig:   - 20 80
# description: My app sample

### BEGIN INIT INFO
# Provides: myapp
# Required-Start: $local_fs $network $named $syslog
# Required-Stop: 
# Should-Start: 
# Should-Stop: 
# Default-Start: 
# Default-Stop: 
# Short-Description: myapp 
# Description: my sample application
### END INIT INFO

# Source function library.
source /etc/rc.d/init.d/functions

# Try to not run as ec2-user!
USER=ec2-user
GROUP=ec2-user

APPDIR="/myapp/app"
PROG="./run-myapp"
PIDFILE="/myapp/run/myapp.pid"
LOCKFILE=/var/lock/subsys/myapp

source /etc/rc.d/init.d/functions-lazyinit.sh
