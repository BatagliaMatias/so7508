#!/bin/bash

GRALOG="./GraLog.sh"

PID=$(pgrep "$1")

if [[ "$PID" != "" ]]
then
        echo Se detuvo el proceso $1
        $GRALOG "detener" "Se detuvo el proceso $1" "INFO"
	kill -9 $PID
       # exit 0
else
	echo "No existe el proceso"
	$GRALOG "detener" "No existe el proceso" "ERR"
fi

