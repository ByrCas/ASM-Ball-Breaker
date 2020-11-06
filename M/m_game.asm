
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
    LOCAL chequear,evaluarTecla, desplazar, destruccion, establecer, fin
    call establecerSegmentoDatos
    PUSH BX
    chequear:
        MOV AH,subFuncionTiempoSistema ;obtenemos el tiempo del sistema
        INT funcionesDOS;CH = hour CL = minute DH = second DL = 1/100 seconds  
        CMP Dl,DS:[Configurador.tiempoActual]  ;Si el milisegundo ecaluado es igual o no al anteriro
        JE chequear    ;Si es igual vuelve a evaluar, si no entonces realiza todo lo demás
        MOV DS:[Configurador.tiempoActual],Dl ;update time
        PUSH CX; se guarda CX por algun otro proceso que lo este empleando durante el juego
        destruccion:
            call delimitarSecuenciaDestruccionBloques
            MOV cl, DS:[Configurador.nivelActual]
            MOV ch, DS:[Configurador.nivelActual]
            ;Se les asigna el indicador de nivel ya que mediante su valor se harán N iteraciones,
            ;esto permite que solo se cambie su valor con el paso de nivel y automáticamente
            ;se desplazarán mas veces, viendose asi mas veloz en pantalla
        evaluarTecla:
            dec ch
            evaluarAccionesDeTeclas; incluye pausa y movimientos de plataforma
            evaluarAccionesDeTeclas;se evalua dos veces para un mayor movimiento y aumentar velocidad
            cmp ch, 0 
            je desplazar
            jmp evaluarTecla 
        desplazar:
            dec cl
            desplazarPelota
            desplazarPelota;se evalua dos veces para un mayor movimiento y aumentar velocidad
            cmp cl, 0 
            je establecer
            jmp desplazar 
        establecer:    
            call establecerSegmentoDatos
            ; se establece ese segmento para las siguiedntes acciones
            ;y por si se debe volver a chequear
            POP CX; recuperamos su valor
            MOV bl, indicadorJuegoInactivo 
            cmp bl, DS:[Configurador.estadoJuego]
            je fin
            JMP chequear ;volvemos a evaluar
    fin:
        POP BX
endm

desplazarPelota macro 
    LOCAL desplazarNoreste, desplazarNoroeste, desplazarSureste, desplazarSuroeste, fin
    PUSH AX; se usara el registro al, pero se usa la pila para no alterar su valor de uso en otras macros 
    call borrarPelotaActual ;esto borraráel biujo actual de la peloya (asi no dejará rastro)
    call establecerSegmentoDatos;necesitamos esa ubicación para el uso de las variables
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

evaluarAccionesDeTeclas macro
    LOCAL evaluarTeclaActiva,evaluarPausa, evaluarTopeIzquierdo, evaluarTopeDerecho, desplazarIzquierda, desplazarDerecha, fin
    PUSH AX
    evaluarTeclaActiva:
        XOR ax, ax
        MOV ah, subFuncionEstadoTeclado; solo verifica si se ingreso una tecla
        int funcionesTeclado; la bandera zero se alrtera a 1 si no fue presionado nada
        jz fin;si bandera Z=1,como no fue presionado nada no se busca ejecutar lo demás
        cmp al, teclaMinusculaA
        je evaluarTopeIzquierdo
        cmp al, teclaMinusculaD
        je evaluarTopeDerecho
        cmp al, teclaMinusculaP; se considerará como acceso a la pausa del juego
        je evaluarPausa
        jmp fin;
    ;EJECUCIÓN DE PAUSA:
    evaluarPausa:
        call retenerPausaEvaluada
        jmp fin
    ;MOVIMIENTOS PLATAFORMA:    
    evaluarTopeIzquierdo:
        MOV ax, plataformaMovible.columnaActual
        dec ax;ax será la columna del margen minimo vertical si se encuentra la plataforma a la par;
        cmp ax, posMargenMinimoVertical
        je fin; si equivale no hace nada(no podria pasar), si no entonces si se mueve    
    desplazarIzquierda:
        call moverLadoIzquierdoPlataforma
        jmp fin
    evaluarTopeDerecho:
        MOV ax, plataformaMovible.columnaActual
        add ax, plataformaMovible.pixelesAncho
        ;ax será la columna del margen maximo vertical si se encuentra la plataforma a la par
        ;ya que es el lado derecho se considerá el ancho de la plataforma
        cmp ax, posMargenMaximoVertical
        je fin; si equivale no hace nada(no podria pasar), si no entonces si se mueve 
    desplazarDerecha:
        call moverLadoDerechoPlataforma
        jmp fin
    fin:
        call limpiarBufferEntradaTeclado
        POP AX
