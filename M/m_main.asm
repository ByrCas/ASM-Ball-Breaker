
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