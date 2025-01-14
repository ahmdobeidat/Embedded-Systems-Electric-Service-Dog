
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;PIC1.c,43 :: 		void interrupt() {
;PIC1.c,44 :: 		if (INTCON & 0x02) {  // External Interrupt
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt0
;PIC1.c,45 :: 		while (PORTB & 0x01) {  // Trigger active
L_interrupt1:
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt2
;PIC1.c,46 :: 		stop_car(); // Stop the car if the trigger is active
	CALL       _stop_car+0
;PIC1.c,47 :: 		delay_ms(500);
	MOVLW      6
	MOVWF      R11+0
	MOVLW      19
	MOVWF      R12+0
	MOVLW      173
	MOVWF      R13+0
L_interrupt3:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt3
	DECFSZ     R12+0, 1
	GOTO       L_interrupt3
	DECFSZ     R11+0, 1
	GOTO       L_interrupt3
	NOP
	NOP
;PIC1.c,48 :: 		drive_backward();
	CALL       _drive_backward+0
;PIC1.c,49 :: 		delay_ms(700);
	MOVLW      8
	MOVWF      R11+0
	MOVLW      27
	MOVWF      R12+0
	MOVLW      39
	MOVWF      R13+0
L_interrupt4:
	DECFSZ     R13+0, 1
	GOTO       L_interrupt4
	DECFSZ     R12+0, 1
	GOTO       L_interrupt4
	DECFSZ     R11+0, 1
	GOTO       L_interrupt4
;PIC1.c,50 :: 		}
	GOTO       L_interrupt1
L_interrupt2:
;PIC1.c,51 :: 		INTCON &= ~0x02;  // Clear External Interrupt flag
	BCF        INTCON+0, 1
;PIC1.c,52 :: 		}
L_interrupt0:
;PIC1.c,53 :: 		}
L_end_interrupt:
L__interrupt40:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_init_interrupts:

;PIC1.c,55 :: 		void init_interrupts() {
;PIC1.c,56 :: 		INTCON = 0x00;       // Clear INTCON register
	CLRF       INTCON+0
;PIC1.c,57 :: 		INTE_bit = 1;            // Enable external interrupt on INT0
	BSF        INTE_bit+0, BitPos(INTE_bit+0)
;PIC1.c,58 :: 		INTEDG_bit = 1;          // Set INT0 to trigger on rising edge
	BSF        INTEDG_bit+0, BitPos(INTEDG_bit+0)
;PIC1.c,59 :: 		GIE_bit = 1;             // Enable global interrupts
	BSF        GIE_bit+0, BitPos(GIE_bit+0)
;PIC1.c,60 :: 		}
L_end_init_interrupts:
	RETURN
; end of _init_interrupts

_init_ADC:

;PIC1.c,62 :: 		void init_ADC() {
;PIC1.c,63 :: 		TRISA = 0xFF;        // Set PORTA as input for analog sensors
	MOVLW      255
	MOVWF      TRISA+0
;PIC1.c,64 :: 		TRISB = 0x09;        // RB3 as input (flame detector), others as output
	MOVLW      9
	MOVWF      TRISB+0
;PIC1.c,65 :: 		TRISC = 0x00;        // RC pins as outputs (motors, reverse LED)
	CLRF       TRISC+0
;PIC1.c,66 :: 		TRISD = 0x51;        // RD4 and RD6 as inputs (motion and extra buzzer)
	MOVLW      81
	MOVWF      TRISD+0
;PIC1.c,67 :: 		PORTB = 0x00;        // Initialize PORTB to 0 (LEDs off)
	CLRF       PORTB+0
;PIC1.c,68 :: 		PORTC = 0x00;        // Initialize PORTC to 0 (motors off)
	CLRF       PORTC+0
;PIC1.c,69 :: 		PORTD = 0x00;        // Initialize PORTD to 0 (buzzers off)
	CLRF       PORTD+0
;PIC1.c,71 :: 		ADCON1 = 0x06;  // Configure analog inputs
	MOVLW      6
	MOVWF      ADCON1+0
;PIC1.c,72 :: 		ADCON0 = 0x01;  // Enable ADC and select channel 0
	MOVLW      1
	MOVWF      ADCON0+0
;PIC1.c,73 :: 		}
L_end_init_ADC:
	RETURN
; end of _init_ADC

