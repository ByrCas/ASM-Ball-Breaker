
;================ SECCIÓN DE MACROS ============================== 
salirPrograma macro 
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
imprimirEnConsola tituloJuego
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
ItildadaMinus EQU 0A1h ;A2H -> 162 -> ó
OtildadaMinus EQU 0A2h ;A2H -> 162 -> ó 
finCadena EQU 24h ;24h-> 36 -> $     
  
;=== INTERRUPCIONES EQUIVALENTES === 
subFuncionVerCadena EQU 09h ;09h -> 9 -> Visualización de una cadena d ecaracteres  
subFuncionFinPrograma EQU 4ch ;4ch -> 76 -> Terminación de Programa con Código de Retorno
funcionesDOS EQU 21h ;21h -> 33 -> petición de función al DOS  
  
;=== CADENAS PARA MENSAJES EN CONSOLA ===                                         
tituloJuego db saltoLn,retornoCR,'!*!*!*!*!*!*! ASM BALL BREAKER !*!*!*!*!*!*!*!*!',finCadena 
lineaSeparadora db saltoLn,retornoCR,'!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!',saltoLn,finCadena  
inicioJuego db saltoLn,retornoCR,'Iniciando Partida...',finCadena 
finJuego db saltoLn,retornoCR,'fin de Partida...',finCadena 
datosCurso db saltoLn,retornoCR, 'Universidad de San Carlos de Guatemala', saltoLn,retornoCR,'Facultad de Ingenier',ItildadaMinus,'a', saltoLn,retornoCR,'Arquitectura de Computadores y Ensambladores 1', saltoLn,retornoCR,'Segundo Semestre 2020', saltoLn,retornoCR,'Secci',OtildadaMinus,'n: A', saltoLn,retornoCR,'Proyecto 2', saltoLn,retornoCR,finCadena                                                                                
misDatos db saltoLn,retornoCR,tabulador,'Byron Gerardo Castillo G',OtildadaMinus,'mez',saltoLn,retornoCR,tabulador,tabulador,'20170544',finCadena


;================== SEGMENTO DE CODIGO ===========================
.code 
    asignarDIreccionDatos:
       MOV dx,@data ; Dirección del segmento de datos
	   MOV ds,dx 
	main proc
		IniciarPrograma:
		    mostrarEncabezado
			mostrarMenuPrincipal    
		Salir: 
			salirPrograma
	main endp
end