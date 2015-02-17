#
# ProyectoII.asm
#
# Descripcion: Juego de Domino con interfaz
# por consola para 4 jugadores
# escrito en MIPS Assembly
#
# Nombres:
#    Alejandra Cordero / Carnet: 12-10645
#    Pablo Maldonado   / Carnet: 12-10561
#
# Ultima modificacion: 17/02/2015
#

########################################################
#                  SECCION DE DATOS                    #                      
########################################################

		.data

jugadores:			.word     0
tablero:				.word     0
arregloTablero:		.word 	0
rondas: 				.word	0
nuevoJuego:			.word     0
fichas:				.word     0
numeroFichasJugadores: 	.word 	0
tieneCochina:			.word 	0
turnoRonda:			.word	0 
turnoActual:			.word	0  
piedrasArchivo:		.space  169
nombre:				.space   20
letra:				.word     0
nombreArchivo:			.asciiz "/home/prmm95/Desktop/CI3815/Proyectos/ProyectoII/PIEDRAS"
errorLecturaA:			.asciiz "Error: Problemas con el archivo de entrada. \n"
m_finalizarEjec:		.asciiz "Finalizara la ejecucion del programa."
parentesisAbre:		.asciiz "("
parentesisCierra:		.asciiz ")"
punto:				.asciiz "."
dosPuntos:			.asciiz " :  "
saltoDeLinea:			.asciiz "\n"
mensaje: 				.asciiz "Jugador "
Introducir:			.asciiz "Introduzca su opcion de juego:  "
Invalido:				.asciiz "Opcion invalida.Introduzca su opcion de juego:  "
texto:				.asciiz " introduzca su nombre: "
mensajeParaElJugador: 	.asciiz " aqui estan sus opciones de juego :  "
JugadaInvalida:		.asciiz "La jugada es invalida. "
finJuego:				.asciiz "Fin del juego / " 
ganadores:			.asciiz "Ganadores: \n"
m_chancleta:			.asciiz "Chancleta."
m_zapatero:			.asciiz "Zapatero."
m_normal:				.asciiz "victoria normal."
Opcion:		 	 	.asciiz " Opcion "
guion:				.asciiz "- "
por:					.asciiz "por "

		.text

########################################################
#                DECLARACION DE MACROS                 #                      
########################################################

.macro imprimir_t (%texto) 
	# Descripcion: imprime un texto almacenado 
	# en una etiqueta.
	li 		$v0, 4
	la		$a0, %texto
	syscall
.end_macro

#------------------------------------------------------#
		
.macro imprimir_i (%numero) 
	# Descripcion: imprime un entero
	li		$v0, 1
	move		$a0, %numero
	syscall
.end_macro

#------------------------------------------------------#

.macro reservarEspacio(%espacio) 
	# Descripcion: Reserva el espacio de memoria 
	# indicado.
	li		$v0  9
	li		$a0  %espacio
	syscall
.end_macro 

#------------------------------------------------------#

.macro finalizarPrograma()
	# Descripcion: Finaliza la ejecucion del programa.
	li		$v0 10
	syscall
.end_macro

#------------------------------------------------------#

.macro generarSemilla()
	# Descripcion: Configura la semilla del generador 
	# de numeros aleatorios.
	li 		$v0, 40
	li 		$a0, 0
	li 		$a1, 0
	syscall		
.end_macro

########################################################
#             INICIO DEL CODIGO PRINCIPAL              #                      
########################################################

main:

		# Se configura la semilla del generador de numeros aleatorios:		
		generarSemilla()

		jal 		leerArchivoPiedras 
		# Se retorna en $v0 la direccion de los datos leidos
		move 	$a0,$v0
		jal 		extraerPiedras
		
		# Se crea la clase jugador
		jal 		CrearClaseJugador 
		sw 		$v0 jugadores
		lw 		$v0 jugadores
		
		# Es un  argumento, hay que cambiar $t7 por $a0 
		move 	$t7 $v0  # Se estaria trabajando la estructura de datos jugador como algo global (no se si eso es bueno)

		# Pedir nombre a Jugadores
		jal 		PedirYalmacenarNombreJugadores
		
		lw 		$v0 jugadores

		# Se reparten las fichas a los jugadores:
		lw 		$a0, jugadores
		lw 		$a1, fichas  		
		jal 		RepartirFichas 
		

		sw $v1,tieneCochina	
		sw $v0,numeroFichasJugadores

		# Se crea la clase tablero
		jal 		CrearClaseTablero
		sw 		$v0, tablero
		sw 		$v1, arregloTablero

		li 		$a0 1
		sw		$a0 rondas 	  # NumeroRondas = 1
		sw		$a0 nuevoJuego   # NuevoJuego = True


		# Se inicializan las variables de los turnos del juego

		lw 		$s0,tieneCochina
		sw 		$s0,turnoRonda
		sw 		$s0,turnoActual		

#########################################################
# Cuando encontremos la cochina guardar en una variable 
#  el numero del jugador que le toca sacar en la proxima 
#  ronda
#########################################################

