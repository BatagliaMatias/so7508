#!/usr/bin/perl 
use Getopt::Long;
use Scalar::Util qw(looks_like_number);


#Hashes
%centralesHash;
%agentesHash;
%oficinasHash;
%umbralesHash;
%destinosHash;
@arrayResultQuery=();
$lastId =0;

# Variables de argumentos.
$help = 0;
$stats=0;
$query = 0;
$fileIn = '';
@oficinas =(); #Guarda el filtro de oficinas
@aniomes =(); #Guarda el filtro de aniomes


# Flags de filtros
$statTypeRanking=0; #1:Tiempo de llamadas 2:Cantidad de llamadas 3:Ambas anteriores
$statFilterType=0;
$writeToFileFlag=0;
$rangeOfaniomes=();
$matchStrFlag=0;
$registrosResultantes=0;

$printFlag=0;


$querySelectionChoice = "*";
$filtroCentralesSelection = "*";
$filtroAgentesSelection = "*";
$filtroUmbralSelection = "*";
$filtroTipoLlamadaSelection = "*";
$filtroTiempoConversacionMinSelection = "0";
$filtroTiempoConversacionMaxSelection = "99999";
$filtroNumOrigenSelection = "*";
$filtroNumDestinoSelection = "*";

$archivoDeConsultasPreviasSelection= "*";



# Seteo las variables en base a la informacion que brinda el entorno
sub parseConfig{
	
	#$maeDir = "/home/npersia/Escritorio/TP/MAE";
	#$procDir= "/home/npersia/Escritorio/TP/PROCDIR";
	#$repoDir= "/home/npersia/Escritorio/TP/REPODIR";
	$maeDir = $ENV{"MAEDIR"};#"/home/npersia/Escritorio/TP/MAE";
	$procDir= $ENV{"PROCDIR"};#"/home/npersia/Escritorio/TP/PROCDIR";
	$repoDir= $ENV{"REPODIR"};#"/home/npersia/Escritorio/TP/REPODIR";
	$centrales = $maeDir."/centrales.csv";
	$agentes = $maeDir. "/agentes.mae";
	$umbrales = $maeDir. "/umbrales.tab";
	$codAreas = $maeDir. "/CdA.mae";
	$codPaises = $maeDir. "/CdP.mae";
}


#Parsea los argumentos ingresados por el usuario
sub parseArguments()
{
	@myArgs = @ARGV;
	GetOptions('help|h' => \$help, 
				"fileIn|i" => \$fileIn,
				"writeToFile|w" => \$writeToFileFlag,
				"query|r" => \$query,
				'statistic|s' => \$stats,
				);
	if( $help == 1 ) 
	{
		# Si encuentra -h imprime ayuda y sale
		showHelpMenu();
		exit 1;
	}

	if( $query ==1)
	{
		mainQuery();
	}

	if( $stats == 1 ) 
	{
		mainStat();
	}




}

####################################################################################################################
#######################################   CONSULTAS  ###############################################################
####################################################################################################################



#Main del proceso de egneración de una consulta
#Pre:
#Pos:
sub mainQuery()
{
	showQueryMenu();
	processQueryMenuSelection();	
	blankAllQuerySelection();
	showQuerySelection();
}

#Menu para mostrar las opciones de la Consulta
#Pos: La variable queryChoice es seteada con un valor
sub showQueryMenu()
{
print "\n\tINGRESE EL TIPO DE ARCHIVO DE ENTRADA
	-----------------------------------------------------------------------
	1) Archivos de Llamadas Sospechosas
	2) Archivos de Consultas Previas
	3) Salir
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$queryChoice = <>;
}


#Se procesa la selección de la variable queryChoice
#Pos 1: Si queryChoice = 1, se va a hacer uso de los archivos de llamadas sospechosas.
#Pos 2: Si queryChoice = 2, se va hacer uso de los archivos que el usuario indique.
#Pos 3: Si queryChoice = 3, sale del programa.
#Pos 4: Si queryChoice es distinto 1,2 o 3, retorna al proceso principal de la consulta: mainQuery
sub processQueryMenuSelection()
{

	if($queryChoice <1 or $queryChoice >3)
	{
		showErrorSelection();
		mainQuery();
	}

	#Llamadas sospechosas (Oficinas y Aniomes)
	if ($queryChoice == 1)
	{
		showQueryOficinaFilter();
		showQueryAnioMesFilter();
		@workFilesQuery=();

		#Valido las oficinas
		@oficinafechaAValidar=();
		@oficinafechavalidadas=();
		opendir(DIR,$procDir);

		#Si se solicitaron todas las oficinas, se cargan en un vector todos los archivos 
		# de llamadas sospechosas.
		if($oficinasValidadas[0] eq "*")
		{
			my @filesOFTP = readdir(DIR);
			closedir(DIR);

			foreach (@filesOFTP)
			{
				my $aFile = $_;

				if(fileSospechosasValid($aFile))
				{
					push @oficinafechaAValidar,$aFile;
				}
			}
		}
		#Se valida que las oficinas existan en la carpeta de archivos de llamadas sospechosas y se los carga en un vector.
		else
		{
			my @filesOFTP = readdir(DIR);
			closedir(DIR);
			foreach (@filesOFTP)
			{
				my $aFile = $_;
				my $matched = 0;
				$t =0;

				while (($matched == 0) and ($t < scalar(@oficinasValidadas)))
				{
					
					my $anOficina = substr $oficinasValidadas[$t], 0,3;
					my $aFileOficina = substr $aFile,0,3;								

					if( $aFileOficina eq $anOficina and fileSospechosasValid($aFile))
					{
						push @oficinafechaAValidar, $aFile;
						$matched =1;
					}
					else
					{
						
						$t++;;
		
					}
				}
			}
		}
		if(scalar(@oficinafechaAValidar) == 0)
		{
			showErrorBadFiles();
			mainQuery();
		}

		if($aniomesesValidados[0] eq '*')
		{
			@workFilesQuery = @oficinafechaAValidar;

		}
		else
		{
			foreach(@oficinafechaAValidar)
			{
				my $anOficinafechaAValidar = $_;
				my $matchedd = 0;
				my $j =0;
				while ($matchedd == 0 and $j < scalar(@aniomesesValidados))
				{
					my $anAniomes = substr $aniomesesValidados[$j], 0,6;
					my $anOficinafechaAValidarFecha = substr $anOficinafechaAValidar,4,6;

					if( $anOficinafechaAValidarFecha eq $anAniomes)
					{
						push @workFilesQuery, $aFile;
						$matchedd =1;
					}
					else
					{
						$j++;
					}
				}

			}
			if(scalar(@workFilesQuery) == 0)
			{
				showErrorBadFiles();
				mainQuery();
			}
		
		}

	}
	elsif ($queryChoice == 2)
	{
		showArchivosDeConsultasPrevias();	
	}
	else
	{
		exit 0;
	}

}

