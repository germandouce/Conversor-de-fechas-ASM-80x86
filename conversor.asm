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
    tiene                       db  "tiene espacio",10,10,0
    
    debugConChar                db "este es el char: %s",10,0
    formatoChar                 db "%s",10,0
    debugConInt                db  "esta es el numero %hi",10,10,0
    debugConints                db "debug %hi %hi %hi",10,0
    formatoNum                  db " este es el numero: %hi %hi",10,0

    ;____ msjs ingresos usuario con formatos ___
    msjIngFormatoFecha        db  "Indique el formato de la fecha que desea convertir (1-gregoriano 2-romano 3-juliano)",10,0
    formatoCaracterIndicFecha db  "%hi"
    
    msjIngFechaFormatoGrego   db  "Ingrese una fecha en formato gregoriano (DD MM AAAA) separando con espacios los numeros ej: 05 04 2001",10,0
    formatoInputFechaGrego    db  "%hi %hi %hi" ;hi (16 bits, 2 bytes 1 word)


    msjIngFechaFormatoRom     db  "Ingrese una fecha en formato romano (DD/MM/AAAA)",10,0
    formatoInputFechaRom        db "%s %s %s",0 ;%s string

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

    vecSimbolosRomanos          db  "M ",0 
                                db  "CM",0
                                db  "D ",0
                                db  "CD",0
                                db  "C ",0
                                db  "XC",0
                                db  "L ",0
                                db  "XL",0
                                db  "X ",0
                                db  "IX",0
                                db  "V ",0
                                db  "IV",0
                                db  "I ",0

    ;vecOrigin                   db  "1234",0

    vecValoresRomanos           dw  1000, 900, 500, 400,100, 90, 50, 40,10, 9, 5, 4, 1

    posEnVectoresRomanos        dd  0   ;para facilitar cuentas al moverme en vectores    
    
    tamNumeroRomanoArmado       dw  0

    posEnNumeroRomano           dd  0

    vecSimbolosRomanosSimple    db  "M",0 
                                db  "D",0
                                db  "C",0
                                db  "L",0
                                db  "X",0
                                db  "V",0
                                db  "I",0

    vecValoresRomanosSimple     dw  1000, 500, 100, 50, 10, 5, 1                                

    numeroGregorianoArmado      dw  0

    numeroDiaJuliano            dw  0

    ;___
    desplaz                         dw  0
    aux                             dw  0
    diaAux                          dw  0