loopPrincipal:

	
		# Se verifica si los puntos del grupo 1 son mayores o iguales que 100
		lw 		$s1 jugadores
		lw 		$s2 4($s1)
		li 		$s3 100
		bge 		$s2 $s3 RevisarPuntos
		blt 		$s2 $s3 continuar

		continuar:
			# Se verifica si los puntos del grupo 2 son mayores o iguales que 100
			lw 		$s2 16($s1)
			bge 		$s2 $s3 RevisarPuntos
			blt		$s2 $s3 VerificarRondaNueva
		
		VerificarRondaNueva:
	
			# Se verifica si nuevoJuego = True
			lw 		$s1 rondas
			lw 		$s2 nuevoJuego
			li 		$s3 1
			beq  	$s2 $s3 VerificarNumeroRondas
			bne  	$s2 $s3 continuarJuego
		
		VerificarNumeroRondas:
			# Se verifica si numeroRondas!=1
			bne 		$s1 $s3 NuevaPartida
			beq 		$s1 $s3 continuarJuego
		
		
		NuevaPartida:
	
			# Se empieza una nueva partida
	
			# mezclar(piedras)
			# repartirFichas()
			
			li $s1 0
			sw $s1 nuevoJuego  # NuevoJuego=False
			jal CrearClaseTablero
			sw $v0 tablero     # tablero almacena la cabecera del Tablero 
			jal CambiarTurno
			move $s7 $v0
		
		continuarJuego:
		
			lw $a0 turnoActual
			lw $a1 jugadores
			jal mostrarFichas
			
			#jal VerificarSiSePuedeJugar
		
			VerificacionJugada:
				move $a0 $v0 # $a0 es la direccion del arreglo de fichas del jugador
				move $a1 $v1 # $a1 es el numero de fichas que tiene el jugador actual
				
				#Prologo
				move $fp, $sp 
				addi $sp $sp -4
				sw $fp, 4($sp) 
				addi $sp, $sp, -4
				sw $ra, 4($sp)
				addi $sp $sp -4
				sw $v0, 4($sp)
				addi $sp $sp -4
				sw $v1, 4($sp) 
				
				jal RecibirOpcionJugador
			
				move $a0 $v0 # $a0 es el argumento de entrada de la funcion (direccion de la ficha seleccionada por el jugador)
				lw $a1 tablero # Direccion del tablero
				lw $a2 rondas # Numero de rondas
				
				addi $sp $sp -4
				sw $v0, 4($sp)

				jal VerificarJugada
				
				move $s1 $v0 # Registro de salida de la funcion
					
				 #Epilogo	

				lw $a1 4($sp) # Direccion de la ficha seleccionada
				addi	$sp $sp 4
				lw $v1 4($sp)
				addi $sp, $sp, 4
				lw $v0 4($sp)
				addi $sp, $sp, 4
				lw $ra, 4($sp)
				addi $sp, $sp, 4
				lw $fp, 4($sp)
				addi $sp, $sp, 4
				
				lw $s2 ($s1)
				
				beqz $s2 VerificacionJugada # $s2 es 1 si la jugada es valida y 0 si no lo es
			

			lw $a0, tablero 
			lw $a2, 4($s1)
			lw $a3, 8($s1)
			
			# Empilamos:
			addi $sp $sp -4
			sw $a1, 4($sp) # Direccion de la ficha seleccionada
			addi $sp $sp -4
			sw $v0, 4($sp) # Direccion del arrecho de fichas del jugador actual

			jal actualizarTablero	

			lw $a0, tablero		
			jal imprimirTablero
			
			# Desempilamos:
			lw $a0 4($sp)  # Direccion del arrecho de fichas del jugador actual
			addi $sp, $sp, 4
			lw $a1 4($sp)  # Direccion de la ficha seleccionada
			addi $sp, $sp, 4
			
			lw $a2 numeroFichasJugadores
			lw $a3 turnoActual
			
			jal RestarFichaJugador
			move $s1 $v0	# $v0 tiene el numero de fichas del jugador actual
			
			bnez $s1 Cambio
			#beqz $s1 FinDeLaPartida
			
			Cambio:
				lw $a0 turnoActual
				jal CambiarTurno
				sw $v0 turnoActual
				b loopPrincipal

			#FinDeLaPartida:
				# En $a0 recibe el turno actual
				#jal SumarPuntos
				#b loopPrincipal
				
				# NOTA: SE TIENE QUE CREAR UNA FUNCION LLAMADA SumaFichas
			
				#jal RevisarPuntos
				
		li 		$a0,1
		li 		$a1,1
		lw		$a2,jugadores
		jal		imprimirMensajeGanador	
		li 		$v0, 10
				syscall	

########################################################
#               DECLARACION DE FUNCIONES               #                      
########################################################

leerArchivoPiedras:
		#
		# Descripcion de la funcion:
		# 	Abre el archivo PIEDRAS en modo lectura
		#    y devuelve la direccion que almacena 
		# 	la informacion leida del archivo.
		# Registros de entrada:
		#	- Ninguno
		# Registros de salida:
		#	- $v0 : Direccion que almacena la informacion leida
		#

		# Se abre el archivo PIEDRAS en modo de solo lectura ($a1 = 0):
		li		$v0, 13				
		la		$a0, nombreArchivo	
		li		$a1, 0				
		li		$a2, 0	
		syscall					# $v0 almacena el file descriptor				
		
		# Si hay problemas de lectura se finaliza la ejecucion del programa
		# y se muestra un mensaje al usuario:
		blt		$v0, $zero, errorLectura		

		# $t0 contiene ahora el file descriptor para el proximo syscall:
		move		$t0, $v0					

		# Se realiza la lectura del archivo y se almacena la informacion
		# en piedras archivo:
		li		$v0, 14					# Leo el archivo
		move 	$a0, $t0
		la 		$a1, piedrasArchivo
		li 		$a2, 169
		syscall
		
		# Si ocurre un error durante la lectura del archivo, el mismo
		# se cierra, y se finaliza la ejecucion del programa con un mensaje
		# al usuario:
		blt 		$v0, $zero, cerrar	

		# Se mueve a $v0 el file descriptor (retorno de la funcion)
			
		la $v0,piedrasArchivo

		jr $ra

cerrar:		
		# Se cierra el archivo:
		li		$v0, 16
		move		$a0, $t0	
		syscall
						
errorLectura:		
		# Se imprime un mensaje de error de lectura del 
		# archivo y se finaliza la ejecucion del programa:
		imprimir_t(errorLecturaA)
		imprimir_t(m_finalizarEjec)
		finalizarPrograma()
	
#------------------------------------------------------#

