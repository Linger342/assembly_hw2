DATASEG SEGMENT
	RES DB 3 DUP(0)
	PR DB 00H,'*',00H,'=', 2 DUP(2),' ','$' 		;结果，DUP(2):末尾俩字节_$
	LINE DB 0DH,0AH,'$'   			;换行，0D:回车，0A:换行
	IPP DW 0000H   				;IP
DATASEG ENDS

STACKSEG SEGMENT
	DB 30 DUP(0)
STACKSEG ENDS

CODESEG SEGMENT
	ASSUME CS:CODESEG,DS:DATASEG,SS:STACKSEG
START: 	MOV AX,DATASEG
 	MOV DS,AX
 	MOV CX,0009H				;CX=0009，CL=09H
;行(1-9)循环
L1: 	MOV DH,0AH				
 	SUB DH,CL  				;DH：最大列，DH=1?
 	MOV DL,01H  				;DL存储当前列数
 	MOV AL,DH
 	AND AX,00FFH
;列(1-9)循环
L2: 	CMP DL,DH				;循环直至DL>DH
 	JA NEXT					;大于后跳转NEXT
 	PUSH DX  				;列数
 	PUSH CX  				;行数
 	PUSH AX  				;被乘数
 	PUSH DX  				;乘数
 	MOV AL,DH
 	MUL DL
 	PUSH AX  				;结果
 	CALL NUM				;引用函数NUM，见下
 	POP CX  					;行数
 	POP DX  					;列数
 	INC DL					;横向延展L2重复
 	JMP L2 					;L2再次循环
NEXT: 	MOV DX,OFFSET LINE
 	MOV AH,09H
 	INT 21H 
 	LOOP L1					;L1循环
 	MOV AH,4CH				;程序结束
 	INT 21H

NUM PROC
	POP IPP 					;主函数地址
	POP DX 					;结果
	MOV AX,DX				;放进AX
	MOV BL,0AH				;转十进制
	DIV BL
	ADD AX,3030H				;两字节转十进制显示
	MOV PR+4,AL
	MOV PR+5,AH
	POP AX  					;乘数
	AND AL,0FH				;?
	ADD AL,30H
	MOV PR+2,AL
	POP AX  					;被乘数
	AND AL,0FH				;?
	ADD AL,30H
	MOV PR,AL
;输出
	MOV DX,OFFSET PR			;显示PR串，偏移PR
	MOV AH,09H
	INT 21H
	PUSH IPP
	RET  
NUM ENDP

CODESEG ENDS
END START
