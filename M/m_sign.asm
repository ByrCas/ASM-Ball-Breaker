
;================ MACROS PARA EL REGISTRO DE JUGADORES VALIDADOS ============================== 

verificarRegistro macro  
     LOCAL LecturaIngresoUsuario, ErrorEntradaUsuario, reVerificarUsuario, verificarUsuario,denegarCaracter, aceptarCaracter,usuarioExistente,LecturaIngresoPass,ErrorEntradaPass, verificarDigitos, numerico, noNumerico,registroUsuario,transferirOriginal, separarFilaNueva, transferirUsuario, separarColumna, separarColumna, transferirPass, separarRegistroNuevo, registro  
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
        je LecturaIngresoPass 
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
            cmp  lectorEntradaFicheros[di], coma
            ; si equivale a coma es que el usuario si existe y esta en uso, no se pued registrar
            je  usuarioExistente
            jmp denegarCaracter 
     usuarioExistente:
            imprimirEnConsola usuarioEnUso 
            MOV dl, 1
            reiniciarLectorTeclado dl; reinicia el lector de usuario
            jmp LecturaIngresoUsuario
     LecturaIngresoPass:  
            xor si,si ;Se reinicia si para evaluar la cadena ingresada nuevamente
            MOV dl, 2
            reiniciarLectorTeclado dl; reinicia lector de pass  
		    imprimirEnConsola  solicitudPass          
		    obtenerLecturaTeclado lectorEntradaPass
		    cmp cl, longMaxPass ;si es == 4 se evalua, si no lo vuelve a solicitar
		    je verificarDigitos
		    ErrorEntradaPass:
		        imprimirEnConsola passMaxError
		        jmp LecturaIngresoPass
		    verificarDigitos:
		        cmp  lectorEntradaPass[si], '0' 
                je  numerico
		        cmp  lectorEntradaPass[si], '1' 
                je  numerico 
                cmp  lectorEntradaPass[si], '2' 
                je  numerico 
                cmp  lectorEntradaPass[si], '3' 
                je  numerico 
                cmp  lectorEntradaPass[si], '4' 
                je  numerico 
                cmp  lectorEntradaPass[si], '5' 
                je  numerico 
                cmp  lectorEntradaPass[si], '6' 
                je  numerico 
                cmp  lectorEntradaPass[si], '7' 
                je  numerico 
                cmp  lectorEntradaPass[si], '8' 
                je  numerico
                cmp  lectorEntradaPass[si], '9' 
                je  numerico  
                jmp noNumerico 
             numerico:
                inc si
                cmp  si, longMaxPass 
                jl  verificarDigitos
                jmp registroUsuario
             noNumerico:
                imprimirEnConsola passNoNumerico
                jmp LecturaIngresoPass   
     registroUsuario:
        reiniciarEscritorFicheros
        MOV dl, 0 ;indica que se use la ruta del archivo de indice 0 (Gamers.txt)
        MOV bl, 1 ;indicador de apertura y lectura del archivo 
        accionarArchivoEnrutado dl, bl ;se abre el contenido de se archivo 
        xor di, di ;Se reinicia para emplearlo como indice ubicador
        xor si,si ;Se reinicia para emplearlo como indice ubicador
        ;transferirOriginal:
            ;MOV bl, lectorEntradaFicheros[di]
            ;MOV escritorFicheroActual[si], bl 
            ;inc si
            ;inc di 
            ;cmp lectorEntradaFicheros[di], finCadena
            ;je separarFilaNueva
           ; jmp transferirOriginal 
        separarFilaNueva:
            MOV escritorFicheroActual[si],retornoCR
            inc si
            MOV escritorFicheroActual[si],saltoLn 
            inc si 
            xor di, di
        transferirUsuario:
            MOV bl, lectorEntradaUsuario[di]
            MOV escritorFicheroActual[si], bl 
            inc si
            inc di 
            cmp lectorEntradaUsuario[di], finCadena
            je separarColumna
            jmp transferirUsuario 
        separarColumna:
            MOV escritorFicheroActual[si],coma 
            inc si  
            xor di,di
        transferirPass:
            MOV bl, lectorEntradaPass[di]
            MOV escritorFicheroActual[si], bl 
            inc si 
            inc di
            cmp lectorEntradaPass[di], finCadena
            je separarRegistroNuevo
            jmp transferirPass 
        separarRegistroNuevo:
            MOV escritorFicheroActual[si],puntoComa 
            inc si
            MOV cx, si;cuenta de elementos byte a adjuntar en el fichero
            xor si,si
            xor di,di   
        registro:
            adjuntarContenidoArchivo cx,escritorFicheroActual,controladorFicheros
            cerrarArchivo controladorFicheros ;se cierra el archivo para evitar problemas posteriores
            reiniciarEscritorFicheros
            imprimirEnConsola usuarioRegistrado 
endm 