extraerPiedras:
		#
		# Descripcion de la funcion:
		# 	Abre el archivo PIEDRAS en modo lectura
		#    y devuelve la direccion que almacena 
		# 	la informacion leida del archivo.
		# Registros de entrada:
		#	- Ninguno
		# Registros de salida:
		#	- $v0 : Direccion que almacena la informacion leida
		#

		# Descripcion de la funcion:
		# Planificador de registros:
		#   Entrada: 
		#		$a0 contiene la direccion de los datos leidos

		move 	$t1,$a0

		li $t4, 42
			
		#la $t5, fichas

		reservarEspacio(112)
		sw $v0, fichas	
		move $t5 $v0
					
		# Se reserva el espacio para la primera ficha
		reservarEspacio(8)

		li $t2,9
		sw $t2,($v0)
		sw $t2,4($v0)	

		sw $v0 ($t5)

		cicloExtraer:

				# Se lee el primer caracter de la linea
				lw 		$t2, ($t1)
				srl       $t2, $t2, 0
				andi 	$t2,$t2,255

				move $fp, $sp #Prologo
				addi $sp $sp -4
				sw $fp, 4($sp) 
				addi $sp, $sp, -4
				sw $ra, 4($sp)
				addi $sp, $sp, -4
				sw $t4 4($sp)

				move $a3 $t4
				move $a1,$t5
				jal AgregarSimbolo
				move $t5,$v0


				lw $t4 4($sp)
				addi $sp, $sp, 4
				lw $ra, 4($sp) #Epilogo
				addi $sp, $sp, 4
				lw $fp, 4($sp)
				addi $sp, $sp, 4				

				#sw $t2,letra
				#li $v0, 4
				#la $a0,letra
				#syscall	

				# Se lee el segundo caracter de la linea:

				lw 		$t2, ($t1)
				srl       $t2, $t2, 8
				andi 	$t2,$t2,255

				move $fp, $sp #Prologo
				addi $sp $sp -4
				sw $fp, 4($sp) 
				addi $sp, $sp, -4
				sw $ra, 4($sp)	
				addi $sp, $sp, -4
				sw $t4 4($sp)	
		
				move $a3 $t4
				move $a1,$t5
				jal AgregarSimbolo
				move $t5,$v0

				lw $t4 4($sp)
				addi $sp, $sp, 4
				lw $ra, 4($sp) #Epilogo
				addi $sp, $sp, 4
				lw $fp, 4($sp)
				addi $sp, $sp, 4
		
				#sw $t2,letra
				#li $v0, 4
				#la $a0,letra
				#syscall


				# Se lee el tercer caracter de la linea:
	
				lw 		$t2, ($t1)
				srl       $t2, $t2, 16
				andi 	$t2,$t2,255

				move $fp, $sp #Prologo
				addi $sp $sp -4
				sw $fp, 4($sp) 
				addi $sp, $sp, -4
				sw $ra, 4($sp)
				addi $sp, $sp, -4
				sw $t4 4($sp)

				move $a1,$t5
				move $a3 $t4
				jal AgregarSimbolo
				move $t5,$v0

				lw $t4 4($sp)
				addi $sp, $sp, 4
				lw $ra, 4($sp) #Epilogo
				addi $sp, $sp, 4
				lw $fp, 4($sp)
				addi $sp, $sp, 4

				#sw $t2,letra
				#li $v0, 4
				#la $a0,letra
				#syscall	
			
				# Se lee el cuarto caracter de la linea:
	
				lw 		$t2, ($t1)
				srl       $t2, $t2, 24
				andi 	$t2,$t2,255

				move $fp, $sp #Prologo
				addi $sp $sp -4
				sw $fp, 4($sp) 
				addi $sp, $sp, -4
				sw $ra, 4($sp)
				addi $sp, $sp, -4
				sw $t4 4($sp)

				move $a1,$t5
				move $a3 $t4
				jal AgregarSimbolo
				move $t5,$v0


				lw $t4 4($sp)
				addi $sp, $sp, 4
				lw $ra, 4($sp) #Epilogo
				addi $sp, $sp, 4
				lw $fp, 4($sp)
				addi $sp, $sp, 4

				#sw $t2,letra
				#li $v0, 4
				#la $a0,letra
				#syscall	

				addi $t1,$t1,4
				addi $t4,$t4,-1
				bnez $t4,cicloExtraer

				jr $ra

#------------------------------------------------------#

AgregarSimbolo:
	# La entrada por ahora esta en $t2 (hay que arreglar las convenciones $a0 )
	# La direccion de las fichas por ahora esta en $t5
	# El numero casillas de la memoria recorrida se almacena en $a3
		
	li $s0, 48  # Corresponde al 0 en ASCII
	li $t6, 41  # Corresponde al ) en ASCII

	bgeu $t2,$s0,esNumero				
	beq  $t2,$t6,cambiaCaja
	blt  $t2 $s0 regresar


	esNumero:
		
		addi $t2,$t2,-48
		#imprimir_i($t2)

		lw $t4 ($a1)
		move $t7,$t4
		lw $t4,($t4)

		beq $t4,9,guardar
		bne $t4,9,siguiente

		guardar:
			sw $t2,($t7)
			b regresar

		siguiente:
			sw $t2,4($t7)
			b regresar

	cambiaCaja:

		bne $a3 1 crearCaja
		beq $a3 1 regresar

	crearCaja:
		reservarEspacio(8)
		li $t7 9
		sw $t7 ($v0)
		sw $t7 4($v0)
		addi $a1,$a1,4
		sw $v0,($a1)
		
	regresar:	
		move $v0,$a1	
		jr $ra

#------------------------------------------------------#

CrearClaseJugador:
	
	#
	# [[Nombre[4],PuntosGrupo[4],Fichas[4]],[].[].[]
	#    = numeroJugador*(4*3)+2*(4)
	#    Jugador[i].fichas = i*(TamanoPalabra*NumeroColumnas)+(Columna que nos interesa(2)*TamanoPalabra)

	reservarEspacio(64)
	move $v1,$v0
	
	# Se inicializan los puntos en 0
	li $a0 0
	sw $a0 4($v0)
	sw $a0 16($v0)
	sw $a0 28($v0)
	sw $a0 40($v0)
	sw $a0 44($v0)


	move $t0, $v0

	# Se crea la lista de fichas para cada jugador:

	li $t1,0
	li $t2,4
	li $t3,2
	li $t8,3

	mult $t2,$t8
	mflo $t4 # $t4 = TamanoPalabra*NumeroColumna

	mult $t3,$t2
	mflo $t5 # $t5 = Columna que nos interesa [2]*TamanoPalabra
	
	crearLista:
		mult $t1,$t4
		mflo $t6
		add $t6,$t6,$t5 

		add $t0,$t0,$t6
		
		reservarEspacio(28)
		sw $v0,($t0)

		sub $t0,$t0,$t6	
		addi $t1,$t1,1
		bne $t1,$t2,crearLista

	move $v0,$v1
	jr $ra
	
#------------------------------------------------------#	

