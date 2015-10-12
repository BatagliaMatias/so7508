Sistema AFRA-J

Para instalar el sistema:
	
	1. Iniciar terminal.
	
	2. Copiar el archivo GRUPO12.tgz a la carpeta en la que quiere realizar la instalación:
		$ cp [ruta_paquete]/GRUPO12.tgz [ruta_instalacion]

	3. Vaya a la carpeta de instalación y extraiga el contenido del paquete de instalación:
		$ cd [ruta_instalacion]
		$ tar -xvf GRUPO12.tgz

	4. asignar permisos de ejecución al instalador AFINSTAL.sh:
		$ cd GRUPO12
		$ chmod u+rx AFINSTAL.sh

	5. Ejecute el instalador:
		$ ./AFINSTAL.sh

	6. Continuar con las indicaciones del instalador

Para inicializar las variables:

. arrancar AFINI.sh

Para ejecutar el comando AFREC:

. arrancar.sh AFREC.sh

Para ejercutar el comando AFLIST:

. arrancar.sh AFLIS.pl


PARA detener algun comando:

./detener.sh comando.sh


A REALIZAR:

-Al loguear guarda los logs en el /conf y no en /log
-y cuando le pedis que lo haga como err o warning lo hace como info
-Que el primer comando sea en mayuscula
