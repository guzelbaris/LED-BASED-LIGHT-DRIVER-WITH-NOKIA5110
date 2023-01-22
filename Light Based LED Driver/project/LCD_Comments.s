;LABEL			DIRECTIVE	VALUE			COMMENT	
	
PIN_RESET   	EQU 		0x40004200		
SSI0_DR_R   	EQU 		0x40008008	
SSI0_SR_R   	EQU 		0x4000800C
DC          	EQU 		0x40004100
	
;LABEL			DIRECTIVE	VALUE		COMMENT
				AREA    	main   , READONLY, CODE		
				THUMB                   	; Subsequent instructions are Thumb
				EXPORT		LCD_Comments
				EXPORT		SSi_Checker
				EXPORT		ssi_data_check
				EXPORT  	Screen_Clear
				EXPORT  	dly_100m
				EXPORT		delay_1000m
				EXPORT		X_Cursor
				EXPORT		Y_Cursor		
				EXPORT		initial_screen
				EXPORT		zero_0
				EXPORT		one_1
				EXPORT		two_2
				EXPORT		three_3
				EXPORT		four_4
				EXPORT		five_5
				EXPORT		six_6
				EXPORT		seven_7
				EXPORT		eight_8
				EXPORT		nine_9
				EXPORT		step_1
				EXPORT		step_2
				EXPORT		step_3
				EXPORT		step_4
				EXPORT		C_RED
				EXPORT		C_GREEN
				EXPORT		C_BLUE
				EXPORT		data_write
			
	
				
LCD_Comments	PROC
	
SSi_Checker		PROC		;WAIT IF THE SSI IS BUSY
				PUSH {LR}
				PUSH {R0-R1}
ssi_command		LDR R1, =SSI0_SR_R
				LDR R0, [R1]
				ANDS R0, #0x00000010 ;SSI Busy Bit
				BNE ssi_command
				POP {R0-R1}
				POP{LR}
				
				ENDP
				BX	LR
		
ssi_data_check		PROC ;WAIT SSI BEFORE SENDING DATA
				PUSH {LR}
				PUSH {R0-R1}				
ssi_data			LDR R1, =SSI0_SR_R		
				LDR R0, [R1]
				ANDS R0, #0x00000002 
				BEQ ssi_data					
				POP {R0-R1}
				POP{LR}
				ENDP
				BX	LR	
				LTORG
	
Screen_Clear		PROC			;CLEAR ALL SCREEN
				PUSH {LR}
				PUSH {R0-R2}
				LDR R1, =DC				;data
				LDR R0, [R1]
				MOV R0, #0x40 ; 
				STR R0, [R1]							
				MOV R2, #518
		
loopClear		BL ssi_data_check	
				MOV R5, #0x00	; SEND 0X00 518 TIMES
				BL data_write
				SUBS R2,#1				
				BNE loopClear
				POP {R0-R2}
				POP{LR}
				ENDP
				BX	LR	
				LTORG
				
dly_100m		PROC
				PUSH {LR}
				PUSH {R0}
				
				LDR 		R0, =250; Counter value
counter			SUBS		R0,#1
				BNE			counter
		
				POP			{R0}
				POP			{LR}
				BX			LR
				ENDP
				LTORG
			
delay_1000m		PROC
				PUSH {LR}
				PUSH {R0}
				
				LDR 		R0, =250000; Counter value
counter_2		SUBS		R0,#1
				BNE			counter_2
		
				POP			{R0}
				POP			{LR}
				BX			LR
				ENDP
				LTORG	

X_Cursor		PROC			;ADJUST SET CURSORX
	
				PUSH {LR}	
				PUSH {R0-R4}
				LDR R1, =DC			;command 
				LDR R0, [R1]
				MOV R0, #0 ; 
				STR R0, [R1]				
				BL SSi_Checker				
				LDR R1, =SSI0_DR_R				
				MOV R3,  #0x80			
				ORR R0, R3,R4
				STR R0, [R1]						
				BL SSi_Checker				
				LDR R1, =DC				;data
				LDR R0, [R1]
				MOV R0, #0x40 ; 
				STR R0, [R1]
				POP {R0-R4}
				POP{LR}
				ENDP
				BX	LR
				LTORG

