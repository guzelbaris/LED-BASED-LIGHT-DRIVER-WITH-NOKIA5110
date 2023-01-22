;LABEL			DIRECTIVE	VALUE		COMMENT

PIN_RESET  		EQU 		0x40004200		
SSI0_DR_R   	EQU 		0x40008008	
SSI0_SR_R  	 	EQU 		0x4000800C
DC          	EQU 		0x40004100

;LABEL		DIRECTIVE	VALUE		COMMENT
				AREA    	main   , READONLY, CODE		
				THUMB                   ; Subsequent instructions are Thumb
				EXPORT  	first_config_Nokia	; Make available
				EXTERN 		dly_100m	

first_config_Nokia	PROC
	
				PUSH {LR}
				LDR R1, =DC
				LDR R0, [R1]
				MOV R0, #0 ; 
				STR R0, [R1]
				
				LDR R1, =PIN_RESET	;To initialize the Nokia screen first toggle the Reset 
									;pin by holding it low for 100ms then setting it high.
				LDR R0, [R1]
				MOV R0, #0 ; 
				STR R0, [R1]
				
				BL	dly_100m
				BL	dly_100m
				
				LDR R1, =PIN_RESET
				LDR R0, [R1]
				MOV R0, #0x80 ;
				STR R0, [R1]
				
waiting_for_1			LDR R1, =SSI0_SR_R
				LDR R0, [R1]
				ANDS R0, #0x00000010 ;SSI Busy Bit
				BNE waiting_for_1				
				
				LDR R1, =SSI0_DR_R
				LDR R0, [R1]
				MOV R0, #0x21 ;chip active; horizontal addressing mode (V = 0); use extended instruction set (H = 1)
				STR R0, [R1]
				
waiting_for_2			LDR R1, =SSI0_SR_R
				LDR R0, [R1]
				ANDS R0, #0x00000010 ;SSI Busy Bit
				BNE waiting_for_2				
				
								
				LDR R1, =SSI0_DR_R
				LDR R0, [R1]
				MOV R0, #0xBF		; 0xBF due to our screen is too dark
				STR R0, [R1]
				
waiting_for_3			LDR R1, =SSI0_SR_R
				LDR R0, [R1]
				ANDS R0, #0x00000010 ;SSI Busy Bit
				BNE waiting_for_3				
				
								
				LDR R1, =SSI0_DR_R
				LDR R0, [R1]
				MOV R0, #0x04 ;set temp coefficient
				STR R0, [R1]
				
waiting_for_4			LDR R1, =SSI0_SR_R
				LDR R0, [R1]
				ANDS R0, #0x00000010 ;SSI Busy Bit
				BNE waiting_for_4				
				
								
				LDR R1, =SSI0_DR_R
				LDR R0, [R1]
				MOV R0, #0x14 ;LCD bias mode 1:48: try 0x13 or 0x14
				STR R0, [R1]
				
waiting_for_5			LDR R1, =SSI0_SR_R
				LDR R0, [R1]
				ANDS R0, #0x00000010 ;SSI Busy Bit
				BNE waiting_for_5				
				
								
				LDR R1, =SSI0_DR_R
				LDR R0, [R1]
				MOV R0, #0x20 ;we must send 0x20 before modifying the display control mode
				STR R0, [R1]
				
waiting_for_6			LDR R1, =SSI0_SR_R
				LDR R0, [R1]
				ANDS R0, #0x00000010 ;SSI Busy Bit
				BNE waiting_for_6				
				
								
				LDR R1, =SSI0_DR_R
				LDR R0, [R1]
				MOV R0, #0x0C ; set display control to normal mode: 0x0D for inverse
				STR R0, [R1]
				
waiting_for_7			LDR R1, =SSI0_SR_R
				LDR R0, [R1]
				ANDS R0, #0x00000010 ;SSI Busy Bit
				BNE waiting_for_7

				POP{LR}
				ENDP
				BX			LR					
				ALIGN
				END