PedirYalmacenarNombreJugadores:
	# Descripcion de la funcion:
	#	Pide por consola los nombres de los jugadores y los almacena
	#  en el arreglo correspondiente.
	# Planificador de registros: 
	#	Registros de entrada:
	#		* $t7: Variable que almacenara la direccion de la clase jugador
	#	Registro de salida:
	#		Ninguno

	# [[Nombre[4],Puntos[4],Fichas[4],PuntosGrupo[4]],[].[].[]
		#    = numeroJugador*(4*4)+2*(4)
		#    Jugador[i].fichas = i*(TamanoPalabra*NumeroColumnas)+(Columna que nos interesa(0)*TamanoPalabra)
	
	###################################################

	#lw $t7,jugadores

	li $t1 0
	li $t9 4
	li $t3,0
	li $t8,3

	mult $t9,$t8
	mflo $t4 # $t4 = TamanoPalabra*NumeroColumna

	mult $t3,$t9
	mflo $t5 # $t5 = Columna que nos interesa [2]*TamanoPalabra

	loop:
		imprimir_t (mensaje)
		imprimir_i ($t1)
		imprimir_t (texto)
		
		reservarEspacio(20)
		move $t0,$v0

		li $v0 8
		move $a0, $t0
		li $a1 20
		syscall
		
		move $t2, $a0 # Almaceno el nombre del jugador

		mult $t1 $t4
		mflo $t3
		add $t3 $t3 $t5 
		
		add $t6 $t7 $t3 # Me muevo hasta la posicion en donde esta 
		sw $t2 ($t6)	# Se almacena la direccion del nombre del jugador
		
	
		#li $v0 4
		#move  $a0 $t2
		#syscall
		#imprimir_t ($t2)
		#imprimir_t (saltoDeLinea)
		
		#li $v0 4
		#la $a0 saltoDeLinea
		#syscall
		
		addi $t1 $t1 1
		bne $t1 4 loop
			
	imprimir_t(saltoDeLinea)
	jr $ra	

#------------------------------------------------------#	

RepartirFichas:
		# Descripcion de la funcion:
		#	Reparte las fichas a los jugadores
		# Planificador de registros:
		#  	Registros de entrada:
		#		* $a0: Almacena el arreglo de Jugadores
		#    	* $a1: Almacena el arreglo de las fichas 
		#  	Registros de salida:
		#		* $v0: Arreglo de numero de fichas de los jugadores
		#		* $v1: Numero del jugador que tiene la cochina

		# [[Nombre[4],Puntos[4],Fichas[4]],[].[].[]
		#    = numeroJugador*(4*4)+2*(4)
		#    Jugador[i].fichas = i*(TamanoPalabra*NumeroColumnas)+(Columna que nos interesa(2)*TamanoPalabra)
		

		li $t1,0
		li $t2,4
		li $t3,2
		li $t8,3

		mult $t2,$t8
		mflo $t4 # $t4 = TamanoPalabra*NumeroColumna

		mult $t3,$t2
		mflo $t5 # $t5 = Columna que nos interesa [2]*TamanoPalabra

		#li $t8, 0 # Para moverse en el arreglo fichas [0..27]
	

		cicloRepartir:

				mult $t1,$t4
				mflo $t6
				add $t6,$t6,$t5 
	
				add $t0,$t0,$t6 # Se obtiene el desplazamiento
				add $a0,$a0,$t6	

				lw $t9,($a0)			

				sub $a0,$a0,$t6	

				li	$t2,0  # Contador de f ---->  [[],[],...,[]]
					
				cicloFichas:
						# [[n],[p],[f]]						
						# 
						# [[],[],[],,,,,[]]

						lw $t8,($a1)

						lw $t6 ($t8)

						beq $t6,6,verificarEsCochina
						bne $t6,6,noEsCochina

						verificarEsCochina:
							lw $t6, 4($t8)
							beq $t6,6 siEsCochina
							bne $t6,6 noEsCochina

							siEsCochina:
								move $v1, $t1

						noEsCochina:

						sw $t8,($t9)

						addi $t9,$t9,4
						addi		$a1,$a1,4 # F [0..27]
						addi		$t2,$t2,1
						bne 		$t2,7,cicloFichas
				
		

				addi		$t1,$t1,1
				bne		$t1,4,cicloRepartir
		
		reservarEspacio(16)
		li $t9,7
		sw $t9,($v0)
		sw $t9,4($v0)
		sw $t9,8($v0)
		sw $t9,12($v0)
	
		jr $ra

#------------------------------------------------------#	
		
CrearClaseTablero:

	# Estructura de la "Cabecera" del tablero:
	# 	- 4 bytes que "apuntan" al primer elemento
	# 	- 4 bytes que almacenan el numero de elementos que tiene la lista
	# 	- 4 bytes que "apuntan" al ultimo elemento de la lista
	
	reservarEspacio(12) # Cabecera del tablero
				
	move 	$t1 $v0      # $t1 contiene la cabecera 
	li $t2,0
	
	sw		$zero ($v0)   # Primer elemento del tablero
	sw		$t2, 4($v0) # Numero de elementos del tablero
	sw		$zero, 8($v0) # Primer elemento del tablero
	
	reservarEspacio(336)

	# Se mueve a $v1 (valor de retorno) la direccion del primer elemento del arreglo
	move $v1 $v0
	
	# Se inicializan las direcciones del primer y ultimo elemento del tablero
	sw		$v0 ($t1)     
	sw		$v0 8($t1)
	 
	#li $t2,2
	#sw $t2,($v0)
	#sw $t2,4($v0)
	#sw $zero,8($v0)
	
	# Se mueve a $v0 (valor de retorno) la cabecera creada
	move		$v0 $t1
	
	jr $ra

#------------------------------------------------------#
	

CambiarTurno:


	#  Registros de entrada:
	#	* $a0: Turno a cambiar
	
	# Registros salida:
	#	*$v0  : Turno actual
	
	
	li $t2 3
	
	beq $a0 $t2 cambiar
	bne $a0 $t2 cambiar2
	cambiar:
		li $v0 0
		jr $ra
		
	cambiar2:
	
		addi $v0 $a0 1
		jr $ra

#------------------------------------------------------#

