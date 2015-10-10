#!/bin/bash

status="0"

function verificarInicializacionDeAmbiente() {

	if [[ "$CONFDIR" == "" ]]
	then
	       echo No se encuentra inicializada la variable CONFDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable CONFDIR" "ERR"
	       let status="1"
	fi
	if [[ $BINDIR == "" ]]
	then
	      echo No se encuentra inicializada la variable BINDIR
	      $GRALOG "Arrancar" "No se encuentra inicializada la variable BINDIR" "ERR"
	      let status="1"
	fi
	if [[ $MAEDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable MAEDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable MAEDIR" "ERR"
	       let status="1"
	fi
	if [[ $NOVEDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable NOVEDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable NOVEDIR" "ERR"
	       let status="1"
	fi
	if [[ $ACEPDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable ACEPDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable ACEPDIR" "ERR"
	       let status="1"
	fi
	if [[ $PROCDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable PROCDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable PROCDIR" "ERR"
	       let status="1"
	fi
	if [[ $REPODIR == "" ]]
	then
	       echo No se encuentra inicializada la variable REPODIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable REPODIR" "ERR"
	       let status="1"
	fi
	if [[ $LOGDIR == "" ]]
	then
 	      echo No se encuentra inicializada la variable LOGDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable LOGDIR" "ERR"
	       let status="1"
	fi
	if [[ $RECHDIR == "" ]]
	then
	       echo No se encuentra inicializada la variable RECHDIR
	       $GRALOG "Arrancar" "No se encuentra inicializada la variable RECHDIR" "ERR"
	       let status="1"
	fi
}


if [[ ($1 != "AFINI.sh") && ($1 != "AfInstal.sh") ]]
then
	verificarInicializacionDeAmbiente
	if [ "$status" -eq "0" ]
	then


		#Verifico que tenga un parametro
		if [ $# -ne 1 ]
		then
			echo "Se debe indicar un proceso a arrancar"
			$GRALOG "Arrancar" "Se debe indicar un proceso a arrancar" "ERR"

		else



			#obtengo el pid
			PID=`ps | grep "$1" | head -1 | awk '{print "$1" }'`

			#Verifico que no este corriendo
			if [[ $PID != "" ]]
			then
				echo Ya se esta ejecutando el proceso
				$GRALOG "Arrancar" "Ya se esta ejecutando el proceso" "ERR"
			else

				#ejecuto el proceso
				if [ $1 == "AfInstal.sh" ]
				then
					./$1
				else

					if [ $1 == "AFINI.sh" ]
					then
						. $1
					else


						nohup "$BINDIR/$1" > /dev/null 2>&1 &
						PID=$!

						#Verifico que se haya ejecutado correctamente
						if [ "$PID" != "" ]; then
							echo "El proceso $1 fue ejecutado con PID: $PID"
							$GRALOG "Arrancar" "El proceso $1 fue ejecutado con PID: $PID" "INFO"
						else
							echo "Ocurrio un error al ejecutar $1"
							$GRALOG "Arrancar" "Ocurrio un error al ejecutar $1" "ERR"
						fi
					fi
				fi
			fi
		fi
	fi
fi
