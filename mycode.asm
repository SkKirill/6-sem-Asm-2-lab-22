.MODEL SMALL
.STACK 100h
.DATA
 size dw ?             
 array dw 256 dup (?)  
 proc_res dw ?
 isNeg dw ?

 input_size_msg db "VVedite razmer massiva: $" 
 input_array_msg db "vvedite massiv : $"
 output_array_msg db "poluchenn massiv: $"
 pos_res_msg db "da$"
 neg_res_msg db "ne$"

 new_line db 0dh, 0ah, '$'

.CODE
start:
        MOV AX, @DATA 
        MOV DS, AX
        MOV AH, 9     
        MOV DX, offset input_size_msg   
        INT 21h       
        CALL ReadInteger  
        MOV size, AX   
        CALL PrintNewLine  

        MOV AH, 9       
        MOV DX, offset input_array_msg  
        INT 21h         
        CALL PrintNewLine 

        MOV DI, offset array  
        MOV CX, size       
        
    input_next_num:
        CALL ReadInteger    
        CALL PrintNewLine  
        MOV [DI], AX    
        ADD DI, 2       
        LOOP input_next_num 
        CALL PrintNewLine  

        MOV AH, 9        
        MOV DX, offset output_array_msg 
        INT 21h        

        MOV DI, offset array
        MOV CX, size    
        
    output_next_num:
        MOV AX, [DI]    
        ADD DI, 2      

        CALL WriteInteger  

        MOV AL, ' '     
        CALL WriteChar  

        LOOP output_next_num 
        CALL PrintNewLine 

        PUSH offset proc_res 
        PUSH offset array 
        PUSH offset size    
        CALL ArrayProc     
        
        CMP proc_res, 1  
        JNE output_false   
        
    output_true:
        MOV DX, offset pos_res_msg 
        JMP output         
        
    output_false:
        MOV DX, offset neg_res_msg
        JMP output           
output:
        MOV AH, 9h      
        INT 21h       
        INT 20h  

PrintNewLine PROC
        PUSH AX          
        PUSH DX          

        MOV AH, 9h    
        MOV DX, offset new_line 
        INT 21h         

        POP DX        
        POP AX           
        RET            
PrintNewLine ENDP

ReadChar PROC
        MOV AH, 1       
        INT 21h       
        RET              
ReadChar ENDP

WriteChar PROC
        PUSH AX            
        PUSH DX       

        MOV DL, AL  
        MOV AH, 2
        INT 21h        

        POP DX        
        POP AX         
        RET               
WriteChar ENDP

ReadInteger PROC
        PUSH CX            
        PUSH BX  
        PUSH DX           
        
        MOV isNeg, 0      
        XOR CX, CX    
        MOV BX, 10    

        CALL ReadChar   
        
        CMP AL,'-'     
        JE is_neg      
        JMP not_neg     

    is_neg:
        MOV isNeg, 1    

    read_next:
        CALL ReadChar    

    not_neg:
        CMP AL, 13       
        JE done        
        
        SUB AL, '0'      
        
        XOR AH, AH       
        XOR DX, DX    
        XCHG CX, AX      
        
        MUL BX         
        
        ADD AX, CX       
        XCHG AX, CX      
        JMP read_next    

    done:
        XCHG AX, CX       
        
        CMP isNeg, 1      
        JE set_neg     
        JMP set_not_neg   
        
    set_neg:
        NEG AX        
        
    set_not_neg:
        POP DX            
        POP BX         
        POP CX            
        RET            
ReadInteger ENDP

WriteInteger PROC
        PUSH AX            
        PUSH CX         
        PUSH BX          
        PUSH DX        
        
        XOR CX, CX     
        MOV BX, 10      
        CMP AX, 0      
        JL if_neg     
        JMP get_dig     

    if_neg:
        PUSH AX       
        MOV AL, '-' 
        CALL WriteChar  
        POP AX 
        NEG AX     
        
    get_dig:
        XOR DX, DX 
        DIV BX     
        
        PUSH DX     
        
        INC CX  
        CMP AX, 0    
        JG get_dig      
        
    write_dig:
        POP AX        
        ADD AL, '0'    
        
        CALL WriteChar 
        LOOP write_dig  
        
        POP DX         
        POP BX         
        POP CX       
        POP AX          
        RET              
WriteInteger ENDP

ArrayProc PROC
        PUSH BP        
        MOV BP, SP

        PUSH DI          
        PUSH CX           
        PUSH SI         
        PUSH DI           
        PUSH AX           

        MOV DI, [BP  + 4] 
        MOV CX, [DI]      
        MOV SI, [BP + 6]  
        MOV DI, [BP + 8]  
        
        MOV BX, CX         
        loop_edn_el:
        ADD SI, 2               
        
        LOOP loop_edn_el   
                       
        MOV AX, [SI]  
        MOV SI, [BP + 6]
        MOV CX, BX                                                              
        DEC CX
         

    loop_start:
        cmp AX, [SI]   
        JE output_true   
        ADD SI, 2       
        LOOP loop_start  
        JMP output_false  

    repeats_true:      
        MOV [DI], 1      
        JMP end_proc      

    repeats_false:       
        MOV [DI], 0     

    end_proc:
        POP AX          
        POP DI
        POP SI
        POP CX
        POP DI
        POP BP
        RET 6    
ArrayProc ENDP

end start