mostrarFichas:

		# Registros de entrada:
		#
		#	* $a0: Turno actual
		#	* $a1: Direccion de la "clase" jugadores
		#
		# Registros de salida:
		#	* $v0 : La direccion del arreglo de fichas del jugador en turno
		#

		li $t2,4  # Tamano palabra
		li $t3,2  # Columna que nos interesa
		li $t8,3  # Numero columna
		
		mult $t2,$t8
		mflo $t4 # $t4 = TamanoPalabra*NumeroColumna

		mult $t3,$t2
		mflo $t5 # $t5 = Columna que nos interesa [2]*TamanoPalabra

		mult $a0 $t4  # i*( TamanoPalabra*NumeroColumna)
		mflo $t4

		add $t4 $t4 $t5  # Dezamiento
		add $a1 $a1 $t4 #Realizo el dsplazamiento
		
		lw $t1 ($a1) # Obtengo la direccion del arreglo
		move $t6 $t1 # Muevo la direccion del arreglo

		# Obtengo la direccion del arreglo de fichas del jugador i
		li $t2 7	# Iterador en el ciclo
		li $t9 0	# Iterador para el numero de opciones del jugador
		
		move $t3 $a0 # Muevo el el numero correspondiente al jugador actual para imprimir
		
		imprimir_t(mensaje)
		imprimir_i($t3)
		imprimir_t(mensajeParaElJugador)
		imprimir_t(saltoDeLinea)

		loopMostrarFicha:
		
			beq $t1 0 saltar

			lw $t3 ($t1) # Obtengo la direccion de la caja que contiene la ficha
			lw $t4 ($t3) # Obtengo un valor de la ficha
			lw $t5 4($t3)  # Obtengo un valor de la ficha

			imprimir_t(Opcion)
			imprimir_i($t9)
			imprimir_t(dosPuntos)
			imprimir_t(parentesisAbre)

			li $v0 1
			move $a0 $t4
			syscall

			imprimir_t(punto)

			li $v0 1
			move $a0 $t5
			syscall

			imprimir_t(parentesisCierra)
			imprimir_t(saltoDeLinea)

			saltar:
				addi $t1 $t1 4
				addi $t9 $t9 1
				addi $t2 $t2 -1
				bnez $t2 loopMostrarFicha
				beqz $t2 regresarMain

		regresarMain:
			move $v0 $t6
			move $v1 $t9
			# Se debe hacer una estructura de datos para almacenar $v0 y $v1
			# 	y devolver su direccion en $v0
			jr $ra


#------------------------------------------------------#
RecibirOpcionJugador:


	# Registros de entrada:
	#
	#	* $a0: Direccion de memoria del arreglo de fichas del jugador actual
	#	* $a1: Numero de fichas que posee el jugador actual
	#
	# Registros de salida:
	#	* $v0 : La direccion de la ficha que el jugador va a jugar
	#
	move $t4 $a0
	#li $t1 4

	imprimir_t(Introducir)
	
	li $v0 5
	syscall
		
	bge  $v0 $a1 verificacion
	bltz $v0 verificacion
	addi $v0 $v0 1
	b ClacularDireccion
	
	verificacion:
		imprimir_t(Invalido)
		li $v0 5
		syscall
		bgt $v0 $a1 verificacion
		bltz $v0 verificacion

	ClacularDireccion:		
		
		#mult $t1 $v0
		#mflo $t1
	
		lw $t5 ($t4)
		addi $t4 $t4 4
		
		beqz $t5 ClacularDireccion
		
		beqz $v0 regreso
		addi $v0 $v0 -1
		lw $t2 ($t5)
		lw $t3 4($t5)
		#addi $t4 $t4 4
		bnez $v0 ClacularDireccion 
	
	regreso:	
	 	move $v0 $t5
	 	lw $t2 ($v0)
	 	lw $t3 4($v0)
	 	jr $ra

#------------------------------------------------------#

actualizarTablero:
	#
	# Descripcion de la funcion:
	#	Actualiza el tablero luego de que el jugador realice un movimiento valido
	# Planificador de registros:
	#  	Registros de entrada:
	#		- $a0 : Cabecera del tablero 
	#		- $a1 : Direccion de la ficha a insertar al tablero 
	# 		- $a2 : Indica si la ficha debe voltearse al momento de ser insertada
	#		- $a3 : Indica si la ficha debe insertarse a la izquierda o a la derecha 		
	#  	Registros de salida: Ninguno
	#
	

	beq $a2,1,voltear
	bne $a2,1,noVoltear

	voltear:
		lw $t1, ($a1)  	
		lw $t0, 4($a1)      
		b seguirI
	
	noVoltear:
		lw $t0, ($a1)  	
		lw $t1, 4($a1)      
		b seguirI

	seguirI:

	# Se inserta la nueva ficha al final del arreglo del tablero:

	# $a0 tiene la cabecera

	lw $t2, ($a0)  # $t2 contiene el apuntador al primer elemento del arreglo
	lw $t3, 4($a0) # $t3 contiene el numero de elementos del arreglo 
	lw $t4, 8($a0) # $t4 contiene el apuntador al ultimo elemento insertado 
		
	beqz $t3,primerElemento
	bnez $t3,InsertaFicha

	primerElemento:
		sw $t0, ($t2)
		sw $t1, 4($t2)	
		sw $zero,8($t2) # Se actualiza el atributo "siguiente" del elemento insertado
		sw $t2,($a0)	   # Se actualiza el primer elemento del tablero
		sw $t2,8($a0)   # Se actualiza el ultimo elemento insertado a la lista
		lw $t6,4($a0)
		addi $t6,$t6,1
		sw $t6,4($a0)

		b regresarF
		
	InsertaFicha:

	# Se calcula el desplazamiento para insertar los nuevos elementos 
	# Arreglo[i] = Arreglo + i*TamanoTipo(12)
	
	li $t5,12
	mult $t3,$t5
	mflo $t5
	#add $t3,$t3,$t5 # $t3 tiene ahora el desplazamiento
	add $t2,$t2,$t5 
	sw $t0, ($t2)
	sw $t1, 4($t2)	
	lw $t6,4($a0)
	addi $t6,$t6,1
	sw $t6,4($a0)

	beq $a3,0,insertarIzquierda
	bne $a3,0,insertarDerecha
	

	insertarIzquierda:
		# Se actualizan los apuntadores:
		lw $t8,($a0)
		sw $t8,8($t2)     # Se actualiza el atributo "siguiente" del elemento insertado
		sw $t2,($a0)	   # Se actualiza el primer elemento del tablero
		b regresarF

	insertarDerecha:
		# Se actualizan los apuntadores:
		
		sw $t2,8($t4)   # Se actualiza el atributo "siguiente" del penultimo elemento
		sw $zero,8($t2) # Se actualiza el atributo "siguiente" del elemento insertado
		sw $t2,8($a0)   # Se actualiza el ultimo elemento insertado a la lista		
		b regresarF

	regresarF: 
	jr $ra
	
