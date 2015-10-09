#!/bin/bash
#Instalador AFINSTALL - Grupo 12
#*************************** Variables ***************************
BASEDIR=`pwd`
CONFDIR="./conf"
LOGFILEINS="afinstall.log"
CONFIGFILE="$CONFDIR/afinstall.cnfg"
CONFIGFILETEMP="$CONFDIR/afinstall.temp"
GRUPO="/GRUPO12"
pathResult=""
DATOSDIR="./datos"
ACTUALDIR="./"
BINDIR="$GRUPO/bin"
MAEDIR="$GRUPO/mae"
NOVEDIR="$GRUPO/novedades"
DATASIZE=100 #100Mb  #DATASIZE=104857600 #100Mb
ACEPDIR="$GRUPO/aceptadas"
PROCDIR="$GRUPO/sospechosas"
REPODIR="$GRUPO/reportes"
RECHDIR="$GRUPO/rechazadas"
LOGDIR="$GRUPO/log"
LOGEXT=".log"
LOGSIZE=400 #400Kb #LOGSIZE=409600 #400Kb
LOGCOMMAND="./GraLog.sh"
VERSIONPERL=5
#*************************** Funciones ***************************
function log() {
        command=$1
        message=$2 
        type=$3
        if [ $# -ge 2 ] && [ $# -le 3 ] 
        then
			$LOGCOMMAND "$command" "$message" "$type" 
        fi
}

function initInstalation(){
	while [ -z $optSelect ]
	do
		clear
	#Verifico version de perl instalada
	log "Installer" "Verificando versión de perl instalada" "I"
		
	PERLVERSION=$(perl -v | grep 'v[0-9]\.[0-9]\+\.[0-9]*' -o) #obtengo la version de perl
	NUMPERLVERSION=$(echo $PERLVERSION | cut -d"." -f1 | sed 's/^v\([0-9]\)$/\1/') #obtengo el primer numero
	
	if [ -z "$NUMPERLVERSION" ] || [ $NUMPERLVERSION -lt $VERSIONPERL ]
	then
		echo "Para ejecutar el sistema AFRA-J es necesario contar con Perl $VERSIONPERL o superior."
		echo "Efectúe su instalación e inténtelo nuevamente."
		echo "Proceso de Instalación Cancelado"
		log  "Installer" "Para ejecutar el sistema AFRA-J es necesario contar con Perl $VERSIONPERL o superior." "E"	
		log  "Installer"  "Efectúe su instalación e inténtelo nuevamente." "E"	
		log  "Installer"  "Proceso de Instalación Cancelado" "E"	
		exit 3;
	else
		echo ""
		echo "PERL Instalada, Version: $PERLVERSION"
		#echo "PERL Instalada, Version:" $(perl -v)
		echo ""
		log "Installer" "PERL instalado. Version:$PERLVERSION" "I"
	fi

		echo '
		*************************************************************
		*             Proceso de Instalación de "AFRA-J"            *
		*  Tema J Copyright © Grupo 12 - Segundo Cuatrimestre 2015  *
		*************************************************************
    A T E N C I O N: Al instalar UD. expresa aceptar los términos y condiciones
    del "ACUERDO DE LICENCIA DE SOFTWARE" incluido en este paquete.
    '

		read -p " Acepta?  Si – No: " optSelect
		optSelect=$(echo $optSelect | grep '^[Ss][Ii]$\|^[Nn][Oo]$' | tr '[:upper:]' '[:lower:]')
	done

	#si el usuario no acepta finalizo el script
	if [ $optSelect = "no" ]
	then
		log "Installer" "Usuario NO acepto ACUERDO DE LICENCIA DE SOFTWARE"
		exit 2
	fi
	
	#Usuario Acepto los terminos
	log "Installer" "Usuario acepto ACUERDO DE LICENCIA DE SOFTWARE" "I"
	
	
	#Si existe vuelvo a generar el archivo de configuracion temporal
	if [ -a $CONFIGFILETEMP ]
	then 
		rm $CONFIGFILETEMP
		#touch $CONFIGFILETEMP
	fi
	
	echo "GRUPO=$BASEDIR=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getDirectoryPath "Defina el directorio de instalación de los ejecutables ($BINDIR):" "$BINDIR" 
	BINDIR=$pathTemp
	echo "BINDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP
	
	getDirectoryPath "Defina directorio para maestros y tablas ($MAEDIR):" "$MAEDIR"
	MAEDIR=$pathTemp
	echo "MAEDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getDirectoryPath "Defina el Directorio de recepción de los archivos de las llamadas ($NOVEDIR):" "$NOVEDIR"
	NOVEDIR=$pathTemp
	echo "NOVEDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	readNumber "Defina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes ($DATASIZE)" "$DATASIZE"
	DATASIZETEMP=$numberTemp
	DATASIZEDIR=$(df -B1024 "$ACTUALDIR" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';')
	DATASIZEDIR=$(echo "scale=0 ; $DATASIZEDIR/1024" | bc -l) #lo paso a Mb	

	while [ $DATASIZEDIR -lt $DATASIZETEMP ] 
	do
		echo "Insuficiente espacio en disco."
		echo "Espacio disponible: $DATASIZEDIR Mb."
		echo "Espacio requerido $DATASIZETEMP Mb"
		echo "Inténtelo nuevamente."
		echo ""	
		readNumber "Defina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes ($DATASIZE)" "$DATASIZE"
		DATASIZETEMP=$numberTemp
	done
	DATASIZE=$DATASIZETEMP
	echo "DATASIZE=$DATASIZETEMP=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP
	
	getDirectoryPath "Defina el directorio de grabación de los archivos de llamadas aceptadas ($ACEPDIR):" "$ACEPDIR"
	ACEPDIR=$pathTemp
	echo "ACEPDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	#llamadas sospechosas -> PROCDIR
	getDirectoryPath "Defina el directorio de grabación de los registros de llamadas sospechosas ($PROCDIR):" "$PROCDIR"
	PROCDIR=$pathTemp
	echo "PROCDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	#Directorio de grabacion de los reportes
	getDirectoryPath "Defina el directorio de grabación los reportes ($REPODIR):" "$REPODIR"
	REPODIR=$pathTemp	
	echo "REPODIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getDirectoryPath "Defina el directorio de logs ($LOGDIR):" "$LOGDIR"
	LOGDIR=$pathTemp	
	echo "LOGDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getExtension "Ingrese la extensión para los archivos de log ($LOGEXT): " "$LOGEXT"
	LOGEXT=$extDefault
	echo "LOGEXT=$extDefault=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	readNumber "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE)" "$LOGSIZE"
	LOGSIZETEMP=$numberTemp
	LOGSIZEDISP=$(df -B1024 "$ACTUALDIR" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';')
	
	while [ $LOGSIZEDISP -lt $LOGSIZETEMP ] 
	do
		echo "Insuficiente espacio en disco."
		echo "Espacio disponible: $LOGSIZEDISP Kb."
		echo "Espacio requerido $LOGSIZETEMP Kb"
		echo "Cancele la instalación o inténtelo nuevamente."
		echo ""	
		readNumber "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE)" "$LOGSIZE"
		LOGSIZETEMP=$numberTemp
	done
	LOGSIZE=$LOGSIZETEMP
	echo "LOGSIZE=$LOGSIZETEMP=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP

	getDirectoryPath "Defina el directorio de grabación los archivos rechazados ($RECHDIR):" "$RECHDIR"
	RECHDIR=$pathTemp	
	echo "RECHDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP
}


