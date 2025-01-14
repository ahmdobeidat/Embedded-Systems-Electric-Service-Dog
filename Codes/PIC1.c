#define RIGHT_WHEEL_FORWARD  0x01  // RC0
#define RIGHT_WHEEL_BACKWARD 0x08  // RC3
#define LEFT_WHEEL_FORWARD   0x20  // RC5
#define LEFT_WHEEL_BACKWARD  0x40  // RC6

// Define LEDs connected to PORTB
#define LED1 0x10  // LED1 connected to RB4
#define LED2 0x20  // LED2 connected to RB5
#define LED3 0x40  // LED3 connected to RB6
#define LED4 0x80  // LED4 connected to RB7

// Flame detector input and LEDs
#define FLAME_DETECTOR 0x08  // Flame detector input connected to RB3
#define FLAME_LED 0x04       // LED to indicate flame detection connected to RB2
#define BLUE_LED 0x02        // Blue LED to indicate no flame connected to RB1

// Motion detector and buzzer
#define MOTION_DETECTOR 0x10  // Motion detector input connected to RD4
#define MLED 0x20             // Active buzzer module connected to RD5
#define BUZZER 0x01           // Buzzer connected to RB0
#define BUZZERI 0x40          // Additional buzzer connected to RD6

// Reverse indicator LED
#define REVERSE_LED 0x10      // Reverse indicator LED connected to RC4

unsigned int ldrValue;

// Function prototypes
void init_ADC();
void init_PWM();
void set_pwm_duty_cycle(unsigned char duty);
void drive_forward();
void drive_backward();
void rotate_left();
void rotate_right();
void stop_car();
void msDelay(unsigned int msCnt);
unsigned int ADC_Read(unsigned char channel);
void init_interrupts();

// Interrupt Service Routine (ISR)
void interrupt() {
    if (INTCON & 0x02) {  // External Interrupt
        while (PORTB & 0x01) {  // Trigger active
            stop_car(); // Stop the car if the trigger is active
            delay_ms(500);
            rotate_right();
            delay_ms(700);
        }
        INTCON &= ~0x02;  // Clear External Interrupt flag
    }
}

void init_interrupts() {
    INTCON = 0x00;       // Clear INTCON register
    INTE_bit = 1;            // Enable external interrupt on INT0
    INTEDG_bit = 1;          // Set INT0 to trigger on rising edge
    GIE_bit = 1;             // Enable global interrupts
}

void init_ADC() {
    TRISA = 0xFF;        // Set PORTA as input for analog sensors
    TRISB = 0x09;        // RB3 as input (flame detector), others as output
    TRISC = 0x00;        // RC pins as outputs (motors, reverse LED)
    TRISD = 0x51;        // RD4 and RD6 as inputs (motion and extra buzzer)
    PORTB = 0x00;        // Initialize PORTB to 0 (LEDs off)
    PORTC = 0x00;        // Initialize PORTC to 0 (motors off)
    PORTD = 0x00;        // Initialize PORTD to 0 (buzzers off)

    ADCON1 = 0x06;  // Configure analog inputs
    ADCON0 = 0x01;  // Enable ADC and select channel 0
}

void init_PWM() {
    TRISC &= ~(0x04);  // Set RC2 as output for PWM
    PR2 = 249;         // Set PWM period for ~1 kHz frequency
    T2CON = 0x07;      // Enable Timer2 with 1:16 prescaler
    CCP1CON = 0x0C;    // Set CCP1 to PWM mode
    TMR2 = 1;        // Turn on Timer2
}

void set_pwm_duty_cycle(unsigned char duty) {
    unsigned int duty_cycle = (duty * 10); // Scale 0-100 to 0-1000
    CCPR1L = duty_cycle >> 2;              // Upper 8 bits
    CCP1CON = (CCP1CON & 0xCF) | ((duty_cycle & 0x03) << 4); // Lower 2 bits
}

unsigned int ADC_Read(unsigned char channel) {
    ADCON0 = (ADCON0 & 0xC5) | (channel << 3);  // Select channel
    ADCON0 |= 0x02;  // Start conversion
    while (ADCON0 & 0x02);  // Wait for conversion to complete
    return (ADRESH << 8) | ADRESL;  // Combine result
}