Y_Cursor		PROC		;ADJUST SET CURSORX
	
				PUSH {LR}	
				PUSH {R0-R4}
				LDR R1, =DC			;command 
				LDR R0, [R1]
				MOV R0, #0 ; 
				STR R0, [R1]				
				BL SSi_Checker				
				LDR R1, =SSI0_DR_R				
				MOV R3,  #0x40
				ORR R0, R3,R4
				STR R0, [R1]						
				BL SSi_Checker				
				LDR R1, =DC				;data
				LDR R0, [R1]
				MOV R0, #0x40 ; 
				STR R0, [R1]
				POP	{R0-R4}
				POP{LR}
				ENDP
				BX	LR
				LTORG

initial_screen	PROC
				PUSH {LR}
				PUSH {R0-R12}
			
				BL delay_1000m
				MOV R4, #0
				BL X_Cursor			
				MOV R4, #1
				BL dly_100m
				BL Y_Cursor
				BL delay_1000m
				; T 
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7f
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; - 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; M 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; I 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7F
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; N 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x3f
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; : 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x14
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				
				BL delay_1000m
				MOV R4, #0
				BL X_Cursor			
				MOV R4, #2
				BL dly_100m
				BL Y_Cursor
				BL delay_1000m
				; T 
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7f
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				; - 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; M 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; A 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x09
				BL data_write
				MOV 	R5, #0x09
				BL data_write
				MOV 	R5, #0x09
				BL data_write
				MOV 	R5, #0x09
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; X 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x63
				BL data_write
				MOV 	R5, #0x14
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x14
				BL data_write
				MOV 	R5, #0x63
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; : 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x14
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				BL delay_1000m
				MOV R4, #0
				BL X_Cursor			
				MOV R4, #3
				BL dly_100m
				BL Y_Cursor
				BL delay_1000m	
				
				; L 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3f
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; U 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3f
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x3f
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; M 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; I 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7F
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; N 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x3f
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; : 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x14
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				BL delay_1000m
				MOV R4, #0
				BL X_Cursor			
				MOV R4, #4
				BL dly_100m
				BL Y_Cursor
				BL delay_1000m	
				
				; L 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3f
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; I 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7F
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; G 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x79
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; H 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7f
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x08
				BL data_write
				MOV 	R5, #0x7f
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; T 
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7f
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write

				; : 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x14
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write


			POP {R0-R12}
			POP {LR}	
			ENDP
			BX	LR
				
zero_0			PROC			;{0x00, 0x3e, 0x61, 0x51, 0x49, 0x45, 0x43, 0x3e}
				PUSH {LR}
				PUSH {R5}
	
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x61
				BL data_write
				MOV 	R5, #0x51
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x45
				BL data_write
				MOV 	R5, #0x43
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				POP {R5}
				POP{LR}
				ENDP
				BX	LR			
					
one_1				PROC		;   {0x00, 0x00, 0x01, 0x01, 0x7e, 0x00, 0x00, 0x00}	
				PUSH {LR}
				PUSH {R5}
							
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00	
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write


				POP {R5}
				POP{LR}
				ENDP
				BX	LR				
			
			
			
two_2				PROC			;{0x00, 0x71, 0x49, 0x49, 0x49, 0x49, 0x49, 0x46}
				PUSH {LR}
				PUSH {R5}
				
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x71
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x46
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				POP {R5}
				POP{LR}
				ENDP
				BX	LR
				
				
three_3			PROC			; {0x41, 0x49, 0x49, 0x49, 0x49, 0x49, 0x36, 0x00}
				PUSH {LR}
				PUSH {R5}
				
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x36
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				POP {R5}
				POP{LR}
				ENDP
				BX	LR
				
				
				
				
four_4			PROC		;{0x00, 0x0f, 0x10, 0x10, 0x10, 0x10, 0x10, 0x7f}	
				PUSH {LR}
				PUSH {R5}
				
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x0f
				BL data_write
				MOV 	R5, #0x10
				BL data_write
				MOV 	R5, #0x10
				BL data_write
				MOV 	R5, #0x10
				BL data_write
				MOV 	R5, #0x10
				BL data_write
				MOV 	R5, #0x10
				BL data_write
				MOV 	R5, #0x7f
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				POP {R5}
				POP{LR}
				ENDP
				BX	LR


five_5			PROC			;{0x00, 0x4f, 0x49, 0x49, 0x49, 0x49, 0x49, 0x31}
				PUSH {LR}
				PUSH {R5}
				
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x4f
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x31
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				POP {R5}
				POP{LR}
				ENDP
				BX	LR
				
				
				
				
six_6				PROC		;{0x00, 0x3e, 0x49, 0x49, 0x49, 0x49, 0x49, 0x30}	
				PUSH {LR}
				PUSH {R5}
				
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x30
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				POP {R5}
				POP{LR}
				ENDP
				BX	LR