sub showQueryOficinaFilter()
{
print "\n\tINGRESE LAS OFICINAS A FILTRAR SEPARADAS POR ESPACIOS
	(PARA FILTRAR POR TODAS, INGRESE *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($oficinaFilterSelection = <>);

	@oficinas = split(' ',$oficinaFilterSelection);
	@oficinasValidadas=();
	foreach my $anOficina (@oficinas)
	{
		
		if ((length($anOficina) == 3 and $anOficina =~ /[a-zA-Z0-9]/) or ($anOficina eq "*"))
		{
			push @oficinasValidadas, $anOficina;	
		}

	}
	if(scalar(@oficinasValidadas) == 0)
	{
		showErrorBadFiles();
		mainQuery();
	}
}

sub showQueryAnioMesFilter()
{
print "\n\tINGRESE LAS FECHAS A FILTRAR SEPARADAS POR ESPACIOS (CON FORMATO AAAAMM)
	(PARA FILTRAR POR TODAS, INGRESE *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($anioMesFilterSelection = <>);

	@aniomeses = split(' ',$anioMesFilterSelection);
	@aniomesesValidados=();
	foreach my $anAniomes (@aniomeses)
	{
		if (validateDateFormatAnioMesDia($anAniomes) or ($anAniomes eq "*"))
		{
			push @aniomesesValidados, $anAniomes;	
		}
	}
	if(scalar(@aniomesesValidados) == 0)
	{
		showErrorBadFiles();
		mainQuery();
	}			
}


sub showArchivosDeConsultasPrevias()
{
print "\n\tINGRESE LOS NOMBRES DE ARCHIVO DE CONSULTAS PREVIAS SEPARADOS 
	POR ESPACIOS (PARA FILTRAR POR TODOS, INGRESE *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($archivoDeConsultasPreviasSelection = <>);

	@workFilesQuery=();
	@archivos = split(' ',$archivoDeConsultasPreviasSelection);

					
	if ($archivoDeConsultasPreviasSelection eq "*")
	{
		opendir(DIR,$repoDir);
		my @filesOFTP = readdir(DIR);
		closedir(DIR);

		foreach(@filesOFTP)
		{
			my $aRepoFile = $_;
			if(fileConsultaPreviaValid($aRepoFile))
			{
				push @workFilesQuery, $aRepoFile;		
			}
		}
	}
	else
	{
		foreach (@archivos)
		{
			my $fileUser= $_;
			opendir(DIR,$repoDir);
			my @filesOFTP = readdir(DIR);
			closedir(DIR);

			foreach(@filesOFTP)
			{
				my $aRepoFile = $_;
				if($aRepoFile eq $fileUser and fileConsultaPreviaValid($aRepoFile))
				{
					push @workFilesQuery, $aRepoFile;		
				}
			}
		}
	}

	if(scalar(@workFilesQuery) == 0)
	{
		showErrorBadFiles();
		mainQuery();
		
	}

}



sub blankAllQuerySelection()
{
	$querySelectionChoice = "*";
	$filtroCentralesSelection = "*";
	$filtroAgentesSelection = "*";
	$filtroUmbralSelection = "*";
	$filtroTipoLlamadaSelection = "*";
	$filtroTiempoConversacionMinSelection = "0";
	$filtroTiempoConversacionMaxSelection = "99999";
	$filtroNumOrigenSelection = "*";
	$filtroNumDestinoSelection = "*";
}

sub showQuerySelection()
{
print "\n\tSELECCION DE CONSULTA
	-----------------------------------------------------------------------
	1) Filtro por Central
	2) Filtro por Agente
	3) Filtro por Umbral
	4) Filtro por Tipo de Llamada
	5) Filtro por Tiempo de Conversación
	6) Filtro por Número de Origen
	7) Filtro por Número de Destino
	8) Realizar Consulta
	9) Salir
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$querySelectionChoice = <>;

	if ($querySelectionChoice == 1)
	{
		showCentralFilterMenu();
	}
	elsif($querySelectionChoice == 2)
	{
	showAgenteFilterMenu();
	}	
	elsif($querySelectionChoice == 3)
	{
	showUmbralFilterMenu();
	}
	elsif($querySelectionChoice == 4)
	{
	showTipoLlamadaFilterMenu();
	}
	elsif($querySelectionChoice == 5)
	{
	showTiempoConvMinFilterMenu();
	}
	elsif($querySelectionChoice == 6)
	{
	showNumeroOrigenFilterMenu();
	}
	elsif($querySelectionChoice == 7)
	{
	showNumeroDestinoFilterMenu();
	}
	elsif($querySelectionChoice == 8)
	{
		getQuery();
		showQueryResult();
		mainQuery();
	}
	else
	{
		exit 0;
	}		

	showQuerySelection();

}


sub showCentralFilterMenu()
{
print "\n\tINGRESE LOS NOMBRES DE LAS CENTRALES SEPARADOS POR ESPACIOS
	(PARA FILTRAR POR TODAS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroCentralesSelection = <>);

	my @centralesSel = split(' ',$filtroCentralesSelection);
	@centralesValidados=();
	foreach my $aCentral (@centralesSel)
	{
		if ((length($aCentral) == 3 and $aCentral =~ /[a-zA-Z0-9]/) or ($aCentral eq "*"))
		{

				push @centralesValidados, $aCentral;	
		}
	
	}

	if(scalar(@centralesValidados) == 0)
	{
		showErrorSelection();
		$filtroCentralesSelection = "*";
	}

}

