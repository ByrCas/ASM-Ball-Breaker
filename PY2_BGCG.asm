
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
    LOCAL leerTecla, finalizar 
    PUSH SI
    PUSH AX
    xor si,si;Bits de SI en 0 
    MOV cl,0 ;cntador de telcas ingresadas 
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

reiniciarLectorTeclado macro  
    LOCAL borrar
    PUSH SI  
    xor si,si;Bits de SI en 0 
    borrar:
        MOV lectorEntradaTeclado[si], finCadena 
        inc si
        cmp si, 14h
        jl borrar 
    POP SI
endm   

reiniciarLectorFicheros macro 
    LOCAL borrar
    PUSH SI  
    MOV si,0;Bits de SI en 0  
    MOV CX, dimensionLectorFicheros
    borrar:
        MOV lectorEntradaFicheros[si], finCadena 
        inc si
        loop borrar 
    POP SI
endm  

abrirArchivo macro rutaArchivo,controlador
    mov ah,subFuncionAbrirFichero
    mov al,00h    ;modo de acceso:
    mov dx, offset rutaArchivo
    int funcionesDOS
    mov controlador,ax
    jc errorAperturaArchivo
endm

leerArchivo macro numBytes,arregloLector,controlador
    mov ah,subFuncionLeerFichero
    mov bx,controlador
    mov cx,numBytes       ;cuantos bytes se leerán
    lea dx,arregloLector
    int funcionesDOS
    jc errorLecturaArchivo ;Se produce acarreo = 1 en una lectura fallida
endm        

cerrarArchivo macro controlador 
    MOV ah, subFuncionCerrarFichero
    MOV bx, controlador
    int funcionesDOS                           
endm                               
 
leerArchivoEnrutado macro indicador    
    LOCAL asignarRutaJugadores, asignarRutaPartidas, asignarRutaPuntos,asignarRutaTiempos, lectura
    reiniciarLectorFicheros  
    cmp indicador,0
    je asignarRutaJugadores
    cmp indicador,1
    je asignarRutaPartidas
    cmp indicador,2
    je asignarRutaPuntos
    cmp indicador,3
    je asignarRutaTiempos
    asignarRutaJugadores:
        abrirArchivo nombreArchivoJugadores,controladorFicheros 
        jmp lectura
    asignarRutaPartidas:
        abrirArchivo nombreArchivoPartidas,controladorFicheros
        jmp lectura
    asignarRutaPuntos:
        abrirArchivo nombreReportePuntajes,controladorFicheros
        jmp lectura
    asignarRutaTiempos:
        abrirArchivo nombreReporteTiempos,controladorFicheros     
    lectura:
        leerArchivo dimensionLectorFicheros,lectorEntradaFicheros,controladorFicheros
        imprimirEnConsola  lectorEntradaFicheros  
endm   

verifCoin macro
    leerArchivoEnrutado dl ;se abre y lee el contenido de se archivo 
    cerrarArchivo controladorFicheros  
    xor di,di
    verif:   
          inc di
           imprimirEnConsola debug
          cmp lectorEntradaFicheros[di],2ch
          jne verif    
            
endm                
       