section     .bss
    
    ;___auxiliares__
    aux_reg                     resw    1
    contadorRcx                 resq    1
    
    simboloRomano               resw    1
    numRomAux                   resb    100

    numeroRomanoArmado          resb    100
    vecDestiny                  resb    100    

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
    mov rbp, rsp; for correct debugging

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

        call            validarFechaGeneral 
        ;(Valida anios bissietso, fecha 
        ;existe etc)
        cmp              byte[fechaEsValida],"N"
        je               ingFechaGrego

        ;si la fecha es valida hago los pasajes necesarios

        ;_____GREGORIANO ---> ROMANO
        ;_____DIA____
        mov             r9w,[diaGrego]   ;r9w = diaGregoAux (4 bytes)
        call            convertirGregoARom

        mov             cx,word[tamNumeroRomanoArmado]
        LEA             RSI,[numeroRomanoArmado]
        LEA             RDI,[diaRom]      
        REP     MOVSB     
        
        ;_____MES____
        mov             r9w,[mesGrego]   ;r9w = mesGregoAux (4 bytes)
        call            convertirGregoARom

        mov             cx,word[tamNumeroRomanoArmado]
        LEA             RSI,[numeroRomanoArmado]
        LEA             RDI,[mesRom]      
        REP     MOVSB 
        
        ;_____ANIO____
        mov             r9w,[anioGrego]   ;r9w = anioGregoAux
        call            convertirGregoARom
        mov             cx,word[tamNumeroRomanoArmado]
        LEA             RSI,[numeroRomanoArmado]
        LEA             RDI,[anioRom]      
        REP     MOVSB 
        
        ;_____GREGORIANO ---> JULIANO
        ;laburoooo  #aqui
        call             convertirGregoAJul
        

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

        mov             rcx,strInputFechaRom
        sub             rsp,32
        call            gets ;solo lee lo ingresado como texto. No castea nada
        add             rsp,32

        call            validarFechaRom ;   valido q sean 3 parametros y q sean letras
        cmp             byte[fechaEsValida],"N"
        je              ingFechaRom


        ;ROMANO ---> GREGORIANO    
        ;___dia___
        sub     rdx,rdx ;saco basura
        LEA     rdx,[diaRom]
        ;en la rutina trabajao con la low efective adress que hay en el edx 
        call            convertirRomAGrego
        sub             r8,r8
        mov             r8w,word[numeroGregorianoArmado]
        mov             word[diaGrego],r8w

        ;___mes____
        sub             rdx,rdx ;saco basura
        LEA             rdx,[mesRom]

        call            convertirRomAGrego
        sub             r8,r8
        mov             r8w,word[numeroGregorianoArmado]
        mov             word[mesGrego],r8w

        ;___anio____
        sub             rdx,rdx ;saco basura
        LEA             rdx,[anioRom]

        call            convertirRomAGrego
        sub             r8,r8
        mov             r8w,word[numeroGregorianoArmado]
        mov             word[anioGrego],r8w

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
            mov     byte[fechaEsValida],"N"        
            ;asumo no valida y pregunto....
            mov		rcx,strInputFechaRom
            mov		rdx,formatoInputFechaRom
            mov		r8,diaRom
            mov	    r9,mesRom
            push    anioRom
    

            sub		rsp,32
            call	sscanf
            add		rsp,32

            pop     r15;popeo de la pila anioRom para poder volver de la call correctamente
            sub     r15,r15 ;lo dejo vacio por las dudas...     
            
            cmp		rax,3      
            jne		finValidarFechaGrego
            
            ;#DUDA debo validar que la fecha sea valida en romano con simbolos
            ; x ahora noooooo

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
    mov             rdx,diaRom
    mov             r8,mesRom
    mov             r9,anioRom
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
                jle         finValidarDiaGrego; si menor a 0 ya corto la validacion

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
                mov         bx,word[desplaz]
                mov         rcx,2                       ;1) bytes a comparar
                lea         rsi,[diaGrego]  
                

                ;2) RSI = DIA GREGO
                
                cmp		        byte[esBisiesto],"S"
                    je          diaAnioBisiesto            
            
                    lea         rdi,[vecDiasMeses + ebx]   
                    ;3) tabla de dias destino -> rdi
                                
                    jmp         diaEnRango
                
                diaAnioBisiesto:
                
                    lea         rdi,[vecDiasMesesBisiestos + ebx] 
                    ;3) tabla de dias destino -> rdi
                    

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
    ;bytesSimbolos = BytesNuemeros + posEnVcetores    
    sub rdx,rdx ;ya que el cociente se deposita en RDX:RAX, entonces hay que dejar el rdx vacio
    
    ;mov     ebx,22   ;contador en vector simbolos romanos

    ;OJOOOOOO
    ;mov      r9w,[anioGrego]   ;r9w = numeroAux (4 bytes)    #OJOOOOO
    mov      word[tamNumeroRomanoArmado],0
    
    mov      qword[numeroRomanoArmado],0    
    ;dejo con 0's el lugar donde voy a escribir el numero romano

    mov     dword[posEnVectoresRomanos],0 ;pongo en cero0

    sigDivision:
    sub     rdx,rdx ;#IMPORTANTISIMOOOOO

    sub     rbx,rbx ;#quito basura por las dudas
    mov     ebx,dword[posEnVectoresRomanos]
    
    imul    ebx,2  ;para el vecValoresRomanos son 2 bytes c/elemento
    mov     r10w,[vecValoresRomanos + ebx]  ;r10w = ValorSimboloRomano

    ;r9w = numAuxiliar
    sub     ax,ax   ;#basura
    mov     ax,r9w   ;AX = r9w = numeroAux dsps de restarle simbolo anterior 

    ;quitar lo de aca abajo
    ;mov     r10w,500
    ;mov     cx,500
    
    idiv    r10w     ;AX = AX/R10W 
    ;idiv    cx     ;AX = AX/R10W 
    ;cociente = AX = numero de veces a colocar ese simbolo
    ;sub     rcx,rcx
    ;mov     cx,ax ;CX = AX = veces a concatenar el simbolo
    ;ocurre que si el numero es pequenio, las primeras diviones dan 0. 
    ;chequeo eso
    ;cwde
    ;cdqe
    cmp     ax,0    
    je      sigSimbolo
    
    mov     cx,ax   ;si resultado de la divi es mayor a 0 entro
    ;sino, es q la divion dio mayor a 0, y el simbolo se debe ocncatenar al menos 1 vez 
    repeSimbolo:
        
        ;push rcx ;para no perder el valor del rcx en el loop
        push rcx
        call    concatenarSimbolo   ;
        pop rcx

        ;mov     rax,0   ;#dejo  0 en rax
    
        ;push rcx
        ;call       imprimirNumeroBien    
        ;pop rcx

        sub     r9w,r10w ;numAuxliar - Simbolo
        ;ret
        ;pop rcx

    loop  repeSimbolo

    ;cuando termine con ese simbolo 
    ;(itere tantas veces como res de la division)
    ;ya reste el simbolo a AX, pregunto si e queda algo
    
    ;mov            word[aux_reg],rax
    ; mov            rcx,debugConInt
    ; mov            rdx,r9
    ; sub            rsp,32
    ; call            printf
    ; add             rsp,32

    ;add     ebx,2       ;EBX = POS en vector simbolos romanos

    sigSimbolo:
        inc         dword[posEnVectoresRomanos]

        cmp         r9w,0 ;numAuxliar
        jg          sigDivision

    ;push rcx
    ;call    imprimirNumeroBien
    ;pop rcx
    ;si es mayo a 0 voy a la sig division

    ;add     word[tamNumeroRomanoArmado]
    ;mov     cx,word[tamNumeroRomanoArmado]
    ;LEA RSI,numeroRomanoArmado
    ;L;EA RDI,diaRom      
    ;REP MOVSB  

    ;push rcx
    ;call    unDebug
    ;pop rcx
    
    ret

