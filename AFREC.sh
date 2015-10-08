#!/bin/bash

CICLO=0
SLEEPTIME=12
#MAEDIR=MAEDIR
ARCH_CENTRALES="centrales.csv"
#NOVEDIR=NOVEDIR
#ACEPDIR=ACEPDIR
#RECHDIR
SEPARATOR_MAEDIR=";"
TODAY=date +%Y%m%d >> /dev/null 2>&1
DIAS_LIMITE=365
#RUN_AFUMB=1
#AFUMB="./AFUMB.sh"
MOVER_A="./moverA.sh" 

while [ true ]
do
	let CICLO=CICLO+1
	#1 Grabar en el log el numero de ciclo.
	$GRALOG "AFREC" "Ciclo numero:$CICLO" "INFO"
	#2 Chequeo si hay archivos en NOVEDIR
	if [ ! -d "$NOVEDIR" ];
		then 
		#echo "Directorio $NOVEDIR no existe y se va a crear"
		$GRALOG "AFREC" "Directorio $NOVEDIR no existe y se va a crear" "INFO"
		mkdir -p "$NOVEDIR"
	fi

	if [ ! -d "$ACEPDIR" ];
		then 
		#echo "Directorio $ACEPDIR no existe y se va a crear"
		$GRALOG "AFREC" "Directorio $ACEPDIR no existe y se va a crear" "INFO"
		mkdir -p "$ACEPDIR"
	fi

	if [ ! -d "$MAEDIR" ];
		then 
		#echo "Directorio $MAEDIR no existe y se va a crear"
		$GRALOG "AFREC" "Directorio $MAEDIR no existe y se va a crear" "INFO"
		mkdir -p "$MAEDIR"
	fi

	if find "$NOVEDIR" -maxdepth 0 -empty | read v; 
		then 
		#echo "$NOVEDIR esta vacio";
		$GRALOG "AFREC" "$NOVEDIR esta vacio" "INFO" 
	else
		#3 Chequeo que solo sean archivos de texto (elimina vacios)  
		for FILE in $NOVEDIR/*
		do
			TYPE=$(file "$FILE" | cut -d' ' -f2)
			if [ "$TYPE" != "ASCII" ]
				then #echo "$FILE no es texto"
				$GRALOG "AFREC" "Archivo Rechazado, $FILE no es texto" "WAR"
				$MOVER_A "$FILE" "$RECHDIR"
				 #Mover Archivo que no es texto
			fi
		done

		#4 Chequeo formato de los archivos 
		for FILE in $NOVEDIR/*
		do
			if ! [[ $FILE =~ ^$NOVEDIR/..._........ ]];
				then #echo $FILE NO FORMATO #Mover Archivo que no es formato
				$GRALOG "AFREC" "Archivo Rechazado, $FILE tiene formato incorrecto" "WAR"
				$MOVER_A "$FILE" "$RECHDIR"
			fi
		done

		#5 valido nombres de los archivos
		if [ ! -f $MAEDIR/$ARCH_CENTRALES ]; 
			then echo #"$MAEDIR/$ARCH_CENTRALES no existe"
				$GRALOG "AFREC" "Archivo Maestro $MAEDIR/$ARCH_CENTRALES no existe" "ERR"
		
		else
			for FILE in $NOVEDIR/*
			do
				NOMBRE=${FILE##*/} #me quita la ruta del archivo, queda solo el nombre
				COD_CENTRAL=$(echo $NOMBRE|cut -d'_' -f1) #Parseo codigo de central y fecha
				DATE=$(echo $NOMBRE|cut -d'_' -f2 |cut -d'.' -f1)
				
				if !(grep -q "^$COD_CENTRAL$SEPARATOR_MAEDIR" $MAEDIR/$ARCH_CENTRALES)
				   then #echo "$NOMBRE codigo malo" 
				   		$GRALOG "AFREC" "Archivo Rechazado, $FILE codigo incorrecto" "WAR"
				   		$MOVER_A "$FILE" "$RECHDIR"
				   #mover Archivo que no tiene su codigo en el maestro.
				fi

				if ! (date -d $DATE >> /dev/null 2>&1) #salida quiet
				 	then 
				 		$GRALOG "AFREC" "Archivo Rechazado, $FILE fecha incorrecta" "WAR"
				 		$MOVER_A "$FILE" "$RECHDIR"
				 	#echo "$NOMBRE fecha mala"; #mover archivo por no tener fecha valida
				 	DIFERENCIA_DIAS="-10"
				else
					DIFERENCIA_DIAS=$(( ($(date --date="$TODAY" +%s) - $(date --date="$DATE" +%s)  )/(60*60*24) ));
				fi			

				if [ "$DIFERENCIA_DIAS" -gt "$DIAS_LIMITE" ];
					then
						$GRALOG "AFREC" "Archivo Rechazado, $FILE fecha superior a un anio" "WAR"
						$MOVER_A "$FILE" "$RECHDIR" 
					#echo "$FILE SUPERA EL AÑO" #Mover archivo por superar un año
				fi

				if [ "$DIFERENCIA_DIAS" -lt 0 ];
					then 
						$GRALOG "AFREC" "Archivo Rechazado, $FILE fecha del futuro" "WAR"
						$MOVER_A "$FILE" "$RECHDIR"
					#echo "$FILE ARCHIVO DEL FUTURO" #Mover archivo por ser del futuro.
				fi

				#Si el archivo sigue vivo aca lo manda a la carpeta aceptado.
				$MOVER_A "$FILE" "$ACEPDIR"

			done
		fi

	fi #Finaliza chequeo de archivos nuevos en NOVEDIR

	#Chequear si hay archivos en ACEPDIR y ejecutar AFUMB si se pued
	if find $ACEPDIR -maxdepth 0 -empty | read v; 
		then $GRALOG "AFREC" "$ACEPDIR esta vacio" "INFO"
		#echo "$ACEPDIR esta vacio"; 
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
		    $GRALOG "AFREC" "Se ejecuto AFUMB con PID $PID" "INFO"
		    #echo PID $PID #PID para loguear con que id se ejecuta AFUMB
		else
			 $GRALOG "AFREC" "AFUMB ya se encuentra en ejecucion con PID $PID" "INFO"
		    #echo "AFUMB YA ESTA EJECUTADO" #loguear que correspondia ejecutar pero se pospuso para la siguiente ejecucion
		fi
	fi



	sleep $SLEEPTIME

done

PID=$(pgrep "$1")
