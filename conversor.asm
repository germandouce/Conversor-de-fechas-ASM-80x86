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

    debug                     db  "debug",10,0

    ;____ msjs ingresos usuario ___
    msjIngFormatoFecha        db  "Indique el formato de la fecha que desea convertir (1-gregoriano 2-romano 3-juliano)",10,0
    
    msjIngFechaFormatoGrego   db  "Ingrese una fecha en formato gregoriano (DD/MM/AAAA)",10,0
    msjIngFechaFormatoRom     db  "Ingrese una fecha en formato romano (DD/MM/AAAA)",10,0
    msjIngFechaFormatoJul     db  "Ingrese una fecha en formato Juliano (DDD/AA)",10,0

    ;___ formatos de ingreso ___
    formatoCaracterIndicFecha db  "%hi"
    
    formatoIngFechaGrego      db "%hi %hi %hi",0 ;hi (16 bits, 2 bytes 1 word)
    formatoIngFechaRom        db "%s %s %s",0 ;%s string
    formatoIngFechaRJul       db "%hi %hi",0 ;

    ;___ msjs informe usuario _____

    msjInformeFechaGrego      db "Fecha en formato Gregoriano: %hi/%hi/%hi",10,0
    msjInformeFechaRom        db "Fecha en formato Romano: %s/%s/%s",10,0
    msjInformeFechaJul        db "Fecha en formato Juliano: %hi/%hi",10,0

section     .bss
    
    
    ;gregoriano DD/MM/AAAA
    diaGrego                    resw    1 ; 2bytes 2049
    mesGrego                    resw    1
    anioGrego                   resw    1

    ;Romano DD/MM/AAAA pero con I X etc

    diaRom                      resd    3 ; 12bytes MCMLXXXVIII 1988
    mesRom                      resd    3 
    anioRom                     resd    3

    ;Juliano DDD/ AA
    diaJul                      resw    1 ; 2bytes 
    mesJul                      resw    1 
    anioJul                     resw    1

    ;indicadores de validez
    esValido                    resb    1 ;'S' - Si 'N'- No
    fechaEsValida               resb    1 ;'S' - Si 'N'- No
    esBisiesto                  resb    1

    ;caracter indicador de fecha
    ;deberia lllamarse string o algo asi
    strCaracterFormatoFecha     resb    50
    caracterFormatoFecha        resb    1


section     .text

main:

    call            ingresoFormatoFecha
    
    call            ingresoFecha

    call            mostrarConversiones


ret

ingresoFormatoFecha:
    
    ;imprimo por pantalla pedido de fecha
    
    ;imprimo por pantalla pedido del formato de fecha de ingreso
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

    ;hasta que no ingrese un caracter valido (g r O J) no sale de la rutina
    ret  

    validarCaracterFecha:   

        mov             byte[esValido], "N"; Le coloco un no a la var. es como un false antes del ciclo
        ; guardo y leo caracter "casteo? esta al pedo esto #DUDA"
        mov             rcx,strCaracterFormatoFecha; tomado el ingreso por teclado fuere cual fuere
        mov             rdx,formatoCaracterIndicFecha ; formatea el ingreso como lo escribi
        mov             r8, caracterFormatoFecha ;xa guardar el valor del caracter
        sub             rsp,32
        call            sscanf
        add             rsp,32

        cmp             rax,1
        jne             finValidarCaracterFecha

        cmp		word[caracterFormatoFecha],1
	    jl		finValidarCaracterFecha
	    cmp		word[caracterFormatoFecha],3
	    jg		finValidarCaracterFecha


        mov             byte[esValido], "S"
        finValidarCaracterFecha:
            ret


ingresoFecha:   

    cmp             word[caracterFormatoFecha], 1 ;gregoriano
    je              ingFechaGrego

    cmp             word[caracterFormatoFecha], 2 ;romano
    je              ingFechaRom

    cmp             word[caracterFormatoFecha], 3 ;juliano
    je              ingFechaJul

    ;_______________________Ingreso Fecha Gregoriana ____________________________
    ingFechaGrego:
    
        mov             rcx, msjIngFechaFormatoGrego
        sub             rsp,32
        call            printf
        add             rsp,32   

        ;pido dia mes y anio con espacio (rcx la variable donde guardo)
        ;mov             rcx,inputFilCol
        ;sub             rsp,32
        ;call            gets ;solo lee lo ingresado como texto. No castea nada
        ;add             rsp,32

        call             validarFechaGrego ;(Valida q sean 3 parametrs )
        cmp              byte[fechaEsValida],"N"
        je               ingFechaGrego

        call             validarFechaGeneral 
        ;(Valida anios bissietso, fecha 
        ;existe etc)
        cmp              byte[fechaEsValida],"N"
        je               ingFechaGrego

        ;si la fecha es valida hago los pasajes necesarios

        call            convertirGregoAJul
        call            convertirGregoARom

        jmp              finIngresoFecha
        
        validarFechaGrego:
            mov         byte[fechaEsValida],"N"        
            ;asumo no valida y pregunto....
            ; mov		rcx,inputFilCol
            ; mov		rdx,formatInputFilCol
            ; mov		r8,fila
            ; mov		r9,columna
            ; sub		rsp,32
            ; call	sscanf
            ; add		rsp,32

            ; cmp		rax,2
            ; jl		finValidarFechaGrego
            
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
            cmp		    byte[fechaEsValida],"N" ;esta entre 1950 y 2049 ?
            je		    finvalidarFechaGeneral
                        
            ;___validar mes___ 
            ;esta entre 1 y 31
            call        validarMesGrego   ;guarda la pos en el vector de meses para porx validacion     
            cmp		    byte[fechaEsValida],"N"	
            je		    finvalidarFechaGeneral

            ;___validar dia___
            call        validarDiaGrego
            ;cmp		    byte[fechaEsValida],"N"	;Devuelve S en la variable esValid si el dia es
            ;je		    finvalidarFechaGeneral

            finvalidarFechaGeneral:
            
                ret

            validarAnioGrego:
                mov         byte[fechaEsValida],"N"
                ;entre 1950 y 2049
                
                ;jg
                mov     byte[fechaEsValida],"S"    
                finValidarAnioGrego:
                    ret
            
            validarMesGrego: ;mes entre 1 y 12 y guarda la pos del mes en posMes
                ;[posMes]
                mov     byte[fechaEsValida],"N"
                ;
                mov     byte[fechaEsValida],"S"
                finValidarMesGrego:
                    ret
            
            validarDiaGrego: 
                mov         byte[fechaEsValida],"N"
                ;pregunto si el dia esta en el rango
                ; del numero de dias de posMes es
                ;mov     ebx,posMes
                ;pregunto si el anio es bisiesto
                ;call     anioBisiesto
                ;cmp		  byte[esBisiesto],"S"
                je           diaAnioBisiesto            

                ;si no es bisisteo
                ;mov     al,[diasMeses + ebx]  
                ;con dias no bisisestos va a saltar si es 29 de feb xq tengo un 28
                jmp     diaEnRango
                
                diaAnioBisiesto:
                ;mov     al,[diasMesesBisiesto + ebx]  
                ;con dias bisisestos puede estar hasta el 29

                diaEnRango: ;pregunto si el dia esta en el rango
                    ;cmp    [dia],al
                    ;jle
                    ;bla bla
                    ;y mayor a 0
                
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
    
    mov     byte[esBisiesto],"S"
    ret
;---------------------------------------------------------------------