#------------------------------------------------------#


imprimirTablero:
	#
	# Descripcion de la funcion:
	#	Imprime por consola el estado actual del tablero de juego
	# Planificador de registros:
	#  	Registros de entrada:
	#		* $a0: Contiene la cabecera del tablero
	#  	Registros de salida: Ninguno
	#

	lw $t0, ($a0)  # $t0 contiene la direccion del primer elemento del tablero
	lw $t1, 4($a0) # $t1 contiene el numero de elementos del tablero 
	lw $t2, 8($a0) # $t2 contiene la direccion del ultimo elemento del tablero
	
	imprimeFichasTablero:

			lw $t3, ($t0)

			imprimir_t(parentesisAbre)

			# Se imprime el primer elemento de la ficha: 
			li $v0 1
			move $a0, $t3
			syscall

			imprimir_t(punto)

			lw $t3 4($t0)
			lw $t2 8($t0)

			# Se imprime el segundo elemento de la ficha:
			li $v0 1
			move $a0 $t3
			syscall

			imprimir_t(parentesisCierra)

			lw $t0, 8($t0)
			addi $t1,$t1,-1
			bnez $t1,imprimeFichasTablero

	imprimir_t(saltoDeLinea)

	jr $ra

#------------------------------------------------------#

VerificarJugada:

	# Registros de entrada:
	#
	#	* $a0: Direccion de memoria de la ficha que selecciono el jugador
	#	* $a1: Direccion de memoria de la clase tablero
	#	* $a2 : Numero de rondas de la jugada
	#
	# Registros de salida:
	#	* $v0 : En $vo se almacen una estructura de datos que posee tres argumentos.
	#       * El primer elemento es 1 si la ficha es una jugada correcta y 0 si la jugada es incorrecta
	#	* El segundo elemento es 1 si la ficha se debe voltear y 0 si no lo debe hacer
	#	* El tercer elemento es 0 si la ficha se agregara por la izquierda y 1 
	
	move $t1 $a0
	move $t2 $a1
	move $t3 $a2
	
	beq $t3 1 SeDebeJugarLaCochina  # Si estamos en la primera ronda el jugador debe sacar la cochina
	bne $t3 1 RevisarJugada
	SeDebeJugarLaCochina:
	
		lw $t4 ($t1)
		lw $t5 4($t1)
		
		beq $t4 6 VerificarFicha
		bne $t4 6 NoEsCochina
		
		VerificarFicha:
		
			beq  $t5 6 EsCochina
			bne $t5  6 NoEsCochina
			
		EsCochina:
			li $v0 1
			li $v1 0
			li $t9 0
			b saltarMain
	
		NoEsCochina:
			imprimir_t(JugadaInvalida)
			li $v0 0
			li $v1 0
			li $t9 0
			b saltarMain
			
	RevisarJugada:
	
		lw $t4 ($t1) # Valor de la ficha del jugador
		lw $t5 4($t1) # Valor de la ficha del jugador
		
		lw $t6 ($t2) # Direccion del primer elemento del tablero
		lw $t7 8($t2)# Direccion del ultimo elemento del tablero
		
		# Elemento que nos importa de la ficha del extremo izquierdo del tablero
		lw $t6 ($t6) 
		
		# Elemento que nos importa de la ficha del extremo derecho del tablero
		lw $t7 4($t7)
		
		beq $t5 $t6 izquierda
		beq $t4 $t7 derecha
		beq $t4 $t6 izquierdaVoltear
		beq $t5 $t7 derechaVoltear
		imprimir_t(JugadaInvalida)
		li $v0 0
		b saltarMain
		
		izquierda:
			li $v0 1
			li $v1 0
			li $t9 0 # El elemento se agregara a la izquierda
			b saltarMain
	
		derecha:
			li $v0 1
			li $v1 0
			li $t9 1  # El elemento se agregara a la derecha
			b saltarMain
	
		izquierdaVoltear:
			li $v0 1
			li $v1 1  # El elemento se volteara
			li $t9 0  # El elemento se agregara a la izquierda
			b saltarMain
	
		derechaVoltear:
			li $v0 1
			li $v1 1  # El elemento se volteara
			li $t9 1  # El elemento se agregara a la derecha
			b saltarMain
		
	saltarMain:
	
		move $t2 $v0
		reservarEspacio(12)
		
		sw $t2 ($v0) # Si la pieza es valida o no
		sw $v1 4($v0) # Si la pieza se debe voltear o no
		sw $t9 8($v0) # Si la pieza va a la izquierda o a la derecha
		
		jr $ra
		
#------------------------------------------------------#

RestarFichaJugador:

	# Registros de entrada:
	#
	#	* $a0: Direccion de memoria del arreglo de fichas del jugador actual
	#	* $a1: Direccion de memoria de la ficha que selecciono el jugador
	#	* $a2 : Direccion de memoria que contiene el arreglo con el numero de fichas de cada jugador
	#	* $a3 : Turno actual
	# Registros de salida:
	#	* $v0 : Numero de ficchas que tiene el jugador actual
	
	move $t1 $a0
	move $t2 $a1
	move $t3 $a2
	move $t7 $a3
	
	li $t4 7
	
	loopBuscar:
	
		lw $t5 ($t1)
		beq $t5 $t2 eliminar
		bne $t5 $t2 seguir
		
		eliminar:
			sw $zero ($t1)
			li $t5 4
			mult $t5 $t7
			mflo $t5
			add $t3  $t3 $t5
			lw $t8 ($t3)
			addi $t8 $t8 -1
			sw $t8 ($t3)
			move $v0 $t8 # Registro de salida
			b regresarCiclo
		
		seguir:
			addi $t1 $t1 4
			addi $t4 $t4 -1
			bnez $t4 loopBuscar
		
		
	regresarCiclo:
		jr $ra
	
#------------------------------------------------------#

