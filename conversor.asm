
;Validar fechas en rangos esperados
;y tambien como corte de suma de simbolos
;             finLoop, "N"
;mov          byte[finNum], "S" ;pongo una S para dar el okey de q se ingreso bien
;call            validarFyC ;validamos. en esa rutina modificamos el valor de 'inputValido'
;cmp             word[FinNum], "N" ;N - no valido / S - valido
;je              ingresoDatos


; mov             byte[inputValido], "N"; Le coloco un no a la var. es como un false antes del ciclo
;        ;chequeo q haya casteado los 2 valores enteros ( por ej 3 E daria 1)
;        cmp             rax,2 ;
;        jl              invalido


;concatenar un simbolo a la vez en el loop
; en vez de 4 va 1
; mov eax, [fizz]
; mov [buffer], eax
; mov eax, [buzz]
; mov [buffer+4], eax