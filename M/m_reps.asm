
;================ MACROS PARA EL MANEJO DE REPORTES============================== 

adjuntarEncabezadoTopPuntajes macro
    ;las dimensiones de la cadena  del encabezado serán fijas
    adjuntarContenidoArchivo 50,lineaSeparadora,controladorFicheros
    adjuntarContenidoArchivo 161,datosCurso,controladorFicheros
    adjuntarContenidoArchivo 43,misDatos,controladorFicheros
    adjuntarContenidoArchivo 50,lineaSeparadora,controladorFicheros
    adjuntarContenidoArchivo 50,lineaSeparadora,controladorFicheros
    adjuntarContenidoArchivo 51,tituloTopPuntajes,controladorFicheros
    adjuntarContenidoArchivo 50,lineaSeparadora,controladorFicheros
endm

adjuntarEncabezadoTopTiempos macro
    ;las dimensiones de la cadena  del encabezado serán fijas
    adjuntarContenidoArchivo 50,lineaSeparadora,controladorFicheros
    adjuntarContenidoArchivo 161,datosCurso,controladorFicheros
    adjuntarContenidoArchivo 43,misDatos,controladorFicheros
    adjuntarContenidoArchivo 50,lineaSeparadora,controladorFicheros
    adjuntarContenidoArchivo 50,lineaSeparadora,controladorFicheros
    adjuntarContenidoArchivo 50,tituloTopTiempos,controladorFicheros
    adjuntarContenidoArchivo 50,lineaSeparadora,controladorFicheros
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

establecerLimitesRango macro ;establece el punto inicial y final (del puesto en los tops)
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

reportarPuntajesEnFichero macro
    PUSH CX
    crearArchivo nombreReportePuntajes,controladorFicheros
    cerrarArchivo controladorFicheros ;se cierra el archivo para evitar problemas posteriores
    MOV dl, 2 ;indica que se use la ruta del archivo de indice 2 (Puntos.rep)
    MOV bl, 1 ;indicador de apertura y lectura del archivo 
    accionarArchivoEnrutado dl, bl ;se abre el contenido de se archivo
    adjuntarEncabezadoTopPuntajes
    POP CX
    adjuntarContenidoArchivo cx,escritorFicheroActual,controladorFicheros;cx posee el num de bytes para el archivo
    cerrarArchivo controladorFicheros ;se cierra el archivo para evitar problemas posteriores
    xor cx, cx
endm

reportarTiemposEnFichero macro
    PUSH CX
    crearArchivo nombreReporteTiempos,controladorFicheros
    cerrarArchivo controladorFicheros ;se cierra el archivo para evitar problemas posteriores
    MOV dl, 3 ;indica que se use la ruta del archivo de indice 3 (Tiempos.rep)
    MOV bl, 1 ;indicador de apertura y lectura del archivo 
    accionarArchivoEnrutado dl, bl ;se abre el contenido de se archivo
    adjuntarEncabezadoTopTiempos
    POP CX
    adjuntarContenidoArchivo cx,escritorFicheroActual,controladorFicheros;cx posee el num de bytes para el archivo
    cerrarArchivo controladorFicheros ;se cierra el archivo para evitar problemas posteriores
    xor cx, cx
endm

imprimirTop macro indicadorTitulo
     LOCAL topPuntajes, topTiempos, fin
     mostrarEncabezado
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
        reportarPuntajesEnFichero 
        jmp Fin
     generarTopTiempos:
        reportarTiemposEnFichero
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
    establecerLimitesRango
    ;Establece para CL el inicio y el fin (dado que sirve para asendentes y descendentes) 
    ;Basándonos en el top 10
    verificarFin:
      cmp  lectorEntradaFicheros[di], finCadena
      je finalizado
      cmp  cl, DS:[Orientador.puntoFinalTop] ; el fin se establecio en "establecerLimitesRango"
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
       MOV cx, si; para saber cuantos elementos/bytes se debrán agregar al archivo 
       xor si, si
       xor di, di
       POP DI
       POP SI   
endm  

