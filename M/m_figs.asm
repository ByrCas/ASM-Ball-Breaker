
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
    POP AX
    POP BX
    POP CX
    POP DI
    POP SI
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
        cmp cl, alturaBloque;Es el número de lineas que formasn un bloque
        je final
        jmp dibujar
    final:
        POP CX
endm

dibujarContornosVerticales macro
    ;Nos posicionamos en la fila ax u en la columna bx,
    ;y con di indicamos cuantos pixeles vamos a pintar
    ;verticalmente a partir de ese punto
    MOV dl, colorBlancoGrafico
    MOV ax, 19;0f; 159
    MOV bx, 5 ;63h; 99
    MOV di, 175
    dibujarLineaVertical  
    MOV dl, colorBlancoGrafico
    MOV ax, 19;0f; 159
    MOV bx, 314 ;63h; 99
    MOV di, 175
    dibujarLineaVertical 
endm

dibujarContornosHorizontales macro
    ;Nos posicionamos en la fila ax u en la columna bx,
    ;y con di indicamos cuantos pixeles vamos a pintar
    ;horizontalmente a partir de ese punto
    MOV dl, colorBlancoGrafico
    MOV ax, 19;0f; 159
    MOV bx, 5 ;63h; 99
    MOV di, 310
    dibujarLineaHorizontal
    MOV dl, colorBlancoGrafico
    MOV ax, 194;0f; 159
    MOV bx, 5 ;63h; 99
    MOV di, 310
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
