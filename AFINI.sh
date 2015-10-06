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
		CONFDIR="./GRUPO12/conf"
		CONFIGFILE="$CONFDIR/afinstall.conf"
######################################################################

################## VARIABLES DE AMBIENTE ##################
		export GRALOG="./GraLog.sh"
		FUCTIONSDIR="./functions"
		fileExistsFUNC="$FUCTIONSDIR/fileExists.sh"
		CMD="AFINI"
###########################################################

################## MESSAGES ###############################
		MESSAGE_READY_YET="El ambiente ya fue inicializado, para reiniciar termine la sesión e ingrese nuevamente"
		MESSAGE_FILE_NOT_FOUND="Archivo no encontrado: "
###########################################################

################## LOCAL FUNCTIONS ########################
function installComplete
{
	### LEVANTO LAS VARIABLES DEL ARCHIVO DE CONFIGURACION
	IFS='
	'
	varsToCheck=("GRUPO" "BINDIR" "MAEDIR" "NOVEDIR" "DATASIZE" "ACEPDIR" "PROCDIR" "REPODIR" "LOGDIR" "LOGEXT" "LOGSIZE" "RECHDIR")
	for variableConf in ${varsToCheck[*]}
	do
		line=$(grep "$variableConf=" "$CONFIGFILE")
		if [ "$line" != "" ]; then
			variableInConfig=$(echo "$line" | sed "s/\([^=]*\)=\([^=]*\).*/\1/g")
			valueInConfig=$(echo "$line" | sed "s/\([^=]*\)=\([^=]*\).*/\2/g")
			if [[ $valueInConfig == /G* ]]; then
				valueInConfig="$GRUPO$valueInConfig"
			fi
			export "$variableInConfig"="$valueInConfig"
		else
			return "1"
		fi
	done
	return "0"
}

function existsAllFiles
{
	filesToCheck=("$CONFIGFILE" "$MAEDIR/CdP.mae" "$MAEDIR/CdA.mae" "$MAEDIR/agentes.mae" "$MAEDIR/umbrales.tab")
	for item in ${filesToCheck[*]}
	do
		$fileExistsFUNC "$item" $CMD
		local status=$?
    	if [ $status -ne 0 ]; then
    	    echo "$MESSAGE_FILE_NOT_FOUND $item"
    	    $GRALOG "$CMD" "$MESSAGE_FILE_NOT_FOUND $item" "ERR"
    	    return "1"
    	fi
	done
	return "0"
}

function examPath
{
	description="$1"
	path="$2"
	printArchivos="$3"
	mensaje="$description $path"
	$GRALOG "$CMD" "$mensaje" "INFO"
	echo "$mensaje"
	if [ "$printArchivos" = "true" ]; then
		archivos=$(ls $path)
		for line in $archivos; do
			lineFile="		|------> $line"
			echo $lineFile
			$GRALOG "$CMD" "$lineFile" "INFO"
		done
	fi

}

function verificarPermisos
{
	filesToCheckPerms=("$GRALOG" "$fileExistsFUNC" "./AFREC.sh" "$BINDIR" "$MAEDIR" "$NOVEDIR" "$ACEPDIR" "$PROCDIR" "$REPODIR" "$LOGDIR" "$RECHDIR")
	for func in ${filesToCheckPerms[*]}
	do
		if ! [ -x "$func" ]; then
			
			chmod +x "$func"
			if ! [ -x "$func" ]; then
				echo "FALLO al darle permisos de ejecucion al archivo $func"
				return "1"
			fi
			echo "Se le dio permisos de ejecucion a $func"
		fi
		if ! [ -r "$func" ]; then
			chmod +r "$func"
			if ! [ -r "$func" ]; then
				echo "FALLO al darle permisos de lectura al archivo $func"
				return "1"
			fi
			echo "Se le dio permisos de lectura a $func"
		fi
		if ! [ -w "$func" ]; then
			echo "no tiene permisos $func"
			chmod +w "$func"
			if ! [ -w "$func" ]; then
				echo "FALLO al darle permisos de escritura al archivo $func"
				return "1"
			fi
			echo "Se le dio permisos de escritura a $func"
		fi
	done

	for func in $(ls "$BINDIR")
	do
		fileToActPerm="$BINDIR/$func"
		if ! [ -x "$fileToActPerm" ]; then
			chmod +x "$fileToActPerm"
			if ! [ -x "$fileToActPerm" ]; then
				echo "FALLO al darle permisos de ejecucion al archivo $fileToActPerm"
				return "1"
			fi
			echo "Se le dio permisos de ejecucion a $fileToActPerm"
		fi
	done

	filesToCheckPermsAux=("$BINDIR" "$MAEDIR" "$NOVEDIR" "$ACEPDIR" "$PROCDIR" "$REPODIR" "$LOGDIR" "$RECHDIR")
	for directory in ${filesToCheckPermsAux[*]}
	do
		for fileToActPerm in $(ls "$directory")
		do
			fileToActPerm="$directory/$fileToActPerm"
			if ! [ -r "$fileToActPerm" ]; then
				chmod +r "$fileToActPerm"
				if ! [ -r "$fileToActPerm" ]; then
					echo "FALLO al darle permisos de lectura al archivo $fileToActPerm"
					return "1"
				fi
				echo "FALLO al darle permisos de lectura al archivo $fileToActPerm"
			fi
		done
	done
	return "0"
}

###########################################################
clear
echo "INICIO AFINI"
if [ "$AFINI_STATUS" == "INICIALIZADO" ]; then
	echo "$MESSAGE_READY_YET"
	$GRALOG "$CMD" "$MESSAGE_READY_YET" "ERR"
else
		installComplete
		environmentOk="$?"
		if [ "$environmentOk" != "0" ]; then
		       echo "FALTA COMPLETAR INSTALACION - Ejecutar: ' AfInstal.sh'"
		else
				verificarPermisos
				pemisosOk="$?"
				if [ "$pemisosOk" != "0" ]; then
				       echo "FALLARON LOS PERMISOS"
				else
						existsAllFiles
						todosExiten="$?"
						if [ "$todosExiten" != "0" ]; then
						       echo "FALTAN ARCHIVOS"
						else
								AFINI_STATUS="INICIALIZADO"
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
									afrecRunning=$(ps | grep "AFREC" | sed "s/ *\([0-9]*\).*/\1/g")
									if [ "$afrecRunning" = "" ]; then
										#TODO ejecutar el AFREC
										echo "Se lanza AFREC ..."
										$BINDIR/AFREC.sh&
										afrecRunning=$(ps | grep "AFREC" | sed "s/ *\([0-9]*\).*/\1/g")
									else
										echo "AFREC ya estaba corriendo."
									fi
									mensajeAfrecCorriendo="AFREC corriendo bajo el no.: $afrecRunning"
									echo "$mensajeAfrecCorriendo"
									$GRALOG "$CMD" "$mensajeAfrecCorriendo" "INFO"
									#TODO actualizar como correr el DETENER
									echo "Para detener el proceso AFREC ejecute: detener AFREC"
								fi
								export AFINI_STATUS
								echo "FIN AFINI"
						fi
				fi
		fi
fi