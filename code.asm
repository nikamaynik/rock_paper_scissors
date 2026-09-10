; Rock, Paper, Scissors.
; A simple game on 32-bit Linux NASM Assembly.

section .data
    ; ---ui/ux---
    welcome0 db "__-->_Rock,_Paper,_Scissors_game_<--__", 10
    welcome0_len equ $ - welcome0
    welcome1 db "Welcome User", 10
    welcome1_len equ $ - welcome1 
    query db "Choose a number: 1 (Rock), 2 (Paper), 3 (Scissors): ", 10
    query_len equ $ - query
    res_msg db "The computer chose ", 0 
    res_msg_len equ $ - res_msg   
    newline db 0xA, 0

    ;---Random num generation vars--- 
    minValue dd 1
    maxValue dd 3 
    
section .bss
    user_number resb 2
    bot_number resb 2    
    
section .text
    global _start

_start:
    ;---Display ui/ux---
    mov ecx, welcome0 
    mov edx, welcome0_len
    call .print
    mov ecx, welcome1 
    mov edx, welcome1_len
    call .print
    mov ecx, query 
    mov edx, query_len
    call .print
    ;---Read user input---
    mov ecx, user_number
    mov edx, 2
    call .read_input 
    ;---Random number generation---
    call .get_random_number
    add eax, '0'    
    mov [bot_number], eax
    ;---Prepare result---    
    mov ecx, res_msg
    mov edx, res_msg_len
    call .print            
    mov ecx, bot_number
    mov edx, 1
    call .print       
    ;---Calculate winner---
    ; call .calculate_winner
    ;----------------------           
    jmp .exit    

.print:
    mov eax, 4
    mov ebx, 1 
    int 0x80
    ret 

.read_input:
   mov eax, 3 
   mov ebx, 0 
   int 0x80
   ret             
      
.exit:
    mov eax, 1 
    xor ebx, ebx
    int 0x80

.get_random_number:
    ;  ---Call sys_time and save time in milliseconds to eax ---    
    push ebx
    push ecx
    push edx  
    mov eax, 201
    xor edi, edi
    int 0x80  
    mov edx, eax 
    mov eax, 1000
    imul eax, edx
    ;---Get number from 1 (MinValue) to 3 (Maxvalue)---
    ;(Linear congruential method is used)
    xor edx, edx
    mov ebx, 127773
    div ebx
    push eax 
    mov eax, 16807 
    mul edx 
    pop edx 
    push eax 
    mov eax, 2836 
    mul edx 
    pop edx 
    sub edx, eax 
    mov eax, edx 
    xor edx, edx
    mov ebx, [maxValue]
    sub ebx, [minValue]
    inc ebx
    div ebx
    mov eax, edx
    add eax, [minValue]
    pop edx
    pop ecx
    pop ebx
    ret