
;================ SECCIÓN DE MACROS ============================== 
salirPrograma macro          
    imprimirEnConsola salidaJuego
    MOV ah,subFuncionFinPrograma 
    int funcionesDOS
endm


imprimirEnConsola macro cadena
    MOV ah,subFuncionVerCadena; asignamos la subfunción de la interupción
    MOV dx,offset cadena ;proporcionamos la dirección de desplazamiento
    int funcionesDOS
endm   

mostrarEncabezado macro    
    imprimirEnConsola lineaSeparadora
    imprimirEnConsola datosCurso 
    imprimirEnConsola misDatos
    imprimirEnConsola lineaSeparadora
endm    

mostrarMenuPrincipal macro    
    imprimirEnConsola tituloJuego   
    imprimirEnConsola menuPrincipal
endm              

obtenerTecla macro
    mov ah,subFuncionLeerCaracter
    int funcionesDOS
endm
       
obtenerLecturaTeclado macro arregloLector  
    LOCAL leerTecla, finalizar 
    PUSH SI
    PUSH AX
    xor si,si;Bits de SI en 0 
    MOV cl,0 ;cntador de telcas ingresadas 
    leerTecla:
        obtenerTecla
        cmp al,retornoCR
        je  finalizar
        mov arregloLector[si],al
        inc si
        inc cl ;llevará la cuenta de caracteres ingresados
        jmp leerTecla
    finalizar:
        mov arregloLector[si],finCadena
        POP AX
        POP SI
endm  

reiniciarLectorTeclado macro indicador  
    LOCAL borrarTecladoGeneral, borrarTecladoUsuario, borrarTecladoPass, Fin
    PUSH SI  
    xor si,si;Bits de SI en 0 
    cmp indicador, 0
    je borrarTecladoGeneral 
    cmp indicador, 1  
    je borrarTecladoUsuario 
    cmp indicador, 2
    je borrarTecladoPass 
    borrarTecladoGeneral:
        MOV lectorEntradaTeclado[si], finCadena 
        inc si
        cmp si, 14h;tamaño lector
        jl borrarTecladoGeneral 
        jmp Fin
    borrarTecladoUsuario:
        MOV lectorEntradaUsuario[si], finCadena 
        inc si
        cmp si, 14h  ;tamaño lector
        jl borrarTecladoUsuario   
        jmp Fin
    borrarTecladoPass:
        MOV lectorEntradaPass[si], finCadena 
        inc si
        cmp si, 14h;tamaño lector
        jl borrarTecladoPass 
    Fin:    
        POP SI
endm   

reiniciarLectorFicheros macro 
    LOCAL borrar
    PUSH SI  
    MOV si,0;Bits de SI en 0  
    MOV CX, dimensionLectorFicheros
    borrar:
        MOV lectorEntradaFicheros[si], finCadena 
        inc si
        loop borrar 
    POP SI
endm 

reiniciarEscritorFicheros macro 
    LOCAL borrar
    PUSH SI  
    MOV si,0;Bits de SI en 0  
    MOV CX, dimensionEscritorFicheros
    borrar:
        MOV escritorFicheroActual[si], finCadena 
        inc si
        loop borrar 
    POP SI
endm 

abrirArchivo macro rutaArchivo,controlador
    mov ah,subFuncionAbrirFichero
    mov al, permisoLecturaEscritura  ;modo de acceso:
    mov dx, offset rutaArchivo
    int funcionesDOS
    jc errorAperturaArchivo
    mov controlador,ax
endm

leerArchivo macro numBytes,arregloLector,controlador
    mov ah,subFuncionLeerFichero
    mov bx,controlador
    mov cx,numBytes       ;cuantos bytes se leerán
    lea dx,arregloLector
    int funcionesDOS
    jc errorLecturaArchivo ;Se produce acarreo = 1 en una lectura fallida 
endm        
 
crearArchivo macro rutaArchivo,controlador 
    mov ah,subFuncionCrearFichero
    mov cx,modoEstandar ; es el modo de fichero estándar (existen otros tipos)
    lea dx,rutaArchivo
    int funcionesDOS
    mov controlador,ax                           
