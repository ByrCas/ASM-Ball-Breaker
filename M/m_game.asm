
;================ MACROS DEL JUEGO PRINCIPAL============================== 

;MOV AH,00h ;set the configuration to video mode
;MOV AL,13h ;choose the video mode
;INT 10h    ;execute the configuration 

;MOV AH,0Bh ;set the configuration
;MOV BH,00h ;to the background color
;MOV BL,00h ;choose black as background color
;INT 10h    ;execute the configuration

;MOV AH,0Ch ;set the configuration to writing a pixel
;MOV AL,0Fh ;choose white as color
;MOV BH,00h ;set the page number 
;MOV CX,0Ah ;set the column (X)
;MOV DX,0Ah ;set the line (Y)
;INT 10h    ;execute the configuration

;CHECK_TIME:
		
;			MOV AH,2Ch ;get the system time
;			INT 21h    ;CH = hour CL = minute DH = second DL = 1/100 seconds
;			
;			CMP DL,TIME_AUX  ;is the current time equal to the previous one(TIME_AUX)?
;			JE CHECK_TIME    ;if it is the same, check again
;			;if it's different, then draw, move, etc.
;			
;			MOV TIME_AUX,DL ;update time
;
;			CALL DRAW_BALL 
;			
;			JMP CHECK_TIME ;after everything checks time again

chequearCambios macro
    LOCAL chequear, desplazar, establecer, fin
    call establecerSegmentoDatos
    chequear:
        MOV AH,2Ch ;get the system time
        INT 21h    ;CH = hour CL = minute DH = second DL = 1/100 seconds
        
        CMP Dl,DS:[Configurador.tiempoActual]  ;is the current time equal to the previous one(TIME_AUX)?
        JE chequear    ;if it is the same, check again
        ;if it's different, then draw, move, etc.
        MOV DS:[Configurador.tiempoActual],Dl ;update time
        PUSH CX; se guarda CX por algun otro proceso que lo este empleando durante el juego
        MOV cl, DS:[Configurador.nivelActual]
        desplazar:
            dec cl
            desplazarPelota
            desplazarPelota
            cmp cl, 0 
            je establecer
            jmp desplazar 
        establecer:    
            call establecerSegmentoDatos
            POP CX; recuperamos su valor
            cmp cl, 10
            je fin
            JMP chequear ;after everything checks time again
    fin:
endm

desplazarPelota macro 
    LOCAL desplazarNoreste, desplazarNoroeste, desplazarSureste, desplazarSuroeste, fin
    PUSH AX; se usara el registro al, pero se usa la pila para no alterar su valor de uso en otras macros 
    call borrarPelotaActual
    call establecerSegmentoDatos
    cmp pelota.estadoDireccion, direccionNoresteActiva
    je desplazarNoreste
    cmp pelota.estadoDireccion, direccionNoroesteActiva
    je desplazarNoroeste
    cmp pelota.estadoDireccion, direccionSuresteActiva
    je desplazarSureste
    cmp pelota.estadoDireccion, direccionSuroesteActiva
    je desplazarSuroeste
    desplazarNoroeste:
        MOV pelota.estadoDireccion, direccionNoroesteActiva ;aseguramos la dirección en uso
        MOV ax, pelota.columnaActual ;como se mueve a lado derecho se debe incluir su ancho para llegar al tope
        dec ax ;si esta a usa posición del tope izquierdo se cambia dirección
        cmp ax, posMargenMinimoVertical
        je desplazarNoreste;activamos su inversa si llegó al tope derecho
        MOV ax, pelota.filaActual
        dec ax  ;si esta a usa posición del tope superior se cambia dirección
        cmp ax, posMargenMinimoHorizontal
        je  desplazarSuroeste
        dec pelota.filaActual
        dec pelota.columnaActual
        jmp fin
    desplazarNoreste:
        MOV pelota.estadoDireccion, direccionNoresteActiva ;aseguramos la dirección en uso
        MOV ax, pelota.pixelesAncho ;como se mueve a lado derecho se debe incluir su ancho para llegar al tope
        ADD ax, pelota.columnaActual ;el ancho mas la columna actual, si es igual al margen estará topanpo
        cmp ax, posMargenMaximoVertical
        je desplazarNoroeste;activamos su inversa si llegó al tope derecho
        MOV ax, pelota.filaActual
        dec ax  ;si esta a usa posición del tope superior se cambia dirección
        cmp ax, posMargenMinimoHorizontal
        je  desplazarSureste
        dec pelota.filaActual
        inc pelota.columnaActual
        jmp fin
    desplazarSureste:
        MOV pelota.estadoDireccion, direccionSuresteActiva ;aseguramos la dirección en uso
        MOV ax, pelota.pixelesAncho ;como se mueve a lado derecho se debe incluir su ancho para llegar al tope
        ADD ax, pelota.columnaActual ;el ancho mas la columna actual, si es igual al margen estará topanpo
        cmp ax, posMargenMaximoVertical
        je desplazarSuroeste;activamos su inversa si llegó al tope derecho
        MOV ax, pelota.filaActual
        ADD ax, pelota.pixelesAlto; se considera el espacio que ocupa de alto la pelota
        cmp ax, posMargenMaximoHorizontal
        je  desplazarNoreste
        inc pelota.filaActual
        inc pelota.columnaActual
        jmp fin
    desplazarSuroeste:
        MOV pelota.estadoDireccion, direccionSuroesteActiva ;aseguramos la dirección en uso
        MOV ax, pelota.columnaActual ;como se mueve a lado izquierdo para llegar al tope
        dec ax ;si esta a usa posición del tope izquierdo se cambia dirección
        cmp ax, posMargenMinimoVertical
        je desplazarSureste;activamos su inversa si llegó al tope derecho
        MOV ax, pelota.filaActual
        ADD ax, pelota.pixelesAlto; se considera el espacio que ocupa de alto la pelota
        cmp ax, posMargenMaximoHorizontal
        je  desplazarNoroeste
        inc pelota.filaActual
        dec pelota.columnaActual
        jmp fin
    fin:
        call establecerDireccionVideo
        call dibujarPelotaEstandar
        POP AX ;obtenemos su valor original

