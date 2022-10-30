;- Trabajo práctico Nro 20
;- Douce, Germán A. - 106001
;** Conversor de Fechas **
;**************************************************************************************************
;Desarrollar un programa en assembler Intel 80x86 que permita convertir fechas válidas con el 
;formato DD/MM/AAAA a formato romano y/o juliano (DDD/AA); también debe permitir su inversa.
;Ejemplo:
; - Formato Fecha (DD/MM/AAAA): 14/10/2020
; - Formato Romano: XIV / X / MMXX
; - Formato Juliano (DDD/AA): 288/20
;****************************************************************************************************
;Comentarios y suposiciones del enunciado:
;
;
;

global main
extern printf
extern puts
extern sscanf 
extern gets

section     .data

    debug                       db  "debug",10,10,0
    debugConints                db "debug %hi %hi %hi",10,0
    formatoNum                  db " este es el numero: %hi %hi",10,0

    ;____ msjs ingresos usuario con formatos ___
    msjIngFormatoFecha        db  "Indique el formato de la fecha que desea convertir (1-gregoriano 2-romano 3-juliano)",10,0
    formatoCaracterIndicFecha db  "%hi"
    
    msjIngFechaFormatoGrego   db  "Ingrese una fecha en formato gregoriano (DD MM AAAA) separando con espacios los numeros ej: 05 04 2001",10,0
    formatoInputFechaGrego    db  "%hi %hi %hi" ;hi (16 bits, 2 bytes 1 word)


    msjIngFechaFormatoRom     db  "Ingrese una fecha en formato romano (DD/MM/AAAA)",10,0
    formatoIngFechaRom        db "%s %s %s",0 ;%s string

    msjIngFechaFormatoJul     db  "Ingrese una fecha en formato Juliano (DDD/AA)",10,0
    formatoIngFechaRJul       db "%hi %hi",0 ;
    
    ;___ msjs informe usuario _____

    msjInformeFechaGrego        db "Fecha en formato Gregoriano: %hi/%hi/%hi",10,0
    msjInformeFechaRom          db "Fecha en formato Romano: %s/%s/%s",10,0
    msjInformeFechaJul          db "Fecha en formato Juliano: %hi/%hi",10,0

    ;___Mensajes de error ___
    espacio                     db  "",10
    msjErrorValidarFechaGeneral db  "LA FECHA INGRESADA NO ES VALIDA.",10,10,0
    alertaAnioBisiesto          db  "El anio ingresado ES BISIESTO",10,0
    alertaAnioNoBisiesto        db  "El anio ingresado NO es bisiesto",10,0

    ;__vectores__
    vecDiasMeses                dw  31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    vecDiasMesesBisiestos       dw  31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    ;#DUDA es posible iterarlos si no son de  16 bits?

    ;___
    desplaz                         dw  0
    aux                             dw  0

section     .bss
    
    
    ;gregoriano DD/MM/AAAA
    strInputFechaGrego          resb    100 ;
    diaGrego                    resw    1 ; 2bytes 2049
    mesGrego                    resw    1
    anioGrego                   resw    1

    ;Romano DD/MM/AAAA pero con I X etc
    strInputFechaRom            resb    100 ;
    diaRom                      resd    3 ; 12bytes MCMLXXXVIII 1988
    mesRom                      resd    3 
    anioRom                     resd    3

    ;Juliano DDD/ AA
    strInputFechaJul            resb    100 ;
    diaJul                      resw    1 ; 2bytes 
    mesJul                      resw    1 
    anioJul                     resw    1

    ;indicadores de validez
    esValido                    resb    1 ;'S' - Si 'N'- No
    fechaEsValida               resb    1 ;'S' - Si 'N'- No
    esBisiesto                  resb    1

    ;caracter indicador de fecha
    strCaracterFormatoFecha     resb    64
    caracterFormatoFecha        resb    64


section     .text

main:

    call            ingresoFormatoFecha
    
    call            ingresoFecha

    call            mostrarConversiones



ret