obtenerLecturaOpcionTop macro
    LOCAL LecturaTop, ErrorEntradaTop, distribuirSubMenuTop, subMenusTop, seccionOrdenReportes 
    imprimirEnConsola menuTops 
    LecturaTop:               
        obtenerLecturaTeclado lectorEntradaTop
        cmp cl,1 ;Si la longitud de entrada es 1 puede ser una opción valida 
        je distribuirSubMenuTop ;se manda a validar la opción
        ErrorEntradaTop:
            imprimirEnConsola opcionErronea
            MOV dl, 3 ;indicador de borrar teclado top 
            reiniciarLectorTeclado dl
            jmp LecturaTop
    distribuirSubMenuTop:  
        MOV cl,0; reiniciamos el contador para futuras ocasiones  
        subMenusTop:             
            cmp lectorEntradaTop[0],'1'
            je  seccionOrdenReportes 
            cmp lectorEntradaTop[0],'2'
            je  seccionOrdenReportes 
            cmp lectorEntradaTop[0],'3'
            je  menuInicial 
            MOV dl, 3 ;indicador de borrar teclado top 
            reiniciarLectorTeclado dl  
            JMP ErrorEntradaTop
    seccionOrdenReportes:
            obtenerLecturaOpcionOrden         
endm

obtenerLecturaOpcionOrden macro
    LOCAL LecturaOrden, distribuirSubMenuOrden, ErrorEntradaOrden, subMenusOrden, seccionOrdenamientoReportes
    imprimirEnConsola menuOrden
    LecturaOrden:               
        obtenerLecturaTeclado lectorEntradaOrden
        cmp cl,1 ;Si la longitud de entrada es 1 puede ser una opción valida 
        je distribuirSubMenuOrden ;se manda a validar la opción
        ErrorEntradaOrden:
            imprimirEnConsola opcionErronea
            MOV dl, 4 ; indicador borrar teclado orden
            reiniciarLectorTeclado dl 
            jmp LecturaOrden
    distribuirSubMenuOrden:  
        MOV cl,0; reiniciamos el contador para futuras ocasiones  
        subMenusOrden:             
            cmp lectorEntradaOrden[0],'1'
            je  seccionOrdenamientoReportes 
            cmp lectorEntradaOrden[0],'2'
            je  seccionOrdenamientoReportes 
            MOV dl, 4 ; indicador borrar teclado orden
            reiniciarLectorTeclado dl  
            JMP ErrorEntradaOrden
    seccionOrdenamientoReportes:
            obtenerLecturaOpcionOrdenamiento   
endm

obtenerLecturaOpcionOrdenamiento macro
    LOCAL LecturaOrdenamiento, ErrorEntradaOrdenamiento, distribuirSubMenuOrdenamiento, subMenusOrdenamiento , seccionVelocidadReportes 
    imprimirEnConsola menuOrdenamientos
    LecturaOrdenamiento:               
        obtenerLecturaTeclado lectorEntradaOrdenamiento
        cmp cl,1 ;Si la longitud de entrada es 1 puede ser una opción valida 
        je distribuirSubMenuOrdenamiento ;se manda a validar la opción
        ErrorEntradaOrdenamiento:
            imprimirEnConsola opcionErronea
            MOV dl, 5 ; indicador borrar teclado orden
            reiniciarLectorTeclado dl 
            jmp LecturaOrdenamiento
    distribuirSubMenuOrdenamiento:  
        MOV cl,0; reiniciamos el contador para futuras ocasiones  
        subMenusOrdenamiento:             
            cmp lectorEntradaOrdenamiento[0],'1'
            je  seccionVelocidadReportes 
            cmp lectorEntradaOrdenamiento[0],'2'
            je  seccionVelocidadReportes
            cmp lectorEntradaOrdenamiento[0],'3'
            je  seccionVelocidadReportes 
            MOV dl, 5 ; indicador borrar teclado ordenamiento
            reiniciarLectorTeclado dl  
            JMP ErrorEntradaOrdenamiento
    seccionVelocidadReportes:
            obtenerLecturaOpcionVelocidad 
endm