endm  
 
cerrarArchivo macro controlador 
    MOV ah, subFuncionCerrarFichero
    MOV bx, controlador
    int funcionesDOS                           
endm    

adjuntarContenidoArchivo macro numBytes,arregloEscritor,controlador
	;lo datos se adjuntan si el archivo ya fue leido, ya que el puntero
	; estará en el final, para sobreescribir se debe vaciar el archivo
	;(en algunos casos se crea nuevamente el archivo para que ya este vacio)
	mov bx, controlador
    MOV ah, subFuncionAdjuntarInfoFichero
    MOV cx, numBytes
    MOV dx, offset arregloEscritor
    int funcionesDOS  
endm 

accionarArchivoEnrutado macro indicadorArchivo, indicadorAccion    
    LOCAL asignarRutaJugadores, asignarRutaPartidas,asignarRutaAdmins, asignarRutaPuntos,asignarRutaTiempos, delimitador, lectura, fin
    reiniciarLectorFicheros
    cmp indicadorArchivo,0
    je asignarRutaJugadores
    cmp indicadorArchivo,1
    je asignarRutaPartidas
    cmp indicadorArchivo,2
    je asignarRutaPuntos
    cmp indicadorArchivo,3
    je asignarRutaTiempos
    cmp indicadorArchivo,4
    je asignarRutaAdmins
    asignarRutaJugadores:
        abrirArchivo nombreArchivoJugadores,controladorFicheros 
        jmp delimitador
    asignarRutaPartidas:
        abrirArchivo nombreArchivoPartidas,controladorFicheros
        jmp delimitador
    asignarRutaPuntos:
        abrirArchivo nombreReportePuntajes,controladorFicheros
        jmp delimitador
    asignarRutaAdmins:
        abrirArchivo nombreArchivoAdmins,controladorFicheros
        jmp delimitador
    asignarRutaTiempos:
        abrirArchivo nombreReporteTiempos,controladorFicheros     
    delimitador:
        cmp indicadorAccion,1 ;leerá también el archivo
        je  lectura 
        jmp fin
    lectura:
        leerArchivo dimensionLectorFicheros,lectorEntradaFicheros,controladorFicheros
        ;imprimirEnConsola  lectorEntradaFicheros 
    fin: 
endm    

brindarBienvenidaAdmin macro
     imprimirEnConsola bienvenidaAdmin 
     imprimirEnConsola lectorEntradaUsuario[0];imprime todo el contenido del arreglo(actualmente el username)
endm    

;Los valores que se pasan a las macros "accionar resultados"
;determinan el orden(asc/desc) y si es reporte de tiempos o de puntajes
accionarReportePuntajesAscendentes macro
    MOV bl, 0 ;puntajes ascen
    MOV ah, 0 
    accionarTopResultados bl, ah
endm 

accionarReporteTiemposAscendentes macro
    MOV bl, 1 ;tiempos ascen
    MOV ah, 0 
    accionarTopResultados bl, ah
endm 

accionarReportePuntajesDescendentes macro
    MOV bl, 0  ;puntajes desc
    MOV ah, 1 
    accionarTopResultados bl, ah
endm 

accionarReporteTiemposDescendentes macro
    MOV bl, 1  ;tiempos desc
    MOV ah, 1
    accionarTopResultados bl, ah
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
            adjuntarContenidoArchivo cx escritorFicheroActual controladorFicheros
            cerrarArchivo controladorFicheros ;se cierra el archivo para evitar problemas posteriores
            reiniciarEscritorFicheros
            imprimirEnConsola usuarioRegistrado 
endm 

direccionarTop macro ;incrementa o decrece si es ascendente o descendente
    LOCAL ascender, descender, fin
      cmp al, 1
      je descender
      ascender:
         inc cl
         jmp fin
      descender:
         dec cl
      fin:
endm 

