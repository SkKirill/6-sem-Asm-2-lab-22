.MODEL SMALL
.STACK 100h
.DATA
 size dw ?             ; Ob'yavlenie peremennoi 'size' tipa slovo dlya sokhraneniya razmera massiva
 array dw 256 dup (?)  ; Ob'yavlenie massiva 'array' tipa slovo razmera 256
 proc_res dw ?        ; Ob'yavlenie peremennoi 'proc_res' dlya sokhraneniya rezul'tata ArrayProc
 isNeg dw ?            ; Ob'yavlenie peremennoi 'isNeg' dlya otslezhivaniya, yavlyaetsya li chislo otritsatelnym

 input_size_msg db "VVedite razmer massiva: $"  ; Soobshenie dlya vvedeniya razmera massiva
 input_array_msg db "vvedite massiv : $"  ; Soobshenie dlya vvedeniya elementov massiva
 output_array_msg db "poluchenn massiv: $" ; Soobshenie dlya vivoda massiva
 pos_res_msg db "da$"  ; Soobshenie o polozhitel'nom rezul'tate
 neg_res_msg db "ne$"  ; Soobshenie o otritsatel'nom rezul'tate

 new_line db 0dh, 0ah, '$' ; Simvol novoy stroki

.CODE
start:
        MOV AX, @DATA    ; Pominayem ssylku na segment dannykh v AX, zatem zanosim v register DS
        MOV DS, AX
        MOV AH, 9        ; Preryvanie, vyzov po int
        MOV DX, offset input_size_msg   ; Çàãðóæàåì adres soobsheniya input_size_msg (adres na nachalo stroki)
        INT 21h          ; Preryvanie i vivod
        CALL ReadInteger   ; Vyzyvayem protseduru ReadInteger, chtoby schitat' chislo ot pol'zovatelya
        MOV size, AX     ; Zanosim size v register AX
        CALL PrintNewLine  ; Vivodim novuyu stroku (perehod na novuyu stroku)

        MOV AH, 9        ; Zanosim kod funktsii dlya vivoda stroki
        MOV DX, offset input_array_msg  ; Çàãðóæàåì adres soobsheniya input_array_msg
        INT 21h          ; Vyzyvayem preryvanie DOS dlya vivoda soobsheniya
        CALL PrintNewLine  ; Vivodim novuyu stroku

        MOV DI, offset array ; Çàãðóæàåì adres massiva 'array' v register DI 
        MOV CX, size        ; Ustanavlivaem schetchik cykla CX na 'size'
        
    input_next_num:
        CALL ReadInteger    ; Schitaiem tseloe chislo
        CALL PrintNewLine  ; Vivodim novuyu stroku
        MOV [DI], AX     ; Sokranyayem vvedennoye chislo v massive
        ADD DI, 2         ; Uvelichivayem DI (na 2), chtoby ukazat' na sleduyushuyu pozitsiyu massiva
        LOOP input_next_num ; Umenshaya CX, vozvraschaemsya k input_next_num, esli CX ne ravno nol'
        CALL PrintNewLine  ; Vivodim novuyu stroku

        MOV AH, 9        ; Ustanavlivaem kod funktsii dlya vivoda stroki
        MOV DX, offset output_array_msg ; Çàãðóæàåì adres soobsheniya output_array_msg
        INT 21h          ; Vyzyvayem preryvanie DOS dlya vivoda soobsheniya

        MOV DI, offset array ; Çàãðóæàåì adres massiva 'array (vvedennyy pol'zovatelem)' v DI dlya vivoda
        MOV CX, size        ; Ustanavlivaem schetchik cykla CX na 'size'
        
    output_next_num:
        MOV AX, [DI]     ; Peremeshchayem tekushchiy element massiva v AX
        ADD DI, 2         ; Uvelichivayem DI, chtoby ukazat' na sleduyushuyu pozitsiyu massiva

        CALL WriteInteger   ; Vyzyvayem WriteInteger, chtoby vivesti tekushcheye chislo

        MOV AL, ' '      ; Zanosim simvol probela v AL
        CALL WriteChar   ; Vyzyvayem WriteChar, chtoby vivesti probel

        LOOP output_next_num ; Umenshaya CX, vozvraschaemsya k output_next_num, esli CX ne ravno nol'
        CALL PrintNewLine  ; Vivodim novuyu stroku

        PUSH offset proc_res ; Zanosim adres 'proc_res' v stek
        PUSH offset array   ; Zanosim adres 'array' v stek
        PUSH offset size    ; Zanosim adres 'size' v stek
        CALL ArrayProc      ; Vyzyvayem protseduru ArrayProc
        
        CMP proc_res, 1    ; Sravnivaem 'proc_res' s 1
        JNE output_false   ; Esli 'proc_res' ne ravno 1, pereskaem k output_false
        
    output_true:
        MOV DX, offset pos_res_msg ; Zanosim adres soobsheniya o polozhitel'nom rezul'tate
        JMP output           ; Pereklichivaem k output
        
    output_false:
        MOV DX, offset neg_res_msg ; Zanosim adres soobsheniya o otritsatel'nom rezul'tate
        JMP output           ; Pereklichivaem k output
