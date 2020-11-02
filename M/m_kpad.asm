
;================ MACROS DE RECONOCIMIENTO DE TECLADO============================== 

obtenerTecla macro
    mov ah,subFuncionLeerCaracter
    int funcionesDOS
endm
       
obtenerLecturaTeclado macro arregloLector  
    LOCAL leerTecla, finalizar 
    PUSH SI
    PUSH AX
    xor si,si;Bits de SI en 0 
    MOV cl,0 ;cntador de teclas ingresadas 
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

reiniciarLectorTeclado macro indicador  
    LOCAL borrarTecladoGeneral, borrarTecladoUsuario, borrarTecladoPass, borrarTecladoTop, borrarTecladoOrden, borrarTecladoOrdenamiento, borrarTecladoVelocidad, Fin
    PUSH SI  
    xor si,si;Bits de SI en 0 
    cmp indicador, 0
    je borrarTecladoGeneral 
    cmp indicador, 1  
    je borrarTecladoUsuario 
    cmp indicador, 2
    je borrarTecladoPass
    cmp indicador, 3
    je borrarTecladoTop
    cmp indicador, 4
    je borrarTecladoOrden
    cmp indicador, 5
    je borrarTecladoOrdenamiento
    cmp indicador, 6
    je borrarTecladoVelocidad 
    borrarTecladoGeneral:
        MOV lectorEntradaTeclado[si], finCadena 
        inc si
        cmp si, 14h;tamaño lector
        jl borrarTecladoGeneral 
        jmp Fin
    borrarTecladoUsuario:
        MOV lectorEntradaUsuario[si], finCadena 
        inc si
        cmp si, 14h  ;tamaño lector
        jl borrarTecladoUsuario   
        jmp Fin
    borrarTecladoPass:
        MOV lectorEntradaPass[si], finCadena 
        inc si
        cmp si, 14h;tamaño lector
        jl borrarTecladoPass 
        jmp Fin
    borrarTecladoTop:
        MOV lectorEntradaTop[si], finCadena 
        inc si
        cmp si, 14h;tamaño lector
        jl borrarTecladoTop 
        jmp Fin
    borrarTecladoOrden:
        MOV lectorEntradaOrden[si], finCadena 
        inc si
        cmp si, 14h;tamaño lector
        jl borrarTecladoOrden 
        jmp Fin 
    borrarTecladoOrdenamiento:
        MOV lectorEntradaOrdenamiento[si], finCadena 
        inc si
        cmp si, 14h;tamaño lector
        jl borrarTecladoOrdenamiento 
        jmp Fin
    borrarTecladoVelocidad:
        MOV lectorEntradaVelocidad[si], finCadena 
        inc si
        cmp si, 14h;tamaño lector
        jl borrarTecladoVelocidad             
    Fin:    
        POP SI
endm 