establecerPuntoInicial macro ;establece el punto incial (del puesto en los tops)
     LOCAL inicioBajo, inicioAlto, fin
      cmp al, 1
      je inicioAlto
      inicioBajo:
         MOV DS:[Orientador.puntoInicialTop],inicioAsciiDigito 
         MOV DS:[Orientador.puntoFinalTop],finAsciiDigito   
         jmp fin
      inicioAlto:
         MOV DS:[Orientador.puntoInicialTop],finAsciiDigito
         MOV DS:[Orientador.puntoFinalTop],inicioAsciiDigito 
      fin:
         MOV cl,DS:[Orientador.puntoInicialTop]
endm

imprimirTop macro indicadorTitulo
     LOCAL topPuntajes, topTiempos, fin
     ;mostrarEncabezado
     cmp indicadorTitulo, 0
     je  topPuntajes
     cmp indicadorTitulo, 1
     je  topTiempos
     topPuntajes:
        imprimirEnConsola tituloTopPuntajes
        jmp fin
     topTiempos:
         imprimirEnConsola tituloTopTiempos
        jmp fin
     fin:
        imprimirEnConsola escritorFicheroActual[0]       
endm    

accionarTopResultados macro indicadorAccion, indicadorOrden
     LOCAL elegirElementos, mostrarTopPuntajes, mostrarTopTiempos, generarTopPuntajes, generarTopTiempos, Fin
     elegirElementos:                                       
        cmp indicadorAccion, 0 ;mostrar Top Puntajes consola  
        je  mostrarTopPuntajes
        cmp indicadorAccion, 1 ;mostrar Top Tiempos consola
        je  mostrarTopTiempos
        cmp indicadorAccion, 2 ;generar Fichero Top Puntajes 
        je  generarTopPuntajes
        cmp indicadorAccion, 3 ;generar Fichero Top Tiempos 
        je  generarTopTiempos
     mostrarTopPuntajes:
        MOV bh, 0
        MOV al, indicadorOrden
        obtenerDataTop bh 
        imprimirTop bh 
        jmp generarTopPuntajes
     mostrarTopTiempos:
        MOV bh, 1  
        MOV al, indicadorOrden
        obtenerDataTop bh
        imprimirTop bh
        jmp generarTopTiempos
     generarTopPuntajes: 
        
        jmp Fin
     generarTopTiempos:
        ;sobreEscribirTopTiempos
        jmp Fin
     Fin:
        reiniciarEscritorFicheros                      
endm 

