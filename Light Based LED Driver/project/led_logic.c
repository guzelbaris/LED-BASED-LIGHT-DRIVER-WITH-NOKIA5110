#include "TM4C123GH6PM.h"
#include "led_logic.h"
#include "other_funcs.h"
#include <stdio.h>

//
extern void OutStr(char *);
//

int data = 0; // ADC data 
int lowthflag = 0; // Flags to use POT accordingly
int highthflag = 0; // Flags to use POT accordingly
int lowth = 300; // Default low threshold value
int highth = 600; // Default high threshold value


void led_gpio_init(void){ //Initialization of PF1,PF2 and PF3
	
	SYSCTL->RCGCGPIO |= 0x20; // Turn on bus clock for GPIOF
	while (! SYSCTL->PRGPIO) {}
		
  GPIOF->DIR			|= (7<<1); //set PF1,PF2 and PF3 as output
  GPIOF->AFSEL		&= ~(7<<1);  // Regular port function for PF1, PF2 and PF3.
	GPIOF->PCTL			&= ~(0xFFFFFFFF);  // Clear port control
	GPIOF->AMSEL		&= ~(7<<1);  //Disable analog for all pins
	GPIOF->DEN			|= (7<<1); // Enable port digital for PF1, PF2 and PF3.
		
}


void adc_gpio_init (void) // PE3 will be connected to the POT
{
	
	SYSCTL->RCGCGPIO |= 0x10; // Turn on bus clock for GPIOE
	while (!SYSCTL->PRGPIO) {} // Wait for it to open
  GPIOE->DIR			&= ~(1<<3); //Set PE3 as input
  GPIOE->AFSEL		|= (1<<3);  // Regular port function for PE3
	GPIOE->PCTL			&= ~(0xFFFFFFFF);  // Clear port control since AIN default value will be used
	GPIOE->AMSEL		|= (1<<3); //Enable analog for all pins
	GPIOE->DEN			&= ~(1<<3); // Disable port digital for PE3
		
}

void adc_init(void){ // Configure ADC itself
	
	SYSCTL->RCGCADC |= 1; // Enable clock for ADC 0
	while (! SYSCTL->PRADC) {} // Wait until ADC clock opens
	ADC0->ACTSS &= ~(1<<3); //Disable SS3 during setup
	ADC0->EMUX  &= ~(0xF000); //Select SS3 event mux as processor(default)
	ADC0->SSMUX3 &=~(0xF);		// Select SS3 input as AIN0
	ADC0->SSCTL3 |= (0x6);		//No differential input (b0=0),  Sampling ends at this input (b1=1)	, Interrupt Enable (b2=1), No temperature select (b3=0)
	ADC0->PC			|=(0x1);		//125Ksps	sampling rate select
	ADC0->ACTSS |= (1<<3); //Enable SS3 after setup
		
}

void push_buttons_init (void) // PF0 -> Low Threshold Setting, PF4 -> High Threshold Setting.
	
{
	SYSCTL->RCGCGPIO |= 0x20; // Turn on bus clock for GPIOF (Already open but put here anyways)
	while (! SYSCTL->PRGPIO) {} // Wait Until Clock is ON
		
	GPIOF->LOCK = 0x4C4F434B;   // Unlock GPIOCR register
  GPIOF->CR = 0x11;           // Enable Commit for PF0 and PF4
  GPIOF->PUR |= 0x11;        // Enable Pull Up resistor PF4 and PF0
  GPIOF->DIR &= ~(0x11);      //Set PF0 and PF4 as input.
  GPIOF->DEN |= 0x11;         // Enable PF0 and PF4 digital pins
		
	GPIOF->IS					&= ~(0x11); // Interrupt sense edge detect for PF4 and PF0
	GPIOF->IBE				&= ~(0x11); // Not both edges
	GPIOF->IEV				&= ~(0x11); // Falling edge
	GPIOF->IM					|= (0x11); // Interrupt not masked
	GPIOF->ICR				|= (0x11); // Interrupt is cleared
	NVIC->ISER[0]			|= (1<<30); // In the NVIC table, in the row0 , portF interrupts are enabled. NVIC table [0] = [A B C D E ............ F(30) G(31)]

}


void GPIOF_Handler (void) { // Decision of which threshold is going to be changed in the POT.
	
	if(GPIOF->RIS & 0x01) // PF0 has created an interrupt. We have to perform low threshold setting.
	{
		
		if (highthflag) // If high threshold setting were used before
		{
			highthflag = 0;
			lowthflag = 1;
			timer1_delay(); // Wait for debouncing to disappear to prevent further interrupts.
			GPIOF->ICR |= (1<<0); // PF0 interrupt is cleared after operation is done.
			return;
		}
		lowthflag = 1; // Else, set the lowthflag.
		timer1_delay(); // Wait for debouncing to disappear to prevent further interrupts.
		GPIOF->ICR |= (1<<0); // PF0 interrupt is cleared after operation is done.
		return;
		
	}
	
	else if (GPIOF->RIS & 0x10) // PF4 has created an interrupt. We have to perform low threshold setting.
	{
		
		if (lowthflag) // If low threshold setting were used before
		{
		lowthflag = 0;
		highthflag = 1;
		timer1_delay(); // Wait for debouncing to disappear to prevent further interrupts.
		GPIOF->ICR |= (1<<4); // PF4 interrupt is cleared after operation is done.
		return;
		}
		highthflag = 1; // Else, set the highthflag
		timer1_delay(); // Wait for debouncing to disappear to prevent further interrupts.
		GPIOF->ICR |= (1<<4); // PF4 interrupt is cleared after operation is done.
		return;
		
	}
	
}

