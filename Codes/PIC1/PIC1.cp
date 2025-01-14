#line 1 "C:/Users/20210325/Desktop/PIC1/PIC1.c"
#line 26 "C:/Users/20210325/Desktop/PIC1/PIC1.c"
unsigned int ldrValue;



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


void interrupt() {
 if (INTCON & 0x02) {
 while (PORTB & 0x01) {
 stop_car();
 delay_ms(500);
 drive_backward();
 delay_ms(700);
 }
 INTCON &= ~0x02;
 }
}

void init_interrupts() {
 INTCON = 0x00;
 INTE_bit = 1;
 INTEDG_bit = 1;
 GIE_bit = 1;
}

void init_ADC() {
 TRISA = 0xFF;
 TRISB = 0x09;
 TRISC = 0x00;
 TRISD = 0x51;
 PORTB = 0x00;
 PORTC = 0x00;
 PORTD = 0x00;

 ADCON1 = 0x06;
 ADCON0 = 0x01;
}

void init_PWM() {
 TRISC &= ~(0x04);
 PR2 = 249;
 T2CON = 0x07;
 CCP1CON = 0x0C;
 TMR2 = 1;
}

void set_pwm_duty_cycle(unsigned char duty) {
 unsigned int duty_cycle = (duty * 10);
 CCPR1L = duty_cycle >> 2;
 CCP1CON = (CCP1CON & 0xCF) | ((duty_cycle & 0x03) << 4);
}
void set_pwm_duty_cycle_interrupt(unsigned char duty) {
 unsigned int duty_cycle = (duty * 10);
 CCPR1L = duty_cycle >> 2;
 CCP1CON = (CCP1CON & 0xCF) | ((duty_cycle & 0x03) << 4);
}

unsigned int ADC_Read(unsigned char channel) {
 ADCON0 = (ADCON0 & 0xC5) | (channel << 3);
 ADCON0 |= 0x02;
 while (ADCON0 & 0x02);
 return (ADRESH << 8) | ADRESL;
}

void drive_forward() {
 PORTC &= ~( 0x40  |  0x08 );
 PORTC |=  0x20  |  0x01 ;
 set_pwm_duty_cycle(90);

 PORTC &= ~ RC4_bit ;
}

void drive_backward() {
 PORTC &= ~( 0x20  |  0x01 );
 PORTC |=  0x40  |  0x08 ;
 PORTC |=  RC4_bit ;
}

void rotate_left() {
 PORTC &= ~( 0x01  |  0x40 );
 PORTC |=  0x08  |  0x20 ;
 set_pwm_duty_cycle(90);
 PORTC |=  RC4_bit ;
}

void rotate_right() {
 PORTC &= ~( 0x20  |  0x08 );
 PORTC |=  0x40  |  0x01 ;
 set_pwm_duty_cycle(90);
 PORTC &= ~ RC4_bit ;
}

void stop_car() {
 PORTC &= ~( 0x20  |  0x40  |  0x01  |  0x08 );
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
 x_value = ADC_Read(2);
 y_value = ADC_Read(3);

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

 ldrValue = ADC_Read(0);
 if (ldrValue < 512) {
 PORTB |= ( RB4_bit  |  RB5_bit  |  RB6_bit  |  RB7_bit );
 } else {
 PORTB &= ~( RB4_bit  |  RB5_bit  |  RB6_bit  |  RB7_bit );
 }

 if ( RB3_bit ) {
  RB2_bit  = 1;
  RB1_bit  = 0;
 while( RB3_bit ){
 RD7_bit=1;
 delay_ms(300);
 RD7_bit=0;
 delay_ms(300);

 }} else {
  RB2_bit  = 0;
  RB1_bit  = 1;
 RD7_bit=0;
 }


 motion_detected = 0;
 if (PORTD &  RD4_bit ) {
 msDelay(10);
 if (PORTD &  RD4_bit ) {
 motion_detected = 1;
 }
 }
 PORTD = (PORTD & ~ RD5_bit ) | (motion_detected ?  RD5_bit  : 0);

 buzzeri_state = 0;
 if (PORTD &  RD6_bit ) {
 msDelay(10);
 if (PORTD &  RD6_bit ) {
 buzzeri_state = 1;
 }
 }
 PORTB = (PORTB & ~ RB0_bit ) | (buzzeri_state ?  RB0_bit  : 0);

 msDelay(100);
 }
}