sub validarCentralFilter
{
	my ($aCentral) = @_;
	if($filtroCentralesSelection eq '*')
	{
		return 1;
	}
	else
	{
		$encontroMatch = 0;
		$i=0;
		while( $encontroMatch ==0 && $i < scalar(@centralesValidados))
		{
			if($aCentral eq $centralesValidados[$i])
			{
				return 1;
			}
			else
			{
				$i++;
			}
		}
		return 0;
	}
}

sub showAgenteFilterMenu()
{
print "\n\tINGRESE LOS NOMBRES DE LOS AGENTES SEPARADOS POR ESPACIOS
	(PARA FILTRAR POR TODOS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroAgentesSelection = <>);


	my @agentesSel = split(' ',$filtroAgentesSelection);
	@agentesValidados=();
	foreach my $anAgente (@agentesSel)
	{
		if ($anAgente =~ /[a-zA-Z0-9]/ or $anAgente == "*")
			{
				push @agentesValidados, $anAgente;	
			}
		
	}

	if(scalar(@agentesValidados) == 0)
	{
		showErrorSelection();
		$filtroAgentesSelection = "*";
	}

}


sub validarAgenteFilter
{
	my ($aCentral) = @_;
	if($filtroAgentesSelection eq '*')
	{
		return 1;
	}
	else
	{
		$encontroMatch = 0;
		$i=0;
		while( $encontroMatch ==0 && $i < scalar(@agentesValidados))
		{
			if($aCentral eq $agentesValidados[$i])
			{
				return 1;
			}
			else
			{
				$i++;
			}
		}
		return 0;
	}
}


sub showUmbralFilterMenu()
{
print "\n\tINGRESE LOS UMBRALES SEPARADOS POR ESPACIOS (PARA FILTRAR POR TODOS, 
	INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroUmbralSelection = <>);


	my @umbraSel = split(' ',$filtroUmbralSelection);
	@umbralesValidados=();
	foreach my $unUmbral (@umbraSel)
	{
		if ($unUmbral =~ /[a-zA-Z0-9]/ or $unUmbral == "*")
		{

				push @umbralesValidados, $unUmbral;	
	
		}

	}

	if(scalar(@umbralesValidados) == 0)
	{
		showErrorSelection();
		$filtroUmbralSelection = "*";
	}

}


sub validarUmbralFilter
{
	my ($aCentral) = @_;
	if($filtroUmbralSelection eq '*')
	{
		return 1;
	}
	else
	{
		$encontroMatch = 0;
		$i=0;
		while( $encontroMatch ==0 && $i < scalar(@umbralesValidados))
		{
			if($aCentral eq $umbralesValidados[$i])
			{
				return 1;
			}
			else
			{
				$i++;
			}
		}
		return 0;
	}
}



sub showTipoLlamadaFilterMenu()
{
print "\n\tINGRESE LOS TIPOS DE LLAMADAS SEPARADOS POR ESPACIOS
	(PARA FILTRAR POR TODOS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroTipoLlamadaSelection = <>);

	my @tiposSel = split(' ',$filtroTipoLlamadaSelection);
	@tiposValidados=();
	foreach my $unTipo (@tiposSel)
	{
		if ($unTipo eq "DDI" or $unTipo eq "DDN" or $unTipo eq "LOC" or $unTipo eq "*") 
		{
			push @tiposValidados, $unTipo;		
		}
	}

	if(scalar(@tiposValidados) == 0)
	{
		showErrorSelection();
		$filtroTipoLlamadaSelection = "*";
	}

}


sub validarTipoLlamada
{
	my ($aTipo) = @_;
	if($filtroTipoLlamadaSelection eq '*')
	{
		return 1;
	}
	else
	{
		$encontroMatch = 0;
		$i=0;
		while( $encontroMatch ==0 && $i < scalar(@tiposValidados))
		{
			if($aTipo eq $tiposValidados[$i])
			{
				return 1;
			}
			else
			{
				$i++;
			}
		}
		return 0;
	}
}



sub showTiempoConvMinFilterMenu()
{
print "\n\tINGRESE EL TIEMPO DE CONVERSACION MINIMO (El mínimo es 0)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroTiempoConversacionMinSelection = <>);
	
	if($filtroTiempoConversacionMinSelection =~ /[0-9]/)
	{
		showTiempoConvMaxFilterMenu()
	}else
	{
		showErrorSelection();
		$filtroTiempoConversacionMinSelection = "0";
	}
	



}


sub showTiempoConvMaxFilterMenu()
{
print "\n\tINGRESE EL TIEMPO DE CONVERSACION MAXIMO
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroTiempoConversacionMaxSelection = <>);

	if($filtroTiempoConversacionMaxSelection =~ /[0-9]/)
	{

	}else
	{
		showErrorSelection();
		$filtroTiempoConversacionMinSelection = "0";
		$filtroTiempoConversacionMaxSelection = "99999";
	}

}


sub validarTiempoConv
{
	my ($aTiempoConv) = @_;
	if( $filtroTiempoConversacionMinSelection <= $aTiempoConv and $aTiempoConv <= $filtroTiempoConversacionMaxSelection )
	{
		return 1;
	}
	else
	{
		return 0;
	}


}


sub showNumeroOrigenFilterMenu()
{
print "\n\tINGRESE LOS NUMEROS DE ORIGEN SEPARADOS POR ESPACIOS
	(PARA FILTRAR POR TODOS, INGRESE *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroNumOrigenSelection = <>);


	my @numOrigenSel = split(' ',$filtroNumOrigenSelection);
	@numOrigenValidados=();
	foreach my $unNum (@numOrigenSel)
	{
		if (($unNum =~ /[0-9]/ and validarNumeroA($unNum) == 1) or ($unNum eq "*") )
		{
			push @numOrigenValidados, $unNum;		
		}
	}

	if(scalar(@numOrigenValidados) == 0)
	{
		showErrorSelection();
		$filtroNumOrigenSelection = "*";
	}
}

sub validarNumeroOrigenFilter
{
	my ($codAreaA) = @_[0];
	my ($numA) = @_[1];
	
	if($filtroNumOrigenSelection eq '*')
		{
			return 1;
		}
		else
		{
			$encontroMatch = 0;
			$i=0;
			while($i < scalar(@numOrigenValidados))
			{
				if($codAreaA.$numA eq $numOrigenValidados[$i])
				{
					return 1;
				}
				else
				{
					$i++;
				}
			}
			return 0;
		}


}

