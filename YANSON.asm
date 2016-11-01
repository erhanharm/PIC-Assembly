;GİRİŞ ÇIKIŞ TANIMLAMALARI YAPILIYOR	
PTD     EQU     $0003
DDRD    EQU     $0007
TBCR    EQU     $001C
CONFIG1 EQU     $001F
PCTL    EQU     $0036
PBWC    EQU     $0037
PMSH    EQU     $0038
PMSL    EQU     $0039
PMRS    EQU     $003A
PMDS    EQU     $003B
ROMSTART EQU     $8000
VECTORSTART  EQU  $FFDC

        ORG     ROMSTART

INITIALIZE:
        MOV     #$31,CONFIG1		;config1 değeri konuldu
        BCLR    5,PCTL			;PLL kontrol registerinin 5. biti 0 yapıldı. PLL OFF konumuna getirildi
        MOV     #$00,PCTL		;PCTL nin bütün bitlerini 0 yap
        MOV     #$01,PCTL		;PCTL nin ilk bitini 1 yaparak VPR0 =1 yapıldı son durum VPR0=1 VPR1=0 VPR2=0 Durum: E sayısı
        MOV     #$01,PMSH		;PMSH ilk biti 1 yapıldı. N sayısının yüksek biti
        MOV     #$2C,PMSL		;PMSH ilk biti 1 yapıldı. N sayısının düşük biti
        MOV     #$80,PMRS		;PMRS L sayısı konuldu
        MOV     #$01,PMDS 		;PMDS R sayısı konuldu (hep  1 )
					;Frekans 2.4576 MHz seçilmiş oldu.
        BSET    5,PCTL			;PLL aktif et	
        BSET    7,PBWC			;PLL bandwith kontrol registerini otomatik yaptık
        BRCLR   6,PBWC,* 		;6. bit 1 oluncaya kadar burda kal Frekans tamalanınca aşağıya in
	BSET    4,PCTL			;AYARLANAN VCO CLOCK'u ASIL KULLANILAN GERÇEK CLOCK OLARAK ŞEÇ.

MAIN:

        MOV     #$10,DDRD		;DDRD nin 5. bitini çıkış yap
        MOV     #$08,TBCR		;TIMEBASE kontrol bitine 0000,1000 konuldu(250 ms seçildi)
        BSET    1,TBCR			;Time base açıldı

LABEL:
        BRCLR   7,TBCR,LABEL		;TBCRnin 7. bitine bak 250 ms dolmadığı sürece burda kal
        				;250 ms geçti
	LDA     PTD			;PTD nin içindeki değeri AKÜye yükle
        EOR     #$FF			;AKÜ'nin içindekinin tersini al (bit-bit)
        STA     PTD			;AKÜnün içindekini PTD ye yükle
        BSET    3,TBCR			;TIMEBASE bayrağını indir (ki tekrar saysın)
        BRA     LABEL			;LABEL üzerinde dallan 

dummy_isr:
          rti				;stack'e bu kısmı yükle 
;- INTERRUPT VECTOR TABLE -------------------------------------------------------------------
        org  VectorStart
        dw  dummy_isr    ; Time Base Vector
        dw  dummy_isr    ; ADC Conversion Complete
        dw  dummy_isr    ; Keyboard Vector
        dw  dummy_isr    ; SCI Transmit Vector
        dw  dummy_isr    ; SCI Receive Vector
        dw  dummy_isr    ; SCI Error Vector
        dw  dummy_isr    ; SPI Transmit Vector
        dw  dummy_isr    ; SPI Receive Vector
        dw  dummy_isr    ; TIM2 Overflow Vector
        dw  dummy_isr    ; TIM2 Channel 1 Vector
        dw  dummy_isr    ; TIM2 Channel 0 Vector
        dw  dummy_isr    ; TIM1 Overflow Vector
        dw  dummy_isr    ; TIM1 Channel 1 Vector
        dw  dummy_isr    ; TIM1 Channel 0 Vector
        dw  dummy_isr    ; PLL Vector
        dw  dummy_isr    ; ~IRQ1 Vector
        dw  dummy_isr    ; SWI Vector
        dw  INITIALIZE   ; Reset Vector	;reset gelirse bir şekilde INITIALIZE kısmına dön
;- INTERRUPT TABLE --------------------------------------------------------------------------
