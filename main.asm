;Main.s by Westin & Denver 
;02/22/2019
;I2C - Lab 7
			INCLUDE 'derivative.inc'
			XDEF _Startup, main
			XREF __SEG_END_SSTACK	;symbol defined by the linker for the end ss

	ORG $0090	;other start of memory
addr DS.B 16	;declare space for address
	ORG $E000	;start of memory


main:
_Startup:
            LDA SOPT1	;disable watchdog
            AND #$7F	
            STA SOPT1

			BSET 7, PTBDD	;clock (LED2)
			BSET 6, PTBDD	;data (LED1)
			
			CLR $75 ;clears mem
			CLR $76 ;clears mem
			CLR $77 ;clears mem
			CLR $78	;clears data mem
			CLR $79 ;clears mem
			CLR $80 ;clears mem
			CLR $81 ;clears mem
mainLoop:
			BSET 7, PTBD	;clock (LED2)
			BSET 6, PTBD	;data (LED1)
			MOV #251, $75   ;set delay counter1
			MOV #254, $76   ;set delay counter2
			MOV #8, $77 ;clock cycle counter
			MOV #10, $78 ; set clock cycles 
			MOV #0, $79  ; set counter to 0
			MOV #0, $80  ; set counter to 0 
			MOV #8, $81  ; set counter to 8
			MOV #%10010100, addr ;declare address 		
send:
			JSR delay
			JSR startBit	;send start bit

			JSR clkloop  ;start clock
			JSR dataLoop ;send data
			JSR stopBit	 ;send stop bit
			JSR delay
sleep:
			;JSR delay	;sleeps after 9 cycles	
			;JMP sleep	;sleep loop
			BRA mainLoop
clkloop:	
			BCLR 7, PTBD	;pull clock low 
			LDA addr	;load address to acumulator
			ROLA	;rotate address data
			STA addr ;save back to memory
			BCC sendLow	;call sendLow
			BCS sendHigh	;call sendHigh
clkDelay:
			JSR delay	;delay
			BSET 7, PTBD	;pull clock line high 
			JSR delay
			LDA $77	;clock counter
			DECA ;decrament 
			STA $77	;save clock couter
			BNE clkloop
			MOV #8, $77  ;reset 
			BCLR 7, PTBD ;pull clock low 
			JSR setupDelay   ;delay
			BCLR 6, PTBD ; pull data line low
			
			JSR ack  ;send handshake
			
			RTS		
sendLow:
			BCLR 6, PTBD	;pull data line low
			BRA clkDelay 
sendHigh:		
			BSET 6, PTBD	;pull data line high
			BRA clkDelay 
setupDelay:
			LDA $76 ;load into the accumlator from 0x76
			ADC #1  ;count up by 1
			STA $76 ;store from the accumlator into 0x76
			BCC setupDelay	;branches through delay as long as there is no carry
		
			MOV #254, $76 ;reset memory to zero in location 0x76
			RTS
delay:
			LDA $75 ;load into the accumlator from 0x75
			ADC #1  ;count up by 1
			STA $75 ;store from the accumlator into 0x75
			BCC delay	;branches through delay as long as there is no carry
			
			MOV #251, $75 ;reset memory to zero in location 0x75
			RTS
startBit:
			BCLR 6, PTBD	;pull data line low 
			JSR setupDelay	;delay
			BCLR 7, PTBD	;pull clock low
			RTS
stopBit:
			BCLR 6, PTBD	;pull data line low 
			BSET 7, PTBD	;pull clock high
			BSET 6, PTBD	;pull clock high
			JSR setupDelay
			RTS
dataLoop:
			BCLR 7, PTBD	;pull clock low
			LDA $79	;load address to acumulator
			ROLA	;rotate address data
			STA $79
			BCC sendDataLow	;call sendDataLow
			BCS sendDataHigh
dataDelay:			
			JSR delay	;delay
			BSET 7, PTBD	;pull clock line high 
			JSR delay
			LDA $81	;clock counter
			DECA
			STA $81	;save clock couter
			BNE dataLoop
			BCLR 7, PTBD ;pull clock low
			JSR delay
			MOV #8, $81 ;clock cycle counter
			
			JSR ack ;send handshake
			LDA $80 ;load 
			INCA ;incrament counter
			
			STA $80 ;save counter 
			STA $79 ;then save counter again
			JSR delay
			
			LDA $78	;clock counter
			DECA ;decrament 
			STA $78  ;save counter 
			BNE dataLoop
			BCLR 6, PTBD ;pull data low 
			MOV #10, $78 ;reset counter
			MOV #0, $79  ;reset counter
			MOV #0, $80  ;reset counter
			MOV #8, $81  reset counter
			
			RTS
			
sendDataLow:
			BCLR 6, PTBD	;pull data line low
			BRA dataDelay 
sendDataHigh:		
			BSET 6, PTBD	;pull data line high
			BRA dataDelay
ack:	;Handshake 
			BCLR 6, PTBD ;pull data low 
			JSR setupDelay
			BSET 7, PTBD	;pull clock line high 
			JSR delay
					
			BCLR 7, PTBD ;pull clock low
			JSR delay
			RTS






