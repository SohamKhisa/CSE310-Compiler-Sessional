.MODEL SMALL 
.STACK 100H 

.DATA

rt	DW	?
a1	DW	?
a2	DW	?
b2	DW	?
x2	DW	?
a3	DW	?
b3	DW	?
t0	DW	?
t1	DW	?
t2	DW	?
t3	DW	?

.CODE

PRINT PROC 
PUSHA 
MOV BX, AX 
CMP BX, 0 
JE CORNER 
JNL SKIP 
MOV AH, 2 
MOV DL, '-' 
INT 21H 
NEG BX 
SKIP: 
MOV CX, 0 
MOV AX, BX 
VAG: 
CMP AX, 0 
JE END_VAG 
MOV DX, 0 
MOV BX, 10 
IDIV BX 
PUSH DX 
INC CX 
JMP VAG 
END_VAG: 
OUTPUT: 
POP DX 
ADD DX, '0' 
MOV AH, 2 
INT 21H 
LOOP OUTPUT 
JMP DONE 
CORNER: 
MOV DX, '0' 
MOV AH, 2 
INT 21H 
DONE: 
MOV AH, 2 
MOV DL, ' ' ;0DH 
INT 21H 
;MOV DL, 0AH 
;INT 21H 
POPA 
RET 
PRINT ENDP 

f0 PROC 
PUSHA
MOV t0, 2	; new temp
MOV AX, t0
IMUL a1
MOV t1, AX	; new temp
MOV AX, t1
MOV rt, AX 
JMP done_f
MOV t0, 9	; new temp
MOV AX, t0
MOV a1, AX
MOV t1, AX	; new temp
done_f:
POPA
RET
f0 ENDP

g0 PROC 
PUSHA
PUSH a2
PUSH b2
PUSH x2
MOV AX, a2
MOV a1, AX
CALL f0
POP x2
POP b2
POP a2
MOV AX, rt
MOV t0, AX	; new temp
MOV AX, t0
ADD AX, a2
MOV t1, AX	; new temp
MOV AX, t1
ADD AX, b2
MOV t2, AX	; new temp
MOV AX, t2
MOV x2, AX
MOV t3, AX	; new temp
MOV AX, x2
MOV rt, AX 
JMP done_g
done_g:
POPA
RET
g0 ENDP

MAIN PROC
MOV AX, @DATA
MOV DS, AX
MOV t0, 1	; new temp
MOV AX, t0
MOV a3, AX
MOV t1, AX	; new temp
MOV t0, 2	; new temp
MOV AX, t0
MOV b3, AX
MOV t1, AX	; new temp
PUSH a3
PUSH b3
MOV AX, a3
MOV a2, AX
MOV AX, b3
MOV b2, AX
CALL g0
POP b3
POP a3
MOV AX, rt
MOV t0, AX	; new temp
MOV AX, t0
MOV a3, AX
MOV t1, AX	; new temp
MOV AX, a3
CALL PRINT
MOV t0, 0	; new temp
MOV AX, t0
MOV rt, AX 
JMP done_main
done_main:
MOV AH, 4CH 
INT 21H
MAIN ENDP 

END MAIN


