; --- Datos PIC ---
list	P=16F628A
#include	<P16F628A.INC>
	
; --- Fusibles de Configuracion ---
 __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _MCLRE_OFF & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

; --- Declaraciones ---
COUNTER1	equ	0x20
COUNTER2	equ	0x26
D1	equ	0x21
D2	equ	0x22
D3	equ	0x23
D4	equ	0x24
V	equ	0x25
S	equ	0x27
I	equ	0x28
X	equ 0x29

#define	MYLF	0x26
#define	INT	0

; --- Programa ---
Reset	org	0x00
	goto	Inicio
	org	0x04
	goto	IntSP
	org	0x05

Inicio	bsf	STATUS,RP0
;	bsf	PCON,OSCF	; Oscilador Interno funcione a 4MHz.
	movlw	0x20
	movwf	TRISA
	movlw	0x00
	movwf	TRISB
 	bcf	STATUS,RP0
	movlw	0x07	; Comparadores Apagados. 
	movwf	CMCON

	movlw	0x30	; Preescalador
	movwf	T1CON
	movlw	0x0B	; 0xF4
	movwf	TMR1H
	movlw	0xE2	; 0x24
	movwf	TMR1L
	bsf	T1CON,TMR1ON
	
	bsf	STATUS,RP0
	bsf	PIE1,TMR1IE
	bsf	INTCON,PEIE
	bsf	INTCON,GIE
	bcf	STATUS,RP0

	bsf		PORTA,4
    
    movlw	0xFF
	movwf	COUNTER2
    movlw	0xFF
	movwf	COUNTER1
	decf	COUNTER1,1
	btfss	STATUS,Z
	goto	$-2
	decf	COUNTER2
	btfss	STATUS,Z
	goto	$-7
	
	bcf		PORTA,4
	bsf	STATUS,RP0
	movlw	0x30
	movwf	TRISA
	bcf STATUS,RP0

	clrf	D1
	clrf	D2
	clrf	D3
	clrf	D4
	clrf	S
	clrf	X
	clrf	I

Programa	btfsc	PORTA,4
	goto	$+5
	btfsc	PORTA,5
	goto	$+7
	call Mostrar
	goto Programa
	btfss	PORTA,4
	goto	$+7
	call	Mostrar
	goto	$-3
	btfss	PORTA,5
	goto	$+5
	call	Mostrar
	goto	$-3
	call	IncHs
	goto Programa
	call	IncMs
	goto	Programa

Mostrar	movfw	D1
	call	Tabla
	btfsc	S,0
	addlw	0x80
	movwf	PORTB
	bsf	PORTA,0
	call	Retardo
	bcf	PORTA,0

	movfw	D2
	call	Tabla
	btfsc	S,0
	addlw	0x80
	movwf	PORTB
	bsf	PORTA,1
	call	Retardo
	bcf	PORTA,1

	movfw	D3
	call	Tabla
	btfsc	S,0
	addlw	0x80
	movwf	PORTB
	bsf	PORTA,2
	call	Retardo
	bcf	PORTA,2

	movfw	D4
	call	Tabla
	btfsc	S,0
	addlw	0x80
	movwf	PORTB
	bsf	PORTA,3
	call	Retardo
	bcf	PORTA,3

	return

IntSP	btfss	PIR1,TMR1IF
	retfie
	bcf	PIR1,TMR1IF

	movwf	V
	movlw	0x0B	;0x0F
	movwf	TMR1H
	movlw	0xE2	;0xF0
	movwf	TMR1L

	incf	I
	movfw	I
	xorlw	.2
	btfss	STATUS,Z
	goto	EndIntSP
	clrf	I

	incf	S
	movfw	S
	xorlw	.60
	btfss	STATUS,Z
	goto	EndIntSP
	clrf	S

IncMs	incf	D4
	movfw	D4
	xorlw	.10
	btfss	STATUS,Z
	goto	EndIntSP
	clrf	D4

	incf	D3
	movfw	D3
	xorlw	.6
	btfss	STATUS,Z
	goto	EndIntSP
	clrf	D3

IncHs	incf	D2
	btfsc	D1,1
	goto	$+7
	movfw	D2
	xorlw	.10
	btfss	STATUS,Z
	goto	EndIntSP
	clrf	D2
	goto	$+6
	movfw	D2
	xorlw	.4
	btfss	STATUS,Z
	goto	EndIntSP
	clrf	D2

	incf	D1
	movfw	D1
	xorlw	.3
	btfss	STATUS,Z
	goto	EndIntSP
	clrf	D1

EndIntSP	movfw	V
	retfie

Tabla	addwf	PCL,f	; dp, g, f, e, d, c, b, a
	retlw	b'00111111'	; 0
	retlw	b'00000110'	; 1	
	retlw	b'01011011'	; 2	
	retlw	b'01001111'	; 3	
	retlw	b'01100110'	; 4	
	retlw	b'01101101'	; 5
	retlw	b'01111101'	; 6	
	retlw	b'00000111'	; 7	
	retlw	b'01111111'	; 8
	retlw	b'01101111'	; 9	
	retlw	b'01110111'	; A	
	retlw	b'01111100'	; B	
	retlw	b'00111001'	; C	
	retlw	b'01011110'	; D	
	retlw	b'01111001'	; E	
	retlw	b'01110001'	; F

TablaI	addwf	PCL,f	; dp, g, f, e, d, c, b, a
	retlw	b'11000000'	; 0
	retlw	b'11111001'	; 1	
	retlw	b'10100100'	; 2	
	retlw	b'10110000'	; 3	
	retlw	b'10011001'	; 4	
	retlw	b'10010010'	; 5
	retlw	b'10000010'	; 6	
	retlw	b'11111000'	; 7	
	retlw	b'10000000'	; 8
	retlw	b'10010000'	; 9	
	retlw	b'10001000'	; A	
	retlw	b'10000011'	; B	
	retlw	b'11000110'	; C	
	retlw	b'10100001'	; D	
	retlw	b'10000110'	; E	
	retlw	b'10001110'	; F

Retardo
    movlw	0x04
	movwf	COUNTER2
    movlw	0xFF
	movwf	COUNTER1
	decf	COUNTER1,1
	btfss	STATUS,Z
	goto	$-2
	decf	COUNTER2
	btfss	STATUS,Z
	goto	$-7
	retfie

	end
