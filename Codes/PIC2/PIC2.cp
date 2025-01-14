#line 1 "C:/Users/20210325/Desktop/PIC2/PIC2.c"
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


void interrupt(void) {
 if (INTCON & 0x04) {
 TMR0 = 248;
 Dcntr++;
 if (Dcntr == 500) {
 Dcntr = 0;
 read_sonar();
 }
 INTCON &= 0xFB;
 }

 if (Distance < 23) {
 PORTD |= 0x08;
 PORTB |= 0x08;
 } else {
 PORTD &= ~0x08;
 PORTB &= ~0x08;
 }

 if (PIR1 & 0x04) {
 PIR1 &= 0xFB;
 }

 if (PIR1 & 0x01) {
 T1overflow++;
 PIR1 &= 0xFE;
 }

 if (INTCON & 0x02) {
 INTCON &= 0xFD;
 }
}

void pwm_compare_mode_init(void) {
 TRISC &= ~0x04;
 CCP1CON = 0x08;
 T1CON = 0x30;
 TMR1H = 0;
 TMR1L = 0;
}

void set_servo_position1(int degrees) {
 unsigned int pulse_width = (degrees + 90) * 8 + 500;
 unsigned int compare_value = (pulse_width * 2);

 CCPR1H = (compare_value >> 8);
 CCPR1L = (compare_value & 0xFF);

 T1CON |= 0x01;

 while (!(PIR1 & 0x04));
 PIR1 &= 0xFB;

 PORTC |= 0x04;
 delay(pulse_width / 1000);
 PORTC &= ~0x04;
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
 TRISD = 0x00;
 TRISB = 0x02;

 pwm_compare_mode_init();
 init_sonar();

 OPTION_REG = 0x87;
 INTCON = 0xF0;

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

 PORTB |= 0x04;
 usDelay(10);
 PORTB &= ~0x04;

 while (!(PORTB & 0x02));
 T1CON = 0x19;
 while (PORTB & 0x02);
 T1CON = 0x18;

 T1counts = ((TMR1H << 8) | TMR1L) + (T1overflow * 65536);
 T1time = T1counts;
 Distance = ((T1time * 34) / 1000) / 2;
}

void init_sonar(void) {
 T1overflow = 0;
 T1counts = 0;
 T1time = 0;
 Distance = 0;
 TMR1H = 0;
 TMR1L = 0;
 TRISB = 0x02;
 PORTB = 0x00;

 INTCON |= 0xC0;
 PIE1 |= 0x01;
 T1CON = 0x18;
}

void usDelay(unsigned int usCnt) {
 unsigned int us;
 for (us = 0; us < usCnt; us++) {
 asm NOP;
 asm NOP;
 }
}
