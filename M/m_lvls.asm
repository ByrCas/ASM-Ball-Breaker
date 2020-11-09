

dibujarCaparazon macro ;obstaculos de nivel 1
    MOV DS:[Configurador.bloquesGenerados], 0; se inicializa en 0 para que pueda incrementar o reducir la cuenta
    call establecerDireccionVideo
    MOV di, anchoBloque ; las lineas horizontales del bloque tendran 20 pixeles de longitud
    dibujarContornoCaparazon
    dibujarPrimeraCapaCaparazon
    ;dibujarSegundaCapaCaparazon
    dibujarTerceraCapaCaparazon
    ;dibujarCuartaCapaCaparazon
    call establecerSegmentoDatos
endm

dibujarCaja macro 
    MOV DS:[Configurador.bloquesGenerados], 0
    call establecerDireccionVideo
    MOV di, anchoBloque ; las lineas horizontales del bloque tendran 20 pixeles de longitud
    dibujarInterrogacion
    dibujarBordesHorizontales
    dibujarBordesVerticales
    call establecerSegmentoDatos
endm

dibujarMensajeColorido macro
    MOV DS:[Configurador.bloquesGenerados], 0
    call establecerDireccionVideo
    MOV di, anchoBloque ; las lineas horizontales del bloque tendran 20 pixeles de longitud
    dibujarLetraA
    dibujarLetraR
    dibujarLetraQ
    dibujarNumUno
    call establecerSegmentoDatos
endm

dibujarContornoCaparazon macro
    MOV dl, colorBlancoGrafico
    MOV ax, 50 ;fila
    MOV bx, 50  ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50
    MOV bx, 80
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50
    MOV bx, 110
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 50
    MOV bx, 140
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50
    MOV bx, 170 
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 50
    MOV bx, 200 
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50
    MOV bx, 230 
    dibujarBloque
    call incrementarBloquesDestruibles
endm

dibujarPrimeraCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 60 ;fila
    MOV bx, 65  ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60
    MOV bx, 95 
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60
    MOV bx, 125
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60
    MOV bx, 155 
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60
    MOV bx, 185
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60
    MOV bx, 215
    dibujarBloque
    call incrementarBloquesDestruibles
endm

dibujarSegundaCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 70 ;fila
    MOV bx, 80 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70
    MOV bx, 110
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70
    MOV bx, 140
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70
    MOV bx, 170
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70
    MOV bx, 200
    dibujarBloque
    call incrementarBloquesDestruibles
endm

dibujarTerceraCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 80 ;fila
    MOV bx, 95 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80
    MOV bx, 125
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80
    MOV bx, 155
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80
    MOV bx, 185
    dibujarBloque
    call incrementarBloquesDestruibles
endm

dibujarCuartaCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 90 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 90
    MOV bx, 140
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 90
    MOV bx, 170
    dibujarBloque
    call incrementarBloquesDestruibles
endm

dibujarInterrogacion macro
    ;Simbolo ?
    MOV dl, colorRojoGrafico
    MOV ax, 50 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 40 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 30 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 30 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 30 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 40 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 90 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 110 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
endm

dibujarBordesHorizontales macro 
    MOV dl, colorAmarilloGrafico
    ;LINEA HORIZONTAL SUPERIOR
    MOV ax, 20 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 20 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 20 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 20 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 20 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    ;LINEA HORIZONTAL INFERIOR 
    MOV ax, 120 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 120 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 120 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 120 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 120 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
endm

dibujarBordesVerticales macro
    MOV dl, colorAmarilloGrafico
    ;LINEA VERTICAL IZQUIERDA 
    MOV ax, 30 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 40 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 90 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 100 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 110 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    ;LINEA VERTICAL DERECHA 
    MOV ax, 30 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 40 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 90 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 100 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 110 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
endm

dibujarLetraA macro 
    MOV dl, colorRojoGrafico
    ;LINEA CENTRAL:
    MOV ax, 30 ;fila
    MOV bx, 44 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 44 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    ;LINEA IZQUIERDA:
    MOV ax, 40 ;fila
    MOV bx, 23 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50 ;fila
    MOV bx, 23 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 23 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70 ;fila
    MOV bx, 23 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80 ;fila
    MOV bx, 23 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    ;LINEA DERECHA:
    MOV ax, 40 ;fila
    MOV bx, 65 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50 ;fila
    MOV bx, 65 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 65 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70 ;fila
    MOV bx, 65 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80 ;fila
    MOV bx, 65 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
endm

dibujarLetraR macro 
    MOV dl, colorAzulGrafico
    ;LINEA VERTICAL IZQUIERDA
    MOV ax, 30 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 40 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 50 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 70 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 80 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    ;LINEA CENTRAL
    MOV ax, 30 ;fila
    MOV bx, 113 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 50 ;fila
    MOV bx, 113 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    ;LINEA DERECHA
    MOV ax, 30 ;fila
    MOV bx, 135 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 40 ;fila
    MOV bx, 135 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 135 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 70 ;fila
    MOV bx, 135 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV ax, 80 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
endm

dibujarLetraQ macro 
    ;LINEA CENTRAL:
    MOV dl, colorVerdeGrafico
    MOV ax, 30 ;fila
    MOV bx, 183 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    MOV dl, colorVerdeGrafico
    MOV ax, 80 ;fila
    MOV bx, 183 ;columna
    dibujarBloque 
    call incrementarBloquesDestruibles
    ;LINEA IZQUIERDA
    MOV ax, 40 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    ;LINEA DERECHA
    MOV ax, 40 ;fila
    MOV bx, 205 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50 ;fila
    MOV bx, 205 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 205 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70 ;fila
    MOV bx, 205 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80 ;fila
    MOV bx, 205 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    ;Linea Cortante
    MOV ax, 86 ;fila
    MOV bx, 213 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
endm 

dibujarNumUno macro
    ;Copete
    MOV dl, colorAmarilloGrafico
    MOV ax, 40 ;fila
    MOV bx, 240 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    ;LINEA CENTRAL:
    MOV ax, 30 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 40 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 50 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 60 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 70 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    ;LINEA BASE
    MOV ax, 80 ;fila
    MOV bx, 240 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
    MOV ax, 80 ;fila
    MOV bx, 290 ;columna
    dibujarBloque
    call incrementarBloquesDestruibles
endm