ingresoFormatoFecha:

    mov             rcx, msjIngFormatoFecha
    sub             rsp,32
    call            printf
    add             rsp,32

    ;pido caracter indicador de formato de fechs
    mov             rcx,strCaracterFormatoFecha
    sub             rsp,32
    call            gets ;solo lee lo ingresado como texto. No castea nada
    add             rsp,32

    call            validarCaracterFecha ;validar que el caracter del formato de fecha es correcto
    cmp             byte[esValido],"N"
    je		        ingresoFormatoFecha     

    ret  

    validarCaracterFecha:   

        mov             byte[esValido], "N"; Le coloco un no a la var. es como un false antes del ciclo
        mov             rcx,strCaracterFormatoFecha; tomado el ingreso por teclado fuere cual fuere
        mov             rdx,formatoCaracterIndicFecha ; formatea el ingreso como lo escribi
        mov             r8, caracterFormatoFecha ;xa guardar el valor del caracter
        sub             rsp,32
        call            sscanf
        add             rsp,32

        cmp             rax,1
        jne             finValidarCaracterFecha

        cmp		        byte[caracterFormatoFecha],1
	    jl		        finValidarCaracterFecha
	    cmp		        byte[caracterFormatoFecha],3
	    jg		        finValidarCaracterFecha


        mov     byte[esValido], "S"
        finValidarCaracterFecha:
            ret