obtenerDataTop macro indicadorElemento
    LOCAL verificarFin, asignarPuesto, obtenerUsername,separarUsuario,desplazarAFin,readecuarDestino, obtenerNivel,separarNivel,obtenerPuntaje,separarFila,obtenerTiempo,desplazarATiempo,obtenerDato,elegirElemento, finalizado,sobrepasarSeparador, reconocerSalto, desplazarSalto           
    PUSH SI
    PUSH DI
    PUSH AX 
    PUSH Bx 
    ;Dado que para pasar el parámetro usamos bh pero este registro
    ;puede alterarse con la apertura y lectura del archivo entonces se hace un push 
    MOV dl, 1 ;indica que se use la ruta del archivo de indice 1 (Rounds.txt)
    MOV bl, 1 ;indicador de apertura y lectura archivo 
    accionarArchivoEnrutado dl, bl ;se abre y lee el contenido de se archivo 
    cerrarArchivo controladorFicheros ;se cierra el archivo para evitar problemas posteriores
    POP Bx 
    POP AX
    ;con el pop recuperamso los valores de la pila que se metio previamente
    xor si, si;inicializamos nuestros controles de indice
    xor di, di
    xor cl, cl;reestablecemos a 0 nuestro contadores
    xor ch, ch;
    establecerPuntoInicial
    ;Establece para CL el inicio y el fin (dado que sirve para asendentes y descendentes) 
    ;Basándonos en el top 10
    verificarFin:
      cmp  lectorEntradaFicheros[di], finCadena
      je finalizado
      cmp  cl, DS:[Orientador.puntoFinalTop] ; el fin se establecio en "establecerPuntoInicial"
      je finalizado 
    asignarPuesto:
       MOV escritorFicheroActual[si], cl
       ;guarda la cuenta en hexa de los datos reconocidos, asi mismo sirve como indicador del "puesto en el top"
       inc si
       MOV escritorFicheroActual[si], punto
       inc si
    obtenerUsername:
       MOV bl, lectorEntradaFicheros[di]
       MOV escritorFicheroActual[si], bl 
       inc si
       inc di
       cmp lectorEntradaFicheros[di], coma
       je  separarUsuario
       jmp obtenerUsername
    separarUsuario:; agrega espacios como separación   
       MOV escritorFicheroActual[si], espacio
       inc si
       inc ch
       cmp ch, cantidadSeparacion
       jl  separarUsuario
       xor ch, ch
       inc di
    obtenerNivel: 
       MOV bl, lectorEntradaFicheros[di]
       MOV escritorFicheroActual[si], bl 
       inc si
       inc di
       cmp lectorEntradaFicheros[di], coma
       je  separarNivel
       jmp obtenerNivel
    separarNivel:; agrega espacios como separación entre los datos   
       MOV escritorFicheroActual[si], espacio
       inc si
       inc ch
       cmp ch, cantidadSeparacion
       jl  separarNivel
       xor ch, ch
       inc di
    elegirElemento:;se emplea bh ya que el tiene actualmente guardado ese valor
       cmp  bh, 0
       je   obtenerPuntaje
       cmp  bh, 1
       je  readecuarDestino 
    obtenerPuntaje:   
       MOV bl, lectorEntradaFicheros[di]
       MOV escritorFicheroActual[si], bl 
       inc si
       inc di
       cmp lectorEntradaFicheros[di], coma
       je  desplazarAFin
       jmp obtenerPuntaje
    desplazarAFin:; se desplaza sobre los datos hasta llegar al ";" que delimita el fin
       cmp lectorEntradaFicheros[di], puntoComa
       je separarFila
       inc di
       jmp desplazarAFin    
    separarFila: 
       MOV escritorFicheroActual[si],retornoCR
       inc si
       MOV escritorFicheroActual[si],saltoLn 
       inc si
       direccionarTop
       ; ya se obtuvo la data de un usuario, entinces en base a si es ascendente o descente se incremente
       ;o decrece la cuenta
    reconocerSalto: 
        inc di
        cmp lectorEntradaFicheros[di], retornoCR
        je desplazarSalto
        jmp verificarFin
    desplazarSalto:
        add di, 2
        jmp verificarFin
    readecuarDestino:
        inc di        
    desplazarATiempo:; Se desplaza sobre los datos hasta llegar a la info del tiempo 
       cmp lectorEntradaFicheros[di], coma
       je sobrepasarSeparador
       jmp readecuarDestino 
    sobrepasarSeparador:
       inc di    
    obtenerDato:
       MOV bl, lectorEntradaFicheros[di]
       MOV escritorFicheroActual[si], bl 
       inc si
       inc di
       cmp lectorEntradaFicheros[di], puntoComa
       je  separarFila
       jmp obtenerDato          
    finalizado:
       xor cx, cx 
       xor si, si
       xor di, di
       POP SI
       POP DI   
endm    
     
       
;================ DEFINICIÓN DE MODELO Y PILA ==============================       
.model small ;small: Se utilizará solo un segmento de datos con un segmento de código,
             ;en total 128 Kbytes de memoria
.stack 100h  ;asignamos su tamaño 
;================ SEGMENTO DE DATOS ============================== 
.data   
  
