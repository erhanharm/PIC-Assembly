
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
;_______CGM-INIT-FREKANS ARTIRMA MODÜLÜ____________________________________________________

cgm_init:
  BCLR	5,PCTL
  MOV #$00,PCTL      ;P=0 E=0
  MOV #$00,PMSH      ;N=F5
  MOV #$F5,PMSL      ;N=F5
  MOV #$D1,PMRS      ;L=D1
  MOV #$01,PMDS      ;R=1 YAPILARAK 2MHz SEÇÝLDÝ.
  BSET 5,PCTL        ;PLL ALTÝF EDÝLDÝ.
  BSET 7,PBWC
  BRCLR 6,PBWC,*     ;PLL STABÝLÝTESÝNÝ SAÐLAYANA KADAR BEKLE
  BSET 4,PCTL        ;AYARLANAN PLL'Ý BUS'A AKTAR.
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

        BRCLR   2,PTA,ARTI               ;PORTA'NI 2 NOLU PÝNÝNDEKÝ BUTONA BASILDIÐINDA 'ARTI'YA DALLAN
        BRCLR   3,PTA,EKSI               ;PORTA'NI 3 NOLU PÝNÝNDEKÝ BUTONA BASILDIÐINDA 'EKSÝ'YE DALLAN
        bra     main_loop                ;HER KOÞUL ALTINDA LOOP'A DALLAN
ARTI:
        BRCLR   2,PTA,*                 ;PORTA'NI 2 NOLU PÝNÝNDEKÝ BUTONA HALA BASILI ÝSE BURADA BEKLE, DEÐÝÞMÝÞ ÝSE ALTA GEÇ
        INC     SET                     ;SET DEÐERÝNÝ BÝR ARTTIR
        bra     main_loop               ;ANA DÖNGÜYE GERÝ DÖN
EKSI:
        BRCLR   3,PTA,*                 ;PORTA'NI 3 NOLU PÝNÝNDEKÝ BUTONA HALA BASILI ÝSE BURADA BEKLE, DEÐÝÞMÝÞ ÝSE ALTA GEÇ
        DEC     SET                     ;SET DEÐERÝNÝ BÝR AZALT
        bra     main_loop

;- MAIN -------------------------------------------------------------------------------------

;- TIMER_ISR --------------------------------------------------------------------------------
; timer_isr: happens approx twice per second and complements states of both LEDs
timer_isr:
        psha
        LDA     DURUM           ;A'NI ÝÇERÝSÝNE DURUM DEÐÝÞKENÝ ÝÇERÝSÝNDEKÝ DEÐER  ATANIR
        CMP     #$00            ;AKUMULATOR 00H DEÐERÝ ÝLE KARÞILAÞTIRILIR
        BNE     ATAMA           ;AKUMULATOR 00H'E EÞÝT OLAMADIÐI DURUMDA 'ATAMA' YA DALLAN
        MOV     SET,DURUM       ;AKUMULATOR 00H'E EÞÝT ÝSE SET'IN ÝÇERÝSÝNÝ DURUM ÝÇERÝSÝNE ATA
        BRA     CIKIS
ATAMA:
        DBNZ        DURUM,CIKIS
        LDA         PTD         ;PORTD'NIN BÝLGÝSÝNÝ AKUMULATOR ÝÇERÝSÝNE AL.
        EOR         #$FF        ;AKUMULATOR'U FFH ÝLE EXOR ÝÞLEMÝNE SOK.
        STA         PTD         ;AKUMULATOR ÝÇERÝSÝNDEKÝ DEÐERÝ PORTD'YE ATA
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
