
;================ SECCIÓN DE MACROS ============================== 
     
;include M/m_bars.asm     
include M/m_file.asm 
include M/m_game.asm 
include M/m_kpad.asm 
include M/m_log.asm 
include M/m_main.asm 
include M/m_reps.asm 
include M/m_sign.asm 
include M/m_figs.asm 
include M/m_lvls.asm 

;================ DEFINICIÓN DE MODELO Y PILA ==============================       
.model small ;small: Se utilizará solo un segmento de datos con un segmento de código,
             ;en total 128 Kbytes de memoria
.stack 100h  ;asignamos su tamaño 
;================ SEGMENTO DE DATOS ============================== 
.data   
  
;=== EQUIVALENTES ===========================================   
;Simbolos:  
saltoLn EQU 0ah ;0ah-> 10 -> \n 
retornoCR EQU 0dh ;0dh-> 13 ->\r       
tabulador EQU 09h ;09h -> 9 -> \t    
EtildadaMinus EQU 82h ;82H -> 130 -> é
ItildadaMinus EQU 0A1h ;A1H -> 161 -> í
OtildadaMinus EQU 0A2h ;A2H -> 162 -> ó
coma EQU 2ch ;2ch-> 44 -> , 
guion EQU 2dh; 2dh -> 45 -> "-"
punto EQU 2eh ;2eh-> 46 -> ,  
puntoComa EQU 3bh ;3bh-> 59 -> ;
espacio EQU 20h;20h->32 -> espacio en blanco  
finRutaFichero EQU 0h ;0h-> 0 -> 0 
finCadena EQU 24h ;24h-> 36 -> $
teclaMinusculaA EQU 61h; 61h -> 91 -> "a"
teclaMinusculaD EQU 64h; 64h -> 91 -> "d"
teclaMinusculaP EQU 70h; 70h-> 112 -> "p"

;Dimensiones y longitudes:
dimensionLectorTeclado EQU 14h; 20D 
dimensionLectorFicheros EQU 7d0h;2000D 
dimensionEscritorFicheros EQU 7d0h;2000D 
longMaxUsuario EQU 07h;7 caracteres máximo
longMaxPass EQU 04h;4 digitos fijos  

;indicadores
permisoLecturaEscritura EQU 02h; 2 hace referencia a ese modo de acceso en ficheros 
modoEstandar EQU 00h; 0 hace referencia a ese modo o tipo estándar en ficheros 
cantidadSeparacion EQU 15 ;sirve como cuenta para los espacios sepradores en los reportes
inicioAsciiDigito EQU 0030h; es el 0 decimal en ascii
finAsciiDigito EQU 003ah; se tomará como representación del 10 decimal en ascii
diferenciaASCII EQU 30h ; es la diferencia de un número a su verdadero ascci
modoVideoGrafico EQU 13h ;13h -> 19 ->320 x 200 de resolución y 256 colores
modoTextoEstandar EQU 03h ;03h -> 3 -> Establece el modo texto (se usa para regresar del modo video) 80x25. 16 colores. 8 paginas.
direccionBaseMemoriaGrafica EQU 0A000h; Sirve para establecwer a DS la dir. de memoria gráfica y optimizar mejor los resultados proyectados en pantalla 1 página

;indicadores de juego:
pixelesTotales EQU 0FA00h; 64,000 pixeles en ese modo de resolución 320 * 200
tamanioFila EQU 320 ;el tamaño de fila es de 320 columnas en el modo video 13h, se emplea para ubicar la matriz linealizada/mapeada en memoria
alturaBloque EQU 5 ;Es el número de lineas que formasn un bloque
anchoBloque EQU 20 ;Es lunmero de pixeles en columna que forman el bloque
alturaPelota EQU 3 ;Es el número de lineas que formasn una pelota
posicionBaseBarraGrafica EQU 175 ;fila base desde donde se generará la barra hacia arriba
indicadorJuegoActivo EQU 01h; indicará activad del juego (se esta jugando)
indicadorJuegoInactivo EQU 00h; indicará inactivad del juego (no se esta jugando)
indicadorPartidaGanada EQU 01h; indicará que superó todos los niveles del juego
indicadorPartidaPerdida EQU 00h; indicará que perdió la partida, sin importsar en que nivel
indicadorBloqueEliminado EQU 01h; indicará que un bloque ya se eliminó, evita evaluaciones innecesarias y aumenta la fluidez de la ejecución
indicadorBloqueActivo EQU 00h;
extensorPlataforma EQU 3; sirve como base para un iterador que permite mover mas veces la plataforma por milisegundo y dar asi mayopr velocidad a la misma

;Coordenadas Base:
posMargenMinimoVertical EQU 5 ;columna donde se ubica el margen minimo vertical
posMargenMinimoHorizontal EQU 19 ;fila donde se ubica el margen minimo horizontal
posMargenMaximoVertical EQU 314 ;columna donde se ubica el margen maximo vertical
posMargenMaximoHorizontal EQU  194 ;fila donde se ubica el margen másimo horizontal
longitudMargenVertical EQU 175 ;num de pixeles
longitudMargenHorizontal EQU 310;num de pixeles
posFilaInicialPlataforma EQU 185 ;fila de inicio plataforma
posColumnaInicialPlataforma EQU 125 ;columna de inicio Plataforma
posFilaInicialPelota EQU 180; fila donde inica la pelota en el juego
posColumnaInicialPelota EQU 150; fila donde inica la pelota en el juego

;direcciones de pelota
direccionNoresteActiva EQU 00h; representación activa de Noreste
direccionNoroesteActiva EQU 01h; representación activa de Noreste
direccionSuresteActiva EQU 02h; representación activa de Noreste
direccionSuroesteActiva EQU 03h; representación activa de Noreste

;Coordenadas de Titulos en Modo video:
filaEstandarImpresionVideo EQU 1; sobre esa fila se imprimirán todos los datos del nivel
columnaNombreJugador EQU 1 ; ubicación del nombre del jugador actual en el juego
columnaTituloNivel EQU 10; ubicación del titulo
columnaValorNivel EQU 16 ; ubicación del valor del nivel
columnaPuntajeActual EQU 25;ubicación de los puntos actuales
columnaRelojTiempo EQU 33 ;ubicación del reloj que indica el tiempo en el juego
columnaNombreOrdenamiento EQU 1 ; ubicación del nombre del ordenamiento actual del gráfico
digitosMaximosEvaluacion EQU 3 ; dado que solo se aceptan como maximo centenas (999)  para elmanejo de resultados, se establece 3 digitos como máximo
  
;=== COLORES EQUIVALENTES === 
colorBlancoGrafico EQU 0fh
colorRojoGrafico EQU 28h
colorAmarilloGrafico EQU 0eh
colorVerdeGrafico EQU 2eh
colorCelesteGrafico EQU 4eh
colorPielGrafico EQU 5ah
colorAzulGrafico EQU 21h
colorNegroGrafico EQU 00h

;=== INTERRUPCIONES EQUIVALENTES === 
subFuncionLeerCaracter EQU 01h ;01h -> 1 -> Entrada de caracter con salida
subFuncionVerCadena EQU 09h ;09h -> 9 -> Visualización de una cadena de caracteres   
subFuncionCrearFichero EQU 3ch ;3ch -> 60 -> Crear Fichero
subFuncionAbrirFichero EQU 3dh ;3dh -> 61 -> Abrir Fichero  
subFuncionCerrarFichero EQU 3eh; 3eh-> 62 -> Cerrar Archivo
subFuncionLeerFichero EQU 3fh ;3fh -> 63 -> Lectura de Fichero o dispositivo
subFuncionAdjuntarInfoFichero EQU 40h ;40h -> 64 -> Escritura(Adjuntada) en Fichero o dispositivo.
subFuncionLimpiezaBuffer EQU 0Ch; 0ch -> 12 -> limpia el buffer y permite asiganr una función en AL 
subFuncionTiempoSistema EQU 2ch ;2ch -> 44 -> Obtiene la hora del sustema y guarda en los registros sus distnots valores 
subFuncionFinPrograma EQU 4ch ;4ch -> 76 -> Terminación de Programa con Código de Retorno 
funcionesDOS EQU 21h ;21h -> 33 -> petición de función al DOS 

subFuncionModoVideo EQU 00h ;00h->0->Establecer modo de video
subFuncionObtenerColor EQU  0DH ;0DH 13 obtiene el color del pixel en modos de video
funcionesDespligueVideo EQU 10h ;10h -> 16 -> funciones de modo gráfico o video

