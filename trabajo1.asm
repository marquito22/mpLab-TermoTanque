;***************************************************************************************************
;		Detalles del Trabajo Practico
;***************************************************************************************************

;fecha de entrega; 11/11.
;Materia: Arquitectura de Computadoras.
;Alumno: Marco Nicolas Carreira.
;DNI: 45873082.

;***************************************************************************************************
;		Detalles del programa
;***************************************************************************************************

;Programa trabajo1.asm
;Pragrama para PIC16F628A.
;Con este promagrama se busca simular el funcionamiento de un termotanque.
;El que va a contar con una temperatura maxima, minima y una del agua.
;Ademas dicho termotanque tendra 4 leds los cuales indicaran el estado de la temperatura de agua en ese momento.
;y con una canilla que de ella dependera si la temperatura del agua desciende con mas velocidad o no.

;****************************************************************************************************
;		Configuracion del pic
;****************************************************************************************************
	
	__CONFIG 3F10	
	LIST p=16f628a	;tipo de pic
	INCLUDE 	<p16f628a.inc>
	ERRORLEVEL -302

;****************************************************************************************************
;		Definiciones
;****************************************************************************************************	

MAXIMA  EQU  0x20		;asignamos la posicion de maxima
MINIMA  EQU  0x21		;asignamos la posicion de minima
AGUA    EQU  0x22		;asignamos la posicion de agua
CANILLA EQU  0x23		;asignamos la posicion de canilla
REG1	EQU	 0x24		;asignamos la posicion del primer retardo
REG2	EQU  0x25		;asignamos la posicion del segundo retardo

;*****************************************************************************************************

	ORG 0				;comando que indica al ensamblador donde iniciara el programa

	goto INICIO ;realizamos un goto hacia el inicio para saltar las subrutinas 


;*****************************************************************************************************
;		Configuracion de los puertos
;*****************************************************************************************************

PUERTOS 

	bsf STATUS,5		;cambiamos de banco del 0 al 1
	movlw B'11110000'	;cargamos el binario 11110000 al registro w
	movwf TRISB			;configuramos el TRISB con sus ultimos 4 bits como salida

	bcf STATUS,5		;volvemos al banco 0
	movlw B'00000000'	;cargamos el binario 00000000 al registro w
	movwf PORTB			;configuramos todos los bits del PORTB en 0	
	RETURN


;******************************************************************************************************
;		Subrutinas para prender leds
;******************************************************************************************************
PRENDER_LED_AZUL		; led que idica que la resistencia esta apagada

	bcf STATUS,5		;nos dirijimos al banco 0
	bsf PORTB,0			;configurar el bit RB0 del portb como salida

	RETURN	

APAGAR_LED_AZUL
	
	bcf STATUS,5
	clrf PORTB

	RETURN

PRENDER_LED_AMARILLO	;led que indica que la temperatura del agua esta incrementando y la resistencia esta prendida

	bcf STATUS,5		;nos dirigimos al banco 0
	bsf PORTB,1			;configurar el bit RB1 del portb como salida

	RETURN

APAGAR_LED_AMARILLO

	bcf STATUS,5
	clrf PORTB
	
	RETURN

PRENDER_LED_ROJO	    ;led que indica que la temperatura del agua llego al maximo

	bcf STATUS,5		;nos dirigimos al banco 0
	bsf PORTB,2			;configurar el bit RB2 del portb como salida

	call RETARDO		;generamos un retardo para mantener al led prendido

	bcf PORTB,2			;apagamos el led rojo

	RETURN

PRENDER_LED_VERDE	    ;led que indica que la temperatura del agua llego al minimo

	bcf STATUS,5		;nos dirigimos al banco 0
	bsf PORTB,3			;configuramos el bit RB3 del portb como salida

	call RETARDO		;generamos un retardo para mantener durante un tiempo el led encendido

	bcf PORTB,3			;apagamos el led verde

	RETURN


;*****************************************************************************************************
;		Subrutina retardo
;*****************************************************************************************************
RETARDO
	
	
	RETURN

;*****************************************************************************************************
;		Subrutinas para calentar agua
;*****************************************************************************************************

INCREMENTAR_TEMPERATURA
	
	call PRENDER_LED_AZUL		;encendemos el led que indica que la resistencia se encuentra apagada
	
	movf MAXIMA,W					;movemos el valor de "MAXIMA" al W para posteriormente restarlo con "MAXIMA"
	subwf AGUA,W					;"MAXIMA" - "AGUA" 

	btfsc STATUS,C				;si "AGUA" < "MAXIMA" salta la siguiente instruccion
	goto INCREMENTAR_TEMPERATURA ;si "AGUA" > "MAXIMA" vuelve a preguntar

	call CALENTAR_AGUA			;llamamos a la subrutina que calienta el agua
	
	RETURN
	
