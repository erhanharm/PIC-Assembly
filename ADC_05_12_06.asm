
;___________________________________________________________
	ADC'nin 1. kanalýndan gelen anlaog þaretin (0-5V) 
1.2 V lt sýnýr 3.6 üst sýnýr kabul edilecek þekilde ölçümünü 
yapýp,alt sýnýrýn altýnda ise Port  D'nin 4 numaralý pinine
baðlý olan sarý ledi, üst sýnýrýn üzerinde ise Port D'nin 5 
numaralý pinine baðlý olan kýrmýzý ledin, sýnýrlar arasýnda 
ise hiçbir ledin yanmamasýný saðlayan assembly kodunu yazýnýz.
;___________________________________________________________

DEFINITIONS:
	PTD		EQU	$0003
	DDRD		EQU	$0007
	CONFIG1		EQU	$001F
	ADSCR		EQU 	$003C
	ADCLK		EQU	$003E
	ADR		EQU	$003D


	ORG	$0040		;RAM bölgesine git

	ALT	DS	1	;ALT diye 1 byte lik bir alan ayýr
	UST	DS	1	;UST diye 1 byte lýk bir alan ayýr

	ORG	$8000		;ROM bölgesine git

INITIALIZE:

	MOV	#$31,CONFIG1	;DENETLEYÝCÝ ÝÇÝN GEREKLÝ AYARLAMALAR
	MOV	#$30,DDRD	;ÇIKIÞ VE GÝRÝÞLER TANIMLANDI
	CLR 	PTD		;PORT D'nin TAMAMI TEMÝZLENDÝ, SIFIRLANDI
	MOV	#$21,ADSCR	;ADC0,AIEN,COCO ve kanal seçim bitleri için gerekli atamalar yapýldý. 
	MOV	#$70,ADCLK	;ADC dön,üþüm süresi internal bus clock seçildi ve 8'e bölündü.

	CLRA			;ADC'nin bu ayarlamalarý yapmasý ve iþlemi
	DBNZA	*		;baþlatmasý için bellirli bir süre beklenir.

	MOV	#$B4,UST	;Üst sýnýr deðeri belirlendi
	MOV	#$3C,ALT	;alt sýnýr deðeri belirlendi

MAIN:
	LDA	ADR		;ADC'den okunan bilgi üzerinde iþlem yapmak için A'ya aktarýldý.
	CMPA	UST		;A'daki deðer ile UST deðeri karþýlaþtýr
	BHS	OVER		;eðer eþit ve büyük ise OVER'a dallan.
	CMP	ALT		;A'daki deðer ile ALT deðeri karþýlaþtýr
	BHI	MID		;eðer deðer büyük ise UNDER'a dallan.
	BRA	UNDER		;her ne koþlda olursun MAIN'e dallan.

OVER:
	MOV	#$20,PTD	;kýrmýzý ledi yak, sarý ledi söndür.
	BRA	MAIN		;MAIN'e git

MID:
	MOV	#$00,PTD	;kýrmýzý ve sarý ledi söndür
	BRA	MAIN		;MAIN'e git

UNDER:	
	MOV	#$10,PTD	;sarý ledi ya, kýrmýzý ledi söndür.
	BRA	MAIN		;MAIN'e git
