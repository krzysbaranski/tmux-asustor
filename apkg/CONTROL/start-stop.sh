#!/bin/sh

NAME="tmux"

case "$1" in
    start)
        echo "Starting $NAME"
        ldconfig
        ;;
    stop)
        echo "Stopping $NAME"
        ;;
    reload)
        echo "Reloading $NAME"
        ;;
    restart|force-reload)
        echo "Restarting $NAME"
        ;;
    *)
        echo "Usage: $0 {start|stop|reload|force-reload|restart}"
        exit 2
        ;;
esac

exit 0