concatenarSimbolo:
    mov     rcx,2  ;supongo no tiene espacio y copiare los 2 simbolos
    
    mov     rdx,0   ;#
    add     dx,2    ;DX =TamAAgrandar numero romano

    ;EBX = Bytes en vecSimbolosRomanos 
    ;Aca, en vecSimbolosRomanos c/"elemento" son 3 bytes entonces
    ;multiplico *3
    sub     ebx,ebx ;#quito basura por las dudas
    mov     ebx,dword[posEnVectoresRomanos]
    imul    ebx,3
    cmp     byte[vecSimbolosRomanos + ebx + 1]," " ; pregunto si tiene un espacio...

    ;#DUDA + efectivo??? poniendo predeterminadamente 1 byte y si no tiene, sumo 1 en
    jne      noTieneEspacio    

        ;si tiene espacio es q hay un solo simbolo Romano,
        mov     rcx,1       ;bytes a copiar
        mov     rdx,0       ;DX =TamAAgrandar numero romano
        add     dx,1        ;DX =TamAAgrandar numero romano


    noTieneEspacio:
    
    LEA RSI,[vecSimbolosRomanos + ebx] 

    mov rax,0
    mov ax,word[tamNumeroRomanoArmado]  ;#NOOOOOOOOOOOOOO: r10 para moverme en numeroRomanoArmado

    cwde    ;muy importante... 

    LEA RDI,[numeroRomanoArmado + eax]       

    REP MOVSB    

    ;______DEJAR ESTE DEBUG ALGO CORRE Y NO ROMPE____
    ;#sacar
    ;push rcx
    ;push  rdx
    ;call    imprimirNumero
    ;pop  rdx
    ;pop rcx
    ;_______Debug______

    ;add      ebx,3   ;3 bytes = 2  bytes letras + 0   
    
    add      word[tamNumeroRomanoArmado],dx   ;le sumo bytes a crecer
    
    ;call    unDebug

    ret



unDebug:

    mov             rcx,debug
    sub             rsp,32
    call            printf
    add             rsp,32

    ret

unDebugConInt:

    ;mov             word[aux],rax
    
    mov            rcx,debugConInt
    mov            rdx,[aux]
    sub            rsp,32
    call            printf
    add             rsp,32

    ret

otroDebugConInt:

    mov             word[aux],r9w
    
    mov            rcx,debugConInt
    mov            rdx,[aux]
    sub            rsp,32
    call            printf
    add             rsp,32

    ret

imprimirNumero:
    mov     rcx,numeroRomanoArmado
    sub		rsp,32
    call	printf  ;IMPRIME HASTA QUE ENCUENTRA UN 0
    add		rsp,32
    
    ret

imprimirNumeroBien:

    mov     rcx,numeroRomanoArmado
    sub		rsp,32
    call	printf  ;IMPRIME HASTA QUE ENCUENTRA UN 0
    add		rsp,32


    ret