;=== EQUIVALENTES ===     
saltoLn EQU 0ah ;0ah-> 10 -> \n 
retornoCR EQU 0dh ;0dh-> 13 ->\r       
tabulador EQU 09h ;09h -> 9 -> \t    
EtildadaMinus EQU 82h ;82H -> 130 -> é
ItildadaMinus EQU 0A1h ;A1H -> 161 -> í
OtildadaMinus EQU 0A2h ;A2H -> 162 -> ó
coma EQU 2ch ;2ch-> 44 -> , 
punto EQU 2eh ;2eh-> 46 -> ,  
puntoComa EQU 3bh ;3bh-> 59 -> ;
espacio EQU 20h;20h->32 -> espacio en blanco  
finRutaFichero EQU 0h ;0h-> 0 -> 0 
finCadena EQU 24h ;24h-> 36 -> $
dimensionLectorTeclado EQU 14h; 20D 
dimensionLectorFicheros EQU 7d0h;2000D 
dimensionEscritorFicheros EQU 7d0h;2000D 
longMaxUsuario EQU 07h;7 caracteres máximo
longMaxPass EQU 04h;4 digitos fijos  
permisoLecturaEscritura EQU 02h; 2 hace referencia a ese modo de acceso en ficheros 
modoEstandar EQU 00h; 0 hace referencia a ese modo o tipo estándar en ficheros 
cantidadSeparacion EQU 15 ;sirve como cuenta para los sepradores en los reportes
inicioAsciiDigito EQU 0030h; es el 0 decimal en ascii
finAsciiDigito EQU 003ah; se tomará como representación del 10 decimal en ascii
  
;=== INTERRUPCIONES EQUIVALENTES === 
subFuncionLeerCaracter EQU 01h ;01h -> 1 -> Entrada de caracter con salida
subFuncionVerCadena EQU 09h ;09h -> 9 -> Visualización de una cadena de caracteres   
subFuncionCrearFichero EQU 3ch ;3ch -> 60 -> Crear Fichero
subFuncionAbrirFichero EQU 3dh ;3dh -> 61 -> Abrir Fichero  
subFuncionCerrarFichero EQU 3eh; 3eh-> 62 -> Cerrar Archivo
subFuncionLeerFichero EQU 3fh ;3fh -> 63 -> Lectura de Fichero o dispositivo
subFuncionAdjuntarInfoFichero EQU 40h ;40h -> 64 -> Escritura(Adjuntada) en Fichero o dispositivo.
subFuncionFinPrograma EQU 4ch ;4ch -> 76 -> Terminación de Programa con Código de Retorno 
funcionesDOS EQU 21h ;21h -> 33 -> petición de función al DOS  
   
;=== VECTORES ===            
lectorEntradaTeclado db 20 dup(finCadena); llenamos el vector de $ y agregamos un final de cadena
lectorEntradaFicheros db 2000 dup(finCadena)
escritorFicheroActual db 2000 dup(finCadena);
lectorEntradaUsuario db 20 dup(finCadena);
lectorEntradaPass db 20 dup(finCadena);   
  
;Rutas ejecutando desde Emu8086:
nombreArchivoJugadores db 'B\Gamers.txt',finRutaFichero ;En dosbox es 'B\Gamers.txt',finRutaFichero
nombreArchivoPartidas db 'B\Rounds.txt',finRutaFichero  ;En dosbox es 'B\Rounds.txt',finRutaFichero
nombreReportePuntajes db 'B\Puntos.rep',finRutaFichero  ;En dosbox es 'B\Puntos.txt',finRutaFichero
nombreReporteTiempos db 'B\Tiempo.rep',finRutaFichero   ;En dosbox es 'B\Tiempo.txt',finRutaFichero
nombreArchivoAdmins db 'B\Admins.txt',finRutaFichero     ;En dosbox es 'B\Asmins.txt',finRutaFichero
controladorFicheros dw ?      

;=== CADENAS PARA MENSAJES EN CONSOLA ===    
;=== SEPARADORES ===                                      
tituloJuego db saltoLn,retornoCR,'!@!@!@!@!@!@! ASM BALL BREAKER !@!@!@!@!@!@!@!@!',saltoLn,finCadena 
lineaSeparadora db saltoLn,retornoCR,'!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!*!',saltoLn,finCadena  

;===   DATOS   ===
datosCurso db saltoLn,retornoCR, 'Universidad de San Carlos de Guatemala', saltoLn,retornoCR,'Facultad de Ingenier',ItildadaMinus,'a', saltoLn,retornoCR,'Arquitectura de Computadores y Ensambladores 1', saltoLn,retornoCR,'Segundo Semestre 2020', saltoLn,retornoCR,'Secci',OtildadaMinus,'n: A', saltoLn,retornoCR,'Proyecto 2', saltoLn,retornoCR,finCadena                                                                                 
misDatos db saltoLn,retornoCR,tabulador,'Byron Gerardo Castillo G',OtildadaMinus,'mez',saltoLn,retornoCR,tabulador,tabulador,'20170544',finCadena

