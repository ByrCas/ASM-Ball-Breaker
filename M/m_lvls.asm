

dibujarCaparazon macro ;obstaculos de nivel 1
    MOV di, 20 ; las lineas horizontales del bloque tendran 20 pixeles de longitud
    dibujarContornoCaparazon
    dibujarPrimeraCapaCaparazon
    dibujarSegundaCapaCaparazon
    dibujarTerceraCapaCaparazon
    dibujarCuartaCapaCaparazon
endm

dibujarCaja macro 
    MOV di, 20 ; las lineas horizontales del bloque tendran 20 pixeles de longitud
    dibujarInterrogacion
    dibujarBordesHorizontales
    dibujarBordesVerticales
endm

dibujarMensajeColorido macro
    MOV di, 20 ; las lineas horizontales del bloque tendran 20 pixeles de longitud
    dibujarLetraA
    dibujarLetraR
    dibujarLetraQ
    dibujarNumUno
endm

dibujarContornoCaparazon macro
    MOV dl, colorBlancoGrafico
    MOV ax, 50 ;fila
    MOV bx, 50  ;columna
    dibujarBloque
    MOV ax, 50
    MOV bx, 80
    dibujarBloque
    MOV ax, 50
    MOV bx, 110
    dibujarBloque 
    MOV ax, 50
    MOV bx, 140
    dibujarBloque
    MOV ax, 50
    MOV bx, 170 
    dibujarBloque 
    MOV ax, 50
    MOV bx, 200 
    dibujarBloque
    MOV ax, 50
    MOV bx, 230 
    dibujarBloque
endm

dibujarPrimeraCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 60 ;fila
    MOV bx, 65  ;columna
    dibujarBloque
    MOV ax, 60
    MOV bx, 95 
    dibujarBloque
    MOV ax, 60
    MOV bx, 125
    dibujarBloque
    MOV ax, 60
    MOV bx, 155 
    dibujarBloque
    MOV ax, 60
    MOV bx, 185
    dibujarBloque
    MOV ax, 60
    MOV bx, 215
    dibujarBloque
endm

dibujarSegundaCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 70 ;fila
    MOV bx, 80 ;columna
    dibujarBloque
    MOV ax, 70
    MOV bx, 110
    dibujarBloque
    MOV ax, 70
    MOV bx, 140
    dibujarBloque
    MOV ax, 70
    MOV bx, 170
    dibujarBloque
    MOV ax, 70
    MOV bx, 200
    dibujarBloque
endm

dibujarTerceraCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 80 ;fila
    MOV bx, 95 ;columna
    dibujarBloque
    MOV ax, 80
    MOV bx, 125
    dibujarBloque
    MOV ax, 80
    MOV bx, 155
    dibujarBloque
    MOV ax, 80
    MOV bx, 185
    dibujarBloque
endm

dibujarCuartaCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 90 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    MOV ax, 90
    MOV bx, 140
    dibujarBloque
    MOV ax, 90
    MOV bx, 170
    dibujarBloque
endm

dibujarInterrogacion macro
    ;Simbolo ?
    MOV dl, colorRojoGrafico
    MOV ax, 80 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    MOV ax, 70 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    MOV ax, 60 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    MOV ax, 60 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    MOV ax, 60 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    MOV ax, 70 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    MOV ax, 80 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    MOV ax, 90 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    MOV ax, 100 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    MOV ax, 110 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    MOV ax, 120 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    MOV ax, 140 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
endm

dibujarBordesHorizontales macro 
    MOV dl, colorAmarilloGrafico
    ;LINEA HORIZONTAL SUPERIOR
    MOV ax, 50 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    MOV ax, 50 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    MOV ax, 50 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    MOV ax, 50 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    MOV ax, 50 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    ;LINEA HORIZONTAL INFERIOR 
    MOV ax, 150 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    MOV ax, 150 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    MOV ax, 150 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
    MOV ax, 150 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    MOV ax, 150 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
endm

dibujarBordesVerticales macro
    MOV dl, colorAmarilloGrafico
    ;LINEA VERTICAL IZQUIERDA 
    MOV ax, 60 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    MOV ax, 70 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    MOV ax, 80 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    MOV ax, 90 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    MOV ax, 100 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    MOV ax, 110 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    MOV ax, 120 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    MOV ax, 130 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    MOV ax, 140 ;fila
    MOV bx, 85 ;columna
    dibujarBloque
    ;LINEA VERTICAL DERECHA 
    MOV ax, 60 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    MOV ax, 70 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    MOV ax, 80 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    MOV ax, 90 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    MOV ax, 100 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    MOV ax, 110 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    MOV ax, 120 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    MOV ax, 130 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
    MOV ax, 140 ;fila
    MOV bx, 185 ;columna
    dibujarBloque