function getDirectoryPath(){
	msj=$1
	pathDefault=$2
	pathTemp=""	
	
	while [ -z $pathTemp ]
	do
		read -p "$msj" pathTemp	
		echo "de nuevo: $pathTemp "
		if [ -z $pathTemp ]
		then
			pathTemp=$pathDefault
		else
			pathTemp=$(echo $pathTemp | grep '^/.*$' )
			if [ ! -z "$pathTemp" -a "$pathTemp" != " " ]
			then	
				pathTemp=$GRUPO$pathTemp														
			fi
		fi		
	done
}

function getExtension(){
	msj=$1
	extDefault=$2
	extTemp=""
	while [ -z $extTemp ]
		do
		read -p "$msj" extTemp
		if [ -z $extTemp ]
		then
			extDefault=$2
			extTemp=$2
		else
			extTemp=$(echo $extTemp | grep '^\..*$' )
			if [ ! -z "$extTemp" -a "$extTemp" != " " ]
			then
				extDefault=$extTemp
			fi
		fi		
	done
}


function readNumber(){
	msj=$1
	numberDefault=$2
	numberTemp=""

	while [ -z $numberTemp ]
	do
		read -p "$msj: " result 

		#Si pulso enter pongo el valor por defecto    	
		if [ -z $result ]
		then
			result=$numberDefault
		fi	
		
		numberTemp=$(echo $result | grep '^[0-9]*$')
	done

	return $numberTemp
}

