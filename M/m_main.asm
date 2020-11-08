
;================ MACROS DE FUNCIONES PRINCIPALES DEL PROGRAMA============================== 

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
    imprimirEnConsola tituloJuego   
    imprimirEnConsola menuPrincipal
endm  

;=============ASCII==============

incrementarValorASCIICadena macro vector
    LOCAL asignarDiferenciaASCII, fin
    MOV DI, 0
    asignarDiferenciaASCII:
        MOV Al, vector[DI]
        ADD Al, diferenciaASCII
        MOV vector[DI], Al
        inc DI
        cmp vector[DI], finCadena
        je fin
        jmp asignarDiferenciaASCII
    fin:
endm

reducirValorASCIICadena macro vector
    LOCAL desasignarDiferenciaASCII, fin
    MOV DI, 0
    desasignarDiferenciaASCII:
        MOV Al, vector[DI]
        SUB Al, diferenciaASCII
        MOV vector[DI], Al
        inc DI
        cmp vector[DI], finCadena
        je fin
        jmp desasignarDiferenciaASCII
    fin:
endm