obtenerLecturaOpcionVelocidad macro
    LOCAL LecturaVelocidad, ErrorEntradaVelocidad, distribuirSubMenuVelocidad, subMenusVelocidad, validacion  
    imprimirEnConsola solicitudVelocidad  
    LecturaVelocidad:               
        obtenerLecturaTeclado lectorEntradaVelocidad
        cmp cl,1 ;Si la longitud de entrada es 1 puede ser una opción valida 
        je distribuirSubMenuVelocidad ;se manda a validar la opción
        ErrorEntradaVelocidad:
            imprimirEnConsola opcionErronea
            MOV dl, 6 ; indicador borrar teclado orden
            reiniciarLectorTeclado dl 
            jmp LecturaVelocidad
    distribuirSubMenuVelocidad:  
        MOV cl,0; reiniciamos el contador para futuras ocasiones  
        subMenusVelocidad: 
            cmp lectorEntradaVelocidad[0],'0'
            je  validacion             
            cmp lectorEntradaVelocidad[0],'1'
            je  validacion 
            cmp lectorEntradaVelocidad[0],'2'
            je  validacion
            cmp lectorEntradaVelocidad[0],'3'
            je  validacion 
            cmp lectorEntradaVelocidad[0],'4'
            je  validacion 
            cmp lectorEntradaVelocidad[0],'5'
            je  validacion 
            cmp lectorEntradaVelocidad[0],'6'
            je  validacion 
            cmp lectorEntradaVelocidad[0],'7'
            je  validacion 
            cmp lectorEntradaVelocidad[0],'8'
            je  validacion 
            cmp lectorEntradaVelocidad[0],'9'
            je  validacion  
            MOV dl, 6 ; indicador borrar teclado ordenamiento
            reiniciarLectorTeclado dl  
            JMP ErrorEntradaVelocidad
    validacion:
            validarParametrosReporte
endm

;Los valores que se pasan a las macros "accionar resultados"
;determinan el orden(asc/desc) y si es reporte de tiempos o de puntajes
validarParametrosReporte macro
    LOCAL evaluarOrden, accionarAscendente, accionarDescendente, evaluarTop, accionarPuntajes, accionarTiempos, generarTop
    evaluarOrden:
        cmp lectorEntradaOrden[0], '2'; orden descendente
        je  accionarDescendente
        accionarAscendente:
            MOV ah, 0  ;0 asc
            jmp evaluarTop
        accionarDescendente:
            MOV ah, 1  ;1 desc
    evaluarTop:
        cmp lectorEntradaTop[0], '2'; top de tiempos
        je  accionarTiempos        
        accionarPuntajes:
            MOV bl, 0  ;puntajes
            jmp generarTop
        accionarTiempos:
            MOV bl, 1  ;tiempos
    generarTop: 
        ;animación y ordenamiewnto
        PUSH BX
        PUSH AX
        call pintarEscenario
        ;accion de ordenamiento
        call establecerModoTexto
        ;reporte:
        POP AX
        POP BX
        accionarTopResultados bl, ah
        jmp seccionTops ;hay que validar una paequeña pausa
endm