output:
        MOV AH, 9h       ; Ustanavlivaem kod funktsii dlya vivoda stroki
        INT 21h          ; Vyzyvayem preryvanie DOS dlya vivoda soobsheniya
        INT 20h          ; Zavershayem programmu

PrintNewLine PROC
        PUSH AX            ; Sokranyayem AX v steke
        PUSH DX            ; Sokranyayem DX v steke

        MOV AH, 9h       ; Ustanavlivaem kod funktsii dlya vivoda stroki
        MOV DX, offset new_line ; zagruzim adres simvola novoy stroki
        INT 21h          ; Vyzyvayem preryvanie DOS dlya vivoda novoy stroki

        POP DX            ; Vozvrashchayem DX iz steka
        POP AX            ; Vozvrashchayem AX iz steka
        RET               ; Vozvrat k zovushchey protsedure
PrintNewLine ENDP

ReadChar PROC
        MOV AH, 1        ; Ustanavlivaem kod funktsii dlya chteniya simvola
        INT 21h          ; Vyzyvayem preryvanie DOS dlya chteniya simvola
        RET               ; Vozvrat k zovushchey protsedure
ReadChar ENDP

WriteChar PROC
        PUSH AX            ; Sokranyayem AX v steke
        PUSH DX            ; Sokranyayem DX v steke

        MOV DL, AL       ; Zanosim simvol v DL
        MOV AH, 2        ; Ustanavlivaem kod funktsii dlya vivoda simvola
        INT 21h          ; Vyzyvayem preryvanie DOS dlya vivoda simvola

        POP DX            ; Vozvrashchayem DX iz steka
        POP AX            ; Vozvrashchayem AX iz steka
        RET               ; Vozvrat k zovushchey protsedure
WriteChar ENDP