;===   ALERTAS   ===  
debug db saltoLn,retornoCR,'Punto Debug...',saltoLn,retornoCR,finCadena  
bienvenidaAdmin db saltoLn,retornoCR,'@: BIENVENIDO ',finCadena
inicioJuego db saltoLn,retornoCR,'Iniciando Partida...',saltoLn,retornoCR,finCadena 
finJuego db saltoLn,retornoCR,'fin de Partida...',saltoLn,retornoCR,finCadena       
salidaJuego db saltoLn,retornoCR,'Saliendo del Juego...',saltoLn,retornoCR,'JUEGO TERMINADO  :)',finCadena
opcionErronea db saltoLn,retornoCR,'La opci',OtildadaMinus,'n ingresada no es correcta',saltoLn,retornoCR,'Debe ingresarla nuevamente:',saltoLn,retornoCR,finCadena 
usuarioAccedido db saltoLn,retornoCR,'Usuario reconocido, accediendo...',saltoLn,retornoCR,finCadena    
usuarioRegistrado db saltoLn,retornoCR,'Usuario registrado, ya puede utilizarlo para jugar',saltoLn,retornoCR,finCadena 
usuarioErroneo db saltoLn,retornoCR,'El usuario no existe!!',saltoLn,retornoCR,finCadena
usuarioEnUso db saltoLn,retornoCR,'El usuario ya existe, elija uno nuevo!!',saltoLn,retornoCR,finCadena
passErroneo db saltoLn,retornoCR,'El pass es incorrecto!!',saltoLn,retornoCR,finCadena 
passNoNumerico db saltoLn,retornoCR,'El pass no es del todo numérico!!',saltoLn,retornoCR,finCadena  
usuarioMaxError db saltoLn,retornoCR,'El usuario ingresado sobrepasa el max(7) de caracteres',saltoLn,retornoCR,finCadena
passMaxError db saltoLn,retornoCR,'El pass ingresado sobr0epasa el max(4) de digitos o no es del todo numerico',finCadena
velocidadErronea db saltoLn,retornoCR,'La velocidad ingresada es incorrecta',saltoLn,retornoCR,finCadena
aperturaArchivoErronea db saltoLn,retornoCR,'Se produjo un fallo al tratar de abrir el fichero',saltoLn,retornoCR,finCadena
lecturaArchivoErronea db saltoLn,retornoCR,'Se produjo un fallo al tratar de leer el fichero',saltoLn,retornoCR,finCadena 
tituloTopPuntajes db saltoLn,retornoCR,'!#!#!#!#!#!#!#! TOP 10 PUNTAJES !#!#!#!#!#!#!#!',saltoLn,retornoCR,finCadena
tituloTopTiempos db saltoLn,retornoCR,'!#!#!#!#!#!#!#! TOP 10 TIEMPOS !#!#!#!#!#!#!#!',saltoLn,retornoCR,finCadena

;=== SOLICITUDES ===    
solicitudUsuario db saltoLn,retornoCR,'Ingrese el usuario:',saltoLn,retornoCR,finCadena   
solicitudPass db saltoLn,retornoCR,'Ingrese el Pass:',saltoLn,retornoCR,finCadena
solicitudVelocidad db saltoLn,retornoCR,'Ingrese la velocidad(0-9):',saltoLn,retornoCR,finCadena 

;=== MENUS DE SELECCI�N ===
menuPrincipal db saltoLn,retornoCR,'!#!#!#!#!#!#! MENU PRINCIPAL !#!#!#!#!#!#!#!#!',saltoLn,retornoCR
              db '(1)->Ingresar al Juego.',saltoLn,retornoCR
              db '(2)->Registrar Usuario.',saltoLn,retornoCR
              db '(3)->Salir del Juego.',saltoLn,retornoCR,saltoLn
              db 'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena
              
