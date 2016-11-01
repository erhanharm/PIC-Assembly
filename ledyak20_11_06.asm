;PORT A NIN 2 NUMARALI PININE BAGLI BULUNAN BUTONA BASILDIGINDA PORTD NIN 5 PININE BAGLI BULUNAN 
;LEDI YAKAN PROGRAMIN KODU


	PTA		EQU	$0000	
	DDRA		EQU	$0004
	PTD		EQU	$0003
	DDRD		EQU	$0007
	CONFIG1		EQU	$001F
	PTAPUE		EQU	$000D
	ROMSTART	EQU	$8000

	ORG	$8000 ;ROMSTART

	MOV	#$31,CONFIG1
	MOV	#$FB,DDRA 		;  ==>1111,1101  (0= giriş, 1= çıkış)
	MOV	#$04,PTAPUE		; PORTA PULL-UP modülünü aç

LBL1:
	BCLR	5,PTD			;PORTD nin 5. biti O yap(LED SÖNER)
	BRSET	2,PTA,LBL1		;PORTA nınn 2. biti 1 ise burda kal ( 1 ise butona basılmıyordur Active-low )
	
LBL:	
	BSET	5,PTD			;PORTD nin 5. bitini 1 yap (LED YANAR)
	BRCLR	2,PTA,LBL		;PORTA nın 2. biti 0 olduğu sürece burda kal (elimizi butona bastıkça burda kalır)
	BRA	LBL1			;Herzaman LBL1 e dallan. Burayı işlemek için butondan elimizi çekmek lazım ;)
		