seven_7			PROC			;{0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x7e, 0x00}
				PUSH {LR}
				PUSH {R5}
				
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				POP {R5}
				POP{LR}
				ENDP
				BX	LR
				
				
				
				
eight_8			PROC			;{0x00, 0x36, 0x49, 0x49, 0x49, 0x49, 0x49, 0x36}
				PUSH {LR}
				PUSH {R5}
					
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x36
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x36
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				POP {R5}
				POP{LR}
				ENDP
				BX	LR


nine_9			PROC			; {0x00, 0x06, 0x49, 0x49, 0x49, 0x49, 0x49, 0x3e}
				PUSH {LR}
				PUSH {R5}
			
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x06
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				POP {R5}
				POP{LR}
				ENDP
				BX	LR
				
				
C_RED			PROC			
				PUSH {LR}
				PUSH {R5}
				
				;R {0x00, 0x7e, 0x01, 0x31, 0x49, 0x49, 0x49, 0x46}

				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x31
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x46
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				;E {0x00, 0x3e, 0x49, 0x49, 0x49, 0x49, 0x49, 0x41}
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				;D {0x00, 0x7f, 0x41, 0x41, 0x41, 0x41, 0x41, 0x3e}
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7f
				BL data_write
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				POP {R5}
				POP{LR}
				ENDP
				BX	LR
				
C_GREEN			PROC			
				PUSH {LR}
				PUSH {R5}
			
				;G {0x00, 0x3e, 0x41, 0x49, 0x49, 0x49, 0x49, 0x79}
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x79
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				;R {0x00, 0x7e, 0x01, 0x31, 0x49, 0x49, 0x49, 0x46}
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x31
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x46
				BL data_write
				MOV 	R5, #0x00
				BL data_write
						
				;N {0x00, 0x7e, 0x01, 0x01, 0x3e, 0x40, 0x40, 0x3f}
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7e
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x01
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x3f
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				
				POP {R5}
				POP{LR}
				ENDP
				BX	LR
				
C_BLUE			PROC			
				PUSH {LR}
				PUSH {R5}
			
				;B {0x00, 0x7f, 0x41, 0x49, 0x49, 0x49, 0x49, 0x36}
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x7f
				BL data_write
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x36
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				; L 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3f
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				; U 
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3f
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x40
				BL data_write
				MOV 	R5, #0x3f
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				;E {0x00, 0x3e, 0x49, 0x49, 0x49, 0x49, 0x49, 0x41}
				MOV 	R5, #0x00
				BL data_write
				MOV 	R5, #0x3e
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x49
				BL data_write
				MOV 	R5, #0x41
				BL data_write
				MOV 	R5, #0x00
				BL data_write
				
				
				POP {R5}
				POP{LR}
				ENDP
				BX	LR

step_1			PROC			
				PUSH {LR}
				PUSH {R4}
			
				BL delay_1000m
				MOV R4, #48
				BL X_Cursor			
				MOV R4, #1
				BL Y_Cursor
				BL delay_1000m
				POP {R4}
				POP{LR}
				ENDP
				BX	LR
				
step_2			PROC			
				PUSH {LR}
				PUSH {R4}
			
				BL delay_1000m
				MOV R4, #48
				BL X_Cursor			
				MOV R4, #2
				BL Y_Cursor
				BL delay_1000m
				POP {R4}
				POP{LR}
				ENDP
				BX	LR
				
step_3			PROC			
				PUSH {LR}
				PUSH {R4}
			
				BL delay_1000m
				MOV R4, #48
				BL X_Cursor			
				MOV R4, #3
				BL Y_Cursor
				BL delay_1000m
				POP {R4}
				POP{LR}
				ENDP
				BX	LR
				
step_4			PROC			
				PUSH {LR}
				PUSH {R4}
			
				BL delay_1000m
				MOV R4, #48
				BL X_Cursor			
				MOV R4, #4
				BL Y_Cursor
				BL delay_1000m
				POP {R4}
				POP{LR}
				ENDP
				BX	LR		

data_write			PROC			;SEND DATA TO data_write
				PUSH {LR}		
				PUSH {R0-R5}		
				LDR R1, =DC				;data
				LDR R0, [R1]
				MOV R0, #0x40 ; 
				STR R0, [R1]

				BL ssi_data_check
				LDR R1, =SSI0_DR_R					
				STR R5, [R1]
		
				BL ssi_data_check			
			
				POP {R0-R5}
				POP{LR}
				 
				BX	LR	

EXIT			POP {R0-R12}
				POP{LR}
				ENDP
				BX	LR

				ALIGN
				END