function executeInstaler(){
	STATUSINST=$1
	while [ -z $optIniciar ]
	do
		clear
		echo '
		*************************************************************
		*             Proceso de Instalación de "AFRA-J"            *
		*  Tema J Copyright © Grupo 12 - Segundo Cuatrimestre 2015  *
		*************************************************************
    '
    echo "
	Directorio de Configuracion: $GRUPO/conf 
	Directorio de Ejecutables:   $BINDIR 
	Directorio de  Maestros y Tablas: $MAEDIR 
	Directorio de de recepción de archivos de llamadas:  $NOVEDIR
	Espacio mínimo libre para arribos: $DATASIZE Mb
	Directorio de  archivos de llamadas Aceptadas: $ACEPDIR
	Directorio de llamadas sospechosas:  $PROCDIR
	Directorio de reportes de llamadas: $REPODIR
	Directorio de Logs de Comandos: $LOGDIR/<comando>$LOGEXT
	Tamaño máximo para los archivos de log del sistema: $LOGSIZE Kb
	Directorio de archivos rechazados: $RECHDIR
	Estado de la instalación: $STATUSINST
		"

		read -p "Iniciando Instalación. Esta Ud. seguro? (Si - No): " optIniciar 
		optIniciar=$(echo $optIniciar | grep '^[Ss][Ii]$\|^[Nn][Oo]$' | tr '[:upper:]' '[:lower:]')
	done

	#si el usuario no acepta finalizo el script
	if [ $optIniciar = "no" ]
	then
		clear
		log "Installer" "Usuario No Quiere realizar la instalacion"
		exit 4
	fi

	if [ -d $BASEDIR$GRUPO ]
	then	
		deletDirOpt=""
		while [ -z $deletDirOpt ]
		do
			read -p "Existen una instalación en el directorio $BASEDIR$GRUPO, se borraran todos los datos para realizar la nueva instalacion, esta seguro? (Si - No): " deletDirOpt 
			optSelect=$(echo $deletDirOpt | grep '^[Ss][Ii]$\|^[Nn][Oo]$' | tr '[:upper:]' '[:lower:]')
		done

		if [ $deletDirOpt = "no" ]
		then
			log "Installer" "El usuario no quiere eliminar el directorio $GRUPO existente" "I"
			exit 5
		else
			log "Installer" "Eliminando contenido de directorio $BASEDIR$GRUPO" "I"
			rm -rf $BASEDIR$GRUPO
		fi
	fi

	clear	
	echo "Creando Estructuras de directorio. . . . "
	echo $BASEDIR$BINDIR
	mkdir -p $BASEDIR$BINDIR

	echo $BASEDIR$MAEDIR
	mkdir -p $BASEDIR$MAEDIR

	echo $BASEDIR$ACEPDIR
	mkdir -p $BASEDIR$ACEPDIR

	echo $BASEDIR$PROCDIR
	mkdir -p $BASEDIR$PROCDIR

	echo $BASEDIR$REPODIR
	mkdir -p $BASEDIR$REPODIR

	echo $BASEDIR$LOGDIR
	mkdir -p $BASEDIR$LOGDIR

	echo $BASEDIR$NOVEDIR
	mkdir -p $BASEDIR$NOVEDIR

	echo $BASEDIR$RECHDIR
	mkdir -p $BASEDIR$RECHDIR

	mkdir -p $BASEDIR$GRUPO/conf

	#cp "MoverA.sh" "$BASEDIR$BINDIR/MoverA.sh"
	#chmod +r+x "$BASEDIR$BINDIR/MoverA.sh"

	#Mover los ejecutables y funciones al directorio BINDIR mostrando el siguiente mensaje
	echo "Instalando Programas y Funciones"
	#Muevo el script para mover archivos	
	#for i in $(ls *.sh *.pl)
	for i in $(ls *.sh)
	 do 
		cp "$i" "$BASEDIR$BINDIR/$i"
		chmod u+x "$BASEDIR$BINDIR/$i"
	done
	for i in $(ls *.pl)
	 do
		cp "$i" "$BASEDIR$BINDIR/$i"
		chmod u+x "$BASEDIR$BINDIR/$i"
	done


	for i in $(ls $CONFDIR)
	do
		cp "$CONFDIR/$i" "$BASEDIR$GRUPO/conf/$i"
	done

	LOGCOMMAND="$BASEDIR$BINDIR/GraLog.sh"

	#Mover los archivos maestros y tablas al directorio MAEDIR mostrando el siguiente mensaje
	echo "Instalando Archivos Maestros y Tablas"
	#for i in $(ls $DATOSDIR)
	# do 
	#cp "$DATOSDIR/$i" "$BASEDIR$MAEDIR/"
	#done	
	
	
	#Actualizar el archivo de configuración mostrando el siguiente mensaje
	echo "Actualizando la configuración del sistema"
	log "Installer" "Actualizando la configuración del sistema" "I"

	log "Installer" "Convirtiendo $GRUPO/conf/afinstall.temp  ->  $BASEDIR$GRUPO/conf/afinstall.conf" "I"

	cp "$BASEDIR$GRUPO/conf/afinstall.temp" "$BASEDIR$GRUPO/conf/afinstall.conf"

	cp -r "$BASEDIR/Datos/MAE/." "$BASEDIR$MAEDIR/"

	echo "Instalación CONCLUIDA"
	log "Installer" "Instalación CONCLUIDA" "I"

}

