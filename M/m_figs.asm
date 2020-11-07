
;================ MACROS ==============================

pintarBytePixel macro color, posFila, posColumna 
    ;Ya que se maneja la memoria de video vamos a manejar la matriz
    ;linealizada de pixeles, y dado que su mapeo es por filas entonces
    ;se calcula de su nueva posición mediante:
    ;posMapeada = (posFila) * tamañoFila + posColumna
    PUSH SI
    PUSH DI
    PUSH CX
    PUSH BX 
    PUSH AX
    PUSH DX 
    ;hacemos un push de los registros ya que la mayoria de ellos se emplean en procesos 
    ;posteriorers con su  valor original, y en el proceso de calculo y pintado
    ;se modificarian perdiendo su valor
    MOV ax, posFila
    MOV cx, tamanioFila
    mul cx
    add ax, posColumna
    MOV di, ax
    POP DX  ;recuperamos el valor del color original de dl
    mov [di], dl
    ;call establecerSegmentoDatos
    ;MOV DS:[Configurador.controladorDeColores[di]], dl
    POP AX
    POP BX
    POP CX
    POP DI
    POP SI
endm

limpiarEscenario macro
    LOCAL pintar, final
    PUSH CX
    PUSH DX
    PUSH DI
    xor di, di
    xor cx, cx
    MOV dl, colorNegroGrafico
    pintar:
        mov [di], dl
        inc di
        inc cx
        cmp cx, pixelesTotales ;64,000
        je final
        jmp pintar  
    final:
        POP DI
        POP DX
        POP CX
endm

moverCursor macro 
    ;Rquiere en DH la fila y en DL la columna
    MOV AH,02H
    MOV BH, 00H
    int funcionesDespligueVideo
endm

dibujarLineaVertical macro
    ;En base a las posciones que se delimiten en los registros se dibuja el elemento
    LOCAL dibujar, final
    PUSH SI
    PUSH DI
    xor si, si
    dibujar:
        pintarBytePixel dl, ax ,bx; dl = color, ax = fila, bx = columna  
        inc ax ;se incrementa la fila para que avance verticalmente
        inc si
        cmp si, di; di= numpixeles
        je final
        jmp dibujar 
    final:
        POP DI
        POP SI
endm

dibujarLineaHorizontal macro
    ;En base a las posciones que se delimiten en los registros se dibuja el elemento
    LOCAL dibujar, final
    PUSH SI
    PUSH DI
    xor si, si
    dibujar:
        pintarBytePixel dl, ax ,bx; dl = color, ax = fila, bx = columna  
        inc bx ;se incrementa la columna para que avance horizontalmente
        inc si
        cmp si, di; di= numpixeles
        je final
        jmp dibujar 
    final:
        POP DI
        POP SI
endm

dibujarBloque macro
    ;En base a las posiciones que se delimiten en los registros se dibuja el elemento
    LOCAL dibujar, final
    PUSH CX
    MOV cl, 0
    dibujar:
        PUSH AX;durante el trazado del dibujo estos registros se emplean, 
        PUSH BX ;por lo que guardamos su valor original
        dibujarLineaHorizontal  
        POP BX ;ahora podemos obtener la fila y columna originales orevias
        POP AX
        inc ax ;se incrementa la fila para que avance verticalmente
        inc cl
        cmp cl, alturaBloque;Es el número de lineas que formasn un bloque
        je final
        jmp dibujar
    final:
        POP CX
endm

borrarBloque macro
    ;En base a las posiciones que se delimiten en los registros se dborrará el elemento
    ;se coloca el color de fondo, no es en si una limpieza pura
    LOCAL dibujar, final
    PUSH CX
    PUSH DX
    MOV cl, 0
    MOV dl, colorNegroGrafico
    dibujar:
        PUSH AX;durante el trazado del dibujo estos registros se emplean, 
        PUSH BX ;por lo que guardamos su valor original
        dibujarLineaHorizontal  
        POP BX ;ahora podemos obtener la fila y columna originales orevias
        POP AX
        inc ax ;se incrementa la fila para que avance verticalmente
        inc cl
        cmp cl, alturaBloque;Es el número de lineas que formasn un bloque
        je final
        jmp dibujar
    final:
        POP DX
        POP CX
endm

dibujarContornosVerticales macro
    ;Nos posicionamos en la fila ax u en la columna bx,
    ;y con di indicamos cuantos pixeles vamos a pintar
    ;verticalmente a partir de ese punto
    MOV dl, colorBlancoGrafico
    MOV ax, posMargenMinimoHorizontal
    MOV bx, posMargenMinimoVertical
    MOV di, longitudMargenVertical
    dibujarLineaVertical  
    ;MOV dl, colorBlancoGrafico
    MOV ax, posMargenMinimoHorizontal
    MOV bx, posMargenMaximoVertical
    MOV di, longitudMargenVertical
    dibujarLineaVertical 
endm

dibujarContornosHorizontales macro
    ;Nos posicionamos en la fila ax u en la columna bx,
    ;y con di indicamos cuantos pixeles vamos a pintar
    ;horizontalmente a partir de ese punto
    MOV dl, colorBlancoGrafico
    MOV ax, posMargenMinimoHorizontal
    MOV bx, posMargenMinimoVertical
    MOV di, longitudMargenHorizontal
    dibujarLineaHorizontal
   ; MOV dl, colorBlancoGrafico
    MOV ax, posMargenMaximoHorizontal
    MOV bx, posMargenMinimoVertical
    MOV di, longitudMargenHorizontal
    dibujarLineaHorizontal
endm

dibujarPelota macro
    ;En base a las posciones que se delimiten en los registros se dibuja el elemento
    LOCAL dibujar, final
    PUSH CX
    MOV cl, 0
    dibujar:
        PUSH AX
        PUSH BX
        dibujarLineaHorizontal  
        POP BX
        POP AX
        inc ax ;se incrementa la columna para que avance horizontalmente
        inc cl
        cmp cl, alturaPelota;Es el número de lineas que formasn una pelota
        je final
        jmp dibujar
    final:
        POP CX
endm

probarBarra macro
    MOV dl, colorBlancoGrafico
    MOV ax, 175;0f; 159
    MOV bx, 15 ;63h; 99
    MOV di, 50
    dibujarBarraDinamica
    dibujarLimitesBarra
endm

dibujarLimitesBarra macro
    MOV dl, colorBlancoGrafico
    MOV ax, 25;0f; 159
    MOV bx, 15 ;63h; 99
    MOV di, 290
    dibujarLineaHorizontal
    MOV ax, 175;0f; 159
    MOV bx, 15 ;63h; 99
    MOV di, 290
    dibujarLineaHorizontal
endm

dibujarBarraDinamica macro
    ;DI deberá tener asignado la cantidad de pixeles de ancho
    LOCAL dibujar, final
    PUSH CX
    MOV cl, 0
    dibujar:
        PUSH AX
        PUSH BX
        dibujarLineaHorizontal  
        POP BX
        POP AX
        dec ax ;se reduce la fils para que retroceda verticalmente
        inc cl
        cmp cl, 150;Es el número de lineas que formasn una pelota
        je final
        jmp dibujar
    final:
        POP CX
endm
