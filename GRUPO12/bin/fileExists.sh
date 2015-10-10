#!/bin/bash
#Verifico que tenga la cantidad de parametros necesarios
status="0"
if [ $# -ne 2 ] 
then
	echo "fileExists - Cantidad de parametros invalidos"
	status="1"
else
	existeArchivo="$1"
	cmdLogger="$2"
	if [ -f "$existeArchivo" ]
	then
		status="0"
	else
		$GRALOG "$2" "No existe: $existeArchivo\nFin de $2 " "ERR"
		status="1"
	fi
fi
echo "$status"

