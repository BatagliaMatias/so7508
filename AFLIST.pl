#!/usr/bin/perl 
use Getopt::Long;


#Hashes
%centralesHash;


# Variables de argumentos.
$help = 0;
$stats=0;
$query = 0;
$fileIn = '';
@oficinas =(); #Guarda el filtro de oficinas
@aniomes =(); #Guarda el filtro de aniomes


# Flags de filtros
$typeRanking=0; #1:Tiempo de llamadas 2:Cantidad de llamadas 3:Ambas anteriores
$writeToFileFlag=0;
$matchStrFlag=0;
$printFlag=0;





# Seteo las variables en base a la informacion que brinda el entorno
sub parseConfig{
	
	$maeDir = "$MAEDIR";
	
	$centrales = $maeDir."/centrales.csv";
	#$agentes = $maeDir. "/agentes.csv";
	
}

#$PROCDIR aca estan las sospechosas

#Parsea los argumentos ingresados por el usuario
sub parseArguments()
{
	@myArgs = @ARGV;
	GetOptions('help|h' => \$help, 
				"fileIn|i" => \$fileIn,
				"writeToFile|w" => \$writeToFileFlag,
				"query|r" => \$query,
				'statistic|s' => \$stats,
				"oficinas|o" => \$oficinas,
				'aniomes|aniomes=s'=>  \@aniomes,
				);
	if( $help == 1 ) 
	{
		# Si encuentra -h imprime ayuda y sale
		showHelpMenu();
		exit 1;
	}

	if( $query ==1)
	{
		showQueryMenu();
		exit 1;
	}

	if( $stats == 1 ) 
	{
		@aniomes= split(/,/,join(',',@aniomes));
		print @aniomes[1];
		loadHashes();
		showStatsMenu();
		if($statChoice >=1 and $choice <= 3)
		{
			showRankingType();
		}
		elsif($statChoice == 6)
		{
			exit 1;
		}
		makeStatQuery();

		exit 1;
	}




}


#Menu para mostrar las opciones de la Consulta
sub showQueryMenu()
{
	#c: filtro por central
	#a: filtro por agente
	#u: filtro por umbral
	#t: filtro por tipo de llamada
	#m: filtro por tiempo de conv
	#na: filtro por número A
	#nb: filtro por número B
	#Validar filtros
}




#Menu para mostrar las opciones de la estadistica
sub showStatsMenu()
{

print "\n\tSELECCION DE RANKING
	-----------------------------------------------------------------------
	1) Ranking de Centrales
	2) Ranking de Oficinas
	3) Ranking de Agentes
	4) Ranking de Destinos
	5) Ranking de Umbrales
	6) Salir
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$statChoice = <>;
	print $statChoice;
}


#Menu para mostrar las opciones de tipo de ranking
sub showRankingType()
{
print "\n\tTIPO DE RANKING
	-----------------------------------------------------------------------
	1) Tiempo de llamadas
	2) Cantidad de llamadas
	3) Tiempo de llamadas y Cantidad de llamadas
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$typeRanking = <>;
	print $typeRanking;
}




#Realiza la consulta sobre los archivos solicitados
sub getQuery()
{


}

#Graba el resultado en un archivo subllamada.xxx dónde xxx es un descriptor siempre distinto que asegura no sobrescribir ningún subllamada previo.
sub saveQueryResult()
{

}


#Muestra por pantalla el nombre del archivo y la cantidad de registros resultantes
sub showQueryResult()
{


}


# Cargo los hashes de Centrales, oficinas, agentes,...
sub loadHashes()
{
	# Abro los archivos de Centrales, Oficinas, Agentes..-
	open F_CENTRALES, "<", "$centrales" or die "No se pudo abrir el archivo de $centrales";


	#Recorro secuencialmente los archivos
	while(<F_CENTRALES>)
	{
		chomp;
		($codCentral, $descCentral) = split(";");
		$centralesHash{$codCentral}=[$descCentral,0,0];
	}
	
	#Cierro los archivos
	close (F_CENTRALES);
}



sub makeStatQuery()
{
#inicializar hash en cero
#getFilesFromDirectory();
#Recorrer todos los archivos, si cumple la condicion del FILTRO, actualizo el hash.

	#recorrer el archivo de llamadas sospechosas
		#actualizar hash de centrales 


#Ordenar el hash de mayor a menor dependiendo el tipo de ranking

#mostrar la central dependiendo tipo de ranking con su código y la desc
#Listar el restante ranking de centrales 
#ifNeeded saveStatsResult();

}

# graba el resultado en un archivo. Incluye validación del destino a guardar
sub saveStatsResult()
{
#DO
	# Solicitar nombre donde se va a guardar el archivo
# hasta validar que no exista un nombre con ese archivo
# guardar

}

sub showStatsResult()
{

}

#Muestra la ayuda del comando
sub showHelpMenu()
{
# Imprime informacion de uso de la herramienta
# Usage:	listarT.pl -<c|e|h|s|k|p|t>
#	
	print "\n\tPrograma: AFLIST.pl - GNU GPLv3
	Descripcion: Genera un reporte de llamadas sospechosas ó estadísticas sobre el maestro de llamadas sospechosas.
				 
	USAGE: AFLIST.pl -<h|w|r|s|i|oficina|aniomes> 
	-----------------------------------------------------------------------\n
	-h : Imprime esta ayuda
	-w : Graba la consulta en un archivo
	-r: Realiza consulta sobre llamadas sospechosas aplicando filtros
	-s: Emite una estadística en base a las llamadas sospechosas y filtros 
	aplicados por el usuario
	-i: Archivo de input para realizar la consulta
	--oficina: filtro de input por oficina para realizar 
	la consulta (en caso de no usar archivo de input)
	--aniomes: filtro de input por aniomes para realizar 
	la consulta (en caso de no usar archivo de input)	
	\n
	-----------------------------------------------------------------------\n
	Ejemplo:
		AFLIST.pl -w -r -i PROCDIR/BEL_20150703
		AFLIST.pl -w -r -fo BEL -fa 201507
		AFLIST.pl -w -s -fa 2015_06
	\n";
	exit 0;

}


#main();
parseConfig();
parseArguments();





