
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
    PUSH BX
    chequear:
        call establecerSegmentoDatos
        MOV AH,subFuncionTiempoSistema ;obtenemos el tiempo del sistema
        INT funcionesDOS;CH = hour CL = minute DH = second DL = 1/100 seconds  
        CMP Dl,DS:[Configurador.tiempoActual]  ;Si el milisegundo ecaluado es igual o no al anteriro
        JE chequear    ;Si es igual vuelve a evaluar, si no entonces realiza todo lo demás
        MOV DS:[Configurador.tiempoActual],Dl ;update time
        PUSH CX; se guarda CX por algun otro proceso que lo este empleando durante el juego
        MOV cl, DS:[Configurador.nivelActual]
        MOV ch, DS:[Configurador.nivelActual]
        ;Se les asigna el indicador de nivel ya que mediante su valor se harán N iteraciones,
        ;esto permite que solo se cambie su valor con el paso de nivel y automáticamente
        ;se desplazarán mas veces, viendose asi mas veloz en pantalla
        evaluarTecla: ;solo se emplea segmento de datos estándar
            dec ch
            evaluarAccionesDeTeclas; incluye pausa y movimientos de plataforma
            ;evaluarAccionesDeTeclas;se evalua dos veces para un mayor movimiento y aumentar velocidad
            cmp ch, 0 
            je desplazar
            jmp evaluarTecla 
        desplazar: ; se emplea segmento de datos estándar
            dec cl
            desplazarPelota
            desplazarPelota;se evalua dos veces para un mayor movimiento y aumentar velocidad
            cmp cl, 0 
            je destruccion
            jmp desplazar 
        destruccion:
            ;call delimitarSecuenciaDestruccionBloques
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
    call borrarPelotaActual ;esto borrar el dibujo actual de la pelota (asi no dejará rastro)
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
        call establecerSegmentoDatos
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
    call establecerSegmentoDatos ;necesitamos obtener valores del DS, no del modo video
    evaluacionVertical:
        ;Dependiendo la dirección se evaluará su colisión, solo para rebotes verticales
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
        ;si nos posicionamos en la (fila actual - 1), entonces estamos posicionados
        ;en la parte baja de un posible bloque que este por encima de la pelota  
        MOV dx, bx ;dx debe tener la fila obtenida
        jmp asignarColumna
    evaluarLadoinferior:
        MOV bx, pelota.filaActual 
        ADD bx, pelota.pixelesAlto
        ;Si nos posicionamos en la (fila actual + pixeles Alto) estamos poosicionados en 
        ;la parte superior de un psobile bloque por debajo de la pelota, se consideran los
        ;pixeles de alto ya que es el espacio del punto de dibujo de la 
        ;pelota + el espacio que ocupa verticalmente
        MOV dx, bx;dx debe tener el valor de la fila
    asignarColumna:
        MOV cx, pelota.columnaActual
        ;se asigna la columna actual, mas adelante se evaluará a lo largo de su ancho
    retenerColumnaMaxima:
        ;se necesita saber hasta que columna como máximo actualmente puede eabarcar la pelota
        ;ya que si cualquiera de los puntos a lo largo del ancho de la pelota toca el bloque
        ;entonces debe destruirse
        MOV ax, pelota.columnaActual
        ADD ax, pelota.pixelesAncho 
        PUSH AX ;lo guardamos en la pila de momento
    evaluarColor:
        ;obtenemos el color del pixel en la coordenada obtenida previamente,
        ;dbemos tener la direccion de video activa para el proceso  
        call establecerDireccionVideo
        call obtenerColorPixel
        ;call obtenerColorPorMatrizControl
        call establecerSegmentoDatos
        cmp al, colorNegroGrafico;si el color no equivale al color de fondo entonces es un bloque
        je reevaluacion 
        jmp destruccion
    destruccion:
        call destruirBloqueDesdeOrigen
        jmp fin
    reevaluacion:
        ;se manda a reevaluar ya que la coordenada actual no es parte de un bloque, pero
        ;debemos evaluar las demas a lo largo del ancho de la pelota; este caso no aplica
        ;para cuando una pelota topa esquina con esquina al bloaque, por eso estas se evaluan
        ;previo a las destrucciones verticales u horizomntales
        inc cx ;sea aumenta para evaluar la siguient ecolumna
        POP AX
        PUSH AX
        cmp cx, ax
        ;obtenemos el valor de las columnas maximas que guardamos en la pila, lo volvemos a guardar 
        ;para futuras evaluaciones, y comparamos, si llegamos a ese punto significa que en todo
        ;el ancho de la pelota no topo con un bloque 
        je fin
        jmp evaluarColor
    fin:
        POP CX; se realiza este pop dado que aun sigue guardada en ppila el número de columnas máximas
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
        ;Dependiendo la dirección se evaluará su colisión, solo para rebotes horizotales
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
        MOV cx, bx ;cx debe tener ese valor
        ;si nos posicionamos en la (columna actual - 1), entonces estamos posicionados
        ;a la par de un posible bloque al costado izquierdo de la pelota  
        jmp asignarFila
    evaluarLadoDerecho:
        MOV bx, pelota.columnaActual
        ADD bx, pelota.pixelesAncho
        ;si nos posicionamos en la (columna actual - 1), entonces estamos posicionados
        ;a la par de un posible bloque al costado izquierdo de la pelota  
        MOV cx, bx; cx debe tener ese valor
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
        ;el analisis es similar a las verticales, pero en base a las filas de alto
        ;de la poelota en vez de las columnas de ancho
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