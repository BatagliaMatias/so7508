#!/bin/bash

CICLO=0
SLEEPTIME=10
#MAEDIR=MAEDIR
ARCH_CENTRALES='centrales.csv'
#NOVEDIR=NOVEDIR
#ACEPDIR=ACEPDIR
SEPARATOR_MAEDIR=";"
TODAY=date +%Y%m%d >> /dev/null 2>&1
DIAS_LIMITE=365
RUN_AFUMB=1
AFUMB="./AFUMB.sh" 

while [ true ]
do
	let CICLO=CICLO+1
	$GRALOG "AFREC" "Ciclo numero:$CICLO" "INFO"
	#1 Grabar en el log el numero de ciclo.

	#2 Chequeo si hay archivos en NOVEDIR
	if [ ! -d "$NOVEDIR" ];
		then echo "Directorio $NOVEDIR no existe y se va a crear"
		mkdir -p "$NOVEDIR"
	fi

	if [ ! -d "$ACEPDIR" ];
		then echo "Directorio $ACEPDIR no existe y se va a crear"
		mkdir -p "$ACEPDIR"
	fi

	if [ ! -d "$MAEDIR" ];
		then echo "Directorio $MAEDIR no existe y se va a crear"
		mkdir -p "$MAEDIR"
	fi

	if find "$NOVEDIR" -maxdepth 0 -empty | read v; 
		then echo "$NOVEDIR esta vacio"; 
	else
		#3 Chequeo que solo sean archivos de texto (elimina vacios)  
		for FILE in $NOVEDIR/*
		do
			TYPE=$(file "$FILE" | cut -d' ' -f2)
			if [ "$TYPE" != "ASCII" ]
				then echo "$FILE no es texto"
				 #Mover Archivo que no es texto
			fi
		done

		#4 Chequeo formato de los archivos 
		for FILE in $NOVEDIR/*
		do
			if ! [[ $FILE =~ ^$NOVEDIR/..._........ ]];
				then echo $FILE NO FORMATO #Mover Archivo que no es formato
			fi
		done

		#5 valido nombres de los archivos
		if [ ! -f $MAEDIR/$ARCH_CENTRALES ]; 
			then echo "$MAEDIR/$ARCH_CENTRALES no existe"
		
		else
			for FILE in $NOVEDIR/*
			do
				NOMBRE=${FILE##*/} #me quita la ruta del archivo, queda solo el nombre
				COD_CENTRAL=$(echo $NOMBRE|cut -d'_' -f1) #Parseo codigo de central y fecha
				DATE=$(echo $NOMBRE|cut -d'_' -f2 |cut -d'.' -f1)
				
				if !(grep -q "^$COD_CENTRAL$SEPARATOR_MAEDIR" $MAEDIR/$ARCH_CENTRALES)
				   then echo "$NOMBRE codigo malo" #mover Archivo que no tiene su codigo en el maestro.
				fi

				if ! (date -d $DATE >> /dev/null 2>&1) #salida quiet
				 	then echo "$NOMBRE fecha mala"; #mover archivo por no tener fecha valida
				 	DIFERENCIA_DIAS="-10"
				else
					DIFERENCIA_DIAS=$(( ($(date --date="$TODAY" +%s) - $(date --date="$DATE" +%s)  )/(60*60*24) ));
				fi			

				if [ "$DIFERENCIA_DIAS" -gt "$DIAS_LIMITE" ];
					then echo "$FILE SUPERA EL AÑO" #Mover archivo por superar un año
				fi

				if [ "$DIFERENCIA_DIAS" -lt 0 ];
					then echo "$FILE ARCHIVO DEL FUTURO" #Mover archivo por ser del futuro.
				fi

				#Si el archivo sigue vivo aca lo manda a la carpeta aceptado.

			done
		fi

	fi #Finaliza chequeo de archivos nuevos en NOVEDIR

	#Chequear si hay archivos en ACEPDIR y ejecutar AFUMB si se pued
	if find $ACEPDIR -maxdepth 0 -empty | read v; 
		then echo "$ACEPDIR esta vacio"; 
	else
		#if [[ $RUN_AFUMB -ne 0 ]]; then
		#	echo veo si corre AFUM
		#fi
		PID=$(pgrep "^AFUMB.sh$")
		if [ -z "$PID" ];
		then
		    $AFUMB & #loguear que ejecuto AFUMB
		    PID=$!
		    #PID=$(pgrep "^AFUMB.sh$")
		    echo PID $PID #PID para loguear con que id se ejecuta AFUMB
		else
		    echo "AFUMB YA ESTA EJECUTADO" #loguear que correspondia ejecutar pero se pospuso para la siguiente ejecucion
		fi
	fi



	sleep $SLEEPTIME

done
PID=$(pgrep "$1")