endm


actualizarDatosPartida macro nivel, puntaje, tiempo
    MOV DS:[Configurador.nivelActual], nivel
    MOV DS:[Configurador.puntajeActual], puntaje
    MOV DS:[Configurador.tiempoActual], tiempo
endm

adjuntarPartida macro
    LOCAL incorporarUsuario, separarUsuario, incorporarNivel, incorporarTiempo, incorporarSeparador 
    PUSH SI
    PUSH DI
    xor si, si
    xor di, di
    MOV dl, 1 ;indica que se use la ruta del archivo de indice 1 (Rounds.txt)
    MOV bl, 1 ;indicador de apertura y lectura del archivo 
    reiniciarEscritorFicheros
    accionarArchivoEnrutado dl, bl ;se abre el contenido de se archivo
    MOV CX, 0
    incorporarUsuario:
        MOV bl, lectorEntradaUsuario[di]
        MOV escritorFicheroActual[si],bl 
        inc si
        inc di
        inc cx
        cmp lectorEntradaUsuario[di], finCadena
        je separarUsuario
        jmp incorporarUsuario
    separarUsuario:
        MOV escritorFicheroActual[si], coma
        inc si
        inc cx  
    incorporarNivel:
        MOV bl, DS:[Configurador.nivelActual] 
        MOV escritorFicheroActual[si], bl
        inc si
        inc cx
        MOV escritorFicheroActual[si], coma;separador
        inc si   
        inc cx   
    incorporarPuntaje:
        MOV bl, DS:[Configurador.puntajeActual]
        MOV escritorFicheroActual[si],  bl
        inc si
        inc cx
        MOV escritorFicheroActual[si], coma;separador
        inc si   
        inc cx 
    incorporarTiempo:
        MOV bl, DS:[Configurador.tiempoActual]
        MOV escritorFicheroActual[si], bl 
        inc si
        inc cx
        MOV escritorFicheroActual[si], puntoComa;separador
        inc si   
        inc cx 
    incorporarSeparador:
        MOV escritorFicheroActual[si], retornoCR 
        inc cx
        inc si  
        MOV escritorFicheroActual[si], saltoLn
        inc cx             
    adjuntarContenidoArchivo cx,escritorFicheroActual,controladorFicheros
    cerrarArchivo controladorFicheros;
    MOV dl, 1
    reiniciarLectorTeclado dl;reinicia el arreglo que almacena el usuario
    xor si, si
    xor di,di
    POP DI
    POP SI
endm



finalizarJuego macro
    ;validar separación de digitos de los puntos y tiempos
    MOV dl, 31h
    MOV bl, 32h
    MOV al, 33h
    actualizarDatosPartida dl, bl, al
    adjuntarPartida 
endm