subFuncionSolicitudTeclado EQU 00h;1h -> 1 -> guarda la tecla ingresada por teclado en AL
subFuncionEstadoTeclado EQU 01h;10h -> 16 -> verifica el estado del teclado para ver si se ingresaron teclas o no mediante el valor de CF(carry flag)
funcionesTeclado EQU 16h ;16h -> 22 ->  Servicios de Entrada y Salida de teclado
   
;=== VECTORES ===            
lectorEntradaTeclado db 20 dup(finCadena); llenamos el vector de $ y agregamos un final de cadena
lectorEntradaFicheros db 2000 dup(finCadena)
escritorFicheroActual db 2000 dup(finCadena);
lectorEntradaUsuario db 20 dup(finCadena);
lectorEntradaPass db 20 dup(finCadena);
lectorEntradaTop db 20 dup(finCadena)
lectorEntradaOrden db 20 dup(finCadena)
lectorEntradaOrdenamiento db 20 dup(finCadena);
lectorEntradaVelocidad db 20 dup(finCadena) 
visorNivel db 2 dup(finCadena) 
tiempoEstable db 0,0,0,finCadena; el tiempo que se registra en los ficheros
;Dado que son para el modo video, necesitamos reflejar "0:00" y "000pts", pero ya que necesitamos usar valores 
;numéricos dado que cambiarán con el tiempo, entonces se agrega con la diferencia ascii (30h) pero para que los
;caracteres cuadren se busco el simbolo que se necesitaba y se le resto 48 en cuanto a ascii, es por eso el uso de 
;saltoLn para ":", de @ para "p", de "D" para t y de "C" pata s 
visorReloj db 0,saltoLn,0,0, finCadena ;0:00
visorPuntos db 0,0,0,'@','D','C',finCadena  ;000pts 
;Arreglos para ordenamientos:
puntajesDesordenados db 2000 dup(finCadena) 
tiemposDesordenados db 2000 dup(finCadena)
auxiliarDeCambioDigito db 10 dup(finCadena) 
auxiliarDeCambioContenidoFila db 200 dup(finCadena) 
  
;Rutas ejecutando desde DosBox:
nombreArchivoJugadores db 'B\Gamers.txt',finRutaFichero ;En emu8086 es 'C:\B\Gamers.txt',finRutaFichero
nombreArchivoPartidas db 'B\Rounds.txt',finRutaFichero  ;En emu8086 es 'C:\B\Rounds.txt',finRutaFichero
nombreReportePuntajes db 'B\Puntos.rep',finRutaFichero  ;En emu8086 es 'C:\B\Puntos.txt',finRutaFichero
nombreReporteTiempos db 'B\Tiempo.rep',finRutaFichero   ;En emu8086 es 'C:\B\Tiempo.txt',finRutaFichero
nombreArchivoAdmins db 'B\Admins.txt',finRutaFichero     ;En emu8086 es 'C:\B\Asmins.txt',finRutaFichero
controladorFicheros dw ?      

;=== CADENAS PARA MENSAJES EN CONSOLA ===    
;=== SEPARADORES ===                                      
tituloJuego db saltoLn,retornoCR,'!@!@!@!@!@!@! ASM BALL BREAKER !@!@!@!@!@!@!@!@!',saltoLn,retornoCR,finCadena 
lineaSeparadora db saltoLn,retornoCR,'!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!',saltoLn,retornoCR,finCadena  

;===   DATOS   ===
datosCurso db saltoLn,retornoCR, 'Universidad de San Carlos de Guatemala', saltoLn,retornoCR,'Facultad de Ingenier',ItildadaMinus,'a', saltoLn,retornoCR,'Arquitectura de Computadores y Ensambladores 1', saltoLn,retornoCR,'Segundo Semestre 2020', saltoLn,retornoCR,'Secci',OtildadaMinus,'n: A', saltoLn,retornoCR,'Proyecto 2', saltoLn,retornoCR,finCadena                                                                                 
misDatos db saltoLn,retornoCR,tabulador,'Byron Gerardo Castillo G',OtildadaMinus,'mez',saltoLn,retornoCR,tabulador,tabulador,'20170544',finCadena

;===   ALERTAS   ===  
debug db 'Punto Debug',saltoLn,retornoCR,finCadena   
bienvenidaAdmin db saltoLn,retornoCR,'@: BIENVENIDO ',finCadena
inicioJuego db saltoLn,retornoCR,'Iniciando Partida...',saltoLn,retornoCR,finCadena 
finJuego db saltoLn,retornoCR,'fin de Partida...',saltoLn,retornoCR,finCadena       
salidaJuego db saltoLn,retornoCR,'Saliendo del Juego...',saltoLn,retornoCR,'JUEGO TERMINADO  :)',finCadena
opcionErronea db saltoLn,retornoCR,'La opci',OtildadaMinus,'n ingresada no es correcta',saltoLn,retornoCR,'Debe ingresarla nuevamente:',saltoLn,retornoCR,finCadena 
usuarioAccedido db saltoLn,retornoCR,'Usuario reconocido, accediendo...',saltoLn,retornoCR,finCadena    
usuarioRegistrado db saltoLn,retornoCR,'Usuario registrado, ya puede utilizarlo para jugar',saltoLn,retornoCR,finCadena 
usuarioErroneo db saltoLn,retornoCR,'El usuario no existe!!',saltoLn,retornoCR,finCadena
usuarioEnUso db saltoLn,retornoCR,'El usuario ya existe, elija uno nuevo!!',saltoLn,retornoCR,finCadena
passErroneo db saltoLn,retornoCR,'El pass es incorrecto!!',saltoLn,retornoCR,finCadena 
passNoNumerico db saltoLn,retornoCR,'El pass no es del todo numérico!!',saltoLn,retornoCR,finCadena  
usuarioMaxError db saltoLn,retornoCR,'El usuario ingresado sobrepasa el max(7) de caracteres',saltoLn,retornoCR,finCadena
passMaxError db saltoLn,retornoCR,'Pass incorrecto, la longitud puede que no sea la esperada(4) o no sea numérica',finCadena
velocidadErronea db saltoLn,retornoCR,'La velocidad ingresada es incorrecta',saltoLn,retornoCR,finCadena
aperturaArchivoErronea db saltoLn,retornoCR,'Se produjo un fallo al tratar de abrir el fichero',saltoLn,retornoCR,finCadena
lecturaArchivoErronea db saltoLn,retornoCR,'Se produjo un fallo al tratar de leer el fichero',saltoLn,retornoCR,finCadena 
tituloTopPuntajes db saltoLn,retornoCR,'!#!#!#!#!#!#!#! TOP 10 PUNTAJES !#!#!#!#!#!#!#!',saltoLn,retornoCR,finCadena
tituloTopTiempos db saltoLn,retornoCR,'!#!#!#!#!#!#!#! TOP 10 TIEMPOS !#!#!#!#!#!#!#!',saltoLn,retornoCR,finCadena

;================= MENSAJES DE FIN DE JUEGO ====================
gameOver db retornoCR,saltoLn,'---@@@@--@--@@@@@--@@@@--@@@@@-@--@--@@@@-@@@@'
         db retornoCR,saltoLn,'---@----@-@-@-@-@--@-----@---@ @--@--@----@--@'
         db retornoCR,saltoLn,'---@-@@-@@@-@-@-@--@@@@--@---@ @--@--@@@@-@@@@'
         db retornoCR,saltoLn,'---@--@-@-@-@-@-@--@-----@---@ @--@--@----@--@'
         db retornoCR,saltoLn,'---@@@@-@-@-@-@-@--@@@@--@@@@@--@@---@@@@-@--@',retornoCR,saltoLn,finCadena

partidaExitosa  db retornoCR,saltoLn,'---@@@@--@--@@@--@--@@-@@@-@@@--@--@'
                db retornoCR,saltoLn,'---@----@-@-@-@-@-@-@---@--@----@--@'
                db retornoCR,saltoLn,'---@-@@-@@@-@-@-@@@-@@--@--@@@--@--@'
                db retornoCR,saltoLn,'---@--@-@-@-@-@-@-@--@--@--@-------'
                db retornoCR,saltoLn,'---@@@@-@-@-@-@-@-@-@@--@--@@@--*--*',retornoCR,saltoLn,finCadena

;======== ALERTAS/TITULOS EN MODO VIDEO =======
debugVideo  db 'Debug',finCadena
tituloNivel  db 'Nivel:',finCadena
tituloBurbuja  db '#Bubble',finCadena
tituloQuick  db '#Quick',finCadena
tituloShell  db '#Shell:',finCadena

;=== SOLICITUDES ===    
solicitudUsuario db saltoLn,retornoCR,'Ingrese el usuario:',saltoLn,retornoCR,finCadena   
solicitudPass db saltoLn,retornoCR,'Ingrese el Pass:',saltoLn,retornoCR,finCadena
solicitudVelocidad db saltoLn,retornoCR,'Ingrese la velocidad(0-9):',saltoLn,retornoCR,finCadena

