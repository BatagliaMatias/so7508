#!/bin/bash

#***************************Variables***************************

#Directorios de archivos
dirArchivosProcesados='proc/'
dirLlamadasRechazados='llamadas/'
#Archivos
arcMaestrodeAgentes="agentes.mae"
arcCodAreaArg="CdA.mae"
arcCodPais="CdP.mae"
arcUmbral="umbrales.tab"
#Variables
listaDeArchivos=""
IDCentral=""
cantidadDeArchivos=0
registroValido=""
camposValidos=""
IDAgente=""
codAreaA=""
numeroDeLineaA=""
tiempo=""
codPaisB=""
codAreaB=""
numLineaB=""
tipoDeLlamado=""
IDUmbral=""
umbrales=""
DIAS_LIMITE=365

#***************************Funciones***************************

mkdir -p "$PROCDIR/$dirArchivosProcesados"
mkdir -p "$RECHDIR/$dirLlamadasRechazados"

function existeArchivo
{

	declare local existeArchivo="$1"

	if [ -f "$existeArchivo" ]
	then
		return
	else
		$GRALOG "AFUMB" "No existe: $existeArchivo Fin de AFUMB " "ERR"
		exit 1
	fi

}
function existeDirectorio
{

	declare local existeDirectorio="$1"

	if [ -d "$existeDirectorio" ]
	then
		return
	else
		$GRALOG "AFUMB" "No existe: $existeDirectorio Fin de AFUMB " "ERR"
		exit 1
	fi

}
function grabar_llamada_sospechosa
{

	declare local arc="$1"
	declare local reg="$2"
	declare local inicioDeLlamada
	declare local fecha
	declare local oficina
	declare local nombreArchivo

	inicioDeLlamada=`echo $reg | grep '^[^;]*;\([^;]*\);[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$' | sed 's/^[^;]*;\([^;]*\);[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$/\1/'`

	fecha=`echo $reg | grep '^[^;]*;\([0-3][0-9]\)/\([0-1][0-9]\)/\([0-9]\{4\}\) [^;]*;.*$' | sed  's-^[^;]*;\([0-3][0-9]\)/\([0-1][0-9]\)/\([0-9]\{4\}\) [^;]*;.*$-\3\2-'`

	existeArchivo "$MAEDIR/$arcMaestrodeAgentes"

	oficina=`grep "^[^;]*;[^;]*;$IDAgente;[^;]*;[^;]*$" $MAEDIR/$arcMaestrodeAgentes | sed "s/^[^;]*;[^;]*;$IDAgente;\(.*\);.*$/\1/"`

	nombreArchivo="$oficina""_""$fecha"

	existeDirectorio "$PROCDIR"

	echo "$IDCentral;$IDAgente;$IDUmbral;$tipoDeLlamado;$inicioDeLlamada;$tiempo;$codAreaA;$numeroDeLineaA;$codPaisB;$codAreaB;$numLineaB;${arc:4}" >> "$PROCDIR/""$nombreArchivo"

}

function buscar_umbral
{

	declare local codigoDestino
	if [ "$tipoDeLlamado" = "DDI" ]
	then
		codigoDestino=$codPaisB
	else
		codigoDestino=$codAreaB
	fi
	#declare local umbrales
	declare local tiempoTope

	
	IDUmbral=""
	
	existeArchivo "$MAEDIR/$arcUmbral"

	umbrales=`echo $umbrales | grep "^[^;]*;$codAreaA;$numeroDeLineaA;$tipoDeLlamado;\($codigoDestino\|\);[0-9^;]*;Activo$" $MAEDIR/$arcUmbral`

	for umbral in $umbrales
	do
		tiempoTope=`echo $umbral | sed 's/^[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\([0-9^;]*\);[^;]*$/\1/'`
		if [ $tiempoTope -lt $tiempo ]
		then
			IDUmbral=`echo $umbral | sed 's/^\([0-9^;]*\);[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$/\1/'`
			return
		fi
	done

}

function obtener_umbrales
{

	existeArchivo "$MAEDIR/$arcUmbral"

	umbrales=""
	umbrales=`grep "^[^;]*;$codAreaA;$numeroDeLineaA;$tipoDeLlamado;[^;]*;[^;]*;[^;]*$" "$MAEDIR/$arcUmbral"`

}

function rechazar_archivo
{

	declare local arc="$1"
	declare local reg="$2"
	declare local motivo="$3"

	existeDirectorio "$RECHDIR/$dirLlamadasRechazados"

	echo "$arc;$motivo;$reg" >> "$RECHDIR/$dirLlamadasRechazados$IDCentral.rech"

}

