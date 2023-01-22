#include "other_funcs.h"
#include "TM4C123GH6PM.h"

// Below function is used in miscellaneous places to create tiny delay between required operations.

void timer1_delay(void){ //Timer1 is used for a delay of 3 ms. It is created to eliminate debouncing.
SYSCTL->RCGCTIMER |=2; //Enable clock for timer 1
TIMER1->CTL =0; //Disable timer before initialization.
TIMER1->CFG = 0x04; // 16 bit timer is selected
TIMER1->TAMR = 0x02; // Periodic mode, since it is default down-counter, it counts down.
TIMER1->TAILR = 250 - 1; // Number to generate 150ms delay.
TIMER1->TAPR 	= 250 - 1 ; // 16 MHz / 250 = 64.000 Hz prescaler value . Resultingly, (1/64000) * 250 = 3.3 ms counting time will occur.
TIMER1->ICR 	= 0x1; // Clear timerA timeout flag, interrupts are cleared during initialization
TIMER1->CTL |= 0x01; // Enable timerA after initialization

	while ((TIMER1 -> RIS	& 0x1) == 0) // RIS will not become 1 until timer counts down. So, this while loop is on until 150ms passes.
	{
	}
TIMER1-> ICR = 0x1; // clear the TimerA timeout flag.	
}

void digit(int a){
int x_1,x_2,x_3,x_4;
	// first digit
x_1=a/1000;
	if(x_1==0){
	zero_0();
	}
	else if(x_1==1){
	one_1();
	}
	else if(x_1==2){
	two_2();
	}
	else if(x_1==3){
	three_3();
	}
	else if(x_1==4){
	four_4();
	}
	else if(x_1==5){
	five_5();
	}
	else if(x_1==6){
	six_6();
	}
	else if(x_1==7){
	seven_7();
	}
	else if(x_1==8){
	eight_8();
	}
	else {
	nine_9();
	}
// second digit
x_2=(a%1000)/100;
	if(x_2==0){
	zero_0();
	}
	else if(x_2==1){
	one_1();
	}
	else if(x_2==2){
	two_2();
	}
	else if(x_2==3){
	three_3();
	}
	else if(x_2==4){
	four_4();
	}
	else if(x_2==5){
	five_5();
	}
	else if(x_2==6){
	six_6();
	}
	else if(x_2==7){
	seven_7();
	}
	else if(x_2==8){
	eight_8();
	}
	else {
	nine_9();
	}
	//third digit
x_3=((a%1000)%100)/10;
if(x_3==0){
	zero_0();
	}
	else if(x_3==1){
	one_1();
	}
	else if(x_3==2){
	two_2();
	}
	else if(x_3==3){
	three_3();
	}
	else if(x_3==4){
	four_4();
	}
	else if(x_3==5){
	five_5();
	}
	else if(x_3==6){
	six_6();
	}
	else if(x_3==7){
	seven_7();
	}
	else if(x_3==8){
	eight_8();
	}
	else {
	nine_9();
	}
	//fourth digit
x_4=((a%1000)%100)%10;
if(x_4==0){
	zero_0();
	}
	else if(x_4==1){
	one_1();
	}
	else if(x_4==2){
	two_2();
	}
	else if(x_4==3){
	three_3();
	}
	else if(x_4==4){
	four_4();
	}
	else if(x_4==5){
	five_5();
	}
	else if(x_4==6){
	six_6();
	}
	else if(x_4==7){
	seven_7();
	}
	else if(x_4==8){
	eight_8();
	}
	else {
	nine_9();
	}
	}