void drive_forward() {
    PORTC &= ~(LEFT_WHEEL_BACKWARD | RIGHT_WHEEL_BACKWARD);
    PORTC |= LEFT_WHEEL_FORWARD | RIGHT_WHEEL_FORWARD;
    set_pwm_duty_cycle(90);  // Set PWM duty cycle to 90%
    PORTC &= ~REVERSE_LED;  // Turn off reverse LED
}

void drive_backward() {
    PORTC &= ~(LEFT_WHEEL_FORWARD | RIGHT_WHEEL_FORWARD);
    PORTC |= LEFT_WHEEL_BACKWARD | RIGHT_WHEEL_BACKWARD;
    set_pwm_duty_cycle(90);  // Set PWM duty cycle to 90%
    PORTC |= REVERSE_LED;  // Turn on reverse LED
}

void rotate_left() {
    PORTC &= ~(RIGHT_WHEEL_FORWARD | LEFT_WHEEL_BACKWARD);
    PORTC |= RIGHT_WHEEL_BACKWARD | LEFT_WHEEL_FORWARD;
    set_pwm_duty_cycle(90);  // Set PWM duty cycle to 90%
    PORTC |= REVERSE_LED;  // Turn on reverse LED
}

void rotate_right() {
    PORTC &= ~(LEFT_WHEEL_FORWARD | RIGHT_WHEEL_BACKWARD);
    PORTC |= LEFT_WHEEL_BACKWARD | RIGHT_WHEEL_FORWARD;
    set_pwm_duty_cycle(90);  // Set PWM duty cycle to 90%
    PORTC &= ~REVERSE_LED;  // Turn off reverse LED
}

void stop_car() {
    PORTC &= ~(LEFT_WHEEL_FORWARD | LEFT_WHEEL_BACKWARD | RIGHT_WHEEL_FORWARD | RIGHT_WHEEL_BACKWARD);
}

void msDelay(unsigned int msCnt) {
    unsigned int ms;
    for (ms = 0; ms < msCnt; ms++) {
        unsigned int cc;
        for (cc = 0; cc < 155; cc++);
    }
}

void main() {
    int x_value, y_value;
    int motion_detected = 0;
    int buzzeri_state = 0;

    init_ADC();
    init_PWM();
    init_interrupts();

    while (1) {
        x_value = ADC_Read(2);  // Read X-axis joystick
        y_value = ADC_Read(3);  // Read Y-axis joystick

        if (x_value > 700) {
            rotate_right();
        } else if (x_value < 300) {
            rotate_left();
        } else if (y_value < 300) {
            drive_backward();
        } else if (y_value > 700) {
            drive_forward();
        } else {
            stop_car();
        }

        ldrValue = ADC_Read(0);  // Read LDR value
        if (ldrValue < 512) {
            PORTB |= (LED1 | LED2 | LED3 | LED4);  // Turn on all LEDs
        } else {
            PORTB &= ~(LED1 | LED2 | LED3 | LED4); // Turn off all LEDs
        }

          if (FLAME_DETECTOR) {    // Flame detected
            FLAME_LED = 1;       // Turn on flame indicator LED
            BLUE_LED = 0;
            while(FLAME_DETECTOR){
            RD7_bit=1;
            delay_ms(300);
            RD7_bit=0;
            delay_ms(300);    
                    // Turn off blue LED (no flame indicator)
        }} else {                 // No flame detected
            FLAME_LED = 0;       // Turn off flame indicator LED
            BLUE_LED = 1;
            RD7_bit=0;        // Turn on blue LED (no flame indicator)
        }


        motion_detected = 0;
        if (PORTD & MOTION_DETECTOR) {
            msDelay(10);
            if (PORTD & MOTION_DETECTOR) {
                motion_detected = 1;
            }
        }
        PORTD = (PORTD & ~MLED) | (motion_detected ? MLED : 0);

        buzzeri_state = 0;
        if (PORTD & BUZZERI) {
            msDelay(10);
            if (PORTD & BUZZERI) {
                buzzeri_state = 1;
            }
        }
        PORTB = (PORTB & ~BUZZER) | (buzzeri_state ? BUZZER : 0);

        msDelay(100);
    }
}
