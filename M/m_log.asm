
brindarBienvenidaAdmin macro
     imprimirEnConsola bienvenidaAdmin 
     imprimirEnConsola lectorEntradaUsuario[0];imprime todo el contenido del arreglo(actualmente el username)
endm 

verificarAdmin macro    
    LOCAL reVerificarUsuario,denegarCaracter,aceptarCaracter,verificarCoincidenciaUsuario, validarPass, verificarPass,aceptarCaracterPass,verificarCoincidenciaPass,usuarioNoAdmin,usuarioAdmin
    MOV dl,4 ;indicador de archivo Admins.txt 
    MOV bl,1 ;indicador de apertura y lectura archivo  
    accionarArchivoEnrutado dl, bl ;se abre y lee el contenido de se archivo 
    cerrarArchivo controladorFicheros  
    xor si,si
    xor di,di
    jmp verificarUsuario 
    reVerificarUsuario:
        xor si,si ;Se reinicia SI para evaluar la cadena ingresada nuevamente
        add di, 3
        ;dado que actualmente esta ubicado en un ";"(separador)
        ;necesitamos el siguiente caracter para evaluar otro usuario,
        ;pero sumamos 3 dado que es ";", "\n", y "\r" lo que separa a cada usuario
    verificarUsuario:     
        cmp  lectorEntradaFicheros[di], finCadena
        je usuarioNoAdmin 
        ;si coincide con fin de cadena significa que ya evaluo todo
        ;y no hay usuario registrado con ese nombre  
        MOV bl, lectorEntradaFicheros[di] 
        cmp  lectorEntradaUsuario[si], bl 
        je aceptarCaracter
        denegarCaracter:
            ;dado que no coincide el usuario: 
            ;se desplaza hasta encontrar ; (nuestro separador de credenciales)       
            cmp lectorEntradaFicheros[di], puntoComa
            je  reVerificarUsuario
            inc di         
            jmp denegarCaracter 
        aceptarCaracter:     
            inc si                     
            inc di  
            cmp lectorEntradaUsuario[si], finCadena 
            je  verificarCoincidenciaUsuario
            jmp verificarUsuario 
     verificarCoincidenciaUsuario:     
            cmp  lectorEntradaFicheros[di], coma ; si equivale a coma es que el usuario si coincide
            je  validarPass
            jmp denegarCaracter 
     validarPass:
           xor si,si ;Se reinicia si para evaluar la cadena ingresada nuevamente 
           inc di;se incrementa ya que actualmente se encutra en el separador "," 
     verificarPass:               
            MOV bl, lectorEntradaFicheros[di]
            cmp  lectorEntradaPass[si], bl 
            je aceptarCaracterPass
            jmp usuarioNoAdmin
            aceptarCaracterPass:    
                inc si
                inc di
                cmp  lectorEntradaPass[si], finCadena 
                je  verificarCoincidenciaPass
                jmp verificarPass
            verificarCoincidenciaPass:     
                cmp  lectorEntradaFicheros[di], puntoComa; si equivale a punto coma es que el pass si coincide 
                je  usuarioAdmin
                jmp usuarioNoAdmin
     usuarioNoAdmin:
        ;Al no ser admin automáticamente se irá a al juego por ser un jugador estándar
        ;accede al juego: 
        MOV dl, 2
        reiniciarLectorTeclado dl; reinicia lector de pass  
        jmp iniciarJuego
     usuarioAdmin:
        MOV dl, 2   
        brindarBienvenidaAdmin
        reiniciarLectorTeclado dl; reinicia lector de pass  
        jmp seccionTops                  
endm                
       
