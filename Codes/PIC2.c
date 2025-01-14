unsigned int T1overflow;
unsigned long T1counts;
unsigned long T1time;
unsigned long Distance;
unsigned int Dcntr;
void usDelay(unsigned int);
void msDelay(unsigned int);

unsigned char cntr = 0;
void init_sonar(void);
void read_sonar(void);

void pwm_compare_mode_init(void);
void set_servo_position1(int degrees);
void delay(unsigned int);

// Interrupt Service Routine
void interrupt(void) {
    if (INTCON & 0x04) { // Timer0 overflow interrupt
        TMR0 = 248; // Reload Timer0
        Dcntr++;
        if (Dcntr == 500) { // After 500 ms
            Dcntr = 0;
            read_sonar();
        }
        INTCON &= 0xFB; // Clear T0IF
    }

    if (Distance < 23) {
        PORTD |= 0x08; // RD3 ON
        PORTB |= 0x08; // RB3 ON
    } else {
        PORTD &= ~0x08; // RD3 OFF
        PORTB &= ~0x08; // RB3 OFF
    }

    if (PIR1 & 0x04) { // CCP1 interrupt
        PIR1 &= 0xFB; // Clear CCP1 interrupt flag
    }

    if (PIR1 & 0x01) { // Timer1 overflow interrupt
        T1overflow++;
        PIR1 &= 0xFE; // Clear Timer1 overflow flag
    }

    if (INTCON & 0x02) { // External Interrupt
        INTCON &= 0xFD; // Clear External Interrupt flag
    }
}

void pwm_compare_mode_init(void) {
    TRISC &= ~0x04;   // Set RC2 (CCP1) as output
    CCP1CON = 0x08;   // Set CCP1 in Compare Mode
    T1CON = 0x30;     // Timer1 with prescaler 1:8, OFF initially
    TMR1H = 0;        // Clear Timer1 High byte
    TMR1L = 0;        // Clear Timer1 Low byte
}

void set_servo_position1(int degrees) {
    unsigned int pulse_width = (degrees + 90) * 8 + 500; // Calculate pulse width in microseconds
    unsigned int compare_value = (pulse_width * 2);      // Convert to Timer1 ticks (with prescaler 1:8)

    CCPR1H = (compare_value >> 8); // Set high byte of compare value
    CCPR1L = (compare_value & 0xFF); // Set low byte of compare value

    T1CON |= 0x01; // Start Timer1

    while (!(PIR1 & 0x04)); // Wait for CCP1 interrupt flag
    PIR1 &= 0xFB; // Clear CCP1 interrupt flag

    PORTC |= 0x04; // Set RC2 high
    delay(pulse_width / 1000); // Wait for pulse duration (in milliseconds)
    PORTC &= ~0x04; // Set RC2 low
}

void delay(unsigned int msCnt) {
    unsigned int ms;
    for (ms = 0; ms < msCnt; ms++) {
        unsigned int us;
        for (us = 0; us < 155; us++) {
            asm NOP;
        }
    }
}

void main() {
    TRISD = 0x00; // Set PORTD as output
    TRISB = 0x02; // RB2 (Trigger) Output, RB1 (Echo) Input

    pwm_compare_mode_init();
    init_sonar();

    OPTION_REG = 0x87; // Timer0 prescaler setup
    INTCON = 0xF0;     // Enable global, Timer0, Timer1, and peripheral interrupts

    while (1) {
        set_servo_position1(-70);
        delay(400);
        set_servo_position1(10);
        delay(400);
    }
}

void read_sonar(void) {
    T1overflow = 0;
    TMR1H = 0;
    TMR1L = 0;

    PORTB |= 0x04; // Trigger ultrasonic sensor
    usDelay(10);
    PORTB &= ~0x04; // Stop trigger

    while (!(PORTB & 0x02)); // Wait for echo start
    T1CON = 0x19; // Timer1 ON
    while (PORTB & 0x02); // Wait for echo end
    T1CON = 0x18; // Timer1 OFF

    T1counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
    T1time = T1counts; // Time in microseconds
    Distance = ((T1time * 34) / 1000) / 2; // Distance in cm
}

void init_sonar(void) {
    T1overflow = 0;
    T1counts = 0;
    T1time = 0;
    Distance = 0;
    TMR1H = 0;
    TMR1L = 0;
    TRISB = 0x02; // RB2 Output (Trigger), RB1 Input (Echo)
    PORTB = 0x00;

    INTCON |= 0xC0; // Enable global and peripheral interrupts
    PIE1 |= 0x01;   // Enable Timer1 overflow interrupt
    T1CON = 0x18;   // Timer1 OFF, prescaler 1:2
}

void usDelay(unsigned int usCnt) {
    unsigned int us;
    for (us = 0; us < usCnt; us++) {
        asm NOP;
        asm NOP;
    }
}