sub showNumeroDestinoFilterMenu()
{

	my ($tllamada) ="";

print "\n\tINGRESE EL CODIGO DE PAIS DEL NUMERO DE DESTINO
	(DEJAR EN BLANCO EN CASO DE SER LOCAL O DDN)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroCodPais = <>);

	if (validarPais($filtroCodPais) == 0 and $filtroCodPais ne ""  )
	{
		showErrorPais();
		return;
	}

	if($filtroCodPais eq ""  )
	{
print "\n\tINGRESE EL CODIGO DE AREA DEL NUMERO DE DESTINO
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroCodArea = <>);

	if (validarArea($filtroCodArea) == 0) 
	{
		showErrorArea();
		return;
	}
	$tLlamada="";
	}
	else
	{
		$tLlamada="DDI";
	}

print "\n\tINGRESE EL NUMERO DE LINEA DEL DESTINO
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroNumB = <>);


	if(validarNumeroB($tLlamada,$filtroCodPais,$filtroCodArea,$filtroNumB) == 0)
	{
		showErrorSelection();
		return;
	}
	else
	{
		$filtroNumDestinoSelection = $filtroCodPais.$filtroCodArea.$filtroNumB;
	}


}

sub validarNumeroDestinoFilter
{

	my ($codPais) = @_[0];
	my ($codAreaB) = @_[1];
	my ($numB) = @_[2];
	
	if(($filtroNumDestinoSelection eq '*') or ($filtroNumDestinoSelection eq $codPais.$codAreaB.$numB))
	{
		return 1;
	}
	else
	{
		return 0;
	}


}

#Realiza la consulta sobre los archivos solicitados
sub getQuery()
{
	
	@arrayResultQuery =();
	foreach(@workFilesQuery)
	{
		if(queryChoice==1)
		{
			$workFilePath = $procDir."/".$_;
		}
		else
		{
			$workFilePath = $repoDir."/".$_;
		}
	
		# Abro los archivos
		open F_WORKFILEPATH, "<", "$workFilePath" or die "ERROR. EL ARCHIVO $workFilePath FUE ELIMINADO EN TIEMPO DE EJECUCION Y NO PUEDE SER ABIERTO";


		#Recorro secuencialmente los archivos
		while(my $line = <F_WORKFILEPATH>)
		{
			chomp;
			($idCentral, $idAgente, $idUmbral, $tipoLlamada,$inicioLlamada,$tiempoLlamada,$codAreaA,$numA,$codPaisB,$codAreaB,$numB,$fechaArch) = split(";", $line);
			#print "A Validar $idUmbral: ",validarUmbralFilter($idUmbral), " tipo:  $tipoLlamada ",validarTipoLlamada($tipoLlamada), " tiempo $tiempoLlamada ",validarTiempoConv($tiempoLlamada)," numA: $codAreaA $numA ",validarNumeroOrigenFilter($codAreaA,$numA), " numbB: $codPaisB $codAreaB $numB ",validarNumeroDestinoFilter($codPaisB,$codAreaB,$numB),"\n";


			if( validarCentralFilter($idCentral) ==1 and validarAgenteFilter($idAgente) and validarUmbralFilter($idUmbral) and validarTipoLlamada($tipoLlamada) and validarTiempoConv($tiempoLlamada) and validarNumeroOrigenFilter($codAreaA,$numA) and validarNumeroDestinoFilter($codPaisB,$codAreaB,$numB))
			{
				push @arrayResultQuery,$line;
			}

			
		}
		close (F_WORKFILEPATH);
			
	}
}

#Devuelve el numero siguiente al número mayor del nombre de los archivos de subllamadas creados.
sub getNextSubllamadaID()
{
	$lastId =0;
	my $cantArchivos=0;
	my @workFilesLlamadas=();
	opendir(DIR,$repoDir);
	my @filesOFTP = readdir(DIR);
	closedir(DIR);
	foreach(@filesOFTP)
	{
		my $aFile = $_;
		if(length($aFile) == 14)
		{
			$nombreLlamada = substr $file, 0, 10;
			$nombrePunto = substr $file, 10,1;
			if( $nombrellamada == "subllamadas" and nombrePunto == ".")
			{
				push @workFilesLlamadas, $aFile;
				$cantArchivos=$cantArchivos+1;		
			}
		}
	}
	if ( $cantArchivos >0)
	{
		if( $cantArchivos -10 >= 0)
		{
			$lastId = "0".($cantArchivos);
		}
		elsif( $cantArchivos -100 >= 0)
		{
			$lastId = $cantArchivos;
		}
		else
		{
			$lastId = "00".($cantArchivos);
		}
	}
	else
	{
		$lastId = "000";
	}
	return $lastId;
}

#Muestra por pantalla el nombre del archivo y la cantidad de registros resultantes
sub showQueryResult()
{
	my @sortedResult = sort @arrayResultQuery;

	if( $writeToFileFlag == 1)
	{
		my $filename = $repoDir."/subllamada.".getNextSubllamadaID();
		open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
		print $fh @sortedResult;
		close $fh;
print "\n\tSE GENERO EL ARCHIVO $filename
	-----------------------------------------------------------------------\n";		
		
	}
	else
	{
		print "@sortedResult\n";
	}
}


####################################################################################################################
###################################### Validaciones de campos  #####################################################

#Valida que exista el codigo de area en el archivo de codigo de áreas
sub validarArea
{
	my ($anArea) = @_;
	my $matched = 0;

# Abro los archivos de Destinos
	open F_AREAS, "<", "$codAreas" or die "No se pudo abrir el archivo de $codAreas";


	#Recorro secuencialmente los archivos
	while(my $row = <F_AREAS> and $matched == 0)
	{
		chomp($row);
		($descArea, $codArea) = split(";",$row);
	
		if($codArea eq $anArea)
		{
			$matched =1;
		}
	}
	close (F_AREAS);

	if ($matched == 1)
	{
		return 1;
	}
	else
	{
		return 0;
	}

}