void adjust (void){ // Potentiometer setting
	
	ADC0->PSSI |= (1<<3); // Start sampling (Processor Sample Sequence Initiate)
	while((ADC0->RIS & 0x8) == 0){} // Wait until an interrupt occurs.
	data = ADC0->SSFIFO3;  // Fetch the adc data. Thresholds can differ between [0,4095]
		
	if (highthflag && !lowthflag) // High threshold will be set.
	{
		if(data < lowth) // High threshold cannot drop below low threshold
			data = lowth + 5;
		
		highth = data; // Set the high threshold.
		lowth = lowth; // Lowth is the same
		ADC0->ISC |= (1<<3); //  Clear interrupt
		return;
	}
	else if (lowthflag && !highthflag) // Low threshold will be set.
	{
		if (data > highth)
			data = highth - 5; // Low threshold cannot exceed high threshold.
		
		lowth = data;
		highth = highth; // Highth is the same
		ADC0->ISC |= (1<<3); //  Clear interrupt
		return;
		
	}
	else // Clear the interrupt without doing anything in other cases.
			ADC0->ISC |= (1<<3); //  Clear interrupt
	
	return;

}

void led_rgb (int lux) // Light up the onboard LEDs based on the lux data.
{
	if(lux <= lowth) // Red LED (PF1) should be ON
	{
		C_RED(); // Print "RED" into Nokia screen.
		GPIOF->DATA &= ~(7<<1); // Turn OFF the other LEDs
		GPIOF->DATA |= (1<<1); // Turn ON the Red LED
	}
	else if (lux > lowth && lux < highth) // Green LED (PF3) should be ON
	{
		C_GREEN(); // Print "GRN" into Nokia screen.
		GPIOF->DATA &= ~(7<<1); // Turn OFF the other LEDs
		GPIOF->DATA |= (1<<3); // Turn ON the Green LED
	}
	else // Blue LED (PF2) should be ON
	{
		C_BLUE(); // Print "BLUE" into Nokia screen.
		GPIOF->DATA &= ~(7<<1); // Turn OFF the other LEDs
		GPIOF->DATA |= (1<<2); // Turn ON the Blue LED
	}
}

int getlowth (void) // Function to be used in the main to attain low threshold.
{
	return lowth;
}

int gethighth (void) // Function to be used in the main to attain high threshold.
{
	return highth;
}

void pwm_init (void) // PC4 will be connected to the gate.
{
	
SYSCTL->RCGCPWM |= 0x01;       // Enable clock to PWM0 module
	while (!SYSCTL->PRPWM) {}  // Wait for clock to open
SYSCTL->RCGCGPIO |= 0x07;   // Enable system clock to PORTC
	while (!SYSCTL->PRGPIO) {} // Wait for clock to open
SYSCTL->RCC &= ~0x00100000; // Directly feed clock to PWM0 module without pre-divider

GPIOC->AFSEL |= (1<<4);     // Alternate function on PC4
GPIOC->PCTL &= ~(0x000F0000); // Clear PC4 just in case anything left
GPIOC->PCTL |= 0x00040000; // Make PC4 PWM0 output pin 
GPIOC->DEN |= (1<<4);      // Make PC4 digital

//Use generator 3 for PWM. Below is the setup for PWM0, Channel 6 for pin PC4.
		
PWM0->_3_CTL &= ~(1<<0);   // Disable PWM in the setup (initially)
PWM0->_3_CTL &= ~(1<<1);   // Down counter
PWM0->_3_GENA = 0x0000008C;// When counter matches with comparator A, drive PWM to low (8). When counter matches the value in LOAD, drive PWM to high (C).
PWM0->_3_LOAD = 16000;     // Set load value for 1kHz (16MHz/16000)
PWM0->_3_CMPA = 8000 - 1;   //Based on the calculated lux, duty cycle will change in the following parts. For now, it is arranged to 50% PWM.
PWM0->_3_CTL = 1;          // Enable PWM since initialization is finished.
PWM0->ENABLE = (1<<6);     // Enable PWM0 channel 6 output
		
}


void duty_cycle (int lux)
{
	if(lux > 1500) // 1500 lux will generate maximum PWM in our application, so it is limited here.
		lux = 1500;
	
	float tempduty = 16000.0 - ((lux/1500.0) * (16000.0)); // Arrange the value to be written to CMPA  register.
	PWM0->_3_CMPA = (int)tempduty - 1;
	
}