_init_PWM:

;PIC1.c,75 :: 		void init_PWM() {
;PIC1.c,76 :: 		TRISC &= ~(0x04);  // Set RC2 as output for PWM
	BCF        TRISC+0, 2
;PIC1.c,77 :: 		PR2 = 249;         // Set PWM period for ~1 kHz frequency
	MOVLW      249
	MOVWF      PR2+0
;PIC1.c,78 :: 		T2CON = 0x07;      // Enable Timer2 with 1:16 prescaler
	MOVLW      7
	MOVWF      T2CON+0
;PIC1.c,79 :: 		CCP1CON = 0x0C;    // Set CCP1 to PWM mode
	MOVLW      12
	MOVWF      CCP1CON+0
;PIC1.c,80 :: 		TMR2 = 1;        // Turn on Timer2
	MOVLW      1
	MOVWF      TMR2+0
;PIC1.c,81 :: 		}
L_end_init_PWM:
	RETURN
; end of _init_PWM

_set_pwm_duty_cycle:

;PIC1.c,83 :: 		void set_pwm_duty_cycle(unsigned char duty) {
;PIC1.c,84 :: 		unsigned int duty_cycle = (duty * 10); // Scale 0-100 to 0-1000
	MOVF       FARG_set_pwm_duty_cycle_duty+0, 0
	MOVWF      R0+0
	MOVLW      10
	MOVWF      R4+0
	CALL       _Mul_8X8_U+0
;PIC1.c,85 :: 		CCPR1L = duty_cycle >> 2;              // Upper 8 bits
	MOVF       R0+0, 0
	MOVWF      R2+0
	MOVF       R0+1, 0
	MOVWF      R2+1
	RRF        R2+1, 1
	RRF        R2+0, 1
	BCF        R2+1, 7
	RRF        R2+1, 1
	RRF        R2+0, 1
	BCF        R2+1, 7
	MOVF       R2+0, 0
	MOVWF      CCPR1L+0
;PIC1.c,86 :: 		CCP1CON = (CCP1CON & 0xCF) | ((duty_cycle & 0x03) << 4); // Lower 2 bits
	MOVLW      207
	ANDWF      CCP1CON+0, 0
	MOVWF      R3+0
	MOVLW      3
	ANDWF      R0+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	IORWF      R3+0, 0
	MOVWF      CCP1CON+0
;PIC1.c,87 :: 		}
L_end_set_pwm_duty_cycle:
	RETURN
; end of _set_pwm_duty_cycle

_set_pwm_duty_cycle_interrupt:

;PIC1.c,88 :: 		void set_pwm_duty_cycle_interrupt(unsigned char duty) {
;PIC1.c,89 :: 		unsigned int duty_cycle = (duty * 10); // Scale 0-100 to 0-1000
	MOVF       FARG_set_pwm_duty_cycle_interrupt_duty+0, 0
	MOVWF      R0+0
	MOVLW      10
	MOVWF      R4+0
	CALL       _Mul_8X8_U+0
;PIC1.c,90 :: 		CCPR1L = duty_cycle >> 2;              // Upper 8 bits
	MOVF       R0+0, 0
	MOVWF      R2+0
	MOVF       R0+1, 0
	MOVWF      R2+1
	RRF        R2+1, 1
	RRF        R2+0, 1
	BCF        R2+1, 7
	RRF        R2+1, 1
	RRF        R2+0, 1
	BCF        R2+1, 7
	MOVF       R2+0, 0
	MOVWF      CCPR1L+0
;PIC1.c,91 :: 		CCP1CON = (CCP1CON & 0xCF) | ((duty_cycle & 0x03) << 4); // Lower 2 bits
	MOVLW      207
	ANDWF      CCP1CON+0, 0
	MOVWF      R3+0
	MOVLW      3
	ANDWF      R0+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	IORWF      R3+0, 0
	MOVWF      CCP1CON+0
;PIC1.c,92 :: 		}
L_end_set_pwm_duty_cycle_interrupt:
	RETURN
; end of _set_pwm_duty_cycle_interrupt

_ADC_Read:

;PIC1.c,94 :: 		unsigned int ADC_Read(unsigned char channel) {
;PIC1.c,95 :: 		ADCON0 = (ADCON0 & 0xC5) | (channel << 3);  // Select channel
	MOVLW      197
	ANDWF      ADCON0+0, 0
	MOVWF      R2+0
	MOVF       FARG_ADC_Read_channel+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVF       R0+0, 0
	IORWF      R2+0, 0
	MOVWF      ADCON0+0
;PIC1.c,96 :: 		ADCON0 |= 0x02;  // Start conversion
	BSF        ADCON0+0, 1
;PIC1.c,97 :: 		while (ADCON0 & 0x02);  // Wait for conversion to complete
L_ADC_Read5:
	BTFSS      ADCON0+0, 1
	GOTO       L_ADC_Read6
	GOTO       L_ADC_Read5
L_ADC_Read6:
;PIC1.c,98 :: 		return (ADRESH << 8) | ADRESL;  // Combine result
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;PIC1.c,99 :: 		}
L_end_ADC_Read:
	RETURN
; end of _ADC_Read

_drive_forward:

;PIC1.c,101 :: 		void drive_forward() {
;PIC1.c,102 :: 		PORTC &= ~(LEFT_WHEEL_BACKWARD | RIGHT_WHEEL_BACKWARD);
	MOVLW      183
	ANDWF      PORTC+0, 1
;PIC1.c,103 :: 		PORTC |= LEFT_WHEEL_FORWARD | RIGHT_WHEEL_FORWARD;
	MOVLW      33
	IORWF      PORTC+0, 1
;PIC1.c,104 :: 		set_pwm_duty_cycle(90);  // Set PWM duty cycle to 90%
	MOVLW      90
	MOVWF      FARG_set_pwm_duty_cycle_duty+0
	CALL       _set_pwm_duty_cycle+0
;PIC1.c,106 :: 		PORTC &= ~REVERSE_LED;  // Turn off reverse LED
	BTFSC      RC4_bit+0, BitPos(RC4_bit+0)
	GOTO       L__drive_forward48
	BSF        3, 0
	GOTO       L__drive_forward49
L__drive_forward48:
	BCF        3, 0
L__drive_forward49:
	CLRF       R0+0
	BTFSC      3, 0
	INCF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      PORTC+0, 1
;PIC1.c,107 :: 		}
L_end_drive_forward:
	RETURN
; end of _drive_forward

_drive_backward:

;PIC1.c,109 :: 		void drive_backward() {
;PIC1.c,110 :: 		PORTC &= ~(LEFT_WHEEL_FORWARD | RIGHT_WHEEL_FORWARD);
	MOVLW      222
	ANDWF      PORTC+0, 1
;PIC1.c,111 :: 		PORTC |= LEFT_WHEEL_BACKWARD | RIGHT_WHEEL_BACKWARD;
	MOVLW      72
	IORWF      PORTC+0, 1
;PIC1.c,112 :: 		PORTC |= REVERSE_LED;  // Turn on reverse LED
	CLRF       R0+0
	BTFSC      RC4_bit+0, BitPos(RC4_bit+0)
	INCF       R0+0, 1
	MOVF       R0+0, 0
	IORWF      PORTC+0, 1
;PIC1.c,113 :: 		}
L_end_drive_backward:
	RETURN
; end of _drive_backward

_rotate_left:

;PIC1.c,115 :: 		void rotate_left() {
;PIC1.c,116 :: 		PORTC &= ~(RIGHT_WHEEL_FORWARD | LEFT_WHEEL_BACKWARD);
	MOVLW      190
	ANDWF      PORTC+0, 1
;PIC1.c,117 :: 		PORTC |= RIGHT_WHEEL_BACKWARD | LEFT_WHEEL_FORWARD;
	MOVLW      40
	IORWF      PORTC+0, 1
;PIC1.c,118 :: 		set_pwm_duty_cycle(90);  // Set PWM duty cycle to 90%
	MOVLW      90
	MOVWF      FARG_set_pwm_duty_cycle_duty+0
	CALL       _set_pwm_duty_cycle+0
;PIC1.c,119 :: 		PORTC |= REVERSE_LED;  // Turn on reverse LED
	CLRF       R0+0
	BTFSC      RC4_bit+0, BitPos(RC4_bit+0)
	INCF       R0+0, 1
	MOVF       R0+0, 0
	IORWF      PORTC+0, 1
;PIC1.c,120 :: 		}
L_end_rotate_left:
	RETURN
; end of _rotate_left

_rotate_right:

