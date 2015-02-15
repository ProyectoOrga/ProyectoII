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
texto:			.asciiz " introduzca su nombre :   "
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
		j fin

# Se crea la clase jugador
jal CrearClaseJugador 
sw $v0 jugadores

move $t7 $v0  # Se estaria trabajando la estructura de datos jugador como algo global (no se si eso es bueno)

# Pedir nombre a Jugadores
jal PedirYalmacenarNombreJugadores

# Se crea la clase tablero
jal CrearClaseTablero
sw $v0 tablero



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

CrearClaseJugador:
	
	li $a0 64
	li $v0 9
	syscall
	
	# Se inicializan los puntos en 0
	li $a0 0
	sw $a0 4($v0)
	sw $a0 16($v0)
	sw $a0 28($v0)
	sw $a0 40($v0)
	sw $a0 44($v0)
	
	jr $ra
	
	
PedirYalmacenarNombreJugadores:

	#
	#  Registro de entrada:
	#	* $t7: Variable que almacenara la direccion de la clase jugador
	#
	#  Registro de salida:
	#	Ninguno
	
	
	
	li $t1 4
	li $t4 12
	loop:
		imprimir_t (mensaje)
		imprimir_i ($t1)
		imprimir_t (texto)
		

		li $v0 8
		la $a0, nombre
		li $a1 20
		syscall
		
		la $t2 nombre # Almaceno el nombre del jugador 
		addi $t3 $t1 -1 # Multiplico 28(i-1)
		mult $t3 $t4
		mflo $t3
		
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
		
		addi $t1 $t1 -1
		bnez $t1 loop	
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