verificarIngreso macro  
     LOCAL LecturaIngresoUsuario, ErrorEntradaUsuario, reVerificarUsuario, verificarUsuario,denegarCaracter, aceptarCaracter, verificarCoincidenciaUsuario,LecturaIngresoPass, ErrorEntradaPass, verificarPass,aceptarCaracterPass, notificarPassErroneo, usuarioInexistente, verificarCoincidenciaPass, accesoUsuario     
     PUSH SI 
     PUSH DI
     MOV dl, 0 ;0 indica que se use el archivo Gamers.txt 
     leerArchivoEnrutado dl ;se abre y lee el contenido de se archivo 
     cerrarArchivo controladorFicheros 
     xor si, si
     xor di, di 
     LecturaIngresoUsuario:  
        imprimirEnConsola  solicitudUsuario          
        obtenerLecturaTeclado lectorEntradaTeclado   
        cmp cl, longMaxUsuario ;si es <= 7 se evalua, si no lo vuelve a solicitar
        jle verificarUsuario
        ErrorEntradaUsuario:
            imprimirEnConsola usuarioMaxError
            reiniciarLectorTeclado
            jmp LecturaIngresoUsuario
     reVerificarUsuario:
        xor si,si ;Se reinicia SI para evaluar la cadena ingresada nuevamente
        add di, 3
        ;dado que actualmente esta ubicado en un ";"(separador)
        ;necesitamos el siguiente caracter para evaluar otro usuario,
        ;pero sumamos 3 dado que es ";", "\n", y "\r" lo que separa a cada usuario   
     verificarUsuario:     
        cmp  lectorEntradaFicheros[di], finCadena
        je usuarioInexistente 
        ;si coincide con fin de cadena significa que ya evaluo todo
        ;y no hay usuario registrado con ese nombre  
        MOV bl, lectorEntradaFicheros[di] 
        cmp  lectorEntradaTeclado[si], bl 
        je aceptarCaracter
        denegarCaracter:
            ;dado que no coincide el usuario: 
            ;se desplaza hasta encontrar ; (nuestro separador de credenciales)       
            cmp lectorEntradaFicheros[di], puntoComa
            je  reVerificarUsuario
            inc di         
            jmp denegarCaracter 
        aceptarCaracter:     
            inc si                     
            inc di  
            cmp  lectorEntradaTeclado[si], finCadena 
            je  verificarCoincidenciaUsuario
            jmp verificarUsuario 
     verificarCoincidenciaUsuario:     
            cmp  lectorEntradaFicheros[di], coma ; si equivale a coma es que el usuario si coincide
            je  LecturaIngresoPass
            jmp denegarCaracter
     ;reiniciarLectorTeclado 
     LecturaIngresoPass:  
            inc di    ;su ultima posición es el separado ",", por eso se incrementa
            xor si,si ;Se reinicia si para evaluar la cadena ingresada nuevamente
            reiniciarLectorTeclado  
		    imprimirEnConsola  solicitudPass          
		    obtenerLecturaTeclado lectorEntradaTeclado
		    cmp cl, longMaxPass ;si es == 4 se evalua, si no lo vuelve a solicitar
		    je verificarPass
		    ErrorEntradaPass:
		        imprimirEnConsola passMaxError 
		        reiniciarLectorTeclado
		        jmp LecturaIngresoPass
     verificarPass:           
            MOV bl, lectorEntradaFicheros[di]
            cmp  lectorEntradaTeclado[si], bl 
            je aceptarCaracterPass
            notificarPassErroneo:
                ;dado que no coincide el pass, se niega el acceso y se solicita nuevamente un usuario   
                xor di,di  
                xor si,si ;Se reinicia si para evaluar la cadena ingresada nuevamente 
                imprimirEnConsola passErroneo
                reiniciarLectorTeclado
                jmp  LecturaIngresoUsuario 
            aceptarCaracterPass:     
                inc si
                inc di
                cmp  lectorEntradaTeclado[si], finCadena 
                je  verificarCoincidenciaPass
                jmp verificarPass
            verificarCoincidenciaPass:     
                cmp  lectorEntradaFicheros[di], puntoComa; si equivale a punto coma es que el pass si coincide 
                je  accesoUsuario
                jmp notificarPassErroneo
     usuarioInexistente:
        imprimirEnConsola usuarioErroneo
        reiniciarLectorTeclado
        xor di,di ; se restablece el puntero al inicio del archivo para nuevas evaluaciones
        jmp LecturaIngresoUsuario 
     accesoUsuario:
        imprimirEnConsola usuarioAccedido  
        ;accede al juego:
		imprimirEnConsola inicioJuego 
		POP SI 
		POP DI     
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
coma EQU 2ch ;2ch-> 44 -> , 
puntoComa EQU 3bh ;3bh-> 59 -> ;  
finRutaFichero EQU 0h ;0h-> 0 -> 0 
finCadena EQU 24h ;24h-> 36 -> $
dimensionLectorTeclado EQU 14h 
dimensionLectorFicheros EQU 0c8h 
longMaxUsuario EQU 07h
longMaxPass EQU 04h   
  
