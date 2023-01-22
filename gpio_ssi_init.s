;*************************************************************** 
; EQU Directives
; These directives do not allocate memory
;***************************************************************
;LABEL		     DIRECTIVE	VALUE				COMMENT	
;PORT A GPIO ADDRESSS
PORTA_DIR      	EQU 		0x40004400			; PORT A Direction Address
PORTA_AFSEL    	EQU 		0x40004420  		; PORT A Alt Function Enable Address
PORTA_DEN     	EQU 		0x4000451C  		; PORT A Digital Enable Address
PORTA_AMSEL    	EQU 		0x40004528  		; PORT A Analog Enable Address
PORTA_PCTL     	EQU 		0x4000452C  		; PORT A Alternate Functions Address
SYSCTL_RCGC2_R 	EQU 		0x400FE108  		; PORT A Clock
														;
;ADDRESS FOR SPI CONFIGURATION	                		;
SYSCTL_RCGC1_R 	EQU 		0x400FE104			; SSI0 Clock
SSI0_CR0_R     	EQU 		0x40008000  		; Control 1 to enable
SSI0_CR1_R     	EQU 		0x40008004  		; Control 0 to set
SSI0_CC_R      	EQU 		0x40008FC8  		; Clock configuration
SSI0_CPSR_R    	EQU 		0x40008010  		; Clock prescale
			

;LABEL			DIRECTIVE	VALUE				COMMENT
				AREA    	main   , READONLY, CODE		
				THUMB                   		; Subsequent instructions are Thumb
				EXPORT  	gpio_ssi_init			; Make available


gpio_ssi_init	PROC	

;;;;;;;;;;;;;;;;;; GPIO INITIALIZATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;; CLOCK INITIALIZATON ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
			
				LDR 		R1, =SYSCTL_RCGC2_R ; Open Clock for GPIO
				LDR 		R0, [R1]
				ORR 		R0, R0, #0x01 		; For Port A write 0x01
				STR 		R0, [R1]
				
				NOP 							; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
;;;;;;;;;;;;;;;;;; CLOCK INITIALIZATON END ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
			
			
				LDR 		R1, =PORTA_DIR		; Direction Register for Port A
				LDR 		R0, [R1]
				ORR 		R0, R0, #0xC0 		; PA5, PA6, and PA7 Direction 
				STR 		R0, [R1]
					
				LDR 		R1, =PORTA_AFSEL	; Alt Function Address
				LDR 		R0, [R1]
				ORR 		R0, R0, #0x2C 		; For PA2, PA3, PA5 Enable Alt Function 
				BIC 		R0, R0, #0xC0	    ; For PA6, PA7 Disable Alt Function
				STR 		R0, [R1]
				
				LDR 		R1, =PORTA_DEN		; Digital Enable Address For Port A
				LDR 		R0, [R1]
				ORR 		R0, R0, #0xEC 		; For PA2, PA3, PA5, PA6, and PA7 Enable Digital I/O
				STR 		R0, [R1]
				
				LDR 		R1, =PORTA_PCTL		; Alternate Functions Address
				LDR 		R0, [R1]
				BIC 		R0, R0, #0x00000F00 ; Choose PA2 as SSI
				ORR 		R0, R0, #0x00000200	
				BIC 		R0, R0, #0x0000F000 ; Choose PA3 as SSI
				ORR 		R0, R0, #0x00002000	
				BIC 		R0, R0, #0x00F00000 ; Choose PA5 as SSI
				ORR 		R0, R0, #0x00200000				
				BIC 		R0, R0, #0x0F000000 ; Choose PA6 as GPIO
				BIC 		R0, R0, #0xF0000000 ; Choose PA7 as GPIO
				STR 		R0, [R1]
						
				LDR 		R1, =PORTA_AMSEL	; Analog Select Address
				LDR 		R0, [R1]
				BIC 		R0, R0, #0xEC 		; For PA2, PA3, PA5, PA6, and PA7 Disable Analog Function Mode
				STR 		R0, [R1]
			
;;;;;;;;;;;;;;;;;; GPIO INITIALIZATION END ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
					
;;;;;;;;;;;;;;;;;; SPI INITIALIZATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;; CLOCK INITIALIZATON ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
				LDR 		R1, =SYSCTL_RCGC1_R ; Open Clock for SSI
				LDR 		R0, [R1]
				ORR 		R0, R0, #0x00000010 ; Open SSI for 
				STR 		R0, [R1]
				
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
				NOP								; Stabilazition for Clock
												
;;;;;;;;;;;;;;;;;; CLOCK INITIALIZATON END ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

				LDR 		R1, =SSI0_CR1_R     ; Direction Register for SSI
				LDR 		R0, [R1]
				BIC 		R0, R0, #0x00000002 ; Initially Close The SSI For Setup
				STR 		R0, [R1]
				BIC 		R0, R0, #0x00000004 ; Open Master Mode 
				STR 		R0, [R1]
					
				LDR 		R1, =SSI0_CC_R		; Configuration for SSI Clock Setup
				LDR 		R0, [R1]
				BIC 		R0, R0, #0x0000000F		
				STR 		R0, [R1]
				
			
				LDR 		R1, =SSI0_CPSR_R	; Clock Configuration since Setup		
				LDR 		R0, [R1]			; Clock division for 3.33 MHz 
				BIC 		R0, R0, #0x0000000F ; SysClk/(CPSDVSR*(1+SCR))
				BIC 		R0, R0, #0x000000F0 ; 80/(24*(1+0)) = 3.33 MHz (slower than 4 MHz)
				ORR 		R0, R0, #24 ;
				STR 		R0, [R1]
				
				
							
				LDR 		R1, =SSI0_CR0_R
				LDR 		R0, [R1]
				BIC 		R0, R0, #0x00000F00 ;
				BIC 		R0, R0, #0x0000F000 ; SSI Serial Clock Rate
				BIC 		R0, R0, #0x00000080 ; SSI Serial Clock Phase	
				BIC 		R0, R0, #0x00000040 ; SSI Serial Clock Polarity
				BIC 		R0, R0, #0x00000030 ; SSI Frame Format Select
				BIC 		R0, R0, #0x0000000F ; SSI Data Size Select
				ORR 		R0, R0, #0x00000007 ; // 8-bit data
				STR 		R0, [R1]
						
				LDR 		R1, =SSI0_CR1_R
				LDR 		R0, [R1]
				ORR 		R0, R0, #0x00000002 ; Enable SSI After Setup Complete
				STR 		R0, [R1]
							
				
				
				
				
				ENDP
				BX			LR					
				ALIGN
				END
				