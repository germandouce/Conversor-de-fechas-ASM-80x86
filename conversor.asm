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

    msjIngFormatoFecha        db  "Indique el formato de la fecha que desea convertir (g-gregoriano r-romano j-juliano)",10,0
    FormatoCaracterIndicFecha db  "%s"


    msjIngFechaFormatoGrego   db  "Ingrese una fecha en formato gregoriano (DD/MM/AAAA)",10,0
    msjIngFechaFormatoRom     db  "Ingrese una fecha en formato romano (DD/MM/AAAA)",10,0
    msjIngFechaFormatoJul     db  "Ingrese una fecha en formato Juliano (DDD/AA)",10,0
    
    formatoIngFechaGrego      db "%hi %hi %hi",0 ;hi (16 bits, 2 bytes 1 word)
    formatoIngFechaRom        db "%s %s %s",0 ;%s string
    formatoIngFechaRJul       db "%hi %hi"

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

    ;caracter indicador de fecha
    ingCaracterFormatoFecha     resb    1
    ingCaracterValido           resb    1
    caracterFormatoFecha        resb    1



section     .text

main:

ingresoDatos:
    ;imprimo por pantalla pedido de fecha
    
    ;imprimo por pantalla pedido del formato de fecha de ingreso
    mov             rcx, msjIngFormatoFecha
    sub             rsp,32
    call            printf
    add             rsp,32

    ;pido caracter indicador de formato de fechs
    mov             rcx,ingCaracterFormatoFecha
    sub             rsp,32
    call            gets ;solo lee lo ingresado como texto. No castea nada
    add             rsp,32

    
    call            validarCaracterFecha ;validar que el caracter del formato de fecha es correcto
    
    cmp             word[caracterFormatoFecha], "g" ;gregoriano
    je              ingFechaGrego

    cmp             word[caracterFormatoFecha], "r" ;romano
    je              ingFechaRom

    cmp             word[caracterFormatoFecha], "j" ;juliano
    je              ingFechaJul

ingFechaGrego:
    
    mov             rcx, msjIngFechaFormatoGrego
    sub             rsp,32
    call            printf
    add             rsp,32   

    jmp             finIngFechaGrego
    ;pido dia mes y anio con espacio (rcx la variable donde guardo)
    ;mov             rcx,inputFilCol
    ;sub             rsp,32
    ;call            gets ;solo lee lo ingresado como texto. No castea nada
    ;add             rsp,32
    
ingFechaRom:

    mov             rcx, msjIngFechaFormatoRom
    sub             rsp,32
    call            printf
    add             rsp,32   

    jmp             finIngFechaRom

ingFechaJul:

    mov             rcx, msjIngFechaFormatoJul
    sub             rsp,32
    call            printf
    add             rsp,32   

    finIngFechaGrego:
    
    finIngFechaRom:

    mov             rcx, debug
    sub             rsp,32
    call            printf
    add             rsp,32 
    

ret


validarCaracterFecha:

    ;mov             byte[inputValido], "N"; Le coloco un no a la var. es como un false antes del ciclo
    ; guardo y leo caracter "casteo? esta al pedo esto #DUDA"
    mov             rcx,ingCaracterFormatoFecha; tomado el ingreso por teclado fuere cual fuere
    mov             rdx,FormatoCaracterIndicFecha ; formatea el ingreso como lo escribi
    mov             r8, caracterFormatoFecha ;xa guardar el valor del caracter
    sub             rsp,32
    call            sscanf
    add             rsp,32
    
ret


