#!/bin/bash

GRALOG="./GraLog.sh"


function verificarInicializacionDeAmbiente() {

	if [[ $CONFDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable CONFDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable CONFDIR" "ERR"
	       exit 0
	fi
	if [[ $BINDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable BINDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable BINDIR" "ERR"
	       exit 0
	fi
	if [[ $MAEDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable MAEDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable MAEDIR" "ERR"
	       exit 0
	fi
	if [[ $NOVEDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable NOVEDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable NOVEDIR" "ERR"
	       exit 0
	fi
	if [[ $ACEPDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable ACEPDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable ACEPDIR" "ERR"
	       exit 0
	fi
	if [[ $PROCDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable PROCDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable PROCDIR" "ERR"
	       exit 0
	fi
	if [[ $REPODIR == "" ]]
	then
	       echo No se encuentra inicializada la variable REPODIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable REPODIR" "ERR"
	       exit 0
	fi
	if [[ $LOGDIR == "" ]]
	then
 	      echo No se encuentra inicializada la variable LOGDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable LOGDIR" "ERR"
	       exit 0
	fi
	if [[ $RECHDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable RECHDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable RECHDIR" "ERR"
	       exit 0
	fi
}


if [[ ($1 != "AFINI.sh") && ($1 != "AfInstal.sh") ]]
then
	verificarInicializacionDeAmbiente
fi

#Verifico que tenga un parametro
if [ $# -ne 1 ] 
then
	echo "Se debe indicar un proceso a arrancar"
	$GRALOG "Arrancar" "Se debe indicar un proceso a arrancar" "ERR"
	exit 1
fi



#obtengo el pid
PID=`ps | grep "$1" | head -1 | awk '{print $1 }'`

#Verifico que no este corriendo
if [[ $PID != "" ]]
then
	echo Ya se esta ejecutando el proceso
	$GRALOG "Arrancar" "Ya se esta ejecutando el proceso" "ERR"
	exit 0
fi

#ejecuto el proceso
nohup $1 > /dev/null 2>&1 &
PID=$!

#Verifico que se haya ejecutado correctamente
if [ "$PID" != "" ]; then
	echo "El proceso $1 fue ejecutado con PID: $PID"
	$GRALOG "Arrancar" "El proceso $1 fue ejecutado con PID: $PID" "INFO"
else 
	echo "Ocurrio un error al ejecutar $1"
	$GRALOG "Arrancar" "Ocurrio un error al ejecutar $1" "ERR"
fi
