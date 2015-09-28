#!/bin/bash

##################### PRECONDICIONES ######################
# chmod +x AFINI.sh 
# mkdir conf
#chmod +x fileExists.sh
# poner los archivos  "CdP.mae" "CdA.mae" "agentes.mae" "umbrales.tab" en la ruta de archivos maestros
#falta config dir en el conf
#chmod +x AFREC.sh
###########################################################

################## VARIABLES CON DATOS DE OTRO LADO ##################
		STATUSINST="LISTA"
		GRUPO12="./GRUPO12"
		CONFDIR="$GRUPO12/conf"
		CONFIGFILE="$CONFDIR/afinstall.conf"
######################################################################

################## VARIABLES DE AMBIENTE ##################
		GRALOG="./GraLog.sh"
		FUCTIONSDIR="./functions"
		fileExistsFUNC="$FUCTIONSDIR/fileExists.sh"
		CMD="AFINI"
#-------------------- EXPORT VARIABLES -------------------#
		export GRALOG
###########################################################

################## MESSAGES ###############################
		MESSAGE_READY_YET="El ambiente ya fue inicializado, para reiniciar termine la sesión e ingrese nuevamente"
		MESSAGE_FILE_NOT_FOUND="Archivo no encontrado: "
###########################################################

################## LOCAL FUNCTIONS ########################
function existsAllFiles
{
	filesToCheck=("$CONFIGFILE" "$MAEDIR/CdP.mae" "$MAEDIR/CdA.mae" "$MAEDIR/agentes.mae" "$MAEDIR/umbrales.tab")
	for item in ${filesToCheck[*]}
	do
		$fileExistsFUNC "$item" $CMD
		local status=$?
    	if [ $status -ne 0 ]; then
    		#### TODO: MEJORAR EL MENSAJE YA QUE FALTAN LOS ARCHIVOS NECESARIOS
    	    echo "$MESSAGE_FILE_NOT_FOUND $item"
    	    $GRALOG "AFINI" "$MESSAGE_FILE_NOT_FOUND $item" "ERR"
    	    exit 1
    	fi
	done
}

function examPath
{
	description="$1"
	path="$2"
	printArchivos="$3"
	mensaje="$description $path"
	$GRALOG "AFINI" "$mensaje" "INFO"
	echo "$mensaje"
	if [ "$printArchivos" = "true" ]; then
		archivos=$(ls $path)
		for line in $archivos; do
			lineFile="		|------> $line"
			echo $lineFile
			$GRALOG "AFINI" "$lineFile" "INFO"
		done
	fi

}

function verificarPermisos
{
	filesToCheckPerms=("$GRALOG" "$fileExistsFUNC" "./AFREC.sh" "$BINDIR")
	for func in ${filesToCheckPerms[*]}
	do
		if ! [ -x "$func" ]; then
			echo "no tiene permisos $func"
			chmod +x "$func"
			if ! [ -x "$func" ]; then
				echo "FALLO al darle permisos de ejecucion al archivo $func"
				exit 1
			fi
		fi
	done

	for func in $(ls "$BINDIR")
	do
		fileToActPerm="$BINDIR/$func"
		echo "$fileToActPerm"
		if ! [ -x "$fileToActPerm" ]; then
			echo "no tiene permisos $fileToActPerm"
			chmod +x "$fileToActPerm"
			if ! [ -x "$fileToActPerm" ]; then
				echo "FALLO al darle permisos de ejecucion al archivo $fileToActPerm"
				exit 1
			fi
		fi
	done
}

###########################################################
clear
echo "INICIO AFINI"
echo $AFINI_STATUS
## TODO: VER COMO hacer que se inicie una sola vez
if [ "$AFINI_STATUS" = "INICIALIZADO" ]; then
	echo $MESSAGE_READY_YET
	$GRALOG "AFINI" "$MESSAGE_READY_YET" "ERR"
	exit 1
fi

## TODO: VER COMO MOSTRAR QUE LE FALTA DE LA INSTALACION, hoy solo chequeo que el archivo de configuracion exista
if [ "$STATUSINST" != "LISTA" ]; then
	exit 1
fi


### LEVANTO LAS VARIABLES DEL ARCHIVO DE CONFIGURACION
IFS='
'
for line in $(cat $CONFIGFILE); do
	variableInConfig=$(echo "$line" | sed "s/\([^=]*\)=\([^=]*\).*/\1/g")
	valueInConfig=$(echo "$line" | sed "s/\([^=]*\)=\([^=]*\).*/\2/g")
	if [[ $valueInConfig == /G* ]]; then
		valueInConfig=".$valueInConfig"
	fi
export "$variableInConfig"="$valueInConfig"
done

verificarPermisos

AFINI_STATUS="INICIALIZADO"
existsAllFiles
examPath "Directorio de Configuración:" "$CONFDIR" "true"
examPath "Directorio de Ejecutables:" "$BINDIR" "true"
examPath "Directorio de Maestros y Tablas:" "$MAEDIR" "true"
examPath "Directorio de recepción de archivos de llamadas:" "$NOVEDIR"
examPath "Directorio de Archivos de llamadas Aceptados:" "$ACEPDIR"
examPath "Directorio de Archivos de llamadas Sospechosas:" "$PROCDIR"
examPath "Directorio de Archivos de Reportes de llamadas:" "$REPODIR"
examPath "Directorio de Archivos de Log:" "$LOGDIR" "true"
examPath "Directorio de Archivos Rechazados:" "$RECHDIR"
examPath "Estado del Sistema:" "$AFINI_STATUS"


while [ -z $activarAFREC ]
do
	read -p "¿Desea efectuar la activación de AFREC? (Si – No) " activarAFREC
	activarAFREC=$(echo $activarAFREC | grep '^[Ss][Ii]$\|^[Nn][Oo]$' | tr '[:upper:]' '[:lower:]')
done
if [ $activarAFREC = "no" ]; then
	echo "No se inicio el comando AFREC"
	#TODO explciar como arrancar con ARRANCAR
	echo "Para arrancarlo puede ejecutar ARRANCAR AFREC "
else
	afrecRunning=$(ps | grep "AFREC" | sed "s/\([0-9]*\).*/\1/g")
	if [ "$afrecRunning" = "" ]; then
		#TODO ejecutar el AFREC
		echo "Se lanza AFREC ..."
		./AFREC.sh &
		afrecRunning=$(ps | grep "AFREC" | sed "s/\([0-9]*\).*/\1/g")
	else
		echo "AFREC ya estaba corriendo."
	fi
	mensajeAfrecCorriendo="AFREC corriendo bajo el no.: $afrecRunning"
	echo "$mensajeAfrecCorriendo"
	$GRALOG "AFINI" "$mensajeAfrecCorriendo" "INFO"
	#TODO actualizar como correr el DETENER
	echo "Para detener el proceso AFREC ejecute: DETENER AFREC"
fi
export AFINI_STATUS

echo "FIN AFINI"
exit 0