ReadInteger PROC
        PUSH CX            ; Sokranyayem CX v steke
        PUSH BX            ; Sokranyayem BX v steke
        PUSH DX            ; Sokranyayem DX v steke
        
        MOV isNeg, 0       ; Iznachal'no ustanavlivaem 'isNeg' v 0 (lozh')
        XOR CX, CX      ; Obnulyayem CX (ispol'zuyetsya dlya nakopleniya tselochisan)
        MOV BX, 10      ; Zanosim 10 v BX (osnova dlya desyatichnogo preobrazovaniya)

        CALL ReadChar     ; Vyzyvayem ReadChar, chtoby schitat' perviy simvol
        
        CMP AL,'-'       ; Proverÿåì, yavlyaetsya li simvol '-' 
        JE is_neg        ; Esli eto tak, perekhod k is_neg
        JMP not_neg       ; Esli ne tak, perekhod k not_neg

    is_neg:
        MOV isNeg, 1      ; Ustanavlivaem 'isNeg' v 1 (pravil'no)

    read_next:
        CALL ReadChar     ; Vyzyvayem ReadChar, chtoby schitat' sleduyushchiy simvol

    not_neg:
        CMP AL, 13       ; Proverÿåì, yavlyaetsya li simvol Carriage Return (13)
        JE done          ; Esli da, perekhod k done
        
        SUB AL, '0'       ; Preobrazuyem simvol v ego tsifrovoye znacheniye
        
        XOR AH, AH       ; Obnulyayem registr AH
        XOR DX, DX       ; Obnulyayem registr DX
        XCHG CX, AX       ; Menyayem mestami CX i AX
        
        MUL BX          ; Umnozhayem CX na 10
        
        ADD AX, CX       ; Dobavlayem predydushcheye znacheniye CX k rezul'tatu
        XCHG AX, CX       ; Menyayem mestami AX i CX
        JMP read_next     ; Vozvrashchayem k read_next

    done:
        XCHG AX, CX       ; Menyayem mestami AX i CX
        
        CMP isNeg, 1      ; Proverÿåì, yavlyayetsya li chislo otritsatelnym
        JE set_neg       ; Esli da, perekhod k set_neg
        JMP set_not_neg   ; Esli ne da, perekhod k set_not_neg
        
    set_neg:
        NEG AX          ; Menyayem znak AX, esli chislo bylo otritsatel'nym
        
    set_not_neg:
        POP DX            ; Vozvrashchayem DX iz steka
        POP BX            ; Vozvrashchayem BX iz steka
        POP CX            ; Vozvrashchayem CX iz steka
        RET               ; Vozvrat k zovushchey protsedure
ReadInteger ENDP

WriteInteger PROC
        PUSH AX            ; Sokranyayem AX v steke
        PUSH CX            ; Sokranyayem CX v steke
        PUSH BX            ; Sokranyayem BX v steke
        PUSH DX            ; Sokranyayem DX v steke
        
        XOR CX, CX      ; Obnulyayem CX (ischitayetsya dlya scheta tsifry)
        MOV BX, 10      ; Zanosim 10 v BX (osnova dlya desyatichnogo preobrazovaniya)
        CMP AX, 0       ; Proverÿåì, menshe li AX 0
        JL if_neg       ; Esli menshe, perekhod k if_neg
        JMP get_dig     ; Esli ne menshe, perekhod k get_dig

    if_neg:
        PUSH AX         ; Zanosim AX v stek
        MOV AL, '-'     ; Zanosim '-' v AL
        CALL WriteChar  ; Vyzyvayem WriteChar dlya vivoda '-'
        POP AX          ; Vyzvashchaem AX iz steka
        NEG AX         ; Menyayem znak AX
        
    get_dig:
        XOR DX, DX    ; Obnulyayem DX
        DIV BX          ; Delim AX na 10
        
        PUSH DX        ; Zanosim ostatok (tsifra) v stek
        
        INC CX          ; Uvelichivayem CX (schetchik tsifry)
        CMP AX, 0     ; Proverÿåì, bol'she li AX 0
        JG get_dig      ; Esli bol'she, perekhod k get_dig
        
    write_dig:
        POP AX        ; Vyzvashchaem tsifru iz steka
        ADD AL, '0'    ; Preobrazuyem tsifru v ee ASCII predstavlenie
        
        CALL WriteChar ; Vyzyvayem WriteChar dlya vivoda tsifry
        LOOP write_dig  ; Umenshaya CX, vozvrashchayem k write_dig, esli CX ne ravno nol'
        
        POP DX          ; Vozvrashchayem DX iz steka
        POP BX         ; Vozvrashchayem BX iz steka
        POP CX          ; Vozvrashchayem CX iz steka
        POP AX          ; Vozvrashchayem AX iz steka
        RET               ; Vozvrat k zovushchey protsedure
WriteInteger ENDP

ArrayProc PROC
        PUSH BP         ; Sokranyayem staroe znachenie BP v steke
        MOV BP, SP;  ; Menyayem ukazatel' steka na BP, ustanavlivaya stekniy ramka

        PUSH DI            ; Sokranyayem DI v steke
        PUSH CX            ; Sokranyayem CX v steke
        PUSH SI            ; Sokranyayem SI v steke
        PUSH DI            ; Sokranyayem DI v steke (izbytochno, no mozhno dlya vyrovnaniya)
        PUSH AX            ; Sokranyayem AX v steke

        MOV DI, [BP  + 4] ; Menyayem adres dliny massiva k DI
        MOV CX, [DI]      ; Menyayem dlinu massiva iz DI v CX (schetchik cykla)
        MOV SI, [BP + 6]  ; Menyayem adres massiva v SI
        MOV DI, [BP + 8]  ; Menyayem adres peremennoi dlya rezul'tata v DI
        
        MOV BX, CX        ; Vyacheslavayem adres poslednego elementa v massive    
        loop_edn_el:
        ADD SI, 2          ; Perekhodym SI na sleduyushchiy element massiva     
        
        LOOP loop_edn_el   
                       
        MOV AX, [SI]  
        MOV SI, [BP + 6]
        MOV CX, BX                                                              
        DEC CX
          ; Umenshayem schetchik cyka, chtoby uchityvat' pervyy element, kotoryy uzhe provyren

    loop_start:
        cmp AX, [SI]      ; Sravnivayem tekushchiy element massiva s poslednim elementom
        JE output_true   ; Esli oni ravny, perekhod k output_true
        ADD SI, 2        ; Perekhodym SI na sleduyushchiy element massiva
        LOOP loop_start   ; Umenshayem CX i vozvrashchayem k loop_start, esli CX ne ravno nol'
        JMP output_false  ; Perekhodym k output_false, esli tsiklenye ubrat' podkhod chisl

    repeats_true:       ; Esli tsiklenye naydeshchiy 
        MOV [DI], 1      ; Ustanavlivaem peremennuyu rezul'tata v 1 (pravda)
        JMP end_proc      ; Perekhodym k kontsovoy protsedure

    repeats_false:        ; Esli cykle ne nahodit
        MOV [DI], 0     ; Ustanavlivaem peremennuyu rezul'tata v 0 (lozhno)

    end_proc:
        POP AX          ; Vozvrashchayem znacheniya iz steka
        POP DI
        POP SI
        POP CX
        POP DI
        POP BP
        RET 6         ; Vozvrat k zovushchey programme, ochistiv stek (6 bayt udaleny)
ArrayProc ENDP

end start
