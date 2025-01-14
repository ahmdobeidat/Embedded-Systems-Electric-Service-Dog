
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;PIC2.c,18 :: 		void interrupt(void) {
;PIC2.c,19 :: 		if (INTCON & 0x04) { // Timer0 overflow interrupt
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt0
;PIC2.c,20 :: 		TMR0 = 248; // Reload Timer0
	MOVLW      248
	MOVWF      TMR0+0
;PIC2.c,21 :: 		Dcntr++;
	INCF       _Dcntr+0, 1
	BTFSC      STATUS+0, 2
	INCF       _Dcntr+1, 1
;PIC2.c,22 :: 		if (Dcntr == 500) { // After 500 ms
	MOVF       _Dcntr+1, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt26
	MOVLW      244
	XORWF      _Dcntr+0, 0
L__interrupt26:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt1
;PIC2.c,23 :: 		Dcntr = 0;
	CLRF       _Dcntr+0
	CLRF       _Dcntr+1
;PIC2.c,24 :: 		read_sonar();
	CALL       _read_sonar+0
;PIC2.c,25 :: 		}
L_interrupt1:
;PIC2.c,26 :: 		INTCON &= 0xFB; // Clear T0IF
	MOVLW      251
	ANDWF      INTCON+0, 1
;PIC2.c,27 :: 		}
L_interrupt0:
;PIC2.c,29 :: 		if (Distance < 23) {
	MOVLW      0
	SUBWF      _Distance+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt27
	MOVLW      0
	SUBWF      _Distance+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt27
	MOVLW      0
	SUBWF      _Distance+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt27
	MOVLW      23
	SUBWF      _Distance+0, 0
L__interrupt27:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt2
;PIC2.c,30 :: 		PORTD |= 0x08; // RD3 ON
	BSF        PORTD+0, 3
;PIC2.c,31 :: 		PORTB |= 0x08; // RB3 ON
	BSF        PORTB+0, 3
;PIC2.c,32 :: 		} else {
	GOTO       L_interrupt3
L_interrupt2:
;PIC2.c,33 :: 		PORTD &= ~0x08; // RD3 OFF
	BCF        PORTD+0, 3
;PIC2.c,34 :: 		PORTB &= ~0x08; // RB3 OFF
	BCF        PORTB+0, 3
;PIC2.c,35 :: 		}
L_interrupt3:
;PIC2.c,37 :: 		if (PIR1 & 0x04) { // CCP1 interrupt
	BTFSS      PIR1+0, 2
	GOTO       L_interrupt4
;PIC2.c,38 :: 		PIR1 &= 0xFB; // Clear CCP1 interrupt flag
	MOVLW      251
	ANDWF      PIR1+0, 1
;PIC2.c,39 :: 		}
L_interrupt4:
;PIC2.c,41 :: 		if (PIR1 & 0x01) { // Timer1 overflow interrupt
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt5
;PIC2.c,42 :: 		T1overflow++;
	INCF       _T1overflow+0, 1
	BTFSC      STATUS+0, 2
	INCF       _T1overflow+1, 1
;PIC2.c,43 :: 		PIR1 &= 0xFE; // Clear Timer1 overflow flag
	MOVLW      254
	ANDWF      PIR1+0, 1
;PIC2.c,44 :: 		}
L_interrupt5:
;PIC2.c,46 :: 		if (INTCON & 0x02) { // External Interrupt
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt6
;PIC2.c,47 :: 		INTCON &= 0xFD; // Clear External Interrupt flag
	MOVLW      253
	ANDWF      INTCON+0, 1
;PIC2.c,48 :: 		}
L_interrupt6:
;PIC2.c,49 :: 		}
L_end_interrupt:
L__interrupt25:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_pwm_compare_mode_init:

;PIC2.c,51 :: 		void pwm_compare_mode_init(void) {
;PIC2.c,52 :: 		TRISC &= ~0x04;   // Set RC2 (CCP1) as output
	BCF        TRISC+0, 2
;PIC2.c,53 :: 		CCP1CON = 0x08;   // Set CCP1 in Compare Mode
	MOVLW      8
	MOVWF      CCP1CON+0
;PIC2.c,54 :: 		T1CON = 0x30;     // Timer1 with prescaler 1:8, OFF initially
	MOVLW      48
	MOVWF      T1CON+0
;PIC2.c,55 :: 		TMR1H = 0;        // Clear Timer1 High byte
	CLRF       TMR1H+0
;PIC2.c,56 :: 		TMR1L = 0;        // Clear Timer1 Low byte
	CLRF       TMR1L+0
;PIC2.c,57 :: 		}
L_end_pwm_compare_mode_init:
	RETURN