#Otorgo permisos a los comando que voy a utilizar
chmod u+r+x $LOGCOMMAND
	
#Inicio del instalador
log "Installer" "Inicio de Ejecución de Installer" 

echo "Log de la instalación: $CONFDIR/$LOGFILEINS"
log "Installer" "Log de la instalación: $CONFDIR/$LOGFILEINS" 

echo "Directorio predefinido de configuración: $GRUPO/conf"
log "Installer" "Directorio predefinido de configuración: $GRUPO/conf"
 
#Detecto si hay una instalacion previa
if [ -a $CONFIGFILETEMP ] 
then
	#Hay una instalación previa
	log "Installer" "Hay una instalación" "I"
		
	BASEDIRTMP=$(grep '^GRUPO' $CONFIGFILETEMP | awk -F"=" '{print $2}')
	BINDIRTMP=$(grep '^BINDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	MAEDIRTMP=$(grep '^MAEDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	NOVEDIRTMP=$(grep '^NOVEDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	DATASIZETMP=$(grep '^DATASIZE' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	ACEPDIRTMP=$(grep '^ACEPDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	PROCDIRTMP=$(grep '^PROCDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	REPODIRTMP=$(grep '^REPODIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	LOGDIRTMP=$(grep '^LOGDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	LOGEXTTMP=$(grep '^LOGEXT' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	LOGSIZETMP=$(grep '^LOGSIZE' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	RECHDIRTMP=$(grep '^RECHDIR' $CONFIGFILETEMP | awk -F"=" '{print $2}' )
	
	declare -a VAR_FALTANTES; #Array con los directorios que falta configurar 
	declare -a VAR_COMPLETO; #Array con los directorios que falta configurar 
	
	if [ -z $BASEDIRTMP ]
	then
		echo "GRUPO=$BASEDIR=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP
	fi

	if [ -z $BINDIRTMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} BINDIR)
	else
		BINDIR=$BINDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} BINDIR)	
	fi

	if [ -z $MAEDIRTMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} MAEDIR)
	else
		MAEDIR=$MAEDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} MAEDIR)	
	fi

	if [ -z $NOVEDIRTMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} NOVEDIR)
	else
		NOVEDIR=$NOVEDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} NOVEDIR)	
	fi

	if [ -z $DATASIZETMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} DATASIZE)
	else
		DATASIZE=$DATASIZETMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} DATASIZE)	
	fi

	if [ -z $ACEPDIRTMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} ACEPDIR)
	else
		ACEPDIR=$ACEPDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} ACEPDIR)	
	fi
		
	if [ -z $PROCDIRTMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} PROCDIR)
	else
		PROCDIR=$PROCDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} PROCDIR)	
	fi

	if [ -z $REPODIRTMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} REPODIR)
	else
		REPODIR=$REPODIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} REPODIR)	
	fi

	if [ -z $LOGDIRTMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} LOGDIR)
	else
		LOGDIR=$LOGDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} LOGDIR)	
	fi

	if [ -z $LOGEXTTMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} LOGEXT)
	else
		LOGEXT=$LOGEXTTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} LOGEXT)	
	fi

	if [ -z $LOGSIZETMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} LOGSIZE)
	else
		LOGSIZE=$LOGSIZETMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} LOGSIZE)	
	fi

	if [ -z $RECHDIRTMP ]
	then 
		VAR_FALTANTES=( ${VAR_FALTANTES[*]} RECHDIR)
	else
		RECHDIR=$RECHDIRTMP
		VAR_COMPLETO=( ${VAR_COMPLETO[*]} RECHDIR)	
	fi

	if [ ${#VAR_FALTANTES[@]} -eq 0 ] #No falta ninguna variable en el archivo temporal
	then	
		initInstalation
	else	
	echo "Direct. de Configuracion: $GRUPO/conf"
		
	for VARVALUE in "${VAR_COMPLETO[@]}"; do
		case $VARVALUE in
			BINDIR )
				echo "Directorio Ejecutables:   $BINDIR";;
			MAEDIR )
				echo "Directorio de Maestros y Tablas: $MAEDIR";;
			NOVEDIR )
				echo "Directorio de recepción de archivos de llamadas:  $NOVEDIR";;
			DATASIZE )
				echo "Espacio mínimo libre para arribos: $DATASIZE Mb";;
			ACEPDIR )
				echo "Directorio de llamadas aceptadas: $ACEPDIR";;
			PROCDIR )
				echo "Directorio de llamadas sospechosas:  $PROCDIR";;
			REPODIR )
				echo "Directorio de Archivos de reportes de llamadas: $REPODIR";;
			LOGDIR )
				echo "Directorio de Logs de Comandos: $LOGDIR/<comando>$LOGEXT";;
			#LOGEXT )
				#echo "LOGEXT: $LOGEXT";;
			LOGSIZE )
				echo "Tamaño máximo para los archivos de log del sistema: $LOGSIZE Kb";;
			RECHDIR )
				echo "Directorio de Archivos rechazados: $RECHDIR";;
			esac
	done

	echo ""	
	echo "Componentes Faltantes: "	
	for VARVALUE in "${VAR_FALTANTES[@]}"
	do
		case $VARVALUE in
			BINDIR )
				echo "Directorio Ejecutables";;
			MAEDIR )
				echo "Directorio de Maestros y Tablas";;
			NOVEDIR )
				echo "Directorio de recepción de archivos de llamadas";;
			DATASIZE )
				echo "Espacio mínimo libre para arribos";;
			ACEPDIR )
				echo "Directorio de llamadas aceptadas";;
			PROCDIR )
				echo "Directorio de llamdas sospechosas";;
			REPODIR )
				echo "Directorio de Archivos de reportes de llamadas";;
			LOGDIR )
				echo "Directorio de Logs de Comandos";;
			#LOGEXT )
				#echo "LOGEXT: $LOGEXT";;
			LOGSIZE )
				echo "Tamaño máximo para los archivos de log del sistema";;
			RECHDIR )
				echo "Directorio de Archivos rechazados";;
			esac
	done
	echo ""
	echo "Estado de la instalación: INCOMPLETA"	

	while [ -z $optSelect ]
	do
		read -p " Desea completar la instalación? (Si - No): " optSelect 
		optSelect=$(echo $optSelect | grep '^[Ss][Ii]$\|^[Nn][Oo]$' | tr '[:upper:]' '[:lower:]')
	done
		if [ $optSelect = "no" ]
	then
		log "Installer" "Usuario no quiere continuar con la instalación" "I"
		exit 6
	fi

	for VARVALUE in "${VAR_FALTANTES[@]}"; do
		case $VARVALUE in
			BINDIR )
				getDirectoryPath "Defina el directorio de instalación de los ejecutables ($BINDIR):" "$BINDIR" 
				BINDIR=$pathTemp
				echo "BINDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			MAEDIR )
				getDirectoryPath "Defina directorio para maestros y tablas ($MAEDIR):" "$MAEDIR"
				MAEDIR=$pathTemp
				echo "MAEDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			NOVEDIR )
				getDirectoryPath "Defina el Directorio de recepción de archivos de llamadas ($NOVEDIR):" "$NOVEDIR"
				NOVEDIR=$pathTemp
				echo "NOVEDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			DATASIZE )
				readNumber "Defina espacio mínimo libre para el arribo de archivos de llamadas en Mbytes ($DATASIZE)" "$DATASIZE"
				DATASIZETEMP=$numberTemp
				DATASIZEDIR=$(df -B1024 "$ACTUALDIR" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';')
				DATASIZEDIR=$(echo "scale=0 ; $DATASIZEDIR/1024" | bc -l) #lo paso a Mb	

				while [ $DATASIZEDIR -lt $DATASIZETEMP ] 
				do
					echo "Insuficiente espacio en disco."
					echo "Espacio disponible: $DATASIZEDIR Mb."
					echo "Espacio requerido $DATASIZETEMP Mb"
					echo "Inténtelo nuevamente."
					echo ""	
					readNumber "Defina espacio mínimo libre para el arribo de archivos de llamadas en Mbytes ($DATASIZE)" "$DATASIZE"
					DATASIZETEMP=$numberTemp
				done
				DATASIZE=$DATASIZETEMP
				echo "DATASIZE=$DATASIZETEMP=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			ACEPDIR )
				getDirectoryPath "Defina el directorio de grabación de los archivos de llamadas aceptadas ($ACEPDIR):" "$ACEPDIR"
				ACEPDIR=$pathTemp
				echo "ACEPDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			PROCDIR )
				getDirectoryPath "Defina el directorio de grabación de los registros de llamadas sospechosas ($PROCDIR):" "$PROCDIR"
				PROCDIR=$pathTemp
				echo "PROCDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			REPODIR )
				getDirectoryPath "Defina el directorio de grabación de los reportes ($REPODIR):" "$REPODIR"
				REPODIR=$pathTemp	
				echo "REPODIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			LOGDIR )
				getDirectoryPath "Defina el directorio de logs ($LOGDIR):" "$LOGDIR"
				LOGDIR=$pathTemp	
				echo "LOGDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			LOGEXT )
				getExtension "Ingrese la extensión para los archivos de log ($LOGEXT): " "$LOGEXT"
				LOGEXT=$extDefault
				echo "LOGEXT=$extDefault=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			LOGSIZE )
				readNumber "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE)" "$LOGSIZE"
				LOGSIZETEMP=$numberTemp
				LOGSIZEDISP=$(df -B1024 "$ACTUALDIR" | tail -n1 | sed -e"s/\s\{1,\}/;/g" | cut -f4 -d';')
				#LOGSIZEDISP=$(echo "scale=0 ; $LOGSIZEDISP/1024" | bc -l) #lo paso a Mb	
		
				while [ $LOGSIZEDISP -lt $LOGSIZETEMP ] 
				do
					echo "Insuficiente espacio en disco."
					echo "Espacio disponible: $LOGSIZEDISP Kb."
					echo "Espacio requerido $LOGSIZETEMP Kb"
					echo "Inténtelo nuevamente."
					echo ""	
					readNumber "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE)" "$LOGSIZE"
					LOGSIZETEMP=$numberTemp
				done
				LOGSIZE=$LOGSIZETEMP
				echo "LOGSIZE=$LOGSIZETEMP=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
			RECHDIR )
				getDirectoryPath "Defina el directorio de grabación de los reportes ($RECHDIR):" "$RECHDIR"
				RECHDIR=$pathTemp	
				echo "RECHDIR=$pathTemp=$USER=`date +'%d-%m-%Y %H:%M:%S'`" >> $CONFIGFILETEMP;;
		esac		
	done
	fi

	executeInstaler "LISTA"

else
	#NO Hay una instalación previa
	log "Installer" "No hay instalación, mostrando aceptación de terminos y condiciones" "I"

	initInstalation
	
	executeInstaler "LISTA"
exit 0;
fi