;=== INTERRUPCIONES EQUIVALENTES === 
subFuncionVerCadena EQU 09h ;09h -> 9 -> Visualización de una cadena de caracteres
subFuncionLeerCaracter EQU 01h ;01h -> 1 -> Entrada de caracter con salida  
subFuncionFinPrograma EQU 4ch ;4ch -> 76 -> Terminación de Programa con Código de Retorno  
subFuncionAbrirFichero EQU 3dh ;3dh -> 61 -> Abrir Fichero 
subFuncionLeerFichero EQU 3fh ;3fh -> 63 -> Lectura de Fichero o dispositivo 
subFuncionCrearFichero EQU 3ch ;3ch -> 60 -> Crear Fichero 
subFuncionCerrarFichero EQU 3eh; 3eh-> 62 -> Cerrar Archivo
subFuncionAdjuntarInfoFichero EQU 40h ;40h -> 64 -> Escritura(Adjuntada) en Fichero o dispositivo.
funcionesDOS EQU 21h ;21h -> 33 -> petición de función al DOS  
   
;=== VECTORES ===            
lectorEntradaTeclado db 20 dup(finCadena); llenamos el vector de $ y agregamos un final de cadena
lectorEntradaFicheros db 200 dup(finCadena)     
;Rutas ejecutando desde Emu8086:
nombreArchivoJugadores db 'C:\B\Gamers.txt',finRutaFichero ;En dosbox es 'B\Gamers.txt',finRutaFichero
nombreArchivoPartidas db 'C:\B\Rounds.txt',finRutaFichero  ;En dosbox es 'B\Rounds.txt',finRutaFichero
nombreReportePuntajes db 'C:\B\Puntos.rep',finRutaFichero  ;En dosbox es 'B\Puntos.txt',finRutaFichero
nombreReporteTiempos db 'C:\B\Tiempo.rep',finRutaFichero   ;En dosbox es 'B\Tiempo.txt',finRutaFichero
controladorFicheros dw ?      