;copiar numero

;#SACAR
copiarNumeroRomano:
;El problema es q yo no cuantos digitos tiene el numero que me ingresoe el usuario
;entonces no lo puedo copiar "completo"
    push rcx
    mov     dword[posEnNumeroRomano],0 ;pongo en cero
    proxChar:
        mov     rax,0   ;#saco basura x las dudas
        mov     ax,word[posEnNumeroRomano]  ;dde esta pos, 
        ;EAX = posEnNumero Romano
        cwde    ;muy importante... 
        cmp     byte[numRomAux + eax],0   ;si es 0 termino y ni entro, sino sigo
        je      finCalcTam
        
        ;si no es igual
        inc     word[posEnNumeroRomano] ;pops + 1
        jmp     proxChar

    finCalcTam:
    mov     cx,word[posEnNumeroRomano] 
    inc     rcx ;bytes a copiar = posNumeroRomano + 1 xq arranca en 0
        
    LEA RDI,[simboloRomano] ;lo cargo ahi

    REP MOVSB

    pop rcx

    ;una vez q tengo el tamanio,



;--------------------------------------------------------------------------------
;Convierte la fecha q este guardada en  
;FORMATO GREGORIANO endiaGrego - mesGrego  - anioGreo  
;a
;FOMRATO JULIANO en diaJul - mesJul  - anioJul
convertirGregoAJul:

    mov         word[numeroDiaJuliano],0
    sub         r9,r9 ;saco basuraa
    mov         r9w,[diaGrego]  ;r9w = numero pivot
    add         word[numeroDiaJuliano],r9w  ;sumo los dias siempre

    sub         r10,r10
    mov         r10w,word[mesGrego] ;r10w = mesAux  

    cmp         byte[esBisiesto],"S"
    jne         restarSigMes
    ;si es bisiesto pregunto si el mes es mayor a 2
        cmp         word[mesGrego],2
        jle         restarSigMes ;listo, resto meses
        ;si es mayor a 2 sumo 1 al dia
            inc         word[numeroDiaJuliano]  ;NumeroDiaJuliano + 1

    restarSigMes:

        dec     r10w
        cmp     r10w,0
        je      finRestarMeses    ;si es 1 o mas resto sig mes

        sub     rax,rax            
        mov     ax,r10w    ;rax = mesAux
        cwde    ;#va????
        imul    eax,2   ;cada ele de vecDiasMeses es una word
        sub     rbx,rbx
        add     bx,[vecDiasMeses + eax - 2 ] ; mesAux - 2 bytes = mesAux - 1mes
        ;bx = dias mesAux
        add     word[numeroDiaJuliano],bx   ;los sumo

        push rcx
        mov            rcx,debugConInt
        mov            rdx,r10
        sub            rsp,32
        call            printf
        add             rsp,32
        pop rcx

        jmp restarSigMes

    finRestarMeses:

        push rcx
        mov            rcx,debugConInt
        mov            rdx,[numeroDiaJuliano]
        sub            rsp,32
        call            printf
        add             rsp,32
        pop rcx
    
    ret