VerificarSiSePuedeJugar:
	#
	# Descripcion de la funcion: 
	#	Funcion que verifica si un jugador pasa o no
	# Registros de entrada:
	#	- $a0 : Direccion del arreglo de fichas del jugador
	#       - $a1 : Direccion de la cabecera del tablero
	#	- $a2 : Direccion del arreglo que posee el numero de fichas del jugador
	# Registros de salida:
	#	- $v0 : Retorna 1 si puede jugar y 0 si no
	#
	
	move $t1 $a0 # Direccion del arreglo de fichas del jugador
	move $t2 $a1 # Direccion de la cabecera del tablero
	
	lw $t3 4($t2) # Numero de elementos del tablero
	
	beqz $t3 primeraRonda
	bnez $t3 VerificarLasFichas
	
	primeraRonda:
		li $v0 1
		jr $ra
	
	VerificarLasFichas:
	
		lw $t3 ($t2) # Direccion del primer elemento del tablero (extremo izquierdo)
		lw $t4 8($2) # Direccion del ultimo elemento del tablero (extremo derecho)
		
		lw $t5 ($t3) # Elemento jugable en el extremo izquierdo del tablero
		lw $t6 4($t4)# Elemento jugable en el extremo derecho del tablero
		
		# Recorremos todas las fichas del jugador para ver si es posible que juegue
		
		lw $t3 ($a2) # Numero de fichas del jugador 
		li $v0 0 	# Inicializo $v0 en 0
		
		loopFichas:
		
			lw $t7 ($t1) # Contenido del arreglo de fichas
			beqz $t7 Siguiente
			bnez $t7 VerificarFicha2
			
			Siguiente:
				addi $t1 $t1 4
				b loopFichas
				
			VerificarFicha2:
			
				lw $t8 ($t7)	# Numero de la ficha
				lw $t9 4($t7)	# Numero de la ficha
				
				beq $t8 $t5 Correcto
				bne $t8 $t5 Verificar1
				
				Verificar1:
					beq $t8 $t6 Correcto
					bne $t8 $t6 Verificar2
				Verificar2:
					beq $t9 $t5 Correcto
					bne $t9 $t5 Verificar3
				Verificar3:
					beq $t9 $t6 Correcto
					bne $t9 $t6 Siguiente2
					
			Correcto:
				li $v0 1
				jr $ra
				
			Siguiente2:
				addi $t1 $t1 4
				addi $t3 $t3 -1
				bnez $t3 loopFichas
			jr $ra
	

#------------------------------------------------------#

sumarPuntosN:
	#
	# Descripcion de la funcion: 
	#	Suma los puntos de los jugadores en caso
	#	de que un jugador se quede sin fichas.
	# Registros de entrada:
	#	- $a0 : Direccion del arreglo de jugadores
	#	- $a1 : Numero correspondiente al grupo ganador
	# Registros de salida:
	#	- Ninguno
	
	jr $ra

#------------------------------------------------------#	

sumarPuntosT:
	#
	# Descripcion de la funcion: 
	#	Suma los puntos de los jugadores en caso
	# 	de que se tranque una partida.
	# Registros de entrada:
	#	- $a0 : Direccion del arreglo de jugadores
	# Registros de salida:
	#	- Ninguno
	#
	
	# NOTA: que pasa si los numeros que suman en trancar son iguales???
	# Ejemplo: suma0 = 20 y suma1 = 20 ?? 
	
	li $t0,0 # Variable de iteracion de cicloSumarT
	li $t1,0 # Inicializacion de la variable suma0
	li $t2,0 # Inicializacion de la variable suma1
	
	# Ahora los registros $a's tienen la direccion de los arreglos de los jugadores
	move $a1,$a0  # Jugador 1
	lw $a1,20($a0)

	move $a2,$a0  # Jugador 2
	lw $a2,32($a0)

	move $a3,$a0  # Jugador 3
	lw $a3,44($a0)

		
	cicloSumarT:

		beqz $t0,primeraVez
		bnez $t0,sumarNum
		
			primeraVez:
				lw $t4,8($a0)     # $t4 contiene la direccion del arreglo de fichas
				lw $t6,($a2)      # $t6 contiene la direccion del arreglo de fichas
				b sumarNum

		sumarNum:
			# Se suman las fichas del jugador0 ($t4) en suma0 ($t1):
		
			lw $t5,($t4)      # Se suma el primer elemento de la ficha
			add $t1,$t1,$t5

			lw $t4,8($a0)	   # $t4 contiene la direccion del arreglo de fichas
			lw $t5,4($t4)     # Se suma el segundo elemento de la ficha
			add $t1,$t1,$t5 
		
			lw $t4,4($t4)     # Se mueve al siguente elemento de la ficha
	
			# Se suman las fichas del jugador2 ($t6) en suma0 ($t1):
	
			lw $t5,($t6)      # Se suma el primer elemento de la ficha
			add $t1,$t1,$t5

			lw $t6,($a2)	   # $t6 contiene la direccion del arreglo de fichas
			lw $t5,4($t6)     # Se suma el segundo elemento de la ficha
			add $t1,$t1,$t5 
		
			lw $t6,4($t6)     # Se mueve al siguente elemento de la ficha

			# Se suman las fichas del jugador1 ($t3) en suma1 ($t2):

			lw $t3,($a1)      # $t3 contiene la direccion del arreglo de fichas
			lw $t5,($t3)      # Se suma el primer elemento de la ficha
			add $t1,$t1,$t5

			lw $t3,($a1)	   # $t3 contiene la direccion del arreglo de fichas
			lw $t5,4($t3)     # Se suma el segundo elemento de la ficha
			add $t1,$t1,$t5 
			
			lw $t3,4($t3)     # Se mueve al siguente elemento de la ficha
	
			# Se suman las fichas del jugador3 ($t7) en suma1 ($t2):

			lw $t7,($a3)     # $t7 contiene la direccion del arreglo de fichas
			lw $t5,($t7)      # Se suma el primer elemento de la ficha
			add $t1,$t1,$t5

			lw $t7,($a3)	   # $t7 contiene la direccion del arreglo de fichas
			lw $t5,4($t7)     # Se suma el segundo elemento de la ficha
			add $t1,$t1,$t5 
		
			lw $t7,4($t7)     # Se mueve al siguente elemento de la ficha

			addi $t0,$t0,1
		bne $t0,6,cicloSumarT

	# $t1 (Suma0) y $t2 (Suma1)

	bgt $t2,$t1,sumarT0
	bgt $t1,$t2,sumarT1

	sumarT0:	

		# jugador0.puntos ($t4)
		lw $t4,4($a0)
		add $t4,$t4,$t2
		sw $t4,4($a0)

		# jugador2.puntos ($t6)
		lw $t6,28($a0)
		add $t6,$t6,$t2
		sw $t6,28($a0)

		b regresarT

	sumarT1:
		
		# jugador1.puntos ($t3)
		lw $t3,16($a0)
		add $t3,$t3,$t1
		sw $t3,16($a0)

		# jugador3.puntos ($t7)
		lw $t7,40($a0)
		add $t7,$t7,$t1
		sw $t7,40($a0)
	
		b regresarT
	
	regresarT:
		jr $ra
	