verificarIngreso macro  
     LOCAL LecturaIngresoUsuario, ErrorEntradaUsuario, reVerificarUsuario, verificarUsuario,denegarCaracter, aceptarCaracter, verificarCoincidenciaUsuario,LecturaIngresoPass, ErrorEntradaPass, verificarPass,aceptarCaracterPass, notificarPassErroneo, usuarioInexistente, verificarCoincidenciaPass, accesoUsuario     
     PUSH SI 
     PUSH DI
     MOV dl, 0 ;indica que se use la ruta del archivo de indice 0 (Gamers.txt)
     MOV bl, 1 ;indicador de apertura y lectura archivo 
     accionarArchivoEnrutado dl, bl ;se abre y lee el contenido de se archivo 
     cerrarArchivo controladorFicheros ;se cierra el archivo para evitar problemas posteriores
     xor si, si ;inicializamos nuestros controles de indice
     xor di, di 
     LecturaIngresoUsuario:  
        imprimirEnConsola  solicitudUsuario          
        obtenerLecturaTeclado lectorEntradaUsuario   
        cmp cl, longMaxUsuario ;si es <= 7 se evalua, si no lo vuelve a solicitar
        jle verificarUsuario
        ErrorEntradaUsuario:
            imprimirEnConsola usuarioMaxError   
            MOV dl, 1
            reiniciarLectorTeclado dl; reinicia el lector de usuario
            jmp LecturaIngresoUsuario
     reVerificarUsuario:
        xor si,si ;Se reinicia SI para evaluar la cadena ingresada nuevamente
        add di, 3
        ;dado que actualmente esta ubicado en un ";"(separador)
        ;necesitamos el siguiente caracter para evaluar otro usuario,
        ;pero sumamos 3 dado que es ";", "\n", y "\r" lo que separa a cada usuario   
     verificarUsuario:     
        cmp  lectorEntradaFicheros[di], finCadena
        je usuarioInexistente 
        ;si coincide con fin de cadena significa que ya evaluo todo
        ;y no hay usuario registrado con ese nombre  
        MOV bl, lectorEntradaFicheros[di] 
        cmp  lectorEntradaUsuario[si], bl 
        je aceptarCaracter
        denegarCaracter:
            ;dado que no coincide el usuario: 
            ;se desplaza hasta encontrar ; (nuestro separador de credenciales)       
            cmp lectorEntradaFicheros[di], puntoComa
            je  reVerificarUsuario
            inc di         
            jmp denegarCaracter 
        aceptarCaracter:     
            inc si                     
            inc di  
            cmp lectorEntradaUsuario[si], finCadena 
            je  verificarCoincidenciaUsuario
            jmp verificarUsuario 
     verificarCoincidenciaUsuario:     
            cmp  lectorEntradaFicheros[di], coma ; si equivale a coma es que el usuario si coincide
            je  LecturaIngresoPass
            jmp denegarCaracter 
     LecturaIngresoPass:  
            inc di    ;su ultima posición es el separado ",", por eso se incrementa
            xor si,si ;Se reinicia si para evaluar la cadena ingresada nuevamente
            MOV dl, 2
            reiniciarLectorTeclado dl; reinicia lector de pass  
		    imprimirEnConsola  solicitudPass          
		    obtenerLecturaTeclado lectorEntradaPass
		    cmp cl, longMaxPass ;si es == 4 se evalua, si no lo vuelve a solicitar
		    je verificarPass
		    ErrorEntradaPass:
		        imprimirEnConsola passMaxError
		        MOV dl, 2 
		        reiniciarLectorTeclado dl
		        jmp LecturaIngresoPass
     verificarPass:           
            MOV bl, lectorEntradaFicheros[di]
            cmp  lectorEntradaPass[si], bl 
            je aceptarCaracterPass
            notificarPassErroneo:
                ;dado que no coincide el pass, se niega el acceso y se solicita nuevamente un usuario   
                xor di,di  
                xor si,si ;Se reinicia si para evaluar la cadena ingresada nuevamente 
                imprimirEnConsola passErroneo 
                MOV dl, 2
                reiniciarLectorTeclado dl; reinicia lector de pass  
                MOV dl, 1
                reiniciarLectorTeclado dl; reinicia lector de usuarios
                jmp  LecturaIngresoUsuario 
            aceptarCaracterPass:     
                inc si
                inc di
                cmp  lectorEntradaPass[si], finCadena 
                je  verificarCoincidenciaPass
                jmp verificarPass
            verificarCoincidenciaPass:     
                cmp  lectorEntradaFicheros[di], puntoComa; si equivale a punto coma es que el pass si coincide 
                je  accesoUsuario
                jmp notificarPassErroneo
     usuarioInexistente:
        imprimirEnConsola usuarioErroneo   
        MOV dl, 1
        reiniciarLectorTeclado dl;reinicia lector de usuarios
        xor di,di ; se restablece el puntero al inicio del archivo para nuevas evaluaciones
        jmp LecturaIngresoUsuario 
     accesoUsuario:
        imprimirEnConsola usuarioAccedido 
		POP SI 
		POP DI  
		verificarAdmin   
endm 