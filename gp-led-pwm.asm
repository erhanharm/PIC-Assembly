; *******************************************************************
;   GP-LED-PWM.ASM
;
;  Program acts as digitally controlled LED dimmer. Demonstrates
;   PWM cappabilites of TIM module.
;  TIMer is initialized to generate PWM waveforms 256 ticks long
;   (TMOD=255). Dimming is controlled by duty cycle setting (TCH).
;   TIMer runs in buffered PWM mode in case of correct PWM
;   controll in very high duty cycles. Care on synchronnous PWM
;   register update is TIMer's job and program don't need to update
;   in critical moment only.
;  PWM runs infinitely and main program loop controlls pushbuttons
;   acquiring and duty cycle control. While there's no delay or
;   any timing routine here, pushbuttons are checked very often and
;   PWM value updated very often too. Due to this there's an
;   prescaler implemented here. Pushbuttons (via software) affect
;   "lsbyte" and overflows/underflows affect PWM constant. It
;   drops system sensitivity to 1/256.
;  No interrupts used here, program runs completely in polling mode.
; *******************************************************************
; 5.3.2001 v2.0
; simulator - ok
; devbrd - ok

RAMStart     EQU  $0040
RomStart     EQU  $E000
VectorStart  EQU  $FFDC

$Include 'gpregs.inc'

        org     RamStart

internal_error  ds      1       ; internal errors counter
lsbyte  ds      1               ; PWM duty cycle is controlled by pushbuttons
                                ; and this register is used as "prescaler" due button scan is very fast

        org     RomStart

; - GPIO_INIT ------------------------------------------------------------------------------
; all-gpios initialization - type: input, state: log.1
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
        mov     #0,DDRB
        mov     #$30,DDRD
        mov     #0,DDRE
        mov     #$0C,PTAPUE
        mov     #$00,PTCPUE
        mov     #$00,PTDPUE
        rts
;- GPIO_INIT --------------------------------------------------------------------------------

;- TIMER_INIT -------------------------------------------------------------------------------
; timer_init: initializes timer to buffered pwm application
timer_init:
        mov     #$34,T1SC        ; Stop & reset, overflow interrupt disable, prescaler=
        mov     #$2A,T1SC0       ; Buffered PWM operation, toggle on overflow, clear on compare
        mov     #$00,T1MODH      ; Modulo count = 255
        mov     #$FF,T1MODL
        clr     T1CH0H           ; Prepare first PWM value into T1CH0 register. Buffered value
        mov     #$FE,T1CH0L      ; will be copied here in next cycle
        mov     #$00,T1CH1H      ; Initialize PWM at minimum level (duty 1:254)
        mov     #$FE,T1CH1L      ; Due to buffered PWM op (see pg. 355 of user manual) is
                                 ; value written to secondary channels registers
        bclr    4,T1SC           ; Un-reset TIMer
        bclr    5,T1SC           ; Enable timer operation
        rts
;- TIMER_INIT -------------------------------------------------------------------------------

;- MAIN -------------------------------------------------------------------------------------
; Everything begins here
Main:
        rsp                     ; stack pointer reset
        clra                    ; register init
        clrx
        sta     internal_error  ; clear internal errors counter
        mov     #$80,lsbyte
        mov     #$31,CONFIG1    ; MCU runs w/o LVI and COP support
        bsr     gpio_init       ; GPIO initialization
        bsr     timer_init      ; TIM initialization
main_loop:
        brclr   2,PTA,main_pwmdown ; note: pwmup means advance pwm constant, but
        brclr   3,PTA,main_pwmup ;  bigger T1CH number causes lower LED light
        bra     main_loop       ; runs infinitely until both buttons pressed
main_pwmup:
        lda     lsbyte          ; user would like to boost light
        add     #$1             ; instead of inc use add w/ flags update
        sta     lsbyte
        bcc     main_loop
        lda     T1CH1L          ; lsbyte overfull, check and update T1CH1L
        inca
        cmpa    #$FF            ; don't go up to 255 ($FF), or pwm will fail
        blo     main_pwmup_ok   ; when under limit, overskip next two decs
        dec     lsbyte          ; take lsbyte back to 255
        deca                    ; return T1CH1L back
main_pwmup_ok:
        sta     T1CH1L          ; save updated value
        bra     main_loop
main_pwmdown:
        brclr   3,PTA,main_monitor
        lda     lsbyte          ; user would like to boost light
        sub     #$1             ; instead of dec use sub w/ flags update
        sta     lsbyte
        bcc     main_loop
        lda     T1CH1L          ; lsbyte overfull, check and update T1CH1L
        deca
        tsta                    ; don't go under zero :-)
        bne     main_pwmup_ok   ; when under limit, overskip next two incs
        inc     lsbyte          ; take lsbyte back to 0
        inca                    ; return T1CH1L back
        bra     main_pwmup_ok
main_monitor:
        swi                     ; both switches activated cause jump to monitor
        bra     main_loop

;- MAIN -------------------------------------------------------------------------------------

;- DUMMY_ISR --------------------------------------------------------------------------------
; Dummy interrupt handler - these interrupt requests will normaly never be activated, but..

dummy_isr:
       inc      internal_error
       rti
;- DUMMY_ISR --------------------------------------------------------------------------------

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
        dw  main         ; Reset Vector
;- INTERRUPT TABLE --------------------------------------------------------------------------
