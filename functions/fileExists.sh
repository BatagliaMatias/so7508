#!/bin/bash
#Verifico que tenga la cantidad de parametros necesarios
if [ $# -ne 2 ] 
then
	echo "fileExists - Cantidad de parametros invalidos"
	exit 1
fi

existeArchivo="$1"
cmdLogger="$2"
if [ -f "$existeArchivo" ]
then
	exit 0
else
	$GRALOG "$2" "No existe: $existeArchivo\nFin de $2 " "ERR"
	exit 1
fi