function validar_numero_B
{

	declare local arc="$1"
	declare local reg="$2"
	declare local existeCodPaisB
	#declare local CodPaisBValido
	declare local existeCodAreaB
	tipoDeLlamado=""

	existeArchivo "$MAEDIR/$arcCodPais"

	existeCodPaisB=`grep "^$codPaisB;[^;]*$" $MAEDIR/$arcCodPais`

	existeArchivo "$MAEDIR/$arcCodAreaArg"

	existeCodAreaB=` grep "^[^;]*;$codAreaB$" $MAEDIR/$arcCodAreaArg`

	if [ "$existeCodPaisB" = "" -a "$codPaisB" != "" ]
	then
		rechazar_archivo "$arc" "$reg" "El codigo de pais no existe"
		$GRALOG "AFUMB" "Llamada rechazada: $reg El codigo de pais no existe" "WAR"
		camposValidos="NO"
		return
	fi	

	if [ "$existeCodAreaB" = "" -a "$codAreaB" != "" ]
	then
		rechazar_archivo "$arc" "$reg" "El codigo de area B no existe"
		$GRALOG "AFUMB" "Llamada rechazada: $reg El codigo de area B no existe" "WAR"
		camposValidos="NO"
		return
	fi

	if [ "$codAreaB" = "" -a "$codPaisB" = "" ]
	then
		rechazar_archivo "$arc" "$reg" "El codigo de area B es invalido"
		$GRALOG "AFUMB" "Llamada rechazada: $reg El codigo de area B es invalido" "WAR"
		camposValidos="NO"
		return
	fi

	if [ "$codPaisB" != "" -a "$numLineaB" != "" -a "$codAreaB" = "" ]
	then
		tipoDeLlamado="DDI"
		return
	fi
	
	declare local longitud
	longitud=`expr ${#codAreaB} + ${#numLineaB}`

	if [ "$codPaisB" = "" -a "$codAreaB" = "$codAreaA" -a "$longitud" -eq 10 ]
	then
		tipoDeLlamado="LOC"
		return
	fi

	if [ "$codPaisB" = "" -a "$codAreaB" != "$codAreaA" -a "$longitud" -eq 10 ]
	then
		tipoDeLlamado="DDN"
		return
	fi

	rechazar_archivo "$arc" "$reg" "La llamada no es ni DDI, ni DDN, ni LOC"
	$GRALOG "AFUMB" "Llamada rechazada: $reg La llamada no es ni DDI, ni DDN, ni LOC" "WAR"
	camposValidos="NO"

}

function verificar_numero_linea_A
{

	declare local cantidadDeDigitos
	cantidadDeDigitos=`expr ${#codAreaA} + ${#numeroDeLineaA}`

	if [ $cantidadDeDigitos -ne 10 ]
	then
		camposValidos="NO"
	fi

}

function verificar_codigo_area_A
{

	declare local existeCodigoAreaA=""

	existeArchivo "$MAEDIR/$arcCodAreaArg"

	existeCodigoAreaA=` grep "^[^;]*;$codAreaA$" $MAEDIR/$arcCodAreaArg`
	if [ "$existeCodigoAreaA" = "" ]
	then
		camposValidos="NO"
	fi

}

function verificar_ID
{

	declare local existeIDAgente=""

	existeArchivo "$MAEDIR/$arcMaestrodeAgentes"

	existeIDAgente=`grep "^[^;]*;[^;]*;$IDAgente;[^;]*;[^;]*$" $MAEDIR/$arcMaestrodeAgentes`
	
	if [ "$existeIDAgente" = "" ]
	then
		camposValidos="NO"
	fi

}