obtenerDataOrdenamientos macro 
    LOCAL verificarFin, ignorarUsername, ignorarNivel, obtenerIndice, obtenerPuntaje, incrementarPuntajes, obtenerTiempo, incrementarTiempos,ignorarSeparadorFila, finalizado 
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

    PUSH DI; guardamos un cero en pila para que el proceso sepa por donde empezar en "obtenerIndice"
    jmp ignorarUsername
    verificarFin:
      inc si
      cmp  lectorEntradaFicheros[si], finCadena
      je finalizado 
    ignorarUsername:
       inc si ;
       cmp lectorEntradaFicheros[si], coma
       je  ignorarNivel
       jmp ignorarUsername
    ignorarNivel: 
       inc si
       cmp lectorEntradaFicheros[si], coma
       je  obtenerIndice
       jmp ignorarNivel
    obtenerIndice:
      POP DI
      ;Si acaba de inicar el proceso obtendrá un cero, si no entonces obtendra el
      ;idice guasrdado en la etiqueta "guardar indice", y asi saber que posicion
      ;del vector nos toca para seguir guardando
      MOV AX, DI; guardamos una copia
      inc si
    obtenerPuntaje:   
       MOV bl, lectorEntradaFicheros[si]
       MOV puntajesDesordenados[di], bl
       inc si
       inc di
       cmp lectorEntradaFicheros[si], coma
       je  incrementarPuntajes
       jmp obtenerPuntaje 
    incrementarPuntajes:
      inc DS:[Graficador.cuentaPuntajesActuales]
    guardarIndice:
      ;dado que tanto puntajes como tiempos manejan una máximo de evaluación
      ;por decenas, entonces ambos tienen la misma loingitud, por lo que DI
      ;actual es el próximo indice a usar en futuras evaluaciones
      PUSH DI
      MOV DI, AX; a DI le asignamos la copia guardad del indice que necesitamos
      inc si
    obtenerTiempo:
       MOV bl, lectorEntradaFicheros[si]
       MOV tiemposDesordenados[di], bl 
       inc si
       inc di
       cmp lectorEntradaFicheros[si], puntoComa
       je  incrementarTiempos
       jmp obtenerTiempo   
    incrementarTiempos:
      inc DS:[Graficador.cuentaTiemposActuales]
    ignorarSeparadorFila: 
       inc si ;retorno de carro
       inc si  ;salto de linea
       jmp verificarFin                  
    finalizado:
       inc DI
       xor si, si
       xor di, di
       POP DI
       POP SI   
       ;imprimirEnConsola lectorEntradaFicheros[0]
       ;imprimirEnConsola tiemposDesordenados
       imprimirEnConsola puntajesDesordenados
       imprimirEnConsola debug
endm 

ordenarBurbujaPuntajes macro indicadorOrden  
   LOCAL elegirOrden, ordenarAscendente,desplazarmeSiguienteDesc, intercambiarPuntajesAsc,desplazarmeSiguienteAsc, verificarRepeticionAsc, ordenarDescendente, intercambiarPuntajesDesc,verificarRepeticionDesc, fin
   PUSH SI
   PUSH DI
   MOV ch, DS:[Graficador.cuentaPuntajesActuales]
   MOV cl, ch ;la copia servirá para el numero de iteraciones, iteraciones = numElementos
   dec ch; burbuja realiza comparaciones, donde comparaciones = numElementos - 1 
   MOV AH, indicadorOrden
   elegirOrden:
      MOV SI, 0
      MOV DI, digitosMaximosEvaluacion ;dado que entre centenas, decenas y unidades hay 3 posiciones de diferencia
      MOV ch, DS:[Graficador.cuentaPuntajesActuales]
      dec ch
      cmp ah, 1; 1 indica ascendentes
      je  ordenarAscendente
      jmp ordenarDescendente
      ordenarAscendente:
         call compararPuntajes ; dl = 1 si pos1 > pos 2
         cmp dl, 1
         je intercambiarPuntajesAsc
         jmp desplazarmeSiguienteAsc
         desplazarmeSiguienteAsc:
            ADD SI, digitosMaximosEvaluacion
            ADD DI, digitosMaximosEvaluacion
            jmp verificarRepeticionAsc
         intercambiarPuntajesAsc:
            call intercambiarPuntaje
         verificarRepeticionAsc:   
            dec ch
            cmp ch, 0
            jg ordenarAscendente
            jmp fin
      ordenarDescendente:
         call compararPuntajes ; dl = 0 si pos1 <  pos 2
         cmp dl, 0
         je intercambiarPuntajesDesc
         jmp desplazarmeSiguienteDesc
         desplazarmeSiguienteDesc:
            ADD SI, digitosMaximosEvaluacion
            ADD DI, digitosMaximosEvaluacion
            jmp verificarRepeticionDesc
         intercambiarPuntajesDesc:
            call intercambiarPuntaje
         verificarRepeticionDesc:   
            dec ch
            cmp ch, 0
            jg ordenarDescendente
            jmp fin
   fin:
      dec cl
      cmp cl, 0
      jg elegirOrden
      POP DI
      POP SI
endm





