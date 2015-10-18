#!/bin/bash

GRALOG="./GraLog.sh"

PID=$(pgrep "$1")

if [ "$#" -eq 1 ]
then

	if [[ "$PID" != "" ]]
	then
	        echo Se detuvo el proceso $1
	        $GRALOG "detener" "Se detuvo el proceso $1" "INFO"
			kill -9 $PID

	else
		echo "No existe el proceso"
		$GRALOG "detener" "No existe el proceso" "ERR"
	fi
else
	echo "Se debe indicar un proceso univoco a detener"
	$GRALOG "detener" "Se debe indicar un proceso univoco a detener" "ERR"
fi