function cargar_campos
{

	declare local arc="$1"
	declare local reg="$2"

	#Carga ID del agente
	IDAgente=`echo $reg | sed 's/^\([^;]*\);[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$/\1/'`

	#Cargo codigo de area A
	codAreaA=`echo $reg | grep $'^[^;]*;[^;]*;[^;]*;[0-9^;]*;[^;]*;[^;]*;[^;]*;[^;]*$' | sed 's/^[^;]*;[^;]*;[^;]*;\([0-9^;]*\);[^;]*;[^;]*;[^;]*;[^;]*$/\1/'`

	if [ "$codAreaA" = "" ]
	then
		rechazar_archivo "$arc" "$reg" "El codigo de area A tiene caracteres invalidos"
		$GRALOG "AFUMB" "Llamada rechazada: $reg El codigo de area A tiene caracteres invalidos" "WAR"
		camposValidos="NO"
		return
	fi

	#Cargo numero de linea A
	numeroDeLineaA=`echo $reg | grep '^[^;]*;[^;]*;[^;]*;[^;]*;[0-9^;]*;[^;]*;[^;]*;[^;]*$' | sed 's/^[^;]*;[^;]*;[^;]*;[^;]*;\([0-9^;]*\);[^;]*;[^;]*;[^;]*$/\1/'`

	if [ "$numeroDeLineaA" = "" ]
	then
		rechazar_archivo "$arc" "$reg" "El numero de linea A tiene caracteres invalidos"
		$GRALOG "AFUMB" "Llamada rechazada: $reg El numero de linea A tiene caracteres invalidos" "WAR"
		camposValidos="NO"
		return
	fi

	#Cargo tiempo de llamada
	tiempo=`echo $reg | grep '^[^;]*;[^;]*;\([0-9^;]*\);[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$' | sed 's/^[^;]*;[^;]*;\([0-9^;]*\);[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$/\1/'`

	#Cargo numero B
	codPaisB=`echo $reg | sed 's/^[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\([^;]*\);[^;]*;[^;]*$/\1/'`

	codAreaB=`echo $reg | grep '^[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\([0-9^;]*\);[^;]*$' | sed 's/^[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\([0-9^;]*\);[^;]*$/\1/'`

	numLineaB=`echo $reg | grep '^[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\([0-9^;]*\)$' | sed 's/^[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;\([0-9^;]*\)$/\1/'`

	if [ "$numLineaB" = "" ]
	then
		rechazar_archivo "$arc" "$reg" "El numero de linea B tiene caracteres invalidos"
		$GRALOG "AFUMB" "Llamada rechazada: $reg El numero de linea B tiene caracteres invalidos" "WAR"
		camposValidos="NO"
		return
	fi

}

#Solo verifica la cantidad de campos del registro
function verificar_registro
{

	declare local reg="$1"
	registroValido=` echo $reg | grep '^[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*;[^;]*$'`

}

function validar_campos
{

	declare local arch="$1"
	declare local reg="$2"
	camposValidos="SI"
	#Verifica la cantidad de campos del registro
	verificar_registro "$reg"
	if [ "$registroValido" = "" ]
	then
		rechazar_archivo "$arch" "$reg" "La cantidad de campos no es correcta"
		$GRALOG "AFUMB" "Llamada rechazada: $reg la cantidad de campos no es correcta" "WAR"
		camposValidos="NO"
		return
	fi

	cargar_campos "$arch" "$reg"

	if [ "$camposValidos" = "NO" ]
	then
		return
	fi
	
	verificar_ID

	if [ "$camposValidos" = "NO" ]
	then
		rechazar_archivo "$arch" "$reg" "La ID no existe"
		$GRALOG "AFUMB" "Llamada rechazada: $reg la La ID no existe" "WAR"
		return
	fi

	verificar_codigo_area_A

	if [ "$camposValidos" = "NO" ]
	then
		rechazar_archivo "$arch" "$reg" "El codigo de area A no existe"
		$GRALOG "AFUMB" "Llamada rechazada: $reg El codigo de area A no existe" "WAR"
		return
	fi

	verificar_numero_linea_A

	if [ "$camposValidos" = "NO" ]
	then
		rechazar_archivo "$arch" "$reg" "El codigo de area mas el numero de linea es distinto a 10 digitos"
		$GRALOG "AFUMB" "Llamada rechazada: $reg El codigo de area mas el numero de linea es distinto a 10 digitos" "WAR"
		return
	fi

	if [ "$tiempo" = "" ]
	then
		camposValidos="NO"
		rechazar_archivo "$arch" "$reg" "El tiempo de comunicacion posee un valor invalido"
		$GRALOG "AFUMB" "Llamada rechazada: $registro El tiempo de comunicacion posee un valor invalido" "WAR"
		return
	fi

	validar_numero_B "$arch" "$reg"

}

function obtener_cantidad
{

	declare local archivos="$1"
	cantidadDeArchivos=0
	for i in $archivos
	do
		cantidadDeArchivos=`expr $cantidadDeArchivos + 1`
	done

}

function ordenar_archivos
{

	declare local archivosValidos=""

	for file in $listaDeArchivos
	do
		if ! [[ $file =~ ^[a-zA-Z]{3}_[0-9]{8}$ ]];
		then
			$GRALOG "AFUMB" "Archivo Rechazado, $file tiene formato incorrecto" "WAR"
			$MOVER_A "$ACEPDIR/$file" "$RECHDIR"
			continue
		fi
		DATE=$(echo $file|cut -d'_' -f2 |cut -d'.' -f1)
		
		if ! (date -d $DATE >> /dev/null 2>&1)
		then
			$GRALOG "AFUMB" "Archivo Rechazado, $file fecha incorrecta" "WAR"
			$MOVER_A "$ACEPDIR/$file" "$RECHDIR"
			DIFERENCIA_DIAS="-10"
			continue
		else
		DIFERENCIA_DIAS=$(( ($(date --date="$TODAY" +%s) - $(date --date="$DATE" +%s)  )/(60*60*24) ));
		fi			

		if [ "$DIFERENCIA_DIAS" -gt "$DIAS_LIMITE" ];
		then
			$GRALOG "AFUMB" "Archivo Rechazado, $file fecha superior a un anio" "WAR"
			$MOVER_A "$ACEPDIR/$file" "$RECHDIR"
			continue
		fi

		if [ "$DIFERENCIA_DIAS" -lt 0 ];
		then 
			$GRALOG "AFUMB" "Archivo Rechazado, $file fecha del futuro" "WAR"
			$MOVER_A "$ACEPDIR/$file" "$RECHDIR"
			continue
		fi

		archivosValidos="$archivosValidos $file"

	done

	obtener_cantidad "$archivosValidos"

	$GRALOG "AFUMB" "Inicio de AFUMB. Cantidad de archivos a procesar: $cantidadDeArchivos" "INFO"

	archivosValidos=` echo $archivosValidos | tr " " "\n" | sort -t '_' -k2 | tr "\n" " "`

	listaDeArchivos=$archivosValidos

}