;=== CADENAS PARA MENSAJES EN CONSOLA ===    
;=== SEPARADORES ===                                      
tituloJuego db saltoLn,retornoCR,'!@!@!@!@!@!@! ASM BALL BREAKER !@!@!@!@!@!@!@!@!',saltoLn,finCadena 
lineaSeparadora db saltoLn,retornoCR,'!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!',saltoLn,finCadena  
;===   DATOS   ===
datosCurso db saltoLn,retornoCR, 'Universidad de San Carlos de Guatemala', saltoLn,retornoCR,'Facultad de Ingenier',ItildadaMinus,'a', saltoLn,retornoCR,'Arquitectura de Computadores y Ensambladores 1', saltoLn,retornoCR,'Segundo Semestre 2020', saltoLn,retornoCR,'Secci',OtildadaMinus,'n: A', saltoLn,retornoCR,'Proyecto 2', saltoLn,retornoCR,finCadena                                                                                 
misDatos db saltoLn,retornoCR,tabulador,'Byron Gerardo Castillo G',OtildadaMinus,'mez',saltoLn,retornoCR,tabulador,tabulador,'20170544',finCadena
;===   ALERTAS   ===  
debug db saltoLn,retornoCR,'Punto Debug...',saltoLn,retornoCR,finCadena
inicioJuego db saltoLn,retornoCR,'Iniciando Partida...',saltoLn,retornoCR,finCadena 
finJuego db saltoLn,retornoCR,'fin de Partida...',saltoLn,retornoCR,finCadena       
salidaJuego db saltoLn,retornoCR,'Saliendo del Juego...',saltoLn,retornoCR,'JUEGO TERMINADO  :)',finCadena
opcionErronea db saltoLn,retornoCR,'La opci',OtildadaMinus,'n ingresada no es correcta',saltoLn,retornoCR,'Debe ingresarla nuevamente:',saltoLn,retornoCR,finCadena 
usuarioAccedido db saltoLn,retornoCR,'Usuario reconocido, accediendo...',saltoLn,retornoCR,finCadena    
usuarioRegistrado db saltoLn,retornoCR,'Usuario registrado, ya puede utilizarlo para jugar',saltoLn,retornoCR,finCadena 
usuarioErroneo db saltoLn,retornoCR,'El usuario no existe!!',saltoLn,retornoCR,finCadena
passErroneo db saltoLn,retornoCR,'El pass es incorrecto!!',saltoLn,retornoCR,finCadena   
usuarioMaxError db saltoLn,retornoCR,'El usuario ingresado sobrepasa el max(7) de caracteres',saltoLn,retornoCR,finCadena
passMaxError db saltoLn,retornoCR,'El pass ingresado sobrepasa el max(4) de digitos o no es del todo num',EtildadaMinus,'rico',finCadena
velocidadErronea db saltoLn,retornoCR,'La velocidad ingresada es incorrecta',saltoLn,retornoCR,finCadena
aperturaArchivoErronea db saltoLn,retornoCR,'Se produjo un fallo al tratar de abrir el fichero',saltoLn,retornoCR,finCadena
lecturaArchivoErronea db saltoLn,retornoCR,'Se produjo un fallo al tratar de leer el fichero',saltoLn,retornoCR,finCadena 
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
			        obtenerLecturaTeclado lectorEntradaTeclado
			        cmp cl,1 ;Si la longitud de entrada es 1 puede ser una opción valida 
			        je distribuirSubMenu ;se manda a validar la opción
			    ErrorEntradaPrincipal:
			        imprimirEnConsola opcionErronea
			        jmp LecturaPrincipal
		seccionIngreso:
		    imprimirEnConsola menuIngreso   
	        verificarIngreso   
		seccionRegistro:
		    imprimirEnConsola menuRegistro
    		    LecturaRegistroUsuario:  
    		        imprimirEnConsola  solicitudUsuario 
    		        reiniciarLectorTeclado            
			        obtenerLecturaTeclado lectorEntradaTeclado 
			        ;VALIDAR EXISTENCIA Y DIMENSION ACTUAL
			    ;ErrorRegistroUsuario:
			    ;    imprimirEnConsola usuarioErroneo
			        ;jmp LecturaIngresoUsuario
			    LecturaRegistroPass:  
			        imprimirEnConsola  solicitudPass 
			        reiniciarLectorTeclado            
			        obtenerLecturaTeclado lectorEntradaTeclado 
			        ;VALIDAR PASS Y DIMENSION ACTUAL
			    ;ErrorRegistroPass:
			    ;    imprimirEnConsola passErroneo
			        ;jmp LecturaIngresoPass 
			    ;VALIDAR ADMIN
			    RegistroExitoso: 
			         imprimirEnConsola usuarioRegistrado
		    jmp  menuInicial 
		seccionTops:
		    imprimirEnConsola menuTops 
		    jmp  menuInicial
		seccionOrdenamientos:
		    imprimirEnConsola menuOrdenamientos 
		    jmp  menuInicial
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
                reiniciarLectorTeclado  
                JMP ErrorEntradaPrincipal 
        errorLecturaArchivo:  
            imprimirEnConsola lecturaArchivoErronea
            jmp  menuInicial      
        errorAperturaArchivo: 
            imprimirEnConsola aperturaArchivoErronea
            jmp  menuInicial
	main endp   
end