endm

dibujarLetraA macro 
    MOV dl, colorRojoGrafico
    ;LINEA CENTRAL:
    MOV ax, 30 ;fila
    MOV bx, 44 ;columna
    dibujarBloque
    MOV ax, 60 ;fila
    MOV bx, 44 ;columna
    dibujarBloque
    ;LINEA IZQUIERDA:
    MOV ax, 40 ;fila
    MOV bx, 23 ;columna
    dibujarBloque
    MOV ax, 50 ;fila
    MOV bx, 23 ;columna
    dibujarBloque
    MOV ax, 60 ;fila
    MOV bx, 23 ;columna
    dibujarBloque
    MOV ax, 70 ;fila
    MOV bx, 23 ;columna
    dibujarBloque
    MOV ax, 80 ;fila
    MOV bx, 23 ;columna
    dibujarBloque
    ;LINEA DERECHA:
    MOV ax, 40 ;fila
    MOV bx, 65 ;columna
    dibujarBloque
    MOV ax, 50 ;fila
    MOV bx, 65 ;columna
    dibujarBloque
    MOV ax, 60 ;fila
    MOV bx, 65 ;columna
    dibujarBloque
    MOV ax, 70 ;fila
    MOV bx, 65 ;columna
    dibujarBloque
    MOV ax, 80 ;fila
    MOV bx, 65 ;columna
    dibujarBloque
endm

dibujarLetraR macro 
    MOV dl, colorAzulGrafico
    ;LINEA VERTICAL IZQUIERDA
    MOV ax, 30 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    MOV ax, 40 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    MOV ax, 50 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    MOV ax, 60 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    MOV ax, 70 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    MOV ax, 80 ;fila
    MOV bx, 90 ;columna
    dibujarBloque 
    ;LINEA CENTRAL
    MOV ax, 30 ;fila
    MOV bx, 113 ;columna
    dibujarBloque 
    MOV ax, 50 ;fila
    MOV bx, 113 ;columna
    dibujarBloque 
    ;LINEA DERECHA
    MOV ax, 30 ;fila
    MOV bx, 135 ;columna
    dibujarBloque 
    MOV ax, 40 ;fila
    MOV bx, 135 ;columna
    dibujarBloque 
    MOV ax, 60 ;fila
    MOV bx, 135 ;columna
    dibujarBloque 
    MOV ax, 70 ;fila
    MOV bx, 135 ;columna
    dibujarBloque 
    MOV ax, 80 ;fila
    MOV bx, 135 ;columna
    dibujarBloque
endm

dibujarLetraQ macro 
    ;LINEA CENTRAL:
    MOV dl, colorVerdeGrafico
    MOV ax, 30 ;fila
    MOV bx, 183 ;columna
    dibujarBloque 
    MOV dl, colorVerdeGrafico
    MOV ax, 80 ;fila
    MOV bx, 183 ;columna
    dibujarBloque 
    ;LINEA IZQUIERDA
    MOV ax, 40 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    MOV ax, 50 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    MOV ax, 60 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    MOV ax, 70 ;fila
    MOV bx, 160 ;columna
    dibujarBloque
    ;LINEA DERECHA
    MOV ax, 40 ;fila
    MOV bx, 205 ;columna
    dibujarBloque
    MOV ax, 50 ;fila
    MOV bx, 205 ;columna
    dibujarBloque
    MOV ax, 60 ;fila
    MOV bx, 205 ;columna
    dibujarBloque
    MOV ax, 70 ;fila
    MOV bx, 205 ;columna
    dibujarBloque
    MOV ax, 80 ;fila
    MOV bx, 205 ;columna
    dibujarBloque
    ;Linea Cortante
    MOV ax, 86 ;fila
    MOV bx, 213 ;columna
    dibujarBloque
endm 

dibujarNumUno macro
    ;Copete
    MOV dl, colorAmarilloGrafico
    MOV ax, 40 ;fila
    MOV bx, 240 ;columna
    dibujarBloque
    ;LINEA CENTRAL:
    MOV ax, 30 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    MOV ax, 40 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    MOV ax, 50 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    MOV ax, 60 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    MOV ax, 70 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    MOV ax, 80 ;fila
    MOV bx, 265 ;columna
    dibujarBloque
    ;LINEA BASE
    MOV ax, 80 ;fila
    MOV bx, 240 ;columna
    dibujarBloque
    MOV ax, 80 ;fila
    MOV bx, 290 ;columna
    dibujarBloque
endm