ingresoFecha:   

    cmp             byte[caracterFormatoFecha], 1 ;gregoriano
    je              ingFechaGrego

    cmp             byte[caracterFormatoFecha], 2 ;romano
    je              ingFechaRom

    cmp             byte[caracterFormatoFecha], 3 ;juliano
    je              ingFechaJul

    ;_______________________Ingreso Fecha Gregoriana ____________________________
    ingFechaGrego:
    
        mov             rcx, msjIngFechaFormatoGrego
        sub             rsp,32
        call            printf
        add             rsp,32   

        ;pido dia mes y anio con espacio (rcx la variable donde guardo)
        mov             rcx,strInputFechaGrego
        sub             rsp,32
        call            gets ;solo lee lo ingresado como texto. No castea nada
        add             rsp,32

        call            validarFechaGrego ;(Valida q sean 3 parametrs )
        cmp             byte[fechaEsValida],"N"

        je              ingFechaGrego 

        call             validarFechaGeneral 
        ;(Valida anios bissietso, fecha 
        ;existe etc)
        cmp              byte[fechaEsValida],"N"
        je               ingFechaGrego

        ;si la fecha es valida hago los pasajes necesarios

        ;call            convertirGregoAJul
        ;call            convertirGregoARom

        jmp              finIngresoFecha
        
        validarFechaGrego:
            mov     byte[fechaEsValida],"N"        
            ;asumo no valida y pregunto....
            mov		rcx,strInputFechaGrego
            mov		rdx,formatoInputFechaGrego
            mov		r8,diaGrego
            mov	    r9,mesGrego
            push    anioGrego
            
            sub		rsp,32
            call	sscanf
            add		rsp,32

            pop     r15;popeo de la pila anioGrego para poder volver de la call correctamente
            sub     r15,r15 ;lo dejo vacio por las dudas...     
            
            cmp		rax,3      
            jne		finValidarFechaGrego   

            ;si llegue hasta aca es valida       
            mov         byte[fechaEsValida],"S" 
            finValidarFechaGrego: 
                ret
    
    ;________________________Ingreso fecha Romana __________________________________
    ingFechaRom:

        mov             rcx, msjIngFechaFormatoRom
        sub             rsp,32
        call            printf
        add             rsp,32   

        ;pido dia mes y anio con espacio (rcx la variable donde guardo)
        ;mov             rcx,inputFilCol
        ;sub             rsp,32
        ;call            gets ;solo lee lo ingresado como texto. No castea nada
        ;add             rsp,32

        call            validarFechaRom ;   valido q sean 3 parametros y q sean letras
        cmp             byte[fechaEsValida],"N"
        je              ingFechaRom

        call            convertirRomAGrego
        ;convierto sea cual sea la fecha ingresada a gregoriano,
        ;luego valido con la rutina para ese tipo de fechas
        ;q la fecha exista, los anios esten en el rango valido etc
        call            validarFechaGeneral
        cmp             byte[fechaEsValida],"N"
        je              ingFechaRom

        ;como ingreso en Rom y ya pase a Grego para validar, 
        ;solo me queda pasar a Juliano,
        ;Como A grego ya pase antes, aprovecho la rutina q tengo
        ;xa ir de Grego a Rom

        call            convertirGregoAJul
        
        ;ya tengo convertida la fecha todos los formatos.

        jmp             finIngresoFecha
        

        validarFechaRom:
            ; mov		rcx,inputFilCol
            ; mov		rdx,formatInputFilCol
            ; mov		r8,fila
            ; mov		r9,columna
            ; sub		rsp,32
            ; call	sscanf
            ; add		rsp,32

            ; cmp		rax,2
            ; jl		finValidarFechaRom

            ;___validar anio___
            call        validarAnioRom
            cmp		    byte[fechaEsValida],"N" ;Letras son correctas
            je		    finValidarFechaRom
                        
            ;___validar mes___ 
            call        validarMesRom   ;Letras con correctas
            cmp		    byte[fechaEsValida],"N"	
            je		    finValidarFechaRom

            ;___validar dia___
            call        validarDiaRom ;letras son correctas 
            ;cmp		byte[fechaEsValida],"N"	
            ;je		    finValidarFechaRom

            finValidarFechaRom:
            
                ret

            validarAnioRom:
                mov         byte[fechaEsValida],"N"
                ;Valido letras con tabla
                ;jg
                
                mov     byte[fechaEsValida],"S"    
                finValidarAnioRom:
                    ret
            
            validarMesRom: 
                mov         byte[fechaEsValida],"N"
                ;valido letras con tabla
                
                mov     byte[fechaEsValida],"S"
                finValidarMesRom:
                    ret
            
            validarDiaRom:
                mov         byte[fechaEsValida],"N" 
                ;valido letras con tablas
                mov     byte[fechaEsValida],"S"
                finValidarDiaRom:
                    ret

    ;_____________________Ingreso Fecha Juliana ____________________________
    ingFechaJul:

        mov             rcx, msjIngFechaFormatoJul
        sub             rsp,32
        call            printf
        add             rsp,32


        ;pido dia mes y anio con espacio (rcx la variable donde guardo)
        ;mov             rcx,inputFilCol
        ;sub             rsp,32
        ;call            gets ;solo lee lo ingresado como texto. No castea nada
        ;add             rsp,32

        call            validarFechaJul ;   valido q sean 2 parametros y q los numeros sean validos
        cmp             byte[fechaEsValida],"N"
        je              ingFechaJul


        ;No hay manera de que la fecha jul no sea valida en terminos de
        ;fechas validas ya que son numeros. Ya valide antes q estos
        ;estuvieran en el rango esperado.
        call            convertirJulAGrego
        
        ;aprovecho la rutina q ya tengo
        call            convertirGregoARom
        
        ;ya tengo convertida la fecha todos los formatos.

        jmp             finIngresoFecha
        
        validarFechaJul:

            ; mov		rcx,inputFilCol
            ; mov		rdx,formatInputFilCol
            ; mov		r8,fila
            ; mov		r9,columna
            ; sub		rsp,32
            ; call	sscanf
            ; add		rsp,32

            ; cmp		rax,2
            ; jl		finValidarFechaJul

            ;___validar anio___
            call        validarAnioJul
            cmp		    byte[fechaEsValida],"N" ; 50 a 49
            je		    finValidarFechaJul

            ;___validar dia___
            call        validarDiaJul ;1 a 365
            ;cmp		    byte[fechaEsValida],"N"	
            ;je		    finValidarFechaRom

            finValidarFechaJul:
            
                ret

            validarAnioJul:
                mov        byte[fechaEsValida],"N"
                ;Valido anio de 50 a 49
                ;jg
                
                mov     byte[fechaEsValida],"S"    
                finValidarAnioJul:
                    ret
            
            validarDiaJul: 
                mov         byte[fechaEsValida],"N"
                ;valido dia de 1 a 365
                
                mov     byte[fechaEsValida],"S"
                finValidarDiaJul:
                    ret
    
    finIngresoFecha:
        
        mov             rcx, debug
        sub             rsp,32
        call            printf
        add             rsp,32 
        

        ret


