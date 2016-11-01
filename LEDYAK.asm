PTA     EQU     $0000
DDRA    EQU     $0004
PTD     EQU     $0003
DDRD    EQU     $0007
CONFIG1 EQU     $001F		;her zaman aynı config1 dosyamız
PTAPUE  EQU     $000D   	;Port A nın PULL-UP device ının registeri
ROMSTART EQU     $8000		;Rom Bölgesini gösterdik
VectorStart  EQU  $FFDC		;Vektör bölgesini gösterdik

        ORG     ROMSTART	;Burdan yazmaya başka

MAIN:
        MOV     #$31,CONFIG1	;config1 içerisine değeri koy
        MOV     #$00,DDRA	;DDRA ya 00 yaparak giriş yaptık 0= giriş, 1= çıkış
        MOV     #$FF,DDRD	;DDRD ye FF koyarak çıkış yağtık 
        MOV     #$02,PTAPUE	;PortA nın 3. pininin PULL-UP device'ını açtık

LBL1:
     BCLR       1,PTD		;Önce söndür
     BRSET      2,PTA,LBL1	;PORTA nın 2. biti 1 olduğu sürece LB1 e git

LBL:
     BSET       1,PTD		;Önce yak	
     BRCLR      2,PTA,LBL	;PORTA nın 2. biti 0 olduğu sürece LBL e git
     BRA        LBL1		;herzaman LB1 e git
dummy_isr:
          rti			;stack e bu durumu aktar
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
        dw  MAIN         ; Reset Vector
;- INTERRUPT TABLE --------------------------------------------------------------------------
