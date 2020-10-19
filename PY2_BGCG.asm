
;================ SECCIÓN DE MACROS ============================== 
salirPrograma macro          
imprimirEnConsola salidaJuego
MOV ah,subFuncionFinPrograma 
int funcionesDOS
endm


imprimirEnConsola macro cadena
MOV ah,subFuncionVerCadena; asignamos la subfunción de la interupción
MOV dx,offset cadena ;proporcionamos la dirección de desplazamiento
int funcionesDOS
endm   

mostrarEncabezado macro    
imprimirEnConsola lineaSeparadora
imprimirEnConsola datosCurso 
imprimirEnConsola misDatos
imprimirEnConsola lineaSeparadora
endm    

mostrarMenuPrincipal macro   
;imprimirEnConsola lineaSeparadora 
imprimirEnConsola tituloJuego   
;imprimirEnConsola lineaSeparadora
imprimirEnConsola menuPrincipal
endm              

obtenerTecla macro
mov ah,subFuncionLeerCaracter
int funcionesDOS
endm
       
obtenerLecturaTeclado macro arregloLector
PUSH SI
PUSH AX
xor si,si;Bits de SI en 0  
leerTecla:
obtenerTecla
    cmp al,retornoCR
    je  finalizar
    mov arregloLector[si],al
    inc si
    inc cl ;llevará la cuenta de caracteres ingresados
    jmp leerTecla
finalizar:
    mov arregloLector[si],finCadena
    POP AX
    POP SI
endm
    
     
;================ DEFINICIÓN DE MODELO Y PILA ==============================       
.model small ;small: Se utilizará sólo un segmento de datos con un segmento de código,
             ;en total 128 Kbytes de memoria
.stack 100h  ;asigamos su tamaño 
;================ SEGMENTO DE DATOS ============================== 
.data   
  
;=== EQUIVALENTES ===     
saltoLn EQU 0ah ;0ah-> 10 -> \n 
retornoCR EQU 0dh ;0dh-> 13 ->\r       
tabulador EQU 09h ;09h -> 0 -Z \t    
EtildadaMinus EQU 82h ;82H -> 130 -> é
ItildadaMinus EQU 0A1h ;A1H -> 161 -> í
OtildadaMinus EQU 0A2h ;A2H -> 162 -> ó 
finCadena EQU 24h ;24h-> 36 -> $     
  
;=== INTERRUPCIONES EQUIVALENTES === 
subFuncionVerCadena EQU 09h ;09h -> 9 -> Visualización de una cadena de caracteres
subFuncionLeerCaracter EQU 01h ;01h -> 1 -> Entrada de caracter con salida  
subFuncionFinPrograma EQU 4ch ;4ch -> 76 -> Terminación de Programa con Código de Retorno
funcionesDOS EQU 21h ;21h -> 33 -> petición de función al DOS  
   
;=== VECTORES ===            
lectorEntradaTeclado db 20 dup(finCadena),finCadena; llenamos el vector de $ y agregamos un final de cadena
   