mostrarConversiones:

    mov             rcx, msjInformeFechaGrego
    mov             rdx, [diaGrego]
    mov             r8, [mesGrego]
    mov             r9, [anioGrego]
    sub             rsp,32
    call            printf
    add             rsp,32 
    
    mov             rcx, msjInformeFechaRom
    sub             rsp,32
    call            printf
    add             rsp,32 

    mov             rcx, msjInformeFechaJul
    sub             rsp,32
    call            printf
    add             rsp,32 

    ret


;------------------------- Rutinas se usan varias veces ---------------------
;Rutina para validar un fecha en formato gregoriano
validarFechaGeneral:

            ;[fechaEsValida],"N"

            ;___validar anio___
            call        validarAnioGrego
            cmp		    byte[fechaEsValida],"N" ;esta entre 1950 y 2049
            je		    ErrorValidarFechaGeneral
                        
            ;___validar mes___ 
            ;esta entre 1 y 31
            call        validarMesGrego   ;guarda la pos en el vector de meses para porx validacion     
            cmp		    byte[fechaEsValida],"N"	
            je		    ErrorValidarFechaGeneral

            ;___validar dia___
            call        validarDiaGrego
            cmp		    byte[fechaEsValida],"N"	;Devuelve S en la variable esValid si el dia es
            je		    ErrorValidarFechaGeneral

            finvalidarFechaGeneral:
                ret
            ErrorValidarFechaGeneral:
                mov             rcx, espacio
                mov             rdx, msjErrorValidarFechaGeneral
                sub             rsp,32
                call            printf
                add             rsp,32
                jmp             finvalidarFechaGeneral             

            validarAnioGrego:
                ;entre 1950 y 2049
                mov         byte[fechaEsValida],"N"
                
                ;si lo hago mas mejor, valido contra un regitstro al q le mdeto anio max
                ;mov        r10,word[AnioLimiteSup]
                ;cmp        word[anioGrego],r10
                ;cmp        r10,word[anioGrego] ;OJO CAMBIAR EL JUmp por jl
                cmp         word[anioGrego],2050
                jge         finValidarAnioGrego
                
                cmp         word[anioGrego],1949
                jle         finValidarAnioGrego
                
                mov         byte[fechaEsValida],"S"    
                finValidarAnioGrego:
                    ret
            
            validarMesGrego: ;mes entre 1 y 12
                mov     byte[fechaEsValida],"N"
                
                cmp         word[mesGrego],12
                jg          finValidarMesGrego
                
                cmp         word[mesGrego],1
                jl          finValidarMesGrego

                mov         byte[fechaEsValida],"S"
                finValidarMesGrego:
                    ret
            
            validarDiaGrego: 
                mov         byte[fechaEsValida],"N"
                ;pregunto si el dia esta en el rango
                ;del numero de dias de posMes es
                cmp         word[diaGrego],0
                jle          finValidarDiaGrego; si menor a 0 ya corto la validacion

                ;es menor a 29 29 30 31..?
                ;[(columna -1) *(longElemento)]
                mov         ebx,0 ;relleno con 0 por las dudas para iterar
                mov         bx,word[mesGrego] ;ebx = mesGrego
                dec         bx         ;(columna -1) mesGregi -1 para pos en vector
                imul        bx,bx,2 ;(columna -1) *(longElemento)es un vector de words, 2 bytes c/u
                mov         word[desplaz],bx ;desplaz = pos en vector de meses

                ;pregunto si el anio es bisiesto
                call        anioBisiesto 
                ;esta rutina usa el bx, por eso tengo q reptir abajo... 
                mov     bx,word[desplaz]
                mov     rcx,2                       ;1) bytes de beneficio
                lea     rsi,[diaGrego]
                
                cmp		    byte[esBisiesto],"S"
                    je          diaAnioBisiesto            
            
                    lea     rdi,[vecDiasMeses + ebx]   ;3) #tabla de dias destino -> rdi
                                
                    jmp         diaEnRango
                
                diaAnioBisiesto:
                
                    lea     rdi,[vecDiasMesesBisiestos + ebx]
                    

                diaEnRango: ;pregunto si el dia esta en el rango

                repe        cmpsb                              
                jg          finValidarDiaGrego 
                
                mov     byte[fechaEsValida],"S"
                finValidarDiaGrego:
                    ret


