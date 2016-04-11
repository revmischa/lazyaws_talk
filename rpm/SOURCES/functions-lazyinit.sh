# SOURCE ME

# This is an example of how to daemonize any application on a
# redhat-style/Amazon Linux system.
# See sysvinit-myapp.sh for example usage

# input vars:
# USER, GROUP, APPDIR, PROG, PROGOPTS, PIDFILE, LOCKFILE, NOWRITEPID, NOBACKGROUND

if [[ -z "$PROGNAME" ]]; then
    PROGNAME="$PROG"
fi

start() {
    echo $"Starting $PROGNAME: "
    cd $APPDIR
    DAEMON="daemon --user=$USER"
    EXEC="$PROG $PROGOPTS"
    if [[ -z "$NOBACKGROUND" ]]; then
        # background
        EXEC="$EXEC &"
    fi
    if [[ -z "$NOWRITEPID" ]]; then
        writepid='eval echo "$!" > '
        writepid="$writepid \"$PIDFILE\""
        DAEMON="$DAEMON --pidfile=$PIDFILE"
        EXEC="$EXEC $writepid"
    fi
    # do it
    echo $DAEMON "$EXEC"
    $DAEMON "$EXEC"
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $LOCKFILE
    return $retval
}

stop() {
    echo -n $"Stopping $PROGNAME: "
    killproc -p "$PIDFILE" 
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $LOCKFILE
    return $retval
}

restart() {
    if [ ! -e "$PIDFILE" ]; then
        return 1
    fi
    
    PID=`cat $PIDFILE`
    if [[ -z "$PID" || -z "`ps axf | grep ${PID} | grep -v grep`" ]]; then
        return 1
    else
        kill -HUP $PID
        return 0
    fi
}

reload() {
    restart
}

force_reload() {
    restart
}

rh_status() {
    if [ ! -e "$PIDFILE" ]; then
        return 1
    fi

    PID=`cat $PIDFILE`
    if [[ -z "$PID" || -z "`ps axf | grep ${PID} | grep -v grep`" ]]; then
        return 1
    else
        return 0
    fi
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}


case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
esac
exit $?