;-----------------------------------------------------------------------------------
;Convierte la fecha q este guardada en diaRom mesRom anioRom 
;a gergoriano y guarda lo nuevos valores en diaGrego - mesGrego - anioGreo
convertirRomAGrego:
    
    mov     dword[posEnNumeroRomano],0 ;pongo en cero
    
    mov     dword[numeroGregorianoArmado],0

    ;posEnNumRom

    sigCharRom:
        
        mov     rax,0   ;#saco basura x las dudas
        ;#OJO TAMANIOS
        mov     ax,word[posEnNumeroRomano]  ;dde esta pos, 
        ;EAX = posEnNumero Romano
        cwde    ;muy importante... 

        ;#OJO
        cdqe

        ;mov     ebx,0   
        ;cmp     byte[diaRom + eax],0   ;si es 0 termino y ni entro, sino sigo
        ;cmp     byte[edx + eax],0   ;si es 0 termino y ni entro, sino sigo
        cmp     byte[rdx + rax],0   ;si es 0 termino y ni entro, sino sigo
        je      finLecturaNumRom

        push rcx
        call    copiarDigitoEnSimboloRomano
        pop rcx
        ;deja simboloRomano = letra a comparar y buscar
        
        ;una vez que tengo el digito el la "var" simboloRomano
        push    rcx
        call     buscarPosCharRom
        pop rcx
        ;deja en posEnVectoresRomanos la pos del simbolo posible a sumar

        sub     r9,r9 ;#saco basura x las dudas
        sub     ebx,ebx ;saco basura
        mov     ebx, dword[posEnVectoresRomanos] ;ebx = pos en vectores
        ;en el vector de simbolos, cada ele mide 2 bytes
        imul    ebx,2
        mov     r9w,[vecValoresRomanosSimple + ebx]  
        ;R9W = valor a sumar o restar    

        chequeoSumOResta:
            ;pregunto por la sig leyra xa ver si es mayor o menor.
            ;primero busco su pos en el vec
            ;#CODIGO REPE, DSPS LO SACO
            mov     rcx,1 ;siempre copio 1 byte #OJO EL ULTIMO 0?????
            
            ;inc     eax ;EAX = posEnNumeroRomano + 1 xq voy a chequear sig letra
            ;#ojo
            inc     rax
            
            cwde    ;muy importante... 
            ;#OJO
            cdqe

            cmp     byte[rdx + rax],0   ;si es 0 termino y ni entro, sino sigo
            je      sumarValor
            ;sino, copio y vuelco a comparar y obtener pos...

            push rcx
            call    copiarDigitoEnSimboloRomano
            pop rcx

            push    rcx
            call     buscarPosCharRom
            pop rcx
            ;queda la pos posEnVectoresRomanos

            sub     ebx,ebx ;saco basura
            mov     ebx, dword[posEnVectoresRomanos] ;ebx = pos en vectores
            ;en el vector de simbolos, cada ele mide 2 bytes
            imul    ebx,2
            ;uso el r10w xq el r9 ya lo use para el primer simbolo
            sub     r10,r10 ;#Saco basura, (casi seguro que debo hacerlo)
            mov     r10w,[vecValoresRomanosSimple + ebx]  
            ;R10W = Sig Valor

            cmp     r10w,r9w
            
            ;SigValor - PrimeroValor = r10w - r9w
            ;comparo a ver si el sig elemento es menor o mayor. 
            ;si es menor, sumo el valor
            jle      sumarValor
                ;si es mayor, hago r10w - r9w
        
                sub     r10w,r9w    ;2do num(grande) - 1erNum (chiquito)

                ;avanzo la posEnNumeroRomano 1 + xq lei 2 letras
                add     dword[posEnNumeroRomano],1   ;pos + 1 

                mov     r9w,r10w    ;dejo en r10w el resultado de la resta

        sumarValor:
            add     word[numeroGregorianoArmado],r9w

        ;push rcx
        ;mov            rcx,debugConInt
        ;mov            rdx,[numeroGregorianoArmado]
        ;sub            rsp,32
        ;call            printf
        ;add             rsp,32
        ;pop rcx
                
        add     dword[posEnNumeroRomano],1   ;pos + 1 
        jmp     sigCharRom 

    finLecturaNumRom:

        ret


    ret

copiarDigitoEnSimboloRomano:
    
    push    rcx

    mov     rcx,1 ;siempre copio 1 byte #OJO EL ULTIMO 0?????
        
    ;LEA RSI,[diaRom + eax]  ;dde este digito copio 1 byte        
    ;LEA RSI,[edx + eax]  ;dde este digito copio 1 byte        
    LEA RSI,[rdx + rax]  ;dde este digito copio 1 byte        

    LEA RDI,[simboloRomano] ;lo cargo ahi

    REP MOVSB

    pop rcx

    ret


buscarPosCharRom:
    
    mov     dword[posEnVectoresRomanos],0 ;pongo en cero0
    
    sigCharRomEnVec:

        LEA     RSI,[simboloRomano]   ;dejo en el rsi el simbolo

        MOV     RCX,1   ;bytes a comparar, siempre uno a la vez
        sub     ebx,ebx ;#quito basura por las dudas
        mov     ebx,dword[posEnVectoresRomanos]
        imul    ebx,2   ;xq son de 2 bytes cada "elemento " (Letra + el 0)

        LEA     RDI,[vecSimbolosRomanosSimple + ebx ]
        
        REPE    CMPSB        ;comparo si el simbolo del nuemro es igual al del vecto

        je      finBuscarPosChar
        ;si no es igual, sumo 1 pos. Si es igual salto y
        ; en posEnVectoresRomanos quedo la pos 
        
        inc     dword[posEnVectoresRomanos] ;sig letra o par de letras
    
        jmp    sigCharRomEnVec

    finBuscarPosChar:
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