menuIngreso db saltoLn,retornoCR,'!#!#!#!#!#!#! INGRESO: !#!#!#!#!#!#!#!#!',saltoLn,retornoCR,finCadena
menuRegistro db saltoLn,retornoCR,'!#!#!#!#!#!#! REGISTRO: !#!#!#!#!#!#!#!#!',saltoLn,retornoCR,finCadena
menuTops db saltoLn,retornoCR,'!#!#!#!#!#!#! MENU TOPS !#!#!#!#!#!#!#!#!',saltoLn,retornoCR
         db '(1)->Ver Top 10 Puntajes.',saltoLn,retornoCR
         db '(2)->Ver Top 10 Tiempos.',saltoLn,retornoCR
         db '(3)->Regresar.',saltoLn,retornoCR,saltoLn
         db 'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena
         
menuOrdenamientos db saltoLn,retornoCR,'!#!#!#!#!#!#! ORDENAMIENTOSL !#!#!#!#!#!#!#!#!',saltoLn,retornoCR
                  db '(1)->Bubble Sort.',saltoLn,retornoCR
                  db '(2)->Quick Sort.',saltoLn,retornoCR
                  db '(3)->Shell Sort.',saltoLn,retornoCR,saltoLn
                  db 'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena     
                  
menuOrden db saltoLn,retornoCR,'!#!#!#!#!#!#! ORDEN !#!#!#!#!#!#!#!#!',saltoLn,retornoCR 
                  db '(1)->Ascendente.',saltoLn,retornoCR
                  db '(2)->Descendente.',saltoLn,retornoCR
                  db 'Elija una opci',OtildadaMinus,'n:',saltoLn,retornoCR,finCadena

;=== ESTRUCTURAS ===
Orientador STRUC
   puntoInicialTop db ?
   puntoFinalTop db ?
Orientador ENDS  

;orientacionGeneral Orientador <0030h, 0039h>

;================== SEGMENTO DE CODIGO ===========================
.code 
    asignarDIreccionDatos:
       MOV dx,@data ; Dirección del segmento de datos
	   MOV ds,dx 
	main proc 
	    accionarReportePuntajesAscendentes
        accionarReporteTiemposAscendentes
        accionarReportePuntajesDescendentes
        accionarReporteTiemposDescendentes   
		IniciarPrograma:
		    mostrarEncabezado
		    menuInicial:
			    mostrarMenuPrincipal
			    LecturaPrincipal:               
			        obtenerLecturaTeclado lectorEntradaTeclado
			        cmp cl,1 ;Si la longitud de entrada es 1 puede ser una opción valida 
			        je distribuirSubMenu ;se manda a validar la opción
			    ErrorEntradaPrincipal:
			        imprimirEnConsola opcionErronea
			        jmp LecturaPrincipal
		seccionIngreso:
		    imprimirEnConsola menuIngreso   
	        ;verificarIngreso   
		seccionRegistro:
		    imprimirEnConsola menuRegistro 
		    ;verificarRegistro
		    jmp  menuInicial 
		seccionTops:
		    imprimirEnConsola menuTops 
		    jmp  menuInicial
		seccionOrdenamientos:
		    imprimirEnConsola menuOrdenamientos 
		    jmp  menuInicial
		seccionOrden:
		    imprimirEnConsola menuOrden 
		iniciarJuego:
		    imprimirEnConsola inicioJuego 
		    jmp  menuInicial    
		Salir: 
			salirPrograma  
	    distribuirSubMenu:  
            MOV cl,0; reiniciamos el contador para futuras ocasiones  
            subMenusPrincipal:             
                cmp lectorEntradaTeclado[0],'1'
                je  seccionIngreso 
                cmp lectorEntradaTeclado[0],'2'
                je  seccionRegistro 
                cmp lectorEntradaTeclado[0],'3'
                je  Salir 
                MOV dl, 0 
                reiniciarLectorTeclado dl  
                JMP ErrorEntradaPrincipal 
        errorLecturaArchivo:  
            imprimirEnConsola lecturaArchivoErronea
            jmp  menuInicial      
        errorAperturaArchivo: 
            imprimirEnConsola aperturaArchivoErronea
            jmp  menuInicial
	main endp
end