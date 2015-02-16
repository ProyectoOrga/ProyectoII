#
# ProyectoII.asm
#
# Descripcion:
#
# Nombres: 
#    Alejandra Cordero / Carnet: 12-10645
#    Pablo Maldonado   / Carnet: 12-10561
#
# Ultima modificacion: 01/02/2015
#

		.data

jugadores:		.word     0
tablero:			.word     0
rondas: 			.word	0
nuevoJuego:		.word     0
fichas:			.word     0
piedrasArchivo:	.space  169
nombre:			.space   20
letra:			.word     0
nombreArchivo:		.asciiz "/home/prmm95/Desktop/CI3815/ProyectoII-Github/PIEDRAS"
saltoDeLinea:		.asciiz "\n"
mensaje: 			.asciiz "Jugador "
texto:			.asciiz " Introduzca su nombre: "
#nombre:		


		.text

########################################################
#                DECLARACION DE MACROS                 #                      
########################################################


.macro imprimir_t (%texto) #Macro para imprimir un texto
	li 		$v0, 4
	la		$a0, %texto
	syscall
.end_macro
		
.macro imprimir_i (%numero) #Macro para imprimir un entero
	li		$v0, 1
	move		$a0, %numero
	syscall
.end_macro

.macro reservarEspacio(%espacio) # Macro para reservar espacio de memoria

	li		$v0  9
	li		$a0  %espacio
	syscall
.end_macro 

########################################################
#             INICIO DEL CODIGO PRINCIPAL              #                      
########################################################

main:

		jal 		leerArchivoPiedras # Se retorna en $v0 la direccion de los datos leidos
		move 	$a0,$v0
		jal 		extraerPiedras
		
		# Se crea la clase jugador
		jal 		CrearClaseJugador 
		sw 		$v0 jugadores
		
		# Es un  argumento, hay que cambiar $t7 por $a0 
		move 	$t7 $v0  # Se estaria trabajando la estructura de datos jugador como algo global (no se si eso es bueno)

		# Pedir nombre a Jugadores
		jal 		PedirYalmacenarNombreJugadores

		# Se reparten las fichas a los jugadores:
		lw 		$a0, jugadores
		lw 		$a1, fichas  		
		jal 		RepartirFichas 	

		# Se crea la clase tablero
		jal 		CrearClaseTablero
		sw 		$v0 tablero



#########################################################
# Cuando encontremos la cochina guardar en una variable 
#  el numero del jugador que le toca sacar en la proxima 
#  ronda
#########################################################

li $a0 1
sw $a0 rondas  # NumeroRondas=1
sw $a0 nuevoJuego #NuevoJuego=True


loopPrincipal:

	
	# Se verifica si los puntos del grupo 1 son mayores o iguales que 100
	lw $s1 jugadores
	lw $s2 4($s1)
	li $s3 100
	bge $s2 $s3 RevisarPuntos
	blt $s2 $s3 continuar

	continuar:
		# Se verifica si los puntos del grupo 2 son mayores o iguales que 100
		lw $s2 16($s1)
		bge $s2 $s3 RevisarPuntos
		blt $s2 $s3 VerificarRondaNueva
		
	VerificarRondaNueva:
	
		# Se verifica si nuevoJuego=True
		lw $s1 rondas
		lw $s2 nuevoJuego
		li $s3 1
		beq  $s2 $s3 VerificarNumeroRondas
		bne  $s2 $s3 NuevaPartida
		
	VerificarNumeroRondas:
		# Se verifica si numeroRondas!=1
		bne $s1 $s3 NuevaPartida
		beq $s1 $s3 continuarJuego
		
		
	NuevaPartida:
	
		# Se empieza una nueva partida
	
		# mezclar(piedras)
		# repartirFichas()
		
		li $s1 0
		sw $s1 nuevoJuego  # NuevoJuego=False
		jal CrearClaseTablero
		sw $v0 tablero
		jal CambiarTurno
		move $s7 $v0
		
	continuarJuego:
	

li 		$v0, 10
		syscall	

########################################################
#               DECLARACION DE FUNCIONES               #                      
########################################################

leerArchivoPiedras:

		# Descripcion de la funcion:
		# Planificador de registros:


		li		$v0, 13					# Abro el archivo
		la		$a0, nombreArchivo	
		li		$a1, 0					# Modo lectura
		li		$a2, 0	
		syscall							# Al hacer el syscall el file descriptor queda en $v0
		
		blt		$v0, $zero, errorLectura		# Si hay error termino la ejecucion
		move		$t0, $v0					# Respaldo el file descriptor en $t0

		li		$v0, 14					# Leo el archivo
		move 	$a0, $t0
		la 		$a1, piedrasArchivo
		li 		$a2, 169
		syscall
		
		blt 		$v0, $zero, cerrar			# Si hay error cierro el archivo y termino la ejecucion 
		move 	$t1, $v0
			
		la $v0,piedrasArchivo

		#imprimir_t(mensaje)
		#imprimir_i($t1)
		#imprimir_t(saltoDeLinea)
		#imprimir_t(texto)		
		#imprimir_t(piedrasArchivo)

		jr $ra

cerrar:		

		li		$v0, 16
		move		$a0, $t0	
		syscall
						
errorLectura:		

		li 		$v0, 10
		syscall	
	
#------------------------------------------------------#

extraerPiedras:
		
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
		li $a0,8
		li $v0,9
		syscall

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
		imprimir_i($t2)

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


	li $a0 64
	li $v0 9
	syscall
	move $v1,$v0
	
	# Se inicializan los puntos en 0
	li $a0 99
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

	lw $t7,jugadores

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
		#

		# [[Nombre[4],Puntos[4],Fichas[4],PuntosGrupo[4]],[].[].[]
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
						sw $t8,($t9)

						addi $t9,$t9,4
						addi		$a1,$a1,4 # F [0..27]
						addi		$t2,$t2,1
						bne 		$t2,7,cicloFichas
				
		

				addi		$t1,$t1,1
				bne		$t1,4,cicloRepartir
			

		jr $ra








		
CrearClaseTablero:

	# 4 bytes que "apuntan" al primer elemento
	# 4 bytes que almacenan el numero de elementos que tiene la lista
	# 4 bytes que "apuntan" al ultimo elemento de la lista
	
	li $a0 12
	li $v0 9
	syscall
		
	sw $zero ($v0)
	li $a0 0
	sw $a0 4($v0)
	sw $zero 8($v0)
	
	jr $ra


CambiarTurno:


	#  Registros de entrada:
	#	* $t1: Turno a cambiar
	
	# Registros salida:
	#	*$v0  : Turno actual
	
	
	li $t2 4
	
	beq $t1 $t2 cambiar
	bne $t1 $t2 cambiar2
	cambiar:
		li $v0 1
		jr $ra
		
	cambiar2:
	
		addi $v0 $t1 1
		jr $ra


RevisarPuntos:

	li $v0 1
	jr $ra

fin:

	li $v0, 10
	syscall