;=== MENUS DE SELECCIÓN ===
menuPrincipal db saltoLn,retornoCR,'!#!#!#!#!#!#! MENU PRINCIPAL !#!#!#!#!#!#!#!#!',saltoLn,retornoCR
              db '(1)->Ingresar al Juego.',saltoLn,retornoCR
              db '(2)->Registrar Usuario.',saltoLn,retornoCR
              db '(3)->Salir del Juego.',saltoLn,retornoCR,saltoLn
              db 'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena
              
menuIngreso db saltoLn,retornoCR,'!#!#!#!#!#!#! INGRESO: !#!#!#!#!#!#!#!#!',saltoLn,retornoCR,finCadena
menuRegistro db saltoLn,retornoCR,'!#!#!#!#!#!#! REGISTRO: !#!#!#!#!#!#!#!#!',saltoLn,retornoCR,finCadena
menuTops db saltoLn,retornoCR,'!#!#!#!#!#!#! MENU TOPS !#!#!#!#!#!#!#!#!',saltoLn,retornoCR
         db '(1)->Ver Top 10 Puntajes.',saltoLn,retornoCR
         db '(2)->Ver Top 10 Tiempos.',saltoLn,retornoCR
         db '(3)->Regresar.',saltoLn,retornoCR,saltoLn
         db 'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena
         
menuOrdenamientos db saltoLn,retornoCR,'!#!#!#!#!#!#! ORDENAMIENTOS !#!#!#!#!#!#!#!#!',saltoLn,retornoCR
                  db '(1)->Bubble Sort.',saltoLn,retornoCR
                  db '(2)->Quick Sort.',saltoLn,retornoCR
                  db '(3)->Shell Sort.',saltoLn,retornoCR,saltoLn
                  db 'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena     
                  
menuOrden db saltoLn,retornoCR,'!#!#!#!#!#!#! ORDEN !#!#!#!#!#!#!#!#!',saltoLn,retornoCR 
                  db '(1)->Ascendente.',saltoLn,retornoCR
                  db '(2)->Descendente.',saltoLn,retornoCR
                  db 'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena

;=== ESTRUCTURAS ===
Orientador STRUC
   puntoInicialTop db ?
   puntoFinalTop db ?
Orientador ENDS 
;Guarda los limites que se usan en los reportes de tops  

Configurador STRUC
   jugadorActual db ?
   nivelActual db ?
   bloquesGenerados db ?
   tiempoActualMilis db ?; sirve para evaluar cosas cada milisegundo
   tiempoActualSegs db ?; sirve para evaluar cosas cada segundo
   estadoJuego db ?; 00h juego inactivo, 01h juego activo
   estadoPartida db ?; 00h partiuda perdida, 01h partida ganada
   controladorBloque db ? 
Configurador ENDS 
;Guarda toda la configuracio´n de los niveles del Ball Breaker

;Graficador STRUC
;   velocidad db ?
;   tiempo db ?
;   nombreOrdenamiento db ?
;Graficador ENDS 


Graficador STRUC
   cuentaPuntajesActuales db ?
   cuentaTiemposActuales db ?
Graficador ENDS
;Guarda toda la configuracio´n par al animación de oso gráficos de ordenamientos



ElementoGrafico STRUC
   pixelesAncho dw ?
   pixelesAlto dw ?
   filaActual dw ?
   columnaActual dw ?
   colorActual db ?
   estadoDireccion db ? ;00h noreste,01h noroeste, 02h sureste, 03h suroeste 
ElementoGrafico ENDS 
;Guarda toda la información referente a la barra de gráficos

BarraOrdenDinamica ElementoGrafico <20, 40, posicionBaseBarraGrafica, 15, colorCelesteGrafico, direccionSuresteActiva>

plataformaMovible ElementoGrafico <50, alturaBloque, posFilaInicialPlataforma, posColumnaInicialPlataforma, colorBlancoGrafico, direccionSuresteActiva>

pelota ElementoGrafico <5, alturaPelota, posFilaInicialPelota, posColumnaInicialPelota, colorPielGrafico, direccionNoroesteActiva>

;pelota ElementoGrafico <5, alturaBloque, posFilaInicialPelota, 50, colorPielGrafico, direccionNoroesteActiva>


;orientacionGeneral Orientador <0030h, 0039h>

