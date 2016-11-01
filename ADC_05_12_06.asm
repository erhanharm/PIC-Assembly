
;___________________________________________________________
	ADC'nin 1. kanal�ndan gelen anlaog �aretin (0-5V) 
1.2 V lt s�n�r 3.6 �st s�n�r kabul edilecek �ekilde �l��m�n� 
yap�p,alt s�n�r�n alt�nda ise Port  D'nin 4 numaral� pinine
ba�l� olan sar� ledi, �st s�n�r�n �zerinde ise Port D'nin 5 
numaral� pinine ba�l� olan k�rm�z� ledin, s�n�rlar aras�nda 
ise hi�bir ledin yanmamas�n� sa�layan assembly kodunu yaz�n�z.
;___________________________________________________________

DEFINITIONS:
	PTD		EQU	$0003
	DDRD		EQU	$0007
	CONFIG1		EQU	$001F
	ADSCR		EQU 	$003C
	ADCLK		EQU	$003E
	ADR		EQU	$003D


	ORG	$0040		;RAM b�lgesine git

	ALT	DS	1	;ALT diye 1 byte lik bir alan ay�r
	UST	DS	1	;UST diye 1 byte l�k bir alan ay�r

	ORG	$8000		;ROM b�lgesine git

INITIALIZE:

	MOV	#$31,CONFIG1	;DENETLEY�C� ���N GEREKL� AYARLAMALAR
	MOV	#$30,DDRD	;�IKI� VE G�R��LER TANIMLANDI
	CLR 	PTD		;PORT D'nin TAMAMI TEM�ZLEND�, SIFIRLANDI
	MOV	#$21,ADSCR	;ADC0,AIEN,COCO ve kanal se�im bitleri i�in gerekli atamalar yap�ld�. 
	MOV	#$70,ADCLK	;ADC d�n,���m s�resi internal bus clock se�ildi ve 8'e b�l�nd�.

	CLRA			;ADC'nin bu ayarlamalar� yapmas� ve i�lemi
	DBNZA	*		;ba�latmas� i�in bellirli bir s�re beklenir.

	MOV	#$B4,UST	;�st s�n�r de�eri belirlendi
	MOV	#$3C,ALT	;alt s�n�r de�eri belirlendi

MAIN:
	LDA	ADR		;ADC'den okunan bilgi �zerinde i�lem yapmak i�in A'ya aktar�ld�.
	CMPA	UST		;A'daki de�er ile UST de�eri kar��la�t�r
	BHS	OVER		;e�er e�it ve b�y�k ise OVER'a dallan.
	CMP	ALT		;A'daki de�er ile ALT de�eri kar��la�t�r
	BHI	MID		;e�er de�er b�y�k ise UNDER'a dallan.
	BRA	UNDER		;her ne ko�lda olursun MAIN'e dallan.

OVER:
	MOV	#$20,PTD	;k�rm�z� ledi yak, sar� ledi s�nd�r.
	BRA	MAIN		;MAIN'e git

MID:
	MOV	#$00,PTD	;k�rm�z� ve sar� ledi s�nd�r
	BRA	MAIN		;MAIN'e git

UNDER:	
	MOV	#$10,PTD	;sar� ledi ya, k�rm�z� ledi s�nd�r.
	BRA	MAIN		;MAIN'e git