;=== CADENAS PARA MENSAJES EN CONSOLA ===    
;=== SEPARADORES ===                                      
tituloJuego db saltoLn,retornoCR,'!@!@!@!@!@!@! ASM BALL BREAKER !@!@!@!@!@!@!@!@!',saltoLn,finCadena 
lineaSeparadora db saltoLn,retornoCR,'!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!',saltoLn,finCadena  
;===   DATOS   ===
datosCurso db saltoLn,retornoCR, 'Universidad de San Carlos de Guatemala', saltoLn,retornoCR,'Facultad de Ingenier',ItildadaMinus,'a', saltoLn,retornoCR,'Arquitectura de Computadores y Ensambladores 1', saltoLn,retornoCR,'Segundo Semestre 2020', saltoLn,retornoCR,'Secci',OtildadaMinus,'n: A', saltoLn,retornoCR,'Proyecto 2', saltoLn,retornoCR,finCadena                                                                                 
misDatos db saltoLn,retornoCR,tabulador,'Byron Gerardo Castillo G',OtildadaMinus,'mez',saltoLn,retornoCR,tabulador,tabulador,'20170544',finCadena
;===   ALERTAS   === 
inicioJuego db saltoLn,retornoCR,'Iniciando Partida...',finCadena 
finJuego db saltoLn,retornoCR,'fin de Partida...',finCadena       
salidaJuego db saltoLn,retornoCR,'Saliendo del Juego...',saltoLn,retornoCR,'JUEGO TERMINADO  :)',finCadena
opcionErronea db saltoLn,retornoCR,'La opci',OtildadaMinus,'n ingresada no es correcta',saltoLn,retornoCR,'Debe ingresarla nuevamente:',saltoLn,retornoCR,finCadena 
usuarioAccedido db saltoLn,retornoCR,'Usuario reconocido, accediendo...',finCadena    
usuarioRegistrado db saltoLn,retornoCR,'Usuario registrado, ya puede utilizarlo para jugar',finCadena 
usuarioErroneo db saltoLn,retornoCR,'El usuario no existe!!',finCadena
passErroneo db saltoLn,retornoCR,'El pass es incorrecto!!',finCadena   
usuarioMax db saltoLn,retornoCR,'El usuario ingresado sobrepasa el max(7) de caracteres',finCadena
passMaxError db saltoLn,retornoCR,'El pass ingresado sobrepasa el max(4) de digitos o no es del todo num',EtildadaMinus,'rico',finCadena
velocidadErronea db saltoLn,retornoCR,'La velocidad ingresada es incorrecta',finCadena 
;=== SOLICITUDES ===    
solicitudUsuario db saltoLn,retornoCR,'Ingrese el usuario:',saltoLn,retornoCR,finCadena   
solicitudPass db saltoLn,retornoCR,'Ingrese el Pass:',saltoLn,retornoCR,finCadena
solicitudVelocidad db saltoLn,retornoCR,'Ingrese la velocidad(0-9):',saltoLn,retornoCR,finCadena 
;=== MENUS DE SELECCIÓN ===
menuPrincipal db saltoLn,retornoCR,'!#!#!#!#!#!#! MENU PRINCIPAL !#!#!#!#!#!#!#!#!',saltoLn,retornoCR,'(1)->Ingresar al Juego.',saltoLn,retornoCR,  '(2)->Registrar Usuario.',saltoLn,retornoCR,'(3)->Salir del Juego.',saltoLn,retornoCR,saltoLn,'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena
menuIngreso db saltoLn,retornoCR,'!#!#!#!#!#!#! INGRESO: !#!#!#!#!#!#!#!#!',saltoLn,retornoCR,finCadena
menuRegistro db saltoLn,retornoCR,'!#!#!#!#!#!#! REGISTRO: !#!#!#!#!#!#!#!#!',saltoLn,retornoCR,finCadena
menuTops db saltoLn,retornoCR,'!#!#!#!#!#!#! MENU TOPS !#!#!#!#!#!#!#!#!',saltoLn,retornoCR,'(1)->Ver Top 10 Puntajes.',saltoLn,retornoCR,'(2)->Ver Top 10 Tiempos.',saltoLn,retornoCR,'(3)->Regresar.',saltoLn,retornoCR,saltoLn,'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena
menuOrdenamientos db saltoLn,retornoCR,'!#!#!#!#!#!#! ORDENAMIENTOSL !#!#!#!#!#!#!#!#!',saltoLn,retornoCR,'(1)->Bubble Sort.',saltoLn,retornoCR,'(2)->Quick Sort.',saltoLn,retornoCR,'(3)->Shell Sort.',saltoLn,retornoCR,saltoLn,'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena
menuOrden db saltoLn,retornoCR,'!#!#!#!#!#!#! ORDEN !#!#!#!#!#!#!#!#!',saltoLn,retornoCR,'(1)->Ascendente.',saltoLn,retornoCR,'(2)->Descendente.',saltoLn,retornoCR,'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena

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
			        MOV cl,0         
			        obtenerLecturaTeclado lectorEntradaTeclado
			        cmp cl,1  
			        je distribuirSubMenu
			    ErrorEntradaPrincipal:
			        imprimirEnConsola opcionErronea
			        jmp LecturaPrincipal
		seccionIngreso:
		    imprimirEnConsola menuIngreso  
		    je  menuInicial
		seccionRegistro:
		    imprimirEnConsola menuRegistro
		    je  menuInicial 
		seccionTops:
		    imprimirEnConsola menuTops 
		    je  menuInicial
		seccionOrdenamientos:
		    imprimirEnConsola menuOrdenamientos 
		    je  menuInicial
		seccionOrden:
		    imprimirEnConsola menuOrden  
		Salir: 
			salirPrograma  
	    distribuirSubMenu:  
            MOV cl,0; reiniciamos el contador para futuras ocasiones  
            subMenusPrincipal:             
                cmp lectorEntradaTeclado[0],'1'
                je  seccionIngreso 
                cmp lectorEntradaTeclado[0],'2'
                je  seccionRegistro 
                cmp lectorEntradaTeclado[0],'3'
                je  Salir  
                MOV lectorEntradaTeclado,finCadena ;sobrescribimos con $ el lector  
                JMP ErrorEntradaPrincipal
	main endp   
end