#!/bin/bash

# You need to add this line below.
IFS=$'\n' 

ORIGEN=$1
DESTINO=$2
PROCESO=$3
ERR_ARCH_NO_EXISTE=4
ERR_DIR_NO_EXISTE=5
ERR_CANT_PARAM=2
ERR_ORIGEN_IGUAL_DESTINO=6

#LOGEXT="log" #VIENE DE AFUERA
PATH=${PATH}:$PWD #VIENE DE AFUERA



############################################# COMIENZO DEL SCRIPT ########################################################

#declare -x RUNDIRECTORY="${0%%/*}"
#echo "el rundirectory es $RUNDIRECTORY"


if [ $# -ne 3 -a $# -ne 2 ]
then
	echo "Cantidad erronea de parametros"
	#GraLog "MoverA" $ERR_CANT_PARAM "2 o 3"
        $GRALOG "MoverA" "$ERR_CANT_PARM" "INFO"
	exit $ERR_CANT_PARAM
fi
if [ ! -f "$ORIGEN" ];then
	echo "Archivo origen inexistente"
	#GraLog "MoverA" $ERR_ARCH_NO_EXISTE $ORIGEN
        $GRALOG "MoverA" "$ERR_ARCH_NO_EXISTE $ORIGEN" "INFO"
	exit $ERR_ARCH_NO_EXISTE
fi
if [ ! -d "$DESTINO" ];then
	echo "Directorio destino inexistente"
	#GraLog "MoverA" $ERR_DIR_NO_EXISTE $DESTINO
        $GRALOG "MoverA" "$ERR_DIR_NO_EXISTE $DESTINO" "INFO"
	exit $ERR_DIR_NO_EXISTE
fi
if [ "$ORIGEN" == "$DESTINO" ];then

	echo "Archivo origen igual al directorio destino "
	#GraLog "MoverA" "$ERR_ORIGEN_IGUAL_DESTINO $ORIGEN"
    $GRALOG "MoverA" "$ERR_ORIGEN_IGUAL_DESTINO $ORIGEN $DESTINO" "INFO"
	exit $ERR_ORIGEN_IGUAL_DESTINO
fi


NOMBRE_ARCHIVO=${ORIGEN##*/}
#echo "VARIABLE DEPURADA $DEPURADA"


COPIA=$DESTINO/$NOMBRE_ARCHIVO

if [ ! -f "$COPIA" ];then
	#echo "MOVER STANDARD"

	mv $ORIGEN $DESTINO/
else
	DUPLICADO='/DUP'	
	CARPETA_DUPLICADO=${DESTINO}$DUPLICADO
	if [ ! -d "$CARPETA_DUPLICADO" ]; then
		mkdir $CARPETA_DUPLICADO
		echo "Carpeta $CARPETA_DUPLICADO creada"
		mv $ORIGEN $CARPETA_DUPLICADO/
	#	echo "MOVER DUPLICADO"
	else
		#CHECKDIR=$CARPETA_DUPLICADO/$ORIGEN
		CHECKDIR=$CARPETA_DUPLICADO/$NOMBRE_ARCHIVO
		CHECKDIRAUX=$CHECKDIR
	#	echo "DIRECCION DUPLICADO $CHECKDIR"
		CONTADOR=0
	# Evaluo si el archivo duplicado con ese nombre si existe. En caso de exisitr le agrego una terminacion
	# que no se encuentre utilizada
		while [ -f "$CHECKDIR" ]; do 
	#		echo "ENTRO AL WHILE"	
	#		echo "PATH A PUNTO DE MIRAR: $CHECKDIR"
			CONTADOR=`expr $CONTADOR + 1`
			TERMINACION='.'"$CONTADOR"	
			CHECKDIR=${CHECKDIRAUX}$TERMINACION
		done
#		RENOMBRADO=$ORIGEN$TERMINACION
		RENOMBRADO=$NOMBRE_ARCHIVO$TERMINACION
		mv $ORIGEN $RENOMBRADO 
		mv $RENOMBRADO $CARPETA_DUPLICADO/
	fi
fi
if [ $# -eq 3 ]
then
	#GraLog "MoverA" I "Se movio el archivo exitosamente mediante el comando $3"
         $GRALOG "MoverA" "Se movio el archivo exitosamente mendiante el comando $3" "INFO"
else
	#GraLog "MoverA" I "Se movio el archivo exitosamente desde la consola"
        $GRALOG "MoverA" "Se movio el archivo exitosamente desde la consola" "INFO"
fi

exit 0