#Valida que exista el código de área en el archivo de códigos de País
sub validarPais
{
	my ($aPais) = @_;
	my $matched = 0;
	open F_PAISES, "<", "$codPaises" or die "No se pudo abrir el archivo de $codPaises";

	while(my $row = <F_PAISES> and $matched == 0)
	{
		chomp($row);
		($codPais, $descPais) = split(";",$row);
		if($codPais eq $aPais)
		{
			$matched =1;
		}
	}
	close (F_PAISES);

	if ($matched == 1)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

#Valida si es un número valido, validando que sea un numero de 10 dígitos y validando que los 
# primeros 2, 3 o 4 dígitos sean un número de área
sub validarNumeroA
{
	my ($aNumb) = @_;

	if(looks_like_number($aNumb) and length($aNumb) == 10)
	{
		$codArea2 = substr	$aNumb,0,2;
		$codArea3 = substr	$aNumb,0,3;
		$codArea4 = substr	$aNumb,0,4;
		if( validarArea($codArea2) == 1 or validarArea($codArea3) == 1 or validarArea($codArea4) == 1)
		{
			return 1;
		}
	}
	return 0;
}

#Valida si es un número valido, y validando que los 
#Pre: Se debe haber validado el tipo de codigo, codigo de pais y el codigo de area.
#Parametros: 
# 1) Tipo de Codigo
# 2) Codigo de Pais
# 3) Codigo de Area
# 4) Numero de Linea B
#Pos: Devuelve 1 si se cumple que:
# contenga un numero
# Si la llamada es DDI, no importa su longitud 
# Si la llamada es LOC o DDN, la suma de digitos código de 
# area+numero de línea debe ser de 10.
sub validarNumeroB
{
	my ($tllamada) = @_[0];
	my ($codPais) = @_[1];
	my ($codArea) = @_[2];
	my ($aNumb) = @_[3];

	if(looks_like_number($aNumb))
	{
		if( $tllamada eq "DDI")
		{
			return 1;
		}
		elsif (length($codArea.$aNumb) == 10 )
		{
			return 1;
		}
	}
	return 0;
}



####################################################################################################################
####################################### ESTADISTICAS ###############################################################
####################################################################################################################



sub mainStat()
{
		@aniomes= split(/,/,join(',',@aniomes));
		loadHashes();
		showFilterType();
		while($statFilterType <1 or $statFilterType >3)
		{
			showErrorSelection();
			showFilterType();
		}
		processFilterTypeSelection();
		makeStatQuery();

		showStatsMenu();
		while($statChoice != 6)
		{

			if($statChoice >=1 or $statChoice <=5)
			{

				if($statChoice >=1 and $statChoice <= 3)
				{
					showRankingType();
					while($statTypeRanking <1 or $statTypeRanking >3)
					{
						showErrorSelection();
						showRankingType();
					}

				}
				showStatsResult();				
			}				
			else
			{
				showErrorSeleccion();
			}
			showStatsMenu();
		}

		exit 1;
}

#Menu para mostrar las opciones de tipo de ranking
sub showFilterType()
{
print "\n\tTIPO DE FILTRO
	-----------------------------------------------------------------------
	1) Un período
	2) Un rango de períodos
	3) Todos los períodos
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$statFilterType = <>;
}

sub processFilterTypeSelection()
{
	if($statFilterType==1)
	{
		my $dateValid=0;
		while($dateValid == 0)
		{
			print "\tPeríodo (aaaamm): ";
			chomp($rangeOfaniomes[0] = <>);
			$dateValid = validateDateFormat($rangeOfaniomes[0]);
			if($dateValid == 0)
			{
				showErrorFormatDate();
			}
		}
	}
	elsif($statFilterType==2)
	{
		my $dateValid=0;
		while($dateValid==0)
		{
			while($dateValid==0)
			{
				print "\tPeríodo mínimo (aaaamm): ";
				chomp($rangeOfaniomes[0] = <>);
				$dateValid= validateDateFormat($rangeOfaniomes[0]);
				if($dateValid == 0)
				{
					showErrorFormatDate();
				}
			}
			$dateValid = 0;
			while($dateValid==0)
			{
				print "\tPeríodo de máximo (aaaamm): ";
				chomp($rangeOfaniomes[1] = <>);
				$dateValid= validateDateFormat($rangeOfaniomes[1]);
				if($dateValid == 0)
				{
					showErrorFormatDate();
					if($rangeOfaniomes[0] >$rangeOfaniomes[1])
					{
						showErrorFormatSecondDate();
					}
				}
			}
		}

	}
	elsif($statFilterType == 3)
	{
		$rangeOfaniomes[0]="*";
	}else
	{
		$statFilterType=0;
	}
}





# Cargo los hashes de Centrales, oficinas, agentes,umbrales y destinos
sub loadHashes()
{
	loadHashCentrales();
	loadHashAgentesOficinas();
	loadHashUmbrales();
	loadHashDestinos();
}

