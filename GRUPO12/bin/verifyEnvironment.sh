#!/bin/bash
#Verifico que esten seteadas las variables
CMD="$1"
status="0"
if [[ "$GRALOG" == "" ]]
then
       echo "No se encuentra inicializada la variable GRALOG"
       status="1"
else
       if [[ "$CONFDIR" == "" ]]
       then
              echo "No se encuentra inicializada la variable CONFDIR"
              $GRALOG "$CMD" "No se encuentra inicializada la variable CONFDIR" "ERR"
              status="1"
       fi
       if [[ "$BINDIR" == "" ]]
       then
              echo "No se encuentra inicializada la variable BINDIR"
              $GRALOG "$CMD" "No se encuentra inicializada la variable BINDIR" "ERR"
              status="1"
       fi
       if [[ "$MAEDIR" == "" ]]
       then
              echo "No se encuentra inicializada la variable MAEDIR"
              $GRALOG "$CMD" "No se encuentra inicializada la variable MAEDIR" "ERR"
              status="1"
       fi
       if [[ "$NOVEDIR" == "" ]]
       then
              echo "No se encuentra inicializada la variable NOVEDIR"
              $GRALOG "$CMD" "No se encuentra inicializada la variable NOVEDIR" "ERR"
              status="1"
       fi
       if [[ "$ACEPDIR" == "" ]]
       then
              echo "No se encuentra inicializada la variable ACEPDIR"
              $GRALOG "$CMD" "No se encuentra inicializada la variable ACEPDIR" "ERR"
              status="1"
       fi
       if [[ "$PROCDIR" == "" ]]
       then
              echo "No se encuentra inicializada la variable PROCDIR"
              $GRALOG "$CMD" "No se encuentra inicializada la variable PROCDIR" "ERR"
              status="1"
       fi
       if [[ "$REPODIR" == "" ]]
       then
              echo "No se encuentra inicializada la variable REPODIR"
              $GRALOG "$CMD" "No se encuentra inicializada la variable REPODIR" "ERR"
              status="1"
       fi
       if [[ "$LOGDIR" == "" ]]
       then
              echo "No se encuentra inicializada la variable LOGDIR"
              $GRALOG "$CMD" "No se encuentra inicializada la variable LOGDIR" "ERR"
              status="1"
       fi
       if [[ "$RECHDIR" == "" ]]
       then
              echo "No se encuentra inicializada la variable RECHDIR"
              $GRALOG "$CMD" "No se encuentra inicializada la variable RECHDIR" "ERR"
              status="1"
       fi

fi
echo "$status"