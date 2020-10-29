
;================ SECCIÓN DE MACROS ============================== 
     
;include M/m_bars.asm     
include M/m_file.asm 
include M/m_game.asm 
include M/m_kpad.asm 
include M/m_log.asm 
include M/m_main.asm 
include M/m_reps.asm 
include M/m_sign.asm 

;================ DEFINICIÓN DE MODELO Y PILA ==============================       
.model small ;small: Se utilizará solo un segmento de datos con un segmento de código,
             ;en total 128 Kbytes de memoria
.stack 100h  ;asignamos su tamaño 
;================ SEGMENTO DE DATOS ============================== 
.data   
  
;=== EQUIVALENTES ===     
saltoLn EQU 0ah ;0ah-> 10 -> \n 
retornoCR EQU 0dh ;0dh-> 13 ->\r       
tabulador EQU 09h ;09h -> 9 -> \t    
EtildadaMinus EQU 82h ;82H -> 130 -> é
ItildadaMinus EQU 0A1h ;A1H -> 161 -> í
OtildadaMinus EQU 0A2h ;A2H -> 162 -> ó
coma EQU 2ch ;2ch-> 44 -> , 
punto EQU 2eh ;2eh-> 46 -> ,  
puntoComa EQU 3bh ;3bh-> 59 -> ;
espacio EQU 20h;20h->32 -> espacio en blanco  
finRutaFichero EQU 0h ;0h-> 0 -> 0 
finCadena EQU 24h ;24h-> 36 -> $
dimensionLectorTeclado EQU 14h; 20D 
dimensionLectorFicheros EQU 7d0h;2000D 
dimensionEscritorFicheros EQU 7d0h;2000D 
longMaxUsuario EQU 07h;7 caracteres máximo
longMaxPass EQU 04h;4 digitos fijos  
permisoLecturaEscritura EQU 02h; 2 hace referencia a ese modo de acceso en ficheros 
modoEstandar EQU 00h; 0 hace referencia a ese modo o tipo estándar en ficheros 
cantidadSeparacion EQU 15 ;sirve como cuenta para los sepradores en los reportes
inicioAsciiDigito EQU 0030h; es el 0 decimal en ascii
finAsciiDigito EQU 003ah; se tomará como representación del 10 decimal en ascii
  
;=== INTERRUPCIONES EQUIVALENTES === 
subFuncionLeerCaracter EQU 01h ;01h -> 1 -> Entrada de caracter con salida
subFuncionVerCadena EQU 09h ;09h -> 9 -> Visualización de una cadena de caracteres   
subFuncionCrearFichero EQU 3ch ;3ch -> 60 -> Crear Fichero
subFuncionAbrirFichero EQU 3dh ;3dh -> 61 -> Abrir Fichero  
subFuncionCerrarFichero EQU 3eh; 3eh-> 62 -> Cerrar Archivo
subFuncionLeerFichero EQU 3fh ;3fh -> 63 -> Lectura de Fichero o dispositivo
subFuncionAdjuntarInfoFichero EQU 40h ;40h -> 64 -> Escritura(Adjuntada) en Fichero o dispositivo.
subFuncionFinPrograma EQU 4ch ;4ch -> 76 -> Terminación de Programa con Código de Retorno 
funcionesDOS EQU 21h ;21h -> 33 -> petición de función al DOS  
   
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
  
;Rutas ejecutando desde Emu8086:
nombreArchivoJugadores db 'B\Gamers.txt',finRutaFichero ;En dosbox es 'B\Gamers.txt',finRutaFichero
nombreArchivoPartidas db 'B\Rounds.txt',finRutaFichero  ;En dosbox es 'B\Rounds.txt',finRutaFichero
nombreReportePuntajes db 'B\Puntos.rep',finRutaFichero  ;En dosbox es 'B\Puntos.txt',finRutaFichero
nombreReporteTiempos db 'B\Tiempo.rep',finRutaFichero   ;En dosbox es 'B\Tiempo.txt',finRutaFichero
nombreArchivoAdmins db 'B\Admins.txt',finRutaFichero     ;En dosbox es 'B\Asmins.txt',finRutaFichero
controladorFicheros dw ?      

;=== CADENAS PARA MENSAJES EN CONSOLA ===    
;=== SEPARADORES ===                                      
tituloJuego db saltoLn,retornoCR,'!@!@!@!@!@!@! ASM BALL BREAKER !@!@!@!@!@!@!@!@!',saltoLn,retornoCR,finCadena 
lineaSeparadora db saltoLn,retornoCR,'!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!',saltoLn,retornoCR,finCadena  

;===   DATOS   ===
datosCurso db saltoLn,retornoCR, 'Universidad de San Carlos de Guatemala', saltoLn,retornoCR,'Facultad de Ingenier',ItildadaMinus,'a', saltoLn,retornoCR,'Arquitectura de Computadores y Ensambladores 1', saltoLn,retornoCR,'Segundo Semestre 2020', saltoLn,retornoCR,'Secci',OtildadaMinus,'n: A', saltoLn,retornoCR,'Proyecto 2', saltoLn,retornoCR,finCadena                                                                                 
misDatos db saltoLn,retornoCR,tabulador,'Byron Gerardo Castillo G',OtildadaMinus,'mez',saltoLn,retornoCR,tabulador,tabulador,'20170544',finCadena

;===   ALERTAS   ===  
debug db saltoLn,retornoCR,'Punto Debug...',saltoLn,retornoCR,finCadena  
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
         
menuOrdenamientos db saltoLn,retornoCR,'!#!#!#!#!#!#! ORDENAMIENTOSL !#!#!#!#!#!#!#!#!',saltoLn,retornoCR
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
   puntajeActual db ?
   tiempoActual db ?
Configurador ENDS 
;Guarda toda la configuracio´n de los niveles del Ball Breaker

Graficador STRUC
   velocidad db ?
   tiempo db ?
   nombreOrdenamiento db ?
Graficador ENDS 
;Guarda toda la configuracio´n par al animación de oso gráficos de ordenamientos

;orientacionGeneral Orientador <0030h, 0039h>

;================== SEGMENTO DE CODIGO ===========================
.code 
    asignarDIreccionDatos:
       MOV dx,@data ; Dirección del segmento de datos
	   MOV ds,dx 
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
		    jmp  menuInicial    
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
	main endp
end