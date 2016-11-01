
RAMStart     EQU  $0040
RomStart     EQU  $E000
VectorStart  EQU  $FFDC

$Include 'gpregs.inc'

        org     RamStart

internal_error  ds      1       ; internal errors counter
durum           ds      1
set             ds      1

        org     RomStart

; - GPIO_INIT ------------------------------------------------------------------------------
; except: PTD4,5 - LED are outputs, PTA2,3 - pushbuttons - pullups on
gpio_init:
        lda     #$FF
        sta     PTA
        sta     PTB
        sta     PTC
        sta     PTD
        sta     PTE
        mov     #0,DDRA
        mov     #0,DDRB
        mov     #0,DDRC
        mov     #$10,DDRD
        mov     #0,DDRE
        mov     #$0C,PTAPUE
        mov     #$00,PTCPUE
        mov     #$00,PTDPUE
        rts
;- GPIO_INIT --------------------------------------------------------------------------------

;- TIMER_INIT -------------------------------------------------------------------------------
; timer_init: initializes timer to free run, no o.c., no i.c., leaves timer stopped
timer_init:
        mov     #$73,T1SC        ; Stop & reset, overflow interrupt enable, prescaler=8
        clr     T1SC0            ; Inhibit all capture/compare functions
        clr     T1SC1
        mov     #$F4,T1MODH      
        mov     #$23,T1MODL
        bclr    4,T1SC           ; Un-reset TIMer
        rts
;- TIMER_INIT -------------------------------------------------------------------------------
;_______CGM-INIT-FREKANS ARTIRMA MOD�L�____________________________________________________

cgm_init:
  BCLR	5,PCTL
  MOV #$00,PCTL      ;P=0 E=0
  MOV #$00,PMSH      ;N=F5
  MOV #$F5,PMSL      ;N=F5
  MOV #$D1,PMRS      ;L=D1
  MOV #$01,PMDS      ;R=1 YAPILARAK 2MHz SE��LD�.
  BSET 5,PCTL        ;PLL ALT�F ED�LD�.
  BSET 7,PBWC
  BRCLR 6,PBWC,*     ;PLL STAB�L�TES�N� SA�LAYANA KADAR BEKLE
  BSET 4,PCTL        ;AYARLANAN PLL'� BUS'A AKTAR.
  RTS

;- MAIN -------------------------------------------------------------------------------------
Main:
        rsp                     ; stack pointer reset
        clra                    ; register init
        clrx
        sta     internal_error  ; clear internal errors counter
        sta     durum
        sta     set
        mov     #$31,CONFIG1    ; MCU runs w/o LVI and COP support
        bsr     gpio_init       ; GPIO initialization
        bsr     cgm_init	; CGM initialization
        bsr     timer_init      ; TIM initialization
        cli
        bclr    5,T1SC           ; start timer

main_loop:

        BRCLR   2,PTA,ARTI               ;PORTA'NI 2 NOLU P�N�NDEK� BUTONA BASILDI�INDA 'ARTI'YA DALLAN
        BRCLR   3,PTA,EKSI               ;PORTA'NI 3 NOLU P�N�NDEK� BUTONA BASILDI�INDA 'EKS�'YE DALLAN
        bra     main_loop                ;HER KO�UL ALTINDA LOOP'A DALLAN
ARTI:
        BRCLR   2,PTA,*                 ;PORTA'NI 2 NOLU P�N�NDEK� BUTONA HALA BASILI �SE BURADA BEKLE, DE���M�� �SE ALTA GE�
        INC     SET                     ;SET DE�ER�N� B�R ARTTIR
        bra     main_loop               ;ANA D�NG�YE GER� D�N
EKSI:
        BRCLR   3,PTA,*                 ;PORTA'NI 3 NOLU P�N�NDEK� BUTONA HALA BASILI �SE BURADA BEKLE, DE���M�� �SE ALTA GE�
        DEC     SET                     ;SET DE�ER�N� B�R AZALT
        bra     main_loop

;- MAIN -------------------------------------------------------------------------------------

;- TIMER_ISR --------------------------------------------------------------------------------
; timer_isr: happens approx twice per second and complements states of both LEDs
timer_isr:
        psha
        LDA     DURUM           ;A'NI ��ER�S�NE DURUM DE���KEN� ��ER�S�NDEK� DE�ER  ATANIR
        CMP     #$00            ;AKUMULATOR 00H DE�ER� �LE KAR�ILA�TIRILIR
        BNE     ATAMA           ;AKUMULATOR 00H'E E��T OLAMADI�I DURUMDA 'ATAMA' YA DALLAN
        MOV     SET,DURUM       ;AKUMULATOR 00H'E E��T �SE SET'IN ��ER�S�N� DURUM ��ER�S�NE ATA
        BRA     CIKIS
ATAMA:
        DBNZ        DURUM,CIKIS
        LDA         PTD         ;PORTD'NIN B�LG�S�N� AKUMULATOR ��ER�S�NE AL.
        EOR         #$FF        ;AKUMULATOR'U FFH �LE EXOR ��LEM�NE SOK.
        STA         PTD         ;AKUMULATOR ��ER�S�NDEK� DE�ER� PORTD'YE ATA
CIKIS   pula
        bclr    7,T1SC           ; clear TOF in TSC - handler is finishing
        rti
;- TIMER_ISR --------------------------------------------------------------------------------

;- DUMMY_ISR --------------------------------------------------------------------------------
; Dummy interrupt handler - these interrupt requests will normaly never be activated, but..

dummy_isr:
       inc      internal_error
       rti
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
        dw  timer_isr    ; TIM1 Overflow Vector
        dw  dummy_isr    ; TIM1 Channel 1 Vector
        dw  dummy_isr    ; TIM1 Channel 0 Vector
        dw  dummy_isr    ; PLL Vector
        dw  dummy_isr    ; ~IRQ1 Vector
        dw  dummy_isr    ; SWI Vector
        dw  main         ; Reset Vector
;- INTERRUPT TABLE --------------------------------------------------------------------------