CALENTAR_AGUA
	
	call APAGAR_LED_AZUL
	call PRENDER_LED_AMARILLO	;prendemos el led que indica que la resistencia esta prendida
	incf AGUA,F					;incrementamos en 1 la temperatura del agua
		
	movf MAXIMA,W				;cargamos el valor de "MAXIMA" al w
	subwf AGUA,W				;restamos el valor del "MAXIMA" con el valor de "AGUA" almacenado en w

	btfss STATUS,Z				;si el bit z del STATUS es igual 1 salta a la instruccion para prender el led
	goto CALENTAR_AGUA			;si "AGUA" < "MAXIMA" incrementa en 1 el valor de "AGUA"
	
	call APAGAR_LED_AMARILLO
	call PRENDER_LED_ROJO		;encendemos el led que indica que el agua llego a la temperatura maxima
	
	RETURN

;*****************************************************************************************************
;		Subrutinas para enfriar el agua
;*****************************************************************************************************

DECREMENTAR_TEMPERATURA
	
	call PRENDER_LED_AZUL
	btfss CANILLA,0			;si el bit 0 de la canilla esta en 1 (canilla abierta) enfriar mas rapido la temperatura del agua
	call ENFRIAR_LENTO		;enfriamos el agua mas lento ya que la canilla esta cerrada

	call ENFRIAR_RAPIDO		;enfriamos el agua mas rapido ya que la canilla esta abierta

	RETURN

ENFRIAR_LENTO

	decf AGUA,F			;incrementamos en 1 la temperatura minima

	movf AGUA,W			;cargamos el valor de "MINIMA" en w
	subwf MINIMA,W			;restamos la "MINIMA" con el "AGUA"

	btfss STATUS,Z			;si el bit Z del STATUS es igual a 1 entonces prendemos el led verde
	goto ENFRIAR_LENTO		;si "AGUA" > "MINIMA" que se vuelva a incrementar en 1 "MINIMA"
	
	call APAGAR_LED_AZUL
	call PRENDER_LED_VERDE	;encendemos led que indica que el agua llego a su temperatura minima

	RETURN

ENFRIAR_RAPIDO

	movlw D'2'				;cargo en w el valor 2 para posterior incrementar el valor de "MINIMA"
	subwf AGUA,F			;incremento en 2 el valor de 

	movf AGUA,W			
	subwf MINIMA,W

	btfss STATUS,Z			;si el bit Z del STATUS es igual a 1 entonces prendemos el led verde
	goto ENFRIAR_RAPIDO		;si "AGUA" > "MINIMA" que se vuelva a incrementar en 2 "MINIMA"	

	call APAGAR_LED_AZUL
	call PRENDER_LED_VERDE	;encendemos led que indica que el agua llego a su temperatura minima
	
	RETURN

;*****************************************************************************************************
;		Subrutina Inicio																			 
;*****************************************************************************************************


INICIO 
	
	call PUERTOS		;llamamos a la subrutina PUERTOS para configurar los puertos de salida
	
	movlw D'60'			;cargamos en w el valor que llevara la variable "MAXIMA"
	movwf MAXIMA		;le damos valor a la variable "MAXIMA"

	movlw D'32'			;cargamos en w el valor que llevara la variable "MINIMA"
	movwf MINIMA		;le damos valor a la variable "MINIMA"

	movlw D'20'			;cargamos en w el valor que llevara la variable "AGUA"
	movwf AGUA			;le damos valor a la variable "AGUA"

	movlw B'00000000'	;cargamos en w el valor que llevara la variable "CANILLA"
	movwf CANILLA		;le damos valor a la variable "CANILLA" al estar en 0 se encuentra "cerrada"
	
	clrw 				;limpiamos el registro W para que no quede almacenado basura
	
	call INCREMENTAR_TEMPERATURA	;llamamos a la subrutina que nos permite incrementar la temperatura del agua
	

	call DECREMENTAR_TEMPERATURA	;llamamos a la subrutina que nos permite enfriar el agua


	goto INICIO						;realizamos un goto al INICIO para repetir el ciclo de forma indefinida

	END 							;fin del programa

	
;*******************************************************************************************************






