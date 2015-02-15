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









