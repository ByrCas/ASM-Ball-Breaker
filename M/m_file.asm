

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
    mov dx, offset rutaArchivo
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