#!/bin/bash
if [ $# -ne 1 ] 
then
       echo "CheckVars - Cantidad de parametros invalidos"
       exit 1
fi

environmentOk=$("$BINDIR"/verifyEnvironment.sh "$1")
if [ "$environmentOk"  != "0" ]; then
       echo "FALTA INICIALIZAR EL ENTORNO - Ejecutar: 'source AFINI.sh'"
       exit 1
fi
exit 0