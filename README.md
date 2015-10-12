Instrucciones para arrancar el SO desde puerto USB y loguearse con usuario de ubuntu por defecto.

1) Conectar el pendrive a un puerto trasero de la máquina.

2) Encender la máquina abriendo las opciones de booteo en caso de que automaticamente no bootee desde el USB (F1 / F2 / F8)

3) Esperar que inicie la instalacion de Ubuntu y seleccionar idioma español

4) Hacer click en la opcion de Probar Sistema Operativo

5) Ahora se encuentra el sistema iniciado y logueado con el usuario de ubuntu por defecto.

------------------------------------------------------------------------

Sistema AFRA-J

Para instalar el sistema:
	
	1. Iniciar terminal.
	
	2. Copiar el archivo GRUPO12.tgz a la carpeta en la que quiere realizar la instalación:
		$ cp [ruta_paquete]/GRUPO12.tgz [ruta_instalacion]

	3. ir a la carpeta de instalación y extraer el contenido del paquete de instalación:
		$ cd [ruta_instalacion]
		$ tar -xvf GRUPO12.tgz

	4. asignar permisos de ejecución al instalador AFINSTAL.sh:
		$ cd GRUPO12
		$ chmod u+rx AFINSTAL.sh

	5. Ejecutar el instalador:
		$ ./AFINSTAL.sh

	6. Continuar con las indicaciones del instalador
	
	7. Instalacion exitosa, se crean los directorios configurados dentro de la carpeta GRUPO12/
	
	8. Para obtener mas información acerca de los pasos realizados durante la instalacion revisar archivo log que se encuentra en /conf/GraLog.log
	
 

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