;PIC1.c,122 :: 		void rotate_right() {
;PIC1.c,123 :: 		PORTC &= ~(LEFT_WHEEL_FORWARD | RIGHT_WHEEL_BACKWARD);
	MOVLW      215
	ANDWF      PORTC+0, 1
;PIC1.c,124 :: 		PORTC |= LEFT_WHEEL_BACKWARD | RIGHT_WHEEL_FORWARD;
	MOVLW      65
	IORWF      PORTC+0, 1
;PIC1.c,125 :: 		set_pwm_duty_cycle(90);  // Set PWM duty cycle to 90%
	MOVLW      90
	MOVWF      FARG_set_pwm_duty_cycle_duty+0
	CALL       _set_pwm_duty_cycle+0
;PIC1.c,126 :: 		PORTC &= ~REVERSE_LED;  // Turn off reverse LED
	BTFSC      RC4_bit+0, BitPos(RC4_bit+0)
	GOTO       L__rotate_right53
	BSF        3, 0
	GOTO       L__rotate_right54
L__rotate_right53:
	BCF        3, 0
L__rotate_right54:
	CLRF       R0+0
	BTFSC      3, 0
	INCF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      PORTC+0, 1
;PIC1.c,127 :: 		}
L_end_rotate_right:
	RETURN
; end of _rotate_right

_stop_car:

;PIC1.c,129 :: 		void stop_car() {
;PIC1.c,130 :: 		PORTC &= ~(LEFT_WHEEL_FORWARD | LEFT_WHEEL_BACKWARD | RIGHT_WHEEL_FORWARD | RIGHT_WHEEL_BACKWARD);
	MOVLW      150
	ANDWF      PORTC+0, 1
;PIC1.c,131 :: 		}
L_end_stop_car:
	RETURN
; end of _stop_car

_msDelay:

;PIC1.c,133 :: 		void msDelay(unsigned int msCnt) {
;PIC1.c,135 :: 		for (ms = 0; ms < msCnt; ms++) {
	CLRF       R3+0
	CLRF       R3+1
L_msDelay7:
	MOVF       FARG_msDelay_msCnt+1, 0
	SUBWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay57
	MOVF       FARG_msDelay_msCnt+0, 0
	SUBWF      R3+0, 0
L__msDelay57:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay8
;PIC1.c,137 :: 		for (cc = 0; cc < 155; cc++);
	CLRF       R1+0
	CLRF       R1+1
L_msDelay10:
	MOVLW      0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay58
	MOVLW      155
	SUBWF      R1+0, 0
L__msDelay58:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay11
	INCF       R1+0, 1
	BTFSC      STATUS+0, 2
	INCF       R1+1, 1
	GOTO       L_msDelay10
L_msDelay11:
;PIC1.c,135 :: 		for (ms = 0; ms < msCnt; ms++) {
	INCF       R3+0, 1
	BTFSC      STATUS+0, 2
	INCF       R3+1, 1
;PIC1.c,138 :: 		}
	GOTO       L_msDelay7
L_msDelay8:
;PIC1.c,139 :: 		}
L_end_msDelay:
	RETURN
; end of _msDelay

_main:

;PIC1.c,141 :: 		void main() {
;PIC1.c,143 :: 		int motion_detected = 0;
	CLRF       main_motion_detected_L0+0
	CLRF       main_motion_detected_L0+1
	CLRF       main_buzzeri_state_L0+0
	CLRF       main_buzzeri_state_L0+1
;PIC1.c,146 :: 		init_ADC();
	CALL       _init_ADC+0
;PIC1.c,147 :: 		init_PWM();
	CALL       _init_PWM+0
;PIC1.c,148 :: 		init_interrupts();
	CALL       _init_interrupts+0
;PIC1.c,150 :: 		while (1) {
L_main13:
;PIC1.c,151 :: 		x_value = ADC_Read(2);  // Read X-axis joystick
	MOVLW      2
	MOVWF      FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0+0, 0
	MOVWF      main_x_value_L0+0
	MOVF       R0+1, 0
	MOVWF      main_x_value_L0+1
;PIC1.c,152 :: 		y_value = ADC_Read(3);  // Read Y-axis joystick
	MOVLW      3
	MOVWF      FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0+0, 0
	MOVWF      main_y_value_L0+0
	MOVF       R0+1, 0
	MOVWF      main_y_value_L0+1
;PIC1.c,154 :: 		if (x_value > 700) {
	MOVLW      128
	XORLW      2
	MOVWF      R0+0
	MOVLW      128
	XORWF      main_x_value_L0+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main60
	MOVF       main_x_value_L0+0, 0
	SUBLW      188
L__main60:
	BTFSC      STATUS+0, 0
	GOTO       L_main15
;PIC1.c,155 :: 		rotate_right();
	CALL       _rotate_right+0
;PIC1.c,156 :: 		} else if (x_value < 300) {
	GOTO       L_main16
L_main15:
	MOVLW      128
	XORWF      main_x_value_L0+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORLW      1
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main61
	MOVLW      44
	SUBWF      main_x_value_L0+0, 0
L__main61:
	BTFSC      STATUS+0, 0
	GOTO       L_main17
;PIC1.c,157 :: 		rotate_left();
	CALL       _rotate_left+0
;PIC1.c,158 :: 		} else if (y_value < 300) {
	GOTO       L_main18
L_main17:
	MOVLW      128
	XORWF      main_y_value_L0+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORLW      1
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main62
	MOVLW      44
	SUBWF      main_y_value_L0+0, 0
L__main62:
	BTFSC      STATUS+0, 0
	GOTO       L_main19
;PIC1.c,159 :: 		drive_backward();
	CALL       _drive_backward+0
;PIC1.c,160 :: 		} else if (y_value > 700) {
	GOTO       L_main20
L_main19:
	MOVLW      128
	XORLW      2
	MOVWF      R0+0
	MOVLW      128
	XORWF      main_y_value_L0+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main63
	MOVF       main_y_value_L0+0, 0
	SUBLW      188
L__main63:
	BTFSC      STATUS+0, 0
	GOTO       L_main21
;PIC1.c,161 :: 		drive_forward();
	CALL       _drive_forward+0
;PIC1.c,162 :: 		} else {
	GOTO       L_main22
L_main21:
;PIC1.c,163 :: 		stop_car();
	CALL       _stop_car+0
;PIC1.c,164 :: 		}
L_main22:
L_main20:
L_main18:
L_main16:
;PIC1.c,166 :: 		ldrValue = ADC_Read(0);  // Read LDR value
	CLRF       FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0+0, 0
	MOVWF      _ldrValue+0
	MOVF       R0+1, 0
	MOVWF      _ldrValue+1
;PIC1.c,167 :: 		if (ldrValue < 512) {
	MOVLW      2
	SUBWF      R0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main64
	MOVLW      0
	SUBWF      R0+0, 0
L__main64:
	BTFSC      STATUS+0, 0
	GOTO       L_main23
;PIC1.c,168 :: 		PORTB |= (LED1 | LED2 | LED3 | LED4);  // Turn on all LEDs
	CLRF       R1+0
	BTFSC      RB4_bit+0, BitPos(RB4_bit+0)
	INCF       R1+0, 1
	CLRF       R0+0
	BTFSC      RB5_bit+0, BitPos(RB5_bit+0)
	INCF       R0+0, 1
	MOVF       R0+0, 0
	IORWF      R1+0, 1
	CLRF       R0+0
	BTFSC      RB6_bit+0, BitPos(RB6_bit+0)
	INCF       R0+0, 1
	MOVF       R0+0, 0
	IORWF      R1+0, 1
	CLRF       R0+0
	BTFSC      RB7_bit+0, BitPos(RB7_bit+0)
	INCF       R0+0, 1
	MOVF       R1+0, 0
	IORWF      R0+0, 1
	MOVF       R0+0, 0
	IORWF      PORTB+0, 1
;PIC1.c,169 :: 		} else {
	GOTO       L_main24
L_main23:
;PIC1.c,170 :: 		PORTB &= ~(LED1 | LED2 | LED3 | LED4); // Turn off all LEDs
	CLRF       R1+0
	BTFSC      RB4_bit+0, BitPos(RB4_bit+0)
	INCF       R1+0, 1
	CLRF       R0+0
	BTFSC      RB5_bit+0, BitPos(RB5_bit+0)
	INCF       R0+0, 1
	MOVF       R0+0, 0
	IORWF      R1+0, 1
	CLRF       R0+0
	BTFSC      RB6_bit+0, BitPos(RB6_bit+0)
	INCF       R0+0, 1
	MOVF       R0+0, 0
	IORWF      R1+0, 1
	CLRF       R0+0
	BTFSC      RB7_bit+0, BitPos(RB7_bit+0)
	INCF       R0+0, 1
	MOVF       R1+0, 0
	IORWF      R0+0, 1
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      PORTB+0, 1
;PIC1.c,171 :: 		}
L_main24:
;PIC1.c,173 :: 		if (FLAME_DETECTOR) {    // Flame detected
	BTFSS      RB3_bit+0, BitPos(RB3_bit+0)
	GOTO       L_main25
;PIC1.c,174 :: 		FLAME_LED = 1;       // Turn on flame indicator LED
	BSF        RB2_bit+0, BitPos(RB2_bit+0)
;PIC1.c,175 :: 		BLUE_LED = 0;
	BCF        RB1_bit+0, BitPos(RB1_bit+0)
;PIC1.c,176 :: 		while(FLAME_DETECTOR){
L_main26:
	BTFSS      RB3_bit+0, BitPos(RB3_bit+0)
	GOTO       L_main27
;PIC1.c,177 :: 		RD7_bit=1;
	BSF        RD7_bit+0, BitPos(RD7_bit+0)
;PIC1.c,178 :: 		delay_ms(300);
	MOVLW      4
	MOVWF      R11+0
	MOVLW      12
	MOVWF      R12+0
	MOVLW      51
	MOVWF      R13+0
L_main28:
	DECFSZ     R13+0, 1
	GOTO       L_main28
	DECFSZ     R12+0, 1
	GOTO       L_main28
	DECFSZ     R11+0, 1
	GOTO       L_main28
	NOP
	NOP
;PIC1.c,179 :: 		RD7_bit=0;
	BCF        RD7_bit+0, BitPos(RD7_bit+0)
;PIC1.c,180 :: 		delay_ms(300);
	MOVLW      4
	MOVWF      R11+0
	MOVLW      12
	MOVWF      R12+0
	MOVLW      51
	MOVWF      R13+0
L_main29:
	DECFSZ     R13+0, 1
	GOTO       L_main29
	DECFSZ     R12+0, 1
	GOTO       L_main29
	DECFSZ     R11+0, 1
	GOTO       L_main29
	NOP
	NOP
;PIC1.c,182 :: 		}} else {                 // No flame detected
	GOTO       L_main26
L_main27:
	GOTO       L_main30
L_main25:
;PIC1.c,183 :: 		FLAME_LED = 0;       // Turn off flame indicator LED
	BCF        RB2_bit+0, BitPos(RB2_bit+0)
;PIC1.c,184 :: 		BLUE_LED = 1;
	BSF        RB1_bit+0, BitPos(RB1_bit+0)
;PIC1.c,185 :: 		RD7_bit=0;        // Turn on blue LED (no flame indicator)
	BCF        RD7_bit+0, BitPos(RD7_bit+0)
;PIC1.c,186 :: 		}
L_main30:
;PIC1.c,189 :: 		motion_detected = 0;
	CLRF       main_motion_detected_L0+0
	CLRF       main_motion_detected_L0+1
;PIC1.c,190 :: 		if (PORTD & MOTION_DETECTOR) {
	CLRF       R0+0
	BTFSC      RD4_bit+0, BitPos(RD4_bit+0)
	INCF       R0+0, 1
	MOVF       PORTD+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_main31
;PIC1.c,191 :: 		msDelay(10);
	MOVLW      10
	MOVWF      FARG_msDelay_msCnt+0
	MOVLW      0
	MOVWF      FARG_msDelay_msCnt+1
	CALL       _msDelay+0
;PIC1.c,192 :: 		if (PORTD & MOTION_DETECTOR) {
	CLRF       R0+0
	BTFSC      RD4_bit+0, BitPos(RD4_bit+0)
	INCF       R0+0, 1
	MOVF       PORTD+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_main32
;PIC1.c,193 :: 		motion_detected = 1;
	MOVLW      1
	MOVWF      main_motion_detected_L0+0
	MOVLW      0
	MOVWF      main_motion_detected_L0+1
;PIC1.c,194 :: 		}
L_main32:
;PIC1.c,195 :: 		}
L_main31:
;PIC1.c,196 :: 		PORTD = (PORTD & ~MLED) | (motion_detected ? MLED : 0);
	BTFSC      RD5_bit+0, BitPos(RD5_bit+0)
	GOTO       L__main65
	BSF        3, 0
	GOTO       L__main66
L__main65:
	BCF        3, 0
L__main66:
	CLRF       R0+0
	BTFSC      3, 0
	INCF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      PORTD+0, 0
	MOVWF      R1+0
	MOVF       main_motion_detected_L0+0, 0
	IORWF      main_motion_detected_L0+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main33
	BTFSC      RD5_bit+0, BitPos(RD5_bit+0)
	GOTO       L__main67
	BCF        ?FLOC___mainT82+0, BitPos(?FLOC___mainT82+0)
	GOTO       L__main68
L__main67:
	BSF        ?FLOC___mainT82+0, BitPos(?FLOC___mainT82+0)
L__main68:
	GOTO       L_main34
L_main33:
	BCF        ?FLOC___mainT82+0, BitPos(?FLOC___mainT82+0)
L_main34:
	CLRF       R0+0
	BTFSC      ?FLOC___mainT82+0, BitPos(?FLOC___mainT82+0)
	INCF       R0+0, 1
	MOVF       R0+0, 0
	IORWF      R1+0, 0
	MOVWF      PORTD+0
;PIC1.c,198 :: 		buzzeri_state = 0;
	CLRF       main_buzzeri_state_L0+0
	CLRF       main_buzzeri_state_L0+1
;PIC1.c,199 :: 		if (PORTD & BUZZERI) {
	CLRF       R0+0
	BTFSC      RD6_bit+0, BitPos(RD6_bit+0)
	INCF       R0+0, 1
	MOVF       PORTD+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_main35
;PIC1.c,200 :: 		msDelay(10);
	MOVLW      10
	MOVWF      FARG_msDelay_msCnt+0
	MOVLW      0
	MOVWF      FARG_msDelay_msCnt+1
	CALL       _msDelay+0
;PIC1.c,201 :: 		if (PORTD & BUZZERI) {
	CLRF       R0+0
	BTFSC      RD6_bit+0, BitPos(RD6_bit+0)
	INCF       R0+0, 1
	MOVF       PORTD+0, 0
	ANDWF      R0+0, 1
	BTFSC      STATUS+0, 2
	GOTO       L_main36
;PIC1.c,202 :: 		buzzeri_state = 1;
	MOVLW      1
	MOVWF      main_buzzeri_state_L0+0
	MOVLW      0
	MOVWF      main_buzzeri_state_L0+1
;PIC1.c,203 :: 		}
L_main36:
;PIC1.c,204 :: 		}
L_main35:
;PIC1.c,205 :: 		PORTB = (PORTB & ~BUZZER) | (buzzeri_state ? BUZZER : 0);
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L__main69
	BSF        3, 0
	GOTO       L__main70
L__main69:
	BCF        3, 0
L__main70:
	CLRF       R0+0
	BTFSC      3, 0
	INCF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      PORTB+0, 0
	MOVWF      R1+0
	MOVF       main_buzzeri_state_L0+0, 0
	IORWF      main_buzzeri_state_L0+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main37
	BTFSC      RB0_bit+0, BitPos(RB0_bit+0)
	GOTO       L__main71
	BCF        ?FLOC___mainT92+0, BitPos(?FLOC___mainT92+0)
	GOTO       L__main72
L__main71:
	BSF        ?FLOC___mainT92+0, BitPos(?FLOC___mainT92+0)
L__main72:
	GOTO       L_main38
L_main37:
	BCF        ?FLOC___mainT92+0, BitPos(?FLOC___mainT92+0)
L_main38:
	CLRF       R0+0
	BTFSC      ?FLOC___mainT92+0, BitPos(?FLOC___mainT92+0)
	INCF       R0+0, 1
	MOVF       R0+0, 0
	IORWF      R1+0, 0
	MOVWF      PORTB+0
;PIC1.c,207 :: 		msDelay(100);
	MOVLW      100
	MOVWF      FARG_msDelay_msCnt+0
	MOVLW      0
	MOVWF      FARG_msDelay_msCnt+1
	CALL       _msDelay+0
;PIC1.c,208 :: 		}
	GOTO       L_main13
;PIC1.c,209 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