; end of _pwm_compare_mode_init

_set_servo_position1:

;PIC2.c,59 :: 		void set_servo_position1(int degrees) {
;PIC2.c,60 :: 		unsigned int pulse_width = (degrees + 90) * 8 + 500; // Calculate pulse width in microseconds
	MOVLW      90
	ADDWF      FARG_set_servo_position1_degrees+0, 0
	MOVWF      R3+0
	MOVF       FARG_set_servo_position1_degrees+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	MOVWF      R3+1
	MOVLW      3
	MOVWF      R2+0
	MOVF       R3+0, 0
	MOVWF      R0+0
	MOVF       R3+1, 0
	MOVWF      R0+1
	MOVF       R2+0, 0
L__set_servo_position130:
	BTFSC      STATUS+0, 2
	GOTO       L__set_servo_position131
	RLF        R0+0, 1
	RLF        R0+1, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__set_servo_position130
L__set_servo_position131:
	MOVLW      244
	ADDWF      R0+0, 0
	MOVWF      R2+0
	MOVF       R0+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDLW      1
	MOVWF      R2+1
	MOVF       R2+0, 0
	MOVWF      set_servo_position1_pulse_width_L0+0
	MOVF       R2+1, 0
	MOVWF      set_servo_position1_pulse_width_L0+1
;PIC2.c,61 :: 		unsigned int compare_value = (pulse_width * 2);      // Convert to Timer1 ticks (with prescaler 1:8)
	MOVF       R2+0, 0
	MOVWF      R4+0
	MOVF       R2+1, 0
	MOVWF      R4+1
	RLF        R4+0, 1
	RLF        R4+1, 1
	BCF        R4+0, 0
;PIC2.c,63 :: 		CCPR1H = (compare_value >> 8); // Set high byte of compare value
	MOVF       R4+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;PIC2.c,64 :: 		CCPR1L = (compare_value & 0xFF); // Set low byte of compare value
	MOVLW      255
	ANDWF      R4+0, 0
	MOVWF      CCPR1L+0
;PIC2.c,66 :: 		T1CON |= 0x01; // Start Timer1
	BSF        T1CON+0, 0
;PIC2.c,68 :: 		while (!(PIR1 & 0x04)); // Wait for CCP1 interrupt flag
L_set_servo_position17:
	BTFSC      PIR1+0, 2
	GOTO       L_set_servo_position18
	GOTO       L_set_servo_position17
L_set_servo_position18:
;PIC2.c,69 :: 		PIR1 &= 0xFB; // Clear CCP1 interrupt flag
	MOVLW      251
	ANDWF      PIR1+0, 1
;PIC2.c,71 :: 		PORTC |= 0x04; // Set RC2 high
	BSF        PORTC+0, 2
;PIC2.c,72 :: 		delay(pulse_width / 1000); // Wait for pulse duration (in milliseconds)
	MOVLW      232
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	MOVF       set_servo_position1_pulse_width_L0+0, 0
	MOVWF      R0+0
	MOVF       set_servo_position1_pulse_width_L0+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      FARG_delay+0
	MOVF       R0+1, 0
	MOVWF      FARG_delay+1
	CALL       _delay+0
;PIC2.c,73 :: 		PORTC &= ~0x04; // Set RC2 low
	BCF        PORTC+0, 2
;PIC2.c,74 :: 		}
L_end_set_servo_position1:
	RETURN
; end of _set_servo_position1

_delay:

;PIC2.c,76 :: 		void delay(unsigned int msCnt) {
;PIC2.c,78 :: 		for (ms = 0; ms < msCnt; ms++) {
	CLRF       R3+0
	CLRF       R3+1
L_delay9:
	MOVF       FARG_delay_msCnt+1, 0
	SUBWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__delay33
	MOVF       FARG_delay_msCnt+0, 0
	SUBWF      R3+0, 0
L__delay33:
	BTFSC      STATUS+0, 0
	GOTO       L_delay10
;PIC2.c,80 :: 		for (us = 0; us < 155; us++) {
	CLRF       R1+0
	CLRF       R1+1
L_delay12:
	MOVLW      0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__delay34
	MOVLW      155
	SUBWF      R1+0, 0
L__delay34:
	BTFSC      STATUS+0, 0
	GOTO       L_delay13
;PIC2.c,81 :: 		asm NOP;
	NOP
;PIC2.c,80 :: 		for (us = 0; us < 155; us++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;PIC2.c,82 :: 		}
	GOTO       L_delay12
L_delay13:
;PIC2.c,78 :: 		for (ms = 0; ms < msCnt; ms++) {
	INCF       R3+0, 1
	BTFSC      STATUS+0, 2
	INCF       R3+1, 1
;PIC2.c,83 :: 		}
	GOTO       L_delay9
L_delay10:
;PIC2.c,84 :: 		}
L_end_delay:
	RETURN
; end of _delay

_main:

;PIC2.c,86 :: 		void main() {
;PIC2.c,87 :: 		TRISD = 0x00; // Set PORTD as output
	CLRF       TRISD+0
;PIC2.c,88 :: 		TRISB = 0x02; // RB2 (Trigger) Output, RB1 (Echo) Input
	MOVLW      2
	MOVWF      TRISB+0
;PIC2.c,90 :: 		pwm_compare_mode_init();
	CALL       _pwm_compare_mode_init+0
;PIC2.c,91 :: 		init_sonar();
	CALL       _init_sonar+0
;PIC2.c,93 :: 		OPTION_REG = 0x87; // Timer0 prescaler setup
	MOVLW      135
	MOVWF      OPTION_REG+0
;PIC2.c,94 :: 		INTCON = 0xF0;     // Enable global, Timer0, Timer1, and peripheral interrupts
	MOVLW      240
	MOVWF      INTCON+0
;PIC2.c,96 :: 		while (1) {
L_main15:
;PIC2.c,97 :: 		set_servo_position1(-70);
	MOVLW      186
	MOVWF      FARG_set_servo_position1_degrees+0
	MOVLW      255
	MOVWF      FARG_set_servo_position1_degrees+1
	CALL       _set_servo_position1+0
;PIC2.c,98 :: 		delay(400);
	MOVLW      144
	MOVWF      FARG_delay_msCnt+0
	MOVLW      1
	MOVWF      FARG_delay_msCnt+1
	CALL       _delay+0
;PIC2.c,99 :: 		set_servo_position1(10);
	MOVLW      10
	MOVWF      FARG_set_servo_position1_degrees+0
	MOVLW      0
	MOVWF      FARG_set_servo_position1_degrees+1
	CALL       _set_servo_position1+0
;PIC2.c,100 :: 		delay(400);
	MOVLW      144
	MOVWF      FARG_delay_msCnt+0
	MOVLW      1
	MOVWF      FARG_delay_msCnt+1
	CALL       _delay+0
;PIC2.c,101 :: 		}
	GOTO       L_main15
;PIC2.c,102 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_read_sonar:

;PIC2.c,104 :: 		void read_sonar(void) {
;PIC2.c,105 :: 		T1overflow = 0;
	CLRF       _T1overflow+0
	CLRF       _T1overflow+1
;PIC2.c,106 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;PIC2.c,107 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;PIC2.c,109 :: 		PORTB |= 0x04; // Trigger ultrasonic sensor
	BSF        PORTB+0, 2
;PIC2.c,110 :: 		usDelay(10);
	MOVLW      10
	MOVWF      FARG_usDelay+0
	MOVLW      0
	MOVWF      FARG_usDelay+1
	CALL       _usDelay+0
;PIC2.c,111 :: 		PORTB &= ~0x04; // Stop trigger
	BCF        PORTB+0, 2
;PIC2.c,113 :: 		while (!(PORTB & 0x02)); // Wait for echo start
L_read_sonar17:
	BTFSC      PORTB+0, 1
	GOTO       L_read_sonar18
	GOTO       L_read_sonar17
L_read_sonar18:
;PIC2.c,114 :: 		T1CON = 0x19; // Timer1 ON
	MOVLW      25
	MOVWF      T1CON+0
;PIC2.c,115 :: 		while (PORTB & 0x02); // Wait for echo end
L_read_sonar19:
	BTFSS      PORTB+0, 1
	GOTO       L_read_sonar20
	GOTO       L_read_sonar19
L_read_sonar20:
;PIC2.c,116 :: 		T1CON = 0x18; // Timer1 OFF
	MOVLW      24
	MOVWF      T1CON+0
;PIC2.c,118 :: 		T1counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
	MOVF       TMR1H+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       TMR1L+0, 0
	IORWF      R0+0, 0
	MOVWF      R8+0
	MOVF       R0+1, 0
	MOVWF      R8+1
	MOVLW      0
	IORWF      R8+1, 1
	MOVF       _T1overflow+1, 0
	MOVWF      R4+3
	MOVF       _T1overflow+0, 0
	MOVWF      R4+2
	CLRF       R4+0
	CLRF       R4+1
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	CLRF       R0+2
	CLRF       R0+3
	MOVF       R4+0, 0
	ADDWF      R0+0, 1
	MOVF       R4+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     R4+1, 0
	ADDWF      R0+1, 1
	MOVF       R4+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     R4+2, 0
	ADDWF      R0+2, 1
	MOVF       R4+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     R4+3, 0
	ADDWF      R0+3, 1
	MOVF       R0+0, 0
	MOVWF      _T1counts+0
	MOVF       R0+1, 0
	MOVWF      _T1counts+1
	MOVF       R0+2, 0
	MOVWF      _T1counts+2
	MOVF       R0+3, 0
	MOVWF      _T1counts+3
;PIC2.c,119 :: 		T1time = T1counts; // Time in microseconds
	MOVF       R0+0, 0
	MOVWF      _T1time+0
	MOVF       R0+1, 0
	MOVWF      _T1time+1
	MOVF       R0+2, 0
	MOVWF      _T1time+2
	MOVF       R0+3, 0
	MOVWF      _T1time+3
;PIC2.c,120 :: 		Distance = ((T1time * 34) / 1000) / 2; // Distance in cm
	MOVLW      34
	MOVWF      R4+0
	CLRF       R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Mul_32x32_U+0
	MOVLW      232
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CLRF       R4+2
	CLRF       R4+3
	CALL       _Div_32x32_U+0
	MOVF       R0+0, 0
	MOVWF      _Distance+0
	MOVF       R0+1, 0
	MOVWF      _Distance+1
	MOVF       R0+2, 0
	MOVWF      _Distance+2
	MOVF       R0+3, 0
	MOVWF      _Distance+3
	RRF        _Distance+3, 1
	RRF        _Distance+2, 1
	RRF        _Distance+1, 1
	RRF        _Distance+0, 1
	BCF        _Distance+3, 7
;PIC2.c,121 :: 		}
L_end_read_sonar:
	RETURN
; end of _read_sonar

_init_sonar:

;PIC2.c,123 :: 		void init_sonar(void) {
;PIC2.c,124 :: 		T1overflow = 0;
	CLRF       _T1overflow+0
	CLRF       _T1overflow+1
;PIC2.c,125 :: 		T1counts = 0;
	CLRF       _T1counts+0
	CLRF       _T1counts+1
	CLRF       _T1counts+2
	CLRF       _T1counts+3
;PIC2.c,126 :: 		T1time = 0;
	CLRF       _T1time+0
	CLRF       _T1time+1
	CLRF       _T1time+2
	CLRF       _T1time+3
;PIC2.c,127 :: 		Distance = 0;
	CLRF       _Distance+0
	CLRF       _Distance+1
	CLRF       _Distance+2
	CLRF       _Distance+3
;PIC2.c,128 :: 		TMR1H = 0;
	CLRF       TMR1H+0
;PIC2.c,129 :: 		TMR1L = 0;
	CLRF       TMR1L+0
;PIC2.c,130 :: 		TRISB = 0x02; // RB2 Output (Trigger), RB1 Input (Echo)
	MOVLW      2
	MOVWF      TRISB+0
;PIC2.c,131 :: 		PORTB = 0x00;
	CLRF       PORTB+0
;PIC2.c,133 :: 		INTCON |= 0xC0; // Enable global and peripheral interrupts
	MOVLW      192
	IORWF      INTCON+0, 1
;PIC2.c,134 :: 		PIE1 |= 0x01;   // Enable Timer1 overflow interrupt
	BSF        PIE1+0, 0
;PIC2.c,135 :: 		T1CON = 0x18;   // Timer1 OFF, prescaler 1:2
	MOVLW      24
	MOVWF      T1CON+0
;PIC2.c,136 :: 		}
L_end_init_sonar:
	RETURN
; end of _init_sonar

_usDelay:

;PIC2.c,138 :: 		void usDelay(unsigned int usCnt) {
;PIC2.c,140 :: 		for (us = 0; us < usCnt; us++) {
	CLRF       R1+0
	CLRF       R1+1
L_usDelay21:
	MOVF       FARG_usDelay_usCnt+1, 0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__usDelay39
	MOVF       FARG_usDelay_usCnt+0, 0
	SUBWF      R1+0, 0
L__usDelay39:
	BTFSC      STATUS+0, 0
	GOTO       L_usDelay22
;PIC2.c,141 :: 		asm NOP;
	NOP
;PIC2.c,142 :: 		asm NOP;
	NOP
;PIC2.c,140 :: 		for (us = 0; us < usCnt; us++) {
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
;PIC2.c,143 :: 		}
	GOTO       L_usDelay21
L_usDelay22:
;PIC2.c,144 :: 		}
L_end_usDelay:
	RETURN
; end of _usDelay
