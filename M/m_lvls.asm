

dibujarCaparazon macro ;obstaculos de nivel 1
    MOV di, 20 ; las lineas horizontales del bloque tendran 20 pixeles de longitud
    dibujarContornoCaparazon
    dibujarPrimeraCapaCaparazon
    dibujarSegundaCapaCaparazon
    dibujarTerceraCapaCaparazon
    dibujarCuartaCapaCaparazon
endm

dibujarContornoCaparazon macro
    MOV dl, colorBlancoGrafico
    MOV ax, 50 ;fila
    MOV bx, 50  ;columna
    dibujarBloque
    MOV dl, colorBlancoGrafico
    MOV ax, 50
    MOV bx, 80
    dibujarBloque
    MOV dl, colorBlancoGrafico
    MOV ax, 50
    MOV bx, 110
    dibujarBloque
    MOV dl, colorBlancoGrafico; 
    MOV ax, 50
    MOV bx, 140
    dibujarBloque
    MOV dl, colorBlancoGrafico; 
    MOV ax, 50
    MOV bx, 170 
    dibujarBloque
    MOV dl, colorBlancoGrafico; 
    MOV ax, 50
    MOV bx, 200 
    dibujarBloque
    MOV dl, colorBlancoGrafico
    MOV ax, 50
    MOV bx, 230 
    dibujarBloque
endm

dibujarPrimeraCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 60 ;fila
    MOV bx, 65  ;columna
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 60
    MOV bx, 95 
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 60
    MOV bx, 125
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 60
    MOV bx, 155 
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 60
    MOV bx, 185
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 60
    MOV bx, 215
    dibujarBloque
endm

dibujarSegundaCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 70 ;fila
    MOV bx, 80 ;columna
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 70
    MOV bx, 110
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 70
    MOV bx, 140
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 70
    MOV bx, 170
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 70
    MOV bx, 200
    dibujarBloque
endm

dibujarTerceraCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 80 ;fila
    MOV bx, 95 ;columna
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 80
    MOV bx, 125
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 80
    MOV bx, 155
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 80
    MOV bx, 185
    dibujarBloque
endm

dibujarCuartaCapaCaparazon macro
    MOV dl, colorVerdeGrafico
    MOV ax, 90 ;fila
    MOV bx, 110 ;columna
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 90
    MOV bx, 140
    dibujarBloque
    MOV dl, colorVerdeGrafico
    MOV ax, 90
    MOV bx, 170
    dibujarBloque
endm