

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