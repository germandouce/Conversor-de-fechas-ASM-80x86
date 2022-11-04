
        mov     [numeroRomanoArmado + ebx],r9w
        ;sub     rdi,rdi
        ;LEA     RDI,[numeroRomanoArmado]
        ;REP     MOVSB

        mov     rcx,debugConChar ;le paso a rcx la direc de cada ele al iterar en la tabla (siempre en la fila que me dio el usuario)
        ;mov     rdx,r8
        ;mov     r8,
        ;sub     rdx,rdx
        mov     rdx,numeroRomanoArmado
        sub		rsp,32
        call	printf
        add		rsp,32
        
        ;add    rsi,2   ;sumo 2 bytes xq es un vector de words
        add    rdi,2   ;sumo 2 bytes xq es un vector de words
        add    ebx,2   ;sumo 2 bytes al vector q armo
        ;add    eax,1   ;sumo 2 bytes al vector q armo
