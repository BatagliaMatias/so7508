#!/bin/bash
if [ $# -ne 1 ] 
then
       echo "CheckVars - Cantidad de parametros invalidos"
       return 1
fi

environmentOk=$(./verifyEnvironment.sh "$1")
if [ "$environmentOk"  != "0" ]; then
       echo "FALTA INICIALIZAR EL ENTORNO - Ejecutar: 'source AFINI.sh'"
       exit 1
fi
echo "PASE"
exit 0