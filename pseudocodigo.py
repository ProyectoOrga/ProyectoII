def RevisarPuntos(jugador1,jugador2):

	Ganador = max(jugador1.puntos(),jugador2.puntos())
	Perdedor = min(jugador1.puntos(),jugador2.puntos())
	if (Perdedor==0):
		mensaje = "Zapatero"
	elif (Perdedor==10):
		mensaje = "Chancleta"
	else:
		mensaje = "Normal"
		
	if (Ganador==jugador1.puntos()):
	    Ganador=1
	    
	elif (Ganador==jugador2.puntos()):
	    Ganador=2
	    
	return mensaje,grupoGanador


def ImprimirMensajeFelicitacion(Mensaje,ganador):
    ganador1=ganador+2
    print(Mensaje)
    print("Los ganadores son: ")
    print(Jugador[ganador]+" y "+Jugador[ganador])
    
def sumarPuntosN(Jugadores,Ganadores):
	
	if Ganadores == 0:
		
		# Se suman las fichas de los jugadores [1] y [3]
		for i in range(7):
			Suma = Suma + jugador1.fichas[i][0]
			Suma = Suma + jugador1.fichas[i][1] 
			Suma = Suma + jugador3.fichas[i][0]
			Suma = Suma + jugador3.fichas[i][1]
		
		# Se asignan a los puntos de los jugadores [0] y [2]:
		jugador0.puntos = jugador0.puntos + Suma
		jugador2.puntos = jugador2.puntos + Suma
		
		
	elif Ganadores == 1:
		
		# Se suman los puntos de los jugadores [0] y [2]
		for i in range(7):
			Suma = Suma + jugador0.fichas[i][0]
			Suma = Suma + jugador0.fichas[i][1]
			Suma = Suma + jugador2.fichas[i][0]
			Suma = Suma + jugador2.fichas[i][1]
		
		# Se asignan a los puntos de los jugadores [1] y [3]
		jugador1.puntos = jugador1.puntos + Suma
		jugador3.puntos = jugador3.puntos + Suma
		
	
#------------------------------------------------------------------------------#

def sumarPuntosT(Jugadores,Ganadores):
	
	for i in range(7):
			
			Suma0 = Suma0 + jugador0.fichas[i][0]
			Suma0 = Suma0 + jugador0.fichas[i][1]
			Suma0 = Suma0 + jugador2.fichas[i][0]
			Suma0 = Suma0 + jugador2.fichas[i][1]
			
			Suma1 = Suma1 + jugador1.fichas[i][0]
			Suma1 = Suma1 + jugador1.fichas[i][1] 
			Suma1 = Suma1 + jugador3.fichas[i][0]
			Suma1 = Suma1 + jugador3.fichas[i][1]
	
	if (Suma1 > Suma0):	
		jugador0.puntos = jugador0.puntos + Suma1
		jugador2.puntos = jugador2.puntos + Suma1
	
	elif (Suma0 > Suma1):
		jugador1.puntos = jugador1.puntos + Suma0
		jugador3.puntos = jugador3.puntos + Suma3



################################################################################
#					           Programa principal		   			           #
################################################################################

leerArchivo()
repartirFichas() # Aca se busca la cochina
colaJuego,colaTurnos = colaArmarColas()
tablero = CrearTablero()
turno = BuscarTurnoCochina()
numeroRonda = 1


while (grupo[1].puntos!=100 and grupo[1].puntos!=100):

	if (numeroRonda!=1 and NuevoJuego):
		mezclar(piedras)
		repartirFichas()
		NuevoJuego=False
		tablero = CrearTablero()
		turno=CambiarTurnoInicio()

	else:
		pass
		

	JugadorActual = BuscarJugador(turno)
	puedoJugar = JugadorActual.fichas.VerificarPaso

	# El jugador JUEGA
	if (puedoJugar):
	   
		JugadorActual.mostrarFichas()
		respuesta=RecibirMensajeJugador
		movimientoValido=VerificarRespuesta(respuesta)

		while not(movimientoValido):
			respuesta=RecibirMensajeJugador
			movimientoValido=VerificarRespuesta(respuesta)

		AgregarFichaAlTablero(respuesta)
		ImprimirTablero()
		JugadorActual.fichas.restarUno()
		numeroFichas=JugadorActual.verificarNumeroFichas()

		if (numeroFichas==0):
			sumarPuntosNormal()
			NuevoJuego=True
			numeroRonda++
			
		else:
		    turno=CambiarTurno()



	# El jugador PASA
	else:

		VariablesGlobales.numeroPasos()++

		if (VariablesGlobales.numeroPasos==4):
			sumarPuntosTrancado()
			NuevoJuego=True

		else:
		    turno=CambiarTurno()
			#JugadorActual = colaJuego.desencolar()

mensaje,gGanador=RevisarPuntos(Jugador[1],Jugador[2])
ImprimirMensajeFelicitacion(mensaje,gGanador)