;---------------------------------------------------------------------------------
;Convierte la fecha q este guardada en 
;FORMATO GREGORIANO en diaGrego - mesGrego  - anioGreo  
;a
;FORMATO ROMANO en diaRom - mesRom  - anioRom
convertirGregoARom:
    ret


;--------------------------------------------------------------------------------
;Convierte la fecha q este guardada en  
;FORMATO GREGORIANO endiaGrego - mesGrego  - anioGreo  
;a
;FOMRATO JULIANO en diaJul - mesJul  - anioJul
convertirGregoAJul:
    ret


;-----------------------------------------------------------------------------------
;Convierte la fecha q este guardada en diaRom mesRom anioRom 
;a gergoriano y guarda lo nuevos valores en diaGrego - mesGrego - anioGreo
convertirRomAGrego:
    ret


;Convierte la fecha q este guardada en  
;FOMRATO JULIANO en diaJul - mesJul  - anioJul
;a
;FORMATO GREGORIANO en diaGrego - mesGrego  - anioGreo  
;------------------------------------------------------------------------
convertirJulAGrego:
    ret



;chequea si un año es bisiesto y coloca en la var esBisiesto "S" o "N" 
anioBisiesto:
    mov 	ax,word[anioGrego]	;AX = ANIO      	
	sub 	dx,dx				;Limpio DX para dejar el resto
    mov 	BX, 400		;BX = 400
	div		BX	;Realiza la operacion AX/BX = ANIO/400 DX = resto
    cmp 	dx, 0
	je 		marcarBisiesto
	;si es divisible por 400 esBisiesto
	;sino sigo mirando
	NodivisiblePorCuatrocientosMiroPorCuatro:
		Mov 	ax, word[anioGrego]	;AX = ANIO				
        sub 	dx,dx						;Reinicializa el registro DX
        mov 	bx, 4 ;BX = 4
		div 	bx	; AX/BX = ANIO/ 4 DX = RESTO						        ;Hace la division AX/0004h
        cmp 	dx, 0
		jne 	marcarNoEsBisiesto						        
		;(no es divisible ni por 400 ni por 4 noEsBisiesto)
		;(no es divisible por 400, pero si por 4, Sigo mirando) 	
        
        NoDivisiblePorCuatrocientosSiPorCuatroMiroPorCien:
            ;Mov DX, 0000h	                          ;Reinicializa el registro DX
            sub 	dx,dx
            mov 	AX, word[anioGrego]
            mov 	bx,100	;BX = 100
            Div 	BX ; AX/BX = ANIO/100 DX = RESTO
            cmp 	dx, 0 
            je 		marcarNoEsBisiesto						       
            ;(no es divisible por 400, pero si por 4 y 100 entonces no es bisiesto)
            ;(no es divisible por 400, no es divisible por 400 pero si es divisible por 4 siEsBisiesto)
        marcarBisiesto:
            mov word[esBisiesto], "S"		
            
            mov		rcx,alertaAnioBisiesto
            sub		rsp,32
            call	printf
            add		rsp,32
            
            jmp     finAnioBisiesto							

    marcarNoEsBisiesto:
        mov word[esBisiesto], "N"		
        
        mov		rcx,alertaAnioNoBisiesto
        sub		rsp,32
        call	printf
        add		rsp,32

    finAnioBisiesto:
        ret
;---------------------------------------------------------------------