#------------------------------------------------------#	

mezclarFichas:
	#
	# Descripcion de la funcion: 
	#	Cuando comienza una nueva ronda, mezcla 
	# 	las fichas en el arreglo de fichas usando
	#	el algoritmo de Fisher-Yates
	# Registros de entrada:
	#	- $a0 : Direccion del arreglo de fichas
	# Registros de salida:
	#	- Ninguno
	#
	li $t0,27	# Variable de iteracion del ciclo
	
	cicloMezclarF:

		# Se determina el entero random j para el swap:

		li $v0, 42
		li $a0, 0
		move $a1, $t0
		syscall
		move $t1, $a0
		
		# Calculamos el desplazamiento de $t2 (A[i]):
		# Arreglo[i] = Arreglo + i*TamanoTipo(4)
	
		li $t5,4
		mult $t0,$t5
		mflo $t5
		add $t2,$a0,$t5 
		
		# Calculamos el desplazamiento de $t3 (A[j]):
		# Arreglo[j] = Arreglo + i*TamanoTipo(4)

		li $t5,4
		mult $t1,$t5
		mflo $t5
		add $t2,$a0,$t5

		# Se realiza el swap de los elementos:
		
		move $t4,$t2    # temp := A[i]
 		sw $t3,($t2)    # A[i] := A[j]
		sw $t4,($t3)    # A[j] := A[i]
		
		addi $t0,$t0,-1
		bne $t0,1,cicloMezclarF
		
	jr $ra


#------------------------------------------------------#

limpiarTablero:
	#
	# Descripcion de la funcion: 
	#	Cuando se comienza una nueva ronda 
	#	la funcion vuelve a inicializar el tablero de juego
	# 	vacio 
	# Registros de entrada:
	#	- $a0 : Direccion de la cabecera del tablero 
	#	- $a1 : Direccion del primer elemento del arreglo del tablero
	# Registros de salida:
	#	- $v0 : Cabecera del tablero inicializada
	#
	
	lw $t0,($a0)  	 # Apuntador al primer elemento del tablero
	lw $t1,4($a0) 	 # Numero de elementos del tablero
	lw $t2, 8($a0)  # Apuntador al ultimo elemento del tablero
	li $t4,0		 # Valor 0 para inicializar el tablero
		
	cicloLimpiar:

		sw $t4,($t0)
		sw $t4,4($t0)

		move $t5,$t0 # Temporal para inicializar el valor de "siguiente
		lw $t0,8($a0)
		sw $t4,8($t5)
	
		addi $t1,$t1,-1
		bnez $t1,cicloLimpiar

	# Luego del ciclo se actualizan los valores de la cabecera:

	sw $a1,($a0)  	 # Se inicializa el primer elemento del tablero
	sw $t4, 4($a0)  # Se inicializan en 0 los elementos del tablero
	sw $a1,8($a0) 	 # Se inicializa el ultimo elemento del tablero
		
	move $v0,$a0

	jr $ra

#------------------------------------------------------#

RevisarPuntos:
	#
	# Descripcion de la funcion: 
	#	Recibe el arreglo de jugadores y verifica cual
	#    es el grupo ganador.
	# Registros de entrada:
	#	- $a0 : Direccion del arreglo de jugadores
	# Registros de salida:
	#	- $v0 : Indica el tipo de victoria (normal,chancleta,zapatero)
	#	- $v1 : Indica el grupo los de ganadores
	#
	
	lw $t0, 4($a0)  # Puntos del grupo 0 (Pares)
	lw $t1, 16($a0) # Puntos del grupo 1 (Impares)
	
	bgt $t0,$t1,ganador0
	blt $t0,$t1,ganador1

	ganador0:
		li $v1,0
		move $t2,$t1 # $t2 contiene el numero de puntos del perdedor
		b TipoVictoria
	
	ganador1:
		li $v1,1
		move $t2,$t0 # $t2 contiene el numero de puntos del perdedor
		b TipoVictoria
	
	TipoVictoria:
		
		beqz $t2,zapatero
		zapatero:
			li $v0, 0
			b retorno
		
		beq $t1,10,chancleta
		chancleta:
			li $v1,1	
			b retorno
		
		# Victoria normal:
		li $v0,2
		
	retorno:

		jr $ra

#------------------------------------------------------#

imprimirMensajeGanador:
	#
	# Descripcion de la funcion:
	# 	Imprime por consola el grupo ganador y el tipo
	#	de victoria (normal,chancleta,zapatero)
	# Registros de entrada:
	#	- $a0 : Variable que indica el tipo de victoria
	#	- $a1 : Numero del grupo de los ganadores
	#	- $a2 : Arreglo de los jugadores 
	# Registros de salida:
	#	- Ninguno
	#
	
	imprimir_t(finJuego)
	imprimir_t(ganadores)

	beq $a1,0,ganadoresPares
	beq $a1,1,ganadoresImpares

	ganadoresPares:
		lw $t0,($a2)
		lw $t1,24($a2)
		
		imprimir_t(guion)

		li $v0,4
		move $a0,$t0
		syscall

		imprimir_t(guion)
		
		li $v0,4
		move $a0,$t1
		syscall


		b mensajesVictoria
	
	ganadoresImpares:
		lw $t0,12($a2)
		lw $t1,36($a2)

		imprimir_t(guion)

		li $v0,4
		move $a0,$t0
		syscall

		imprimir_t(guion)

		li $v0,4
		move $a0,$t1
		syscall
		
		lw $t0,($)
		b mensajesVictoria
	

	mensajesVictoria:	

		imprimir_t(por)

		beq $t3,0,mensajeZapatero
		beq $t3,1,mensajeChancleta
		beq $t3,2,mensajeNormal

		mensajeZapatero:
			imprimir_t(m_zapatero)
			b retornoG

		mensajeChancleta:
			imprimir_t(m_chancleta)
			b retornoG
	
		mensajeNormal:
			imprimir_t(m_normal)
			b retornoG

	retornoG:
	 	jr $ra