endm

evaluarRebotesVerticalesDestructivos macro  
    LOCAL evaluacionVertical, evaluarLadoSuperior, evaluarLadoinferior, retenerColumnaMaxima, asignarColumna,  evaluarColor, destruccion, reevaluacion, fin
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    call establecerSegmentoDatos
    evaluacionVertical:
        cmp pelota.estadoDireccion, direccionNoresteActiva
        je evaluarLadoSuperior
        cmp pelota.estadoDireccion, direccionNoroesteActiva
        je evaluarLadoSuperior
        cmp pelota.estadoDireccion, direccionSuresteActiva
        je evaluarLadoinferior
        cmp pelota.estadoDireccion, direccionSuroesteActiva
        je evaluarLadoinferior
    evaluarLadoSuperior:
        MOV bx, pelota.filaActual
        dec bx
        MOV dx, bx 
        jmp asignarColumna
    evaluarLadoinferior:
        MOV bx, pelota.filaActual
        ADD bx, pelota.pixelesAlto
        MOV dx, bx
    asignarColumna:
        MOV cx, pelota.columnaActual
    retenerColumnaMaxima:
        MOV ax, pelota.columnaActual
        ADD ax, pelota.pixelesAncho
        PUSH AX 
    evaluarColor:
        call establecerDireccionVideo
        call obtenerColorPixel
        ;call obtenerColorPorMatrizControl
        call establecerSegmentoDatos
        cmp al, colorNegroGrafico
        je reevaluacion 
        jmp destruccion
    destruccion:
        call destruirBloqueDesdeOrigen
        jmp fin
    reevaluacion:
        inc cx
        POP AX
        PUSH AX
        cmp cx, ax
        je fin
        jmp evaluarColor
    fin:
        POP CX
        POP DX
        POP CX
        POP BX
        POP AX
endm

evaluarRebotesHorizontalesDestructivos macro  
    LOCAL evaluacionHorizontal, evaluarLadoIzquierdo, evaluarLadoDerecho, retenerFilaMaxima, asignarFila,  evaluarColor, destruccion, reevaluacion, fin
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    call establecerSegmentoDatos
    evaluacionHorizontal: 
        call establecerSegmentoDatos
        cmp pelota.estadoDireccion, direccionNoresteActiva
        je evaluarLadoDerecho
        cmp pelota.estadoDireccion, direccionNoroesteActiva
        je evaluarLadoIzquierdo
        cmp pelota.estadoDireccion, direccionSuresteActiva
        je evaluarLadoDerecho
        cmp pelota.estadoDireccion, direccionSuroesteActiva
        je evaluarLadoIzquierdo
    evaluarLadoIzquierdo:
        MOV bx, pelota.columnaActual
        dec bx
        MOV cx, bx 
        jmp asignarFila
    evaluarLadoDerecho:
        MOV bx, pelota.columnaActual
        ADD bx, pelota.pixelesAncho
        MOV cx, bx
    asignarFila:
        MOV dx, pelota.filaActual
    retenerFilaMaxima:
        MOV ax, pelota.filaActual
        ADD ax, pelota.pixelesAlto
        PUSH AX 
    evaluarColor:
        call establecerDireccionVideo
        call obtenerColorPixel
        ;call obtenerColorPorMatrizControl
        call establecerSegmentoDatos
        cmp al, colorNegroGrafico
        je reevaluacion 
        jmp destruccion
    destruccion:
        call destruirBloqueDesdeOrigen
        jmp fin
    reevaluacion:
        inc dx
        POP AX
        PUSH AX
        cmp dx, ax
        je fin
        jmp evaluarColor
    fin:
        POP DX
        POP DX
        POP CX
        POP BX
        POP AX
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