#!/bin/bash

GRALOG="./GraLog.sh"

#Obtengo el pid
PID=`ps | grep "$1" | head -1 | awk '{print $1 }'`

if [[ $PID != "" ]]
then
        echo Se detuvo el proceso $1
        $GRALOG "detener" "Se detuvo el proceso $1" "INFO"
	kill -9 $PID
        exit 0
fi

echo "No existe el proceso"
$GRALOG "detener" "No existe el proceso"