function obtener_archivos
{

	existeDirectorio "$ACEPDIR"
	declare local archivos=` ls $ACEPDIR`

	for i in $archivos
	do
		#Puede haber directorios
		if [ -f "$ACEPDIR/$i" ]
		then
			listaDeArchivos="$listaDeArchivos $i"
		fi
	done

	ordenar_archivos
	
}

#***************************Incio de AFUMB***************************
LANG='en_US.ISO-8859-15'
obtener_archivos
archivosRechazados=0
for archivo in $listaDeArchivos
do
	IDCentral="${archivo:0:3}"
	llamadasConUmbral=0
	llamadasSinUmbral=0
	llamadasSospechosas=0
	registrosRechazdos=0
	cantidadDeRegistros=0

	existeDirectorio "$PROCDIR/$dirArchivosProcesados"

	if [ -f "$PROCDIR/$dirArchivosProcesados$archivo" ]
	then
		diferencia=`diff "$ACEPDIR/$archiv" "$PROCDIR/$dirArchivosProcesados$archivo"`
		if [ "$diferencia" = ""  ]
		then
			archivosRechazados=`expr $archivosRechazados + 1`
			$GRALOG "AFUMB" "Se rechaza el archivo: $archivo por estar DUPLICADO" "WAR"
			$MOVER_A "$ACEPDIR/$archivo" "$RECHDIR" "AFUMB"
			continue
		fi
	fi
	#Primer registro del archivo
	registro=`head -1 "$ACEPDIR/$archivo"`
	verificar_registro "$registro"
	if [ "$registroValido" = "" ]
	then
		archivosRechazados=`expr $archivosRechazados + 1`
		$GRALOG "AFUMB" "Se rechaza el archivo: $archivo porque su estructura no se corresponde con el formato esperado." "WAR"
		$MOVER_A "$ACEPDIR/$archivo" "$RECHDIR" "AFUMB"
		continue
	fi
	$GRALOG "AFUMB" "Archivo a procesar: $archivo" "INFO"
	IFS='
'
	for registro in `cat "$ACEPDIR/$archivo"`
	do
		cantidadDeRegistros=`expr $cantidadDeRegistros + 1`
		validar_campos "$archivo" "$registro"
		if [ "$camposValidos" = "NO" ]
		then
			registrosRechazdos=`expr $registrosRechazdos + 1`
			continue
		fi
		obtener_umbrales
		if [ "$umbrales" != "" ]
		then
			llamadasConUmbral=`expr $llamadasConUmbral + 1`
			buscar_umbral
			if [ "$IDUmbral" != ""  ]
			then
				llamadasSospechosas=`expr $llamadasSospechosas + 1`
				grabar_llamada_sospechosa "$archivo" "$registro"
			fi
		else
			llamadasSinUmbral=`expr $llamadasSinUmbral + 1`
		fi
	done
	llamadasNoSospechosas=`expr $llamadasConUmbral - $llamadasSospechosas`
	echo -e "    . Cantidad de llamadas: $cantidadDeRegistros: Rechazadas: $registrosRechazdos, Con umbral = $llamadasConUmbral, Sin umbral $llamadasSinUmbral\n    . Cantidad de llamadas sospechosas: $llamadasSospechosas, no sospechosas: $llamadasNoSospechosas"

	$MOVER_A "$ACEPDIR/$archivo" "$PROCDIR/$dirArchivosProcesados" "AFUMB"
	IFS=' '
done

archivosProcesados=`expr $cantidadDeArchivos - $archivosRechazados`
$GRALOG "AFUMB" ". Cantidad de archivos procesados: $archivosProcesados. Cantidad de archivos rechazados: $archivosRechazados Fin de AFUMB" "INFO"
#Hace falta??
#IFS=' '
#LANG='es_AR.UTF-8'
