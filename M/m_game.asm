
;================ MACROS DEL JUEGO PRINCIPAL============================== 

chequearCambios macro
    LOCAL chequear,ajustarRetardo, evaluarCronometro,ajustarNivel,evaluarTecla, desplazar, destruccion, establecer, fin
    PUSH BX
    chequear:
        call establecerSegmentoDatos
        MOV AH,subFuncionTiempoSistema ;obtenemos el tiempo del sistema
        INT funcionesDOS;CH = hour CL = minute DH = second DL = 1/100 seconds  
        CMP Dl,DS:[Configurador.tiempoActualMilis]  ;Si el milisegundo ecaluado es igual o no al anteriro
        JE chequear    ;Si es igual vuelve a evaluar, si no entonces realiza todo lo demás
        MOV DS:[Configurador.tiempoActualMilis],Dl ;update time
        evaluarCronometro:
            CMP DH,DS:[Configurador.tiempoActualSegs]  ;Si el milisegundo ecaluado es igual o no al anteriro
            JE ajustarRetardo    ;Si es igual vuelve a evaluar, si no entonces realiza todo lo demás
            call plasmarCronometro
            MOV DS:[Configurador.tiempoActualSegs],DH ;update time
        ajustarRetardo:
            MOV CL, DS:[Configurador.nivelActual] 
            ;el nivel indicarpa el nupmero de veces que se ejecutará todo el proceso por milisefundo
            ; mientras mas grande sea el nivel, mas iteraciones tendrá y serán mas veloces.
            ;los movimientos
            inc cl ;se incrementa uno para mayor velocidad
            inc cl
        finalizarRepeticiones:
           cmp cl, 0 ;hasta que se terminen las iteraciones vuelve a evaluar el cambio de milisegundo
            je chequear
        evaluarTecla: ;solo se emplea segmento de datos estándar
            evaluarAccionesDeTeclas; incluye pausa y movimientos de plataforma
        desplazar: ; se emplea segmento de datos estándar
            desplazarPelota
        destruccion:
            call delimitarSecuenciaDestruccionBloques
        establecer:    
            call establecerSegmentoDatos
            ; se establece ese segmento para las siguiedntes acciones
            ;y por si se debe volver a chequear
            dec cl
            MOV bl, indicadorJuegoInactivo 
            cmp bl, DS:[Configurador.estadoJuego]
            je fin
            JMP finalizarRepeticiones
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
    LOCAL repetirIzquierda, repetirDerecha, evaluarTeclaActiva,evaluarPausa, evaluarTopeIzquierdo, evaluarTopeDerecho, desplazarIzquierda, desplazarDerecha, fin
    PUSH AX
    PUSH CX
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
        MOV cl, DS:[Configurador.nivelActual]
        add cl, 4 ;sirve para que uere mas veces el movimiento y se aprecie mas veloz
        repetirIzquierda:
            dec cl
            MOV ax, plataformaMovible.columnaActual
            dec ax;ax será la columna del margen minimo vertical si se encuentra la plataforma a la par;
            cmp ax, posMargenMinimoVertical
            je fin; si equivale no hace nada(no podria pasar), si no entonces si se mueve    
        desplazarIzquierda:
            call moverLadoIzquierdoPlataforma
            cmp cl, 0
            je fin
            jmp repetirIzquierda
    evaluarTopeDerecho:
        MOV cl, DS:[Configurador.nivelActual]
        add cl, 4 ;sirve para que uere mas veces el movimiento y se aprecie mas veloz
        repetirDerecha:
            dec cl
            MOV ax, plataformaMovible.columnaActual
            add ax, plataformaMovible.pixelesAncho
            ;ax será la columna del margen maximo vertical si se encuentra la plataforma a la par
            ;ya que es el lado derecho se considerá el ancho de la plataforma
            cmp ax, posMargenMaximoVertical
            je fin; si equivale no hace nada(no podria pasar), si no entonces si se mueve 
    desplazarDerecha:
            call moverLadoDerechoPlataforma
            cmp cl, 0
            je fin
            jmp repetirDerecha
    fin:
        call limpiarBufferEntradaTeclado
        POP CX
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
        inc bx
        inc bx
        ;Si nos posicionamos en la (fila actual + pixeles Alto) estamos poosicionados en 
        ;la parte superior de un posible bloque por debajo de la pelota, se consideran los
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
        ;call establecerDireccionVideo
        ;call obtenerColorPixel
        call obtenerColorPorMatrizControl
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
        inc bx
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
        ;call establecerDireccionVideo
        ;call obtenerColorPixel
        call obtenerColorPorMatrizControl
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
    LOCAL incorporarUsuario, separarUsuario, separarPuntaje, incorporarNivel, incorporarTiempo, incorporarSeparador 
    PUSH SI
    PUSH DI
    xor si, si
    xor di, di
    MOV dl, 1 ;indica que se use la ruta del archivo de indice 1 (Rounds.txt)
    MOV bl, 1 ;indicador de apertura y lectura del archivo 
    reiniciarEscritorFicheros
    accionarArchivoEnrutado dl, bl ;se abre el contenido de el archivo
    MOV CX, 0 ;permitira llevar la cuenta d ebytes/caracteres a escribur enn el fichero
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
        MOV bl, DS:[Configurador.nivelActual[0]]; esto dado que solo es un digito 
        ADD BL, diferenciaASCII
        MOV escritorFicheroActual[si], bl
        inc si
        inc cx
        MOV escritorFicheroActual[si], coma;separador
        inc si   
        inc cx   
        xor di, di
    incorporarPuntaje:
        MOV bl, visorPuntos[di]
        ADD BL, diferenciaASCII
        MOV escritorFicheroActual[si],bl 
        inc si
        inc di
        inc cx
        cmp visorPuntos[di], 40h ; letra @, yaa que el vector tiene 000pts -> 000@
        je separarPuntaje
        jmp incorporarPuntaje
    separarPuntaje:
        MOV escritorFicheroActual[si], coma
        inc si
        inc cx 
        xor di,di
    incorporarTiempo:
        MOV bl, tiempoEstable[di]
        ADD BL, diferenciaASCII
        MOV escritorFicheroActual[si],bl 
        inc si
        inc di
        inc cx
        cmp tiempoEstable[di], finCadena ; letra "p", yaa que el vector tiene 000pts
        je incorporarSeparador
        jmp incorporarTiempo
    incorporarSeparador:
        MOV escritorFicheroActual[si], puntoComa 
        inc cx
        inc si 
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
    adjuntarPartida 
endm