sub loadHashCentrales()
{

	# Abro los archivos de Centrales
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


sub loadHashAgentesOficinas()
{

	# Abro los archivos de Agentes
	open F_AGENTES, "<", "$agentes" or die "No se pudo abrir el archivo de $agentes";


	#Recorro secuencialmente los archivos
	while(<F_AGENTES>)
	{
		chomp;
		($agApellido, $agNombre, $agID,$agOficina, $agMail) = split(";");
		$agentesHash{$agID}=[$agMail,$agOficina,0,0];
		$oficinasHash{$agOficina}=[0,0];
	}
	#Cierro el archivo
	close (F_AGENTES);


}


sub loadHashUmbrales()
{
	# Abro los archivos de Umbrales
	open F_UMBRALES, "<", "$umbrales" or die "No se pudo abrir el archivo de $umbrales";


	#Recorro secuencialmente los archivos
	while(<F_UMBRALES>)
	{
		chomp;
		($idUmbral, $codAreaOrigen, $numOrigen, $tipoLlamada,$codAreaDestino,$tope,$estado) = split(";");
		$umbralesHash{$idUmbral}=[0];
	}
	
	close (F_UMBRALES);
}


sub loadHashDestinos()
{
	# Abro los archivos de Destinos
	open F_AREAS, "<", "$codAreas" or die "No se pudo abrir el archivo de $codAreas";
	open F_PAISES, "<", "$codPaises" or die "No se pudo abrir el archivo de $codPaises";


	#Recorro secuencialmente los archivos
	while(<F_AREAS>)
	{
		chomp;
		($descArea, $codArea) = split(";");
		$destinosHash{$codArea."A"}=[$descArea,0];
	}
	close (F_AREAS);



	while(<F_PAISES>)
	{
		chomp;
		($codPais, $descPais) = split(";");
		$destinosHash{$codPais."P"}=[$descPais,0];
	}
	close (F_PAISES);



}

sub makeStatQuery()
{
	opendir(DIR,$procDir);
	my @filesOFTP = readdir(DIR);
	my @workFiles=();
	closedir(DIR);
	foreach(@filesOFTP)
	{
		my $aFile = $_;
		if(fileSospechosasValid($aFile) and fileMatchAnioMesFilter($aFile))
		{
			push @workFiles, $aFile;
		}
	}

	foreach(@workFiles)
	{
		my $aFile = $_;
		my $idOficina = substr $aFile, 0, 3;
		$workFilePath = $procDir."/".$aFile;
		open F_WORKFILEPATH, "<", "$workFilePath" or die "No se pudo abrir el archivo de $workFilePath";


		#Recorro secuencialmente los archivos
		while(<F_WORKFILEPATH>)
		{
			chomp;
			($idCentral, $idAgente, $idUmbral, $tipoLlamada,$inicioLlamada,$tiempoLlamada,$codAreaA,$numA,$codPaisB,$codAreaB,$numB,$fechaArch) = split(";");
			
			$centralesHash{$idCentral}[1]=$centralesHash{$idCentral}[1]+$tiempoLlamada;
			$centralesHash{$idCentral}[2]++;


			$agentesHash{$idAgente}[2]=$agentesHash{$idAgente}[2]+$tiempoLlamada;
			$agentesHash{$idAgente}[3]++;

			$oficinasHash{$idOficina}[0]=$oficinasHash{$idOficina}[0]+$tiempoLlamada;
			$oficinasHash{$idOficina}[1]++;

			if($tipoLlamada eq "DDI")
			{
				$destinosHash{$codPaisB."P"}[1]++;
			}
			else
			{
				$destinosHash{$codAreaB."A"}[1]++;
			}

			$umbralesHash{$idUmbral}[0]++;
		}


		close (F_WORKFILEPATH);
	}


}

# graba el resultado en un archivo. Incluye validación del destino a guardar
sub saveStatsResult()
{

print "\n\tINGRESE EL NOMBRE DEL ARCHIVO PARA GUARDAR LA ESTADISTICA
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$nombreArchivoStat = <>;
	
	if (-e $repoDir."/".$nombreArchivoStat)
	{ 
print "\n\tYA EXISTE OTRO ARCHIVO CON EL MISMO NOMBRE $nombreArchivoStat
	-----------------------------------------------------------------------\n";
	saveStatsResult();
	}

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
	$statTypeRanking = <>;
}


sub showStatsResult()
{
	if($writeToFileFlag == 1)
	{
		saveStatsResult();		
	}	

	if($statChoice == 1)
	{showCentralesResult();}
elsif($statChoice == 2){showOficinasResult();}
elsif($statChoice == 3)	{showAgentesResult();}
elsif($statChoice == 4){showDestinosResult();}
elsif($statChoice == 5){showUmbralesResult();}
	
}

sub showCentralesResult()
{
			
	if($statTypeRanking==1)
	{
		foreach my $idCentral (sort {$centralesHash{$b}[1] <=> $centralesHash{$a}[1]} keys %centralesHash) {
			my $desc= $centralesHash{$idCentral}[0];
			my $tiempo=$centralesHash{$idCentral}[1];
			if($writeToFileFlag == 1)
			{

				my $filename = $repoDir."/".$nombreArchivoStat;
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				print $fh "Id Central: " . $idCentral. ", Descripción: " . $desc.", Tiempo: " . $tiempo.  "\n";
				close $fh;
			}
			else
			{
				print "Id Central: " . $idCentral. ", Descripción: " . $desc.", Tiempo: " . $tiempo.  "\n";	
			}
		}
	}

	if($statTypeRanking==2)
	{
		foreach my $idCentral (sort {$centralesHash{$b}[2] <=> $centralesHash{$a}[2]} keys %centralesHash) {
			my $desc= $centralesHash{$idCentral}[0];
			my $cant=$centralesHash{$idCentral}[2];
			if($writeToFileFlag == 1)
			{
				my $filename = $repoDir."/".$nombreArchivoStat;
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				print $fh "Id Central: " . $idCentral. ", Descripción: " . $desc.", Cantidad: " . $cant.  "\n";
				close $fh;
			}
			else
			{
				print "Id Central: " . $idCentral. ", Descripción: " . $desc.", Cantidad: " . $cant.  "\n";	
			}
		}

	}

	if($statTypeRanking==3)
	{
		foreach my $idCentral (sort {$centralesHash{$b}[1] <=> $centralesHash{$a}[1] or $centralesHash{$b}[2] <=> $centralesHash{$a}[2]} keys %centralesHash) {
			my $desc= $centralesHash{$idCentral}[0];
			my $tiempo=$centralesHash{$idCentral}[1];
			my $cant=$centralesHash{$idCentral}[2];
			if($writeToFileFlag == 1)
			{
				my $filename = $repoDir."/".$nombreArchivoStat;
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				print $fh "Id Central: " . $idCentral. ", Descripción: " . $desc.", Tiempo: " . $tiempo.", Cantidad: " . $cant.  "\n";
				close $fh;
			}
			else
			{
				print "Id Central: " . $idCentral. ", Descripción: " . $desc.", Tiempo: " . $tiempo.", Cantidad: " . $cant.  "\n";	
			}
		}

	}
	if($writeToFileFlag == 1)
	{
print "\n\tSE GENERO EL ARCHIVO $nombreArchivoStat
	-----------------------------------------------------------------------\n";		
	}	
		


}



sub showOficinasResult()
{
		
	if($statTypeRanking==1)
	{
		foreach my $idOfic (sort {$oficinasHash{$b}[0] <=> $oficinasHash{$a}[0]} keys %oficinasHash) {
			my $tiempo=$oficinasHash{$idOfic}[0];
			if($writeToFileFlag == 1)
			{
				my $filename = $repoDir."/".$nombreArchivoStat;
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				print $fh "Id Oficina: " . $idOfic. ", Tiempo: " . $tiempo.  "\n";
				close $fh;
			}
			else
			{
				print "Id Oficina: " . $idOfic. ", Tiempo: " . $tiempo.  "\n";	
			}
		}
	}

	if($statTypeRanking==2)
	{
		foreach my $idOfic (sort {$oficinasHash{$b}[1] <=> $oficinasHash{$a}[1]} keys %oficinasHash) {
			my $cant=$oficinasHash{$idOfic}[1];
			if($writeToFileFlag == 1)
			{
				my $filename = $repoDir."/".$nombreArchivoStat;
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				print $fh "Id Oficina: " . $idOfic. ", Cantidad: " . $cant.  "\n";
				close $fh;
			}
			else
			{
				print "Id Oficina: " . $idOfic. ", Cantidad: " . $cant.  "\n";	
			}
		}

	}

	if($statTypeRanking==3)
	{
		foreach my $idOfic (sort {$oficinasHash{$b}[0] <=> $oficinasHash{$a}[0] or $oficinasHash{$b}[1] <=> $oficinasHash{$a}[1]} keys %oficinasHash) {
			my $tiempo=$oficinasHash{$idOfic}[0];
			my $cant=$oficinasHash{$idOfic}[1];
			if($writeToFileFlag == 1)
			{
				my $filename = $repoDir."/".$nombreArchivoStat;
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				print $fh "Id Oficina: " . $idOfic. ", Tiempo: " . $tiempo.", Cantidad: " . $cant.  "\n";
				close $fh;
			}
			else
			{
				print "Id Oficina: " . $idOfic. ", Tiempo: " . $tiempo.", Cantidad: " . $cant.  "\n";	
			}
		}

	}
	if($writeToFileFlag == 1)
	{
print "\n\tSE GENERO EL ARCHIVO $nombreArchivoStat
	-----------------------------------------------------------------------\n";		
	}	
}


sub showAgentesResult()
{
					
	if($statTypeRanking==1)
	{
		foreach my $idAgente (sort {$agentesHash{$b}[2] <=> $agentesHash{$a}[2]} keys %agentesHash) {
			my $mail= $agentesHash{$idAgente}[0];
			my $oficina= $agentesHash{$idAgente}[1];
			my $tiempo=$agentesHash{$idAgente}[2];
			if($writeToFileFlag == 1)
			{

				my $filename = $repoDir."/".$nombreArchivoStat;
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				print $fh "Id Agente: " . $idAgente. ", Mail: " . $mail.", Oficina: " . $oficina.", Tiempo: " . $tiempo.  "\n";
				close $fh;
			}
			else
			{
				print "Id Agente: " . $idAgente. ", Mail: " . $mail.", Oficina: " . $oficina.", Tiempo: " . $tiempo.  "\n";
			}
		}
	}

	if($statTypeRanking==2)
	{
		foreach my $idAgente (sort {$agentesHash{$b}[3] <=> $agentesHash{$a}[3]} keys %agentesHash) {
			my $mail= $agentesHash{$idAgente}[0];
			my $oficina= $agentesHash{$idAgente}[1];
			my $cant=$agentesHash{$idAgente}[3];
			if($writeToFileFlag == 1)
			{
				my $filename = $repoDir."/".$nombreArchivoStat;
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				print $fh "Id Agente: " . $idAgente. ", Mail: " . $mail.", Oficina: " . $oficina.", Cantidad: " . $cant.  "\n";
				close $fh;
			}
			else
			{
				print "Id Agente: " . $idAgente. ", Mail: " . $mail.", Oficina: " . $oficina.", Cantidad: " . $cant.  "\n";	
			}
		}

	}

	if($statTypeRanking==3)
	{
		foreach my $idAgente (sort {$agentesHash{$b}[2] <=> $agentesHash{$a}[2] or $agentesHash{$b}[3] <=> $agentesHash{$a}[3]} keys %agentesHash) {
			my $mail= $agentesHash{$idAgente}[0];
			my $oficina= $agentesHash{$idAgente}[1];
			my $tiempo=$agentesHash{$idAgente}[2];
			my $cant=$agentesHash{$idAgente}[3];
			if($writeToFileFlag == 1)
			{
				my $filename = $repoDir."/".$nombreArchivoStat;
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				print $fh print "Id Agente: " . $idAgente. ", Mail: ". $mail.", Oficina: ". $oficina.", Tiempo: " . $tiempo.", Cantidad: ". $cant.  "\n";
				close $fh;
			}
			else
			{
				print "Id Agente: " . $idAgente. ", Mail: " . $mail.", Oficina: " . $oficina.", Tiempo: " . $tiempo. ", Cantidad: " . $cant.  "\n";	
			}
		}

	}
	if($writeToFileFlag == 1)
	{
print "\n\tSE GENERO EL ARCHIVO $nombreArchivoStat
	-----------------------------------------------------------------------\n";		
	}	
		

}

sub showDestinosResult()
{

	foreach my $idDestino (sort {$destinosHash{$b}[1] <=> $destinosHash{$a}[1]} keys %destinosHash) {
		my $desc= $destinosHash{$idDestino}[0];
		my $tiempo=$destinosHash{$idDestino}[1];
		if($writeToFileFlag == 1)
		{
			my $filename = $repoDir."/".$nombreArchivoStat;
			open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
			(chop $idDestino) ;
			print $fh print "Id destino: " . $idDestino . ", Desc: ". $desc." Tiempo: " . $tiempo."\n";
			close $fh;
		}
		else
		{
			(chop $idDestino) ;
			print "Id destino: " . $idDestino . ", Desc: ". $desc." Tiempo: " . $tiempo."\n";	
		}
	}

}

sub showUmbralesResult()
{
	my ($cantUmbralesMayoresAUnaLlamada) = 0;
	foreach my $idUmbral (sort {$umbralesHash{$b}[0] <=> $umbralesHash{$a}[0]} keys %umbralesHash) 
	{
		my $cant=$umbralesHash{$idUmbral}[0];
		if ($cant > 1)
		{
			if($writeToFileFlag == 1)
			{
				my $filename = $repoDir."/".$nombreArchivoStat;
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				print $fh "Id Umbral: " . $idUmbral.", Cantidad: " . $cant.  "\n";
				close $fh;
			}
			else
			{
				print "Id Umbral: " . $idUmbral.", Cantidad: " . $cant.  "\n";	
			}
			$cantUmbralesMayoresAUnaLlamada++;
		}
		
	}
	if($cantUmbralesMayoresAUnaLlamada == 0) 
	{
		if($writeToFileFlag == 1)
		{
			my $filename = $repoDir."/".$nombreArchivoStat;
			open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
			print $fh "NO SE ENCONTRARON UMBRALES CON MÁS DE 1 LLAMADA";
			close $fh;
		}
		else
		{
print "\n\t-----------------------------------------------------------------------
		NO SE ENCONTRARON UMBRALES CON MÁS DE 1 LLAMADA
		-----------------------------------------------------------------------"
		}	
	}

}


sub fileConsultaPreviaValid()
{
	my ($file) = @_;

	if(length($file) != 14)
	{
		return 0;
	}

	my $subllamada = substr $file, 0, 11;
	my $idFile = substr $file, 11, 3;
	
	if( $subllamada eq "subllamada." and $idFile < getNextSubllamadaID())
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

sub fileSospechosasValid()
{
	my ($file) = @_;

	if(length($file) != 10)
	{
		return 0;
	}
	my $oficina = substr $file, 0, 3;
	my $underScore = substr $file, 3, 1;
	my $aDate= substr $file, 4,8;
	
	if( validateOficinaFormat($oficina) == 1 and $underScore eq "_" and validateDateFormatAnioMesDia($aDate) == 1)
	{
		return 1;
	}
	else
	{
		return 0;
	}


}

sub fileMatchAnioMesFilter()
{

	if($statFilterType ==3)
	{
		return 1;
	}
	else
	{
		my ($fileName) = @_;
		my $aDate= substr $fileName, 4,8;
		my $anio= substr $aDate, 0,4;
		my $mes = substr $aDate, 4,2;

		my $rangeAnio= substr $rangeOfaniomes[0], 0,4;
		my $rangeMes = substr $rangeOfaniomes[0], 4,2;

		if($statFilterType ==1)
		{	
			if ($rangeAnio eq $anio and $rangeMes eq $mes)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		else
		{
			my $rangeAnioMax= substr $rangeOfaniomes[1], 0,4;
			my $rangeMesMax = substr $rangeOfaniomes[1], 4,2;
			if ($rangeAnio <= $anio and $rangeMes <= $mes and $anio <= $rangeAnioMax and $mes <= $rangeMesMax )
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}	
	}
}





sub validateOficinaFormat()
{
	my($oficina) = @_;
	if ($oficina =~ m/[^a-zA-Z0-9]/) 
	{
		return 0;
	}
	else
	{
		while ( ($key = each %oficinasHash) and ($oficina != $key) )
		{

		}
		if($oficina !=$key)
		{
			return 0;
		}
		else
		{
			return 1;
		}
	}

}


sub validateDateFormatAnioMesDia
{
	my ($aDate) = @_;

	if(length($aDate) != 6)
	{
		return 0;
	}
	if(looks_like_number($aDate)==0)
	{
		return 0;
	}

	my $year = substr $aDate, 0, 4; 
	my $month = substr $aDate, 4, 2; 
        if ($year < 2016 and $year > 1914 and $month >= 1 and $month <= 12)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

sub validateDateFormat()
{
	my ($aDate) = @_;

	if(length($aDate) != 6)
	{
		return 0;
	}
	if(looks_like_number($aDate)==0)
	{
		return 0;
	}

	my $anio = substr $aDate, 0, 4; 
	my $mes = substr $aDate, 4, 2; 

	if($anio >2015 or $mes > 12 or $mes <1)
	{
		return 0;
	}
	
	return 1;
	
}


sub showErrorPais()
{
print "\n\t-----------------------------------------------------------------------
	SELECCION INCORRECTA - NO EXISTEN PAISES CON ESE CODIGO
	-----------------------------------------------------------------------\n";

}

sub showErrorArea()
{
print "\n\t-----------------------------------------------------------------------
	SELECCION INCORRECTA - NO EXISTEN AREAS CON ESE CODIGO
	-----------------------------------------------------------------------\n";

}


sub showErrorBadFiles()
{
print "\n\t-----------------------------------------------------------------------
	SELECCION INCORRECTA - NO EXISTEN ARCHIVOS CON ESA DESCRIPCION
	-----------------------------------------------------------------------\n";

}

sub showErrorSelection()
{
print "\n\t-----------------------------------------------------------------------
	SELECCION INCORRECTA - INTENTE NUEVAMENTE
	-----------------------------------------------------------------------\n";
}


sub showErrorFormatDate()
{
print "\n\t-----------------------------------------------------------------------
	FORMATO DE FECHA INCORRECTO - INTENTE NUEVAMENTE CON EL FORMATO (AAAAMM)
	-----------------------------------------------------------------------\n";
}

sub showErrorFormatSecondDate()
{
print "\n\t-----------------------------------------------------------------------
	EL PERIODO MAXIMO NO PUEDE SER MENOR AL PERIODO MINIMO: $rangeOfaniomes[0]
	-----------------------------------------------------------------------\n";
}



####################################################################################################################
#######################################    AYUDA     ###############################################################
####################################################################################################################
#Muestra la ayuda del comando
sub showHelpMenu()
{
# Imprime informacion de uso de la herramienta
# Usage:	listarT.pl -<c|e|h|s|k|p|t>
#	
	print "\n\tPrograma: AFLIST.pl - Grupo 12 - GNU GPLv3
	Descripcion: Genera un reporte de llamadas sospechosas ó estadísticas sobre el maestro de llamadas sospechosas.
	Con la aplicación de distintos filtros.			 
	USAGE: AFLIST.pl -<h|w|r|s> 
	-----------------------------------------------------------------------\n
	-h : Imprime esta ayuda
	-w : Graba la consulta en un archivo
	-r: Realiza consulta sobre llamadas sospechosas aplicando filtros
	-s: Emite una estadística en base a las llamadas sospechosas y filtros 
	aplicados por el usuario
	-----------------------------------------------------------------------\n
	Ejemplo:
		AFLIST.pl -w -r 
		AFLIST.pl -w -s
		AFLIST.pl -r
		AFLIST.pl -s
	\n";
	exit 0;

}


#main();
parseConfig();
parseArguments();