;================== SEGMENTO DE CODIGO ===========================
.code 
    call establecerSegmentoDatos

    ;========================= MAIN ==============================================

	main proc 
	    IniciarPrograma:
		    mostrarEncabezado
		    menuInicial:
			    mostrarMenuPrincipal
			    LecturaPrincipal:               
			        obtenerLecturaTeclado lectorEntradaTeclado
			        cmp cl,1 ;Si la longitud de entrada es 1 puede ser una opción valida 
			        je distribuirSubMenuPrincipal ;se manda a validar la opción
			    ErrorEntradaPrincipal:
			        imprimirEnConsola opcionErronea
			        jmp LecturaPrincipal
		seccionIngreso:
		    imprimirEnConsola menuIngreso   
	        verificarIngreso   
		seccionRegistro:
		    imprimirEnConsola menuRegistro 
		    verificarRegistro
		    jmp  menuInicial 
		seccionTops:
             obtenerLecturaOpcionTop             
		iniciarJuego:
		    imprimirEnConsola inicioJuego 
            call establecerValoresInicialesPartida
            call establecerModoVideo
            call pintarPrimerNivel
            call establecerModoTexto
            ;finalizarJuego
		    cmp DS:[Configurador.estadoPartida], indicadorPartidaGanada
            je  notificarJugadaExitosa
            jmp notificarGameOver   
		Salir: 
			salirPrograma  
	    distribuirSubMenuPrincipal:  
            MOV cl,0; reiniciamos el contador para futuras ocasiones  
            subMenusPrincipal:             
                cmp lectorEntradaTeclado[0],'1'
                je  seccionIngreso 
                cmp lectorEntradaTeclado[0],'2'
                je  seccionRegistro 
                cmp lectorEntradaTeclado[0],'3'
                je  Salir 
                MOV dl, 0 
                reiniciarLectorTeclado dl  
                JMP ErrorEntradaPrincipal 
        errorLecturaArchivo:  
            imprimirEnConsola lecturaArchivoErronea
            jmp  menuInicial      
        errorAperturaArchivo: 
            imprimirEnConsola aperturaArchivoErronea
            jmp  menuInicial
        notificarGameOver:
            imprimirEnConsola gameOver
            jmp menuInicial
        notificarJugadaExitosa:
            imprimirEnConsola partidaExitosa
            jmp menuInicial
	main endp

    ;==================    PROCEDIMIENTOS:    ============================

    ;========== ASIGNACIÓN DE DIRECCIONES ========================

    establecerSegmentoDatos proc
        PUSH DX
        asignarDIreccionDatos:
            MOV dx,@data ; Dirección del segmento de datos para poder acceder a las variables
            MOV ds,dx 
        POP DX
        ret 
    establecerSegmentoDatos endp

    establecerDireccionVideo proc
        PUSH AX
        MOV ax, direccionBaseMemoriaGrafica 
        MOV ds,ax 
        POP AX
        ret
    establecerDireccionVideo endp  
    
    establecerModoVideo proc
        PUSH AX
        asignarDIreccionDatos:
            MOV ax, modoVideoGrafico
            int funcionesDespligueVideo
            MOV ax, direccionBaseMemoriaGrafica 
            MOV ds,ax
        POP AX 
        ret 
    establecerModoVideo endp

    establecerModoTexto proc
        asignarDIreccionDatos:
            MOV ax, 0003h
            int funcionesDespligueVideo
            MOV dx, @data 
            MOV ds,dx  
        ret 
    establecerModoTexto endp

    establecerValoresInicialesPartida proc
        MOV DS:[Configurador.tiempoActualMilis],0 ;evaluaciones por milisegundo
        MOV DS:[Configurador.tiempoActualSegs],0 ;evaluaciones por segundo
        MOV DS:[Configurador.nivelActual],1 
        MOV DS:[Configurador.estadoJuego], indicadorJuegoActivo
        MOV DS:[Configurador.estadoPartida], indicadorPartidaPerdida
        MOV pelota.filaActual, posFilaInicialPelota
        MOV pelota.columnaActual, posColumnaInicialPelota
        MOV plataformaMovible.filaActual, posFilaInicialPlataforma
        MOV plataformaMovible.columnaActual, posColumnaInicialPlataforma
        MOV pelota.estadoDireccion, direccionNoroesteActiva
        call reiniciarCronometro
        call reiniciarTiempo
        call reiniciarPuntajeJuego
        ret 
    establecerValoresInicialesPartida endp
        
    cambiarNivel proc
        MOV DS:[Configurador.tiempoActualMilis],0 ;evaluaciones por milisegundo
        MOV DS:[Configurador.tiempoActualSegs],0 ;evaluaciones por segundo
        inc DS:[Configurador.nivelActual]
        MOV DS:[Configurador.estadoJuego], indicadorJuegoActivo
        MOV DS:[Configurador.estadoPartida], indicadorPartidaPerdida
        ;Debemos regresar la pelota a su lugar, ya que se encuntra n el ounto de "fin de juego"
        MOV pelota.filaActual, posFilaInicialPelota
        MOV pelota.columnaActual, posColumnaInicialPelota
        MOV pelota.estadoDireccion, direccionNoroesteActiva
        call establecerDireccionVideo
        limpiarEscenario
        ret
    cambiarNivel endp



    ;================= PUNTADO DE ELEMENTOS DEL JUEGO ==============

    dibujarMarcoGrafico proc
        dibujarContornosVerticales
        dibujarContornosHorizontales
        ret
    dibujarMarcoGrafico endp 

        
    pintarPrimerNivel proc
        call dibujarMarcoGrafico
        call dibujarPlataforma
        call dibujarPelotaEstandar
        dibujarCaparazon
        call imprimirDatosDeNivel
        call solicitarTeclaEspacio
        chequearCambios 
        cmp  DS:[Configurador.estadoJuego],indicadorPartidaGanada
        je subirNivel
        cmp  DS:[Configurador.estadoPartida],indicadorPartidaPerdida
        je regresarMenuPrincipal
        subirNivel:
            call cambiarNivel
            call pintarSegundoNivel
        regresarMenuPrincipal:
            ret ;si pierde alguno de los niveles regresa al menu principal
    pintarPrimerNivel endp

    pintarSegundoNivel proc
        call establecerDireccionVideo
        call dibujarMarcoGrafico
        call dibujarPlataforma
        call dibujarPelotaEstandar
        dibujarCaparazon
        call imprimirDatosDeNivel
        call solicitarTeclaEspacio
        chequearCambios 
        cmp  DS:[Configurador.estadoJuego],indicadorPartidaGanada
        je subirNivel
        cmp  DS:[Configurador.estadoPartida],indicadorPartidaPerdida
        je regresarMenuPrincipal
        subirNivel:
            call cambiarNivel
            call pintarTercerNivel
        regresarMenuPrincipal:
            ret ;si pierde alguno de los niveles regresa al menu principal
    pintarSegundoNivel endp

    pintarTercerNivel proc
        call dibujarMarcoGrafico
        call dibujarPlataforma
        call dibujarPelotaEstandar
        dibujarCaparazon
        call imprimirDatosDeNivel
        call solicitarTeclaEspacio
        chequearCambios  ;aqui no se compaan los estados dado que es el ultimo nivel, siempre saldrá del juego
        regresarMenuPrincipal:
            ret ;si pierde alguno de los niveles regresa al menu principal
    pintarTercerNivel endp

    pintarEscenario proc
        call establecerModoVideo; aqui si es necesario para el grasfico de ordenamientos
        call dibujarMarcoGrafico 
        call imprimirRelojDeTiempo
        cmp lectorEntradaOrdenamiento[0], '1'
        je imprimirBurbuja
        cmp lectorEntradaOrdenamiento[0], '2'
        je imprimirQuick
        cmp lectorEntradaOrdenamiento[0], '3'
        je imprimirShell
        imprimirBurbuja:
            call establecerSegmentoDatos
            MOV cx, offset tituloBurbuja
            call imprimirTituloOrdenamiento
            jmp pedirTecla
        imprimirQuick:
            call establecerSegmentoDatos
            MOV cx, offset tituloQuick
            call imprimirTituloOrdenamiento
            jmp pedirTecla
        imprimirShell:
            call establecerSegmentoDatos
            MOV cx, offset tituloShell
            call imprimirTituloOrdenamiento
            jmp pedirTecla
        ;debemos dibujar las barras
        ;imprimirBarras:
        pedirTecla:
            ; esperar por tecla
            mov ah,10h
            int 16h  
        call establecerSegmentoDatos
        ret
    pintarEscenario endp



    dibujarPlataforma proc
        call establecerSegmentoDatos
        MOV di, plataformaMovible.pixelesAncho ; las lineas horizontales de la plataforma tendran 40 pixeles de longitud
        MOV dl, plataformaMovible.colorActual
        MOV ax, plataformaMovible.filaActual
        MOV bx, plataformaMovible.columnaActual
        call establecerDireccionVideo
        dibujarBloque
        call establecerSegmentoDatos
        ret
    dibujarPlataforma endp

    borrarPlataformaActual proc
        call establecerSegmentoDatos
        MOV di, plataformaMovible.pixelesAncho ; las lineas horizontales de la plataforma tendran 40 pixeles de longitud
        MOV ax, plataformaMovible.filaActual
        MOV bx, plataformaMovible.columnaActual
        call establecerDireccionVideo
        borrarBloque
        call establecerSegmentoDatos
        ret
    borrarPlataformaActual endp

    dibujarPelotaEstandar proc
        call establecerSegmentoDatos
        MOV di, pelota.pixelesAncho ; 
        MOV dl, pelota.colorActual
        MOV ax, pelota.filaActual  
        MOV bx, pelota.columnaActual
        call establecerDireccionVideo
        dibujarPelota
        call establecerSegmentoDatos
        ret
    dibujarPelotaEstandar endp

    borrarPelotaActual proc
        call establecerSegmentoDatos
        MOV di, pelota.pixelesAncho ; 
        MOV ax, pelota.filaActual  
        MOV bx, pelota.columnaActual
        call establecerDireccionVideo
        borrarBloque
        call establecerSegmentoDatos
        ret
    borrarPelotaActual endp

    ;barraDib proc
    ;    call dibujarMarcoGrafico
    ;    probarBarra
    ;    ret
    ;barraDib endp

    ;========================== SOLICITUDES DE TECLADO ================;

    solicitarTeclaEspacio proc
        PUSH AX
        pedirTecla:
            ; esperar por tecla
            mov ah,subFuncionSolicitudTeclado
            int funcionesTeclado
            cmp al, espacio ;AL actualmente posee el ascii de la tecla ingresada
            je retornar
            jmp pedirTecla 
        retornar:  
            POP AX
            ret
    solicitarTeclaEspacio endp

    limpiarBufferEntradaTeclado proc
    ;Normalemnte a al se le asigna un función, como en este caso solo buscamos limpiar el buffer no se le asigna nada
        PUSH AX
        MOV ah, subFuncionLimpiezaBuffer
        int funcionesDOS
        POP AX
        ret
    limpiarBufferEntradaTeclado endp

    ;====================== MOVIMIENTOS ===========================

    moverLadoIzquierdoPlataforma proc
        PUSH CX
        moverIzquierda:
            call borrarPlataformaActual
            call establecerSegmentoDatos
            dec  plataformaMovible.columnaActual
            call establecerDireccionVideo
            call dibujarPlataforma
            call establecerSegmentoDatos
        fin:    
            POP CX    
            ret
    moverLadoIzquierdoPlataforma endp  

    moverLadoDerechoPlataforma proc
        PUSH CX
        moverDerecha:
            call borrarPlataformaActual
            call establecerSegmentoDatos
            inc  plataformaMovible.columnaActual
            call establecerDireccionVideo
            call dibujarPlataforma
            call establecerSegmentoDatos
        fin: 
            POP CX   
            ret
    moverLadoDerechoPlataforma endp  

    obtenerColorPixel proc
        MOV AH,subFuncionObtenerColor  
        MOV BH, 00h; La única página que se utiliza
        int funcionesDespligueVideo
        ret
    obtenerColorPixel endp

    obtenerColorPorMatrizControl proc
        ; cx debe tener la columna y dx la fila a verificar por mapeo
        ;PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        obtenerColorPosicion:
            MOV ax, dx; ax recibe la fila actual
            MOV bx, tamanioFila
            mul bx
            add ax, cx; ax es sumado con la columna actual
            MOV di, ax; lo asignamos a DI para usarlo como indice de busqueda
            call establecerDireccionVideo
            MOV al, [di] ; AL recibe el color de ese pixel
        regresarValoresOriginales:
            POP DI
            POP DX
            POP CX
            POP BX
            ;POP AX
            ret
    obtenerColorPorMatrizControl endp

    destruirBloqueDesdeOrigen proc
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        ;call establecerDireccionVideo
        desplazarmeIzquierda:
            dec cx
            ;call obtenerColorPixel
            call obtenerColorPorMatrizControl
            ;call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            je restablecerColumnaUtil
            jmp desplazarmeIzquierda
        restablecerColumnaUtil:
            inc cx
        elevarFila:
            ;call establecerDireccionVideo
            dec dx
            ;call obtenerColorPixel
            call obtenerColorPorMatrizControl
            ;call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            je restablecerFilaUtil
            cmp al, pelota.colorActual
            je restablecerFilaUtil
            jmp elevarFila
        restablecerFilaUtil:
            inc dx 
        destruirBloque:
            call establecerDireccionVideo
            MOV di, anchoBloque ; las lineas horizontales de la plataforma tendran 40 pixeles de longitud
            MOV ax, dx  
            MOV bx, cx
            ;MOV dl, colorNegroGrafico
            borrarBloque
            ;dibujarBloque
            call establecerSegmentoDatos
            call incrementarPuntos
            call decrecerBloquesDestruibles
            call verificarPasoDeNivel
            MOV DS:[Configurador.controladorBloque], indicadorBloqueEliminado
            ;call alternarRebote   
            POP DI
            POP DX
            POP CX
            POP BX
            POP AX
            ret
    destruirBloqueDesdeOrigen endp

    verificarReboteNoDestructivo proc
        PUSH DX
        PUSH CX
        cmp pelota.estadoDireccion, direccionNoresteActiva
        je noEvaluar
        cmp pelota.estadoDireccion, direccionNoroesteActiva
        je noEvaluar
        verificarColor:
            MOV DX, pelota.filaActual
            ADD DX, pelota.pixelesAlto
            ADD DX, 2 ;espaciado para evitar desfase de choque
            MOV CX, pelota.columnaActual
            call obtenerColorPorMatrizControl
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            je noEvaluar
            cmp dx, posFilaInicialPlataforma
            jne noEvaluar
            call alternarReboteVertical
        noEvaluar:
            POP CX
            POP DX
            ret
    verificarReboteNoDestructivo endp

    delimitarSecuenciaDestruccionBloques proc
        call verificarReboteNoDestructivo ;verifica el rebote de la plataforma
        restringirDestruccionLimites:
            MOV dx, posMargenMinimoVertical
            inc dx; si estuviera uno antes/a la par del margen minimo vertical se restringe
            cmp pelota.columnaActual, dx
            je destruccionFinalizada
            MOV dx, posMargenMaximoVertical
            sub dx, pelota.pixelesAncho
            ;inc dx; si estuviera uno antes/a la par del margen maximo vertical se restringe
            cmp pelota.columnaActual, dx
            je destruccionFinalizada
            MOV dx, posMargenMinimoHorizontal
            inc dx; si estuviera uno antes/por debajo del margen minimo horizontal se restringe
            cmp pelota.filaActual, dx
            je destruccionFinalizada
            MOV dx, posMargenMaximoHorizontal
            SUB dx, pelota.pixelesAlto ; la altura ocuoa espacio antes de que llegue exactamente a esa fila
            dec dx; si estuviera uno antes/por endima  del margen maximo horizontal se restringe
            cmp pelota.filaActual, dx
            je verificarFinalizacionJuego
        verificarDestruccionPorEsquinas:
           ;call evaluarChoqueEsquinas
           cmp DS:[Configurador.controladorBloque], indicadorBloqueEliminado
           je destruccionFinalizada
        verificarDestruccionVertical:
            evaluarRebotesVerticalesDestructivos
            ;call establecerSegmentoDatos
            cmp DS:[Configurador.controladorBloque], indicadorBloqueActivo
            je verificarDestruccionHorizontal
            call alternarReboteVertical
            jmp destruccionFinalizada
        verificarFinalizacionJuego:
            ;call establecerSegmentoDatos
            MOV DS:[Configurador.estadoJuego], indicadorJuegoInactivo ;cambiar esot a INACTIVO finaliza el ciclo evaluativo que controla el nivel
            MOV DS:[Configurador.estadoPartida], indicadorPartidaPerdida
        verificarDestruccionHorizontal:
            evaluarRebotesHorizontalesDestructivos
            ;call establecerSegmentoDatos
            cmp DS:[Configurador.controladorBloque], indicadorBloqueActivo
            je destruccionFinalizada
            call alternarReboteHorizontal
        destruccionFinalizada:
            ;call establecerSegmentoDatos
            MOV DS:[Configurador.controladorBloque], indicadorBloqueActivo
            ret
    delimitarSecuenciaDestruccionBloques endp 

    alternarReboteVertical proc
        ;dependiendo donde este actualmente dirigida la pelota entonces se asigna su nueva
        ;orientación consecuente al rebote
        cmp pelota.estadoDireccion, direccionNoresteActiva
        je orientarSureste
        cmp pelota.estadoDireccion, direccionNoroesteActiva
        je orientarSuroeste
        cmp pelota.estadoDireccion, direccionSuresteActiva
        je orientarNoreste
        cmp pelota.estadoDireccion, direccionSuroesteActiva
        je orientarNoroeste
        orientarNoreste:
             MOV pelota.estadoDireccion, direccionNoresteActiva
             jmp finOrientacion
        orientarNoroeste:
             MOV pelota.estadoDireccion, direccionNoroesteActiva
             jmp finOrientacion
        orientarSureste:
             MOV pelota.estadoDireccion, direccionSuresteActiva
             jmp finOrientacion
        orientarSuroeste:
             MOV pelota.estadoDireccion, direccionSuroesteActiva
             jmp finOrientacion
        finOrientacion:
            ret
    alternarReboteVertical endp

    alternarReboteHorizontal proc
        ;dependiendo donde este actualmente dirigida la pelota entonces se asigna su nueva
        ;orientación consecuente al rebote
        cmp pelota.estadoDireccion, direccionNoresteActiva
        je orientarNoroeste
        cmp pelota.estadoDireccion, direccionNoroesteActiva
        je orientarNoreste
        cmp pelota.estadoDireccion, direccionSuresteActiva
        je orientarSuroeste
        cmp pelota.estadoDireccion, direccionSuroesteActiva
        je orientarSureste
        orientarNoreste:
             MOV pelota.estadoDireccion, direccionNoresteActiva
             jmp finOrientacion
        orientarNoroeste:
             MOV pelota.estadoDireccion, direccionNoroesteActiva
             jmp finOrientacion
        orientarSureste:
             MOV pelota.estadoDireccion, direccionSuresteActiva
             jmp finOrientacion
        orientarSuroeste:
             MOV pelota.estadoDireccion, direccionSuroesteActiva
             jmp finOrientacion
        finOrientacion:
            ret
    alternarReboteHorizontal endp

    ;  NO---------NE
    ;  |           |  
    ;  SO---------SE

    borrarBloqueDesdeEsquinaNoreste proc
        call establecerDireccionVideo
        SUB bx, anchoBloque ;se le resta el ancho, y daod que se pasa 1 posición
        inc bx ; se suma uno para estar en el punto exacto
        borrarBloque
        call establecerSegmentoDatos
        MOV DS:[Configurador.controladorBloque], indicadorBloqueEliminado
        ret
    borrarBloqueDesdeEsquinaNoreste endp

    borrarBloqueDesdeEsquinaNoroeste proc
        call establecerDireccionVideo
        borrarBloque
        call establecerSegmentoDatos
        MOV DS:[Configurador.controladorBloque], indicadorBloqueEliminado
        ret
    borrarBloqueDesdeEsquinaNoroeste endp
        
    borrarBloqueDesdeEsquinaSureste proc
        call establecerDireccionVideo
        SUB bx, anchoBloque
        inc bx;
        SUB ax, alturaBloque
        inc ax
        borrarBloque
        call establecerSegmentoDatos
        MOV DS:[Configurador.controladorBloque], indicadorBloqueEliminado
        ret
    borrarBloqueDesdeEsquinaSureste endp

    borrarBloqueDesdeEsquinaSuroeste proc
        call establecerDireccionVideo
        SUB ax, alturaBloque
        inc ax
        borrarBloque
        call establecerSegmentoDatos
        MOV DS:[Configurador.controladorBloque], indicadorBloqueEliminado
        ret
    borrarBloqueDesdeEsquinaSuroeste endp

    evaluarChoqueEsquinas proc
        call establecerSegmentoDatos
        MOV cx, pelota.columnaActual
        MOV dx, pelota.filaActual
        cmp pelota.estadoDireccion, direccionNoresteActiva
        je orientarSureste
        cmp pelota.estadoDireccion, direccionNoroesteActiva
        je orientarSuroeste
        cmp pelota.estadoDireccion, direccionSuresteActiva
        je orientarNoreste
        cmp pelota.estadoDireccion, direccionSuroesteActiva
        je orientarNoroeste
        orientarNoreste:
            dec cx; pixel arriba de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            jne finOrientacion
            inc dx ;pixel de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            je finOrientacion
            inc cx; pixel al costado derecho de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            jne finOrientacion
            dec cx ;regresamos a la esquina
            MOV ax, dx
            MOV bx, cx
            call borrarBloqueDesdeEsquinaNoreste
            ;call alternarRebote
            jmp finOrientacion
        orientarNoroeste:
            inc cx ;pixel arriba de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            jne finOrientacion
            inc dx ;pixel de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            je finOrientacion
            dec cx; pixel al costado izquierdo de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            jne finOrientacion
            inc cx ;regresamos al pixel de la esquina
            MOV ax, dx
            MOV bx, cx
            call borrarBloqueDesdeEsquinaNoroeste
            ;call alternarRebote
            jmp finOrientacion
        orientarSureste:
            dec cx ;pixel debajo de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            jne finOrientacion
            dec dx ;pixel de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            je finOrientacion
            inc cx; pixel al costado derecho de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            jne finOrientacion
            dec cx ;regresamos al pixel de la esquina
            MOV ax, dx
            MOV bx, cx
            call borrarBloqueDesdeEsquinaSureste
            ;call alternarRebote
            jmp finOrientacion
        orientarSuroeste:
            inc cx ;pixel abajo de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            jne finOrientacion
            dec dx ;pixel de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            je finOrientacion
            dec cx; pixel al costado izquierdo de la esquina
            call establecerDireccionVideo
            call obtenerColorPixel
            call establecerSegmentoDatos
            cmp al, colorNegroGrafico
            jne finOrientacion
            inc cx ;regresamos al pixel de la esquina
            MOV ax, dx
            MOV bx, cx
            call borrarBloqueDesdeEsquinaSuroeste
            ;call alternarRebote
            jmp finOrientacion
        finOrientacion:
            ret
    evaluarChoqueEsquinas endp

    ;======================== IMPRESIÓN DE TITULOS/CONTEIDO EN MODO VIDEO ======================

    imprimirDatosDeNivel proc
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        call imprimirJugador
        call imprimirTituloNivel
        call imprimirNivelActual
        call imprimirRelojDeTiempo
        call imprimirPuntajeAcumulado
        POP DX
        POP CX
        POP BX
        POP AX
        ret
    imprimirDatosDeNivel endp
    
    imprimirTituloNivel proc
        call establecerSegmentoDatos
        MOV DH, filaEstandarImpresionVideo ;fila del cursor
        MOV DL, columnaTituloNivel ;columna del cursor
        MOV cx,offset tituloNivel ;proporcionamos la dirección de desplazamiento
        call establecerDireccionVideo
        moverCursor
        call establecerSegmentoDatos
        MOV ah,subFuncionVerCadena; asignamos la subfunción de la interupción
        MOV dx,cx ;proporcionamos la dirección de desplazamiento
        int funcionesDOS
        ret
    imprimirTituloNivel endp

    imprimirNivelActual proc ;referente al vaor numperico del nivel actual
        call establecerSegmentoDatos
        MOV dl,  DS:[Configurador.nivelActual[0]]; esto es dado que solo queremos el primer elemento y los niveles no son mayores 10
        ADD dl, diferenciaASCII;tenemos el número de nivel, pero necesitmaos el ascii, por eso le sumamos 30h (48D) para que coincida
        MOV visorNivel[0], dl
        MOV cx,offset visorNivel[0] 
        MOV DH, filaEstandarImpresionVideo ;fila del cursor
        MOV DL, columnaValorNivel ;columna del cursor
        call establecerDireccionVideo
        moverCursor
        call establecerSegmentoDatos
        MOV ah,subFuncionVerCadena; asignamos la subfunción de la interupción
        MOV dx,cx ;proporcionamos la dirección de desplazamiento
        int funcionesDOS
        ret
    imprimirNivelActual endp

    imprimirJugador proc
        call establecerSegmentoDatos
        MOV DH, filaEstandarImpresionVideo ;fila del cursor
        MOV DL, columnaNombreJugador ;columna del cursor
        MOV cx, offset lectorEntradaUsuario
        call establecerDireccionVideo
        moverCursor
        call establecerSegmentoDatos
        MOV ah,subFuncionVerCadena; asignamos la subfunción de la interupción
        MOV dx,cx ;proporcionamos la dirección de desplazamiento
        int funcionesDOS
        ret
    imprimirJugador endp   

    imprimirRelojDeTiempo proc
        PUSH DX
        PUSH AX
        PUSH DI
        ;este proceso estará bastante activo en el juego, por eso se emplea la pila para evitar alterar otras subrutinas
        ;los demas no lo tiene dado que solo se usan al generar el nivel
        call establecerSegmentoDatos
        MOV DH, filaEstandarImpresionVideo ;fila del cursor
        MOV DL, columnaRelojTiempo ;columna del cursor
        MOV CX, offset visorReloj
        call establecerDireccionVideo
        moverCursor
        call establecerSegmentoDatos
        incrementarValorASCIICadena visorReloj; a la cadena se le aumenta la dif. ascii para que coincida el simbolo del digito
        imprimirReloj: 
            MOV ah,subFuncionVerCadena; asignamos la subfunción de la interupción
            MOV dx,cx ;proporcionamos la dirección de desplazamiento
            int funcionesDOS
            reducirValorASCIICadena visorReloj ;se reduce ya que no queremos que se incremente cada vez que se imprima
            POP DI
            POP AX
            POP DX
            ret
    imprimirRelojDeTiempo endp

    imprimirPuntajeAcumulado proc
        PUSH DX
        PUSH AX
        PUSH DI
        ;este proceso estará bastante activo en el juego, por eso se emplea la pila para evitar alterar otras subrutinas
        ;los demas no lo tiene dado que solo se usan al generar el nivel
        call establecerSegmentoDatos
        MOV DH, filaEstandarImpresionVideo ;fila del cursor
        MOV DL, columnaPuntajeActual ;columna del cursor
        MOV CX, offset visorPuntos
        call establecerDireccionVideo
        moverCursor
        call establecerSegmentoDatos
        MOV DI, 0
        incrementarValorASCIICadena visorPuntos
        imprimirPuntos: 
            MOV ah,subFuncionVerCadena; asignamos la subfunción de la interupción
            MOV dx,cx ;proporcionamos la dirección de desplazamiento
            int funcionesDOS
            reducirValorASCIICadena visorPuntos
            POP DI
            POP AX
            POP DX
            ret
    imprimirPuntajeAcumulado endp

    imprimirTituloOrdenamiento proc
        MOV DH, filaEstandarImpresionVideo ;fila del cursor
        MOV DL, columnaNombreOrdenamiento ;columna del cursor
        call establecerDireccionVideo
        moverCursor
        call establecerSegmentoDatos
        MOV ah,subFuncionVerCadena; asignamos la subfunción de la interupción
        MOV dx,cx ;proporcionamos la dirección de desplazamiento
        int funcionesDOS
        ret
    imprimirTituloOrdenamiento endp  

    ;================= SUBRUTINAS DEL JUEGO ===============================

    plasmarCronometro proc 
    ;visorReloj db 0,saltoLn,0,0, finCadena ;0:00
    ;0-> minutos
    ;2->decenas de segundo
    ;3->unidades de segundo
        ;inc DS:[Configurador.tiempoBase]; 
        call incrementarTiempo ;este siempre incrementa, ya que los segundos si nos interesan, los otros son solo visuales para el croníometro
        analizarMinutos:
            cmp visorReloj[2], 5 ;si las decenas de segundo no equivalen a 5 evalua los segundos
            jl analizarSegundos
            cmp visorReloj[3], 9 ;si las unidades de segundo no equivalen a 9 evalua los segundos
            jl analizarSegundos
            jmp aumentarMinuto
        analizarSegundos:
            cmp visorReloj[3], 9 
            ;si la unidad de segundo es menor a 9 solo se aumenta, si no se
            ;aumneta la decena y se establece en 0
            jl aumentarUnidadesSegundo
            jmp aumentarDecenasSegundo
        aumentarUnidadesSegundo:
            inc visorReloj[3] ;aumenta la unidad de segundo
            jmp finDeCiclo
        aumentarDecenasSegundo:
            MOV visorReloj[3], 0 ;aumenta las decenas de segundo y establece en 0 las unidades
            inc visorReloj[2]
            jmp finDeCiclo
        aumentarMinuto:
            MOV visorReloj[2], 0 ;establece en 0 lo segundos
            MOV visorReloj[3], 0 
            inc visorReloj[0] ;incrementa el minuto
        finDeCiclo:
            call imprimirRelojDeTiempo
            ret
    plasmarCronometro endp

    incrementarPuntos proc
        ;inc DS:[Configurador.puntajeActual]
        ;0->centenas
        ;1->decenas
        ;2->unidades
        analizarCentenas:
            cmp visorPuntos[2], 9 
            jl analizarInferiores
            cmp visorPuntos[1], 9 
            jl analizarInferiores
            jmp aumentarCentenas
        analizarInferiores: ;decenas y centenas
            cmp visorPuntos[2], 9 
            jl aumentarUnidades
            je aumentarDecenas
        aumentarUnidades:
            inc visorPuntos[2] 
            jmp finDeSuma
        aumentarDecenas:
            MOV visorPuntos[2], 0 
            inc visorPuntos[1]
            jmp finDeSuma
        aumentarCentenas:
            MOV visorPuntos[2], 0 
            MOV visorPuntos[1], 0 
            inc visorPuntos[0]
        finDeSuma:    
            call imprimirPuntajeAcumulado
            ret
    incrementarPuntos endp

    incrementarTiempo proc
        ;0->centenas
        ;1->decenas
        ;2->unidades
        analizarCentenas:
            cmp tiempoEstable[2], 9 
            jl analizarInferiores
            cmp tiempoEstable[1], 9 
            jl analizarInferiores
            jmp aumentarCentenas
        analizarInferiores: ;decenas y centenas
            cmp tiempoEstable[2], 9 
            jl aumentarUnidades
            je aumentarDecenas
        aumentarUnidades:
            inc tiempoEstable[2] 
            jmp finDeSuma
        aumentarDecenas:
            MOV tiempoEstable[2], 0 
            inc tiempoEstable[1]
            jmp finDeSuma
        aumentarCentenas:
            MOV tiempoEstable[2], 0 
            MOV tiempoEstable[1], 0 
            inc tiempoEstable[0]
        finDeSuma:    
            ret
    incrementarTiempo endp

    reiniciarTiempo proc
        MOV tiempoEstable[2], 0 ;unidades
        MOV tiempoEstable[1], 0 ;decenas
        MOV tiempoEstable[0], 0; centenas
        ret
    reiniciarTiempo endp

    reiniciarCronometro proc
        MOV visorReloj[3], 0 ;unidades de segundo
        MOV visorReloj[2], 0 ;decenas de segundo
        MOV visorReloj[0], 0; minutos
        ret
    reiniciarCronometro endp

    reiniciarPuntajeJuego proc
        MOV visorPuntos[2], 0 ;unidades
        MOV visorPuntos[1], 0 ;decenas
        MOV visorPuntos[0], 0; centenas
        ret
    reiniciarPuntajeJuego endp

    incrementarBloquesDestruibles proc
        call establecerSegmentoDatos
        inc DS:[Configurador.bloquesGenerados]
        call establecerDireccionVideo 
        ;esto se haxe ya que este proc solo se usará al momento de generar el nivel,
        ;donde se usará constantemente el modo video
        ret
    incrementarBloquesDestruibles endp

    decrecerBloquesDestruibles proc
        call establecerSegmentoDatos
        dec DS:[Configurador.bloquesGenerados]
        ret
    decrecerBloquesDestruibles endp

    verificarPasoDeNivel proc
        cmp DS:[Configurador.bloquesGenerados], 0
        je pasarDeNivel
        jmp proseguirMismoNivel
        pasarDeNivel:
            MOV DS:[Configurador.estadoPartida],indicadorPartidaGanada; nos permite pasar al siguiente nivel
            MOV DS:[Configurador.estadoJuego],indicadorJuegoInactivo; permite salirnos de la evaluación de nivel
        proseguirMismoNivel:
            ret
    verificarPasoDeNivel endp

    retenerPausaEvaluada proc
        PUSH AX
        ;PUSH CX
        call limpiarBufferEntradaTeclado; se limpia el buffer para no volver a evaluar lo previo ingresado
        ;xor cx, cx
        pedirOpcionTecla:
            ;esperar por tecla
            ;inc cx
            mov ah,subFuncionEstadoTeclado
            int funcionesTeclado
            jz pedirOpcionTecla
            cmp al, espacio ;AL actualmente posee el ascii de la tecla ingresada
            je asignarRegreso
            cmp al, teclaMinusculaP ;AL actualmente posee el ascii de la tecla ingresada
            je reanudarJuego
            ;cmp cx, 6000
            call limpiarBufferEntradaTeclado
            ;je  reanudarJuego
            jmp pedirOpcionTecla 
        asignarRegreso:; cambia el indicaodr para que se sepa que debe finalizar el juego    
            call establecerSegmentoDatos
            MOV DS:[Configurador.estadoJuego], indicadorJuegoInactivo
        reanudarJuego:
            ;POP CX
            POP AX
            ret ;retornará al punto donde fue llamdo (en la evaluación de teclas del jeugo, para proseguir con él)
    retenerPausaEvaluada endp

    ;==============================================================================================

    ;===============================================================================================

    ;=============================== ORDENAMIENTOS: ==================================================

    ;ejecutarOrdenamiento proc
     ;   call establecerValoresInicialesOrdenamiento
      ;  obtenerDataOrdenamientos
       ; ret
    ;ejecutarOrdenamiento endp
    
    establecerValoresInicialesOrdenamiento proc
        MOV DS:[Graficador.cuentaPuntajesActuales],0    
        MOV DS:[Graficador.cuentaTiemposActuales],0 
        ret 
    establecerValoresInicialesOrdenamiento endp

    intercambiarPuntaje proc
        PUSH DX
        PUSH CX
        PUSH BX
        PUSH DI
        ;Guardamos DI porque necesitamos el valor actual pero necesitamos emplear
        ;DI en "emplearCopiaAuxiliar", lo que alteraria su valor
        XOR cx, cx ;inicializamos en 0 para realizar las cuentas
        xor di, di 
        MOV BX, SI 
        ;necesitamos guardar SI ya que se usará para trasladar al auxiliar la información,
        ;pero necesitamos esa misma posición original para realizar despues el intercambio
        emplearCopiaAuxiliar:
            MOV dl, puntajesDesordenados[si]
            MOV auxiliarDeCambioDigito[di], dl 
            ;se maneja con DI ya que SI llevará un indice que se increntará
            ;constantemente durante el ordenamiento, y al auxiliar isempre
            ; debemos evaluarlo iniciando desde 0, 
            inc si
            inc di
            inc cx
            cmp cx, digitosMaximosEvaluacion  
            jl emplearCopiaAuxiliar ;mientras las evaluaciones no pasen el número de digitos max (3)
            xor cx, cx
            POP DI ;Recuperamos el valor original actual de DI
            MOV SI, BX ;obtenemos el valor original de SI actual
        intercambiar:
            PUSH DI 
            ;Guardamos DI porque necesitamos el valor actual pero necesitamos emplear
            ;DI para el acceso al auxiliar, lo que alteraria su valor
            MOV dl, puntajesDesordenados[di]
            MOV puntajesDesordenados[si], dl
            MOV DI, cx; la cuenta coincide con la posicipón necesaria en el acceso a auxiliar
            MOV dl, auxiliarDeCambioDigito[di]
            POP DI ;recuperamos verdadero el valor que necesitamos
            MOV puntajesDesordenados[di], dl
            inc si
            inc di
            inc cx 
            cmp cx, digitosMaximosEvaluacion
            jl intercambiar
        fin:
            ;Dada la ultima iteración tanto SI como DI queadan poisicionados
            ;en el indice exacto donde se necesita para próximas evaluaciones
            ;cuando se emplea en ordenamientos
            POP BX
            POP CX
            POP DX
            ret
    intercambiarPuntaje endp

    compararPuntajes proc
        PUSH AX ;En la posicion actual de si y di realiza la comparación
        PUSH SI 
        ;en este proc se alteran SI y DI pero como solo es para comparar
        ;usamos la pila para guardar el valor original que servirá en otras subrutinas
        PUSH DI
        compararCentenas:
            MOV al, puntajesDesordenados[di]
            ADD al, diferenciaASCII
            MOV ah, puntajesDesordenados[si]
            ADD ah, diferenciaASCII
            cmp ah, al
            jg  indicarMayor ;pos 1 > pos 2
            cmp ah, al
            jl  indicarMenor ;pos 2 > pos 1
        compararDecenas:
            inc si
            inc di
            MOV al, puntajesDesordenados[di]
            ADD al, diferenciaASCII
            MOV ah, puntajesDesordenados[si]
            ADD ah, diferenciaASCII
            cmp ah, al
            jg  indicarMayor ;pos 1 > pos 2
            cmp ah, al
            jl  indicarMenor ;pos 2 > pos 1
        compararUnidades:
            inc si
            inc di
            MOV al, puntajesDesordenados[di]
            ADD al, diferenciaASCII
            MOV ah, puntajesDesordenados[si]
            ADD ah, diferenciaASCII
            cmp ah, al
            jg  indicarMayor ;pos 1 > pos 2
            cmp ah, al
            jl  indicarMenor ;pos 2 > pos 1
            cmp ah, al
            je indicarIgual
        indicarMayor:; dl == 1, indicando que pos1 > pos2
            MOV dl, 1
            cmp dl, 1 
            je finComparacionPuntajes
        indicarMenor:
            MOV dl, 0
            cmp dl, 0 
            je finComparacionPuntajes
        indicarIgual:
            MOV dl, 2
            cmp dl, 2
            je finComparacionPuntajes
        finComparacionPuntajes:
            POP DI
            POP SI
            POP AX
            ret
    compararPuntajes endp 

    intercambiarTiempo proc
        PUSH DX
        PUSH CX
        PUSH BX
        PUSH DI
        ;Guardamos DI porque necesitamos el valor actual pero necesitamos emplear
        ;DI en "emplearCopiaAuxiliar", lo que alteraria su valor
        XOR cx, cx ;inicializamos en 0 para realizar las cuentas
        xor di, di 
        MOV BX, SI 
        ;necesitamos guardar SI ya que se usará para trasladar al auxiliar la información,
        ;pero necesitamos esa misma posición original para realizar despues el intercambio
        emplearCopiaTiempoAuxiliar:
            MOV dl, tiemposDesordenados[si]
            MOV auxiliarDeCambioDigito[di], dl 
            ;se maneja con DI ya que SI llevará un indice que se increntará
            ;constantemente durante el ordenamiento, y al auxiliar isempre
            ; debemos evaluarlo iniciando desde 0, 
            inc si
            inc di
            inc cx
            cmp cx, digitosMaximosEvaluacion  
            jl emplearCopiaTiempoAuxiliar ;mientras las evaluaciones no pasen el número de digitos max (3)
            xor cx, cx
            POP DI ;Recuperamos el valor original actual de DI
            MOV SI, BX ;obtenemos el valor original de SI actual
        intercambiarTm:
            PUSH DI 
            ;Guardamos DI porque necesitamos el valor actual pero necesitamos emplear
            ;DI para el acceso al auxiliar, lo que alteraria su valor
            MOV dl, tiemposDesordenados[di]
            MOV tiemposDesordenados[si], dl
            MOV DI, cx; la cuenta coincide con la posicipón necesaria en el acceso a auxiliar
            MOV dl, auxiliarDeCambioDigito[di]
            POP DI ;recuperamos verdadero el valor que necesitamos
            MOV tiemposDesordenados[di], dl
            inc si
            inc di
            inc cx 
            cmp cx, digitosMaximosEvaluacion
            jl intercambiarTm
        finIntercambioTiempo:
            ;Dada la ultima iteración tanto SI como DI queadan poisicionados
            ;en el indice exacto donde se necesita para próximas evaluaciones
            ;cuando se emplea en ordenamientos
            POP BX
            POP CX
            POP DX
            ret
    intercambiarTiempo endp

    compararTiempos proc
        PUSH AX ;En la posicion actual de si y di realiza la comparación
        PUSH SI 
        ;en este proc se alteran SI y DI pero como solo es para comparar
        ;usamos la pila para guardar el valor original que servirá en otras subrutinas
        PUSH DI
        compararCentenas:
            MOV al, tiemposDesordenados[di]
            ADD al, diferenciaASCII
            MOV ah, tiemposDesordenados[si]
            ADD ah, diferenciaASCII
            cmp ah, al
            jg  indicarMayor ;pos 1 > pos 2
            cmp ah, al
            jl  indicarMenor ;pos 2 > pos 1
        compararDecenas:
            inc si
            inc di
            MOV al, tiemposDesordenados[di]
            ADD al, diferenciaASCII
            MOV ah, tiemposDesordenados[si]
            ADD ah, diferenciaASCII
            cmp ah, al
            jg  indicarMayor ;pos 1 > pos 2
            cmp ah, al
            jl  indicarMenor ;pos 2 > pos 1
        compararUnidades:
            inc si
            inc di
            MOV al, tiemposDesordenados[di]
            ADD al, diferenciaASCII
            MOV ah, tiemposDesordenados[si]
            ADD ah, diferenciaASCII
            cmp ah, al
            jg  indicarMayor ;pos 1 > pos 2
            cmp ah, al
            jl  indicarMenor ;pos 2 > pos 1
            cmp ah, al
            je indicarIgual
        indicarMayor:; dl == 1, indicando que pos1 > pos2
            MOV dl, 1
            cmp dl, 1 
            je finComparacionTiempos
        indicarMenor:
            MOV dl, 0
            cmp dl, 0 
            je finComparacionTiempos
        indicarIgual:
            MOV dl, 2
            cmp dl, 2
            je finComparacionTiempos
        finComparacionTiempos:
            POP DI
            POP SI
            POP AX
            ret
    compararTiempos endp 


    elegirIntercambio proc
        PUSH AX
        ;Asume que AL tiene el indicador de cual intercambio usar
        cmp lectorEntradaTop[0], '1' ;o es indicador de intercambio de puntajes
        je intercambiarParejaPuntajes
        jmp intercambioParejaTiempos
        intercambiarParejaPuntajes:
            call intercambiarPuntaje
            ;cmp al, 0 
            jmp finalizarIntercambios
        intercambioParejaTiempos:
            call intercambiarTiempo
        finalizarIntercambios:
            POP AX
            ret
    elegirIntercambio endp

    elegirComparacion proc 
        PUSH AX
        ;Asume que AL tiene el indicador de cual comparacion usar
        cmp lectorEntradaTop[0], '1' ;o es indicador de intercambio de puntajes
        je compararParejaPuntajes
        jmp compararParejaTiempos
        compararParejaPuntajes:
            call compararPuntajes
            ;cmp al, 0 
            jmp finalizarComparaciones
        compararParejaTiempos:
            call compararTiempos
        finalizarComparaciones:
            POP AX
            ret
    elegirComparacion endp

    ordenarPorBubble proc
        PUSH SI
        PUSH DI
        MOV ch, DS:[Graficador.cuentaPuntajesActuales]
        MOV ch, 12
        MOV cl, ch ;la copia servirá para el numero de iteraciones, iteraciones = numElementos
        dec ch; burbuja realiza comparaciones, donde comparaciones = numElementos - 1 
        elegirOrden:
            MOV SI, 0
            MOV DI, digitosMaximosEvaluacion ;dado que entre centenas, decenas y unidades hay 3 posiciones de diferencia
            ;MOV ch, DS:[Graficador.cuentaPuntajesActuales]
            MOV ch, 12
            dec ch
            cmp lectorEntradaOrden[0], '1'; 1 indica ascendentes
            je  ordenarAscendente 
            jmp ordenarDescendente
        ordenarAscendente:
            ;MOV AL, indicadorComparacion
            call elegirComparacion ; dl = 1 si pos1 > pos 2
            cmp dl, 1
            je intercambiarPuntajesAsc
            jmp desplazarmeSiguienteAsc
            desplazarmeSiguienteAsc:
                ADD SI, digitosMaximosEvaluacion
                ADD DI, digitosMaximosEvaluacion
                jmp verificarRepeticionAsc
            intercambiarPuntajesAsc:
                ;MOV AL, indicadorIntercambio
                call elegirIntercambio
            verificarRepeticionAsc:   
                dec ch
                cmp ch, 0
                jg ordenarAscendente
                jmp fin
        ordenarDescendente:
            ;MOV AL, indicadorComparacion
            call elegirComparacion ; dl = 0 si pos1 <  pos 2
            cmp dl, 0
            je intercambiarPuntajesDesc
            jmp desplazarmeSiguienteDesc
            desplazarmeSiguienteDesc:
                ADD SI, digitosMaximosEvaluacion
                ADD DI, digitosMaximosEvaluacion
                jmp verificarRepeticionDesc
            intercambiarPuntajesDesc:
                ;MOV AL, indicadorIntercambio
                call elegirIntercambio
            verificarRepeticionDesc:   
                dec ch
                cmp ch, 0
                jg ordenarDescendente
                jmp fin
        fin:
            dec cl
            cmp cl, 0
            jge elegirOrden
            POP DI
            POP SI
            ret
    ordenarPorBubble endp  

end