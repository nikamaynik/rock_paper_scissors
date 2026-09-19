; Rock, Paper, Scissors.
; A simple game on 32-bit Linux NASM Assembly.

section .data
    ; ---ui/ux---
    welcome0 db "__-->_Rock,_Paper,_Scissors_game_<--__", 10
    welcome0_len equ $ - welcome0
    welcome1 db "Welcome User", 10
    welcome1_len equ $ - welcome1 
    query0 db "Choose a number: 1 (Rock), 2 (Paper), 3 (Scissors): ", 10
    query0_len equ $ - query0
    query1 db "Do you want to continue? (y/n): "
    query1_len equ $ - query1
    res_msg db "The computer chose ", 0 
    res_msg_len equ $ - res_msg 
    user_winner db "You win.", 0
    user_winner_len equ $ - user_winner    
    bot_winner db "You loose.", 0
    bot_winner_len equ $ - bot_winner
    draw db "It's a draw." 
    draw_len equ $ - draw
    rock db " (Rock)", 10
    rock_len equ $ - rock
    paper db " (Paper)", 10 
    paper_len equ $ - paper 
    scissors db " (Scissors)", 10 
    scissors_len equ $ - scissors      
    newline db 0xA, 0
    dividingline db "---------------------------------------", 10 
    dividingline_len equ $ - dividingline     

    ;---Random num generation vars--- 
    minValue dd 1
    maxValue dd 3 
    
section .bss
    user_number resb 2
    bot_number resb 2
    continue resb 2
    
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
    mov ecx, query0
    mov edx, query0_len
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
    call .print_bot_choice    
    mov ecx, dividingline
    mov edx, dividingline_len
    call .print    
    ;---Calculate winner---
    call .calculate_winner
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
   ;---Continue calculation or exit---
    mov ecx, newline
    mov edx, 1 
    call .print   
    mov ecx, query1 
    mov edx, query1_len
    call .print 
    mov ecx, continue
    mov edx, 2
    call .read_input
  
    mov al, byte [continue]
    cmp al, 'y'
    je .restart
    
    mov eax, 1 
    xor ebx, ebx
    int 0x80

.print_bot_choice:
    cmp byte [bot_number], '1'
    je .@1
    cmp byte [bot_number], '2'
    je .@2 
    cmp byte [bot_number], '3'
    je .@3 
    ret    
       
.@1:
    mov ecx, rock 
    mov edx, rock_len 
    call .print 
    ret           

.@2:
    mov ecx, paper 
    mov edx, paper_len  
    call .print 
    ret 

.@3:
    mov ecx, scissors 
    mov edx, scissors_len  
    call .print 
    ret                                 

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

.calculate_winner:
    mov al, byte [user_number]
    mov bl, byte [bot_number]      
    cmp al, bl
    je .draw
    cmp al, '2'
    je .check_2
    cmp al, '1'
    je .check_1       
    cmp al, '3' 
    je .check_3
     
.check_2:
    cmp al, bl 
    jg .user_win 
    jl .bot_win
    jmp .exit

.check_1:
    cmp bl, '2'
    je .bot_win
    cmp bl, '3'
    je .user_win 
    jmp .exit          
    
.check_3:
    cmp bl, '2' 
    je .user_win 
    cmp bl, '1' 
    je .bot_win 
    jmp .exit              

.draw:
    mov ecx, draw 
    mov edx, draw_len
    call .print
    jmp .exit

.user_win:
    mov ecx, user_winner
    mov edx, user_winner_len
    call .print
    jmp .exit

.bot_win:
    mov ecx, bot_winner 
    mov edx, bot_winner_len 
    call .print
    jmp .exit

.restart:
    mov ecx, newline
    mov edx, 1 
    call .print 
    jmp _start                                 